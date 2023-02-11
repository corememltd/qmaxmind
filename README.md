kdb+/`q` Maxmind Library.

This project provides a native `q` implementation (ie. non-C binding) that processes the CSV databases from Maxmind.

Both IPv4 and IPv6 is supported using GUID as the internal format which since kdb+/`q` version 3.6 release 2017.09.26 the following is supported

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
    q).qmaxmind.loadasn"csv"
    
    q)meta .qmaxmind.asndb
    c   | t f             a
    ----| -----------------
    last| g               s
    addr| g                
    mask| x                
    ipv6| b                
    asn | i .qmaxmind.asn  
    
    q)first .qmaxmind.asndb
    last| 00000000-0000-0000-0000-ffff010000ff
    addr| 00000000-0000-0000-0000-ffff01000000
    mask| 0x18
    ipv6| 0b
    asn | `.qmaxmind.asn$13335i
    
    q)last .qmaxmind.asndb
    last| 2c0fffd8-ffff-ffff-ffff-ffffffffffff
    addr| 2c0fffd8-0000-0000-0000-000000000000
    mask| 0x20
    ipv6| 1b
    asn | `.qmaxmind.asn$37105i
