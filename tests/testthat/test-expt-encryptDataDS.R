source("definition_tests/def_sharing_structure.R")
source("definition_tests/def_process.R")
source("options/options_definitions.R")

context("encryptDataDS::expt::incorrect_parameters")
test_that("variables exists",
{
  expect_error(encryptDataDS(123,134))
  expect_error(encryptDataDS("123","134"))
  expect_error(encryptDataDS(TRUE,"134"))
  expect_error(encryptDataDS("123",FALSE))
})

context("encryptDataDS::expt::no_settings")
test_that("variables exists",
{
  if (exists("settings_ds_share",where = 1))
  {
    rm("settings_ds_share", pos=1)
  }
  expect_error(encryptDataDS(123,134))
  expect_error(encryptDataDS("123","134"))
  expect_error(encryptDataDS(TRUE,"134"))
  expect_error(encryptDataDS("123",FALSE))
  expect_error(encryptDataDS(123,134))
  expect_error(encryptDataDS("123","134"))
  expect_error(encryptDataDS(TRUE,"134"))
  expect_error(encryptDataDS(FALSE,FALSE))
})


set.default.options.restrictive
options(dsSS_sharing.allowed = 0)


context("encryptDataDS::expt::not_allowed_to_share")
test_that("not_allowed_to_take_part",
{
  expect_error(assignSharingSettingsDS())

  expect_error(encryptDataDS(TRUE, FALSE))
})

set.default.options.not.restrictive()
assignSharingSettingsDS()
settings <- get.settings()

context("encryptDataDS::expt::edds.define_no_rows")
test_that("define.no.rows",
{
  #numeric and odd number
  expect_equal(is.integer(edds.define_no_rows(settings)),TRUE)
  expect_equal(edds.define_no_rows(settings) %% 2 == 1, TRUE)
  expect_equal(edds.define_no_rows(settings) %% 2 == 0, FALSE)

  #correct range
  no.rows <- edds.define_no_rows(settings)
  expect_equal((no.rows >= 21 & no.rows <= 31),TRUE)

})
assignSharingSettingsDS()
settings <- get.settings()

context("encryptDataDS::expt::.define_no_columns")
test_that("numeric and odd number",
{
  expect_equal(is.integer(edds.define_no_columns(settings)),TRUE)
  expect_equal(edds.define_no_columns(settings) %% 2 == 1, TRUE)
})

test_that("correct range",
{
  no.columns <- edds.define_no_columns(settings)
  expect_equal((no.columns >= 23 & no.columns <= 33),TRUE)
})

test_that("correct range",
{
  no.rows = 15
  #numeric and odd number
  expect_equal(is.integer(edds.define_no_columns(settings, no.rows = no.rows)),TRUE)
  expect_equal(edds.define_no_columns(settings, no.rows = no.rows) %% 2 == 1, TRUE)
})

test_that("incorrect input",
{
  no.rows = "a"
  expect_error(edds.define_no_columns(settings, no.rows = no.rows))
})

context("encryptDataDS::expt::.createMatrixRUnif")
test_that("no argument",
{
  createdMatrix <- edds.create.matrix.runif(settings)
  expect_equal(nrow(createdMatrix) == settings$min_rows, TRUE)
  expect_equal(ncol(createdMatrix) == settings$min_columns, TRUE)
  expect_equal(all(createdMatrix <= 1, TRUE),TRUE)
})

test_that("no row",
{
  createdMatrix <- edds.create.matrix.runif(settings, no.rows = 10)
  expect_equal(nrow(createdMatrix) == 21, TRUE)
  expect_equal(ncol(createdMatrix) == 23, TRUE)
  expect_equal(all(createdMatrix <= 1, TRUE),TRUE)
})

test_that("no row correct",
{
  createdMatrix <- edds.create.matrix.runif(settings = settings, no.rows = 12)
  expect_equal(nrow(createdMatrix) == 21, TRUE)
  expect_equal(ncol(createdMatrix) == 23, TRUE)
  expect_equal(all(createdMatrix <= 1, TRUE),TRUE)
})

test_that("no column incorrect",
{
  createdMatrix <- edds.create.matrix.runif(settings, no.rows = 13, no.columns = 11)
  expect_equal(nrow(createdMatrix) == 21, TRUE)
  expect_equal(ncol(createdMatrix) == 23, TRUE)
  expect_equal(all(createdMatrix <= 1, TRUE),TRUE)
})

test_that("no row  and columns correct",
{
  createdMatrix <- edds.create.matrix.runif(settings, no.rows = 15, no.columns = 17)
  expect_equal(nrow(createdMatrix) == 21, TRUE)
  expect_equal(ncol(createdMatrix) == 23, TRUE)
  expect_equal(all(createdMatrix <= 1, TRUE),TRUE)
})


test_that("no row  and columns, min value correct",
{
  expect_warning(edds.create.matrix.runif(settings, no.rows = 15, no.columns = 17, min.value = 15))

})

