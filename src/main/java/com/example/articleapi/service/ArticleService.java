package com.example.articleapi.service;

import com.example.articleapi.dto.ArticleDTO;
import com.example.articleapi.dto.ArticleListRequest;
import com.example.articleapi.dto.PageResult;
import com.example.articleapi.entity.Article;
import com.example.articleapi.entity.Category;
import com.example.articleapi.repository.ArticleRepository;
import com.example.articleapi.repository.CategoryRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ArticleService {
    
    private final ArticleRepository articleRepository;
    private final CategoryRepository categoryRepository;
    
    public PageResult<ArticleDTO> getArticleList(ArticleListRequest request) {
        Pageable pageable = PageRequest.of(
            request.getPage(),
            request.getSize(),
            Sort.by(Sort.Direction.DESC, "createTime")
        );
        
        Page<Article> page = articleRepository.findByFilters(
            request.getStatus(),
            request.getCategoryId(),
            request.getArticleType(),
            pageable
        );
        
        List<ArticleDTO> content = page.getContent().stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
        
        return new PageResult<>(
            content,
            page.getNumber(),
            page.getSize(),
            page.getTotalElements()
        );
    }
    
    public ArticleDTO getArticleById(Long id) {
        Article article = articleRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("文章不存在"));
        
        // 增加浏览量
        article.setViewCount(article.getViewCount() + 1);
        articleRepository.save(article);
        
        return convertToDTO(article);
    }
    
    @Transactional
    public ArticleDTO createArticle(ArticleDTO articleDTO) {
        Article article = convertToEntity(articleDTO);
        
        if (articleDTO.getCategoryId() != null) {
            Category category = categoryRepository.findById(articleDTO.getCategoryId())
                    .orElseThrow(() -> new RuntimeException("分类不存在"));
            article.setCategory(category);
        }
        
        Article saved = articleRepository.save(article);
        return convertToDTO(saved);
    }
    
    @Transactional
    public ArticleDTO updateArticle(Long id, ArticleDTO articleDTO) {
        Article article = articleRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("文章不存在"));
        
        article.setTitle(articleDTO.getTitle());
        article.setContent(articleDTO.getContent());
        article.setCoverImage(articleDTO.getCoverImage());
        article.setImages(articleDTO.getImages());
        article.setStatus(articleDTO.getStatus());
        article.setArticleType(articleDTO.getArticleType());
        
        if (articleDTO.getCategoryId() != null && 
            !articleDTO.getCategoryId().equals(article.getCategoryId())) {
            Category category = categoryRepository.findById(articleDTO.getCategoryId())
                    .orElseThrow(() -> new RuntimeException("分类不存在"));
            article.setCategory(category);
        }
        
        Article updated = articleRepository.save(article);
        return convertToDTO(updated);
    }
    
    @Transactional
    public void deleteArticle(Long id) {
        if (!articleRepository.existsById(id)) {
            throw new RuntimeException("文章不存在");
        }
        articleRepository.deleteById(id);
    }
    
    private ArticleDTO convertToDTO(Article article) {
        ArticleDTO dto = new ArticleDTO();
        dto.setId(article.getId());
        dto.setTitle(article.getTitle());
        dto.setContent(article.getContent());
        dto.setCoverImage(article.getCoverImage());
        dto.setImages(article.getImages());
        dto.setCategoryId(article.getCategoryId());
        if (article.getCategory() != null) {
            dto.setCategoryName(article.getCategory().getName());
        }
        dto.setViewCount(article.getViewCount());
        dto.setStatus(article.getStatus());
        dto.setArticleType(article.getArticleType());
        dto.setCreateTime(article.getCreateTime());
        dto.setUpdateTime(article.getUpdateTime());
        return dto;
    }
    
    private Article convertToEntity(ArticleDTO dto) {
        Article article = new Article();
        article.setTitle(dto.getTitle());
        article.setContent(dto.getContent());
        article.setCoverImage(dto.getCoverImage());
        article.setImages(dto.getImages() != null ? dto.getImages() : new ArrayList<>());
        article.setStatus(dto.getStatus() != null ? dto.getStatus() : "PUBLISHED");
        article.setArticleType(dto.getArticleType());
        return article;
    }
}
