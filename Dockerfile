FROM rifqi669/rpi-alpine-ruby:latest as builder

RUN apk --update --no-cache --virtual builder add \
        bash \
        build-base \
        ca-certificates \
        clang-dev \
        clang \
        cmake \
        coreutils \
        curl \
        freetype-dev \
        ffmpeg-dev \
        ffmpeg-libs \
        gcc \
        g++ \
        git \
        gettext \
        lcms2-dev \
        libavc1394-dev \
        libc-dev \
        libffi-dev \
        libjpeg-turbo-dev \
        libpng-dev \
        libressl-dev \
        libwebp-dev \
        linux-headers \
        make \
        musl \
        openjpeg-dev \
        openssl \
        tiff-dev \
        unzip \
        zlib-dev \
        wget \
        musl-dev \
        python3 \
        python3-dev \
        py3-numpy \
        openjpeg-tools \
        linux-headers && \
    ln -s /usr/include/locale.h /usr/include/xlocale.h && \
    ln -s /usr/bin/python3 /usr/bin/python && \
    wget https://github.com/opencv/opencv/archive/4.5.2.zip -O /tmp/opencv-4.5.2.zip && \
    unzip /tmp/opencv-4.5.2.zip -d /tmp/ && \
    mkdir /tmp/opencv-4.5.2/release && \
    cd /tmp/opencv-4.5.2/release && \
    cmake \
        -D WITH_FFMPEG=ON \
        -D WITH_TBB=ON \
        -D CMAKE_BUILD_TYPE=Release \
        -D INSTALL_PYTHON_EXAMPLES=OFF \
        -D INSTALL_C_EXAMPLES=OFF \
        -D PYTHON_EXECUTABLE=/usr/bin/python \
        -D CMAKE_C_COMPILER=/usr/bin/clang \
        -D CMAKE_CXX_COMPILER=/usr/bin/clang++ \
        -D CMAKE_INSTALL_PREFIX=/usr/local .. && \
    make -j$(nproc) && \
    make install && \
    gem install ruby-opencv -- --with-opencv-dir=/usr/local || true && \
    gem install ropencv || true && \
    ruby -c "require 'ropencv'" || true && \
    ruby -c "require 'ruby-opencv'" || true

### finalizing image

FROM rifqi669/rpi-alpine-ruby:latest

COPY --from=builder /usr/local /usr/local

RUN ruby -c "require 'ropencv'" || true && \
    ruby -c "require 'ruby-opencv'" || true

CMD [ "irb" ]
