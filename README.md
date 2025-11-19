# 文章管理API项目

基于 Spring Boot 3 开发的文章管理API系统，提供文章列表、分类管理、文章详情等功能。

## 项目简介

本项目是一个RESTful API服务，用于管理文章和分类信息。支持文章的多图上传、多种类型筛选、分类管理等核心功能。

### 主要特性

- ✅ 文章列表查询（支持分页）
- ✅ 文章详情查看（自动增加浏览量）
- ✅ 文章分类管理
- ✅ 文章多图支持
- ✅ 多种筛选条件（状态、分类、类型）
- ✅ RESTful API设计
- ✅ 统一异常处理

### 技术栈

- **框架**: Spring Boot 3.2.0
- **Java版本**: 17
- **数据库**: MySQL 8.0+
- **ORM**: Spring Data JPA
- **构建工具**: Maven
- **其他**: Lombok, Validation

## 项目结构

```
article-api/
├── src/
│   ├── main/
│   │   ├── java/
│   │   │   └── com/example/articleapi/
│   │   │       ├── ArticleApiApplication.java    # 启动类
│   │   │       ├── controller/                  # 控制器层
│   │   │       │   ├── ArticleController.java
│   │   │       │   └── CategoryController.java
│   │   │       ├── service/                     # 服务层
│   │   │       │   ├── ArticleService.java
│   │   │       │   └── CategoryService.java
│   │   │       ├── repository/                  # 数据访问层
│   │   │       │   ├── ArticleRepository.java
│   │   │       │   └── CategoryRepository.java
│   │   │       ├── entity/                      # 实体类
│   │   │       │   ├── Article.java
│   │   │       │   └── Category.java
│   │   │       ├── dto/                         # 数据传输对象
│   │   │       │   ├── ArticleDTO.java
│   │   │       │   ├── CategoryDTO.java
│   │   │       │   ├── ArticleListRequest.java
│   │   │       │   └── PageResult.java
│   │   │       └── exception/                   # 异常处理
│   │   │           └── GlobalExceptionHandler.java
│   │   └── resources/
│   │       └── application.yml                  # 配置文件
├── database/                                    # 数据库文件
│   ├── schema.sql                              # 数据库结构
│   └── init_data.sql                           # 初始化数据
├── pom.xml                                      # Maven配置
└── README.md                                    # 项目说明

```

## 核心功能说明

### 1. 文章管理

- **文章列表**: 支持分页查询，可按状态、分类、类型筛选
- **文章详情**: 查看文章完整信息，自动增加浏览量
- **文章创建**: 支持创建新文章，可关联分类和多图
- **文章更新**: 支持更新文章信息
- **文章删除**: 支持删除文章

### 2. 分类管理

- **分类列表**: 获取所有分类
- **分类详情**: 查看单个分类信息
- **分类创建**: 创建新分类
- **分类更新**: 更新分类信息
- **分类删除**: 删除分类

### 3. 筛选功能

文章列表支持以下筛选条件：
- **状态筛选**: PUBLISHED（已发布）、DRAFT（草稿）、ARCHIVED（已归档）
- **分类筛选**: 按分类ID筛选
- **类型筛选**: NEWS（新闻）、BLOG（博客）、TUTORIAL（教程）等

### 4. 多图支持

每篇文章可以关联多张图片，图片URL存储在独立的表中，支持灵活管理。

## 快速开始

### 方式一：一键部署（推荐）🚀

项目提供了自动化部署脚本，一键完成所有部署步骤：

```bash
# 给脚本添加执行权限
chmod +x deploy.sh

# 一键部署（自动拉取项目、初始化数据库、编译、启动）
./deploy.sh --git-repo <repository-url> --db-password your_password

# 或者如果项目已在本地
./deploy.sh --skip-git-clone --db-password your_password
```

**一键部署脚本会自动完成：**
- ✅ 环境检查和依赖安装（可选）
- ✅ 项目代码拉取（可选）
- ✅ 数据库创建和初始化
- ✅ 配置文件更新
- ✅ 项目编译打包
- ✅ 应用启动和验证

更多部署选项和详细说明，请参考 [部署文档](DEPLOYMENT.md#一键部署推荐)

### 方式二：手动部署

#### 环境要求

- JDK 17+
- Maven 3.6+
- MySQL 8.0+

#### 安装步骤

1. **克隆项目**
```bash
git clone <repository-url>
cd article-api
```

2. **创建数据库**
```bash
mysql -u root -p < database/schema.sql
mysql -u root -p < database/init_data.sql
```

3. **配置数据库连接**

编辑 `src/main/resources/application.yml`，修改数据库连接信息：
```yaml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/article_db?useUnicode=true&characterEncoding=utf8&useSSL=false&serverTimezone=Asia/Shanghai
    username: root
    password: your_password
```

4. **编译运行**
```bash
mvn clean install
mvn spring-boot:run
```

5. **访问API**

服务启动后，访问地址：`http://localhost:8080/api`

## API文档

详细的API接口文档请参考 [API文档](API_DOCUMENTATION.html)

## 部署说明

详细的部署文档请参考 [部署文档](DEPLOYMENT.md)

## 许可证

MIT License
