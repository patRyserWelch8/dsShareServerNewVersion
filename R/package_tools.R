#'@name create.vector
#'@title  convert character string holding semi-columns separated values into a character vector
#'@description This function converts n variables names into a character vector of n character values
#'@return a character vector
#'@param var_names - a character vector of one element with ";" separated variable names
create.vector <- function (var_names = "")
{
  outcome <- c()
  if(is.character(var_names))
  {
    names.list <- strsplit(var_names,";")
    outcome <- unlist(names.list)
  }
  return(outcome)
}

#'@name generate.secure.seeds
#'@title  uses the footprint set in the Opal server to generate a seed
#'@description This function converts n variables names into a character vector of n character values
#'@return  a seed
#'@param settings - the settings list.
generate.secure.seed <- function(settings = list())
{
    if (is.list(settings))
    {
      # initialise the seed
      if("footprint" %in% names(settings))
      {
        if(is.numeric(settings$footprint))
        {
          footprint  <- settings$footprint
        }
      }
      else
      {
        footprint <- as.integer(runif(1, min = 1, max = .Machine$integer.max/10000))
      }

      repeat
      {
        RNGkind("L'Ecuyer-CMRG")
        index <- round(length(.Random.seed)/2)
        random.seed <- abs(.Random.seed[index])
        seed <- as.integer(abs(random.seed / footprint))

        if(footprint < .Machine$integer.max)
        {
          break()
        }
      }
      return(seed)
    }
    else
    {
      stop("SERVER::ERR:SHARE::024")
    }
}

#'@name compute.random.number
#'@title generate a random number
#'@param seed a integer value to set the seed
#'@param min.value the minimum value used in the range
#'@param max.value the maximum value used in the range
#'@return a number randomly generated
compute.random.number <- function(seed = NULL, min.value = NULL, max.value = NULL )
{
  if(is.numeric(seed) & is.numeric(min.value) & is.numeric(max.value))
  {
    set.seed(seed)
    list.number  <- runif(10000, min = 1000, max = .Machine$integer.max)
    random.index <- runif(1, min = 1, max = 10000)
    return(list.number[random.index])
  }
  else
  {
    stop("SERVER::ERR:SHARE::023")
  }

}

#'@name is.sharing.allowed
#'@title  verifies the variables used to set the parametrisation to for sharing parameters
#'exists on a DataSHIELD server.
#'@description This server function checks some settings used exchange parameters between
#'DataSHIELD server exists. It also verifies the data owners and governance have allowed the
#'sharing of parameters in a specific server.
#'@details This is a helper function. It cannot be called directly from any client-side
#'function.
#'
is.sharing.allowed <- function()
{
  settings <- get.settings()
  allowed  <- as.logical(settings$sharing.allowed)

  if(!allowed)
  {
    stop("SERVER::ERR::SHARING::001")
  }
  else
  {
    return(allowed)
  }

}

#'@name encode.data.with.sharing
#'@title  encode some obscured  data to be exchanged from one server to another.
#'@description This server function can only be used with some encrypted data. It
#'format the data prior its transfer to a client-side function.
#'@param encrypted.data - data to be encoded
#'@param length - an indication how long should be the data
#'@param index - A random number related to the data
#'@details This is a helper function. It cannot be called directly from any client-side
#'function.
#'
#ADD THIS IN DOC
#@seealso \link[dsShareServer]{getDataDS}, \link[dsShareServer]{getCoordinatesDS},
#\link[dsShareServer]{encode.data.no.sharing}
encode.data.with.sharing <- function(encrypted.data, length, index)
{
  #remove conversion once new parsers is available
  header        <- ""
  data          <- as.character(paste(as.numeric(encrypted.data),sep="",collapse=";"))
  size          <- as.numeric(utils::object.size(data))
  timestamp     <- as.numeric(Sys.time()) / size

  return.value  <- list(header = "FM1" ,
                        payload = data,
                        property.a = size,
                        property.b = length,
                        property.c = timestamp,
                        property.d = index/timestamp)
  return(return.value)
}

