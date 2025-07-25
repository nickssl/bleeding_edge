;$Author: nikos $
;$Date: 2021-02-21 18:49:50 -0800 (Sun, 21 Feb 2021) $
;$Header: /home/cdaweb/dev/control/RCS/restore_mystruct.pro,v 1.3 2012/11/01 16:44:44 johnson Exp johnson $
;$Locker: johnson $
;$Revision: 29691 $
;
;Copyright 1996-2013 United States Government as represented by the 
;Administrator of the National Aeronautics and Space Administration. 
;All Rights Reserved.
;
;------------------------------------------------------------------

FUNCTION restore_mystruct,fname

; declare variables which exist at top level
COMMON CDFmySHARE, v0  ,v1, v2, v3, v4, v5, v6, v7, v8, v9,$
                   v10,v11,v12,v13,v14,v15,v16,v17,v18,v19,v20

; Use the IDL restore feature to reconstruct the anonymous structure a
RESTORE,FILENAME=fname
; The anonymous structure should now be in the variable 'a'.  Determine
; if the structure contains .DAT or .HANDLE fields

sz=size(a)
if sz[n_elements(sz)-2] eq 0 then begin
    print,'Looking for structure a but it is undefined. Perhaps this sav file was not generated by cdfx.'
    return,-1
endif
if sz[n_elements(sz)-2] ne 8 then begin
    print,'a is not a structure. Perhaps this sav file was not generated by cdfx.'
    return,-1
endif

ti = tagindex('HANDLE',tag_names(a.(0)))
if ti ne -1 then begin
  tn = tag_names(a) 
  nt = n_elements(tn) ; determine number of variables
  for i=0,nt-1 do begin
    a.(i).HANDLE = handle_create()
    order = 'handle_value,a.(i).HANDLE,v' + strtrim(string(i),2) + ',/SET'
    status = EXECUTE(order)
  endfor
endif
return,a
end
