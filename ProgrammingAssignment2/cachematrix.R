## makeCaheMatrix returns a list of functions to store a matrix and 
## cahe the inverse of the matrix

## Functions are:
# set         sets the Matric
# get         gets the Matrix
# setInverse  caches the inverse Matrix
# getInverse  gets the inverse Matrix cached

makeCacheMatrix <- function(x = matrix()) {
  m <- NULL # will cache the (m)atrix
  
  # store the matrix
  set <- function(y) {
    x <<- y
    m <<- NULL
  }
  
  # returns the sored matrix
  get <- function() x
  
  # cache the incomming matrix (inv)
  setInverse <- function(inv) {
    m <<- inv
  }
  
  # get the cached matrix (inv)
  getInverse <- function() m
  
  list(set = set, get = get, setInverse = setInverse, getInverse = getInverse)

}


## cacheSolve calculates the inverse of the matrix created with makeCacheMatrix 

cacheSolve <- function(x, ...) {
        ## Return a matrix that is the inverse of 'x'
  # get the cached matrix, if it is not null return it
  m <- x$getInverse()
  if(!is.null(m)) {
    message("getting cached data")
    return(m)
  }
  
  # else get the matrix
  data <- x$get()
  # get the inverse
  inv <- solve(data)
  # and store it
  x$setInverse(inv)
  
  # return the inverted matrix
  inverse
}