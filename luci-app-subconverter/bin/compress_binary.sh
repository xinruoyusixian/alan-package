rm -f subconverter_aarch64_min subconverter_amd64_min
./upx-4.2.4-amd64_linux subconverter_aarch64 -9 --lzma -o subconverter_aarch64_min
./upx-4.2.4-amd64_linux subconverter_amd64 -9 --lzma -o subconverter_amd64_min
