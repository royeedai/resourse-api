package com.example.articleapi.controller;

import com.example.articleapi.dto.CategoryDTO;
import com.example.articleapi.service.CategoryService;
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
class CategoryControllerTest {

    @Mock
    private CategoryService categoryService;

    @InjectMocks
    private CategoryController categoryController;

    private CategoryDTO categoryDTO;

    @BeforeEach
    void setUp() {
        categoryDTO = new CategoryDTO();
        categoryDTO.setId(1L);
        categoryDTO.setName("技术");
        categoryDTO.setDescription("技术类文章");
        categoryDTO.setCreateTime(LocalDateTime.now());
        categoryDTO.setUpdateTime(LocalDateTime.now());
    }

    @Test
    void testGetAllCategories() {
        // Given
        List<CategoryDTO> categories = new ArrayList<>();
        categories.add(categoryDTO);
        when(categoryService.getAllCategories()).thenReturn(categories);

        // When
        ResponseEntity<List<CategoryDTO>> response = categoryController.getAllCategories();

        // Then
        assertNotNull(response);
        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertNotNull(response.getBody());
        assertEquals(1, response.getBody().size());
        assertEquals("技术", response.getBody().get(0).getName());
    }

    @Test
    void testGetCategoryById() {
        // Given
        when(categoryService.getCategoryById(1L)).thenReturn(categoryDTO);

        // When
        ResponseEntity<CategoryDTO> response = categoryController.getCategoryById(1L);

        // Then
        assertNotNull(response);
        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertNotNull(response.getBody());
        assertEquals("技术", response.getBody().getName());
    }

    @Test
    void testCreateCategory() {
        // Given
        CategoryDTO newCategory = new CategoryDTO();
        newCategory.setName("新分类");
        newCategory.setDescription("新分类描述");

        when(categoryService.createCategory(any(CategoryDTO.class))).thenReturn(categoryDTO);

        // When
        ResponseEntity<CategoryDTO> response = categoryController.createCategory(newCategory);

        // Then
        assertNotNull(response);
        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertNotNull(response.getBody());
        verify(categoryService, times(1)).createCategory(any(CategoryDTO.class));
    }

    @Test
    void testUpdateCategory() {
        // Given
        CategoryDTO updateDTO = new CategoryDTO();
        updateDTO.setName("更新后的分类");

        when(categoryService.updateCategory(eq(1L), any(CategoryDTO.class))).thenReturn(categoryDTO);

        // When
        ResponseEntity<CategoryDTO> response = categoryController.updateCategory(1L, updateDTO);

        // Then
        assertNotNull(response);
        assertEquals(HttpStatus.OK, response.getStatusCode());
        verify(categoryService, times(1)).updateCategory(eq(1L), any(CategoryDTO.class));
    }

    @Test
    void testDeleteCategory() {
        // Given
        doNothing().when(categoryService).deleteCategory(1L);

        // When
        ResponseEntity<Void> response = categoryController.deleteCategory(1L);

        // Then
        assertNotNull(response);
        assertEquals(HttpStatus.OK, response.getStatusCode());
        verify(categoryService, times(1)).deleteCategory(1L);
    }
}
