FROM mcr.microsoft.com/dotnet/runtime-deps:6.0 as lynxbase

FROM lynxbase as botbase
RUN apt-get update &&\
    apt-get install -y python3 &&\
    apt-get clean all

FROM mcr.microsoft.com/dotnet/sdk:6.0 as lynxbuilder
LABEL "version"="lynx_v0.1-alpha"
# COPY ./publish/* /lynx/
COPY ./publish ./lynx
# RUN curl -s -L https://github.com/eduherminio/Lynx/releases/latest |\
#     egrep -o '/LeelaChessZero/lc0/archive/v.*.tar.gz' |\
#     wget --base=https://github.com/ -O lc0latest.tgz -i - &&\
#     tar xfz lc0latest.tgz && rm lc0latest.tgz && mv lc0* /lc0
WORKDIR /lynx
RUN chmod +x Lynx.Cli &&\
    mv Lynx.Cli Lynx

# FROM lynxbase as lynx
# COPY --from=lynxbuilder /lynx lynx
# WORKDIR /lynx
# ENV PATH=/lynx:$PATH
# CMD Lynx

FROM lynxbuilder as botBuilder
RUN apt-get update &&\
    apt-get install -y python3-venv
RUN git clone https://github.com/careless25/lichess-bot.git /lcbot
WORKDIR /lcbot
RUN python3 -m venv .venv &&\
    . .venv/bin/activate &&\
    pip3 install wheel &&\
    pip3 install -r requirements.txt

FROM botbase as lcbot
COPY --from=lynxbuilder /lynx /lynx
COPY --from=botBuilder /lcbot /lcbot
WORKDIR /lcbot
