#!/bin/bash

# 文章管理API一键部署脚本
# 功能：从拉取项目到启动完成的全流程自动化部署
# 用法: ./deploy.sh [选项]

set -e  # 遇到错误立即退出

# 默认配置
GIT_REPO="${GIT_REPO:-}"
PROJECT_DIR="${PROJECT_DIR:-./article-api}"
DB_HOST="${DB_HOST:-localhost}"
DB_PORT="${DB_PORT:-3306}"
DB_NAME="${DB_NAME:-article_db}"
DB_USER="${DB_USER:-root}"
DB_PASSWORD="${DB_PASSWORD:-root}"
APP_PORT="${APP_PORT:-8080}"
SKIP_GIT_CLONE=false
SKIP_DB_SETUP=false
SKIP_BUILD=false
AUTO_INSTALL_DEPS=false
INIT_DATA=true
APP_PID=""

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 打印带颜色的消息
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_step() {
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}\n"
}

# 显示帮助信息
show_help() {
    cat << EOF
文章管理API一键部署脚本

功能：从拉取项目到启动完成的全流程自动化部署

用法: $0 [选项]

选项:
  --git-repo URL          Git仓库地址（如果指定，将自动拉取项目）
  --project-dir DIR       项目目录路径 (默认: ./article-api)
  --db-host HOST         数据库主机地址 (默认: localhost)
  --db-port PORT         数据库端口 (默认: 3306)
  --db-name NAME         数据库名称 (默认: article_db)
  --db-user USER         数据库用户名 (默认: root)
  --db-password PASSWORD 数据库密码 (默认: root)
  --port PORT            应用端口 (默认: 8080)
  --skip-git-clone       跳过Git拉取步骤（如果项目已存在）
  --skip-db-setup        跳过数据库初始化步骤
  --skip-build           跳过编译步骤
  --auto-install-deps     自动安装缺失的依赖（需要sudo权限）
  --no-init-data         不导入初始测试数据
  --help                 显示帮助信息

环境变量:
  也可以通过环境变量设置参数:
  GIT_REPO, PROJECT_DIR, DB_HOST, DB_PORT, DB_NAME, DB_USER, DB_PASSWORD, APP_PORT

示例:
  # 从Git拉取并部署
  $0 --git-repo https://github.com/user/article-api.git --db-password secret --port 9090
  
  # 本地项目部署
  $0 --skip-git-clone --db-password secret --port 9090
  
  # 自动安装依赖并部署
  $0 --auto-install-deps --db-password secret
EOF
}

# 解析命令行参数
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --git-repo)
                GIT_REPO="$2"
                shift 2
                ;;
            --project-dir)
                PROJECT_DIR="$2"
                shift 2
                ;;
            --db-host)
                DB_HOST="$2"
                shift 2
                ;;
            --db-port)
                DB_PORT="$2"
                shift 2
                ;;
            --db-name)
                DB_NAME="$2"
                shift 2
                ;;
            --db-user)
                DB_USER="$2"
                shift 2
                ;;
            --db-password)
                DB_PASSWORD="$2"
                shift 2
                ;;
            --port)
                APP_PORT="$2"
                shift 2
                ;;
            --skip-git-clone)
                SKIP_GIT_CLONE=true
                shift
                ;;
            --skip-db-setup)
                SKIP_DB_SETUP=true
                shift
                ;;
            --skip-build)
                SKIP_BUILD=true
                shift
                ;;
            --auto-install-deps)
                AUTO_INSTALL_DEPS=true
                shift
                ;;
            --no-init-data)
                INIT_DATA=false
                shift
                ;;
            --help)
                show_help
                exit 0
                ;;
            *)
                print_error "未知参数: $1"
                show_help
                exit 1
                ;;
        esac
    done
}

# 检查命令是否存在
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# 检查并安装Java
check_java() {
    if command_exists java; then
        JAVA_VERSION=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}' | cut -d'.' -f1)
        if [ "$JAVA_VERSION" -ge 17 ]; then
            print_info "Java检查通过: $(java -version 2>&1 | head -n 1)"
            return 0
        else
            print_warn "Java版本过低，需要JDK 17+，当前版本: $JAVA_VERSION"
        fi
    else
        print_warn "未找到Java"
    fi
    
    if [ "$AUTO_INSTALL_DEPS" = true ]; then
        print_info "尝试自动安装Java 17..."
        install_java
    else
        print_error "请先安装JDK 17+，或使用 --auto-install-deps 参数自动安装"
        exit 1
    fi
}

