{ pkgs }: {
    deps = [
        pkgs.bind.dnsutils
        pkgs.qrencode.bin
        pkgs.wget
        pkgs.unzip
    ];
}