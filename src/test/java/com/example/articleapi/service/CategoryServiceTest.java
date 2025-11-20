package com.example.articleapi.service;

import com.example.articleapi.dto.CategoryDTO;
import com.example.articleapi.entity.Category;
import com.example.articleapi.exception.ResourceNotFoundException;
import com.example.articleapi.exception.ValidationException;
import com.example.articleapi.repository.CategoryRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class CategoryServiceTest {

    @Mock
    private CategoryRepository categoryRepository;

    @InjectMocks
    private CategoryService categoryService;

    private Category category;
    private CategoryDTO categoryDTO;

    @BeforeEach
    void setUp() {
        category = new Category();
        category.setId(1L);
        category.setName("技术");
        category.setDescription("技术类文章");
        category.setCreateTime(LocalDateTime.now());
        category.setUpdateTime(LocalDateTime.now());

        categoryDTO = new CategoryDTO();
        categoryDTO.setName("新分类");
        categoryDTO.setDescription("新分类描述");
    }

    @Test
    void testGetAllCategories() {
        // Given
        List<Category> categories = new ArrayList<>();
        categories.add(category);
        when(categoryRepository.findAll()).thenReturn(categories);

        // When
        List<CategoryDTO> result = categoryService.getAllCategories();

        // Then
        assertNotNull(result);
        assertEquals(1, result.size());
        assertEquals("技术", result.get(0).getName());
    }

    @Test
    void testGetCategoryById() {
        // Given
        when(categoryRepository.findById(1L)).thenReturn(Optional.of(category));

        // When
        CategoryDTO result = categoryService.getCategoryById(1L);

        // Then
        assertNotNull(result);
        assertEquals("技术", result.getName());
        assertEquals("技术类文章", result.getDescription());
    }

    @Test
    void testGetCategoryByIdNotFound() {
        // Given
        when(categoryRepository.findById(999L)).thenReturn(Optional.empty());

        // When & Then
        assertThrows(ResourceNotFoundException.class, () -> categoryService.getCategoryById(999L));
    }

    @Test
    void testCreateCategory() {
        // Given
        when(categoryRepository.existsByName("新分类")).thenReturn(false);
        when(categoryRepository.save(any(Category.class))).thenReturn(category);

        // When
        CategoryDTO result = categoryService.createCategory(categoryDTO);

        // Then
        assertNotNull(result);
        verify(categoryRepository, times(1)).existsByName("新分类");
        verify(categoryRepository, times(1)).save(any(Category.class));
    }

    @Test
    void testCreateCategoryWithEmptyName() {
        // Given
        categoryDTO.setName("");

        // When & Then
        assertThrows(ValidationException.class, () -> categoryService.createCategory(categoryDTO));
    }

    @Test
    void testCreateCategoryWithNullName() {
        // Given
        categoryDTO.setName(null);

        // When & Then
        assertThrows(ValidationException.class, () -> categoryService.createCategory(categoryDTO));
    }

    @Test
    void testCreateCategoryWithDuplicateName() {
        // Given
        when(categoryRepository.existsByName("新分类")).thenReturn(true);

        // When & Then
        assertThrows(ValidationException.class, () -> categoryService.createCategory(categoryDTO));
    }

    @Test
    void testUpdateCategory() {
        // Given
        CategoryDTO updateDTO = new CategoryDTO();
        updateDTO.setName("更新后的分类");
        updateDTO.setDescription("更新后的描述");

        when(categoryRepository.findById(1L)).thenReturn(Optional.of(category));
        when(categoryRepository.existsByName("更新后的分类")).thenReturn(false);
        when(categoryRepository.save(any(Category.class))).thenReturn(category);

        // When
        CategoryDTO result = categoryService.updateCategory(1L, updateDTO);

        // Then
        assertNotNull(result);
        verify(categoryRepository, times(1)).findById(1L);
        verify(categoryRepository, times(1)).save(any(Category.class));
    }

    @Test
    void testUpdateCategoryWithEmptyName() {
        // Given
        CategoryDTO updateDTO = new CategoryDTO();
        updateDTO.setName("");
        updateDTO.setDescription("描述");

        when(categoryRepository.findById(1L)).thenReturn(Optional.of(category));

        // When & Then
        assertThrows(ValidationException.class, () -> categoryService.updateCategory(1L, updateDTO));
    }

    @Test
    void testUpdateCategoryNotFound() {
        // Given
        categoryDTO.setName("更新后的分类");
        when(categoryRepository.findById(999L)).thenReturn(Optional.empty());

        // When & Then
        assertThrows(ResourceNotFoundException.class, () -> 
            categoryService.updateCategory(999L, categoryDTO));
    }

    @Test
    void testUpdateCategoryWithDuplicateName() {
        // Given
        CategoryDTO updateDTO = new CategoryDTO();
        updateDTO.setName("已存在的分类");
        updateDTO.setDescription("描述");

        Category existingCategory = new Category();
        existingCategory.setId(2L);
        existingCategory.setName("已存在的分类");

        when(categoryRepository.findById(1L)).thenReturn(Optional.of(category));
        when(categoryRepository.existsByName("已存在的分类")).thenReturn(true);

        // When & Then
        assertThrows(ValidationException.class, () -> 
            categoryService.updateCategory(1L, updateDTO));
    }

    @Test
    void testDeleteCategory() {
        // Given
        when(categoryRepository.existsById(1L)).thenReturn(true);
        doNothing().when(categoryRepository).deleteById(1L);

        // When
        categoryService.deleteCategory(1L);

        // Then
        verify(categoryRepository, times(1)).existsById(1L);
        verify(categoryRepository, times(1)).deleteById(1L);
    }

    @Test
    void testDeleteCategoryNotFound() {
        // Given
        when(categoryRepository.existsById(999L)).thenReturn(false);

        // When & Then
        assertThrows(ResourceNotFoundException.class, () -> categoryService.deleteCategory(999L));
    }
}
