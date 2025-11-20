#!/bin/bash

# 文章API启动脚本
# 使用方法：
#   1. 设置环境变量后启动：
#      export DB_USER=your_username
#      export DB_PASSWORD=your_password
#      ./start.sh
#
#   2. 或者直接传递参数：
#      DB_USER=your_username DB_PASSWORD=your_password ./start.sh

# 默认值（如果未设置环境变量）
export DB_HOST="${DB_HOST:-localhost}"
export DB_PORT="${DB_PORT:-3306}"
export DB_NAME="${DB_NAME:-article_db}"
export DB_USER="${DB_USER:-article_db}"
export DB_PASSWORD="${DB_PASSWORD:-DsjfmS4mMTacHLmX}"

echo "=========================================="
echo "启动文章API应用"
echo "=========================================="
echo "数据库配置:"
echo "  主机: ${DB_HOST}"
echo "  端口: ${DB_PORT}"
echo "  数据库: ${DB_NAME}"
echo "  用户名: ${DB_USER}"
echo "  密码: ${DB_PASSWORD:0:1}*** (已隐藏)"
echo "=========================================="
echo ""

# 检查JAR文件是否存在
JAR_FILE="target/article-api-1.0.0.jar"
if [ ! -f "$JAR_FILE" ]; then
    echo "错误: JAR文件不存在: $JAR_FILE"
    echo "请先运行: mvn clean package"
    exit 1
fi

# 启动应用
echo "正在启动应用..."
java -Xmx1024M -Xms256M -jar "$JAR_FILE" --server.port="${SERVER_PORT:-8080}"
