kdb+/`q` Geolocation Maxmind Library.

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
    6686
    
    q)\t .qmaxmind.loadgeo"csv"	/ only country database present
    7696
    
    q)\t .qmaxmind.loadgeo"csv"	/ city database present
    63737

**N.B.** database loads are *really* slow as kdb+/`q` has no GUID (128-bit) math functions or bitwise operators

## ASN

    q).qmaxmind.asnip "G"$"2a02:10::1"
    addrlast| 2a020010-00ff-ffff-ffff-ffffffffffff
    addr    | 2a020010-0000-0000-0000-000000000000
    mask    | 0x28
    asn     | `.qmaxmind.asn$24785i
    
    / returns null when no location data (ie. rfc1918, bogon, ...)
    q)r:.qmaxmind.asnip("G"$"2a02:10::1";"G"$"188.23.1.6";"G"$"192.0.2.1");r
    addrlast                             addr                                 mas..
    -----------------------------------------------------------------------------..
    2a020010-00ff-ffff-ffff-ffffffffffff 2a020010-0000-0000-0000-000000000000 28 ..
    00000000-0000-0000-0000-ffffbc17ffff 00000000-0000-0000-0000-ffffbc160000 0f ..
    00000000-0000-0000-0000-000000000000 00000000-0000-0000-0000-000000000000 00 ..
    
    q)select from r`asn
    num  | org
    -----| ----------------------------------------------
    38019| "tianjin Mobile Communication Company Limited"
    8447 | "A1 Telekom Austria AG"
         | ""

# Geolocation

    q).qmaxmind.geoip "G"$"2a02:10::1"
    geoname_id                    | `.qmaxmind.geoloc$2750405i
    registered_country_geoname_id | `.qmaxmind.geoloc$2750405i
    represented_country_geoname_id| `.qmaxmind.geoloc$0Ni
    is_anonymous_proxy            | 0b
    is_satellite_provider         | 0b
    postal_code                   | ""
    latitude                      | 52.3824e
    longitude                     | 4.8995e
    accuracy_radius               | 100h
    addrlast                      | 2a020017-ffff-ffff-ffff-ffffffffffff
    addr                          | 2a020010-0000-0000-0000-000000000000
    mask                          | 0x1d

    / returns null when no location data (ie. rfc1918, bogon, ...)
    q)r:.qmaxmind.geoip("G"$"2a02:10::1";"G"$"188.23.1.6";"G"$"192.0.2.1");r
    geoname_id registered_country_geoname_id represented_country_geoname_id is_an..
    -----------------------------------------------------------------------------..
    2750405    2750405                                                      0    ..
    2761369    2782113                                                      0    ..
                                                                            1    ..
    q)select from r`geoname_id
    geoname_id| continent_code country_iso_code subdivision_1_iso_code subdivisio..
    ----------| -----------------------------------------------------------------..
    4887398   | NA             US               IL                               ..
    2778067   | EU             AT               6                                ..
              |                                                                  ..
    
    / name column dictionaries are keyed by locale
    q)first select from r`geoname_id
    continent_code        | `EU
    country_iso_code      | `NL
    subdivision_1_iso_code| `
    subdivision_2_iso_code| `
    metro_code            | 0Nh
    time_zone             | `Europe/Amsterdam
    is_in_european_union  | 1b
    continent_name        | `de`en`es`fr`ja`pt-BR`ru`zh-CN!`Europa`Europe`Europa`..
    country_name          | `de`en`es`fr`ja`pt-BR`ru`zh-CN!`Niederlande`Netherlan..
    subdivision_1_name    | `de`en`es`fr`ja`pt-BR`ru`zh-CN!("";"";"";"";"";"";"";..
    subdivision_2_name    | `de`en`es`fr`ja`pt-BR`ru`zh-CN!("";"";"";"";"";"";"";..
    city_name             | `de`en`es`fr`ja`pt-BR`ru`zh-CN!("";"";"";"";"";"";"";..

## Raw Data

The raw imported data is accessible via the following:

    q)first select from value .qmaxmind.asndb
    q)first select from .qmaxmind.asn
    
    q)first select from value .qmaxmind.geodb
    q)first select from .qmaxmind.geoloc

**N.B.** for the main databases we use [step dictionaries](https://code.kx.com/q/ref/apply/#step-dictionaries) as an accessor
