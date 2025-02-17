#!/data/data/com.termux/files/usr/bin/bash

# Fungsi untuk menampilkan pesan dan keluar jika terjadi error
error_exit() {
    echo "Error: $1" >&2
    exit 1
}

# Cek apakah OpenSSH sudah terinstal
check_ssh() {
    if ! command -v sshd &> /dev/null; then
        echo "OpenSSH belum terinstal. Menginstal sekarang..."
        pkg update && pkg upgrade -y
        pkg install openssh -y || error_exit "Gagal menginstal OpenSSH."
    else
        echo "OpenSSH sudah terinstal."
    fi
}

# Memulai SSH server sebagai root dan di port 22
start_ssh() {
    su -c "sshd -p 22" || error_exit "Gagal menjalankan SSH server."
    echo "SSH server telah dijalankan di port 22 sebagai root."
}

# Menghentikan SSH server
stop_ssh() {
    su -c "pkill sshd" || error_exit "Gagal menghentikan SSH server."
    echo "SSH server telah dihentikan."
}

# Menampilkan informasi SSH
ssh_info() {
    local ip_address=$(ip a | grep 'inet ' | awk '{print $2}' | head -n 1)
    echo "Username: $(whoami)"
    echo "Alamat IP: ${ip_address%/*}"
    echo "Gunakan perintah berikut untuk menghubungkan dari perangkat lain:"
    echo "ssh root@${ip_address%/*}"
}

# Konfigurasi SSH agar berjalan otomatis saat boot dengan akses root
setup_boot() {
    mkdir -p ~/.termux/boot/
    cat <<EOF > ~/.termux/boot/start-sshd
#!/data/data/com.termux/files/usr/bin/sh
su -c 'termux-wake-lock'
su -c 'sshd -p 22'
EOF
    chmod +x ~/.termux/boot/start-sshd || error_exit "Gagal mengatur boot script."
    echo "SSH telah dikonfigurasi untuk berjalan otomatis saat boot dengan akses root."
}

# Membuka port 22 di iptables untuk akses jaringan
open_port() {
    su -c "iptables -A INPUT -p tcp --dport 22 -j ACCEPT" || error_exit "Gagal membuka port 22."
    echo "Port 22 telah dibuka di firewall."
}

# Menu CLI
show_menu() {
    echo "\n=== Termux SSH CLI ==="
    echo "1) Cek dan Instal OpenSSH"
    echo "2) Mulai SSH Server (Root, Port 22)"
    echo "3) Hentikan SSH Server"
    echo "4) Tampilkan Info SSH"
    echo "5) Konfigurasi SSH agar berjalan saat boot (Root)"
    echo "6) Buka Port 22 di iptables"
    echo "7) Keluar"
    read -p "Pilih opsi: " choice
    case $choice in
        1) check_ssh ;;
        2) start_ssh ;;
        3) stop_ssh ;;
        4) ssh_info ;;
        5) setup_boot ;;
        6) open_port ;;
        7) exit 0 ;;
        *) echo "Pilihan tidak valid!" ;;
    esac
}

# Loop menu
while true; do
    show_menu
done

