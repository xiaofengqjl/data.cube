library(data.table)
library(data.cube)

X = populate_star(1e5, Y = 2015)
cb = as.cube(X)[,,,"NY",as.Date("2015-01-15")] # drop time and geog dimensions to fit array well into memory
cb.dimnames = dimnames(cb)
measure = "value"
dt = as.data.table(cb, na.fill = TRUE)
ar = as.array(cb, measure = measure)
dimcols = c(product = "prod_name", customer = "cust_profile", currency = "curr_name")

# length of array results, dummy tests
stopifnot(
    prod(sapply(cb.dimnames, length)) > 0L,
    dt[, prod(sapply(.SD, uniqueN)), .SDcols = dimcols] > 0L
)

## as.data.table
stopifnot(all.equal(dt[, c(dimcols, measure), with=FALSE], setnames(as.data.table(ar, na.rm = FALSE), names(dimcols), dimcols)))

## as.array

# use dimcols
stopifnot(all.equal(ar, as.array(dt, dimcols, measure)))

# use dimcols unnamed
ar.ren = ar
dimnames(ar.ren) = setNames(cb.dimnames, dimcols)
stopifnot(all.equal(ar.ren, as.array(dt, unname(dimcols), measure)))

# use dimnames only
dt.ren = copy(dt)
setnames(dt.ren, dimcols, names(dimcols))
stopifnot(all.equal(ar, as.array(dt.ren, measure = measure, dimnames = cb.dimnames)))

# use dimnames and dimcols
stopifnot(all.equal(ar, as.array(dt, dimcols = dimcols, measure = measure, dimnames = cb.dimnames)))

# detect measure
stopifnot(
    all.equal(ar, as.array(dt[, c(dimcols, measure), with=FALSE], dimcols))
    , all.equal(ar, as.array(dt.ren[, c(names(dimcols), measure), with=FALSE], dimnames = cb.dimnames))
    , all.equal(ar, as.array(dt[, c(dimcols, measure), with=FALSE], dimcols = dimcols, dimnames = cb.dimnames))
)

# tests status ------------------------------------------------------------

invisible(TRUE)
