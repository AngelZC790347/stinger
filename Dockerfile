FROM swift:5.8-jammy

RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true \
    && apt-get update && apt-get install -y \
    && apt-get -q dist-upgrade -y\
    && rm -rf /var/lib/apt/lists/* 
RUN apt-get update && apt-get -y install curl
RUN git config --global --add safe.directory '*'
WORKDIR ./stinger
COPY ./Package.* ./
EXPOSE 3000
RUN swift package resolve
COPY . .
# RUN swift build
CMD [ "swift","run","stinger" ]
