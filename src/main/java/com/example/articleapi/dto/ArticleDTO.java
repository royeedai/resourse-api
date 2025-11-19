package com.example.articleapi.dto;

import lombok.Data;
import java.time.LocalDateTime;
import java.util.List;

@Data
public class ArticleDTO {
    private Long id;
    private String title;
    private String content;
    private String coverImage;
    private List<String> images;
    private Long categoryId;
    private String categoryName;
    private Integer viewCount;
    private String status;
    private String articleType;
    private String tag; // HOT-热门, LATEST-最新
    private LocalDateTime createTime;
    private LocalDateTime updateTime;
}
