# GCC CrossCompiler
Simple bash script to compiling GCC for windows in Debian basse

# Component details
- ZSTD 1.5.5
- GMP 6.3.0
- MPFR 4.2.1
- MPC 1.3.1
- ISL 0.26
- EXPAT 2.5.0
- BINUTILS 2.41
- GCC 13.2.0
- MINGW64 11.0.1
- GDB 14.1
- MAKE 4.4

# Requirements
- Ubuntu 20+
- Debian 11+
- Sudoer privileges / root access
- Wget installed in system
- Min 2 GB Ram [ Rec: 8 GB ]
- Min 2 Core [ Rec: 8 Core ]

# Test History
- Build Machine [ Debian 12 ]
- Result testing [ Windows 10 22H2 & Windows 11 23H2 ]
- C++ Code Debug
- C++ Code Building
- C Code Debug
- C Code Building

# Usage
```bash
cd /root
wget -O build https://raw.githubusercontent.com/wildyrando/GCC-CrossCompiler/main/build.sh
bash build "NUMBER OF CORE TO USE FOR COMPILE" "Your Name"
```

# Usage Examples
```bash
bash build 12 "Wildy Sheverando"
```
That's command will build gcc using 12 of cpu cores and Wildy Sheverando as gcc VERSION

# License
This script is not licensed, u can do anything in this script.
