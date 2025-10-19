program main

use, intrinsic :: iso_c_binding, only: C_BOOL, C_CHAR

implicit none

interface
logical(C_BOOL) function has_filename(path) bind(C)
import
character(kind=C_CHAR), dimension(*), intent(in) :: path
end function
end interface

if (has_filename("hello.txt")) print '(a)', "has_filename: OK"

end program
