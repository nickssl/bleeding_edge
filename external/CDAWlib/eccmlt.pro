;$Author: nikos $
;$Date: 2021-02-21 18:49:50 -0800 (Sun, 21 Feb 2021) $
;$Header: /home/cdaweb/dev/control/RCS/eccmlt.pro,v 1.2 1996/08/09 18:28:21 kovalick Exp johnson $
;$Locker: johnson $
;$Revision: 29691 $
;------------------------------------------------------------------
;+
; NAME:
;       ECCMLT  
;
; PURPOSE:
;       Convert coordinates from geographic to geomagnetic and computes
;       eccentric dipole MLT 
;
;       calling sequence:
;
;       pos = eccmlt(year,doy,sod,r,lat,lon)
;
;
;Copyright 1996-2013 United States Government as represented by the 
;Administrator of the National Aeronautics and Space Administration. 
;All Rights Reserved.
;
;------------------------------------------------------------------
function eccmlt,year,doy,sod,r,lat,lon 
;
        ierr=0
        outpos=fltarr(3)
        year=fix(year)
        ierr = call_external('LIB_PGM.so','L_mlat_mlt_idl',$
              year,doy,sod,r,lat,lon,outpos,ierr)
        return,outpos
        end
