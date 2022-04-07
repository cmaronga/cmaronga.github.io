---
  title: <center><strong> Working with databases in R </strong></center>
  author: <center><strong> Christopher Maronga - R Programmer </strong></center>
  date: <center><strong> 12 June, 2021 </strong></center>
  output: 
  html_document:
  keep_md: yes
number_sections: yes
theme: united
toc: yes
toc_depth: 4
toc_float:
  collapsed: yes
smooth_scroll: yes
---
  
  
  
  
  
  # Loading packages
  
  
  ```r
library(DBI)  # R database interface
library(odbc)  # connection to odbc compatible database
library(RSQLite) # Backed driver for SQLite
library(RMySQL) # Backed driver for MySQL
library(tidyverse) # dplyr verbs and more
library(redcapAPI) # connecting to REDCap database
library(here)  # manage working directories
```


## Available drivers for `odbc`


```r
odbcListDrivers()[[1]] %>% unique()
```

[1] "SQL Server"                    "PostgreSQL ANSI(x64)"         
[3] "PostgreSQL Unicode(x64)"       "SAS ACCESS to SQL Server"     
[5] "MySQL ODBC 8.0 ANSI Driver"    "MySQL ODBC 8.0 Unicode Driver"


# Connecting to `MySQL` database

You can connect to `MySQL` in two ways:-
  
  ## Using an `odbc` driver
  
  
  
  ```r
# using appropriate odbc driver
# Not appropriate for serverless databases such as SQLite; first letters of all arguments are uppercase

nai_con1 <- dbConnect(odbc(),
                      Driver = Sys.getenv("driver"),
                      Server = Sys.getenv("server"),
                      Uid = Sys.getenv("uid"),
                      Database = Sys.getenv("database") ,
                      Pwd = Sys.getenv("pwd"))


dbListTables(nai_con1)
```

[1] "tbl_baseline"   "tbl_disch"      "tbl_month3_fup" "tbl_mtcars"    


## `DBI` compliant R package

Provide `DBI` compliant back-end for connecting to RDBMS. These include `RMySQL`, `RSQLite`, `ROracle`, `RPostgreSQL` etc.


```r
# use of DBI compliant R packages

nai_con2 <- dbConnect(MySQL(),
                      host = "localhost",
                      dbname = "naidemostudy",
                      user = "root",
                      password = "root@2021Train!")

dbListTables(nai_con2)
```

[1] "tbl_baseline"   "tbl_disch"      "tbl_month3_fup" "tbl_mtcars"    

```r
# world
world_con <- dbConnect(MySQL(),
                       host = "localhost",
                       dbname = "world",
                       user = "root",
                       password = "root@2021Train!")

dbListTables(world_con)
```

[1] "city"            "country"         "countrylanguage"


# Connecting to `SQLite` database

Light-weight and serverless database


```r
# need to supply the backend driver and dbname/location .db file

nyc_con1 <- dbConnect(SQLite(),
                      dbname = here("SQLite_databases", "nyc_flights.db"))

dbListTables(nyc_con1)
```

[1] "tbl_airlines" "tbl_airports" "tbl_flights"  "tbl_planes"   "tbl_weather" 



# Exploring the `DBI` functions

## List tables in a database

```r
# List tables in a database

dbListTables(world_con)
```

[1] "city"            "country"         "countrylanguage"

## List field names in tables

```r
# List field names of a particular database table
dbListFields(nai_con2, "tbl_baseline")
```

[1] "row_names"     "subjid"        "agemonth"      "base_muac"    
[5] "base_weight"   "base_headcirc" "base_height"   "sex"          
[9] "base_date"     "site"         


## Execute a `SQL` query

```r
# Execute a query in a database

worl_res <- dbSendQuery(world_con, "SELECT * FROM city")
```

## Fetch results of a query

```r
# Fetch results from a previously executed query
# returns a data frame 

dframe <- dbFetch(worl_res)

dbClearResult(worl_res)
```

[1] TRUE


## Execute and fetch query results

```r
# Execute/send query and fetch/retrieve results at ago
# returns a data frame

dframe2 <- dbGetQuery(world_con, "SELECT * FROM city")

# JOIN
world_data <- dbGetQuery(world_con, "SELECT * FROM city AS c
                         JOIN countrylanguage As con ON c.CountryCode = con.CountryCode")
```


