kdb+/`q` Maxmind Library.

This project provides a native `q` implementation (ie. non-C binding) that uses the CSV databases from Maxmind.

Both IPv4 and IPv6 is supported by using GUID as the internal address format (supported in kdb+/`q` version 3.6 since release 2017.09.26):

    q)"G"$/:("2001:db8:85a3::8a2e:0370:7334";"192.0.2.125")
    20010db8-85a3-0000-0000-8a2e03707334 00000000-0000-0000-0000-ffffc000027d

## Related Links

 * [Poorman's geoIP lookups for kdb+/q using Maxmind's (CSV) GeoIP database](https://gist.github.com/jimdigriz/2dd4b249d2e3f24d8838f6466674f945)
 * [Developing with kdb+ and the q language](https://code.kx.com/q/)
    * [Step dictionaries](https://code.kx.com/q/ref/apply/#step-dictionaries)
 * [Maxmind](https://maxmind.com/)
    * [GeoLite2 Free Geolocation Data](https://dev.maxmind.com/geoip/geolite2-free-geolocation-data)

# Preflight

Fetch a copy of this project:

    git clone https://github.com/corememltd/qmaxmind.git

Now fetch copies of the Maxmind GeoIP2 (CSV) database:

 1. create an account with Maxmind
 1. download at least one CSV database into the directory you created
     * the city database contains the information found in the country database
     * if you download and extract both the country and city, the country database will be ignored by this library
     * it is recommended you pick the country database if that is all you need as it is faster and will use significantly less RAM
 1. extract each CSV database using:

        unzip -d csv -j GeoLite2-TYPE-CSV_YYYYMMDD.zip *.csv

This should leave you with a `csv` directory that looks something like:

    bob@host:~$ tree csv
    csv
    |-- GeoLite2-ASN-Blocks-IPv4.csv
    |-- GeoLite2-ASN-Blocks-IPv6.csv
    |-- GeoLite2-City-Blocks-IPv4.csv
    |-- GeoLite2-City-Blocks-IPv6.csv
    |-- GeoLite2-City-Locations-de.csv
    |-- GeoLite2-City-Locations-en.csv
    |-- GeoLite2-City-Locations-es.csv
    |-- GeoLite2-City-Locations-fr.csv
    |-- GeoLite2-City-Locations-ja.csv
    |-- GeoLite2-City-Locations-pt-BR.csv
    |-- GeoLite2-City-Locations-ru.csv
    `-- GeoLite2-City-Locations-zh-CN.csv

# Usage

    q)\l qmaxmind.q
    
    q)\t .qmaxmind.loadasn"csv"
    2962
    
    q)\t .qmaxmind.loadgeo"csv"	/ only country database present
    3817
    
    q)\t .qmaxmind.loadgeo"csv"	/ city database present
    28198

## ASN

    q).qmaxmind.asnip "G"$"2201:123::1"
    addr| 20498e02-f000-0000-0000-000000000000
    mask| 0x24
    ipv6| 1b
    asn | `.qmaxmind.asn$38019i
    
    q)r:.qmaxmind.asnip("G"$"2201:123::1";"G"$"188.23.1.6");r
    addr                                 mask ipv6 asn
    ----------------------------------------------------
    20498e02-f000-0000-0000-000000000000 24   1    38019
    00000000-0000-0000-0000-ffffbc160000 0f   0    8447
    
    q)select from r`asn
    num  | org
    -----| ----------------------------------------------
    38019| "tianjin Mobile Communication Company Limited"
    8447 | "A1 Telekom Austria AG"

# Geolocation

    q).qmaxmind.geoip "G"$"2201:123::1"
    geoname_id                    | `.qmaxmind.geoloc$4887398i
    registered_country_geoname_id | `.qmaxmind.geoloc$0Ni
    represented_country_geoname_id| `.qmaxmind.geoloc$0Ni
    is_anonymous_proxy            | 0b
    is_satellite_provider         | 0b
    postal_code                   | "60602"
    latitude                      | 41.8874e
    longitude                     | -87.6318e
    accuracy_radius               | 100i
    addr                          | 21600150-0000-0000-0000-000000000000
    mask                          | 0x21
    ipv6                          | 1b
    
    q)r:.qmaxmind.geoip("G"$"2201:123::1";"G"$"188.23.1.6");r
    geoname_id registered_country_geoname_id represented_country_geoname_id is_an..
    -----------------------------------------------------------------------------..
    4887398                                                                 0    ..
    2778067    2782113                                                      0    ..
    
    q)select from r`geoname_id
    geoname_id| continent_code country_iso_code subdivision_1_iso_code subdivisio..
    ----------| -----------------------------------------------------------------..
    4887398   | NA             US               IL                               ..
    2778067   | EU             AT               6                                ..
    
    / name column dictionaries are keyed by locale
    q)first select from r`geoname_id
    continent_code        | `NA
    country_iso_code      | `US
    subdivision_1_iso_code| `IL
    subdivision_2_iso_code| `
    metro_code            | "602"
    time_zone             | `America/Chicago
    is_in_european_union  | 0b
    continent_name        | `de`en`es`fr`ja`pt-BR`ru`zh-CN!`Nordamerika`North Ame..
    country_name          | `de`en`es`fr`ja`pt-BR`ru`zh-CN!`Vereinigte Staaten`Un..
    subdivision_1_name    | `de`en`es`fr`ja`pt-BR`ru`zh-CN!("";"Illinois";"Illino..
    subdivision_2_name    | `de`en`es`fr`ja`pt-BR`ru`zh-CN!("";"";"";"";"";"";"";..
    city_name             | `de`en`es`fr`ja`pt-BR`ru`zh-CN!("Chicago";"Chicago";"..
