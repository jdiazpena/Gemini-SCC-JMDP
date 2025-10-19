import numpy as np
import xarray


def Esaid(pg: xarray.Dataset, Epeak: float, Ebackground: float) -> xarray.Dataset:
    mlon_mean = pg.mlon.mean().item()
    mlat_mean = pg.mlat.mean().item()

    beta=0.15
    T=1/42
    f=pg.mlon.data[:, None] - mlon_mean
    shapelon=0*f

    for i in range(np.size(f,0)):
        if abs(f[i])<(1-beta)/(2*T):
            shapelon[i]=1
        elif (1-beta)/(2*T)<abs(f[i]) and abs(f[i])<(1+beta)/(2*T):
            shapelon[i]=0.5*(1+np.cos( (np.pi*T/beta)*(abs(f[i])-(1-beta)/(2*T)) ))
        else:
            shapelon[i]=0



    if "mlat_sigma" in pg.attrs:
        shapelat = np.exp(
            -((pg.mlat.data[None, :] - mlat_mean - 8.65 * pg.mlat_sigma) ** 2) / (2 * pg.mlat_sigma**2)
        )
    else:
        raise LookupError("precipation must be defined in latitude, longitude or both")
    
    E=Epeak*shapelon*shapelat

    E[E < Ebackground] = Ebackground

    return E
