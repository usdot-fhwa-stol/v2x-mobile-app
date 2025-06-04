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
# RUN export PATH="/build/flutter/flutter/bin:$PATH"
ENV PATH="$PATH:/build/flutter/flutter/bin"
RUN git config --global --add safe.directory /build/flutter/flutter
RUN flutter



# Add Sources and Extract them
ADD . /build


#ADD ./asn1/2024.tar.gz /build

# Modify Includes on all files
#ADD ./asn1/change_includes.py /build

# Extract Raw C Sources
RUN tar -xaf /build/asn1/2024.tar.gz -C /build/src
RUN rm /build/src/generated-files/2024/converter-example.c
RUN rm /build/src/generated-files/2024/converter-example.mk

# Copy in some override files for a handful of problem classes
#RUN cp /build/asn1/NodeOffsetPointLL.h /build/src/generated-files/2024/NodeOffsetPointLL.h
#RUN cp /build/asn1/NodeOffsetPointLL.c /build/src/generated-files/2024/NodeOffsetPointLL.c

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
# RUN dart pub get
# RUN dart run ffigen
RUN flutter pub run ffigen


FROM scratch AS ffi
COPY --from=build /build/lib/generated_bindings.dart /generated_bindings.dart
COPY --from=build /build/src/generated-files/2024/ /generated-files/2024/

# ENTRYPOINT [ "" ]
#ENTRYPOINT ["tail", "-f", "/dev/null"]

#RUN tar -xaf 2024.tar.gz




# Resolve app dependencies.

# COPY pubspec.* ./
# RUN dart pub get

# # Copy app source code and AOT compile it.
# COPY . .
# # Ensure packages are still up-to-date if anything has changed
# RUN dart pub get --offline
# RUN dart compile exe bin/server.dart -o bin/server

# # Build minimal serving image from AOT-compiled `/server` and required system
# # libraries and configuration files stored in `/runtime/` from the build stage.
# FROM scratch
# COPY --from=build /runtime/ /
# COPY --from=build /app/bin/server /app/bin/

# # Start server.
# EXPOSE 8080
# CMD ["/app/bin/server"]

#ENTRYPOINT ["tail", "-f", "/dev/null"]