test_that("no row  and columns, min value incorrect",
{

  createdMatrix <- edds.create.matrix.runif(settings, no.rows = settings$min_rows+1,
                                          no.columns = settings$min_columns+1, min.value = -12)
  expect_equal(nrow(createdMatrix) == settings$min_rows+1, TRUE)
  expect_equal(ncol(createdMatrix) == settings$min_columns+1, TRUE)
  expect_equal(all(createdMatrix >= -12 & createdMatrix <= 1, TRUE),TRUE)
})

test_that("no row  and columns, min value, max value correct",
{
  createdMatrix <- edds.create.matrix.runif(settings, no.rows = 15, no.columns = 17, min.value = -12, max.value = 298)
  expect_equal(nrow(createdMatrix) == 21, TRUE)
  expect_equal(ncol(createdMatrix) == 23, TRUE)
  expect_equal(all(createdMatrix >= -12 & createdMatrix <= 298, TRUE),TRUE)
})

options(param.name.struct = "sharing")
options(param.sharing.allowed = 1)

#("Step 0")
assign("pi_value_1", 100000, pos = 1)
assign("pi_value_2", 200000, pos = 1)
assign("pi_value_3", 300000, pos = 1)

assignSharingSettingsDS()


#("Step 1")
encryptDataDS(TRUE, FALSE)
assign("master.1" ,get("sharing",pos=1), pos = 1)

#("Step 2")
assign("a", getDataDS(master_mode =TRUE), pos = 1)
rm(sharing,pos=1)
assignDataDS(master_mode = FALSE,a$header,a$payload,a$property.a,a$property.b,a$property.c,a$property.d)
assign("receiver.1", get("sharing",pos=1), pos = 1)

#("Step 3")
encryptDataDS(FALSE, FALSE)
assign("receiver.2", get("sharing",pos=1), pos = 1)

#("step 4")
assign("b",getDataDS(master_mode =  FALSE), pos = 1)
rm(sharing,pos=1)
assign("sharing", get("master.1", pos = 1), pos=1)
b <- get("b", pos = 1)
assignDataDS(master_mode = TRUE, b$header,b$payload,b$property.a,b$property.b,b$property.c,b$property.d)
assign("master.2", get("sharing",pos=1), pos = 1)


#("step 5")
decryptDataDS()
assign("master.3", get("sharing",pos=1), pos = 1)
outcome <- assignParamSettingsDS(c("pi_value_1","pi_value_2","pi_value_3"))
assign("master.3.5", get("sharing",pos = 1), pos = 1)
assign("f", getCoordinatesDS(), pos = 1)
rm(sharing,pos=1)
assign("sharing", get("receiver.2", pos = 1), pos=1)
assignCoordinatesDS(f$header, f$payload,f$property.a,f$property.b,f$property.c,f$property.d)
assign("receiver.2.5", get("sharing", pos = 1), pos = 1)
rm(sharing,pos=1)
assign("sharing", get("master.3.5", pos = 1), pos=1)

encryptParamDS()

assign("master.4", get("sharing",pos = 1), pos = 1)
removeEncryptingDataDS(master_mode = TRUE)
assign("master.5", get("sharing",pos = 1), pos = 1)

#("step 6 - Receiver becomes master .... ")
assign("sharing", get("receiver.2.5", pos = 1), pos=1)
removeEncryptingDataDS(master_mode = FALSE)
assign("receiver.3", get("sharing",pos = 1), pos = 1)



context("encryptDataDS::expt::.is.encrypted.valid")
test_that(".is.encrypted.valid",
{
  #correct structure
  encryptDataDS(TRUE,TRUE)
  sharing <- get("sharing",pos = 1)
  expect_equal(edds.is.encrypted.valid(sharing,expected.list),TRUE)

  correct.structure  <- list(data = c(1:4),
  concealing.matrix = matrix(1:2,1,1),
  masking.matrix = matrix(1:2,1,1),
  encrypted.matrix = matrix(1:2,1,1),
  index = 3)
  assign("sharing",correct.structure, pos=1)
  expect_equal(edds.is.encrypted.valid(sharing,expected.list),TRUE)

  #incorrect structure
  incorrect.structure <- list()
  assign("sharing",incorrect.structure, pos=1)
  sharing <- get("sharing",pos = 1)
  expect_equal(edds.is.encrypted.valid(sharing,expected.list),FALSE)

  incorrect.structure <- list(master.vector = c(1,2,3),
  concealing.matrix = matrix(1:2,1,1))
  assign("sharing",incorrect.structure, pos=1)
  sharing <- get("sharing",pos = 1)
  expect_equal(edds.is.encrypted.valid(sharing,expected.list),FALSE)
})

context("encryptDataDS::expt::.create.structure.master")
test_that(".create.structure.master",
{
  expected.list <- c("concealing","masking","no_columns","no_rows")
  assignSharingSettingsDS()
  settings <- get("settings_ds_share", pos =1)
  sharing <- edds.create.structure.master(settings, min=1, max=2,no.rows=11, no.columns=13)
  expect_equal(is.list(sharing),TRUE)
  expect_equal(all(expected.list %in% names(sharing), TRUE), TRUE)
  expect_equal(length(sharing) == length(expected.list), TRUE)

  expect_equal(is.matrix(sharing$masking), TRUE)
  expect_equal(is.matrix(sharing$concealing), TRUE)
})



