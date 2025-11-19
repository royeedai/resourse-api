#!/bin/bash

# 文章管理API部署脚本
# 用法: ./deploy.sh [选项]
# 选项:
#   --db-host HOST         数据库主机地址 (默认: localhost)
#   --db-port PORT         数据库端口 (默认: 3306)
#   --db-name NAME         数据库名称 (默认: article_db)
#   --db-user USER         数据库用户名 (默认: root)
#   --db-password PASSWORD 数据库密码 (默认: root)
#   --port PORT            应用端口 (默认: 8080)
#   --skip-build           跳过编译步骤
#   --help                 显示帮助信息

set -e  # 遇到错误立即退出

# 默认配置
DB_HOST="${DB_HOST:-localhost}"
DB_PORT="${DB_PORT:-3306}"
DB_NAME="${DB_NAME:-article_db}"
DB_USER="${DB_USER:-root}"
DB_PASSWORD="${DB_PASSWORD:-root}"
APP_PORT="${APP_PORT:-8080}"
SKIP_BUILD=false

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
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

# 显示帮助信息
show_help() {
    cat << EOF
文章管理API部署脚本

用法: $0 [选项]

选项:
  --db-host HOST         数据库主机地址 (默认: localhost)
  --db-port PORT         数据库端口 (默认: 3306)
  --db-name NAME         数据库名称 (默认: article_db)
  --db-user USER         数据库用户名 (默认: root)
  --db-password PASSWORD 数据库密码 (默认: root)
  --port PORT            应用端口 (默认: 8080)
  --skip-build           跳过编译步骤
  --help                 显示帮助信息

环境变量:
  也可以通过环境变量设置参数:
  DB_HOST, DB_PORT, DB_NAME, DB_USER, DB_PASSWORD, APP_PORT

示例:
  $0 --db-host 192.168.1.100 --db-user admin --db-password secret --port 9090
  DB_HOST=192.168.1.100 DB_USER=admin $0 --port 9090
EOF
}

# 解析命令行参数
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
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
            --skip-build)
                SKIP_BUILD=true
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

# 检查必要的工具
check_requirements() {
    print_info "检查环境要求..."
    
    # 检查Java
    if ! command -v java &> /dev/null; then
        print_error "未找到Java，请先安装JDK 17+"
        exit 1
    fi
    
    JAVA_VERSION=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}' | cut -d'.' -f1)
    if [ "$JAVA_VERSION" -lt 17 ]; then
        print_error "Java版本过低，需要JDK 17+，当前版本: $JAVA_VERSION"
        exit 1
    fi
    print_info "Java版本检查通过: $(java -version 2>&1 | head -n 1)"
    
    # 检查Maven
    if ! command -v mvn &> /dev/null; then
        print_error "未找到Maven，请先安装Maven 3.6+"
        exit 1
    fi
    print_info "Maven版本检查通过: $(mvn -version | head -n 1)"
}

# 更新配置文件
update_config() {
    print_info "更新应用配置..."
    
    CONFIG_FILE="src/main/resources/application.yml"
    
    if [ ! -f "$CONFIG_FILE" ]; then
        print_error "配置文件不存在: $CONFIG_FILE"
        exit 1
    fi
    
    # 备份原配置文件
    cp "$CONFIG_FILE" "${CONFIG_FILE}.bak"
    print_info "已备份配置文件到 ${CONFIG_FILE}.bak"
    
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
        return
    fi
    
    print_info "开始编译项目..."
    
    # 清理并编译
    mvn clean package -DskipTests
    
    if [ $? -eq 0 ]; then
        print_info "项目编译成功"
    else
        print_error "项目编译失败"
        exit 1
    fi
}

# 启动应用
start_application() {
    print_info "启动应用..."
    
    JAR_FILE="target/article-api-1.0.0.jar"
    
    if [ ! -f "$JAR_FILE" ]; then
        print_error "JAR文件不存在: $JAR_FILE"
        print_error "请先运行编译步骤或检查构建输出"
        exit 1
    fi
    
    print_info "应用将在端口 ${APP_PORT} 上启动"
    print_info "访问地址: http://localhost:${APP_PORT}/api"
    print_info "按 Ctrl+C 停止应用"
    
    # 启动应用
    java -jar "$JAR_FILE"
}

# 主函数
main() {
    print_info "========================================="
    print_info "  文章管理API部署脚本"
    print_info "========================================="
    echo
    
    # 解析参数
    parse_args "$@"
    
    # 显示配置信息
    print_info "部署配置:"
    print_info "  数据库主机: ${DB_HOST}"
    print_info "  数据库端口: ${DB_PORT}"
    print_info "  数据库名称: ${DB_NAME}"
    print_info "  数据库用户: ${DB_USER}"
    print_info "  应用端口: ${APP_PORT}"
    echo
    
    # 检查环境
    check_requirements
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

# 执行主函数
main "$@"
