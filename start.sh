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
cat > ~/.vnc/xstartup << 'EOF'
#!/bin/bash
xrdb $HOME/.Xresources
startxfce4 &
EOF
chmod +x ~/.vnc/xstartup

# --- کشتن سرور قبلی احتمالی و اجرای VNC روی دیسپلی :1 ---
vncserver -kill $DISPLAY > /dev/null 2>&1 || true
vncserver $DISPLAY -geometry ${RESOLUTION%x*} -depth ${RESOLUTION##*x} -localhost no

# --- Railway پورت را در متغیر PORT می‌فرستد؛ اگر نبود از 8080 استفاده کن ---
LISTEN_PORT=${PORT:-8080}

echo "=================================================="
echo "  دسکتاپ آماده است."
echo "  از طریق مرورگر به آدرس Railway وصل شو (پورت $LISTEN_PORT)"
echo "=================================================="

# --- اجرای noVNC که ترافیک وب را به VNC داخلی پل می‌زند ---
/opt/noVNC/utils/novnc_proxy --vnc localhost:5901 --listen $LISTEN_PORT
