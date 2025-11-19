#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
抓取 xiaoxuewang.cn 网站数据并生成SQL插入语句
"""

import requests
from bs4 import BeautifulSoup
import re
import time
import json
from urllib.parse import urljoin, urlparse
import html

class XiaoxuewangScraper:
    def __init__(self, base_url="http://www.xiaoxuewang.cn"):
        self.base_url = base_url
        self.session = requests.Session()
        self.session.headers.update({
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
        })
        self.categories = {}
        self.articles = []
        
    def fetch_page(self, url, encoding='gbk'):
        """获取网页内容"""
        try:
            response = self.session.get(url, timeout=10)
            response.encoding = encoding
            return response.text
        except Exception as e:
            print(f"获取页面失败 {url}: {e}")
            return None
    
    def parse_categories(self):
        """解析分类信息"""
        html_content = self.fetch_page(self.base_url)
        if not html_content:
            return
        
        soup = BeautifulSoup(html_content, 'html.parser')
        
        # 查找导航菜单中的分类链接
        nav_links = soup.find_all('a', href=re.compile(r'kc/\d+/'))
        
        categories_set = set()
        for link in nav_links:
            text = link.get_text(strip=True)
            if text and text not in ['课程', '首页']:
                categories_set.add(text)
        
        # 添加一些常见的小学分类
        default_categories = {
            '语文': '小学语文相关文章',
            '数学': '小学数学相关文章',
            '英语': '小学英语相关文章',
            '一年级': '一年级相关文章',
            '二年级': '二年级相关文章',
            '三年级': '三年级相关文章',
            '四年级': '四年级相关文章',
            '五年级': '五年级相关文章',
            '六年级': '六年级相关文章',
        }
        
        for name, desc in default_categories.items():
            if name not in categories_set:
                categories_set.add(name)
        
        # 创建分类映射
        for idx, name in enumerate(sorted(categories_set), 1):
            self.categories[name] = {
                'id': idx,
                'name': name,
                'description': default_categories.get(name, f'{name}相关文章')
            }
    
    def extract_articles_from_list(self, url):
        """从列表页提取文章"""
        html_content = self.fetch_page(url)
        if not html_content:
            return []
        
        soup = BeautifulSoup(html_content, 'html.parser')
        articles = []
        
        # 查找文章链接 - 尝试多种选择器
        article_links = []
        
        # 方法1: 查找包含文章标题的链接
        links = soup.find_all('a', href=True)
        for link in links:
            href = link.get('href', '')
            text = link.get_text(strip=True)
            
            # 过滤掉导航链接和无效链接
            if (text and len(text) > 5 and 
                not href.startswith('#') and 
                not href.startswith('javascript:') and
                'index' not in href.lower() and
                'login' not in href.lower() and
                'register' not in href.lower()):
                
                full_url = urljoin(self.base_url, href)
                if 'xiaoxuewang.cn' in full_url:
                    article_links.append({
                        'url': full_url,
                        'title': text[:200]  # 限制标题长度
                    })
        
        # 去重
        seen_urls = set()
        for item in article_links:
            if item['url'] not in seen_urls and item['title']:
                seen_urls.add(item['url'])
                articles.append(item)
        
        return articles[:50]  # 限制每页最多50篇文章
    
    def extract_article_content(self, url):
        """提取文章详情"""
        html_content = self.fetch_page(url)
        if not html_content:
            return None
        
        soup = BeautifulSoup(html_content, 'html.parser')
        
        # 提取标题
        title = ''
        title_tag = soup.find('title')
        if title_tag:
            title = title_tag.get_text(strip=True)
            # 清理标题
            title = re.sub(r'[-_].*?xiaoxuewang.*?$', '', title, flags=re.IGNORECASE)
            title = title.strip()
        
        # 提取内容
        content = ''
        # 尝试多种内容选择器
        content_selectors = [
            'div.content',
            'div.article-content',
            'div.text',
            'div.main-content',
            'article',
            'div[class*="content"]',
            'div[class*="article"]'
        ]
        
        for selector in content_selectors:
            content_div = soup.select_one(selector)
            if content_div:
                # 移除脚本和样式
                for script in content_div(["script", "style"]):
                    script.decompose()
                content = content_div.get_text(separator='\n', strip=True)
                if len(content) > 100:  # 确保内容足够长
                    break
        
        # 如果没找到，尝试获取body中的所有文本
        if not content or len(content) < 100:
            body = soup.find('body')
            if body:
                for script in body(["script", "style", "nav", "header", "footer"]):
                    script.decompose()
                content = body.get_text(separator='\n', strip=True)
                # 清理内容
                content = re.sub(r'\n{3,}', '\n\n', content)
                content = content[:5000]  # 限制内容长度
        
        # 提取图片
        images = []
        img_tags = soup.find_all('img', src=True)
        for img in img_tags:
            src = img.get('src', '')
            if src:
                full_url = urljoin(self.base_url, src)
                if 'xiaoxuewang.cn' in full_url or src.startswith('http'):
                    images.append(full_url)
        
        return {
            'title': title[:200] if title else '未命名文章',
            'content': content[:5000] if content else '',
            'images': images[:10],  # 最多10张图片
            'cover_image': images[0] if images else None
        }
    
    def scrape_articles(self, max_articles=100):
        """抓取文章"""
        print("开始解析分类...")
        self.parse_categories()
        print(f"找到 {len(self.categories)} 个分类")
        
        print("开始抓取文章...")
        
        # 从首页开始抓取
        article_urls = self.extract_articles_from_list(self.base_url)
        
        # 尝试抓取一些分类页面
        category_urls = [
            f"{self.base_url}/kc/1/yw/",  # 一年级语文
            f"{self.base_url}/kc/2/sx/",  # 二年级数学
            f"{self.base_url}/kc/3/yy/",  # 三年级英语
        ]
        
        for cat_url in category_urls:
            try:
                urls = self.extract_articles_from_list(cat_url)
                article_urls.extend(urls)
                time.sleep(1)  # 避免请求过快
            except Exception as e:
                print(f"抓取分类页面失败 {cat_url}: {e}")
        
        # 去重
        seen_urls = set()
        unique_articles = []
        for item in article_urls:
            if item['url'] not in seen_urls:
                seen_urls.add(item['url'])
                unique_articles.append(item)
        
        print(f"找到 {len(unique_articles)} 个文章链接")
        
        # 抓取文章详情
        for idx, article_info in enumerate(unique_articles[:max_articles], 1):
            print(f"正在抓取文章 {idx}/{min(len(unique_articles), max_articles)}: {article_info['title']}")
            
            detail = self.extract_article_content(article_info['url'])
            if detail:
                # 确定分类（简单匹配）
                category_name = '语文'  # 默认分类
                url_lower = article_info['url'].lower()
                if 'sx' in url_lower or '数学' in article_info['title']:
                    category_name = '数学'
                elif 'yy' in url_lower or '英语' in article_info['title']:
                    category_name = '英语'
                elif 'yw' in url_lower or '语文' in article_info['title']:
                    category_name = '语文'
                
                # 如果没有找到对应分类，使用标题中的年级信息
                if category_name not in self.categories:
                    for grade in ['一年级', '二年级', '三年级', '四年级', '五年级', '六年级']:
                        if grade in article_info['title']:
                            category_name = grade
                            break
                
                # 如果还是没找到，使用第一个分类
                if category_name not in self.categories:
                    category_name = list(self.categories.keys())[0] if self.categories else '语文'
                
                self.articles.append({
                    'title': detail['title'] or article_info['title'],
                    'content': detail['content'],
                    'cover_image': detail['cover_image'],
                    'images': detail['images'],
                    'category_name': category_name,
                    'url': article_info['url']
                })
            
            time.sleep(0.5)  # 避免请求过快
        
        print(f"成功抓取 {len(self.articles)} 篇文章")
    
    def escape_sql_string(self, s):
        """转义SQL字符串"""
        if not s:
            return ''
        s = str(s)
        s = s.replace('\\', '\\\\')
        s = s.replace("'", "\\'")
        s = s.replace('\n', '\\n')
        s = s.replace('\r', '\\r')
        return s
    
    def generate_sql(self):
        """生成SQL插入语句"""
        sql_lines = []
        sql_lines.append("-- 从 xiaoxuewang.cn 抓取的初始数据")
        sql_lines.append("")
        sql_lines.append("USE article_db;")
        sql_lines.append("")
        
        # 生成分类插入语句
        sql_lines.append("-- 插入分类数据")
        sql_lines.append("INSERT INTO categories (name, description) VALUES")
        category_values = []
        for cat in self.categories.values():
            name = self.escape_sql_string(cat['name'])
            desc = self.escape_sql_string(cat['description'])
            category_values.append(f"('{name}', '{desc}')")
        
        sql_lines.append(",\n".join(category_values) + ";")
        sql_lines.append("")
        
        # 生成文章插入语句
        if not self.articles:
            sql_lines.append("-- 未找到文章数据")
            return "\n".join(sql_lines)
        
        sql_lines.append("-- 插入文章数据")
        sql_lines.append("INSERT INTO articles (title, content, cover_image, category_id, status, article_type, view_count) VALUES")
        
        article_values = []
        for article in self.articles:
            title = self.escape_sql_string(article['title'])
            content = self.escape_sql_string(article['content'])
            cover_image = self.escape_sql_string(article['cover_image']) if article['cover_image'] else 'NULL'
            category_id = self.categories.get(article['category_name'], {}).get('id', 1)
            
            if cover_image != 'NULL':
                cover_image = f"'{cover_image}'"
            
            article_values.append(
                f"('{title}', '{content}', {cover_image}, {category_id}, 'PUBLISHED', 'NEWS', {hash(article['url']) % 1000})"
            )
        
        sql_lines.append(",\n".join(article_values) + ";")
        sql_lines.append("")
        
        # 生成文章图片插入语句
        sql_lines.append("-- 插入文章图片数据")
        sql_lines.append("INSERT INTO article_images (article_id, image_url) VALUES")
        
        image_values = []
        article_start_id = 1  # 假设从ID 1开始
        
        for idx, article in enumerate(self.articles):
            article_id = article_start_id + idx
            for img_url in article.get('images', [])[:5]:  # 每篇文章最多5张图片
                img_url_escaped = self.escape_sql_string(img_url)
                image_values.append(f"({article_id}, '{img_url_escaped}')")
        
        if image_values:
            sql_lines.append(",\n".join(image_values) + ";")
        
        return "\n".join(sql_lines)


def main():
    scraper = XiaoxuewangScraper()
    scraper.scrape_articles(max_articles=50)  # 抓取50篇文章作为初始数据
    
    sql_content = scraper.generate_sql()
    
    # 保存SQL文件
    output_file = '/workspace/database/init_data_scraped.sql'
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write(sql_content)
    
    print(f"\nSQL文件已生成: {output_file}")
    print(f"共生成 {len(scraper.categories)} 个分类和 {len(scraper.articles)} 篇文章")


if __name__ == '__main__':
    main()
