#source: dt-relr-3.s
#ld: -shared $DT_RELR_LDFLAGS
#readelf: -rW -d
#target: x86_64-*-linux* i?86-*-linux-gnu i?86-*-gnu*

#failif
#...
Relocation section '\.relr\.dyn' at offset .*
#pass