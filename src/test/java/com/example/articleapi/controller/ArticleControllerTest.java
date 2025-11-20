package com.example.articleapi.controller;

import com.example.articleapi.dto.ArticleDTO;
import com.example.articleapi.dto.PageResult;
import com.example.articleapi.service.ArticleService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class ArticleControllerTest {

    @Mock
    private ArticleService articleService;

    @InjectMocks
    private ArticleController articleController;

    private ArticleDTO articleDTO;
    private PageResult<ArticleDTO> pageResult;

    @BeforeEach
    void setUp() {
        articleDTO = new ArticleDTO();
        articleDTO.setId(1L);
        articleDTO.setTitle("测试文章");
        articleDTO.setContent("测试内容");
        articleDTO.setStatus("PUBLISHED");

        List<ArticleDTO> content = new ArrayList<>();
        content.add(articleDTO);
        pageResult = new PageResult<>(content, 0, 10, 1L);
    }

    @Test
    void testGetArticleList() {
        // Given
        when(articleService.getArticleList(any())).thenReturn(pageResult);

        // When
        ResponseEntity<PageResult<ArticleDTO>> response = articleController.getArticleList(
            null, null, null, null, null, null);

        // Then
        assertNotNull(response);
        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertNotNull(response.getBody());
        assertEquals(1, response.getBody().getContent().size());
    }

    @Test
    void testGetArticleListWithParameters() {
        // Given
        when(articleService.getArticleList(any())).thenReturn(pageResult);

        // When
        ResponseEntity<PageResult<ArticleDTO>> response = articleController.getArticleList(
            0, 10, "PUBLISHED", 1L, "NEWS", "HOT");

        // Then
        assertNotNull(response);
        assertEquals(HttpStatus.OK, response.getStatusCode());
        verify(articleService, times(1)).getArticleList(any());
    }

    @Test
    void testGetArticleById() {
        // Given
        when(articleService.getArticleById(1L)).thenReturn(articleDTO);

        // When
        ResponseEntity<ArticleDTO> response = articleController.getArticleById(1L);

        // Then
        assertNotNull(response);
        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertNotNull(response.getBody());
        assertEquals("测试文章", response.getBody().getTitle());
    }

    @Test
    void testCreateArticle() {
        // Given
        ArticleDTO newArticle = new ArticleDTO();
        newArticle.setTitle("新文章");
        newArticle.setContent("新内容");

        when(articleService.createArticle(any(ArticleDTO.class))).thenReturn(articleDTO);

        // When
        ResponseEntity<ArticleDTO> response = articleController.createArticle(newArticle);

        // Then
        assertNotNull(response);
        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertNotNull(response.getBody());
        verify(articleService, times(1)).createArticle(any(ArticleDTO.class));
    }

    @Test
    void testUpdateArticle() {
        // Given
        ArticleDTO updateDTO = new ArticleDTO();
        updateDTO.setTitle("更新后的标题");

        when(articleService.updateArticle(eq(1L), any(ArticleDTO.class))).thenReturn(articleDTO);

        // When
        ResponseEntity<ArticleDTO> response = articleController.updateArticle(1L, updateDTO);

        // Then
        assertNotNull(response);
        assertEquals(HttpStatus.OK, response.getStatusCode());
        verify(articleService, times(1)).updateArticle(eq(1L), any(ArticleDTO.class));
    }

    @Test
    void testDeleteArticle() {
        // Given
        doNothing().when(articleService).deleteArticle(1L);

        // When
        ResponseEntity<Void> response = articleController.deleteArticle(1L);

        // Then
        assertNotNull(response);
        assertEquals(HttpStatus.OK, response.getStatusCode());
        verify(articleService, times(1)).deleteArticle(1L);
    }
}