# 安装Java
install_java() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if command_exists apt-get; then
            sudo apt-get update
            sudo apt-get install -y openjdk-17-jdk
        elif command_exists yum; then
            sudo yum install -y java-17-openjdk-devel
        else
            print_error "无法自动安装Java，请手动安装JDK 17+"
            exit 1
        fi
    else
        print_error "当前系统不支持自动安装Java，请手动安装JDK 17+"
        exit 1
    fi
}

# 检查并安装Maven
check_maven() {
    if command_exists mvn; then
        print_info "Maven检查通过: $(mvn -version | head -n 1)"
        return 0
    fi
    
    if [ "$AUTO_INSTALL_DEPS" = true ]; then
        print_info "尝试自动安装Maven..."
        install_maven
    else
        print_error "请先安装Maven 3.6+，或使用 --auto-install-deps 参数自动安装"
        exit 1
    fi
}

# 安装Maven
install_maven() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if command_exists apt-get; then
            sudo apt-get update
            sudo apt-get install -y maven
        elif command_exists yum; then
            sudo yum install -y maven
        else
            print_error "无法自动安装Maven，请手动安装Maven 3.6+"
            exit 1
        fi
    else
        print_error "当前系统不支持自动安装Maven，请手动安装Maven 3.6+"
        exit 1
    fi
}

# 检查MySQL客户端
check_mysql_client() {
    if command_exists mysql; then
        print_info "MySQL客户端检查通过"
        return 0
    fi
    
    if [ "$AUTO_INSTALL_DEPS" = true ]; then
        print_info "尝试自动安装MySQL客户端..."
        install_mysql_client
    else
        print_warn "未找到MySQL客户端，数据库初始化可能失败"
        print_warn "可以手动执行数据库脚本，或使用 --auto-install-deps 参数自动安装"
    fi
}

# 安装MySQL客户端
install_mysql_client() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if command_exists apt-get; then
            sudo apt-get update
            sudo apt-get install -y mysql-client
        elif command_exists yum; then
            sudo yum install -y mysql
        else
            print_warn "无法自动安装MySQL客户端"
        fi
    fi
}

# 检查MySQL服务是否运行
check_mysql_service() {
    print_info "检查MySQL服务连接..."
    
    if command_exists mysql; then
        if mysql -h"$DB_HOST" -P"$DB_PORT" -u"$DB_USER" -p"$DB_PASSWORD" -e "SELECT 1" >/dev/null 2>&1; then
            print_info "MySQL服务连接成功"
            return 0
        else
            print_error "无法连接到MySQL服务"
            print_error "请检查："
            print_error "  1. MySQL服务是否启动"
            print_error "  2. 数据库连接信息是否正确"
            print_error "  3. 用户权限是否足够"
            exit 1
        fi
    else
        print_warn "MySQL客户端未安装，跳过连接检查"
        print_warn "请确保MySQL服务正在运行且可访问"
    fi
}

# 拉取项目
clone_project() {
    if [ "$SKIP_GIT_CLONE" = true ]; then
        print_info "跳过Git拉取步骤"
        return 0
    fi
    
    if [ -z "$GIT_REPO" ]; then
        print_info "未指定Git仓库，跳过拉取步骤"
        print_info "如果项目已存在，可以使用 --skip-git-clone 参数"
        return 0
    fi
    
    print_step "步骤 1: 拉取项目代码"
    
    if [ -d "$PROJECT_DIR" ]; then
        print_warn "项目目录已存在: $PROJECT_DIR"
        read -p "是否删除并重新拉取? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm -rf "$PROJECT_DIR"
        else
            print_info "使用现有项目目录"
            return 0
        fi
    fi
    
    if ! command_exists git; then
        print_error "未找到Git，请先安装Git"
        if [ "$AUTO_INSTALL_DEPS" = true ]; then
            print_info "尝试自动安装Git..."
            if command_exists apt-get; then
                sudo apt-get update && sudo apt-get install -y git
            elif command_exists yum; then
                sudo yum install -y git
            fi
        else
            exit 1
        fi
    fi
    
    print_info "正在从 $GIT_REPO 拉取项目..."
    git clone "$GIT_REPO" "$PROJECT_DIR"
    print_info "项目拉取完成"
}

# 切换到项目目录
cd_to_project() {
    if [ ! -d "$PROJECT_DIR" ]; then
        # 如果项目目录不存在，尝试使用当前目录
        if [ -f "pom.xml" ]; then
            print_info "在当前目录找到项目，使用当前目录"
            PROJECT_DIR="."
        else
            print_error "项目目录不存在: $PROJECT_DIR"
            exit 1
        fi
    else
        cd "$PROJECT_DIR" || exit 1
        print_info "已切换到项目目录: $(pwd)"
    fi
}

