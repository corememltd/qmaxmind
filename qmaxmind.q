/ kdb+/q Maxmind Library
/ Copyright (C) 2023, coreMem Limited <info@coremem.com>
/ SPDX-License-Identifier: AGPL-3.0-only

\d .qmaxmind

/ x=mask[int/byte] y=ipv6[boolean]
frommask:{(((128-o)div 8)#0x00),$[0=v:o mod 8;();"x"$-1+"i"$2 xexp v],((o:$[y;128;32]-x)div 8)#0xff}

frombyte:{"G"$"-"sv 0 8 12 16 20 cut raze string x}

fromcidr:{
 flip`addrlast`addr`mask`ipv6!flip{[x;y](frombyte(0x00 vs x)|frommask[m;v];x:"G"$x;y:"x"$m:"I"$y;v:count[x]>x?":")}.'"/"vs/:x}

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

files:{l where(l:string key hsym`$x)like y}

loadasn:{
 db:raze{[x;f]("*I*";enlist",")0:hsym`$x,"/",f}[x]each files[x;"GeoLite2-ASN-Blocks-IPv[46].csv"];
 asn::`id xkey `id xasc select distinct id:autonomous_system_number, org:autonomous_system_organization from db;
 asndb::`addrlast xasc delete network, autonomous_system_number, autonomous_system_organization from update asn:`.qmaxmind.asn$db`autonomous_system_number from db + .qmaxmind.fromcidr db`network}

loadgeo:{
 t:$[any(string key hsym`$x)like"GeoLite2-City-Blocks-IPv[46].csv";"City";"Country"];
 c:("Country";"City")!(`blk`loc!("*IIIBB";"ISSSSSB");`blk`loc!("*IIIBB*EEI";"ISSSSSS*S***SB"));
 r:{[x;m;f](m;enlist",")0:hsym`$x,"/",f}[x];
 db:raze r[(c t)`blk]each files[x;"GeoLite2-",t,"-Blocks-IPv[46].csv"];
 loc:raze r[(c t)`loc]each files[x;"GeoLite2-",t,"-Locations-*.csv"];
 geoloc::`geoname_id xkey `geoname_id xasc $[t like"City";
  select continent_name:locale_code!continent_name, country_name:locale_code!country_name, subdivision_1_name:locale_code!subdivision_1_name, subdivision_2_name:locale_code!subdivision_2_name, city_name:locale_code!city_name by geoname_id, continent_code, country_iso_code, subdivision_1_iso_code, subdivision_2_iso_code, metro_code, time_zone, is_in_european_union from loc;
  select continent_name:locale_code!continent_name, country_name:locale_code!country_name by geoname_id, continent_code, country_iso_code, is_in_european_union from loc];
 geodb::`addrlast xasc delete network from update geoname_id:`.qmaxmind.geoloc$db`geoname_id from db + .qmaxmind.fromcidr db`network}

\d .
