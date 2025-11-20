package com.example.articleapi.service;

import com.example.articleapi.dto.ArticleDTO;
import com.example.articleapi.dto.ArticleListRequest;
import com.example.articleapi.dto.PageResult;
import com.example.articleapi.entity.Article;
import com.example.articleapi.entity.Category;
import com.example.articleapi.exception.ResourceNotFoundException;
import com.example.articleapi.exception.ValidationException;
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
import java.util.Objects;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ArticleService {
    
    private final ArticleRepository articleRepository;
    private final CategoryRepository categoryRepository;
    
    public PageResult<ArticleDTO> getArticleList(ArticleListRequest request) {
        // 根据标签确定排序方式：热门按浏览量，其他按创建时间
        Sort sort = "HOT".equals(request.getTag()) 
            ? Sort.by(Sort.Direction.DESC, "viewCount")
            : Sort.by(Sort.Direction.DESC, "createTime");
        
        // 确保分页参数有效
        int page = Math.max(0, request.getPage() != null ? request.getPage() : 0);
        int size = request.getSize() != null && request.getSize() > 0 
            ? Math.min(request.getSize(), 100) // 限制最大页面大小为100
            : 10;
        
        Pageable pageable = PageRequest.of(page, size, sort);
        
        Page<Article> pageResult = articleRepository.findByFilters(
            request.getStatus(),
            request.getCategoryId(),
            request.getArticleType(),
            request.getTag(),
            pageable
        );
        
        List<ArticleDTO> content = pageResult.getContent().stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
        
        return new PageResult<>(
            content,
            pageResult.getNumber(),
            pageResult.getSize(),
            pageResult.getTotalElements()
        );
    }
    
    @Transactional
    public ArticleDTO getArticleById(Long id) {
        Article article = articleRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("文章不存在"));
        
        // 增加浏览量
        article.setViewCount((article.getViewCount() != null ? article.getViewCount() : 0) + 1);
        articleRepository.save(article);
        
        return convertToDTO(article);
    }
    
    @Transactional
    public ArticleDTO createArticle(ArticleDTO articleDTO) {
        if (articleDTO.getTitle() == null || articleDTO.getTitle().trim().isEmpty()) {
            throw new ValidationException("文章标题不能为空");
        }
        
        Article article = convertToEntity(articleDTO);
        
        if (articleDTO.getCategoryId() != null) {
            Category category = categoryRepository.findById(articleDTO.getCategoryId())
                    .orElseThrow(() -> new ResourceNotFoundException("分类不存在"));
            article.setCategory(category);
        }
        
        Article saved = articleRepository.save(article);
        return convertToDTO(saved);
    }
    
    @Transactional
    public ArticleDTO updateArticle(Long id, ArticleDTO articleDTO) {
        Article article = articleRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("文章不存在"));
        
        article.setTitle(articleDTO.getTitle());
        article.setContent(articleDTO.getContent());
        article.setCoverImage(articleDTO.getCoverImage());
        article.setImages(articleDTO.getImages() != null ? articleDTO.getImages() : new ArrayList<>());
        article.setStatus(articleDTO.getStatus() != null ? articleDTO.getStatus() : "PUBLISHED");
        article.setArticleType(articleDTO.getArticleType());
        article.setTag(articleDTO.getTag());
        
        // 处理分类更新：如果categoryId为null，清除分类；如果不同，更新分类
        if (articleDTO.getCategoryId() == null) {
            article.setCategory(null);
        } else if (!Objects.equals(articleDTO.getCategoryId(), article.getCategoryId())) {
            Category category = categoryRepository.findById(articleDTO.getCategoryId())
                    .orElseThrow(() -> new ResourceNotFoundException("分类不存在"));
            article.setCategory(category);
        }
        
        Article updated = articleRepository.save(article);
        return convertToDTO(updated);
    }
    
    @Transactional
    public void deleteArticle(Long id) {
        if (!articleRepository.existsById(id)) {
            throw new ResourceNotFoundException("文章不存在");
        }
        articleRepository.deleteById(id);
    }
    
    private ArticleDTO convertToDTO(Article article) {
        ArticleDTO dto = new ArticleDTO();
        dto.setId(article.getId());
        dto.setTitle(article.getTitle());
        dto.setContent(article.getContent());
        dto.setCoverImage(article.getCoverImage());
        dto.setImages(article.getImages() != null ? article.getImages() : new ArrayList<>());
        // categoryId是只读字段，从category关系或直接字段获取
        Long categoryId = article.getCategoryId();
        if (categoryId == null && article.getCategory() != null) {
            categoryId = article.getCategory().getId();
        }
        dto.setCategoryId(categoryId);
        if (article.getCategory() != null) {
            dto.setCategoryName(article.getCategory().getName());
        }
        dto.setViewCount(article.getViewCount() != null ? article.getViewCount() : 0);
        dto.setStatus(article.getStatus());
        dto.setArticleType(article.getArticleType());
        dto.setTag(article.getTag());
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
        article.setTag(dto.getTag());
        return article;
    }
}
