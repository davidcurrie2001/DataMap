# Note - msodbcsql17 v17.3 required OpenSSL 1.0.2, but the later version of the R Docker images had OpenSSL 1.1 installed
# # so this image is based on rocker/r-ver:3.4 instead.  Once msodbcsql17 v17.4 is release I shoudl be be able to revert back to using the
# trestletech/plumber image directly
FROM rocker/r-ver:3.4
MAINTAINER Marine Institute
RUN apt-get update -qq && apt-get install -y \
  git-core \
  libssl-dev \
  libcurl4-gnutls-dev
RUN apt-get -y install unixodbc unixodbc-dev
RUN apt-get -y install curl
RUN apt-get -y install gnupg2
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
# The following command seemed to cause issues with https so I hardcoded it instead - not ideal...
#RUN curl https://packages.microsoft.com/config/debian/9/prod.list > /etc/apt/sources.list.d/mssql-release.list
RUN echo "deb [arch=amd64] http://packages.microsoft.com/debian/9/prod stretch main" > /etc/apt/sources.list.d/mssql-release.list
RUN apt-get update
RUN ACCEPT_EULA=Y apt-get -y install msodbcsql17
RUN install2.r plumber
RUN R -e "install.packages('RODBC')"
RUN R -e "install.packages('jsonlite')"
RUN mkdir /app
COPY DataMapper.R /app/
COPY script.R /app/
EXPOSE 8000
CMD ["R","-e","source('/app/script.R')"]
# docker build -t mi/datamapper:test .
# docker run -d -p 8000:8000 mi/datamapper:test