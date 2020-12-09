ARG BUILDER_IMAGE_NAME=envoyproxy/envoy-build-ubuntu:b480535e8423b5fd7c102fd30c92f4785519e33a

FROM ${BUILDER_IMAGE_NAME} as builder

ARG ENVOY_BRANCH=release/v1.16
ARG ENVOY_REPO=https://github.com/envoyproxy/envoy.git

RUN git clone --depth 1 --branch ${ENVOY_BRANCH} ${ENVOY_REPO} /source
WORKDIR /source

RUN mkdir /build

ENV BAZEL_BUILD_OPTIONS='--define boringssl=fips'
RUN ./ci/do_ci.sh bazel.release.server_only


FROM ubuntu

COPY --from=builder /build/envoy/source/exe/envoy /usr/bin/envoy

ENTRYPOINT [ "/usr/bin/envoy", "-c", "/etc/envoy/envoy.yaml" ]