# 初始化数据库
setup_database() {
    if [ "$SKIP_DB_SETUP" = true ]; then
        print_warn "跳过数据库初始化步骤"
        return 0
    fi
    
    print_step "步骤 2: 初始化数据库"
    
    if [ ! -d "database" ]; then
        print_warn "database目录不存在，跳过数据库初始化"
        return 0
    fi
    
    if ! command_exists mysql; then
        print_warn "MySQL客户端未安装，无法自动初始化数据库"
        print_warn "请手动执行以下命令："
        print_warn "  mysql -h$DB_HOST -P$DB_PORT -u$DB_USER -p$DB_PASSWORD < database/schema.sql"
        if [ "$INIT_DATA" = true ]; then
            print_warn "  mysql -h$DB_HOST -P$DB_PORT -u$DB_USER -p$DB_PASSWORD < database/init_data.sql"
        fi
        return 0
    fi
    
    # 检查数据库是否存在
    DB_EXISTS=$(mysql -h"$DB_HOST" -P"$DB_PORT" -u"$DB_USER" -p"$DB_PASSWORD" -e "SHOW DATABASES LIKE '$DB_NAME';" 2>/dev/null | grep -c "$DB_NAME" || echo "0")
    
    if [ "$DB_EXISTS" -eq 0 ]; then
        print_info "数据库 $DB_NAME 不存在，正在创建..."
        mysql -h"$DB_HOST" -P"$DB_PORT" -u"$DB_USER" -p"$DB_PASSWORD" < database/schema.sql 2>/dev/null
        print_info "数据库创建成功"
    else
        print_info "数据库 $DB_NAME 已存在"
    fi
    
    # 导入初始数据
    if [ "$INIT_DATA" = true ] && [ -f "database/init_data.sql" ]; then
        print_info "正在导入初始数据..."
        mysql -h"$DB_HOST" -P"$DB_PORT" -u"$DB_USER" -p"$DB_PASSWORD" "$DB_NAME" < database/init_data.sql 2>/dev/null
        print_info "初始数据导入完成"
    fi
}

# 更新配置文件
update_config() {
    print_step "步骤 3: 配置应用"
    
    CONFIG_FILE="src/main/resources/application.yml"
    
    if [ ! -f "$CONFIG_FILE" ]; then
        print_error "配置文件不存在: $CONFIG_FILE"
        exit 1
    fi
    
    # 备份原配置文件
    if [ ! -f "${CONFIG_FILE}.bak" ]; then
        cp "$CONFIG_FILE" "${CONFIG_FILE}.bak"
        print_info "已备份配置文件到 ${CONFIG_FILE}.bak"
    fi
    
    # 构建数据库URL
    DB_URL="jdbc:mysql://${DB_HOST}:${DB_PORT}/${DB_NAME}?useUnicode=true&characterEncoding=utf8&useSSL=false&serverTimezone=Asia/Shanghai"
    
    # 使用sed更新配置文件（兼容不同系统）
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        sed -i '' "s|url: jdbc:mysql://.*|url: ${DB_URL}|" "$CONFIG_FILE"
        sed -i '' "s|username: .*|username: ${DB_USER}|" "$CONFIG_FILE"
        sed -i '' "s|password: .*|password: ${DB_PASSWORD}|" "$CONFIG_FILE"
        sed -i '' "s|port: [0-9]*|port: ${APP_PORT}|" "$CONFIG_FILE"
    else
        # Linux
        sed -i "s|url: jdbc:mysql://.*|url: ${DB_URL}|" "$CONFIG_FILE"
        sed -i "s|username: .*|username: ${DB_USER}|" "$CONFIG_FILE"
        sed -i "s|password: .*|password: ${DB_PASSWORD}|" "$CONFIG_FILE"
        sed -i "s|port: [0-9]*|port: ${APP_PORT}|" "$CONFIG_FILE"
    fi
    
    print_info "配置已更新:"
    print_info "  数据库: ${DB_HOST}:${DB_PORT}/${DB_NAME}"
    print_info "  用户名: ${DB_USER}"
    print_info "  应用端口: ${APP_PORT}"
}

# 编译项目
build_project() {
    if [ "$SKIP_BUILD" = true ]; then
        print_warn "跳过编译步骤"
        return 0
    fi
    
    print_step "步骤 4: 编译项目"
    
    if [ ! -f "pom.xml" ]; then
        print_error "pom.xml不存在，无法编译项目"
        exit 1
    fi
    
    print_info "开始编译项目（这可能需要几分钟）..."
    
    # 清理并编译
    mvn clean package -DskipTests
    
    if [ $? -eq 0 ]; then
        print_info "项目编译成功"
    else
        print_error "项目编译失败"
        exit 1
    fi
}

