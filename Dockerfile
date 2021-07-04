FROM mcr.microsoft.com/dotnet/runtime:6.0 as lynxbase
RUN apt-get update &&\
    # apt-get install -y libopenblas-base libprotobuf10 zlib1g-dev \
    # ocl-icd-libopencl1 tzdata &&\
    apt-get clean all

FROM lynxbase as botbase
RUN apt-get update &&\
    apt-get install -y python3 &&\
    apt-get clean all

FROM mcr.microsoft.com/dotnet/sdk:6.0 as builder
WORKDIR /lynx
LABEL "version"="lynx_v0.1-alpha"
# COPY ./publish/* /lynx/
COPY ./publish ./
# RUN curl -s -L https://github.com/eduherminio/Lynx/releases/latest |\
#     egrep -o '/LeelaChessZero/lc0/archive/v.*.tar.gz' |\
#     wget --base=https://github.com/ -O lc0latest.tgz -i - &&\
#     tar xfz lc0latest.tgz && rm lc0latest.tgz && mv lc0* /lc0
WORKDIR /lynx
# RUN CC=clang-6.0 CXX=clang++-6.0 INSTALL_PREFIX=/lc0 \
    # ./build.sh release && ls /lc0/bin
# WORKDIR /lc0/bin
# RUN curl -s -L https://github.com/LeelaChessZero/lczero-client/releases/latest |\
#     egrep -o '/LeelaChessZero/lczero-client/releases/download/v.*/lc0-training-client-linux' |\
#     head -n 1 | wget --base=https://github.com/ -i - &&\
RUN chmod +x Lynx.Cli &&\
    mv Lynx.Cli Lynx

FROM lynxbase as lynx
COPY --from=builder /lynx lynx
WORKDIR /lynx
ENV PATH=/lynx:$PATH
CMD Lynx

FROM builder as botBuilder
RUN apt-get update &&\
    apt-get install -y python3-venv
RUN git clone https://github.com/careless25/lichess-bot.git /lcbot
WORKDIR /lcbot
RUN python3 -m venv .venv &&\
    . .venv/bin/activate &&\
    pip3 install wheel &&\
    pip3 install -r requirements.txt

FROM botbase as lcbot
COPY --from=builder /lynx /lynx
COPY --from=botBuilder /lcbot /lcbot
WORKDIR /lcbot