## Read a database table

```r
# Read tables of the database as dataframes dbReadTable
# Basically skip the SELECT * ----

dframe3 <- dbReadTable(nai_con1, "tbl_disch") # SELECT * FROM tbl_dish
```


## Connection metadata

```r
# Metadata about the connection
dbGetInfo(nai_con1)
```

$dbname
[1] "naidemostudy"

$dbms.name
[1] "MySQL"

$db.version
[1] "8.0.25"

$username
[1] "root"

$host
[1] ""

$port
[1] ""

$sourcename
[1] "\004"

$servername
[1] "localhost via TCP/IP"

$drivername
[1] "myodbc8w.dll"

$odbc.version
[1] "03.80.0000"

$driver.version
[1] "08.00.0025"

$odbcdriver.version
[1] "03.80"

$supports.transactions
[1] TRUE

$getdata.extensions.any_column
[1] TRUE

$getdata.extensions.any_order
[1] TRUE

attr(,"class")
[1] "MySQL"       "driver_info" "list"       


# Using `dplyr` functions

## `tbl` function

```r
tbl(nai_con2, "tbl_baseline") %>% 
  select(subjid, agemonth, base_muac)
```

# Source:   lazy query [?? x 3]
# Database: mysql 8.0.25 [@localhost:/naidemostudy]
subjid agemonth base_muac
<dbl>    <dbl>     <dbl>
  1    481        8      11.3
2    482        6      10.4
3    483       10      11  
4    484       16      11.4
5    485        6      11.3
6    486       16      11  
7    487        8      11.3
8    488        8      10.2
9    489        7      10.4
10    490       10      11.9
# ... with more rows


## `show_query` function

Getting to see/view the SQL code generated by tidyverse workflow

```r
tbl(nai_con2, "tbl_baseline") %>% 
  select(subjid, agemonth, base_muac) %>% show_query()
```

<SQL>
  SELECT `subjid`, `agemonth`, `base_muac`
FROM `tbl_baseline`

```r
tbl(nai_con2, "tbl_baseline") %>% 
  filter(agemonth >= 10) %>% show_query()
```

<SQL>
  SELECT *
  FROM `tbl_baseline`
WHERE (`agemonth` >= 10.0)


## `collect` function


# Closing database connection


```r
nai_dframe1 <- tbl(nai_con2, "tbl_baseline") %>% 
  select(subjid, agemonth, base_muac) %>% collect()

city_dframe <- tbl(world_con, "city") %>% collect() # dbReadTable()


# JOIN

tbl(nai_con1, "tbl_baseline") %>% 
  left_join(tbl(nai_con1, "tbl_disch"),
            by = "subjid") %>% show_query()
```

<SQL>
  SELECT `LHS`.`row_names` AS `row_names.x`, `LHS`.`subjid` AS `subjid`, `agemonth`, `base_muac`, `base_weight`, `base_headcirc`, `base_height`, `sex`, `base_date`, `site`, `RHS`.`row_names` AS `row_names.y`, `disc_date`, `disch_oxysat`, `hb`
FROM `tbl_baseline` AS `LHS`
LEFT JOIN `tbl_disch` AS `RHS`
ON (`LHS`.`subjid` = `RHS`.`subjid`)

```r
base_dish <- tbl(nai_con1, "tbl_baseline") %>% 
  left_join(tbl(nai_con1, "tbl_disch"),
            by = "subjid") %>% collect()
```


# Connecting via `sql` chunk


```sql

SELECT * FROM `tbl_baseline`

```



# Connecting to `REDCap` database



```r
# To create a connection, you need to supply
# 1. redcap url
# 2. API token
# redcap_con <- redcapConnection(url = "https://uat.chainnetwork.org/redcap/api/",
#                                token = "76B2DF219CCFBC048E8661AD64CB7205")
```


## List REDCap events




## List database instruments





## Database metadata




## Export records

Can be achieved in 3 ways

### Export all records

Suitable for small-sized databases



### Export by event

Useful for otherwise very large databases to speed up things




### Export by instrument

Exporting an instrument at a time



## Export users
View and manage users accessing your database




# API security


```r
#file.edit("~/.Renviron")
```

















