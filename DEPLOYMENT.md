# 部署文档

本文档介绍如何部署文章管理API项目到生产环境。

## 目录

- [一键部署（推荐）](#一键部署推荐)
- [环境要求](#环境要求)
- [本地开发部署](#本地开发部署)
- [生产环境部署](#生产环境部署)
- [Docker部署](#docker部署)
- [配置说明](#配置说明)
- [常见问题](#常见问题)

## 一键部署（推荐）

项目提供了自动化部署脚本 `deploy.sh`，可以一键完成从拉取项目到启动完成的所有流程。

### 快速开始

#### 方式一：从Git仓库部署（推荐）

```bash
# 给脚本添加执行权限
chmod +x deploy.sh

# 一键部署（自动拉取项目、初始化数据库、编译、启动）
./deploy.sh --git-repo https://github.com/your-username/article-api.git \
            --db-password your_password \
            --port 8080
```

#### 方式二：本地项目部署

如果项目已经在本地，可以跳过Git拉取步骤：

```bash
./deploy.sh --skip-git-clone \
            --db-password your_password \
            --port 8080
```

#### 方式三：自动安装依赖

如果系统缺少Java、Maven等依赖，可以使用自动安装功能（需要sudo权限）：

```bash
./deploy.sh --auto-install-deps \
            --git-repo https://github.com/your-username/article-api.git \
            --db-password your_password
```

### 脚本功能

一键部署脚本会自动完成以下所有步骤：

1. ✅ **环境检查**：检查Java、Maven、MySQL客户端是否安装
2. ✅ **自动安装依赖**：可选自动安装缺失的依赖（需要sudo权限）
3. ✅ **拉取项目**：从Git仓库自动拉取项目代码（可选）
4. ✅ **数据库初始化**：自动创建数据库并执行初始化脚本
5. ✅ **配置更新**：自动更新数据库连接和应用端口配置
6. ✅ **项目编译**：使用Maven自动编译打包项目
7. ✅ **服务启动**：启动应用并验证服务可用性

### 脚本参数说明

| 参数 | 说明 | 默认值 |
|------|------|--------|
| `--git-repo URL` | Git仓库地址（如果指定，将自动拉取项目） | - |
| `--project-dir DIR` | 项目目录路径 | ./article-api |
| `--db-host HOST` | 数据库主机地址 | localhost |
| `--db-port PORT` | 数据库端口 | 3306 |
| `--db-name NAME` | 数据库名称 | article_db |
| `--db-user USER` | 数据库用户名 | root |
| `--db-password PASSWORD` | 数据库密码 | root |
| `--port PORT` | 应用端口 | 8080 |
| `--skip-git-clone` | 跳过Git拉取步骤 | false |
| `--skip-db-setup` | 跳过数据库初始化步骤 | false |
| `--skip-build` | 跳过编译步骤 | false |
| `--auto-install-deps` | 自动安装缺失的依赖 | false |
| `--no-init-data` | 不导入初始测试数据 | false |
| `--help` | 显示帮助信息 | - |

### 使用环境变量

也可以通过环境变量设置参数：

```bash
export DB_HOST=192.168.1.100
export DB_USER=admin
export DB_PASSWORD=secret
export APP_PORT=9090

./deploy.sh --git-repo https://github.com/your-username/article-api.git
```

### 完整示例

```bash
# 示例1：完整部署流程
./deploy.sh \
  --git-repo https://github.com/your-username/article-api.git \
  --project-dir /opt/article-api \
  --db-host 192.168.1.100 \
  --db-port 3306 \
  --db-name article_db \
  --db-user article_user \
  --db-password strong_password \
  --port 8080

# 示例2：本地项目快速部署
./deploy.sh \
  --skip-git-clone \
  --db-password mypassword \
  --port 9090

# 示例3：生产环境部署（不导入测试数据）
./deploy.sh \
  --skip-git-clone \
  --no-init-data \
  --db-host prod-db.example.com \
  --db-user prod_user \
  --db-password prod_password \
  --port 8080
```

### 注意事项

1. **MySQL服务**：确保MySQL服务已启动并可访问
2. **数据库权限**：确保数据库用户有创建数据库和表的权限
3. **端口占用**：确保指定的应用端口未被占用
4. **自动安装**：使用 `--auto-install-deps` 需要sudo权限，脚本会自动检测系统类型并安装依赖
5. **配置文件备份**：脚本会自动备份原始配置文件到 `application.yml.bak`

### 验证部署

部署完成后，脚本会自动验证服务是否可用。你也可以手动验证：

```bash
# 检查文章列表接口
curl http://localhost:8080/api/articles

# 检查分类列表接口
curl http://localhost:8080/api/categories

# 检查应用进程
ps aux | grep article-api
```

---

**提示**：如果一键部署脚本无法满足你的需求，可以参考下面的手动部署步骤。

## 环境要求

### 基础环境

- **JDK**: 17 或更高版本
- **Maven**: 3.6+ 
- **MySQL**: 8.0+ 或更高版本
- **操作系统**: Linux / Windows / macOS

### 推荐配置

- **内存**: 至少 2GB RAM
- **磁盘**: 至少 1GB 可用空间
- **CPU**: 2核或以上

## 本地开发部署

### 1. 克隆项目

```bash
git clone <repository-url>
cd article-api
```

### 2. 数据库准备

#### 2.1 创建数据库

```bash
# 登录MySQL
mysql -u root -p

# 执行SQL脚本创建数据库和表
source database/schema.sql

# 导入初始数据（可选）
source database/init_data.sql
```

或者直接执行：

```bash
mysql -u root -p < database/schema.sql
mysql -u root -p < database/init_data.sql
```

#### 2.2 配置数据库连接

编辑 `src/main/resources/application.yml`：

```yaml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/article_db?useUnicode=true&characterEncoding=utf8&useSSL=false&serverTimezone=Asia/Shanghai
    username: root
    password: your_password  # 修改为你的数据库密码
```

### 3. 编译项目

```bash
# 清理并编译
mvn clean compile

# 打包（跳过测试）
mvn clean package -DskipTests
```

### 4. 运行项目

#### 方式一：使用Maven运行

```bash
mvn spring-boot:run
```

#### 方式二：使用Java运行JAR包

```bash
# 打包
mvn clean package -DskipTests

# 运行
java -jar target/article-api-1.0.0.jar
```

### 5. 验证部署

访问以下URL验证服务是否正常：

```bash
# 获取文章列表
curl http://localhost:8080/api/articles

# 获取分类列表
curl http://localhost:8080/api/categories
```

## 生产环境部署

### 1. 服务器准备

确保服务器已安装：
- JDK 17+
- MySQL 8.0+

### 2. 数据库配置

#### 2.1 创建生产数据库

```bash
mysql -u root -p < database/schema.sql
```

#### 2.2 配置数据库用户权限

```sql
-- 创建专用数据库用户（推荐）
CREATE USER 'article_user'@'%' IDENTIFIED BY 'strong_password';
GRANT ALL PRIVILEGES ON article_db.* TO 'article_user'@'%';
FLUSH PRIVILEGES;
```

### 3. 应用配置

#### 3.1 修改配置文件

创建生产环境配置文件 `src/main/resources/application-prod.yml`：

```yaml
spring:
  datasource:
    url: jdbc:mysql://your-db-host:3306/article_db?useUnicode=true&characterEncoding=utf8&useSSL=true&serverTimezone=Asia/Shanghai
    username: article_user
    password: strong_password
  
  jpa:
    hibernate:
      ddl-auto: validate  # 生产环境使用validate，不自动创建表
    show-sql: false  # 生产环境关闭SQL日志

server:
  port: 8080
  servlet:
    context-path: /api

logging:
  level:
    root: INFO
    com.example.articleapi: INFO
  file:
    name: /var/log/article-api/application.log
```

#### 3.2 打包应用

```bash
mvn clean package -DskipTests
```

生成的JAR包位于：`target/article-api-1.0.0.jar`

### 4. 部署应用

#### 方式一：直接运行

```bash
# 创建应用目录
sudo mkdir -p /opt/article-api
sudo cp target/article-api-1.0.0.jar /opt/article-api/

# 运行应用
cd /opt/article-api
java -jar -Dspring.profiles.active=prod article-api-1.0.0.jar
```

#### 方式二：使用systemd服务（推荐）

创建服务文件 `/etc/systemd/system/article-api.service`：

```ini
[Unit]
Description=Article API Service
After=network.target mysql.service

[Service]
Type=simple
User=www-data
WorkingDirectory=/opt/article-api
ExecStart=/usr/bin/java -jar -Dspring.profiles.active=prod -Xms512m -Xmx1024m article-api-1.0.0.jar
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
```

启动服务：

```bash
# 重新加载systemd配置
sudo systemctl daemon-reload

# 启动服务
sudo systemctl start article-api

# 设置开机自启
sudo systemctl enable article-api

# 查看服务状态
sudo systemctl status article-api

# 查看日志
sudo journalctl -u article-api -f
```

### 5. Nginx反向代理（可选）

如果需要通过Nginx代理，配置示例：

```nginx
server {
    listen 80;
    server_name api.example.com;

    location /api {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

## Docker部署

### 1. 创建Dockerfile

在项目根目录创建 `Dockerfile`：

```dockerfile
FROM openjdk:17-jdk-slim

WORKDIR /app

COPY target/article-api-1.0.0.jar app.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "-Dspring.profiles.active=prod", "app.jar"]
```

### 2. 创建docker-compose.yml

```yaml
version: '3.8'

services:
  mysql:
    image: mysql:8.0
    container_name: article-mysql
    environment:
      MYSQL_ROOT_PASSWORD: root_password
      MYSQL_DATABASE: article_db
      MYSQL_USER: article_user
      MYSQL_PASSWORD: article_password
    ports:
      - "3306:3306"
    volumes:
      - mysql_data:/var/lib/mysql
      - ./database/schema.sql:/docker-entrypoint-initdb.d/schema.sql
    networks:
      - article-network

  app:
    build: .
    container_name: article-api
    ports:
      - "8080:8080"
    environment:
      SPRING_DATASOURCE_URL: jdbc:mysql://mysql:3306/article_db?useUnicode=true&characterEncoding=utf8&useSSL=false&serverTimezone=Asia/Shanghai
      SPRING_DATASOURCE_USERNAME: article_user
      SPRING_DATASOURCE_PASSWORD: article_password
    depends_on:
      - mysql
    networks:
      - article-network

volumes:
  mysql_data:

networks:
  article-network:
    driver: bridge
```

### 3. 构建和运行

```bash
# 构建镜像
docker-compose build

# 启动服务
docker-compose up -d

# 查看日志
docker-compose logs -f app

# 停止服务
docker-compose down
```

## 配置说明

### 应用配置项

| 配置项 | 说明 | 默认值 |
|--------|------|--------|
| `server.port` | 服务端口 | 8080 |
| `server.servlet.context-path` | 上下文路径 | /api |
| `spring.datasource.url` | 数据库连接URL | - |
| `spring.datasource.username` | 数据库用户名 | root |
| `spring.datasource.password` | 数据库密码 | - |
| `spring.jpa.hibernate.ddl-auto` | DDL策略 | update |
| `spring.jpa.show-sql` | 是否显示SQL | true |

### JVM参数建议

生产环境建议使用以下JVM参数：

```bash
java -jar \
  -Xms512m \
  -Xmx1024m \
  -XX:+UseG1GC \
  -XX:MaxGCPauseMillis=200 \
  -Dspring.profiles.active=prod \
  article-api-1.0.0.jar
```

## 常见问题

### 1. 数据库连接失败

**问题**: 应用启动时提示数据库连接失败

**解决方案**:
- 检查MySQL服务是否启动
- 确认数据库连接配置正确
- 检查防火墙设置
- 确认数据库用户权限

### 2. 端口被占用

**问题**: 8080端口已被占用

**解决方案**:
```bash
# 查找占用端口的进程
lsof -i :8080
# 或
netstat -tulpn | grep 8080

# 修改application.yml中的server.port配置
```

### 3. 内存不足

**问题**: 应用运行出现OutOfMemoryError

**解决方案**:
- 增加JVM内存参数：`-Xmx2048m`
- 检查服务器可用内存
- 优化应用代码

### 4. 表不存在错误

**问题**: 提示表不存在

**解决方案**:
```bash
# 执行数据库初始化脚本
mysql -u root -p article_db < database/schema.sql

# 或修改application.yml中的ddl-auto为update（仅开发环境）
```

### 5. 日志文件权限问题

**问题**: 无法写入日志文件

**解决方案**:
```bash
# 创建日志目录并设置权限
sudo mkdir -p /var/log/article-api
sudo chown -R www-data:www-data /var/log/article-api
```

## 监控和维护

### 健康检查

应用启动后，可以通过以下方式检查健康状态：

```bash
# 检查应用是否响应
curl http://localhost:8080/api/articles

# 检查进程
ps aux | grep article-api
```

### 日志查看

```bash
# 如果使用systemd
sudo journalctl -u article-api -f

# 如果使用文件日志
tail -f /var/log/article-api/application.log
```

### 备份数据库

```bash
# 备份数据库
mysqldump -u root -p article_db > backup_$(date +%Y%m%d).sql

# 恢复数据库
mysql -u root -p article_db < backup_20240101.sql
```

## 安全建议

1. **数据库安全**
   - 使用强密码
   - 创建专用数据库用户，避免使用root
   - 限制数据库访问IP

2. **应用安全**
   - 使用HTTPS（配置SSL证书）
   - 配置防火墙规则
   - 定期更新依赖包

3. **服务器安全**
   - 定期更新系统补丁
   - 配置SSH密钥认证
   - 禁用不必要的服务

## 更新部署

更新应用时：

```bash
# 1. 备份当前版本
cp article-api-1.0.0.jar article-api-1.0.0.jar.backup

# 2. 停止服务
sudo systemctl stop article-api

# 3. 替换JAR包
cp new-version.jar article-api-1.0.0.jar

# 4. 启动服务
sudo systemctl start article-api

# 5. 检查服务状态
sudo systemctl status article-api
```

---

如有其他问题，请参考项目README或联系技术支持。
