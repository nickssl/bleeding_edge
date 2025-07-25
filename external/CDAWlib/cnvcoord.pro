;$Author: nikos $
;$Date: 2021-02-21 18:49:50 -0800 (Sun, 21 Feb 2021) $
;$Header: /home/cdaweb/dev/control/RCS/cnvcoord.pro,v 1.2 1996/08/09 17:11:47 kovalick Exp johnson $
;$Locker: johnson $
;$Revision: 29691 $
;
;Copyright 1996-2013 United States Government as represented by the 
;Administrator of the National Aeronautics and Space Administration. 
;All Rights Reserved.
;
;------------------------------------------------------------------
;+
; NAME:
;	CNVCOORD
;
; PURPOSE:
;	Convert coordinates from geographic to PACE magnetic or
;	from PACE magnetic to geographic
;
;	calling sequence:
;	  pos = cnvcoord(inpos,[inlong],[height],[/GEO])
;	     the routine can be called either with a 3-element floating
;	     point array giving the input latitude, longitude and height
;	     or it can be called with 3 separate floating point values
;	     giving the same inputs.  The default conversion is from
;	     geographic to PACE geomagnetic coordinates.  If the keyword
;	     GEO is set (/GEO) then the conversion is from magnetic to
;	     geographic.
;
;----------------------------------------------------------------------------
function cnvcoord, in1, in2, in3, geo = geo
;
	if (keyword_set(geo)) then mgflag = 2 else mgflag = 1
        if (n_params() GE 3) then inp = float([in1,in2,in3]) $
		else inp = float(in1)
        if (n_elements(inp) NE 3) then begin
          print,'input position must be fltarr(3) [lat,long,height]'
          return,[0,0,0]
          end
	order=4
	err=0
	outpos=fltarr(3)
	err = call_external('LIB_PGM.so',$
		'cnvcoord_idl',inp,order,outpos,mgflag,err)
	return,outpos
	end
