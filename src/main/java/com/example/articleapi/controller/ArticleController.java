package com.example.articleapi.controller;

import com.example.articleapi.dto.ArticleDTO;
import com.example.articleapi.dto.ArticleListRequest;
import com.example.articleapi.dto.PageResult;
import com.example.articleapi.service.ArticleService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/articles")
@RequiredArgsConstructor
public class ArticleController {
    
    private final ArticleService articleService;
    
    @GetMapping
    public ResponseEntity<PageResult<ArticleDTO>> getArticleList(
            @RequestParam(required = false) Integer page,
            @RequestParam(required = false) Integer size,
            @RequestParam(required = false) String status,
            @RequestParam(required = false) Long categoryId,
            @RequestParam(required = false) String articleType,
            @RequestParam(required = false) String tag) {
        
        ArticleListRequest request = new ArticleListRequest();
        request.setPage(page);
        request.setSize(size);
        request.setStatus(status);
        request.setCategoryId(categoryId);
        request.setArticleType(articleType);
        request.setTag(tag);
        
        PageResult<ArticleDTO> result = articleService.getArticleList(request);
        return ResponseEntity.ok(result);
    }
    
    @GetMapping("/{id}")
    public ResponseEntity<ArticleDTO> getArticleById(@PathVariable Long id) {
        ArticleDTO article = articleService.getArticleById(id);
        return ResponseEntity.ok(article);
    }
    
    @PostMapping
    public ResponseEntity<ArticleDTO> createArticle(@RequestBody ArticleDTO articleDTO) {
        ArticleDTO created = articleService.createArticle(articleDTO);
        return ResponseEntity.ok(created);
    }
    
    @PutMapping("/{id}")
    public ResponseEntity<ArticleDTO> updateArticle(
            @PathVariable Long id,
            @RequestBody ArticleDTO articleDTO) {
        ArticleDTO updated = articleService.updateArticle(id, articleDTO);
        return ResponseEntity.ok(updated);
    }
    
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteArticle(@PathVariable Long id) {
        articleService.deleteArticle(id);
        return ResponseEntity.ok().build();
    }
}