#'@name encode.data.no.sharing
#'@title  encode some randomised data
#'@description This server-side function generates some random data to be made available to a client-side
#'function. Its purpose is to mimick the same behaviour as [dsServerParameter]{encode.data.with.sharing}. It aims a
#'a "decoy", if an error has occurred in the process.
#'@details This is a helper function. It cannot be called directly from any client-side
#'function.
#@seealso \link[dsShareServer]{getDataDS} \link[dsShareServer]{getCoordinatesDS},[dsShareServer]{encode.data.no.sharing}
encode.data.no.sharing <- function()
{
  settings      <- get.settings()
  header        <- ""
  data          <- as.character(paste(stats::runif(11 *13, 100000, 400000),sep="", collapse=";"))
  size          <- as.numeric(utils::object.size(data))
  no.columns    <- as.integer(stats::runif(1, min=settings$min_rows, max=settings$max_rows))
  no.rows       <- as.integer(stats::runif(1, min=settings$min_columns, max=settings$max_columns))
  index         <- ceiling(stats::runif(1, min = 0, max = no.columns))
  timestamp     <- as.numeric(Sys.time()) / size
  return.value  <- list(header = "FM2" ,
                        payload = data,
                        property.a = size,
                        property.b = no.columns,
                        property.c = timestamp,
                        property.d = index/timestamp)
  return(return.value)
}

#'@name are.params.created
#'@title check the some variables considered as parameters are created on a server
#'@param param_names names of params
#'@details This is a helper function. It cannot be called directly from any client-side
#'function.
#'@return TRUE if parameters are created. Otherwise false
are.params.created <- function(param_names = c())
{
  params.exist <- FALSE
  all.numeric  <- FALSE

  if (length(param_names) > 0)
  {
    if(length(param_names) >= 1  & is.character(param_names))
    {
      list.var      <- ls(pos = 1, all.names = TRUE)
      params.exist  <- all(param_names %in% list.var)

      if(params.exist)
      {
        #get the object and check for numerical values. mget checks for the existence and
        #retrieve object.
        env = globalenv()
        params      <-  mget(x = param_names, envir = env)
        all.numeric <- all(sapply(params, is.numeric))
      }
    }
  }
  return(params.exist & all.numeric)
}


#'@name are.encoded.data.and.settings.suitable
#'@title check some settings encoded data and settings are suitable for continuing transferring
#'@details This is a helper function. It cannot be called directly from any client-side
#'function.
#'@description  It checks the sharing for the following criteria:
#' 0. sharing is allowed
#' 1. the encoded data is the same as previously stated in the encoding check
#' 2. encoded data exists
#' 3. encoded data is a data frame
#' 4. the data encoded is character
#'@param data.encoded some encoded data
#'@param envir environment set by default to globalenv
#'@note Throws the following errors:
#'"SERVER::ERR:SHARE::002"  sharing is not allowed or the disclosure setting has not been set to 0 or 1
#'"SERVER::ERR:SHARE::005"  data.encoded does not exists on the server
#'"SERVER::ERR:SHARE::008"  data.encoded is not the same R object as previously validated \code{isDataEncodedDS}
#'"SERVER::ERR:SHARE::009"  data.encoded has yet to be validated by \code{isDataEncodedDS}
#'"SERVER::ERR:SHARE::010"  data.encoded is not a character vector
#'
are.arg.and.settings.suitable <- function(data.encoded, envir = globalenv())
{
  outcome <- FALSE
  if(is.sharing.allowed())
  {
    settings  <- get.settings()

    if(!is.character(data.encoded))
    {
      stop("SERVER::ERR:SHARE::010")
    }

    same.name   <- identical(settings$encoded.data.name,data.encoded)
    data.exists <- exists(data.encoded, where = envir)
    if(!data.exists)
    {
      stop("SERVER::ERR:SHARE::009")
    }

    data.encoded.var <- get(data.encoded, envir = envir)
    correct.format <- is.data.frame(data.encoded.var)
    if(!correct.format)
    {
      stop("SERVER::ERR:SHARE::005")
    }


    same.name <- identical(settings$encoded.data.name,data.encoded)
    if(!same.name)
    {
      stop("SERVER::ERR:SHARE::008")
    }
    outcome <- same.name & data.exists & correct.format
  }
  else
  {
    stop("SERVER::ERR:SHARE::002")
  }
  return(outcome)
}

