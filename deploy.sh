#!/bin/bash

# 文章管理API编译脚本
# 功能：编译项目代码到JAR包
# 用法: ./deploy.sh [选项]

set -e  # 遇到错误立即退出

# 默认配置
SKIP_TESTS=true
OUTPUT_DIR="${OUTPUT_DIR:-target}"

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
文章管理API编译脚本

功能：编译项目代码到JAR包

用法: $0 [选项]

选项:
  --run-tests           运行测试（默认跳过测试）
  --output-dir DIR      输出目录 (默认: target)
  --help                显示帮助信息

示例:
  # 编译项目（跳过测试）
  $0

  # 编译项目并运行测试
  $0 --run-tests

  # 指定输出目录
  $0 --output-dir /path/to/output
EOF
}

# 解析命令行参数
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --run-tests)
                SKIP_TESTS=false
                shift
                ;;
            --output-dir)
                OUTPUT_DIR="$2"
                shift 2
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

# 检查pom.xml是否存在
check_project() {
    if [ ! -f "pom.xml" ]; then
        print_error "pom.xml不存在，请确保在项目根目录执行此脚本"
        exit 1
    fi
    print_info "项目检查通过"
}

# 编译项目
build_project() {
    print_step "编译项目"
    
    print_info "开始编译项目..."
    
    # 构建Maven命令
    MVN_CMD="mvn clean package"
    
    if [ "$SKIP_TESTS" = true ]; then
        MVN_CMD="$MVN_CMD -DskipTests"
        print_info "跳过测试"
    else
        print_info "将运行测试"
    fi
    
    # 执行编译
    print_info "执行命令: $MVN_CMD"
    $MVN_CMD
    
    if [ $? -eq 0 ]; then
        print_info "项目编译成功"
        
        # 查找生成的JAR文件
        JAR_FILE=$(find "$OUTPUT_DIR" -name "*.jar" -not -name "*-sources.jar" -not -name "*-javadoc.jar" | head -n 1)
        
        if [ -n "$JAR_FILE" ]; then
            print_info "JAR包位置: $JAR_FILE"
            print_info "文件大小: $(du -h "$JAR_FILE" | cut -f1)"
        else
            print_warn "未找到生成的JAR文件"
        fi
    else
        print_error "项目编译失败"
        exit 1
    fi
}

# 主函数
main() {
    print_step "文章管理API编译脚本"
    
    # 解析参数
    parse_args "$@"
    
    # 显示配置信息
    print_info "编译配置:"
    print_info "  跳过测试: ${SKIP_TESTS}"
    print_info "  输出目录: ${OUTPUT_DIR}"
    echo
    
    # 检查项目
    check_project
    echo
    
    # 编译项目
    build_project
    echo
    
    print_step "编译完成"
    print_info "JAR包已生成在 ${OUTPUT_DIR} 目录"
}

# 捕获中断信号
trap 'echo ""; print_warn "编译被中断"; exit 130' INT TERM

# 执行主函数
main "$@"