context("encryptDataDS::expt::.create.structure.receiver")
test_that("received matrix does not exist",
{
  expected.list <- c("concealing.matrix","masking.matrix","received.matrix")
  #the received matrix does not exists
  assignSharingSettingsDS()
  settings <- get("settings_ds_share", pos =1)


  sharing <- edds.create.structure.receiver(settings, 4,23)
  expect_equal(is.list(sharing),TRUE)
  expect_equal(all(expected.list %in% names(sharing), FALSE), FALSE)
  expect_equal(length(sharing) == 0, TRUE)

  expect_equal(is.vector(sharing$master.vector), FALSE)
  expect_equal(is.matrix(sharing$encoded.matrix), FALSE)
  expect_equal(is.matrix(sharing$masking.matrix), FALSE)
  expect_equal(is.matrix(sharing$concealing.matrix), FALSE)

  a.list <- list(element = 3.1427)
  assign("sharing",a.list, pos=1)
  assignSharingSettingsDS()
  settings <- get("settings_ds_share", pos =1)
  sharing <- edds.create.structure.receiver(settings,4,23)
  expect_equal(is.list(sharing),TRUE)
  expect_equal(all(expected.list %in% names(sharing), FALSE), FALSE)
  expect_equal(length(sharing) == 0, TRUE)

  expect_equal(is.vector(sharing$master.vector), FALSE)
  expect_equal(is.matrix(sharing$encoded.matrix), FALSE)
  expect_equal(is.matrix(sharing$masking.matrix), FALSE)
  expect_equal(is.matrix(sharing$concealing.matrix), FALSE)
})

#start again from clean environment to test the outcome
rm(list=ls(pos = 1),pos=1)
#("Step 0")
#("Step 0")
assign("pi_value_1", 100000, pos = 1)
assign("pi_value_2", 200000, pos = 1)
assign("pi_value_3", 300000, pos = 1)

assignSharingSettingsDS()


#("Step 1")
encryptDataDS(TRUE, FALSE)
assign("master.1" ,get("sharing",pos=1), pos = 1)

#("Step 2")
assign ("a", getDataDS(master_mode =TRUE), pos = 1)
rm(sharing,pos=1)
assignDataDS(master_mode = FALSE,a$header,a$payload,a$property.a,a$property.b,a$property.c,a$property.d)
assign("receiver.1", get("sharing",pos=1), pos = 1)

#("Step 3")
encryptDataDS(FALSE, FALSE)
assign("receiver.2", get("sharing",pos=1), pos = 1)

#("step 4")
assign("b", getDataDS(master_mode =  FALSE), pos = 1)
rm(sharing,pos=1)
assign("sharing", get("master.1", pos = 1), pos=1)
assignDataDS(master_mode = TRUE, b$header,b$payload,b$property.a,b$property.b,b$property.c,b$property.d)
assign("master.2", get("sharing",pos=1), pos = 1)


#("step 5")
decryptDataDS()
assign("master.3", get("sharing",pos=1), pos = 1)
outcome <- assignParamSettingsDS(c("pi_value_1","pi_value_2","pi_value_3"))
assign("master.3.5", get("sharing",pos = 1), pos = 1)
assign("f", getCoordinatesDS(), pos = 1)
rm(sharing,pos=1)
assign("sharing", get("receiver.2", pos = 1), pos=1)
assignCoordinatesDS(f$header, f$payload,f$property.a,f$property.b,f$property.c,f$property.d)
assign("receiver.2.5", get("sharing", pos = 1), pos = 1)
rm(sharing,pos=1)
assign("sharing", get("master.3.5", pos = 1), pos=1)

encryptParamDS()

assign("master.4", get("sharing",pos = 1), pos = 1)
removeEncryptingDataDS(master_mode = TRUE)
assign("master.5", get("sharing",pos = 1), pos = 1)

#("step 6 - Receiver becomes master .... ")
assign("sharing", get("receiver.2.5", pos = 1), pos=1)
removeEncryptingDataDS(master_mode = FALSE)
assign("receiver.3", get("sharing",pos = 1), pos = 1)
assign("outcome", encryptDataDS(TRUE, TRUE), pos = 1)
assign("receiver.4", get("sharing",pos = 1), pos = 1)

test_that("step 6",
{
   expect_equal(get("outcome", pos = 1), TRUE)

})

#("step 7")
assign("c", getDataDS(master_mode = TRUE), pos = 1)
rm(sharing,pos=1)
assign("sharing", master.5, pos = 1)
c <- get("c" ,pos = 1)
assignDataDS(master_mode = FALSE,c$header,c$payload,c$property.a,c$property.b,c$property.c,c$property.d)
assign("master.6", get("sharing",pos = 1), pos = 1)

#("step 8 ")
outcome <- encryptDataDS(FALSE, TRUE)
master.7 <- get("sharing",pos=1)

test_that("step 8",
{
  expect_equal(outcome, TRUE)
})




