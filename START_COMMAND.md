# 正确的启动命令

## 问题说明

如果遇到 `Access denied for user 'root'@'localhost'` 错误，通常是因为启动命令语法错误导致环境变量未正确设置。

## 错误的启动命令

```bash
# ❌ 错误：使用 & 会导致命令并行执行
export DB_USER=article_db & export DB_PASSWORD=DsjfmS4mMTacHLmX & java -jar app.jar
```

## 正确的启动命令

### 方式1：使用 && 顺序执行（推荐）

```bash
export DB_USER=article_db && \
export DB_PASSWORD=DsjfmS4mMTacHLmX && \
export DB_HOST=localhost && \
export DB_PORT=3306 && \
export DB_NAME=article_db && \
export SERVER_PORT=8083 && \
/www/server/java/jdk-17.0.8/bin/java -Xmx1024M -Xms256M -jar /www/wwwroot/resource/resourse-api/target/article-api-1.0.0.jar --server.port=8083
```

### 方式2：一行命令设置环境变量

```bash
DB_USER=article_db DB_PASSWORD=DsjfmS4mMTacHLmX DB_HOST=localhost DB_PORT=3306 DB_NAME=article_db SERVER_PORT=8083 /www/server/java/jdk-17.0.8/bin/java -Xmx1024M -Xms256M -jar /www/wwwroot/resource/resourse-api/target/article-api-1.0.0.jar --server.port=8083
```

### 方式3：使用启动脚本（最简单）

```bash
# 设置环境变量
export DB_USER=article_db
export DB_PASSWORD=DsjfmS4mMTacHLmX
export DB_HOST=localhost
export DB_PORT=3306
export DB_NAME=article_db
export SERVER_PORT=8083

# 启动应用
./start-prod.sh
```

### 方式4：修改 start-prod.sh 脚本中的默认值

编辑 `start-prod.sh`，修改以下行：
```bash
export DB_USER="${DB_USER:-article_db}"  # 将默认值改为 article_db
export DB_PASSWORD="${DB_PASSWORD:-DsjfmS4mMTacHLmX}"  # 将默认值改为你的密码
export SERVER_PORT="${SERVER_PORT:-8083}"  # 将默认端口改为 8083
```

然后直接运行：
```bash
./start-prod.sh
```

## 重要提示

1. **使用 `&&` 而不是 `&`**：`&&` 表示顺序执行，`&` 表示后台并行执行
2. **Java 参数顺序**：应该是 `-Xmx1024M -Xms256M -jar`，而不是 `-jar -Xmx1024M -Xms256M`
3. **环境变量设置**：确保在 Java 进程启动前环境变量已经设置好

## 验证环境变量

启动前可以验证环境变量是否正确设置：

```bash
export DB_USER=article_db
export DB_PASSWORD=DsjfmS4mMTacHLmX
echo "DB_USER=$DB_USER"
echo "DB_PASSWORD=$DB_PASSWORD"
```

## 检查数据库连接

如果环境变量设置正确但仍然连接失败，检查数据库：

```bash
# 检查 MySQL 服务
systemctl status mysql

# 测试数据库连接
mysql -u article_db -pDsjfmS4mMTacHLmX -h localhost article_db -e "SELECT 1;"
```
