#!/bin/bash

# 生产环境启动脚本
# 使用方法：
#   ./start-prod.sh
#   或者设置环境变量后启动：
#   DB_USER=article_db DB_PASSWORD=DsjfmS4mMTacHLmX DB_HOST=localhost DB_PORT=3306 DB_NAME=article_db SERVER_PORT=8083 ./start-prod.sh

# 设置默认值
export DB_HOST="${DB_HOST:-localhost}"
export DB_PORT="${DB_PORT:-3306}"
export DB_NAME="${DB_NAME:-article_db}"
export DB_USER="${DB_USER:-article_db}"
export DB_PASSWORD="${DB_PASSWORD:-DsjfmS4mMTacHLmX}"
export SERVER_PORT="${SERVER_PORT:-8080}"

# Java 路径（根据实际环境修改）
JAVA_HOME="${JAVA_HOME:-/www/server/java/jdk-17.0.8}"
JAVA_CMD="${JAVA_HOME}/bin/java"

# JAR 文件路径（根据实际环境修改）
JAR_FILE="${JAR_FILE:-/www/wwwroot/resource/resourse-api/target/article-api-1.0.0.jar}"

echo "=========================================="
echo "启动文章API应用（生产环境）"
echo "=========================================="
echo "数据库配置:"
echo "  主机: ${DB_HOST}"
echo "  端口: ${DB_PORT}"
echo "  数据库: ${DB_NAME}"
echo "  用户名: ${DB_USER}"
echo "  密码: ${DB_PASSWORD:0:1}*** (已隐藏)"
echo "服务器端口: ${SERVER_PORT}"
echo "=========================================="
echo ""

# 检查 Java 是否存在
if [ ! -f "$JAVA_CMD" ]; then
    echo "错误: Java 可执行文件不存在: $JAVA_CMD"
    echo "请设置正确的 JAVA_HOME 或修改脚本中的 JAVA_HOME 路径"
    exit 1
fi

# 检查 JAR 文件是否存在
if [ ! -f "$JAR_FILE" ]; then
    echo "错误: JAR文件不存在: $JAR_FILE"
    echo "请修改脚本中的 JAR_FILE 路径或确保文件存在"
    exit 1
fi

# 启动应用
echo "正在启动应用..."
echo "Java 路径: $JAVA_CMD"
echo "JAR 文件: $JAR_FILE"
echo ""

"$JAVA_CMD" -Xmx1024M -Xms256M -jar "$JAR_FILE" --server.port="${SERVER_PORT}"
