# 📚 文章管理API接口文档

## 基础信息

- **基础URL**: `http://localhost:8080/api`
- **Content-Type**: `application/json`

---

## 📝 文章接口

### 标签功能说明

文章支持标签功能，用于标识和筛选文章：

- **HOT（热门）**: 当使用 `tag=HOT` 筛选时，文章列表会按浏览量（viewCount）降序排列，显示最受欢迎的文章
- **LATEST（最新）**: 当使用 `tag=LATEST` 筛选时，文章列表会按创建时间（createTime）降序排列，显示最新发布的文章
- 标签可以作为文章属性存储，也可以仅作为筛选条件使用
- 标签筛选可以与其他筛选条件（status、categoryId、articleType）组合使用

### 1. 获取文章列表

**接口描述**: 获取文章列表 - 支持分页和多种筛选条件

**请求方式**: `GET`

**请求路径**: `/articles`

**请求参数**:

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| page | Integer | 否 | 页码，从0开始，默认0 |
| size | Integer | 否 | 每页数量，默认10 |
| status | String | 否 | 状态筛选：PUBLISHED（已发布）、DRAFT（草稿）、ARCHIVED（已归档） |
| categoryId | Long | 否 | 分类ID筛选 |
| articleType | String | 否 | 文章类型筛选：NEWS（新闻）、BLOG（博客）、TUTORIAL（教程）等 |
| tag | String | 否 | 标签筛选：HOT（热门，按浏览量降序）、LATEST（最新，按创建时间降序） |

**请求示例**:
```
# 获取热门文章
GET /api/articles?tag=HOT&page=0&size=10

# 获取最新文章
GET /api/articles?tag=LATEST&page=0&size=10

# 组合筛选：获取某个分类下的热门文章
GET /api/articles?tag=HOT&categoryId=1&status=PUBLISHED

# 普通列表（默认按创建时间降序）
GET /api/articles?page=0&size=10&status=PUBLISHED&categoryId=1&articleType=BLOG
```

**响应示例**:
```json
{
  "content": [
    {
      "id": 1,
      "title": "Spring Boot 3 新特性介绍",
      "content": "Spring Boot 3 带来了许多新特性...",
      "coverImage": "https://example.com/images/spring-boot-3.jpg",
      "images": [
        "https://example.com/images/spring-boot-3-1.jpg",
        "https://example.com/images/spring-boot-3-2.jpg"
      ],
      "categoryId": 1,
      "categoryName": "技术",
      "viewCount": 100,
      "status": "PUBLISHED",
      "articleType": "TUTORIAL",
      "tag": "HOT",
      "createTime": "2024-01-01T10:00:00",
      "updateTime": "2024-01-01T10:00:00"
    }
  ],
  "page": 0,
  "size": 10,
  "totalElements": 50,
  "totalPages": 5,
  "hasNext": true,
  "hasPrevious": false
}
```

---

### 2. 获取文章详情

**接口描述**: 获取文章详情 - 查看指定文章的完整信息，访问后自动增加浏览量

**请求方式**: `GET`

**请求路径**: `/articles/{id}`

**路径参数**:

| 参数名 | 类型 | 说明 |
|--------|------|------|
| id | Long | 文章ID |

**请求示例**:
```
GET /api/articles/1
```

**响应示例**:
```json
{
  "id": 1,
  "title": "Spring Boot 3 新特性介绍",
  "content": "Spring Boot 3 带来了许多新特性和改进...",
  "coverImage": "https://example.com/images/spring-boot-3.jpg",
  "images": [
    "https://example.com/images/spring-boot-3-1.jpg",
    "https://example.com/images/spring-boot-3-2.jpg",
    "https://example.com/images/spring-boot-3-3.jpg"
  ],
  "categoryId": 1,
  "categoryName": "技术",
  "viewCount": 101,
  "status": "PUBLISHED",
  "articleType": "TUTORIAL",
  "tag": "LATEST",
  "createTime": "2024-01-01T10:00:00",
  "updateTime": "2024-01-01T10:00:00"
}
```

---

### 3. 创建文章

**接口描述**: 创建文章 - 创建一篇新文章

**请求方式**: `POST`

