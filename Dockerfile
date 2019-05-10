FROM rocker/r-ver:3.4
MAINTAINER Marine Institute
RUN apt-get update -qq && apt-get install -y \
  git-core \
  libssl-dev \
  libcurl4-gnutls-dev
#FROM trestletech/plumber
#MAINTAINER Marine Institute
RUN apt-get -y install unixodbc unixodbc-dev
RUN apt-get -y install curl
RUN apt-get -y install gnupg2
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
#RUN curl https://packages.microsoft.com/config/debian/9/prod.list > /etc/apt/sources.list.d/mssql-release.list
RUN echo "deb [arch=amd64] http://packages.microsoft.com/debian/9/prod stretch main" > /etc/apt/sources.list.d/mssql-release.list
RUN apt-get update
RUN ACCEPT_EULA=Y apt-get -y install msodbcsql17
RUN install2.r plumber
#RUN R -e 'install.packages("plumber")'
RUN R -e "install.packages('RODBC')"
RUN R -e "install.packages('jsonlite')"
#RUN echo "deb http://snapshot.debian.org/archive/debian/20150827 sid main" | tee -a /etc/apt/sources.list
#RUN apt-get -o Acquire::Check-Valid-Until=false  update
#RUN apt-get -y  --allow-downgrades install openssl=1.0.2d-1
#RUN ln -s /usr/lib/x86_64-linux-gnu/libssl.so.1.1 /usr/lib/x86_64-linux-gnu/libssl.so.1.0.2
#RUN ln -s /usr/lib/x86_64-linux-gnu/libcrypto.so.1.1 /usr/lib/x86_64-linux-gnu/libcrypto.so.1.0.2
RUN mkdir /app
COPY DataMapper.R /app/
COPY script.R /app/
#COPY openssl-1.0.2r.tar.gz /app/
EXPOSE 8000
#ENTRYPOINT ["R", "-e", "pr <- plumber::plumb(commandArgs()[4]); pr$run(host='0.0.0.0', port=8000)"]
#CMD ["/app/DataMapper.R"]
CMD ["R","-e","source('/app/script.R')"]
# docker build -t mi/datamapper:test .
# docker run -d -p 8000:8000 mi/datamapper:test