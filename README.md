# دسکتاپ لینوکسی XFCE روی Railway (از طریق مرورگر)

این پروژه یک محیط دسکتاپ گرافیکی سبک لینوکسی (XFCE) می‌سازد که از طریق مرورگر
(با noVNC) قابل دسترسی است — شبیه Remote Desktop ولی کاملاً وب‌بیس.

## نحوه دیپلوی روی Railway

### روش ۱: از طریق داشبورد وب Railway
1. این پوشه (شامل `Dockerfile` و `start.sh`) را در یک ریپوی گیت‌هاب قرار بده.
2. در Railway → New Project → Deploy from GitHub repo → ریپو را انتخاب کن.
3. Railway به‌طور خودکار `Dockerfile` را پیدا و بیلد می‌کند.
4. در تنظیمات سرویس (Variables) یک متغیر محیطی اضافه کن:
   - `VNC_PASSWORD` = یک پسورد قوی دلخواه (حتماً این کار را بکن، وگرنه پسورد رندوم در لاگ چاپ می‌شود)
5. در تنظیمات Networking، یک دامنه عمومی (Public Domain) برای سرویس فعال کن.
6. بعد از دیپلوی، روی همان دامنه در مرورگر باز کن — صفحه noVNC باز می‌شود و با پسوردی که ست کردی وصل می‌شوی.

### روش ۲: از طریق Railway CLI
```bash
npm i -g @railway/cli
railway login
railway init
railway up
railway variables set VNC_PASSWORD=یک_پسورد_قوی
railway domain
```

## نکات مهم امنیتی
- **حتماً VNC_PASSWORD را ست کن** و آن را با کسی به اشتراک نگذار؛ این سرویس روی یک دامنه عمومی در دسترس اینترنت قرار می‌گیرد.
- بعد از تمام شدن کار تست، سرویس را از Railway متوقف یا حذف کن تا هزینه/منابع اضافی مصرف نشود.
- برای امنیت بیشتر، می‌توانی یک لایه Basic Auth یا محدودیت IP جلوی noVNC اضافه کنی.

## نصب ابزارهای اضافی برای تست کد
داخل `Dockerfile`، بعد از خط نصب پکیج‌های پایه، هر زبان یا ابزار مورد نیازت را اضافه کن. مثلاً:

```dockerfile
# برای Node.js
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs

# برای Docker-in-Docker (اگر لازم شد)
RUN apt-get install -y docker.io
```

سپس از داخل ترمینال دسکتاپ (Applications → Terminal) کد را clone و اجرا کن.

## محدودیت‌های شناخته‌شده
- منابع (CPU/RAM) به پلن Railway بستگی دارد؛ اپلیکیشن‌های سنگین گرافیکی (بازی، رندر ۳بعدی) مناسب نیستند.
- تاخیر (Latency) به دلیل ماهیت VNC-over-web بیشتر از RDP بومی است اما برای کار توسعه/تست کاملاً کافی است.
