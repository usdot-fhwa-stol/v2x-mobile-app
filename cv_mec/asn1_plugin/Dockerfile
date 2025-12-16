# Specify the Dart SDK base image version using dart:<version> (ex: dart:2.12)
FROM ubuntu:latest AS build


WORKDIR /build


RUN apt-get update

## Install Dependencies
RUN apt-get install -y libclang-dev wget gpg python3 apt-transport-https curl git unzip xz-utils zip libglu1-mesa



## Install Dart
RUN wget -qO- https://dl-ssl.google.com/linux/linux_signing_key.pub \
    | gpg  --dearmor -o /usr/share/keyrings/dart.gpg

RUN echo 'deb [signed-by=/usr/share/keyrings/dart.gpg arch=amd64] https://storage.googleapis.com/download.dartlang.org/linux/debian stable main' \
    | tee /etc/apt/sources.list.d/dart_stable.list

RUN apt-get update && apt-get install dart


## Install Flutter

RUN wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.24.0-stable.tar.xz
RUN mkdir /build/flutter
RUN tar -xaf /build/flutter_linux_3.24.0-stable.tar.xz -C /build/flutter
ENV PATH="$PATH:/build/flutter/flutter/bin"
RUN git config --global --add safe.directory /build/flutter/flutter
RUN flutter



# Add Sources and Extract them
ADD . /build

# Extract Raw C Sources
RUN tar -xaf /build/asn1/2024.tar.gz -C /build/src
RUN rm /build/src/generated-files/2024/converter-example.c
RUN rm /build/src/generated-files/2024/converter-example.mk

RUN cp /build/asn1/NodeOffsetPointLL.h /build/src/generated-files/2024/NodeOffsetPointLL.h
RUN cp /build/asn1/NodeOffsetPointLL.c /build/src/generated-files/2024/NodeOffsetPointLL.c


RUN cp /build/asn1/overrides/GeneralizedTime_ber.c /build/src/generated-files/2024/GeneralizedTime_ber.c
RUN cp /build/asn1/overrides/GeneralizedTime_print.c /build/src/generated-files/2024/GeneralizedTime_print.c
RUN cp /build/asn1/overrides/GeneralizedTime_xer.c /build/src/generated-files/2024/GeneralizedTime_xer.c
RUN cp /build/asn1/overrides/GeneralizedTime.c /build/src/generated-files/2024/GeneralizedTime.c

RUN rm /build/src/generated-files/2024/Point.h
RUN rm /build/src/generated-files/2024/Point.c

RUN rm /build/src/generated-files/2024/Time.h
RUN rm /build/src/generated-files/2024/Time.c

# Remove Path Referenced Headers
RUN python3 /build/asn1/change_includes.py

# Generate FFI Components
RUN flutter pub get
RUN flutter pub run ffigen


FROM scratch AS ffi
COPY --from=build /build/lib/generated_bindings.dart /generated_bindings.dart
COPY --from=build /build/src/generated-files/2024/ /generated-files/2024/