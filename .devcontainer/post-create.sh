#!/usr/bin/env bash
# Chạy 1 lần sau khi devcontainer được tạo.
set -e

echo "==> Flutter version"
flutter --version

echo "==> Tắt analytics (tránh prompt khi build trong CI/container)"
flutter config --no-analytics || true

echo "==> Bật hỗ trợ web"
flutter config --enable-web || true

echo "==> Tải dependencies"
flutter pub get

echo "==> Hoàn tất. Chạy app bằng:"
echo "    flutter run -d web-server --web-port 8080 --web-hostname 0.0.0.0"
