;$Author: nikos $
;$Date: 2021-02-21 18:49:50 -0800 (Sun, 21 Feb 2021) $
;$Header: /home/cdaweb/dev/control/RCS/encode_CDFEPOCH.pro,v 1.7 2012/02/07 17:24:12 kovalick Exp johnson $
;$Locker: johnson $
;$Revision: 29691 $
;+------------------------------------------------------------------------
; NAME: ENCODE_CDFEPOCH
; PURPOSE: 
;	Convert a 'yyyy/mm/dd hh:mm:ss' string into CDF epoch time
; CALLING SEQUENCE:
;	e = encode_cdfepoch(instring)
; INPUTS:
;       instring = string in the form: 'yyyy/mm/dd hh:mm:ss'
; KEYWORD PARAMETERS:
;       epoch16 - if set, the value returned is double complex epoch16
;                 value
;       tt2000 - if set, the value returned is a 8 byte integer tt200
;                value
;
;                 if not set, return the usual epoch double value
; OUTPUTS:
;       e = CDF epoch timetag (i.e. DOUBLE, millisecs since 0 A.D.)
;       if /epoch16 set, return an epoch16 value which is a double
;       complex.  Newly supported in IDL6.3 and CDF3.1 - added here
;       by TJK on 7/19/2006.
;       if /tt2000 is set, return a tt2000 value which is an 8 byte
;       int.  Newly support in CDF3.3.3 to support leap seconds...
;       by TJK 8/22/2011.
;
;
; AUTHOR:
;       Richard Burley, NASA/GSFC/Code 632.0, Feb 13, 1996
;       burley@nssdca.gsfc.nasa.gov    (301)286-2864
; MODIFICATION HISTORY:
;       8/20/96  : R. Burley     : Modify so that input parameter is not
;                                : changed by this function. 
;
;Copyright 1996-2013 United States Government as represented by the 
;Administrator of the National Aeronautics and Space Administration. 
;All Rights Reserved.
;
;------------------------------------------------------------------
;
FUNCTION encode_CDFEPOCH, instring,EPOCH16=epoch16, TT2000=tt2000, $
MSEC= MSEC, USEC= USEC, NSEC=NSEC, PSEC=PSEC

; Convert the yyyy/mm/dd hh:mm:ss string into a CDF Epoch time
estr = strtrim(instring,2) ; trim any leading and trailing whitespace
; Define punctuation marks to be searched for
Punctuation = [44B,45B,46B,47B,58B,59B] ; (i.e. ",-./:;")
a=0 & reads,estr,a,FORMAT='(I)' ; read the year field from the string
s = strpos(estr,'/',0) & estr = strmid(estr,s+1,20) ; reposition after '/'
b=0 & reads,estr,b,FORMAT='(I)' ; read the month field form the string
s = strpos(estr,'/',0) & estr = strmid(estr,s+1,20) ; reposition after '/'
c=0 & reads,estr,c,FORMAT='(I)' ; read the day field from the string
s = strpos(estr,' ',0) & estr = strmid(estr,s+1,20) ; reposition after ' '
d=0 & reads,estr,d,FORMAT='(I)' ; read the hour field from the string
s = strpos(estr,':',0) & estr = strmid(estr,s+1,20) ; reposition after ':'
e=0 & reads,estr,e,FORMAT='(I)' ; read the minute field from the string
s = strpos(estr,':',0) & estr = strmid(estr,s+1,20) ; reposition after ':'
f=0 & reads,estr,f,FORMAT='(I)' ; read the sec field from the string
; Perform TBD validation
;TJK 7/21/2006 add resolution keywords now supported in CDF3.1 and IDL6.3
;  msec=0 & usec = 0 & nsec = 0 & psec = 0 ; RCJ 08/06/2007 commented out
  if (keyword_set(MSEC)) then msec = fix(MSEC) else msec = 0
  if (keyword_set(USEC)) then usec = fix(USEC) else usec = 0
  if (keyword_set(NSEC)) then nsec = fix(NSEC) else nsec = 0
  if (keyword_set(PSEC)) then psec = fix(PSEC) else psec = 0

;TJK 7/21/2006 check for EPOCH16 and IDL version before making call
if ((!version.release ge '6.2') and keyword_set(EPOCH16)) then begin
;initialize values 
  CDF_EPOCH16,etime,a,b,c,d,e,f,msec, usec, nsec, psec, /COMPUTE_EPOCH
endif else begin
   if (keyword_set(TT2000)) then begin
      CDF_TT2000,etime,a,b,c,d,e,f,msec, usec, nsec, /COMPUTE
   endif else begin
    CDF_EPOCH,etime,a,b,c,d,e,f,msec,/COMPUTE_EPOCH
   endelse
endelse
return,etime
end

