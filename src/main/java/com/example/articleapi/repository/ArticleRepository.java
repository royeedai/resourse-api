package com.example.articleapi.repository;

import com.example.articleapi.entity.Article;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface ArticleRepository extends JpaRepository<Article, Long> {
    
    Page<Article> findByStatus(String status, Pageable pageable);
    
    Page<Article> findByCategoryId(Long categoryId, Pageable pageable);
    
    Page<Article> findByArticleType(String articleType, Pageable pageable);
    
    Page<Article> findByStatusAndCategoryId(String status, Long categoryId, Pageable pageable);
    
    Page<Article> findByStatusAndArticleType(String status, String articleType, Pageable pageable);
    
    Page<Article> findByCategoryIdAndArticleType(Long categoryId, String articleType, Pageable pageable);
    
    Page<Article> findByStatusAndCategoryIdAndArticleType(String status, Long categoryId, String articleType, Pageable pageable);
    
    @Query("SELECT a FROM Article a WHERE " +
           "(:status IS NULL OR a.status = :status) AND " +
           "(:categoryId IS NULL OR a.categoryId = :categoryId) AND " +
           "(:articleType IS NULL OR a.articleType = :articleType)")
    Page<Article> findByFilters(
        @Param("status") String status,
        @Param("categoryId") Long categoryId,
        @Param("articleType") String articleType,
        Pageable pageable
    );
    
    Optional<Article> findByIdAndStatus(Long id, String status);
}
