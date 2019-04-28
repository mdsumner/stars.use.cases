f <- fs::dir_ls("../rasterwise/extdata", regex = "nc$", recursive = TRUE)
read_ncdf(f[1])
library(furrr)
library(purrr)
plan(multiprocess)
safe_read_ncdf <- safely(function(x) summary(read_ncdf(x)))

x <- future_map(f, safe_read_ncdf)

idx <- which(unname(unlist(lapply(x, function(a) is.null(a$result)))))

##../rasterwise/extdata/R13352.nc
##Error in names(object) <- nm : 
##  'names' attribute [3] must be the same length as the vector [2] 

## warning
#../rasterwise/extdata/19911203.nc 
# Warning message:
#   ignoring unrecognized unit: n/a 

## memory problem

##../rasterwise/extdata/large-mem/pp_ens_mean_0.25deg_reg_v19.0e.nc 


f[30]
# ../rasterwise/extdata/rectilinear/ACCfronts_nc4.nc
# read_ncdf(f[30])
# Error : NetCDF: Variable not found
# In addition: Warning messages:
#   1: Could not parse expression: ‘`valid` * `range` * `from` * ^(0) * `to` * ^(12)’. Returning as a single symbolic unit() 
# 2: ignoring unrecognized unit: valid range from 0 to 12 
# Error : NetCDF: Variable not found
# Error in as.POSIXct.numeric(units::set_units(c(t0, t1), u, mode = "standard")) : 
#   'origin' must be supplied 



# TODO
# - allow stars_proxy to be pulled
# - allow stars_proxy to apply select_var
# - 
#' @examples
#' f <- system.file("nc/reduced.nc", package = "stars")
#' read_stars_tidync(f)
#' read_stars_tidync(f, select_var = "anom", proxy = FALSE) ## only works if proxy = FALSE
#' read_stars_tidync(f, lon = index <= 10, lat = index <= 12, time = index < 2)
read_stars_tidync = function(.x, ..., select_var = NULL, proxy = TRUE) {
  if (length(.x) > 1) {
    warning("only first source/file used")
    .x = .x[1L]
  }
  if (!proxy) {
    x = tidync::tidync(.x) %>% 
      tidync::hyper_filter(...) %>% 
      tidync::hyper_array(select_var = select_var, drop = FALSE)  ## always keep degenerate dims
    tt = attr(x, "transforms")
    
    nms = names(tt)
    tt = lapply(tt, function(tab) tab[tab$selected, , drop = FALSE])
    dims = stars:::create_dimensions(setNames(lapply(nms, 
                                                     function(nm) stars:::create_dimension(values = tt[[nm]][[nm]])), nms))
    attr(x, "transforms") = NULL
    attr(x, "source") = NULL
    
    class(x) = "list"
    out = stars:::st_stars(x, dims)
  } else {
    x = tidync::tidync(.x) %>% tidync::hyper_filter(...) #%>% tidync::hyper_array()
    tt = tidync::hyper_transforms(x, all = FALSE)
    nms = names(tt)
    tt =  lapply(tt, function(tab) tab[tab$selected, , drop = FALSE])
    dims = stars:::create_dimensions(setNames(lapply(nms, 
                                                     function(nm) stars:::create_dimension(values = tt[[nm]][[nm]])), nms))
    
    out = structure(list(names = .x), dimensions = dims, NA_value = NA, class = c("stars_proxy", "stars"))
  }
  out
}

                                                     
f = "~/Git/rasterwise/extdata/large-mem/pp_ens_mean_0.25deg_reg_v19.0e.nc"
read_stars_tidync(f, longitude = longitude < -39, time = index <= 5)

f = "~/Git/rasterwise/extdata/1D/test.nc"
read_stars_tidync(f, z = z > 900)

