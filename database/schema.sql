-- 创建数据库
CREATE DATABASE IF NOT EXISTS article_db DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE article_db;

-- 创建分类表
CREATE TABLE IF NOT EXISTS categories (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE COMMENT '分类名称',
    description VARCHAR(200) COMMENT '分类描述',
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX idx_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='文章分类表';

-- 创建文章表
CREATE TABLE IF NOT EXISTS articles (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(200) NOT NULL COMMENT '文章标题',
    content TEXT COMMENT '文章内容',
    cover_image VARCHAR(500) COMMENT '封面图片',
    category_id BIGINT COMMENT '分类ID',
    view_count INT DEFAULT 0 COMMENT '浏览量',
    status VARCHAR(20) DEFAULT 'PUBLISHED' COMMENT '状态: PUBLISHED-已发布, DRAFT-草稿, ARCHIVED-已归档',
    article_type VARCHAR(50) COMMENT '文章类型: NEWS-新闻, BLOG-博客, TUTORIAL-教程等',
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE SET NULL,
    INDEX idx_category_id (category_id),
    INDEX idx_status (status),
    INDEX idx_article_type (article_type),
    INDEX idx_create_time (create_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='文章表';

-- 创建文章图片表（多图支持）
CREATE TABLE IF NOT EXISTS article_images (
    article_id BIGINT NOT NULL COMMENT '文章ID',
    image_url VARCHAR(500) NOT NULL COMMENT '图片URL',
    FOREIGN KEY (article_id) REFERENCES articles(id) ON DELETE CASCADE,
    INDEX idx_article_id (article_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='文章图片表';
