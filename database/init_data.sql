-- 初始化测试数据

USE article_db;

-- 插入分类数据
INSERT INTO categories (name, description) VALUES
('技术', '技术相关文章'),
('生活', '生活相关文章'),
('新闻', '新闻资讯'),
('教程', '教程类文章');

-- 插入文章数据
INSERT INTO articles (title, content, cover_image, category_id, status, article_type, view_count) VALUES
('Spring Boot 3 新特性介绍', 
 'Spring Boot 3 带来了许多新特性和改进，包括对 Java 17 的支持、原生镜像支持等。本文将详细介绍这些新特性。',
 'https://example.com/images/spring-boot-3.jpg',
 1,
 'PUBLISHED',
 'TUTORIAL',
 100),

('Java 17 新特性详解',
 'Java 17 是一个长期支持版本，引入了许多新特性，如密封类、模式匹配等。',
 'https://example.com/images/java-17.jpg',
 1,
 'PUBLISHED',
 'BLOG',
 85),

('如何提高编程效率',
 '本文分享一些提高编程效率的技巧和工具，帮助开发者更高效地工作。',
 'https://example.com/images/productivity.jpg',
 1,
 'PUBLISHED',
 'BLOG',
 120),

('今日科技新闻',
 '今日科技行业的重要新闻和动态。',
 'https://example.com/images/news.jpg',
 3,
 'PUBLISHED',
 'NEWS',
 200);

-- 插入文章图片数据（多图支持）
INSERT INTO article_images (article_id, image_url) VALUES
(1, 'https://example.com/images/spring-boot-3-1.jpg'),
(1, 'https://example.com/images/spring-boot-3-2.jpg'),
(1, 'https://example.com/images/spring-boot-3-3.jpg'),
(2, 'https://example.com/images/java-17-1.jpg'),
(2, 'https://example.com/images/java-17-2.jpg'),
(3, 'https://example.com/images/productivity-1.jpg');
