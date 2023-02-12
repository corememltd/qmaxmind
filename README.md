kdb+/`q` Maxmind Library.

This project provides a native `q` implementation (ie. non-C binding) that uses the CSV databases from Maxmind.

Both IPv4 and IPv6 is supported by using GUID as the internal address format (supported in kdb+/`q` version 3.6 since release 2017.09.26):

    q)"G"$/:("2001:db8:85a3::8a2e:0370:7334";"192.0.2.125")
    20010db8-85a3-0000-0000-8a2e03707334 00000000-0000-0000-0000-ffffc000027d

## Related Links

 * [Poorman's geoIP lookups for kdb+/q using Maxmind's (CSV) GeoIP database](https://gist.github.com/jimdigriz/2dd4b249d2e3f24d8838f6466674f945)
 * [Developing with kdb+ and the q language](https://code.kx.com/q/)
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
    
    q)\t .qmaxmind.loadgeo"csv"	/ country database
    3817
    
    q)\t .qmaxmind.loadgeo"csv"	/ city database
    28198

## ASN

    q).qmaxmind.asnip "G"$"2201:123::1"
    org     | "Korea Telecom"
    addrlast| 00000000-0000-0000-0000-ffff0216e7ff
    addr    | 00000000-0000-0000-0000-ffff0216e700
    mask    | 0x18
    ipv6    | 0b
    asn     | `.qmaxmind.asn$34164i
    
    q).qmaxmind.asnip("G"$"2201:123::1";"G"$"188.23.1.6")
    org             addrlast                             addr                    ..
    -----------------------------------------------------------------------------..
    "Korea Telecom" 00000000-0000-0000-0000-ffff0216e7ff 00000000-0000-0000-0000-..
    "RCS & RDS"     00000000-0000-0000-0000-ffff053908ff 00000000-0000-0000-0000-..
    
# Geolocation

    q).qmaxmind.geoip "G"$"2201:123::1"
    geoname_id                    | `.qmaxmind.geoloc$6535113i
    registered_country_geoname_id | `.qmaxmind.geoloc$3175395i
    represented_country_geoname_id| `.qmaxmind.geoloc$0Ni
    is_anonymous_proxy            | 0b
    is_satellite_provider         | 0b
    postal_code                   | "22070"
    latitude                      | 45.8089e
    longitude                     | 8.9346e
    accuracy_radius               | 50i
    addrlast                      | 00000000-0000-0000-0000-ffff02248aff
    addr                          | 00000000-0000-0000-0000-ffff02248a00
    mask                          | 0x18
    ipv6                          | 0b
    continent_code                | `AS
    country_iso_code              | `KR
    subdivision_1_iso_code        | `
    subdivision_2_iso_code        | `
    metro_code                    | ""
    time_zone                     | `Asia/Seoul
    is_in_european_union          | 0b
    continent_name                | `de`en`es`fr`ja`pt-BR`ru`zh-CN!`Asien`Asia`As..
    country_name                  | `de`en`es`fr`ja`pt-BR`ru`zh-CN!`Südkorea`Sou..
    ..
    
    q).qmaxmind.geoip("G"$"2201:123::1";"G"$"188.23.1.6")
    geoname_id registered_country_geoname_id represented_country_geoname_id is_an..
    -----------------------------------------------------------------------------..
    6535113    3175395                                                      0    ..
    4440076    6252001                                                      0    ..
