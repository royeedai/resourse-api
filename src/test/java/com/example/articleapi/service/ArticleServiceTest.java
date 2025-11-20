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
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class ArticleServiceTest {

    @Mock
    private ArticleRepository articleRepository;

    @Mock
    private CategoryRepository categoryRepository;

    @InjectMocks
    private ArticleService articleService;

    private Article article;
    private Category category;
    private ArticleDTO articleDTO;

    @BeforeEach
    void setUp() {
        category = new Category();
        category.setId(1L);
        category.setName("技术");
        category.setDescription("技术类文章");

        article = new Article();
        article.setId(1L);
        article.setTitle("测试文章");
        article.setContent("测试内容");
        article.setCategory(category);
        article.setCategoryId(1L);
        article.setViewCount(10);
        article.setStatus("PUBLISHED");
        article.setArticleType("NEWS");
        article.setTag("HOT");
        article.setCreateTime(LocalDateTime.now());
        article.setUpdateTime(LocalDateTime.now());

        articleDTO = new ArticleDTO();
        articleDTO.setTitle("新文章");
        articleDTO.setContent("新内容");
        articleDTO.setCategoryId(1L);
        articleDTO.setStatus("PUBLISHED");
        articleDTO.setArticleType("NEWS");
    }

    @Test
    void testGetArticleList() {
        // Given
        ArticleListRequest request = new ArticleListRequest();
        request.setPage(0);
        request.setSize(10);
        request.setStatus("PUBLISHED");

        List<Article> articles = new ArrayList<>();
        articles.add(article);
        Page<Article> page = new PageImpl<>(articles, PageRequest.of(0, 10), 1);

        when(articleRepository.findByFilters(any(), any(), any(), any(), any(Pageable.class)))
                .thenReturn(page);

        // When
        PageResult<ArticleDTO> result = articleService.getArticleList(request);

        // Then
        assertNotNull(result);
        assertEquals(1, result.getContent().size());
        assertEquals(0, result.getPage());
        assertEquals(10, result.getSize());
        assertEquals(1L, result.getTotalElements());
    }

    @Test
    void testGetArticleById() {
        // Given
        when(articleRepository.findById(1L)).thenReturn(Optional.of(article));
        when(articleRepository.save(any(Article.class))).thenReturn(article);

        // When
        ArticleDTO result = articleService.getArticleById(1L);

        // Then
        assertNotNull(result);
        assertEquals("测试文章", result.getTitle());
        assertEquals(11, article.getViewCount()); // 应该增加1
        verify(articleRepository, times(1)).save(article);
    }

    @Test
    void testGetArticleByIdNotFound() {
        // Given
        when(articleRepository.findById(999L)).thenReturn(Optional.empty());

        // When & Then
        assertThrows(ResourceNotFoundException.class, () -> articleService.getArticleById(999L));
    }

    @Test
    void testCreateArticle() {
        // Given
        articleDTO.setTitle("新文章标题");
        when(categoryRepository.findById(1L)).thenReturn(Optional.of(category));
        when(articleRepository.save(any(Article.class))).thenReturn(article);

        // When
        ArticleDTO result = articleService.createArticle(articleDTO);

        // Then
        assertNotNull(result);
        verify(categoryRepository, times(1)).findById(1L);
        verify(articleRepository, times(1)).save(any(Article.class));
    }

    @Test
    void testCreateArticleWithEmptyTitle() {
        // Given
        articleDTO.setTitle("");

        // When & Then
        assertThrows(ValidationException.class, () -> articleService.createArticle(articleDTO));
    }

    @Test
    void testCreateArticleWithNullTitle() {
        // Given
        articleDTO.setTitle(null);

        // When & Then
        assertThrows(ValidationException.class, () -> articleService.createArticle(articleDTO));
    }

    @Test
    void testCreateArticleWithInvalidCategory() {
        // Given
        articleDTO.setTitle("新文章标题");
        articleDTO.setCategoryId(999L);
        when(categoryRepository.findById(999L)).thenReturn(Optional.empty());

        // When & Then
        assertThrows(ResourceNotFoundException.class, () -> articleService.createArticle(articleDTO));
    }

    @Test
    void testUpdateArticle() {
        // Given
        ArticleDTO updateDTO = new ArticleDTO();
        updateDTO.setTitle("更新后的标题");
        updateDTO.setContent("更新后的内容");
        updateDTO.setStatus("DRAFT");

        when(articleRepository.findById(1L)).thenReturn(Optional.of(article));
        when(articleRepository.save(any(Article.class))).thenReturn(article);

        // When
        ArticleDTO result = articleService.updateArticle(1L, updateDTO);

        // Then
        assertNotNull(result);
        verify(articleRepository, times(1)).findById(1L);
        verify(articleRepository, times(1)).save(any(Article.class));
    }

    @Test
    void testUpdateArticleWithNullCategoryId() {
        // Given
        ArticleDTO updateDTO = new ArticleDTO();
        updateDTO.setTitle("更新后的标题");
        updateDTO.setCategoryId(null);

        when(articleRepository.findById(1L)).thenReturn(Optional.of(article));
        when(articleRepository.save(any(Article.class))).thenReturn(article);

        // When
        ArticleDTO result = articleService.updateArticle(1L, updateDTO);

        // Then
        assertNotNull(result);
        verify(articleRepository, times(1)).save(any(Article.class));
    }

    @Test
    void testUpdateArticleNotFound() {
        // Given
        articleDTO.setTitle("更新后的标题");
        when(articleRepository.findById(999L)).thenReturn(Optional.empty());

        // When & Then
        assertThrows(ResourceNotFoundException.class, () -> 
            articleService.updateArticle(999L, articleDTO));
    }

    @Test
    void testDeleteArticle() {
        // Given
        when(articleRepository.existsById(1L)).thenReturn(true);
        doNothing().when(articleRepository).deleteById(1L);

        // When
        articleService.deleteArticle(1L);

        // Then
        verify(articleRepository, times(1)).existsById(1L);
        verify(articleRepository, times(1)).deleteById(1L);
    }

    @Test
    void testDeleteArticleNotFound() {
        // Given
        when(articleRepository.existsById(999L)).thenReturn(false);

        // When & Then
        assertThrows(ResourceNotFoundException.class, () -> articleService.deleteArticle(999L));
    }

    @Test
    void testGetArticleListWithHotTag() {
        // Given
        ArticleListRequest request = new ArticleListRequest();
        request.setPage(0);
        request.setSize(10);
        request.setTag("HOT");

        List<Article> articles = new ArrayList<>();
        articles.add(article);
        Page<Article> page = new PageImpl<>(articles, PageRequest.of(0, 10), 1);

        when(articleRepository.findByFilters(any(), any(), any(), eq("HOT"), any(Pageable.class)))
                .thenReturn(page);

        // When
        PageResult<ArticleDTO> result = articleService.getArticleList(request);

        // Then
        assertNotNull(result);
        assertEquals(1, result.getContent().size());
    }
}
