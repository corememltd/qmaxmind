/ kdb+/q Maxmind Library
/ Copyright (C) 2023, coreMem Limited <info@coremem.com>
/ SPDX-License-Identifier: AGPL-3.0-only

\d .qmaxmind

/ x=mask[int/byte] y=ipv6[boolean]
frommask:{(((128-o)div 8)#0x00),$[0=v:o mod 8;();"x"$-1+"i"$2 xexp v],((o:$[y;128;32]-x)div 8)#0xff}

frombyte:{"G"$"-"sv 0 8 12 16 20 cut raze string x}

fromcidr:{
 flip`last`addr`mask`ipv6!flip{[x;y](frombyte(0x00 vs x)|frommask[m;v];x:"G"$x;y:"x"$m:"I"$y;v:count[x]>x?":")}.'"/"vs/:x}

toaddr:{
 c:{"G"$"00000000-0000-0000-0000-ffff",raze string x};
 $[-2=t:type x;x;
  10=t;"G"$first"/"vs x;	/ string (native support since 2017.09.26)
  4=t;c x;			/ list of byte
  7=t;c"x"$x;			/ list of int
  -6=t;c 0x00 vs x;		/ int
  0Ng]}

tomask:{
 $[-4h=t:type x;x;
  10=t;"x"$"H"$last"/"vs x;
  0x00]}

loadasn:{
 db:raze{[x;v]("*I*";enlist",")0:hsym`$x,"/GeoLite2-ASN-Blocks-IPv",string[v],".csv"}[x]@/:4 6;
 .qmaxmind.asn::`id xkey `id xasc select distinct id:autonomous_system_number, org:autonomous_system_organization from db;
 .qmaxmind.asndb::`last xasc delete network, autonomous_system_number, autonomous_system_organization from update asn:`.qmaxmind.asn$db`autonomous_system_number from db + .qmaxmind.fromcidr db`network}

\d .