# 检查端口是否被占用
check_port() {
    if command_exists lsof; then
        if lsof -Pi :"$APP_PORT" -sTCP:LISTEN -t >/dev/null 2>&1; then
            print_warn "端口 $APP_PORT 已被占用"
            print_warn "请停止占用该端口的进程，或使用 --port 参数指定其他端口"
            exit 1
        fi
    elif command_exists netstat; then
        if netstat -tuln | grep -q ":$APP_PORT "; then
            print_warn "端口 $APP_PORT 已被占用"
            exit 1
        fi
    fi
}

# 启动应用
start_application() {
    print_step "步骤 5: 启动应用"
    
    JAR_FILE="target/article-api-1.0.0.jar"
    
    if [ ! -f "$JAR_FILE" ]; then
        print_error "JAR文件不存在: $JAR_FILE"
        print_error "请先运行编译步骤"
        exit 1
    fi
    
    check_port
    
    print_info "应用将在端口 ${APP_PORT} 上启动"
    print_info "访问地址: http://localhost:${APP_PORT}/api"
    print_info ""
    print_info "测试接口:"
    print_info "  文章列表: curl http://localhost:${APP_PORT}/api/articles"
    print_info "  分类列表: curl http://localhost:${APP_PORT}/api/categories"
    print_info ""
    
    # 在后台启动应用
    print_info "正在后台启动应用..."
    nohup java -jar "$JAR_FILE" > app.log 2>&1 &
    APP_PID=$!
    
    # 等待应用启动
    print_info "等待应用启动..."
    sleep 5
    
    # 验证服务
    verify_service
    
    print_info ""
    print_info "应用已启动，进程ID: $APP_PID"
    print_info "日志文件: app.log"
    print_info "查看日志: tail -f app.log"
    print_info ""
    print_warn "按 Ctrl+C 不会停止应用，请使用以下命令停止："
    print_warn "  kill $APP_PID"
    print_warn "或查找进程: ps aux | grep article-api"
    print_info ""
    
    # 显示日志
    if [ -f "app.log" ]; then
        print_info "最近的日志输出："
        tail -n 20 app.log
        print_info ""
        print_info "实时查看日志: tail -f app.log"
    fi
}

# 验证服务
verify_service() {
    print_info "验证服务是否启动..."
    
    local max_attempts=30
    local attempt=0
    
    while [ $attempt -lt $max_attempts ]; do
        sleep 2
        attempt=$((attempt + 1))
        
        if command_exists curl; then
            if curl -s -f "http://localhost:${APP_PORT}/api/articles" >/dev/null 2>&1; then
                print_info "✓ 服务启动成功！"
                print_info "访问地址: http://localhost:${APP_PORT}/api"
                return 0
            fi
        else
            # 如果没有curl，检查进程是否还在运行
            if [ -n "$APP_PID" ] && ps -p "$APP_PID" > /dev/null 2>&1; then
                if [ $attempt -ge 10 ]; then
                    print_info "✓ 应用进程运行中（无法验证HTTP接口，请手动访问）"
                    print_info "访问地址: http://localhost:${APP_PORT}/api"
                    return 0
                fi
            elif [ -n "$APP_PID" ]; then
                print_error "应用进程已退出，请查看日志文件 app.log"
                exit 1
            fi
        fi
        
        if [ $((attempt % 5)) -eq 0 ]; then
            print_info "等待服务启动... ($attempt/$max_attempts)"
        fi
    done
    
    print_warn "服务启动超时，但进程仍在运行"
    print_warn "请检查日志文件 app.log 或手动访问 http://localhost:${APP_PORT}/api"
}

# 主函数
main() {
    print_step "文章管理API一键部署脚本"
    
    # 解析参数
    parse_args "$@"
    
    # 显示配置信息
    print_info "部署配置:"
    print_info "  项目目录: ${PROJECT_DIR}"
    if [ -n "$GIT_REPO" ]; then
        print_info "  Git仓库: ${GIT_REPO}"
    fi
    print_info "  数据库主机: ${DB_HOST}"
    print_info "  数据库端口: ${DB_PORT}"
    print_info "  数据库名称: ${DB_NAME}"
    print_info "  数据库用户: ${DB_USER}"
    print_info "  应用端口: ${APP_PORT}"
    echo
    
    # 检查环境要求
    print_step "检查环境要求"
    check_java
    check_maven
    check_mysql_client
    check_mysql_service
    echo
    
    # 拉取项目
    clone_project
    echo
    
    # 切换到项目目录
    cd_to_project
    echo
    
    # 初始化数据库
    setup_database
    echo
    
    # 更新配置
    update_config
    echo
    
    # 编译项目
    build_project
    echo
    
    # 启动应用
    start_application
}

# 捕获中断信号
trap 'echo ""; print_warn "部署被中断"; exit 130' INT TERM

# 执行主函数
main "$@"
