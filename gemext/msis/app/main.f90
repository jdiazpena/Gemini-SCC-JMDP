program msis_driver
!! will write to stdout if "-" specified, so we avoid printing to console unless file output is used

use msis_interface, only : msis_gtd7, msis_gtd8, msisinit
use h5fortran, only : hdf5_file, hsize_t
use, intrinsic:: iso_fortran_env, only : real32, real64, stderr=>error_unit, stdout=>output_unit, stdin=>input_unit

implicit none

integer :: i,j,k
real(real32) :: doy,sec,f107a,f107, Ap(7)
real(real32), allocatable, dimension(:,:,:,:) :: Dn, Tn
real(real32), allocatable, dimension(:,:,:) :: glat, glon, alt
integer :: u, msis_version, lx1, lx2, lx3
character(2048) :: buf
logical :: has_msis2, debug = .false.
character(:), allocatable :: infile,outfile

integer, parameter :: comp_lvl = 3

!> user options
select case (command_argument_count())
case (1)
  !! asking for help or features
  call get_command_argument(1, buf)

  if (buf == '-features') then
    if(has_msis2) then
      print '(a)', "MSIS00 MSIS2"
    else
      print '(a)', "MSIS00"
    endif
    stop
  endif
  write(stderr,'(a)') "msis_setup: unknown option: " // trim(buf)
  error stop "msis_setup: usage: msis_setup infile outfile  |  msis_setup -features"
case (2)
  call get_command_argument(1,buf)
  infile = trim(buf)
  call get_command_argument(2, buf)
  outfile = trim(buf)
case default
  error stop "msis_setup: usage: msis_setup infile outfile  |  msis_setup -features"
end select

!> select input format
call input_hdf5(infile, msis_version, doy,sec,f107a,f107,Ap, glat, glon, alt)

!> Run MSIS
lx1 = size(alt,1)
lx2 = size(alt,2)
lx3 = size(alt,3)
allocate(Dn(lx1,lx2,lx3, 9), Tn(lx1,lx2,lx3, 2))

if(msis_version > 0) call msisinit()

do i=1,lx1
  do j=1,lx2
    do k=1,lx3

      select case (msis_version)
      case (0)
        call msis_gtd7(doy, sec, alt(i,j,k), glat(i,j,k), glon(i,j,k), f107a, f107, Ap, Dn(i,j,k,:), Tn(i,j,k,:), use_meters=.true.)
      case (21)
        !! MSIS 2.x
        call msis_gtd8(doy, sec, alt(i,j,k), glat(i,j,k), glon(i,j,k), f107a, f107, Ap, Dn(i,j,k,:), Tn(i,j,k,:))
      case default
        write(stderr, '(a,i0)') "ERROR: msis_setup: unknown msis_version ", msis_version
        error stop
      end select

      !> sanity check
      if(debug .or. any(Dn(i,j,k,:) < 0) .or. any(Tn(i,j,k,:) > 1000000) .or. any(Tn(i,j,k,:) < 0)) then
        write(stderr,'(a,f3.1,a,f4.0,1x,f10.3,1x,f8.3,1x,f8.3,1x,f8.3,1x,f8.3,1x,f8.3,1x,f4.0)') "MSIS", &
        real(msis_version)/10, &
          " inputs: doy, UTsec, alt, glat, glon, f107a, f107, Ap ", &
          doy, sec, alt(i,j,k), glat(i,j,k), glon(i,j,k), f107a, f107, Ap(1)
        write(stderr, '(a,f15.3)') "N2 density: ", Dn(i,j,k,3)
        write(stderr, '(a,2f18.1)') "Temperature, exo temperature: ", Tn(i,j,k,2), Tn(i,j,k,1)
        if (.not. debug) error stop "msis_setup failed"
      endif

    end do
  end do
end do

call output_hdf5(outfile, doy, sec, alt, glat, glon, Dn, Tn, msis_version)

contains


subroutine input_hdf5(filename, msis_version, doy,sec,f107a,f107,Ap7, glat, glon, alt)
!! use binary to reduce file size and read times
character(*), intent(in) :: filename
integer, intent(out) :: msis_version
real(real32), intent(inout) :: doy,sec,f107a,f107,ap7(7)
!! intent(out)
real(real32), intent(inout), allocatable :: glat(:,:,:), glon(:,:,:), alt(:,:,:)
!! intent(out)

type(hdf5_file) :: hf
integer(hsize_t), allocatable :: dims(:)
integer :: lx1,lx2,lx3, doy_int
logical :: exists

inquire(file=filename, exist=exists)
if(.not. exists) error stop "input_hdf5: input MSIS data file not found: " // filename

call hf%open(filename, action='r')

call hf%read("/msis_version", msis_version)
if(msis_version < 0) error stop "msis_driver: msis_version must be >= 0"

call hf%read("/doy", doy_int)
if(doy_int < 1 .or. doy_int > 366) error stop 'msis_driver:input_hdf5: 1 <= doy <= 366'
doy = doy_int

