# Luci-App-Subconverter

## Based On

This project is based on the following open-source projects:

* [Subweb](https://github.com/stilleshan/subweb)
* [Subconverter (v1.3 and below)](https://github.com/tindy2013/subconverter)
* [asdlokj1qpi233/subconverter (v1.4+ to support vless)](https://github.com/asdlokj1qpi233/subconverter)
## Overview

a control panel for subweb and subconverter

# Screenshot

![subconverter](./img/subconverter.png)
![prefini](./img/prefini.png)
![subweb](./img/subweb.png)
## Features

* Supports amd64 and arm64 devices
* Tested on official OpenWRT 23.05.5/24.10.4 and LEDE R23.4.1/R20.4.8

## System Requirements

* Disk space: 3MB
* Memory: 256MB

## Security Notice

**WARNING:** SUBCONVERTER AND SUBWEB HAVE NO PASSWORD PROTECTION. FOR SECURITY REASONS, DO NOT EXPOSE THEM TO THE PUBLIC INTERNET.
<br>

### To generate the `subconverter` binary from trusted sources, follow the steps below:

[UPX 4.2.4](https://github.com/upx/upx/releases/tag/v4.2.4)
<br>
[asdlokj1qpi233/subconverter](https://github.com/asdlokj1qpi233/subconverter/actions/runs/17318035053)
```bash
./upx -9 --lzma ./subconverter
```
<br>
