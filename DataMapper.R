# DataMapper.R

#' Get biological data using the ConfigObject supplied
#' @param  ConfigObject The JSON configuration object that defines how to connect to the database
#' @param  NumberOfRows The number of rows to return, the default value is to return all rows
#' @param  SurveyYear The survey year of the data to return , the default value is to return all years
#' @param  SurveyName The name of the survey to return, the default value is to return all surveys
#' @param  Species The three letter code of the species data to return, the default value is to return all species
#' @get /GetBioData
GetBioData <- function(ConfigObject, NumberOfRows=NA, SurveyYear=NA, SurveyName=NA, Species=NA){

  # Ensure we have the right packages available - can't run the function otherwise
  if (!require(RODBC)){
    install.packages("RODBC")
    if (!require(RODBC)){
      return("Error- could not install RODBC")
    }
  }
  
  if (!require(jsonlite)){
    install.packages("jsonlite")
    if (!require(jsonlite)){
      return("Error- could not install jsonlite")
    }
  }

  # TODO- this function is very vulnerable to SQL injection attacks 
  # - this will need to be fixed in the proper version
  
  
  
  # Convert the JSON config object into an R object
  ConfigObject_R <-fromJSON(ConfigObject)
  
  # Get the connection string and table name from the configuration object
  myConnectionString <- ConfigObject_R[1]
  myTable <- ConfigObject_R[2]
  
  # Get the data frame with the field mappings
  myFields <- ConfigObject_R[3]$fields
  
  # Now we'll build the query string from the field list and the tabel name
  myQueryString <- "SELECT"
  
  # See if we need to limit the number of rows returned
  NumberOfRowsAsNumber <- as.numeric(NumberOfRows)
  if (!is.na(NumberOfRowsAsNumber) &&  is.numeric(NumberOfRowsAsNumber) && NumberOfRowsAsNumber > 0){
    myQueryString <- paste(myQueryString,"TOP",NumberOfRowsAsNumber)
  }
  
  myFieldString <- ""
  
  # Loop through the field list to constract the SQL statement
  for (i in 1:nrow(myFields)){
  
    myFieldString <- paste(myFields[i,"source"],"as",myFields[i,"destination"])
    myQueryString <- paste(myQueryString,myFieldString)
    
    #if we're not on the last pair of fields we want to add a comma to the query string
    if (i < nrow(myFields)){
      myQueryString <- paste(myQueryString,",")
    }
  }
  
  # add the table to the SQL query string
  myQueryString <- paste(myQueryString,"from",myTable)
  
  myWhereString <- "WHERE"
  
  # Add in the WHERE conditions
  
  # If SurveyYear has been supplied try and add it to the WHERE clause
  if (!is.na(SurveyYear)){
    SurveyYearAsNumber <- as.numeric(SurveyYear)
    if (!is.na(SurveyYearAsNumber) && SurveyYearAsNumber >= 1900 && SurveyYearAsNumber <= 2100){
      # Does this handle duplicate "destination" fields correctly? Does it need to?
      fieldToCheck <- myFields[myFields$destination == "SurveyYear","source"]
      if (!is.na(fieldToCheck) && !is.null(nchar(fieldToCheck))){
        
        # See if we need to add AND
        if (nchar(myWhereString) >5){
          myWhereString <- paste(myWhereString,"and")
        }
        
        myWhereString <- paste(myWhereString,fieldToCheck,"=",SurveyYearAsNumber)
      }
    }
  }
  
  # If SurveyName has been supplied try and add it to the WHERE clause
  if (!is.na(SurveyName)){
    if (!is.na(SurveyName) && nchar(SurveyName) >= 0){
      # Does this handle duplicate "destination" fields correctly? Does it need to?
      fieldToCheck <- myFields[myFields$destination == "SurveyName","source"]
      if (!is.na(fieldToCheck) && !is.null(nchar(fieldToCheck))){
        
        # See if we need to add AND
        if (nchar(myWhereString) >5){
          myWhereString <- paste(myWhereString,"and")
        }
        
        # Need to be careful about the sep value when comparing text
        myWhereString <- paste(myWhereString," ", fieldToCheck," = '",SurveyName,"'", sep="")
      }
    }
  }
  
  # If Species has been supplied try and add it to the WHERE clause
  if (!is.na(Species)){
    if (!is.na(Species) && nchar(Species) >= 0){
      # Does this handle duplicate "destination" fields correctly? Does it need to?
      fieldToCheck <- myFields[myFields$destination == "Species","source"]
      if (!is.na(fieldToCheck) && !is.null(nchar(fieldToCheck))){
        
        # See if we need to add AND
        if (nchar(myWhereString) >5){
          myWhereString <- paste(myWhereString,"and")
        }
        
        # Need to be careful about the sep value when comparing text
        myWhereString <- paste(myWhereString," ", fieldToCheck," = '",Species,"'", sep="")
      }
    }
  }
  
  # If we have a valid WHERE string that is longer than 5 characters - add it to the the query string
  if (!is.na(myWhereString) && nchar(myWhereString) >5){
    myQueryString <- paste(myQueryString,myWhereString)
  }
  
  
  # Now try to read the data from the database
  channel <- odbcDriverConnect(myConnectionString)
  myData <- sqlQuery(channel,myQueryString)
  close(channel)
  

  myData

}