call hf%read("/UTsec", sec)
if(sec < 0 .or. sec > 86400) error stop 'msis_driver:input_hdf5: 0 <= sec <= 86400'

call hf%read("/f107a", f107a)
if(f107a < 0) error stop 'msis_driver:input_hdf5: f107a > 0'

call hf%read("/f107", f107)
if(f107 < 0) error stop 'msis_driver:input_hdf5: f107 > 0'

call hf%read("/Ap", Ap7)
if(any(Ap < 0)) error stop 'msis_driver:input_hdf5: Ap > 0'

call hf%shape("/glat", dims)
lx1 = int(dims(1))
lx2 = int(dims(2))
lx3 = int(dims(3))

allocate(glat(lx1,lx2,lx3), glon(lx1,lx2,lx3), alt(lx1,lx2,lx3))

call hf%read("/glat", glat)
call hf%read("/glon", glon)
call hf%read("/alt", alt)

call hf%close()

! print *, 'TRACE: file input: doy,UTsec ', filename, doy,sec

end subroutine input_hdf5


subroutine output_hdf5(filename, doy, sec, alt, glat, glon, Dn, Tn, msis_version)

character(*), intent(in) :: filename
real(real32), intent(in) :: doy, sec
real(real32), intent(in), dimension(:,:,:) :: alt, glat, glon
real(real32), intent(in), dimension(:,:,:,:) :: Dn, Tn
integer, intent(in) :: msis_version

type(hdf5_file) :: hf

call hf%open(filename, action="w", comp_lvl=comp_lvl)

!> echo back inputs to help dbugging
call hf%write("/msis_version", msis_version)
call hf%write("/doy", doy)
call hf%write("/UTsec", sec)
call hf%write("/alt", alt)
call hf%write("/glat", glat)
call hf%write("/glon", glon)

call hf%write("/nHe", Dn(:,:,:,1))
call hf%write("/nO", Dn(:,:,:,2))
call hf%write("/nN2", Dn(:,:,:,3))
call hf%write("/nO2", Dn(:,:,:,4))
call hf%write("/nAr", Dn(:,:,:,5))
call hf%write("/TotalMassDensity", Dn(:,:,:,6))
call hf%write("/nH", Dn(:,:,:,7))
call hf%write("/nN", Dn(:,:,:,8))
call hf%write("/nOana", Dn(:,:,:,9))

call hf%write("/Tn", Tn(:,:,:,2))
call hf%write("/Texo", Tn(:,:,:,1))

call hf%close()

end subroutine output_hdf5


! ------- below not used anymore

subroutine output_text(filename, alt, Dn, Tn)

character(*), intent(in) :: filename
real(real32), intent(in) :: alt(:), Dn(:,:), Tn(:,:)
logical :: pipe

pipe = filename == '-'

if (pipe) then
  u = stdout
else
  open(newunit=u, file=outfile, status='replace',action='write')
endif

do i = 1,size(alt)
  write(u,'(F9.2, 9ES15.6, F9.2)') alt(i), Dn(i,:), Tn(i,2)
end do

if (outfile /= '-') close(u)

end subroutine output_text


subroutine input_text(filename, doy,sec,f107a,f107,apday,ap3, glat, glon, alt)

character(*), intent(in) :: filename
real(real32), intent(out) :: doy,sec,f107a,f107,apday,ap3
real(real32), intent(out), allocatable :: glat(:),glon(:),alt(:)

integer :: u, i, lz

if(filename == "-") then
  u = stdin
else
  open(newunit=u, file=filename, status="old", action="read")
endif

read(u, *, iostat=i) doy
if (i/=0) error stop "doy: day of year (1..366)"
read(u, *, iostat=i) sec
if (i/=0) error stop "sec: seconds since UTC midnight"
read(u, *, iostat=i) f107a, f107, apday, ap3
if (i/=0) error stop "expecting: f107a, f107, apday, ap3"
read(u, *, iostat=i) lz
if (i/=0) error stop "lz: expecting integer number of altitudes"

call check_lz(lz)
allocate(glat(lz),glon(lz),alt(lz))
read(u,*, iostat=i) glat
if (i/=0)then
  write(stderr,*) 'read iostat', i
  error stop "glat: ran out of input elements unexpectedly"
endif

read(u,*, iostat=i) glon
if (i/=0) then
  write(stderr,*) 'read iostat', i
  error stop "glon: ran out of input elements unexpectedly"
endif
read(u,*, iostat=i) alt
if (i/=0) error stop "alt: ran out of input elements unexpectedly"

if (filename /= "-") close(u)

end subroutine input_text


subroutine check_lz(lz)

integer, intent(in) :: lz
character(256) :: buf
integer :: i

if (lz < 1) error stop 'lz must be positive'

call get_command_argument(4, buf, status=i)
if (i==0) then
  read(buf, *) i
  if (i /= lz) then
    write(stderr,*) 'expected ',i,' grid points but read ',lz
    error stop
  endif
endif

end subroutine check_lz


end program
