!! a CLI frontent for ffilesystem
!! helps people understand ffilesystem output

program filesystem_cli

use, intrinsic :: iso_fortran_env, only: compiler_version, compiler_options, stdout=>output_unit, stderr=>error_unit

use filesystem

implicit none

integer :: i, L, argc
character(1000) :: buf, buf2
character(16) :: fcn

argc = command_argument_count()

if (argc < 1) error stop "usage: ./filesystem_cli <function> [<path> ...]"

call get_command_argument(1, fcn, length=L, status=i)
if (L == 0 .or. i /= 0) error stop "invalid function name: " // trim(fcn)

select case (fcn)
case ("cpp", "lang", "compiler", "get_cwd", "homedir", "tempdir", &
  "is_admin", "is_bsd", "is_cygwin", "is_wsl", "is_mingw", "is_unix", "is_linux", "is_windows", "is_macos", &
    "max_path", "exe_path", "lib_path")
  if (argc /= 1) error stop "usage: ./filesystem_cli " // trim(fcn)
case ("chmod_exe", "copy_file", "relative_to", "same_file", "with_suffix")
  if (argc /= 3) error stop "usage: ./filesystem_cli <function> [arg1 ...]"
  call get_command_argument(2, buf, status=i)
  if (i /= 0) error stop "invalid path: " // trim(buf)
  call get_command_argument(3, buf2, status=i)
  if (i /= 0) error stop "invalid path: " // trim(buf2)
case default
  !! 2 arguments
  if (argc /= 2) error stop "usage: ./filesystem_cli <function> <path>"
  call get_command_argument(2, buf, status=i)
  if (i /= 0) error stop "invalid path: " // trim(buf)
end select


select case (fcn)
case ("compiler")
  print '(a,/,a)', compiler(), compiler_version()
case ("cpp")
  print '(L1)', fs_cpp()
case ("lang")
  print '(i0)', fs_lang()
case ("is_admin")
  print '(L1)', is_admin()
case ("is_bsd")
  print '(L1)', is_bsd()
case ('is_macos')
  print '(L1)', is_macos()
case ('is_windows')
  print '(L1)', is_windows()
case ('is_linux')
  print '(L1)', is_linux()
case ('is_unix')
  print '(L1)', is_unix()
case ('is_wsl')
  print '(i1)', is_wsl()
case ('is_mingw')
  print '(L1)', is_mingw()
case ('is_cygwin')
  print '(L1)', is_cygwin()
case ("copy_file")
  call copy_file(buf, buf2, status=i)
  if (i /= 0) error stop "copy_file failed"
case ("get_cwd")
  print '(A)', trim(get_cwd())
case ("chdir", "set_cwd")
  print '(a)', "cwd: " // trim(get_cwd())
  if (.not. set_cwd(buf)) error stop "could not chdir " // trim(buf)
  print '(a)', "new cwd: " // trim(get_cwd())
case ("perm")
  print '(A)', get_permissions(buf)
case ("chmod_exe")
  block
  logical :: m
  integer :: ierr

  if(is_windows()) write(stderr,'(a)') "chmod_exe: not supported on windows"

  buf = canonical(buf)

  read(buf2, '(L1)', iostat=ierr) m
  if (ierr /= 0) then
    write(stderr, '(a, i0)') "chmod_exe: could not read CLI true/false: error ", ierr
    error stop
  endif

  write(stdout, '(a)', advance='no') "chmod " // get_permissions(buf) // " " // trim(buf) // " => "
  call chmod_exe(buf, m)
  print '(a)', get_permissions(buf) // " " // trim(buf)
  end block
case ("touch")
  print *, "touch: " // trim(buf)
  call touch(buf)
case ("normal")
  print '(A)', normal(buf)
case ("expanduser")
  print '(A)', expanduser(buf)
case ("exists")
  print '(L1)', exists(buf)
case ("homedir")
  print '(A)', get_homedir()
case ("is_absolute")
  print '(L1)', is_absolute(buf)
case ("is_dir")
  print '(L1)', is_dir(buf)
case ("is_exe")
  print '(L1)', is_exe(buf)
case ("is_file")
  print '(L1)', is_file(buf)
case ("is_symlink")
  print '(L1)', is_symlink(buf)
case ("exe_path")
  print '(A)', exe_path()
case ("lib_path")
  print '(A)', lib_path()
case ("mkdir")
  print *, "mkdir: " // trim(buf)
  call mkdir(trim(buf))
case ("parent")
  print '(A)', parent(buf)
case ("relative_to")
  print '(A)', relative_to(buf, buf2)
case ("which")
  print '(A)', which(buf)
case ("canonical")
  print '(A)', canonical(buf)
case ("resolve")
  print '(A)', resolve(buf)
case ("root")
  print '(A)', root(buf)
case ("same")
  print '(L1)', same_file(buf, buf2)
case ("file_size")
  print '(I0)', file_size(buf)
case ("stem")
  print '(A)', stem(buf)
case ("suffix")
  print '(A)', suffix(buf)
case ("tempdir")
  print '(A)', get_tempdir()
case ("with_suffix")
  print '(A)', with_suffix(buf, buf2)
case ("max_path")
  print '(i0)', get_max_path()
case default
  write(stderr,'(a)') "unknown function: " // trim(fcn)
  error stop
end select


end program
