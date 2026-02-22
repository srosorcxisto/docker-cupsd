FROM debian:testing-slim

ARG MAINTAINER_LABEL
ARG SOURCE_URL_LABEL
ARG IMAGE_URL_LABEL
ARG DOCUMENTATION_URL_LABEL

LABEL org.opencontainers.image.authors="${MAINTAINER_LABEL}" \
      org.opencontainers.image.source="${SOURCE_URL_LABEL}" \
      org.opencontainers.image.documentation="${DOCUMENTATION_URL_LABEL}" \
      org.opencontainers.image.url="${IMAGE_URL_LABEL}" \
      org.opencontainers.image.licenses="GPL-3.0-only" \
      org.opencontainers.image.title="CUPS print server image" \
      org.opencontainers.image.description="Docker image including CUPS print server and printing drivers installed from the Debian packages."

# Optional local .deb package(s)
COPY debs/ /tmp/debs/


RUN apt-get update \
 && apt-get install -y --no-install-recommends \
    avahi-utils \
    cups \
    cups-browsed \
    cups-bsd \
    cups-client \
    cups-filters \
    foomatic-db-compressed-ppds \
    foomatic-db-engine \
    hp-ppd \
    openprinting-ppds \
    printer-driver-brlaser \
    printer-driver-c2050 \
    printer-driver-c2esp \
    printer-driver-cjet \
    printer-driver-cups-pdf \
    printer-driver-dymo \
    printer-driver-escpr \
    printer-driver-foo2zjs \
    printer-driver-fujixerox \
    printer-driver-gutenprint \
    printer-driver-indexbraille \
    printer-driver-m2300w \
    printer-driver-min12xxw \
    printer-driver-oki \
    printer-driver-pnm2ppa \
    printer-driver-ptouch \
    printer-driver-pxljr \
    printer-driver-sag-gdi \
    printer-driver-splix \
    smbclient \
    sudo \
    usbutils \
    whois \
 && if ls /tmp/debs/*.deb >/dev/null 2>&1; then apt-get install -y /tmp/debs/*.deb; fi \
 && rm -rf /var/lib/apt/lists/* /tmp/debs

# Expose cups
EXPOSE 631

# Setup users
RUN useradd \
      --create-home \
      --home-dir /home/print \
      --shell /bin/bash \
      --groups sudo,lp,lpadmin \
      --password "$(mkpasswd print)" \
      print \
 && sed -i '/^%sudo[[:space:]]/ s/ALL[[:space:]]*$/NOPASSWD:ALL/' /etc/sudoers

# Copy default CUPS config
COPY --chown=root:lp cupsd.conf /etc/cups/cupsd.conf

CMD ["/usr/sbin/cupsd", "-f"]
