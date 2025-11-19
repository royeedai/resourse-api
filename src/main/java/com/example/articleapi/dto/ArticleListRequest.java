package com.example.articleapi.dto;

import lombok.Data;

@Data
public class ArticleListRequest {
    private Integer page = 0;
    private Integer size = 10;
    private String status; // PUBLISHED, DRAFT, ARCHIVED
    private Long categoryId;
    private String articleType; // NEWS, BLOG, TUTORIAL, etc.
    private String tag; // HOT-热门, LATEST-最新
}
