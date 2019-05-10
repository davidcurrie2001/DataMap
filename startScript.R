pr<-plumber::plumb('/app/DataMapper.R') 
pr$run(host='0.0.0.0', port=8000)
