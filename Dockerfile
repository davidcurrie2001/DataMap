FROM trestletech/plumber
MAINTAINER Marine Institute
RUN apt-get -y install unixodbc unixodbc-dev
RUN apt-get -y install curl
RUN apt-get -y install gnupg2
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
RUN curl https://packages.microsoft.com/config/debian/9/prod.list > /etc/apt/sources.list.d/mssql-release.list
RUN apt-get update
RUN ACCEPT_EULA=Y apt-get -y install msodbcsql17
RUN R -e "install.packages('RODBC')"
RUN R -e "install.packages('jsonlite')"
COPY DataMapper.R /app/
CMD ["/app/DataMapper.R"]
# docker build -t mi/datamapper:test .
# docker run -d -p 8000:8000 mi/datamapper:test