/ kdb+/q Geolocation Maxmind Library
/ Copyright (C) 2023, coreMem Limited <info@coremem.com>
/ SPDX-License-Identifier: AGPL-3.0-only

\d .qmaxmind

/ x=mask[int/byte] y=ipv6[boolean]
frommask:{(((128-o)div 8)#0x00),$[0=v:o mod 8;();"x"$-1+"i"$2 xexp v],((o:$[y;128;32]-x)div 8)#0xff}

/ cast byte representation of an IPv6 address into a GUID
frombyte:{"G"$"-"sv 0 8 12 16 20 cut raze string x}

/ takes a CIDR in string format and returns a dict describing it
fromcidr:{
 flip`addrlast`addr`mask!flip{[x;y]
  / 0b sv'(0b vs'0x20010db8000000000000000000000000)|(0b vs'0x0000000003ffffffffffffffffffffff)
  bor:('[0b sv'(or'/)0b vs'';(;)]);
  (frombyte bor[0x00 vs a;frommask[m;count[x]>x?":"]];a:"G"$x;"x"$m:"I"$y)}.'"/"vs/:x}

files:{l where(l:string key hsym`$x)like y}

nullip:{key[x]!{[v]$[-2=type v;0Ng;-20=type v;key[v]$(neg type value v)$0N;(neg type v)$0N]}each value x}

loadasn:{
 db:raze{[x;f]("*I*";enlist",")0:hsym`$x,"/",f}[x]each files[x;"GeoLite2-ASN-Blocks-IPv[46].csv"];
 asn::`num xkey`num xasc select distinct num:autonomous_system_number, org:autonomous_system_organization from db;
 asndb::`addrlast xasc delete network, autonomous_system_number, autonomous_system_organization from update asn:`.qmaxmind.asn$db`autonomous_system_number from db + .qmaxmind.fromcidr db`network;
 asndb::{`s#(y x)!y}[`addr;asndb]}

asnip:{{[i]$[i>(v:asndb i)`addrlast;nullip v;v]}each x}

loadgeo:{
 t:$[any(string key hsym`$x)like"GeoLite2-City-Blocks-IPv[46].csv";"City";"Country"];
 / https://dev.maxmind.com/geoip/docs/databases/city-and-country?lang=en#csv-databases
 / metro_code is Nielsen DMA codes which ranges from 500 to 881
 c:("Country";"City")!(`blk`loc!("*IIIBB";"ISSSSSB");`blk`loc!("*IIIBB*EEH";"ISSSSSS*S**HSB"));
 r:{[x;m;f](m;enlist",")0:hsym`$x,"/",f}[x];
 db:raze r[(c t)`blk]each files[x;"GeoLite2-",t,"-Blocks-IPv[46].csv"];
 loc:raze r[(c t)`loc]each files[x;"GeoLite2-",t,"-Locations-*.csv"];
 geoloc::`geoname_id xkey`geoname_id xasc $[t like"City";
  select continent_name:locale_code!continent_name, country_name:locale_code!country_name, subdivision_1_name:locale_code!subdivision_1_name, subdivision_2_name:locale_code!subdivision_2_name, city_name:locale_code!city_name by geoname_id, continent_code, country_iso_code, subdivision_1_iso_code, subdivision_2_iso_code, metro_code, time_zone, is_in_european_union from loc;
  select continent_name:locale_code!continent_name, country_name:locale_code!country_name by geoname_id, continent_code, country_iso_code, is_in_european_union from loc];
 geodb::`addrlast xasc delete network from update geoname_id:`.qmaxmind.geoloc$db`geoname_id, registered_country_geoname_id:`.qmaxmind.geoloc$db`registered_country_geoname_id, represented_country_geoname_id:`.qmaxmind.geoloc$db`represented_country_geoname_id from db + .qmaxmind.fromcidr db`network;
 geodb::{`s#(y x)!y}[`addr;geodb]}

geoip:{{[i]$[i>(v:geodb i)`addrlast;nullip v;v]}each x}

\d .
