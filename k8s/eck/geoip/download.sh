#!/bin/sh


for GEOFILE in GeoLite2-City GeoLite2-ASN GeoLite2-Country ; do
      curl --create-dirs -o /opt/registry/images/geoip/geoip-packages/${GEOFILE}.tar.gz https://download.maxmind.com/app/geoip_download\?edition_id\=${GEOFILE}\&license_key\=$1\&suffix\=tar.gz
      tar --strip 1 -xzvf /opt/registry/images/geoip/geoip-packages/${GEOFILE}.tar.gz --directory /opt/registry/images/geoip/geoip-packages/
    done

rm -rf /opt/registry/images/geoip/geoip-packages/*.tar.gz /opt/registry/images/geoip/geoip-packages/README.txt /opt/registry/images/geoip/geoip-packages/LICENSE.txt /opt/registry/images/geoip/geoip-packages/COPYRIGHT.txt