**请求路径**: `/articles`

**请求体参数**:

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| title | String | **是** | 文章标题 |
| content | String | 否 | 文章内容 |
| coverImage | String | 否 | 封面图片URL |
| images | Array<String> | 否 | 文章图片URL数组（支持多图） |
| categoryId | Long | 否 | 分类ID |
| status | String | 否 | 状态，默认PUBLISHED |
| articleType | String | 否 | 文章类型 |
| tag | String | 否 | 标签：HOT（热门）、LATEST（最新） |

**请求示例**:
```
POST /api/articles
Content-Type: application/json

{
  "title": "新文章标题",
  "content": "文章内容...",
  "coverImage": "https://example.com/images/cover.jpg",
  "images": [
    "https://example.com/images/img1.jpg",
    "https://example.com/images/img2.jpg"
  ],
  "categoryId": 1,
  "status": "PUBLISHED",
  "articleType": "BLOG",
  "tag": "HOT"
}
```

---

### 4. 更新文章

**接口描述**: 更新文章 - 更新指定文章的信息

**请求方式**: `PUT`

**请求路径**: `/articles/{id}`

**请求示例**:
```
PUT /api/articles/1
Content-Type: application/json

{
  "title": "更新后的标题",
  "content": "更新后的内容...",
  "images": ["https://example.com/images/new-img.jpg"],
  "status": "PUBLISHED",
  "tag": "LATEST"
}
```

---

### 5. 删除文章

**接口描述**: 删除文章 - 删除指定文章

**请求方式**: `DELETE`

**请求路径**: `/articles/{id}`

**请求示例**:
```
DELETE /api/articles/1
```

---

## 📂 分类接口

### 1. 获取所有分类

**接口描述**: 获取所有分类 - 返回所有文章分类列表

**请求方式**: `GET`

**请求路径**: `/categories`

**响应示例**:
```json
[
  {
    "id": 1,
    "name": "技术",
    "description": "技术相关文章",
    "createTime": "2024-01-01T10:00:00",
    "updateTime": "2024-01-01T10:00:00"
  },
  {
    "id": 2,
    "name": "生活",
    "description": "生活相关文章",
    "createTime": "2024-01-01T10:00:00",
    "updateTime": "2024-01-01T10:00:00"
  }
]
```

---

### 2. 获取分类详情

**接口描述**: 获取分类详情 - 获取指定分类的详细信息

**请求方式**: `GET`

**请求路径**: `/categories/{id}`

---

### 3. 创建分类

**接口描述**: 创建分类 - 创建新的文章分类

**请求方式**: `POST`

**请求路径**: `/categories`

**请求示例**:
```
POST /api/categories
Content-Type: application/json

{
  "name": "新分类",
  "description": "分类描述"
}
```

---

### 4. 更新分类

**接口描述**: 更新分类 - 更新指定分类的信息

**请求方式**: `PUT`

**请求路径**: `/categories/{id}`

---

### 5. 删除分类

**接口描述**: 删除分类 - 删除指定分类

**请求方式**: `DELETE`

**请求路径**: `/categories/{id}`

---

## ❌ 错误响应

当请求失败时，API会返回以下格式的错误响应：

### 错误响应格式

```json
{
  "success": false,
  "message": "错误信息",
  "code": 400
}
```

### 常见错误码

| HTTP状态码 | 说明 |
|-----------|------|
| 400 | 请求参数错误 |
| 404 | 资源不存在 |
| 500 | 服务器内部错误 |

---

## 📝 注意事项

1. **基础URL**: 所有接口的基础路径为 `/api`，完整URL为 `http://localhost:8080/api`
2. **Content-Type**: 所有POST和PUT请求需要设置 `Content-Type: application/json`
3. **分页参数**: `page` 从0开始，`size` 默认为10
4. **自动功能**: 获取文章详情时会自动增加浏览量（viewCount）
5. **时间格式**: 所有时间字段使用ISO 8601格式：`2024-01-01T10:00:00`

## 🔗 相关文档

- [项目README](README.md)
- [部署文档](DEPLOYMENT.md)

---

**文档版本**: 1.0.0 | **最后更新**: 2024年
