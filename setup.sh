#!/data/data/com.termux/files/usr/bin/bash

REPO_URL="https://github.com/Gopartner/termux-ssh.git"
INSTALL_DIR="/data/data/com.termux/files/usr/bin"
PROJECT_DIR="$HOME/termux-ssh"
SCRIPT_NAME="termux-ssh-cli.sh"
EXECUTABLE="termux-ssh"

# Fungsi untuk menampilkan pesan dan keluar jika terjadi error
error_exit() {
    echo "Error: $1" >&2
    exit 1
}

# Pastikan git sudah terinstal
if ! command -v git &> /dev/null; then
    echo "Git tidak ditemukan, menginstal sekarang..."
    pkg update && pkg install git -y || error_exit "Gagal menginstal Git."
fi

# Clone atau update repository
if [ ! -d "$PROJECT_DIR/.git" ]; then
    echo "Meng-clone repository Termux-SSH..."
    git clone "$REPO_URL" "$PROJECT_DIR" || error_exit "Gagal meng-clone repository."
else
    echo "Repository sudah ada, menarik update terbaru..."
    cd "$PROJECT_DIR" && git pull origin main || error_exit "Gagal menarik update terbaru."
fi

# Berikan izin eksekusi pada semua skrip
chmod +x "$PROJECT_DIR/scripts"/*.sh

# Jalankan skrip install
bash "$PROJECT_DIR/scripts/install.sh" || error_exit "Gagal menjalankan install.sh."

# Buat alias untuk update otomatis
cat <<EOF > "$INSTALL_DIR/$EXECUTABLE"
#!/data/data/com.termux/files/usr/bin/bash
if [ "\$1" == "--update" ]; then
    bash "$PROJECT_DIR/scripts/update.sh"
else
    bash "$PROJECT_DIR/scripts/$SCRIPT_NAME"
fi
EOF

chmod +x "$INSTALL_DIR/$EXECUTABLE"

echo "Termux-SSH telah diinstal dan siap digunakan! Jalankan dengan 'termux-ssh'"
echo "Untuk memperbarui, jalankan: termux-ssh --update"

