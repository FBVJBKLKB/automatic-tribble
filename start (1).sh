#!/bin/bash
set -e

# --- تنظیم پسورد VNC از متغیر محیطی (حتما در Railway ست کن) ---
# اگر VNC_PASSWORD ست نشده باشد، یک پسورد رندوم تولید و در لاگ چاپ می‌شود
if [ -z "$VNC_PASSWORD" ]; then
  export VNC_PASSWORD=$(tr -dc 'A-Za-z0-9' </dev/urandom | head -c 16)
  echo "=================================================="
  echo "  VNC_PASSWORD ست نشده بود، یک پسورد رندوم ساخته شد:"
  echo "  $VNC_PASSWORD"
  echo "  این پسورد را در Railway به عنوان متغیر محیطی VNC_PASSWORD ذخیره کن"
  echo "=================================================="
fi

mkdir -p ~/.vnc
echo "$VNC_PASSWORD" | vncpasswd -f > ~/.vnc/passwd
chmod 600 ~/.vnc/passwd

# --- فایل استارتاپ دسکتاپ XFCE ---
# نکته: startxfce4 باید در foreground (با exec) اجرا شود، وگرنه vncserver
# اسکریپت را «زود تمام شده» تلقی می‌کند و پیوسته آن را ری‌استارت می‌کند
cat > ~/.vnc/xstartup << 'EOF'
#!/bin/bash
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
exec startxfce4
EOF
chmod +x ~/.vnc/xstartup

# --- کشتن سرور قبلی احتمالی و اجرای VNC روی دیسپلی :1 ---
vncserver -kill $DISPLAY > /dev/null 2>&1 || true
vncserver $DISPLAY -geometry ${RESOLUTION%x*} -depth ${RESOLUTION##*x} -localhost no

# --- کمی صبر تا مطمئن شویم Xvnc کاملاً بالا آمده ---
sleep 3

# بررسی اینکه سرور VNC واقعاً روی 5901 گوش می‌دهد
if ! ss -ltn | grep -q ':5901'; then
  echo "!! خطا: VNC server روی پورت 5901 بالا نیامد. لاگ زیر را ببین:"
  cat ~/.vnc/*.log 2>/dev/null || true
  exit 1
fi

# --- Railway پورت را در متغیر PORT می‌فرستد؛ اگر نبود از 8080 استفاده کن ---
LISTEN_PORT=${PORT:-8080}

echo "=================================================="
echo "  دسکتاپ آماده است."
echo "  از طریق مرورگر به آدرس Railway وصل شو (پورت $LISTEN_PORT)"
echo "=================================================="

# --- اجرای noVNC که ترافیک وب را به VNC داخلی پل می‌زند؛ صریحاً روی همه اینترفیس‌ها ---
exec /opt/noVNC/utils/novnc_proxy --vnc localhost:5901 --listen 0.0.0.0:${LISTEN_PORT}
