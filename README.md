# GCC CrossCompiler
Simple bash script to compiling GCC for windows in Debian basse

# Requirements
- Ubuntu 20+
- Debian 11+
- Sudoer privileges / root access
- Wget installed in system
- Min 2 GB Ram [ Rec: 8 GB ]
- Min 2 Core [ Rec: 8 Core ]

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
