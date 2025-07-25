;$Author: nikos $
;$Date: 2021-02-21 18:49:50 -0800 (Sun, 21 Feb 2021) $
;$Header: /home/cdaweb/dev/control/RCS/angadj.pro,v 1.3 2012/05/03 16:12:52 johnson Exp johnson $
;$Locker: johnson $
;$Revision: 29691 $
; NAME:  ANGADJ.PRO 
;
; PURPOSE: computes angle between the geographic and geomagnetic coordinates
;          by which the radar vector should be rotated.
;
; CALLING SEQUENCE:
;       angadj,mltin,iyr,mlats,mlons,malts
;
; INPUT:
;       mltin - coordinate control variable  0 - ECC; 1 - AACGC; 2 - GEOG
;       iyr   - year (1965 > y > 2000)
;       mlats - latitude
;       mlons - longitude       
;       malts - altitude
;  
; OUTPUT:
;       rot - rotation angle
;
; SET VARIABLE:
;       irot  - direction of rotation 0 - geo2gmt  1 - gmt2geo
;       delta - increment used in angle calculation
;
;Copyright 1996-2013 United States Government as represented by the 
;Administrator of the National Aeronautics and Space Administration. 
;All Rights Reserved.
;
;------------------------------------------------------------------

function angadj,mltin,iyr,lat,lon,alt
  
   zero=0
   one =1
   delta=1.0
   irot=fix(one)
   dr=3.1415927/180.
   ierr=fix(zero)

   if(mltin eq 0 or mltin eq 1) then begin
     if(mltin eq 1) then begin
        lat1=lat
        lon1=lon+delta

      opos=cnvcoord(lat,lon,alt,/GEO)
      opos1=cnvcoord(lat1,lon1,alt,/GEO)

      a=(abs(opos1[0]-opos[0]))*dr
      b=(abs(opos1[1]-opos[1]))*dr
      rot=(atan(a,b))/dr
     endif
     if(mltin eq 0) then begin
        lat1=lat
        lon1=lon+delta
      
        err = call_external('LIB_PGM.so',$
                'coodecc_idl',lat,lon,alt,iyr,irot,ierr)
        err = call_external('LIB_PGM.so',$
                'coodecc_idl',lat1,lon1,alt,iyr,irot,ierr)

        a=(abs(lat1-lat))*dr
        b=(abs(lon1-lon))*dr
        rot=(atan(a,b))/dr

     endif
   endif else begin
     rot=0.0
   endelse 
 
return, rot
end 
