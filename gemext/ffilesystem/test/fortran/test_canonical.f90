program test_canon

use, intrinsic:: iso_fortran_env, only : stderr=>error_unit

use filesystem, only : path_t, get_cwd, same_file, canonical, is_dir, is_file, is_cygwin

implicit none


call test_canonical()
print '(a)', "OK: canonical full"

contains

subroutine test_canonical()

type(path_t) :: cur, par, file, p1, p2
character(*), parameter :: dummy = "nobody.txt"

integer :: L1, L2, L3

! -- current directory  -- old MacOS doesn't handle "." or ".." alone
cur = path_t(".")
cur = cur%canonical()
L1 = cur%length()
if (L1 < 1) then
  write(stderr,*) "ERROR: canonical '.' " // cur%path()
  error stop
endif

if (cur%path() /= get_cwd()) then
  write(stderr,*) "ERROR: canonical('.') " // cur%path() // " /= get_cwd: " // get_cwd()
  error stop
endif

print *, "OK: current dir = ", cur%path()
! -- home directory
p1 = path_t("~")
p1 = p1%canonical()
if (p1%path(1,1) == "~") error stop "%canonical ~ did not expanduser: " // p1%path()
if (canonical("~") == "~") error stop "canonical('~') should not be '~'"
print *, "OK: home dir = ", p1%path()

p2 = path_t(p1%parent())
L1 = p2%length()
if (L1 >= p1%length()) error stop "parent home " // p2%path()
print *, "OK: parent home = ", p2%path()


! -- relative dir
par = path_t("~/..")
par = par%canonical()

L2 = par%length()
if (L2 /= L1) then
  write(stderr,*) 'ERROR:canonical:relative: up dir not canonicalized: ~/.. => ' // par%path()
  error stop
endif
print *, 'OK: canon_dir = ', par%path()

! -- relative, non-existing file
if(is_cygwin()) then
  print '(a)', 'skip relative file not-exist as Cygwin does not support it'
else
file = path_t('~/../' // dummy)
file = file%canonical()
if(file%length() == 0) error stop "ERROR: relative file did not canonicalize: " // file%path()
L3 = file%length()

L1 = len(dummy)
if (L2 > 1) L1 = L1 + 1  !< when L2==1, $HOME is like /root instead of /home/user

if (L3 - L2 /= L1) then
  write(stderr,*) 'ERROR relative file was not canonicalized: ' // file%path(), L2, par%path(), L3, len(dummy)
  error stop
endif
endif !< is_cygwin

file = path_t('../' // dummy)
file = file%canonical()
if (file%path() /= "../" // dummy) then
  write(stderr,*) 'ERROR: relative file did not canonicalize: ' // file%path()
  error stop
end if

!> empty
if(canonical("") /= "") error stop "canonical('') " // canonical("") // " /= ''"

print *, 'OK: canon_file = ', file%path()

end subroutine test_canonical


end program
