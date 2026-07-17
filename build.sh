#!/bin/bash
set -e

IMGTOOL_URL="https://github.com/AppImage/appimagetool/releases/download/continuous/appimagetool-x86_64.AppImage"
IMGTOOL="aitool"
TAG="2026.1.0"
SCILAB_TAR="scilab-${TAG}.bin.x86_64-linux-gnu.tar.xz"
SCILAB_URL="https://www.scilab.org/download/${TAG}/${SCILAB_TAR}"
APPDIR="Scilab.AppDir"

if [ ! -f "$SCILAB_TAR" ]; then
  echo "[1/6] Downloading Scilab ${SCILAB_VERSION}..."
  wget "$SCILAB_URL"
else
  echo "[1/6] Scilab tarball already exists. Skipping download."
fi

rm -rf "$APPDIR"
mkdir -p "$APPDIR/usr"
tar -xf "$SCILAB_TAR" -C "$APPDIR/usr" --strip-components=1

cat <<'EOF' >"$APPDIR/AppRun"
#!/bin/sh
HERE="$(dirname "$(readlink -f "${0}")")"

export SCI="${HERE}/usr/share/scilab"
export JAVA_HOME="${HERE}/usr/thirdparty/java"
export PATH="${JAVA_HOME}/bin:${PATH}"

export LD_LIBRARY_PATH="${HERE}/usr/lib/scilab:${HERE}/usr/lib/thirdparty:${HERE}/usr/lib/thirdparty/redist:${LD_LIBRARY_PATH}"

export GTK_THEME=Adwaita:light

# Execute Scilab
exec "${HERE}/usr/bin/scilab" "$@"

EOF
chmod +x "$APPDIR/AppRun"

echo "[4/6] Creating .desktop file..."
cat <<'EOF' >"$APPDIR/scilab.desktop"
[Desktop Entry]
Name=Scilab
Comment=Scientific software package for numerical computations
Exec=scilab
Icon=scilab
Terminal=false
Type=Application
Categories=Science;Math;Education;
EOF

cp "$APPDIR/usr/share/icons/hicolor/256x256/apps/scilab.png" "$APPDIR/scilab.png"

if [ ! -f "appimagetool-x86_64.AppImage" ]; then
  wget -O "$IMGTOOL" "$IMGTOOL_URL"
  chmod +x $IMGTOOL
fi

echo "SCILAB_VERSION=$TAG" >>$GITHUB_ENV
