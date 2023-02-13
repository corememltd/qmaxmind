/ kdb+/q Geolocation Maxmind Library
/ Copyright (C) 2023, coreMem Limited <info@coremem.com>
/ SPDX-License-Identifier: AGPL-3.0-only

\d .qmaxmind

/ x=mask[int/byte] y=ipv6[boolean]
frommask:{(((128-o)div 8)#0x00),$[0=v:o mod 8;();"x"$-1+"i"$2 xexp v],((o:$[y;128;32]-x)div 8)#0xff}

/ cast byte representation of an IPv6 address into a GUID
frombyte:{"G"$"-"sv 0 8 12 16 20 cut raze string x}

/ takes a CIDR in string format and returns a dict describing it
/ 0b sv'(0b vs'0x2a020390900000000000000000000000)|(0b vs'0x0000000003ffffffffffffffffffffff)
fromcidr:{flip`addrlast`addr`mask`ipv6!flip{[x;y](frombyte 0b sv'(0b vs'0x00 vs x)|0b vs'frommask[m;v];x:"G"$x;y:"x"$m:"I"$y;v:count[x]>x?":")}.'"/"vs/:x}

/ user function that attempts to parse anything into a IPv6 GUID
toaddr:{
 c:{"G"$"00000000-0000-0000-0000-ffff",raze string x};
 $[-2=t:type x;x;
  10=t;"G"$first"/"vs x;	/ string (native support since 2017.09.26)
  4=t;c x;			/ list of byte
  7=t;c"x"$x;			/ list of int
  -6=t;c 0x00 vs x;		/ int
  0Ng]}

files:{l where(l:string key hsym`$x)like y}

loadasn:{
 db:raze{[x;f]("*I*";enlist",")0:hsym`$x,"/",f}[x]each files[x;"GeoLite2-ASN-Blocks-IPv[46].csv"];
 asn::`num xkey`num xasc select distinct num:autonomous_system_number, org:autonomous_system_organization from db;
 asndb:`addrlast xasc delete network, autonomous_system_number, autonomous_system_organization from update asn:`.qmaxmind.asn$db`autonomous_system_number from db + .qmaxmind.fromcidr db`network;
 asnip::{`s#(y x)!y}[`addr;asndb]}

loadgeo:{
 t:$[any(string key hsym`$x)like"GeoLite2-City-Blocks-IPv[46].csv";"City";"Country"];
 c:("Country";"City")!(`blk`loc!("*IIIBB";"ISSSSSB");`blk`loc!("*IIIBB*EEH";"ISSSSSS*S***SB"));
 r:{[x;m;f](m;enlist",")0:hsym`$x,"/",f}[x];
 db:raze r[(c t)`blk]each files[x;"GeoLite2-",t,"-Blocks-IPv[46].csv"];
 loc:raze r[(c t)`loc]each files[x;"GeoLite2-",t,"-Locations-*.csv"];
 geoloc::`geoname_id xkey`geoname_id xasc $[t like"City";
  select continent_name:locale_code!continent_name, country_name:locale_code!country_name, subdivision_1_name:locale_code!subdivision_1_name, subdivision_2_name:locale_code!subdivision_2_name, city_name:locale_code!city_name by geoname_id, continent_code, country_iso_code, subdivision_1_iso_code, subdivision_2_iso_code, metro_code, time_zone, is_in_european_union from loc;
  select continent_name:locale_code!continent_name, country_name:locale_code!country_name by geoname_id, continent_code, country_iso_code, is_in_european_union from loc];
 geodb:`addrlast xasc delete network from update geoname_id:`.qmaxmind.geoloc$db`geoname_id, registered_country_geoname_id:`.qmaxmind.geoloc$db`registered_country_geoname_id, represented_country_geoname_id:`.qmaxmind.geoloc$db`represented_country_geoname_id from db + .qmaxmind.fromcidr db`network;
 geoip::{`s#(y x)!y}[`addr;geodb]}

\d .
