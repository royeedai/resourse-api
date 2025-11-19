# 数据库配置说明

## 问题描述
如果遇到 `Access denied for user 'root'@'localhost'` 错误，说明数据库用户名或密码不正确。

## 解决方案

### 方案1：使用环境变量（推荐，无需重新编译）

配置文件已更新为支持环境变量。你可以通过以下方式设置数据库连接信息：

#### 方式1：在启动前设置环境变量
```bash
export DB_USER=你的数据库用户名
export DB_PASSWORD=你的数据库密码
export DB_HOST=localhost  # 可选，默认 localhost
export DB_PORT=3306       # 可选，默认 3306
export DB_NAME=article_db # 可选，默认 article_db

# 然后启动应用
java -jar target/article-api-1.0.0.jar
```

#### 方式2：使用启动脚本
```bash
# 设置环境变量并启动
DB_USER=你的用户名 DB_PASSWORD=你的密码 ./start.sh

# 或者先设置环境变量
export DB_USER=你的用户名
export DB_PASSWORD=你的密码
./start.sh
```

#### 方式3：一行命令启动
```bash
DB_USER=你的用户名 DB_PASSWORD=你的密码 java -jar target/article-api-1.0.0.jar
```

### 方案2：修改配置文件并重新编译

1. 编辑 `src/main/resources/application.yml`，修改以下内容：
```yaml
spring:
  datasource:
    username: 你的数据库用户名
    password: 你的数据库密码
```

2. 重新编译打包：
```bash
mvn clean package
```

3. 启动应用：
```bash
java -jar target/article-api-1.0.0.jar
```

## 检查MySQL密码

如果不知道MySQL的root密码，可以尝试以下方法：

### 方法1：重置MySQL root密码

1. 停止MySQL服务：
```bash
sudo systemctl stop mysql
# 或
sudo service mysql stop
```

2. 以安全模式启动MySQL（跳过权限检查）：
```bash
sudo mysqld_safe --skip-grant-tables &
```

3. 连接MySQL并重置密码：
```bash
mysql -u root
```
```sql
USE mysql;
UPDATE user SET authentication_string=PASSWORD('新密码') WHERE User='root';
FLUSH PRIVILEGES;
EXIT;
```

4. 重启MySQL服务：
```bash
sudo systemctl restart mysql
```

### 方法2：使用sudo权限连接MySQL

```bash
sudo mysql -u root
```

然后创建或修改用户：
```sql
ALTER USER 'root'@'localhost' IDENTIFIED BY '新密码';
FLUSH PRIVILEGES;
```

### 方法3：检查现有用户和权限

```bash
sudo mysql -u root
```
```sql
SELECT user, host FROM mysql.user;
SHOW GRANTS FOR 'root'@'localhost';
```

## 常见问题

### Q: 修改了配置文件，但应用还是使用旧配置？
A: 如果是从JAR包启动，需要重新编译打包。JAR包中的配置文件是编译时打包进去的。

### Q: 如何确认应用使用的数据库配置？
A: 查看应用启动日志，Spring Boot会打印数据源配置信息（密码会被隐藏）。

### Q: 环境变量和配置文件哪个优先级高？
A: 环境变量的优先级高于配置文件。如果设置了环境变量，会覆盖配置文件中的值。

## 测试数据库连接

在设置好配置后，可以使用以下命令测试数据库连接（需要安装MySQL客户端）：

```bash
mysql -h localhost -P 3306 -u 你的用户名 -p你的密码 -e "SELECT 1"
```

如果连接成功，会显示查询结果。如果失败，会显示错误信息。
