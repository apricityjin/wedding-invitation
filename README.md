# 婚礼邀请函 H5

浪漫优雅的婚礼邀请函单页应用，移动端优先、响应式适配。单文件（`index.html`）实现，零构建，可直接部署到任意静态托管。

## 功能

- **封面首屏**：花瓣飘落动画、新人姓名、婚期/农历/地点、敬邀署名、背景音乐（内置合成钢琴旋律，可换真实音频）
- **爱情倒计时**：天/时/分/秒实时跳动，翻转动效，婚礼过后自动切换兜底文案
- **我们的故事**：左右交错时间线，滚动渐入
- **婚纱相册**：分组管理、精选照片横向滚动、人气榜（访客点赞）、Lightbox 浏览（缩略图/中图/原图三级加载）
- **婚礼信息**：当日流程时间轴 + 地点导航（高德/百度/系统地图）+ 交通指引浮层
- **出席回执**：表单校验（姓名/人数/手机号），仅主人可查看
- **祝福墙**：访客留言实时上墙
- **主人态**：邮箱密码登录后可编辑全站文案、上传/删除照片、管理分组、查看回执
- **分享优化**：Open Graph 卡片 + 微信分享引导浮层
- 右侧悬浮圆点导航（自动高亮）、全板块渐入动画、平滑滚动

## 快速开始（纯本地模式，无需后端）

直接双击打开 `index.html`，或：

```bash
python3 -m http.server 8000
# 访问 http://localhost:8000
```

本地模式下照片/祝福等数据保存在访客浏览器 localStorage，适合体验。要多人共享数据请接入 Supabase（下一步）。

## 接入 Supabase（云端模式）

1. 在 [Supabase](https://supabase.com) 创建项目
2. Dashboard → SQL Editor → 粘贴执行 [`supabase-setup.sql`](supabase-setup.sql)（建表 + RLS 权限策略 + 存储桶）
3. Authentication → Users → Add User，创建主人账号（邮箱 + 密码）
4. 打开 `index.html`，找到 `CONFIG`，填入：
   ```js
   supabaseUrl: 'https://你的项目.supabase.co',
   supabaseAnonKey: 'sb_publishable_...',   // publishable key，配合 RLS 可安全公开
   ```

云端模式下：访客可写祝福/点赞/回执，**只有主人账号**能上传照片、修改配置、删除内容（由 RLS 在服务端强制）。

## 修改为你的婚礼信息

大多数文案**不用改代码**：登录主人态后点左下角「编辑信息」，可修改姓名、日期（公历/农历）、地址、爱情故事、当日流程、交通指引，保存后所有访客可见。

需要改代码的（`index.html` 顶部 `CONFIG`）：

| 字段 | 说明 |
|---|---|
| `weddingTime` | 倒计时目标时间 |
| `amapShare` | 高德分享链接（高德地图 App 内分享地点获得，定位最准） |
| `gcj` / `bd` | 地点坐标，GCJ-02（高德/苹果）与 BD-09（百度）两种坐标系 |
| `musicUrl` | 真实音乐文件 URL，留空用内置合成旋律 |
| `<head>` 里的 og 标签 | 把 `https://your-domain.com/` 换成你的域名，替换 `og-cover.png` 分享封面 |

## 照片性能约定（可选）

云端相册按文件名约定加载派生尺寸：原图存 `gallery/原图名` 时，若同时存在 `thumbs/原图名`（约 800px）与 `medium/原图名`（约 2048px），网格和灯箱会自动使用加速加载，不存在则回退原图。不上传派生图也能正常工作。

## 部署

任意静态托管均可（单文件 + 一张封面图）：

```bash
# Vercel
vercel deploy --prod
```

Gitee Pages / GitHub Pages / Netlify / OSS 同理，上传 `index.html` 与 `og-cover.png` 即可。

## 技术栈

- 原生 HTML/CSS/JS，单文件，无构建
- [Supabase](https://supabase.com)（Postgres + Auth + Storage，可选）
- Google Fonts（Noto Serif SC / Ma Shan Zheng / Cormorant Garamond）

## License

[MIT](LICENSE)