#'@name get.sharing.name
#'@title retrieve the name of the sharing object
#'@description This function uses the option "dsSS_settings" to retrieve this information and the global env
#'@param envir the environment set by default to globalenv
get.sharing.name <-  function(envir = globalenv())
{
  settings           <- get.settings(envir)
  name.struct.exists <- any("name.struct.sharing" %in% names(settings))
  if (name.struct.exists)
  {
    return(settings$name.struct.sharing)
  }
  else if (!is.null(getOption("dsSS_sharing_param.name.struct")))
  {
    return(getOption("dsSS_sharing_param.name.struct"))
  }
  else
  {
    return("no_sharing")
  }
}

#'@name get.sharing
#'@title retrieve the sharing R object
#'@description This function uses the option "dsSS_settings" and the global enviroment
#'to retrieve the sharing of the data
#'@param envir the environment set by default to globalenv
#'@return the sharing R object if it has been created. Otherwise an empty list.
get.sharing <- function(envir = globalenv())
{
  sharing.name <- get.sharing.name()
  if(exists(sharing.name, envir = envir))
  {
    return(get(sharing.name,envir = envir))
  }
  else
  {
    return(list())
  }
}

#'@name get.transfer.name
#'@title retrieve the name of the transfer object
#'@description This function uses the option "dsSS_settings" to retrieve this information and the global env
#'@param envir the environment set by default to globalenv
#'@return name of the transfer object
get.transfer.name <-  function(envir = globalenv())
{
  settings           <- get.settings(envir = envir)
  name.struct.exists <- any("name.struct.transfer" %in% names(settings))
  if (name.struct.exists)
  {
    return(settings$name.struct.transfer)
  }
  else if (!is.null(getOption("dsSS_transfer.name.struct")))
  {
    return(getOption("dsSS_transfer.name.struct"))
  }
  else
  {
    return("no_transfer")
  }
}

#'@name get.name
#'@title read the name from an option
#'@description This function read the name of an option. If it it does not
#'exists then the current name value is returned.
#'@param current.name - A character argument representing a default value. Set to ""
#'@param option.name  - A character argument representing a R option. Set to ""
get.name <- function(current.name = "", option.name = "")
{
  # sets new.name to current name. If issues then name does not change.
  new.name <- current.name

  # obtain the option value
  name     <- getOption(option.name)

  # check the value is a class character
  if (is.character(name))
  {
    # check the value is different than current name
    if(!identical(name, current.name) & length(name) > 1)
    {
      new.name <- as.character(name)
    }
  }

  return(new.name)
}

#'@name get.transfer
#'@title retrieve the transfer R object
#'@description This function uses the option "dsSS_settings" and the global enviroment to retrieve the sharing of the data
#'@param envir the environment set by default to globalenv
#'@return the transfer R object if it has been created. Otherwise an empty list.
get.transfer <- function(envir = globalenv())
{
  transfer.name <- get.transfer.name()
  if(exists(transfer.name, envir = envir))
  {
    return(get(transfer.name,envir = envir))
  }
  else
  {
    return(list())
  }
}



#'@name get.settings.name
#'@title retrieve the name of the settings object
#'@description This function uses the option "dsSS_settings" to retrieve this information
#'
get.settings.name <-  function()
{
  env = globalenv()
  if (!exists("dsSS"))
  {
    setting.name <-  get.name("settings_ds_share","dsSS_settings")
    assign("dsSS", setting.name, envir = env)
  }

  return(get("dsSS", envir = env))
}

#'@name get.settings
#'@title retrieve the settings for the package
#'@description This function uses the option "dsSS_settings" and the global enviroment
#'to retrieve the settings
#'@param envir the environment set by default to globalenv
#'@export
get.settings <- function(envir = globalenv())
{
    settings.name <- get.settings.name()
    if(exists(settings.name, envir = envir))
    {
      return(get(settings.name,envir = envir))
    }
    else
    {
      stop("SERVER:ERR:021")
    }
}
