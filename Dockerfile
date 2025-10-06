FROM ghcr.io/sdr-enthusiasts/docker-baseimage:mlatclient AS buildimage

SHELL ["/bin/bash", "-x", "-o", "pipefail", "-c"]

# hadolint ignore=DL3008,SC2086,DL4006,SC2039
RUN \
  # readsb: clone repo
  git clone \
  --branch "dev" \
  --depth 1 \
  --single-branch \
  'https://github.com/wiedehopf/readsb.git' \
  '/src/readsb' \
  && \
  # readsb: build & install
  pushd /src/readsb && \
  make \
  RTLSDR=yes \
  WITH_UUIDS=yes \
  AIRCRAFT_HASH_BITS=14 \
  DISABLE_RTLSDR_ZEROCOPY_WORKAROUND=yes \
  -j "$(nproc)" \
  && \
  cp readsb /usr/local/bin/ && \
  /usr/local/bin/readsb --version && \
  popd && \
  true

FROM ghcr.io/sdr-enthusiasts/docker-adsb-ultrafeeder:latest

COPY --from=buildimage /usr/local/bin/readsb /usr/local/bin/readsb
