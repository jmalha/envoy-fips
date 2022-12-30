ARG BUILDER_IMAGE_NAME=envoyproxy/envoy-build-ubuntu:5c8e6ab946230d0232d6875344f28457a3c68dd7

FROM ${BUILDER_IMAGE_NAME} as builder

ARG ENVOY_BRANCH=main
ARG ENVOY_REPO=https://github.com/jmalha/envoy-graviton.git

RUN git clone --depth 1 --branch ${ENVOY_BRANCH} ${ENVOY_REPO} /source
WORKDIR /source

RUN mkdir /build

ENV BAZEL_BUILD_OPTIONS='--define boringssl=fips'
RUN ./ci/do_ci.sh bazel.release.server_only


FROM ubuntu

COPY --from=builder /build/envoy/source/exe/envoy /usr/bin/envoy

ENTRYPOINT [ "/usr/bin/envoy", "-c", "/etc/envoy/envoy.yaml" ]
