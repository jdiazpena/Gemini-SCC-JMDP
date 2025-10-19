import xarray
import numpy as np


def fac(E: xarray.Dataset, gridflag: int, flagdip: bool) -> xarray.Dataset:
    """
    for 3D sim, FAC up/down 0.5 degree FWHM
    """

    if E.mlon.size == 1 or E.mlat.size == 1:
        raise ValueError("for 3D sims only")

    # nonuniform in longitude
    beta=0.15
    T=1/42
    f=E.mlon-E.mlonmean
    shapelon=0*f

    for i in range(len(f)):
        if abs(f[i])<(1-beta)/(2*T):
            shapelon[i]=1
        elif (1-beta)/(2*T)<abs(f[i]) and abs(f[i])<(1+beta)/(2*T):
            shapelon[i]=0.5*(1+np.cos( (np.pi*T/beta)*(abs(f[i])-(1-beta)/(2*T)) ))
        else:
            shapelon[i]=0


    # nonuniform in latitude
    shapelat = -1.0*np.exp(
        -((E.mlat - E.mlatmean - 1.5 * E.mlatsig) ** 2) / 2 / E.mlatsig ** 2
    ) + 1.0*np.exp(-((E.mlat - E.mlatmean + 1.5 * E.mlatsig) ** 2) / 2 / E.mlatsig ** 2)

    for t in E.time[2:]:
        E["flagdirich"].loc[t] = 0

        k = "Vminx1it" if gridflag == 1 else "Vmaxx1it"
        E[k].loc[t] = E.Jtarg * shapelon * shapelat

    return E
