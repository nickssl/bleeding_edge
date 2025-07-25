;$Author: nikos $
;$Date: 2022-09-23 18:16:23 -0700 (Fri, 23 Sep 2022) $
; /home/rumba/cdaweb/dev/control/RCS/virtual_funcs.pro,v 1.0 
;$Locker: rcjohns1 $
;$Revision: 31135 $
;
;Copyright 1996-2013 United States Government as represented by the 
;Administrator of the National Aeronautics and Space Administration. 
;All Rights Reserved.
;
;------------------------------------------------------------------

compile_opt idl2


;+
;
; NAME: Function VTYPE_NAMES
;
; PURPOSE: Returns array of names or index numbers where the var_type is
;          equal to vtype (eg."data").
;

function vtype_names, buf, vtype, NAMES=vNAMES

  tagnames = tag_names(buf)
  tagnums = n_tags(buf)
  vnames=strarr(tagnums)
  vindices=intarr(tagnums)
; Determine names and indices
   ii=0
   for i=0, tagnums-1 do begin
    tagnames1=tag_names(buf.(i))
    if(tagindex('VAR_TYPE', tagnames1) ge 0) then begin
;upcase both sides in case there's mixed case
;        if(buf.(i).VAR_TYPE eq vtype) then begin
        if(strupcase(buf.(i).VAR_TYPE) eq strupcase(vtype)) then begin
        ;if(buf.(i).VAR_TYPE eq 'data') then begin
           vnames[ii]=tagnames[i]
           ;vindices(ii)=i
           vindices[ii]=i
           ii=ii+1
        endif
    endif
   endfor

   wc=where(vnames ne '',wcn)
   if(wc[0] lt 0) then begin
    vnames[0]=wc
    vindices[0]=wc
   endif else begin
    vnames=vnames[wc]
    vindices=vindices[wc]
   endelse

;Jan. 6, 2003 - TJK added the "or (n_elements..." below because in IDL 5.6 
;if the NAMES keyword is set as "" in the calling routine, IDL doesn't think
;the keyword is set (as it does in previous IDL versions).

;if(keyword_set(NAMES) or (n_elements(names) gt 0)) then begin
;	NAMES=vnames
;endif
return, vindices
end

;+
;
; NAME: Function Trap 
;
; PURPOSE: Trap malformed idl structures or invalid arguments. 
;
; INPUT;  a   an idl structure

function buf_trap, a 

  ibad=0
  str_tst=size(a)
  if(str_tst[str_tst[0]+1] ne 8) then begin
    ibad=1
    v_data='DATASET=UNDEFINED'
    v_err='ERROR=a'+strtrim(string(i),2)+' not a structure.'
    v_stat='STATUS=Cannot plot this data'
    a=create_struct('DATASET',v_data,'ERROR',v_err,'STATUS',v_stat)
  endif else begin
; Test for errors trapped in conv_map_image
   atags=tag_names(a)
   rflag=tagindex('DATASET',atags)
   if(rflag[0] ne -1) then ibad=1
  endelse

return, ibad
end

;+
;
; NAME: Function VV_NAMES
;
; PURPOSE: Returns array of virtual variable names or index numbers.
;

function vv_names, buf, NAMES=NAMES

  tagnames = tag_names(buf)
  tagnums = n_tags(buf)
  vnames=strarr(tagnums)
  vindices=intarr(tagnums)
; Determine names and indices
   ii=0
   for i=0, tagnums-1 do begin
    tagnames1=tag_names(buf.(i))
    if(tagindex('VIRTUAL', tagnames1) ge 0) then begin
        if(buf.(i).VIRTUAL) then begin
           vnames[ii]=tagnames[i]
           vindices[ii]=i
           ii=ii+1
        endif
    endif
   endfor
   wc=where(vnames ne '',wcn)
   if(wc[0] lt 0) then begin
    vnames[0]=wc
    vindices[0]=wc
   endif else begin
    vnames=vnames[wc]
    vindices=vindices[wc]
   endelse
 
;TJK IDL6.1 doesn't recognize this keyword as being set since
;its defined as a strarr(1)...
;if(keyword_set(NAMES)) then NAMES=vnames
if(n_elements(NAMES)) then begin
NAMES=vnames
endif
return, vindices 
end
;-----------------------------------------------------------------------------
;+
; NAME: Function CHECK_MYVARTYPE
;
; PURPOSE:
; Check that all variables in the original variable list are declared as
; data otherwise set to ignore_data
; Find variables w/ var_type == data
;
; CALLING SEQUENCE:
;
;          status = check_myvartype(buf,org_names)
;
; VARIABLES:
;
; Input:
;  buf        - an IDL structure built w/in read_myCDF
;  org_names  - list of original variables input to read_myCDF. Any
;               variables in this list will remain tagged as
;               VAR_TYPE= data otherwise VAR_TYPE = metadata.
;
; Output:
;  buf    - an IDL structure containing the populated virtual
;               variables
;  status - 0 ok else failed
; 
; Keyword Parameters:
;
;
; REQUIRED PROCEDURES:
;
function check_myvartype, nbuf, org_names
   status=0
   var_names=strarr(1)
   var_indices = vtype_names(nbuf,'data',NAMES=var_names)
   if(var_indices[0] lt 0) then begin
     print, "STATUS= No variable of type DATA detected."
     print, "ERROR= No var_type=DATA variable found in check_myvartype.pro"
     print, "ERROR= Message: ",var_indices[0]
     status = -1
     return, status
   endif
   org_names=strupcase(org_names)
   
   ; RCJ 08/29/2012   Let's find all 'components'. We'll need this list below.
   compnames=[''] 
   for i=0, n_elements(var_indices)-1 do begin
      tnames=tag_names(nbuf.(i))
      for k=0,n_elements(tnames)-1 do begin
         pos = strpos(tnames[k],'COMPONENT_')
         if (pos eq 0) then compnames=[compnames,nbuf.(var_indices[i]).(k)]
      endfor
   endfor   
     
   for i=0, n_elements(var_indices)-1 do begin
      wc=where(org_names eq var_names[i],wcn)
      if(wc[0] lt 0) then begin  ; this is not the originally requested var.
     ;   print,'***** not requested, make support_data : ',var_names[i]
        nbuf.(var_indices[i]).var_type = 'support_data'
        ;
        wc1=where(strupcase(compnames) eq var_names[i])
        if (wc1[0] ne -1) then nbuf.(var_indices[i]).var_type='additional_data'
    ;    if (wc1[0] ne -1) then print,'********** and a component, make additional_data: ',nbuf.(var_indices[i]).varname
      endif
   endfor   
   ;  Old logic: (RCJ 08/29/2012)
   ;
   ; RCJ 01/23/2007  depend_0s is to be used if one of the vars
   ; becomes additional or ignore_data
;   depend_0s=''
;   for i=0,n_elements(tag_names(nbuf))-1 do begin
;      depend_0s=[depend_0s,nbuf.(i).depend_0]
;   endfor
;   depend_0s=depend_0s[1:*]
;   ; RCJ 11/09/2007  Added same thing for depend_1's
;   depend_1s=''
;   for i=0,n_elements(tag_names(nbuf))-1 do begin
;      if (tagindex('DEPEND_1',tag_names(nbuf.(i))) ge 0) then $
;      depend_1s=[depend_1s,nbuf.(i).depend_1]
;   endfor
;   if n_elements(depend_1s) gt 1 then depend_1s=depend_1s[1:*]
   ;
       ; we don't want the var to be ignored in case we are going to write a cdf,
       ; but we also don't want the var listed/plotted, so turn it into a
       ; 'additional_data'.
      ; if ((nbuf.(var_indices(i)).var_type eq 'data') or $
      ;  (nbuf.(var_indices(i)).var_type eq 'support_data')) then $
      ;   nbuf.(var_indices(i)).var_type = 'additional_data' else $
      ;   nbuf.(var_indices(i)).var_type='ignore_data'
      ; if ((nbuf.(var_indices(i)).var_type eq 'additional_data') or $
      ;  (nbuf.(var_indices(i)).var_type eq 'ignore_data')) then begin
      ;	  if nbuf.(var_indices(i)).depend_0 ne '' then begin
      ;       q=where(depend_0s eq nbuf.(var_indices(i)).depend_0)
      ;       if n_elements(q) eq 1 then $
      ;	        s=execute("nbuf."+nbuf.(var_indices(i)).depend_0+".var_type='additional_data'")
      ;    endif	
      ;       if nbuf.(var_indices(i)).depend_1 ne '' then begin
      ;       q=where(depend_1s eq nbuf.(var_indices(i)).depend_1)
      ;       if n_elements(q) eq 1 then $
      ;	        s=execute("nbuf."+nbuf.(var_indices(i)).depend_1+".var_type='additional_data'")
      ;    endif	
      ; endif	
       ; RCJ 07/14/2008  Now we do want the depends listed.
;       print,'*********** not requested: ', nbuf.(var_indices[i]).varname,'  ',nbuf.(var_indices[i]).var_type
;       if (nbuf.(var_indices[i]).var_type eq 'data')  then $
;         nbuf.(var_indices[i]).var_type='additional_data'
;       if (nbuf.(var_indices[i]).var_type eq 'additional_data') then begin
;      	  if nbuf.(var_indices[i]).depend_0 ne '' then begin
;                   q=where(depend_0s eq nbuf.(var_indices[i]).depend_0)
;                   if n_elements(q) eq 1 then $
;      	        s=execute("nbuf."+nbuf.(var_indices[i]).depend_0+".var_type='additional_data'")
;                endif	
;      	  if nbuf.(var_indices[i]).depend_1 ne '' then begin
;                   q=where(depend_1s eq nbuf.(var_indices[i]).depend_1)
;                   if n_elements(q) eq 1 then $
;      	        s=execute("nbuf."+nbuf.(var_indices[i]).depend_1+".var_type='additional_data'")
;          endif	
;      endif	
;
;    Even older logic:  (RCJ 08/29/2012)
;
    ;if(wc[0] lt 0) then nbuf.(var_indices[i]).var_type="ignore_data"
    ;if(wc[0] lt 0) then nbuf.(var_indices[i]).var_type="metadata"   

return, status
end

;+
; NAME: Function ALTERNATE_VIEW
;
; PURPOSE: Find virtual variables and replace their data w/ the component0
;          data 
;
; CALLING SEQUENCE:
;
;          new_buf = alternate_view(buf,org_names)
;
; VARIABLES:
;
; Input:
;
;  buf        - an IDL structure built w/in read_myCDF
;  org_names  - list of original variables input to read_myCDF. Any
;               variables in this list will remain tagged as 
;               VAR_TYPE= data otherwise VAR_TYPE = support_data.
;
; Output:
;
;  new_buf    - an IDL structure containing the populated virtual 
;               variable 
;  
; Keyword Parameters: 
;
;
; REQUIRED PROCEDURES:
;
;   none
;
;-------------------------------------------------------------------
; History
;
;         1.0  R. Baldwin  HSTX     1/6/98 
;		Initial version
;
;-------------------------------------------------------------------

function alternate_view, buf,org_names,flip_vert=flip_vert

status=0

; Establish error handler
  catch, error_status
  if(error_status ne 0) then begin
   print, "ERROR= number: ",error_status," in alternate_view"
   print, "ERROR= Message: ",!ERR_STRING
   status = -1
   return, status
  endif

; Find virtual variables
   vvtag_names=strarr(1) 
   vvtag_indices = vv_names(buf,NAMES=vvtag_names)
   if(vvtag_indices[0] lt 0) then begin
     print, "ERROR= No VIRTUAL variable found in alternate_view"
     print, "ERROR= Message: ",vvtag_indices[0]
     status = -1
     return, status
   endif

   tagnames = tag_names(buf)
   tagnums = n_tags(buf)

for i=0, n_elements(vvtag_indices)-1 do begin
  ;    variable_name=arrayof_vvtags(i) 
  ;    tag_index = tagindex(variable_name, tagnames)

  tagnames1=tag_names(buf.(vvtag_indices[i]))

  ;now look for the COMPONENT_0 attribute tag for this VV.
  ;TJK had to change to check for 'ge 0', otherwise it wasn't true...

  if(tagindex('COMPONENT_0', tagnames1) ge 0) then $
              component0=buf.(vvtag_indices[i]).COMPONENT_0

  ; Check if the component0 variable exists 

  component0_index = tagindex(component0,tagnames)

  ;print, buf.(vvtag_indices[i]).handle 
  vartags = tag_names(buf.(vvtag_indices[i]))

  ;11/5/04 - TJK - had to change FUNCTION to FUNCT for IDL6.* compatibility
  ;    findex = tagindex('FUNCTION', vartags) ; find the FUNCTION index number
  findex = tagindex('FUNCT', vartags) ; find the FUNCTION index number
  if (findex[0] ne -1) then func_name=strlowcase(buf.(vvtag_indices[i]).(findex[0]))
  
  ; Loop through all vv's and assign image handle to all w/ 0 handles RTB 12/98
  ; Check if handle = 0 and if function = 'alternate_view'
  ;if(func_name eq 'alternate_view') then begin
  if ((func_name eq 'alternate_view') or (func_name eq 'alternate_view_flip_vert')) then begin
    ;print, func_name 
    ;print, vvtag_names[i]
    if(component0_index ge 0) then begin
      ; WARNING if /NODATASTRUCT keyword not set an error will occur here
      ;TJK - changed this from tagnames to tagnames1
      if(tagindex('HANDLE',tagnames1) ge 0) then begin
        if keyword_set(flip_vert) then begin
          handle_value,buf.(component0_index).HANDLE,img
	  flipimg=img ;  placeholder. images will be flipped
	  im_size=size(img)
          if im_size[0] eq 3 then imgs=im_size[3] else imgs=1
          for j=0,imgs-1 do begin
            flipimg[*,*,j]= reverse(img[*,*,j])
          endfor
          buf.(vvtag_indices[i]).HANDLE=handle_create(value=flipimg)
	endif else $
          buf.(vvtag_indices[i]).HANDLE=buf.(component0_index).HANDLE 
      endif else print, "Set /NODATASTRUCT keyword in call to read_myCDF";
    endif else begin
     print, "ERROR= No COMPONENT0 variable found in alternate_view"
     print, "ERROR= Message: ",component0_index
     status = -1
     return, status
    endelse 
  endif
  ;print, buf.(vvtag_indices[i]).handle 
endfor

; Check that all variables in the original variable list are declared as
; data otherwise set to support_data
; Find variables w/ var_type == data

   status = check_myvartype(buf, org_names)

return, buf
end

;------------------------------------------------------------------------
;+
; NAME: Function CLAMP_TO_ZERO
;
; PURPOSE: Clamp all values less than or equal to 'clamp_threshold' to zero. 
;
; CALLING SEQUENCE:
;
;          new_buf = clamp_to_zero(buf,org_names)
;
; VARIABLES:
;
; Input:
;
;  buf        - an IDL structure built w/in read_myCDF
;  org_names  - list of original variables input to read_myCDF. Any
;               variables in this list will remain tagged as 
;               VAR_TYPE= data otherwise VAR_TYPE = support_data.
;
; Output:
;
;  new_buf    - an IDL structure containing the populated virtual 
;               variable 
;  
; Keyword Parameters: 
;
;
; REQUIRED PROCEDURES:
;
;   none
;
; History: Written by Ron Yurow 08/15, based on alternate_view
;-

function clamp_to_zero, buf, org_names, index=index

status=0

; Establish error handler
  catch, error_status
  if(error_status ne 0) then begin
   print, "ERROR= number: ",error_status," in clamp_to_zero"
   print, "ERROR= Message: ",!ERR_STRING
   status = -1
   return, status
  endif

   tagnames = tag_names(buf)
   tagnums = n_tags(buf)

;   for i=0, n_elements(vvtag_indices)-1 do begin
;    variable_name=arrayof_vvtags(i) 
;    tag_index = tagindex(variable_name, tagnames)

   tagnames1 = tag_names (buf.(index))

; now look for the COMPONENT_0 attribute tag for this VV.

    component0_index = !NULL

    if  (tagindex('COMPONENT_0', tagnames1) ge 0) then begin

         component0 = buf.(index).COMPONENT_0

; Get the index of the component 0 variable. 

         component0_index = tagindex (component0, tagnames)

    endif

; and look for the COMPONENT_1 attribute tag for this VV.

    component1_index = !NULL

    if  (tagindex('COMPONENT_1', tagnames1) ge 0) then begin

        component1 = buf.(index).COMPONENT_1

; Get the index of the component 1 variable.

        component1_index = tagindex (component1, tagnames)

    endif

; and get the fill value 

    fillval = !NULL 

    if  (tagindex('FILLVAL', tagnames1) ge 0) then begin

        fillval = buf.(index).FILLVAL

    endif

    if  (component0_index ne !NULL && component1_index ne !NULL) then begin

; WARNING if /NODATASTRUCT keyword not set an error will occur here
        if  (tagindex ('HANDLE', tagnames1) ge 0) then begin

             handle_value, buf.(component0_index).handle, mydata

             handle_value, buf.(component1_index).handle, limit

             ; find values less then the threshold limit
             clamp = WHERE (mydata le limit, cnt)

             ; Make sure we have some values to clamp
             IF  cnt gt 0 THEN BEGIN

                 ; Select all of the elements that fulfill the clamp the criteria
                 ; but which are not set FILLVAL
                 notfv = WHERE (mydata [clamp] ne fillval, /NULL) 

                 ; Clamp to zero!!
                 mydata [clamp [notfv]] = 0.D
                                             
             ENDIF
                 
                 buf.(index).HANDLE = handle_create ()
                 HANDLE_VALUE, buf.(index).HANDLE, mydata, /SET

        ENDIF ELSE BEGIN

            print, "Set /NODATASTRUCT keyword in call to read_myCDF";

        ENDELSE

    ENDIF ELSE BEGIN

        print, "ERROR= No COMPONENT0 variable found in clamp_to_zero"
        print, "ERROR= Message: ",component0_index
        status = -1

        RETURN, status
   ENDELSE

; Check that all variables in the original variable list are declared as
; data otherwise set to support_data
; Find variables w/ var_type == data

   status = check_myvartype (buf, org_names)

RETURN, buf
end

;+
; NAME: Function COMPOSITE_TBL
;
; PURPOSE: Create a variable that is a composite of of multiple variables. 
;
; CALLING SEQUENCE:
;
;          new_buf = composite_tbl(buf,org_names)
;
; VARIABLES:
;
; Input:
;
;  buf        - an IDL structure built w/in read_myCDF
;  org_names  - list of original variables input to read_myCDF. Any
;               variables in this list will remain tagged as 
;               VAR_TYPE= data otherwise VAR_TYPE = support_data.
;
; Output:
;
;  new_buf    - an IDL structure containing the populated virtual 
;               variable 
;  
; Keyword Parameters: 
;
;
; REQUIRED PROCEDURES:
;
;   none
;
; History: Written by Ron Yurow 08/15, based on alternate_view
;-

function composite_tbl, buf, org_names, index=index

status=0

; Establish error handler
  catch, error_status
  if(error_status ne 0) then begin
   print, "ERROR= number: ",error_status," in composite_tbl"
   print, "ERROR= Message: ",!ERR_STRING
   status = -1
   return, status
  endif

   tagnames = tag_names(buf)
   tagnums = n_tags(buf)

;   for i=0, n_elements(vvtag_indices)-1 do begin
;    variable_name=arrayof_vvtags(i) 
;    tag_index = tagindex(variable_name, tagnames)

   tagnames1 = tag_names (buf.(index))

; now look for the COMPONENT_0 attribute tag for this VV.

    component0_index = !NULL

    if  (tagindex('COMPONENT_0', tagnames1) ge 0) then begin

         component0 = buf.(index).COMPONENT_0

; Get the index of the component 0 variable. 

         component0_index = tagindex (component0, tagnames)

    endif

; and look for the COMPONENT_1 attribute tag for this VV.

    component1_index = !NULL

    if  (tagindex('COMPONENT_1', tagnames1) ge 0) then begin

        component1 = buf.(index).COMPONENT_1

; Get the index of the component 1 variable.

        component1_index = tagindex (component1, tagnames)

    endif

; and look for the COMPONENT_2 attribute tag for this VV.

    component2_index = !NULL

    if  (tagindex('COMPONENT_2', tagnames1) ge 0) then begin

        component2 = buf.(index).COMPONENT_2

; Get the index of the component 1 variable.

        component2_index = tagindex (component2, tagnames)

    endif

; and get the fill value 

    fillval = !NULL 

    if  (tagindex('FILLVAL', tagnames1) ge 0) then begin

        fillval = buf.(index).FILLVAL

    endif

    all_good = 1

    if  (component0_index eq !NULL) then all_good = 0
    if  (component1_index eq !NULL) then all_good = 0
    if  (component2_index eq !NULL) then all_good = 0
    

    if  (all_good) then begin

; WARNING if /NODATASTRUCT keyword not set an error will occur here
        if  (tagindex ('HANDLE', tagnames1) ge 0) then begin

             handle_value, buf.(component0_index).handle, indicator

             handle_value, buf.(component1_index).handle, v0

             handle_value, buf.(component2_index).handle, v1

             n_rec = N_ELEMENTS (indicator)

             v0dim = SIZE (v0, /DIMENSIONS)
             v1dim = SIZE (v1, /DIMENSIONS)

             IF  (~ ARRAY_EQUAL (v0dim, v1dim)) THEN BEGIN

                 print, "ERROR= COMPONENT1 variable must have same dimensions as COMPONENT2 variable."
                 status = -1

                 return, status

             ENDIF

             v0type = SIZE (v0, /TYPE)

             composite = INTARR (v0dim, N_ELEMENTS (indicator)) 

             composite = FIX (composite, TYPE = v0type)

             index0 = where (indicator eq 0, cnt0)

             index1 = where (indicator eq 1, cnt1)

             IF  (cnt0 gt 0) THEN FOR i = 0, cnt0 - 1 do composite [0, index0 [i]] = v0

             IF  (cnt1 gt 0) THEN FOR i = 0, cnt1 - 1 do composite [0, index1 [i]] = v1

             buf.(index).HANDLE = handle_create ()
             HANDLE_VALUE, buf.(index).HANDLE, composite, /SET                 

        ENDIF ELSE BEGIN

            print, "Set /NODATASTRUCT keyword in call to read_myCDF"

        ENDELSE

    ENDIF ELSE BEGIN

        print, "ERROR= Missing variables indicated by one of the following attributes: " + $
               "COMPONENT0, COMPONENT1, or COMPONENT2."
        status = -1

        RETURN, status
   ENDELSE

; Check that all variables in the original variable list are declared as
; data otherwise set to support_data
; Find variables w/ var_type == data

   status = check_myvartype (buf, org_names)

RETURN, buf
end

;+
; NAME: Function arr_slice
;
; PURPOSE: Create a variable by extracting a subset (slice) of a multidimensional array.  
;          Works on variables up to 7 dimensions. 
;
; DETAILED DESCRIPTION:
;
;          The arr_slice virtual function extracts a subarray of a multidimensional 
;          variable, in the processes reducing the dimensionality of the resultant 
;          data array by 1.  The dimensionality of the original data variable must be
;          at least 2. 
;
;          The arr_slice function requires that COMPONENT_0 vAttribute be set to source
;          data variable.  In addition, the following vAttributes are also required:  
;
;          ARR_INDEX:    Index into the requested dimension to extract the subarray from.
;          ARR_DIM:      The dimension of the source data variable to reduce.
;
;          All values are referenced from 0.
;
;          As an example suppose the variable TEST is a 10 x 10 Array.  Specifying an
;          ARR_INDEX of 4 and an ARR_DIM of 0 would result in a vector consisting of the
;          5th column of the array.  Likewise, specifying and ARR_INDEX of 0 and an
;          ARR_DIM of 1 would result in a vector consisting of the 1st row of the array.
;
;          The master fa_esa_l2_ies_00000000_v01 has been updated so that the variables
;          "pitch_angle_median" and "energy_median" now use this function.
;
;
; CALLING SEQUENCE:
;
;          new_buf = arr_slice (buf,org_names)
;
; VARIABLES:
;
; Input:
;
;  buf        - an IDL structure built w/in read_myCDF
;  org_names  - list of original variables input to read_myCDF. Any
;               variables in this list will remain tagged as 
;               VAR_TYPE= data otherwise VAR_TYPE = support_data.
;
; Output:
;
;  new_buf    - an IDL structure containing the populated virtual 
;               variable 
;  
; Keyword Parameters: 
;
;
; REQUIRED PROCEDURES:
;
;   none
;
; History: Written by Ron Yurow 05/16, based on alternate_view
;-

function arr_slice, buf, org_names, index=index

status=0

; Establish error handler
  catch, error_status
  if(error_status ne 0) then begin
   print, "ERROR= number: ",error_status," in ARR_SLICE"
   print, "ERROR= Message: ",!ERR_STRING
   status = -1
   return, status
  endif

   tagnames = tag_names(buf)
   tagnums = n_tags(buf)

;   for i=0, n_elements(vvtag_indices)-1 do begin
;    variable_name=arrayof_vvtags(i) 
;    tag_index = tagindex(variable_name, tagnames)

   tagnames1 = tag_names (buf.(index))

; now look for the COMPONENT_0 attribute tag for this VV.

   component0_index = !NULL

   if  (tagindex('COMPONENT_0', tagnames1) ge 0) then begin

       component0 = buf.(index).COMPONENT_0

; Get the index of the component 0 variable. 

       component0_index = tagindex (component0, tagnames)

   endif

   ; Get the index of the array slice we should extract 
   ind = !NULL

   v = tagindex (tagnames1, 'ARR_INDEX')

   IF  ( v  ne -1) THEN BEGIN
       ind = buf.(index).(v)
   ENDIF

   ; Get the dimension of the array we should reduce when extracting the slice
   dim = !NULL

   v = tagindex (tagnames1, 'ARR_DIM')

   IF  ( v  ne -1) THEN BEGIN
       dim = buf.(index).(v)
   ENDIF

; and get the fill value 

   fillval = !NULL 

   IF  (tagindex('FILLVAL', tagnames1) ge 0) THEN begin

       fillval = buf.(index).FILLVAL

   ENDIF

   all_good = 1

   IF  (component0_index eq !NULL) THEN all_good = 0
   IF  (ind eq !NULL) THEN all_good = 0  
   IF  (dim eq !NULL) THEN all_good = 0

   IF  (all_good) THEN BEGIN

; WARNING if /NODATASTRUCT keyword not set an error will occur here
       if  (tagindex ('HANDLE', tagnames1) ge 0) THEN BEGIN

            handle_value, buf.(component0_index).handle, src

            n_dim = N_ELEMENTS (buf.(component0_index).DIM_SIZES)

            dim_sizes = (SIZE (src, /DIMENSIONS)) [0:n_dim-1]

            ; Make sure we are not calling this on a one dimensional array
            IF  (n_dim lt 2) THEN BEGIN
                
                print, "ERROR= COMPONENT0 variable must have dimensionality greater than 1."

                status = -1

                RETURN, status

            END

            ; also can not exceed the number of dimensions of the source variable.
            IF  (dim gt n_dim - 1) THEN BEGIN
                
                print, "ERROR= Invalid dimension requestest from COMPONENT0 variable."

                status = -1

                RETURN, status

            END
            
            ; Check that ind selects a valid slice of the source array
            IF  (ind ge dim_sizes [dim] || ind lt 0) THEN BEGIN

                print, "ERROR=  Invalid index specified to select array slice from COMPONENT0" + $
                       " variable."

                status = -1

                RETURN, status

            ENDIF

            ; Brute force way of extracting the array slice, but easier than writing a 
            ; more general solution.
            CASE dim OF
               0: trg = REFORM (src [ind, *, *, *, *, *, *, *]) 
               1: trg = REFORM (src [*, ind, *, *, *, *, *, *]) 
               2: trg = REFORM (src [*, *, ind, *, *, *, *, *]) 
               3: trg = REFORM (src [*, *, *, ind, *, *, *, *]) 
               4: trg = REFORM (src [*, *, *, *, ind, *, *, *]) 
               5: trg = REFORM (src [*, *, *, *, *, ind, *, *]) 
               6: trg = REFORM (src [*, *, *, *, *, *, ind, *]) 


               ELSE: BEGIN
                  print, "ERROR= Invalid dimension requested from COMPONENT0 variable." 

                  status = -1

                  RETURN, status

               END

            ENDCASE

            buf.(index).HANDLE = handle_create ()
            HANDLE_VALUE, buf.(index).HANDLE, trg, /SET           

        ENDIF ELSE BEGIN

            print, "Set /NODATASTRUCT keyword in call to read_myCDF"

        ENDELSE

    ENDIF ELSE BEGIN

        print, "ERROR= Missing variable indicated by COMPONENT0 or other required " + $
               "attributes."

        status = -1

        RETURN, status
   ENDELSE

; Check that all variables in the original variable list are declared as
; data otherwise set to support_data
; Find variables w/ var_type == data

   status = check_myvartype (buf, org_names)

RETURN, buf
end

;+
; NAME: Function CROP_IMAGE
;
; PURPOSE: Crop [60,20,*] images into [20,20,*]
;
; CALLING SEQUENCE:
;
;          new_buf = crop_image(buf,org_names,index)
;
; VARIABLES:
;
; Input:
;
;  buf        - an IDL structure built w/in read_myCDF
;  org_names  - list of original variables input to read_myCDF. Any
;               variables in this list will remain tagged as 
;               VAR_TYPE= data otherwise VAR_TYPE = support_data.
;  index      - variable index, so we deal with one variable at a time.
;
; Output:
;
;  new_buf    - an IDL structure containing the populated virtual 
;               variable 
;
; History: Written by RCJ 12/00, based on alternate_view
;-

function crop_image, buf, org_names, index=index
status=0
;print, 'In Crop_image'
; Establish error handler
catch, error_status
if(error_status ne 0) then begin
   print, "ERROR= number: ",error_status," in crop_image"
   print, "ERROR= Message: ",!ERR_STRING
   status = -1
   return, status
endif

tagnames = tag_names(buf)
tagnames1=tag_names(buf.(index))
;now look for the COMPONENT_0 attribute tag for this VV.
if(tagindex('COMPONENT_0', tagnames1) ge 0) then $
   component0=buf.(index).COMPONENT_0
; Check if the component0 variable exists 
component0_index = tagindex(component0,tagnames)
; this line is useful if we are just replacing the old data w/ the new:
;buf.(index).HANDLE=buf.(component0_index).HANDLE
;handle_value,buf.(index).handle,img
handle_value,buf.(component0_index).handle,img
; Rick Burley says that from the original 60x20 image
; we need to extract a 20x20 image:
buf.(index).handle=handle_create()
handle_value,buf.(index).handle,img[19:38,*,*],/set
;
; RCJ 10/22/2003 If the image is being cropped then depend_1
; should also be cropped. Found this problem when trying to list the data,
; the number of depend_1s did not match the number of data columns.
if(tagindex('DEPEND_1', tagnames1) ge 0) then $
   depend1=buf.(index).DEPEND_1
; RCJ 05/16/2013  Good, but if alt_cdaweb_depend_1 exists, use it instead:
if(tagindex('ALT_CDAWEB_DEPEND_1', tagnames1) ge 0) then if (buf.(index).alt_cdaweb_depend_1 ne '') then $
   depend1=buf.(index).alt_cdaweb_depend_1
;
depend1_index = tagindex(depend1,tagnames)
handle_value,buf.(depend1_index).handle,sp
; RCJ 12/29/2003  Check to see if this depend_1 wasn't already cropped
; because of another variable which also uses this var as it's depend_1
if n_elements(sp) gt 20 then $
   handle_value,buf.(depend1_index).handle,sp[19:38],/set $
   else handle_value,buf.(depend1_index).handle,sp,/set ; no change

; Check that all variables in the original variable list are declared as
; data otherwise set to support_data
; Find variables w/ var_type == data

status = check_myvartype(buf, org_names)

return, buf
end

;+
; NAME: Function clean_data 
;
; pURPOSE: Remove data 3*sigma from mean 
;
; INPUT:
;
;    data          simple data array 
;
; KEYWORDS:
;    FILLVAL       the fill value to be used to replace outlying data.
;
; CALLING SEQUENCE:
;
;         data = clean_data(data,keywords...)
;



function clean_data, data, FILLVAL=FILLVAL

 if not keyword_set(FILLVAL) then FILLVAL=1.0+e31;
   
   w=where(data ne FILLVAL,wn)
   if(wn eq 0) then begin
     print, "ERROR = No valid data found in function clean_data";
     print, "STATUS = No valid data found. Re-select time interval.";
   endif
   
;   mean= total(data[w[0:(wn-1)]])/fix(wn)
   ; RCJ 10/03/2003 The function moment needs data to have 2 or more elements.
   ; If that's not possible, then the mean will be the only valid element of
   ; data and the sdev will be 0. 



   if n_elements(data[w[0:(wn-1)]]) gt 1 then begin
      result = moment(data[w[0:(wn-1)]],sdev=sig)
      mean=result[0]
   endif else begin
      mean=data[w[0:(wn-1)]]
      sig=0.
   endelse      
   sig3=3.0*sig

   w=where(abs(data-mean) gt sig3, wn);
;TJK 4/8/2005 - add the next two lines because we have a case where
; all of the data values are exactly the same, and the "moment" routine
; above returns a sig value greater that the difference between the mean
; and data, so all values are set to fill, which isn't correct at all...
; So to make up for this apparent bug in the moment routine, do the following:

   t = where(data eq data[0], tn)
   if (tn eq n_elements(data)) then begin
	wn = 0
	print, 'DEBUG clean_data - overriding results from moment func. because '
	print, 'all data are the same valid value = ',data[0]
   endif

   if(wn gt 0) then data[w] = FILLVAL

return, data
end

;+
; NAME: Function CONV_POS 
;
; PURPOSE: Find virtual variables and compute their data w/ the component0,
;          component1,... data.  This function specifically converts position
;          information from 1 coordinate system into another. 
;
; INPUT:
;
;    buf           an IDL structure
;    org_names     an array of original variables sent to read_myCDF
;
; KEYWORDS:
;    COORD         string corresponding to coordinate transformation
;	           default(SYN-GCI)
;	           (ANG-GSE)
;    TSTART        start time for synthetic data
;    TSTOP         start time for synthetic data
;
; CALLING SEQUENCE:
;
;         newbuf = conv_pos(buf,org_names,keywords...)
;

function conv_pos, buf, org_names, COORD=COORD, TSTART=TSTART, $ 
                   TSTOP=TSTOP, DEBUG=DEBUG, INDEX=INDEX

 status=0
; Establish error handler
 catch, error_status
 if(error_status ne 0) then begin
   print, "ERROR= number: ",error_status," in conv_pos.pro"
   print, "ERROR= Message: ",!ERR_STRING
   status = -1
   return, status
 endif

 org_names=strupcase(org_names)
 if keyword_set(DEBUG) then DEBUG=1L else DEBUG=0L
 if not keyword_set(INDEX) then INDEX=0L;
 if not keyword_set(COORD) then COORD="SYN-GCI";
 if (keyword_set(TSTART) and keyword_set(TSTOP))then begin
        start_time = 0.0D0 ; initialize
        b = size(TSTART) & c = n_elements(b)
        if (b[c-2] eq 5) then start_time = TSTART $ ; double float already
        else if (b[c-2] eq 7) then start_time = encode_cdfepoch(TSTART); string
        stop_time = 0.0D0 ; initialize
        b = size(TSTOP) & c = n_elements(b)
        if (b[c-2] eq 5) then stop_time = TSTOP $ ; double float already
        else if (b[c-2] eq 7) then stop_time = encode_cdfepoch(TSTOP); string
 endif

 ;m3int=fix((stop_time - start_time)/(180.0*1000.0))
 ; RCJ 07/10/02 Replaced fix w/ round. Fix won't work correctly on long integers
 m3int=round((stop_time - start_time)/(180.0*1000.0))
 t3min=dblarr(m3int+1)
 failed=0 
 
 dep=parse_mydepend0(buf)  
 depends=tag_names(dep)
 depend0=depends[dep.num]
 epoch1='Epoch1'
 namest=strupcase(tag_names(buf))

 if((COORD eq "SYN-GCI") or (COORD eq "SYN-GEO")) then begin
; Determine time array 
 depend0=strupcase(buf.(INDEX).depend_0)
 incep=where(namest eq depend0,w)
 incep=incep[0]
 names=tag_names(buf.(incep))
 ntags=n_tags(buf.(incep))
; Check to see if HANDLE a tag name
 wh=where(names eq 'HANDLE',whn)
 if(whn) then begin
  handle_value, buf.(incep).HANDLE,time 
  datsz=size(time)
 endif else begin
  time=buf.(incep).dat
 endelse
; Determine position array 
;help, buf.sc_pos_syngci, /struct
  vvtag_names=strarr(1)
  vvtag_indices = vv_names(buf,NAMES=vvtag_names)
  vvtag_names = strupcase(vvtag_names)

;TJK 12/15/2006, the following doesn't work when reading a 
;a1_k0_mpa data file directly (w/o a master) because
;the data cdfs have one of the label variables incorrectly
;defined as a virtual variable, so you can't just assume
;the 1st one in vvtag_indices is the correct one.
; use the index passed in instead of vvtag_indices[0]
;  cond0=buf.(vvtag_indices[0]).COMPONENT_0 
  cond0=buf.(index).COMPONENT_0 
  x0=execute('handle_value, buf.'+cond0+'.HANDLE,data') 
;TJK 12/15/2006 these aren't right either - we'll use index
;  fillval=buf.(vvtag_indices[0]).fillval 
;  rmin=buf.(vvtag_indices[0]).VALIDMIN[0] 
;  tmin=buf.(vvtag_indices[0]).VALIDMIN[1] 
;  pmin=buf.(vvtag_indices[0]).VALIDMIN[2] 
;  rmax=buf.(vvtag_indices[0]).VALIDMAX[0] 
;  tmax=buf.(vvtag_indices[0]).VALIDMAX[1] 
;  pmax=buf.(vvtag_indices[0]).VALIDMAX[2] 
  fillval=buf.(index).fillval 
  rmin=buf.(index).VALIDMIN[0] 
  tmin=buf.(index).VALIDMIN[1] 
  pmin=buf.(index).VALIDMIN[2] 
  rmax=buf.(index).VALIDMAX[0] 
  tmax=buf.(index).VALIDMAX[1] 
  pmax=buf.(index).VALIDMAX[2] 

;  x0=execute('cond0=buf.'+vvtag_indices[0]+'.COMPONENT_0') 
;  x0=execute('handle_value, buf.'+org_names[0]+'.HANDLE,data') 
;  x0=execute('fillval=buf.'+org_names[0]+'.fillval') 

; if(COORD eq "SYN-GCI") then begin
  r=data[0,*]
  theta=data[1,*]
  phi=data[2,*]
; Check for radius in kilometers; switch to Re
  wrr=where(((r gt 36000.0) and (r lt 48000.0)),wrrn)
  if(wrrn gt 0) then r[wrr] = r[wrr]/6371.2 

; Check validity of data; if outside min and max set to fill
  rhi=where(r gt rmax,rhin)
  if(rhin gt 0) then r[rhi]=fillval
  rlo=where(r lt rmin,rlon)
  if(rlon gt 0) then r[rlo]=fillval
  ;print, rmax, rmin
  ;print, 'DEBUG',min(r, max=maxr) & print, maxr

  thi=where(theta gt tmax,thin)
  if(thin gt 0) then theta[thi]=fillval
  tlo=where(theta lt tmin,tlon)
  if(tlon gt 0) then theta[tlo]=fillval

  phii=where(phi gt pmax,phin)
  if(phin gt 0) then phi[phii]=fillval
  plo=where(phi lt pmin,plon)
  if(plon gt 0) then phi[plo]=fillval
;
  num=long(n_elements(time))
  stime=time-time[0]
  dtime=(time[num-1] - time[0])/1000.0
  d_m3time=dtime/(60.0*3.0)  ; 3min/interval=(secs/interval) / (secs/3min)
  m3time=fix(d_m3time)

; Compute syn_phi, syn_r, and syn_theta
   syn_phi=dblarr(m3int+1)
   syn_theta=dblarr(m3int+1)
   syn_r=dblarr(m3int+1)
   newtime=dblarr(m3int+1)
   tst_theta=dblarr(num)

; Clean up any bad data; set to fill values outside 3-sigma 
   phi=clean_data(phi,FILLVAL=fillval)
   theta=clean_data(theta,FILLVAL=fillval)
   r=clean_data(r,FILLVAL=fillval)

   wcp=where(phi ne fillval,wcnp)
   wct=where(theta ne fillval,wcnt)
   wcr=where(r ne fillval,wcnr)
   if((wcnp le 0) or (wcnt le 0) or (wcnr le 0)) then begin
     print, 'ERROR= Data all fill'
     print, 'STATUS= No valid data found for this time period'
     return, -1
   endif
   if((wcnp eq 1) or (wcnt eq 1) or (wcnr eq 1)) then begin
     print, 'ERROR= Only one valid point'
     print, 'STATUS= Only one valid point found for this time period'
     return, -1
   endif
; For short intervals < 10 points use wcnp otherwise average the 1st 10 points
; to obtain extrapolation parameters
   ;wcnp=wcnp-1  
   ;if(wcnp gt 10) then wcnp=10 else wcnp=wcnp-1  
; Compute average of all points
   mphi= total(phi[wcp[0:(wcnp-1)]])/fix(wcnp)
   ;mr= total(r(wcr[0:(wcnr-1)]))/fix(wcnr)
   mr= total(r[wcr[0:(wcnr-1)]])/fix(wcnr)
   mtheta= total(theta[wct[0:(wcnt-1)]])/fix(wcnt)
   ampl=double(max(theta[wct]))
;print, mphi, mr, mtheta, ampl
   wc=where(theta eq ampl,wcn)

  dphi=phi[wcp[wcnp-1]] - phi[wcp[0]]
  dr=r[wcr[wcnr-1]] - r[wcr[0]]
  dtheta=theta[wct[wcnt-1]] - theta[wct[0]]
  phi_rate=dphi/d_m3time
  r_rate=dr/d_m3time
  theta_rate=dtheta/d_m3time
  nominal_rate=0.75
  new_rate= double(360.0/(nominal_rate + phi_rate))
;  print, nominal_rate, phi_rate, new_rate, r_rate

;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
; Skip latitude daily variation approximation
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;  iter=0 
;  sign=0
;  corr_coef=0.0
;  while(corr_coef lt 0.75) do begin 
;   T=time(wc[0])/180000.0
;;   T1=time(wc[0]-1)/180000.0
;;   T2=time(wc[0]-2)/180000.0
;;   T3=time(wc[0]+1)/180000.0
;;   T4=time(wc[0]+2)/180000.0
;   if(iter eq 0) then T=double(T)
;;   if(iter eq 1) then T=double((T+T1)/2.0)
;;   if(iter eq 2) then T=double((T1+T2)/2.0)
;;   if(iter eq 3) then T=double((T+T3)/2.0)
;;   if(iter eq 4) then T=double((T4+T3)/2.0)
;;print, ampl,  T, mphi, mr, mtheta
;
;; determine array for correlation test
;   for i=0L,num-1 do begin
;      tm=time[i]/(180.0*1000.0)
;;     tst_theta[i] = ampl*sin((2.0*(!pi))*(tm-T)/480.08898)
;      if(sign eq 0) then tst_theta[i] = ampl*double(cos((2.0*(!pi))*(tm-T)/new_rate))
;      if(sign eq 1) then tst_theta[i] = ampl*double(sin((2.0*(!pi))*(tm-T)/new_rate))
;   endfor
;
;   corr_coef=correlate(theta,tst_theta)
;   if(DEBUG) then print, iter," CC = ", corr_coef
;
;;   if(iter eq 4) then begin
;     if(sign eq 0) then begin
;        iter=0 
;        sign = 1
;     endif
;;   endif
;   iter=iter+1
;;   if(iter gt 5) then goto, break   
;   if(iter gt 1) then goto, break   
;  endwhile
;  break:
;
;   if(corr_coef lt 0.75) then failed=1
;
  failed=1  ; forces average theta variation to be used approx. 0.0
; Generate 3-min data
   for i=0L,m3int do begin   
    tm = (start_time)/180000.0 + i
    t3min[i]=i*180000.0 + start_time
    half=m3int/2
    it=i-(half+1)
    syn_phi[i] = mphi + phi_rate*it
    ; syn_r[i] = mr + r_rate*i
    syn_r[i] = mr 
   if(failed) then begin
;    if(abs(mtheta) > 2.0) then begin
;      print, 'WARNING: Check daily latitude variation.' 
;      return, -1;
;    endif
      syn_theta[i] = 0.0  ; Can't compute daily variation; use this estimate
    ; syn_theta[i] = mtheta ; Can't compute daily variation; use this estimate
    ; syn_theta[i] = mtheta + theta_rate*i 
   endif else begin
;     syn_theta[i] = ampl*sin((2.0*(!pi))*(tm-T)/480.08898)
    if(sign eq 0) then syn_theta[i] = ampl*double(cos((2.0*(!pi))*(tm-T)/new_rate))
    if(sign eq 1) then syn_theta[i] = ampl*double(sin((2.0*(!pi))*(tm-T)/new_rate))
   endelse  
  endfor

;      print, t3min[0], syn_r[0], syn_theta[0], syn_phi[0]
; Convert spherical to cartesian 
;    Determine the offset of the given point from the origin.
  gei=dblarr(3,m3int+1)
  geo=dblarr(3,m3int+1)
  deg2rd=!pi/180.0 
  j=-1
  for i=0L, m3int do begin 
      CT = SIN(syn_theta[i]*deg2rd)
      ST = COS(syn_theta[i]*deg2rd)
      CP = COS(syn_phi[i]*deg2rd)
      SP = SIN(syn_phi[i]*deg2rd)
; Save syn-geo 
       geo[0,i]=syn_r[i]
       geo[1,i]=syn_theta[i]
       geo[2,i]=syn_phi[i]
;     Convert GEO spherical coordinates SGEO(1,2,3) [R,LAT,LON]
;          to GEO cartesian coordinates in REs GEO(1,2,3) [X,Y,Z].
      RHO =    syn_r[i] * ST
      xgeo = RHO * CP
      ygeo = RHO * SP
      zgeo = syn_r[i] * CT
      xgei=0.0 & ygei=0.0 & zgei=0.0
; Rotate 3-min vectors from geo to gci
      epoch=t3min[i] 
;      cdf_epoch, epoch, yr, mo, dy, hr, mn, sc, milli, /break
;      if((i mod 100) eq 0) then print, epoch, yr, mo, dy, hr, mn, sc, milli
      geigeo,xgei,ygei,zgei,xgeo,ygeo,zgeo,j,epoch=epoch
;       if((i mod 100) eq 0) then print, xgei,ygei,zgei,xgeo,ygeo,zgeo
       gei[0,i]=xgei 
       gei[1,i]=ygei 
       gei[2,i]=zgei 
  endfor

; Modify existing structure 

  nbuf=buf
; Modify depend0 (Epoch1), but don't add it again!!
  dc=where(depends eq 'EPOCH1',dcn)
  if(not dcn) then begin
   nu_ep_handle=handle_create(value=t3min)
   ;x0=execute('nbuf.'+depend0+'.handle=nu_ep_handle')
   x0=execute('temp_buf=nbuf.'+depend0)
   new=create_struct('EPOCH1',temp_buf)
   x0=execute('new.'+epoch1+'.handle=nu_ep_handle')
   x0=execute('new.'+epoch1+'.VARNAME=epoch1')
   x0=execute('new.'+epoch1+'.LABLAXIS=epoch1')
  endif
; Modify position data
  if(COORD eq "SYN-GCI") then begin
    nu_dat_handle=handle_create(value=gei)
    vin=where(vvtag_names eq 'SC_POS_SYNGCI',vinn)
    if(vinn) then begin
      ;nbuf.(vvtag_indices(vin[0])).handle=nu_dat_handle
      nbuf.(vvtag_indices[vin[0]]).handle=nu_dat_handle
      ;nbuf.(vvtag_indices(vin[0])).depend_0=epoch1
      nbuf.(vvtag_indices[vin[0]]).depend_0=epoch1
    endif
  endif
  if(COORD eq "SYN-GEO") then begin
    nu_dat_handle=handle_create(value=geo)
    vin=where(vvtag_names eq 'SC_POS_SYNGEO',vinn)
    if(vinn) then begin
      ;nbuf.(vvtag_indices(vin[0])).handle=nu_dat_handle
      nbuf.(vvtag_indices[vin[0]]).handle=nu_dat_handle
      ;nbuf.(vvtag_indices(vin[0])).depend_0=epoch1
      nbuf.(vvtag_indices[vin[0]]).depend_0=epoch1
    endif
  endif

  cond0=strupcase(cond0) 
  pc=where(org_names eq cond0,pcn)
  ;blank=' '
  if(pc[0] eq -1) then begin
    ; RCJ 06/16/2004  Only make epoch.var_type = metadata if no other
    ; variable needs epoch as its depend_0. in this case epoch
    ; should still be support_data.
    q=where(strlowcase(depends) eq 'epoch')
    if q[0] eq -1 then nbuf.epoch.var_type='metadata'
    ; RCJ 01/23/2007 The line below does not help listing. Does it do anything useful?
    ;nbuf.sc_pos_geo.depend_0=blank
  endif

  if(not dcn) then nbuf=create_struct(nbuf,new)
 endif

 if(COORD eq "ANG-GSE") then begin
  nbuf=buf 
  vvtag_names=strarr(1)
  vvtag_indices = vv_names(buf,NAMES=vvtag_names)

; Determine time array 
; depend0=depends(INDEX)
; incep=where(vvtag_names eq namest(INDEX),w)
; incep=incep[0]
 ;depend0=buf.(vvtag_indices(incep)).DEPEND_0
 depend0=buf.(INDEX).DEPEND_0
;print, depend0, INDEX
 incep=tagindex(depend0, namest)
 incep=incep[0]
 names=tag_names(buf.(incep))
 ntags=n_tags(buf.(incep))
; Check to see if HANDLE a tag name
 wh=where(names eq 'HANDLE',whn)
 if(whn) then begin
  handle_value, buf.(incep).HANDLE,time 
  datsz=size(time)
 endif else begin
  time=buf.(incep).dat
 endelse
; Determine position array 
;  indat=where(vvtag_names eq namest(INDEX),w)
;  indat = indat[0]
  cond0=buf.(INDEX).COMPONENT_0 
  ;cond0=buf.(vvtag_indices(indat)).COMPONENT_0 
;print, cond0, INDEX
  x0=execute('handle_value, buf.'+cond0+'.HANDLE,data') 

; Convert BGSE vector to angular BGSE; 
  data_sz=size(data)
  ang_gse=dblarr(data_sz[1],data_sz[2])
;  cart_polar,data[0,*],data[1,*],data[2,*],ang_gse[0,*],ang_gse[1,*],$
;             ang_gse[2,*],1,/degrees
; ang_gse[0,*]=sqrt(data[0,*]*data[0,*]+data[1,*]*data[1,*]+data[2,*]*data[2,*])
  ang_gse[0,*]=sqrt(data[0,*]^2+data[1,*]^2+data[2,*]^2)
  ang_gse[1,*]=90.0-(!radeg*acos(data[2,*]/ang_gse[0,*])) 
  ang_gse[2,*]=!radeg*atan(data[1,*],data[0,*]) 
  wc=where(ang_gse[2,*] lt 0.0,wcn)
  if(wcn gt 0) then ang_gse[2,wc] = ang_gse[2,wc]+360.0
  nu_dat_handle=handle_create(value=ang_gse)
  ;nbuf.(vvtag_indices(indat)).handle=nu_dat_handle
  nbuf.(INDEX).handle=nu_dat_handle
 endif


; Check that all variables in the original variable list are declared as
; data otherwise set to metadata 
; Find variables w/ var_type == data

   status = check_myvartype(nbuf, org_names)

return, nbuf 
end 


;to get help: IDL> ptg,/help
; ancillary routines --------------------------------------------

FUNCTION dtand,x
    RETURN,DOUBLE(TAN(x*!DTOR))
END

FUNCTION datand,x
    RETURN,DOUBLE(ATAN(x)/!DTOR)
END

FUNCTION fgeodeP,a,b,v1x,v1y,v1z,v2x,v2y,v2z
    RETURN,v1x*v2x + v1y*v2y + v1z*v2z * a*a/(b*b)
END

;---------------------------------------------------------------

PRO vector_to_ra_decP,x,y,z,ra,dec


    fill_value = -1.D31
    ndx = WHERE(z NE 0,count)
    IF(count GT 0) THEN dec[ndx] = 90.*z[ndx]/ABS(z[ndx])

    tmp = SQRT(x*x + y*y)
    ndx = WHERE(tmp NE 0,count)
    IF (count GT 0) THEN BEGIN
      dec[ndx] = atan2d(z[ndx],tmp[ndx])
      ra[ndx]  = atan2d(y[ndx],x[ndx])
    ENDIF

    ndx = WHERE((ra LT 0) AND (ra NE fill_value),count)
    IF (count GT 0) THEN ra[ndx] = ra[ndx] + 360.

END

;---------------------------------------------------------------
PRO drtollP,x,y,z,lat,lon,r

; RTB gci point validity check
    if((abs(x) gt 10000.0) or (abs(y) gt 10000.0) or (abs(z) gt 10000.0)) $
    then begin
      lat = -1.0e+31
      lon = -1.0e+31
        r = -1.0e+31
    endif else begin
      lat = atan2d(z,SQRT(x*x + y*y))
      lon = atan2d(y,x)
      r   = SQRT(x*x + y*y + z*z)
    endelse

; RTB comment
 ;     tmp = WHERE(x EQ Y) AND WHERE(x EQ 0)
 ;     IF ((size(tmp))[0] NE 0) THEN BEGIN
 ;        lat(tmp)  = DOUBLE(90.D * z(tmp)/ABS(z(tmp)))
 ;        lon(tmp) = 0.D
 ;        r = 6371.D
 ;     ENDIF

       tmp2 = WHERE(lon LT 0) 
       IF ((size(tmp2))[0] NE 0) THEN BEGIN
          ;lon(tmp2) = lon(tmp2) + 360.D
          lon[tmp2] = lon[tmp2] + 360.D
       ENDIF
; RTB added 4/98 avoid boundary
       tmp3 = where(lon eq 0.0)
       if(tmp3[0] ne -1) then lon[tmp3] = 0.01D
       tmp4 = where(lon eq 360.0)
       if(tmp4[0] ne -1) then lon[tmp4] = 359.09D

END

;---------------------------------------------------------------

PRO get_scalarP,Ox,Oy,Oz,Lx,Ly,Lz,emis_hgt,ncols,nrows,s,f

;...  Equatoral radius (km) and polar flattening of the earth
;     Ref: Table 15.4, 'Explanatory Supplement to the
;          Astronomical Almanac,' K. Seidelmann, ed. (1992).
      re_eq = 6378.136D
      inv_f = 298.257D

;...  initialize output
      s =  DBLARR(ncols,nrows)
      s1 = DBLARR(ncols,nrows)
      s2 = DBLARR(ncols,nrows)

;...  get polar radius
      re_po = re_eq*(1.D - 1.D /inv_f)

;...  get radii to assumed emission height
      ree = re_eq + emis_hgt
      rep = re_po + emis_hgt

;...  get flattening factor based on new radii
      f = (ree - rep)/ree

;...  get elements of quadratic formula
      a = fgeodeP(ree,rep,Lx,Ly,Lz,Lx,Ly,Lz)
      b = fgeodeP(ree,rep,Lx,Ly,Lz,Ox,Oy,Oz) * 2.D
      c = fgeodeP(ree,rep,Ox,Oy,Oz,Ox,Oy,Oz) - ree*ree

;...  check solutions to quadratic formula
      determinant = b*b - 4.D * a*c 
;...  remove points off the earth
      determinant = determinant > 0. 
      tmp_d2 = WHERE(determinant EQ 0.,count) 
      IF(count GT 0) THEN b[tmp_d2] = 0.D
;...  solve quadratic formula (choose smallest solution) 
      s1 = ( -b + SQRT(determinant) ) / ( 2.D *a ) 
      s2 = ( -b - SQRT(determinant) ) / ( 2.D *a ) 

      s = s1<s2

END

pro ptg_new,orb,LpixX,LpixY,LpixZ,emis_hgt,gclat,gclon,r,epoch=epoch

     size_L=size(LpixX)
;... Convert Lpix to a Unit Vector
     mag = dfmag(LpixX,LpixY,LpixZ)

     LpixX = LpixX/mag
     LpixY = LpixY/mag
     LpixZ = LpixZ/mag

; Option which could be included
;    calculate right ascension and declination
;     IF(KEYWORD_SET(getra)) THEN $
;        vector_to_ra_decP,LpixX,LpixY,LpixZ,ra,dec

;... Find scalar (s) such that s*L0 points to
;    the imaged emission source.  If the line of
;    sight does not intersect the earth s=0.0
     Ox = orb[0]
     Oy = orb[1]
     Oz = orb[2]
     get_scalarP,Ox,Oy,Oz,LpixX,LpixY,LpixZ,emis_hgt,size_L[1],size_L[2],s,f
     posX = Ox + s*LpixX
     posY = Oy + s*LpixY
     posZ = Oz + s*LpixZ

;... Convert from GCI to GEO coordinates. 
     j=1
     geigeo,posX,posY,posZ,p_geoX,p_geoY,p_geoZ,j,epoch=epoch

;... Get geocentric lat/lon.  this converts from
;    a 3 element vector to two angles: lat & longitude
; Each point must be checked for outlying cyl. geo values.
  for i=0, size_L[1]-1 do begin
   for j=0, size_L[2]-1 do begin
     drtollP,p_geoX[i,j],p_geoY[i,j],p_geoZ[i,j],dum1,dum2,dum3
;print, dum1,dum2, dum3
     gclat[i,j]=dum1
     gclon[i,j]=dum2
     r[i,j]=dum3
   endfor
  endfor

     gclat = gclat < 90.

;... Convert to geodetic lat/lon.  F is the flattening
;    factor of the Earth.  See get_scalar for details.
;    Ref: Spacecraft Attitude Determination and Control,
;    J.R. Wertz, ed., 1991, p.821.
     IF(KEYWORD_SET(geodetic)) THEN BEGIN
        gdlat = 90.D + 0.D * gclat
        ndx = WHERE(gclat LT 90.,count)
        IF(count GT 0) THEN BEGIN
           gdlat[ndx] = datand(dtand(gclat[ndx])/(1.D - f)*(1.D - f))
        ENDIF
        gclat = gdlat
     ENDIF


end
;-------------------------------------------------------------------------
;  ROUTINE:	ptg
;-------------------------------------------------------------------------

PRO ptg,system,time,l0,att,orb,emis_hgt,gclat,gclon $
       ,geodetic=geodetic,getra=getra,ra=ra,dec=dec,s=s $
       ,LpixX=LpixX,LpixY=LpixY,LpixZ=LpixZ $
       ,posX=posX,posY=posY,posZ=posZ, epoch=epoch $
       ,versStr=versStr,help=help

    IF(KEYWORD_SET(help)) THEN BEGIN
       PRINT,''
       PRINT,' PRO ptg,system,time,l0,att,orb,emis_hgt,gclat,gclon
       PRINT,''
       PRINT,' Original base code:  UVIPTG'
       PRINT,' 7/31/95  Author:  G. Germany'
       PRINT,' Development into PTG: 01/15/98'
       PRINT,' Authors:  Mitch Brittnacher & John O''Meara'
       PRINT,''
       PRINT,' calculates geocentric lat,lon, for a complete image
       PRINT,' 
       PRINT,' input
       PRINT,'    system          =1 primary; =2 secondary
       PRINT,'    time            time(1)=yyyyddd, time(2)=msec of day 
       PRINT,'    L0              gci look direction (from uvilook)
       PRINT,'    att             gci attitude 
       PRINT,'    orb             gci position
       PRINT,'    emis_hgt        los altitude
       PRINT,'
       PRINT,' output
       PRINT,'    gclat           geocentric latitude
       PRINT,'    gclon           geocentric longitude
       PRINT,'
       PRINT,' keywords
       PRINT,'    geodetic        (set) returns geodetic values if set
       PRINT,'    getra           (set) calulates ra & dec if set
       PRINT,'       ra           (out) right ascension (deg)
       PRINT,'      dec           (out) declination (deg)
       PRINT,'        s           (out) scalar for lpix
       PRINT,'    lpixX           (out) x component of unit look direction
       PRINT,'    lpixY           (out) y component of unit look direction
       PRINT,'    lpixZ           (out) z component of unit look direction
       PRINT,'     posX           (out) x,y,z components of vector from
       PRINT,'     posY           (out)       earth center to emission
       PRINT,'     posZ           (out) 
       PRINT,'  versStr           (out) software version string
       PRINT,'
       PRINT,' external library routines required
       PRINT,'    ic_gci_to_geo
       PRINT,'
       PRINT,' NOTES:
       PRINT,'
       PRINT,' 1. Unlike UVIPTG, this routine returns latitude and longitude
       PRINT,'    for all pixels in an image.  It does the calculation in a
       PRINT,'    fraction of the time required by UVIPTG.
       PRINT,'
       PRINT,' 2. The default lat/lon values are in geocentric coordinates.
       PRINT,'    Geographic (geocentric) coordinates assume the earth is
       PRINT,'    a sphere and are defined from the center of the sphere.
       PRINT,'    For geodetic coordinates, the earth is assumed to be an 
       PRINT,'    ellipsoid of revolution.  See the routine fgeode for 
       PRINT,'    details.  
       PRINT,'    Geodetic coordinates are defined from the normal to the 
       PRINT,'    geode surface.  To enable geodetic calculations, set the 
       PRINT,'    keyword /GEODETIC.
       PRINT,' 
       PRINT,' 3. The look direction for a specified pixel (Lpix) is
       PRINT,'    calculated from the look direction of the center of the
       PRINT,'    UVI field of view (L0) by successive rotations in
       PRINT,'    row and column directions.  Each pixel is assumed to have
       PRINT,'    a fixed angular width.  The angular distance from the center
       PRINT,'    of the pixel to the center of the fov is calculated and then
       PRINT,'    L0 is rotated into Lpix.
       PRINT,'
       PRINT,'    Unlike UVIPTG, this routine explicitly calculates three
       PRINT,'    orthogonal axes whereas UVIPTG implicitly assumed the image
       PRINT,'    z-axis was given by the attitude vector.
       PRINT,'
       PRINT,' 4. The secondary and primary detectors have different 
       PRINT,'    orientations and require different rotations between L0 and 
       PRINT,'    Lpix.
       PRINT,'    
       PRINT,' 5. Geocentric lat/lon values are the intersection
       PRINT,'    of the look direction for the specified pixel (Lpix) and
       PRINT,'    the surface of the earth.  The geocentric values are then
       PRINT,'    transformed into geodetic values.  The vector from the
       PRINT,'    center of the earth to the intersection is pos so that
       PRINT,'    pos = orb + S*Lpix, where orb is the GCI orbit vector
       PRINT,'    and S is a scalar.
       PRINT,'
       PRINT,' 6. The intersection of Lpix and the earth is calculated first
       PRINT,'    in GCI coordinates and then converted to geographic 
       PRINT,'    coordinates.  The conversion is by means of ic_gci_to_geo.  
       PRINT,'    This routine and its supporting routines, was taken from 
       PRINT,'    the CDHF and is part of the ICSS_TRANSF_orb call.
       PRINT,'
       PRINT,' 7. The viewed emissions are assumed to originate emis_hgt km
       PRINT,'    above the surface of the earth.  See get_scalar for details.
       PRINT,'
       PRINT,'10. The keywords POS(xyz) are needed for LOS corrections.
       PRINT,'
       RETURN
     ENDIF   

     versStr = 'PTG v1.0  1/98'
     ncols = 200
     nrows = 228
     zrot  = DBLARR(ncols,nrows)
     yrot  = DBLARR(ncols,nrows)
     gclat = DBLARR(ncols,nrows)
     gclon = DBLARR(ncols,nrows)
     r     = DBLARR(ncols,nrows)
     ra    = DBLARR(ncols,nrows)
     dec   = DBLARR(ncols,nrows)

     primary   = 1
     secondary = 2
     fill_value = -1.D31

;... Define orthonormal coordinate axes
     xax = l0/dfmag(l0[0],l0[1],l0[2])
     yax = CROSSP(att,l0)
     yax = yax/dfmag(yax[0],yax[1],yax[2])
     zax = CROSSP(xax,yax)

;... single pixel angular resolution
     pr = 0.03449D       ; 9-bin mean primary detector 9/26/97 (Pyth)
     pc = 0.03983D       ; same

;... initialize output arrays to default
     gclat[*,*] = fill_value
     gclon[*,*] = fill_value
        ra[*,*] = fill_value
       dec[*,*] = fill_value

;... find rotation angles for each pixel
     IF (system EQ secondary) THEN BEGIN
       a = (FINDGEN(200)-99.5)*pc
       b = REPLICATE(1.,228)
       zrot = a#b
       c = (FINDGEN(228)-113.5)*pr
       d = REPLICATE(1.,200)
       yrot = d#c 
     ENDIF ELSE BEGIN 
       IF (system EQ primary) THEN BEGIN
         a = (FINDGEN(200)-99.5)*pc
         b = REPLICATE(1.,228)
         zrot = a#b
         c = -(FINDGEN(228)-113.5)*pr
         d = REPLICATE(1.,200)
         yrot = d#c 
       ENDIF ELSE BEGIN 
         ;  error trap
         RETURN 
       ENDELSE 
     ENDELSE

;... Determine Lpix
     tanz = tan(zrot*!DTOR)
     tany = tan(yrot*!DTOR)
 
     lpx = 1.D /SQRT(1.D + tany*tany + tanz*tanz)
     lpy = lpx*tanz
     lpz = lpx*tany
 
     LpixX = lpx*xax[0] + lpy*yax[0] + lpz*zax[0]
     LpixY = lpx*xax[1] + lpy*yax[1] + lpz*zax[1]
     LpixZ = lpx*xax[2] + lpy*yax[2] + lpz*zax[2]

     ptg_new, orb,LpixX,LpixY,LpixZ,emis_hgt,gclat,gclon,r,epoch=epoch

;... Convert Lpix to a Unit Vector
;     mag = dfmag(LpixX,LpixY,LpixZ)
;
;     LpixX = LpixX/mag
;     LpixY = LpixY/mag
;     LpixZ = LpixZ/mag
;
;;    calculate right ascension and declination
;     IF(KEYWORD_SET(getra)) THEN $
;        vector_to_ra_decP,LpixX,LpixY,LpixZ,ra,dec
;
;;... Find scalar (s) such that s*L0 points to
;;    the imaged emission source.  If the line of
;;    sight does not intersect the earth s=0.0
;;help,orb
;     Ox = orb[0]
;     Oy = orb[1]
;     Oz = orb[2]
;     get_scalarP,Ox,Oy,Oz,LpixX,LpixY,LpixZ,emis_hgt,ncols,nrows,s,f
;
;     posX = Ox + s*LpixX
;     posY = Oy + s*LpixY
;     posZ = Oz + s*LpixZ
;;
;; RTB replace  MSFC GCI to GEO routine w/ geopack
;     j=1
;     geigeo,posX,posY,posZ,p_geoX,p_geoY,p_geoZ,j,epoch=epoch
;
;; SOMETHING WRONG HERE !!!!!
;;... Convert from GCI to GEO coordinates.  ROTM is the
;;    rotation matrix.
;;      ic_gci_to_geo,time,rotm
;;      p_geoX = rotm(0,0)*posX + rotm(1,0)*posY + rotm(2,0)*posZ
;;      p_geoY = rotm(0,1)*posX + rotm(1,1)*posY + rotm(2,1)*posZ
;;      p_geoZ = rotm(0,2)*posX + rotm(1,2)*posY + rotm(2,2)*posZ
;
;
;;... Get geocentric lat/lon.  this converts from
;;    a 3 element vector to two angles: lat & longitude
;; Each point must be checked for outlying cyl. geo values.
;  for i=0, 199 do begin
;   for j=0, 227 do begin
;     drtollP,p_geoX(i,j),p_geoY(i,j),p_geoZ(i,j),dum1,dum2,dum3
;     gclat(i,j)=dum1
;     gclon(i,j)=dum2
;     r(i,j)=dum3
;   endfor
;  endfor
;
;     gclat = gclat < 90.
;
;;... Convert to geodetic lat/lon.  F is the flattening
;;    factor of the Earth.  See get_scalar for details.
;;    Ref: Spacecraft Attitude Determination and Control,
;;    J.R. Wertz, ed., 1991, p.821.
;     IF(KEYWORD_SET(geodetic)) THEN BEGIN
;        gdlat = 90.D + 0.D * gclat
;        ndx = WHERE(gclat LT 90.,count)
;        IF(count GT 0) THEN BEGIN
;;           gdlat[ndx] = datand(dtand(gclat[ndx])/(1.D - f)*(1.D - f))
;        ENDIF
;        gclat = gdlat
;     ENDIF

END

;+
; NAME: Function CONV_MAP_IMAGE
;
; PURPOSE: Convert provided idl structure to structure containing neccesary 
;          variables for an auroral image map.  Use variables pointed to by
;          COMPONENT variable attributes to compute geodetic latitude and
;          longitude. Populate GEOD_LAT & GEOD_LONG variables w/ the computed
;          values. Return the modifiy idl structure. 
;
;  NEED TO REMOVE UVI DEPENDENCIES.......
; 
; CALLING SEQUENCE: 
;
;          new_buf = conv_map_image(buf,org_names)
;
; VARIABLES:
;
; Input:
;
;  buf        - an IDL structure built w/in read_myCDF
;  org_names  - list of original variables input to read_myCDF. Any
;               variables in this list will remain tagged as
;               VAR_TYPE= data otherwise VAR_TYPE = support_data.
;
; Output:
;
;  new_buf    - an IDL structure containing the populated virtual
;               variable
; 
; Keyword Parameters:
;
;
; REQUIRED PROCEDURES:
;
;   none
;
;-------------------------------------------------------------------
; History
;
;         1.0  R. Baldwin  HSTX     1/30/98
;               Initial version
;
;-------------------------------------------------------------------

function conv_map_image, buf, org_names, DEBUG=DEBUG

; Trap any errors propagated through buf
if(buf_trap(buf)) then begin
   print, "idl structure bad (conv_map_image)
   return, buf 
endif

; Check tags 
tagnames=tag_names(buf)
;
;print, 'In Conv_map_image'

;TJK added 6/10/98 - if the 1st image virtual variable handle or dat structure
;elements are already set, then return buf as is (because the other
;image variables, if requested, have already been set on the 1st call to this
;function.

vv_tagnames=strarr(1)
vv_tagindx = vv_names(buf,names=vv_tagnames) ;find the virtual vars
vtags = tag_names(buf.(vv_tagindx[0])) ;tags for the 1st Virtual image var.
if (vv_tagindx[0] lt 0) then return, -1

ireturn=1
im_val_arr=intarr(n_elements(vv_tagindx))
for ig=0, n_elements(vv_tagindx)-1 do begin ; RTB added 9/98
  vtags=tag_names(buf.(vv_tagindx[ig]))
  v = tagindex('DAT',vtags)
  if (v[0] ne -1) then begin
   im_val = buf.(vv_tagindx[ig]).dat
  endif else begin
   im_val = buf.(vv_tagindx[ig]).handle
   if (im_val eq 0) then ireturn=0
  endelse
  im_val_arr[ig]=im_val
  im_size = size(im_val)
  im_val=0
  if (im_val[0] ne 0 or im_size[0] eq 3) then begin
    im_val = 0B ;free up space
    ireturn=0
  endif
endfor

if(ireturn) then return, buf ; Return only if all orig_names are already

a0=tagindex(tagnames,'IMAGE_DATA')
   
if(a0 ne -1) then begin
 image_handle=buf.(a0).handle
 image_depend0=strupcase(buf.(a0).depend_0)
 handle_value, buf.(a0).handle, im_data
 ;TJK 6/27/2013 - add in check if all values are fill, if so get out
 fillz = where(im_data ne buf.(a0).fillval, fillcnt)
 
 if (fillcnt eq 0) then begin
    ;  RCJ 20Jan2022  If image_data is all fillval then vars that have image_data
    ;      as component_0 should be too :  (similarly for gci_sun)
    for i=0,n_elements(tagnames)-1 do begin
        if buf.(i).component_0 eq 'IMAGE_DATA' then buf.(i).handle=handle_create(value=im_data)
        if buf.(i).component_0 eq 'GCI_SUN' then buf.(i).handle=handle_create(value=im_data)
    endfor
    return, buf
 endif  
 im_sz=size(im_data)
 im_data=0B ; Release image data after we know the dimensionality
endif

a0=tagindex(tagnames,image_depend0)
if(a0 ne -1) then begin
 handle_value, buf.(a0).handle, im_time
endif

a0=tagindex(tagnames,'ATTITUDE')
if(a0 ne -1) then begin
 handle_value, buf.(a0).handle, attit
endif
;attit=[-0.34621945,0.93623523,-0.059964006]

a0=tagindex(tagnames,'GCI_POSITION')
if(a0 ne -1) then begin
 handle_value, buf.(a0).handle, gpos 
endif
;gpos=[11776.447,7885.8336,55474.6585]

a0=tagindex(tagnames,'SYSTEM')
if(a0 ne -1) then begin
 handle_value, buf.(a0).handle, sys 
endif

a0=tagindex(tagnames,'FILTER')
if(a0 ne -1) then begin
 handle_value, buf.(a0).handle, filt 
endif

a0=tagindex(tagnames,'DSP_ANGLE')
if(a0 ne -1) then begin
 handle_value, buf.(a0).handle, dsp 
endif
  
; Call uviptg.pro to generate geodetic lat & lon registration of polar images   

; uviptg constants
emis_hgt=120.D0 ; km 

; Process each time frame
jcol=im_sz[2]
irow=im_sz[1]
if(im_sz[0] eq 2) then ntimes=1 else ntimes=im_sz[3]
geod_lat=temporary(fltarr(irow,jcol,ntimes))
geod_lon=temporary(fltarr(irow,jcol,ntimes))
time=intarr(2)

for it=0, ntimes-1 do begin 
  ; Load ancillary data  
  ;  L0=double(look(*,it))
  L0=dblarr(3)
  att=double(attit[*,it])
  ; att=double(attit)
  orb=double(gpos[*,it])
  ;orb=double(gpos)
  if(sys[it] lt 0) then system=sys[it]+3 else system=sys[it]
  filter=fix(filt[it])-1
  dsp_angle=double(dsp[it])

  gdlat=DBLARR(jcol,irow)
  gdlon=DBLARR(jcol,irow)

  epoch=im_time[it]

  ; Compute time(1)=yyyyddd and time(2) msec of day from Epoch
  cdf_epoch, im_time[it], year, month, day,hr,min,sec,milli,/break
  ;print, im_time(it), year, month, day,hr,min,sec,milli

  ical,year,doy,month,day,/idoy
  ;print, year,doy,month,day
  time=fltarr(2)
  time[0]=year*1000+doy
  time[1]=(hr*(3600)+min*60+sec)*1000+milli

  ; Use uvilook program to compute 2nd detector gci_look
  uvilook,time,orb,att,dsp_angle,filter,dummy,L0,system=system

  ptg,system,time,L0,att,orb,emis_hgt,gdlat,gdlon $
       ,getra=getra,ra=ra,dec=dec,s=s $
       ,LpixX=LpixX,LpixY=LpixY,LpixZ=LpixZ $
       ,posX=posX,posY=posY,posZ=posZ, epoch=epoch 

  gwc=where(gdlon gt 180.0,gwcn)
  if(gwc[0] ne -1) then gdlon[gwc]=gdlon[gwc]-360.0

  geod_lat[*,*,it]=transpose(gdlat[*,*])
  geod_lon[*,*,it]=transpose(gdlon[*,*])
endfor

; Add to org_names list so that 
temp=org_names
corg=n_elements(temp)
org_names=strarr(n_elements(temp)+2)
wc=where(temp ne '',wcn)
org_names[wc]=temp[wc]

; Populate idl structure w/ geod_lat and geod_lon data
; Create handles and to existing structure
a0=tagindex(tagnames,'GEOD_LAT')
if(a0 ne -1) then begin
 gdlat_handle=handle_create(value=geod_lat)
 buf.(a0).handle=gdlat_handle
 org_names[corg]='GEOD_LAT'
endif else begin
  print, "ERROR= No GEOD_LAT variable found in cdf (conv_map_image)"
  print, "ERROR= Message: ", a0
  return, -1 
endelse

a0=tagindex(tagnames,'GEOD_LONG')
if(a0 ne -1) then begin
 gdlon_handle=handle_create(value=geod_lon)
 buf.(a0).handle=gdlon_handle
 org_names[corg+1]='GEOD_LONG'
endif else begin
  print, "ERROR= No GEOD_LONG variable found in cdf (conv_map_image)"
  print, "ERROR= Message: ", a0
  return, -1								    
endelse

; Copy IMAGE_DATA handle to GEOD_IMAGE ; Regular registered map
a0=tagindex(tagnames,'GEOD_IMAGE')
if(a0 ne -1) then begin
 buf.(a0).handle=image_handle
endif 

; Copy IMAGE_DATA handle to GEOD_IMAGE_P; Geo. fixed registered map
a0=tagindex(tagnames,'GEOD_IMAGE_P')
if(a0 ne -1) then begin
 buf.(a0).handle=image_handle
endif 

; Copy IMAGE_DATA handle to GEOD_IMAGE_PS; Geo. registered sun-fixed
a0=tagindex(tagnames,'GEOD_IMAGE_PS')
if(a0 ne -1) then begin
 buf.(a0).handle=image_handle
endif 

; Copy IMAGE_DATA handle to GEOD_IMAGE_O; Geo. map overlay (not-registered) 
a0=tagindex(tagnames,'GEOD_IMAGE_O')
if(a0 ne -1) then begin
 buf.(a0).handle=image_handle
endif

; Copy IMAGE_DATA handle to GEOD_IMAGE_M; MLT registered map
a0=tagindex(tagnames,'GEOD_IMAGE_M')
if(a0 ne -1) then begin
 buf.(a0).handle=image_handle
endif

; Copy IMAGE_DATA handle to IMAGE_MOVIE_PS; Geo. registered sun-fixed
a0=tagindex(tagnames,'IMAGE_MOVIE_PS')
if(a0 ne -1) then begin
 buf.(a0).handle=image_handle
endif

; Copy IMAGE_DATA handle to IMAGE_MOVIE_O; Geo. map overlay (not-registered)
a0=tagindex(tagnames,'IMAGE_MOVIE_O')
if(a0 ne -1) then begin
 buf.(a0).handle=image_handle
endif

; Copy IMAGE_DATA handle to IMAGE_MOVIE_M; MLT registered map
a0=tagindex(tagnames,'IMAGE_MOVIE_M')
if(a0 ne -1) then begin
 buf.(a0).handle=image_handle
endif

; Check buf and reset variables not in orignal variable list to metadata
status = check_myvartype(buf, org_names)

return, buf
end


FUNCTION calc_p, buf, org_names, INDEX=INDEX, DEBUG=DEBUG

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;  PURPOSE:
;
;The general algorithm for Dynamic Pressure is mNV^2. I want the units
;to be in nanoPascals (nPa) and so have determined a coefficient which
;contains the proton mass and the conversions to the correct units. A
;typical pressure in the solar wind is a few nPa.
;
;coefficient = 1.6726 e-6
;
;Use the variables from WI_K0_SWE:
;
;  "V_GSE_p(0)" - flow speed (km/s)
;  "Np" - ion number density (/cc)
;
; ALGORITHM:
;
; Pressure = coefficient * Np * V_GSE_p(0) * V_GSE_p(0)
;
; CALLING SEQUENCE:
;
;          new_buf = calc_p(buf,org_names)
;
; VARIABLES:
;
; Input:
;
;  buf        - an IDL structure built w/in read_myCDF
;  org_names  - list of original variables input to read_myCDF. Any
;               variables in this list will remain tagged as 
;               VAR_TYPE= data otherwise VAR_TYPE = support_data.
;
; Output:
;
;  new_buf    - an IDL structure containing the populated virtual 
;               variable 
; Constants:
;
;  coefficient -  Dynamic Pressure conversion coefficient
;  
; Keyword Parameters: 
;
;
; REQUIRED PROCEDURES:
;
;   none 
; 
;-------------------------------------------------------------------
; History
;
;         1.0  R. Baldwin  HSTX     1/6/98 
;		Initial version
;
;-------------------------------------------------------------------

 status=0
 coefficient = 1.6726e-6
 fillval = -1.00000e+31

; Establish error handler
 catch, error_status
 if(error_status ne 0) then begin
   print, "ERROR= number: ",error_status," in calc_p.pro"
   print, "ERROR= Message: ",!ERR_STRING
   status = -1
   return, status
 endif
  
 org_names=strupcase(org_names)
 if keyword_set(DEBUG) then DEBUG=1L else DEBUG=0L
 if not keyword_set(INDEX) then INDEX=0L;

 dep=parse_mydepend0(buf)  
 depends=tag_names(dep)
 depend0=depends[dep.num]
 namest=strupcase(tag_names(buf))

  nbuf=buf 
  vvtag_names=strarr(1)
  vvtag_indices = vv_names(buf,NAMES=vvtag_names)

; Determine time array 
; depend0=depends(INDEX)
; incep=where(vvtag_names eq namest(INDEX),w)
; incep=incep[0]
 ;depend0=buf.(vvtag_indices(incep)).DEPEND_0
 depend0=buf.(INDEX).DEPEND_0
;print, depend0, INDEX
 incep=tagindex(depend0, namest)
 incep=incep[0]
 names=tag_names(buf.(incep))
 ntags=n_tags(buf.(incep))
; Check to see if HANDLE a tag name
 wh=where(names eq 'HANDLE',whn)
 if(whn) then begin
  handle_value, buf.(incep).HANDLE,time 
  datsz=size(time)
 endif else begin
  time=buf.(incep).dat
 endelse
; Determine components
   ;cond0=buf.(vvtag_indices(indat)).COMPONENT_0 
  cond0=buf.(INDEX).COMPONENT_0 
   ;cond1=buf.(vvtag_indices(indat)).COMPONENT_1 
  cond1=buf.(INDEX).COMPONENT_1 
  x0=execute('handle_value, buf.'+cond0+'.HANDLE,V_GSE_p') 
  x1=execute('handle_value, buf.'+cond1+'.HANDLE,np') 
; Compute Pressure
  wnp=where(np eq fillval, wnpn)
  wv=where(V_GSE_p[0,*] eq fillval, wvn)

  num = n_elements(np)-1
  pressure = fltarr(n_elements(np))
  for i=0L, num do begin
   pressure[i] = coefficient*np[i]*V_GSE_p[0,i]^2.0
  endfor
   if(wvn ne 0) then pressure[wv] = fillval 
   if(wnpn ne 0) then pressure[wnp] = fillval

  nu_dat_handle=handle_create(value=pressure)
  ;nbuf.(vvtag_indices(indat)).handle=nu_dat_handle
  nbuf.(INDEX).handle=nu_dat_handle

; Check that all variables in the original variable list are declared as
; data otherwise set to metadata 
; Find variables w/ var_type == data

   status = check_myvartype(nbuf, org_names)

return, nbuf 
end 

FUNCTION Add_51s, buf, org_names, INDEX=INDEX, DEBUG=DEBUG

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;  PURPOSE:
;
;Want to take the given variables value and add 51 to it.  This was
;written specifically for po_h2_uvi, but is generic.
;
; CALLING SEQUENCE:
;
;          new_buf = Add_51s(buf,org_names)
;
; VARIABLES:
;
; Input:
;
;  buf        - an IDL structure built w/in read_myCDF
;  org_names  - list of original variables input to read_myCDF. Any
;               variables in this list will remain tagged as 
;               VAR_TYPE= data otherwise VAR_TYPE = support_data.
;
; Output:
;
;  new_buf    - an IDL structure containing the populated virtual 
;               variable 
; Constants:
;
;  # to add -  defaults to 51
;  
; Keyword Parameters: 
;	INDEX : this can be set the structure variable index # for which
;	you'd like this conversion.  If this isn't set we'll look for the
;	epoch variable.
;
; REQUIRED PROCEDURES:
;
;   none 
; 
;-------------------------------------------------------------------
; History
;
;         1.0  T. Kovalick 4/16/2001
;		Initial version
;
;-------------------------------------------------------------------

 status=0
 num_milliseconds = 51000 ; 51 seconds in milliseconds

; Establish error handler
 catch, error_status
 if(error_status ne 0) then begin
   print, "ERROR= number: ",error_status," in Add_51s.pro"
   print, "ERROR= Message: ",!ERR_STRING
   status = -1
   return, status
 endif
  
 org_names=strupcase(org_names)
 if keyword_set(DEBUG) then DEBUG=1L else DEBUG=0L

;Get the virtual variables index #.
 if (n_elements(INDEX) gt 0) then vvar_index = INDEX else print, 'No virtual variable specified.'

 if (vvar_index ge 0) then begin

  nbuf=buf 
  
  epoch_names = tag_names(buf.(vvar_index))
  handle_found = 0

; Check to see if HANDLE is a tag name
  wh=where(epoch_names eq 'HANDLE',whn)
  if(whn) then handle_found = 1

; Determine the "parent variable" component_0
  cond0=buf.(vvar_index).COMPONENT_0 
  if (handle_found) then x0=execute('handle_value, buf.'+cond0+'.HANDLE,parent_times') $
	else x0=execute('parent_times =  buf.'+cond0+'.DAT')
  shifted_times = parent_times ; create the same sized array

  num = n_elements(parent_times)-1
  for i=0L, num do begin
	shifted_times[i] = parent_times[i]+ num_milliseconds
  endfor

  if (handle_found eq 1) then begin
    nu_dat_handle=handle_create(value=shifted_times)
    nbuf.(vvar_index).handle=nu_dat_handle
  endif else begin
    nbuf.(vvar_index).dat=shifted_times
  endelse

; Check that all variables in the original variable list are declared as
; data otherwise set to metadata 
; Find variables w/ var_type == data

   status = check_myvartype(nbuf, org_names)

   return, nbuf 

endif else begin
   print, 'No valid variable found in add_51s, returning -1'
   return, -1
endelse

end 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
FUNCTION Add_seconds, buf, org_names, seconds=seconds, INDEX=INDEX, DEBUG=DEBUG
;
;  PURPOSE:
;
;Want to take the given "epoch" variables value and add "n" number of seconds
; to it.  This was written specifically for po_h2_uvi, but is generic.
;
; CALLING SEQUENCE:
;
;          new_buf = Add_seconds(buf, org_names, seconds)
;
; VARIABLES:
;
; Input:
;
;  buf        - an IDL structure built w/in read_myCDF
;  org_names  - list of original variables input to read_myCDF. Any
;               variables in this list will remain tagged as 
;               VAR_TYPE= data otherwise VAR_TYPE = support_data.
;  seconds    - the number of seconds to add to given time 
;
; Output:
;
;  new_buf    - an IDL structure containing the populated virtual 
;               variable 
; Constants:
;
;  # to add -  defaults to 51
;  
; Keyword Parameters: 
;	INDEX : this can be set the structure variable index # for which
;	you'd like this conversion.  If this isn't set we'll look for the
;	epoch variable.
;  	SECONDS    - the number of seconds to add to given time 
;
; REQUIRED PROCEDURES:
;
;   none 
; 
;-------------------------------------------------------------------
; History
;
;         1.0  T. Kovalick 1/24/2005
;		Generic version, to accept the number of seconds 
;		as a keyword
;
;-------------------------------------------------------------------

 status=0
 if (n_elements(seconds) gt 0) then seconds = seconds else seconds = 51
 num_milliseconds = seconds * 1000L
 ;help, num_milliseconds

; Establish error handler
 catch, error_status
 if(error_status ne 0) then begin
   print, "ERROR= number: ",error_status," in Add_51s.pro"
   print, "ERROR= Message: ",!ERR_STRING
   status = -1
   return, status
 endif
  
 org_names=strupcase(org_names)
 if keyword_set(DEBUG) then DEBUG=1L else DEBUG=0L

;Get the virtual variables index #.
 if (n_elements(INDEX) gt 0) then vvar_index = INDEX else print, 'No virtual variable specified.'

 if (vvar_index ge 0) then begin

  nbuf=buf 
  
  epoch_names = tag_names(buf.(vvar_index))
  handle_found = 0

; Check to see if HANDLE is a tag name
  wh=where(epoch_names eq 'HANDLE',whn)
  if(whn) then handle_found = 1

; Determine the "parent variable" component_0
  cond0=buf.(vvar_index).COMPONENT_0 
  if (handle_found) then x0=execute('handle_value, buf.'+cond0+'.HANDLE,parent_times') $
	else x0=execute('parent_times =  buf.'+cond0+'.DAT')
  shifted_times = parent_times ; create the same sized array

  num = n_elements(parent_times)-1
  for i=0L, num do begin
	shifted_times[i] = parent_times[i]+ num_milliseconds
  endfor

  if (handle_found eq 1) then begin
    nu_dat_handle=handle_create(value=shifted_times)
    nbuf.(vvar_index).handle=nu_dat_handle
  endif else begin
    nbuf.(vvar_index).dat=shifted_times
  endelse

; Check that all variables in the original variable list are declared as
; data otherwise set to metadata 
; Find variables w/ var_type == data

   status = check_myvartype(nbuf, org_names)

   return, nbuf 

endif else begin
   print, 'No valid variable found in add_seconds, returning -1'
   return, -1
endelse

end 


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

FUNCTION compute_magnitude, buf, org_names, INDEX=INDEX, DEBUG=DEBUG
;
;  PURPOSE:
;
;This routine computes the magnitude given a x,y,z vector variable
;
; CALLING SEQUENCE:
;
;          new_buf = compute_magnitude(buf,org_names, INDEX=INDEX)
;
; VARIABLES:
;
; Input:
;
;  buf        - an IDL structure built w/in read_myCDF
;  org_names  - list of original variables input to read_myCDF. Any
;               variables in this list will remain tagged as 
;               VAR_TYPE= data otherwise VAR_TYPE = support_data.
;
; Output:
;
;  new_buf    - an IDL structure containing the populated virtual 
;               variable 
; Constants:
;
;  none
;  
; Keyword Parameters: 
;	INDEX : this can be set the structure variable index # for which
;	you'd like this conversion.  If this isn't set we'll look for the
;	epoch variable.
;
; REQUIRED PROCEDURES:
;
;   none 
; 
;-------------------------------------------------------------------
; History
;
;         1.0  T. Kovalick 6/27/2001
;		Initial version
;
;-------------------------------------------------------------------

 status=0

; Establish error handler
 catch, error_status
 if(error_status ne 0) then begin
   print, "ERROR= number: ",error_status," in compute_magnitude function"
   print, "ERROR= Message: ",!ERR_STRING
   status = -1
   return, status
 endif
  
 org_names=strupcase(org_names)
 if keyword_set(DEBUG) then DEBUG=1L else DEBUG=0L

;Get the virtual variables index #.
 if (n_elements(INDEX) gt 0) then vvar_index = INDEX else print, 'No virtual variable specified.'

 if (vvar_index ge 0) then begin

  nbuf=buf 
  
  names = tag_names(buf.(vvar_index))
  handle_found = 0

; Check to see if HANDLE is a tag name
  wh=where(names eq 'HANDLE',whn)
  if(whn) then handle_found = 1

; Determine the "parent variable" component_0
  cond0=buf.(vvar_index).COMPONENT_0 
  if (handle_found) then x0=execute('handle_value, buf.'+cond0+'.HANDLE,parent') $
	else x0=execute('parent =  buf.'+cond0+'.DAT')

  psize = size(parent, /struct)
  ; create a magnitude array
  magnitude = make_array(psize.dimensions[psize.n_dimensions-1])

  if (psize.n_dimensions eq 1) then begin ;single record
	bx = parent[0]
	by = parent[1]
	bz = parent[2]
	magnitude = sqrt(bx*bx + by*by + bz*bz)
	
  endif else begin
     if (psize.n_dimensions eq 2) then begin
	num = psize.dimensions[1]-1
  
	for i=0L, num do begin

	  bx = parent[0, i]
	  by = parent[1, i]
	  bz = parent[2, i]
	  magnitude[i] = sqrt(bx*bx + by*by + bz*bz)

	endfor
     endif
  endelse

  if (handle_found eq 1) then begin
    nu_dat_handle=handle_create(value=magnitude)
    nbuf.(vvar_index).handle=nu_dat_handle
  endif else begin
    nbuf.(vvar_index).dat=magnitude
  endelse

; Check that all variables in the original variable list are declared as
; data otherwise set to metadata 
; Find variables w/ var_type == data

   status = check_myvartype(nbuf, org_names)

   return, nbuf 

endif else begin
   print, 'No valid variable found in compute_magnitude, returning -1'
   return, -1
endelse
end
;;;;;;;;;;;;;;;;;;;;;;
FUNCTION extract_array, buf, org_names, INDEX=INDEX, DEBUG=DEBUG
;
;  PURPOSE:
;
;This routine extracts the requested (by specifying index in the ARG0
;variable attribute value), the energy array given a 2-d energy
;vs. telescope array variable.  This was written specifically for the
;RBSP RBSPICE datasets, but will be applicable to others in the future.
;
; CALLING SEQUENCE:
;
;          new_buf = extract_array(buf,org_names, INDEX=INDEX)
;
; VARIABLES:
;
; Input:
;
;  buf        - an IDL structure built w/in read_myCDF
;  org_names  - list of original variables input to read_myCDF. Any
;               variables in this list will remain tagged as 
;               VAR_TYPE= data otherwise VAR_TYPE = support_data.
;
; Output:
;
;  new_buf    - an IDL structure containing the populated virtual 
;               variable 
; Constants:
;
;  none
;  
; Keyword Parameters: 
;	INDEX : this can be set the structure variable index # for which
;	you'd like this conversion.  If this isn't set we'll look for the
;	epoch variable.
;  Looks for a new variable attribute called ARG0 - for the array
;  index value to be used for the
;
; REQUIRED PROCEDURES:
;
;   none 
; 
;-------------------------------------------------------------------
; History
;
;         1.0  T. Kovalick 10/31/2012
;		Initial version
;
;-------------------------------------------------------------------

 status=0

; Establish error handler
 catch, error_status
 if(error_status ne 0) then begin
   print, "ERROR= number: ",error_status," in compute_energy function"
   print, "ERROR= Message: ",!ERR_STRING
   status = -1
   return, status
 endif
  
 org_names=strupcase(org_names)
 if keyword_set(DEBUG) then DEBUG=1L else DEBUG=0L

;Get the virtual variables index #.
 if (n_elements(INDEX) gt 0) then vvar_index = INDEX else print, 'No virtual variable specified.'

 if (vvar_index ge 0) then begin

  nbuf=buf 
  
  names = tag_names(buf.(vvar_index))
  handle_found = 0

; Check to see if HANDLE is a tag name
  wh=where(names eq 'HANDLE',whn)
  if(whn) then handle_found = 1

; Determine the array element to pull out
  t = 0
  t = buf.(vvar_index).ARG0

; Determine the "parent variable" component_0
  cond0=buf.(vvar_index).COMPONENT_0 
  if (handle_found) then x0=execute('handle_value, buf.'+cond0+'.HANDLE,parent') $
	else x0=execute('parent =  buf.'+cond0+'.DAT')

  evarname = buf.(vvar_index).varname

;  print, 'variable name requesting values = ',evarname
;  print, 'array index = ',t
  psize = size(parent, /struct)

  if (psize.n_dimensions eq 2) then begin
     ; create a energy array
     energy = make_array(psize.dimensions[0])
     energy = parent[*, t-1] ; fill array
  endif

  if (handle_found eq 1) then begin
    nu_dat_handle=handle_create(value=energy)
    nbuf.(vvar_index).handle=nu_dat_handle
  endif else begin
    nbuf.(vvar_index).dat=energy
  endelse

; Check that all variables in the original variable list are declared as
; data otherwise set to metadata 
; Find variables w/ var_type == data

   status = check_myvartype(nbuf, org_names)

   return, nbuf 

endif else begin
   print, 'No valid variable found in extract_array, returning -1'
   return, -1
endelse
end
;;;;;;;;;;;;;;;;;;;;;;;;;;;
;+
; NAME: Function HEIGHT_ISIS
;
; PURPOSE: Retrieve only height from vector geo_coord:
; (lat1, lon1, height1, lat2, lon2, height2, lat3, lon3, height3, .....)
;
; CALLING SEQUENCE:
;
;          new_buf = height_isis(buf,org_names,index)
;
; VARIABLES:
;
; Input:
;
;  buf        - an IDL structure built w/in read_myCDF
;  org_names  - list of original variables input to read_myCDF. Any
;               variables in this list will remain tagged as 
;               VAR_TYPE= data otherwise VAR_TYPE = support_data.
;  index      - variable index, so we deal with one variable at a time.
;
; Output:
;
;  new_buf    - an IDL structure containing the populated virtual 
;               variable 
;
; History: Written by RCJ 09/01, based on crop_image
;-

function height_isis, buf, org_names, index=index
;
status=0
print, 'In Height_isis'

; Establish error handler
catch, error_status
if(error_status ne 0) then begin
   print, "ERROR= number: ",error_status," in height_isis"
   print, "ERROR= Message: ",!ERR_STRING
   status = -1
   return, status
endif

tagnames = tag_names(buf)
tagnames1=tag_names(buf.(index))

; look for the COMPONENT_0 attribute tag for this VV.
if(tagindex('COMPONENT_0', tagnames1) ge 0) then $
   component0=buf.(index).COMPONENT_0

; Check if the component0 variable exists 
component0_index = tagindex(component0,tagnames)

; get coordinates
handle_value,buf.(component0_index).handle,geo_coord

; get height from coordinates
height=0
;  RCJ 06/05/2014  Small change in read_myCDF (look for valid_recs_isis)
;   prompted this change. array = [0, lat, lon, height, lat, lon, height, etc..]  
; Old line:  for i=2L,n_elements(geo_coord)-1,3 do height=[height,geo_coord[i]]
for i=3L,n_elements(geo_coord)-1,3 do height=[height,geo_coord[i]]
; RCJ 10/01/2003 I would start the height array at [1:*] to eliminate the first
; 0 but a few more 0's come from read_mycdf so I have to start it at [2:*] :
;height=height[2:*]
; RCJ 06/05/2014  Small change in read_myCDF (look for valid_recs_isis) 
;  made this right again.
height=height[1:*]
buf.(index).handle=handle_create()
handle_value,buf.(index).handle,height,/set

; Check that all variables in the original variable list are declared as
; data otherwise set to support_data
; Find variables w/ var_type == data
status = check_myvartype(buf, org_names)

return, buf
;

end 

;+
; NAME: Function FLIP_IMAGE
;
; PURPOSE: Flip_image [*,*] 
;
; CALLING SEQUENCE:
;
;          new_buf = flip_image(buf,org_names,index)
;
; VARIABLES:
;
; Input:
;
;  buf        - an IDL structure built w/in read_myCDF
;  org_names  - list of original variables input to read_myCDF. Any
;               variables in this list will remain tagged as 
;               VAR_TYPE= data otherwise VAR_TYPE = support_data.
;  index      - variable index, so we deal with one variable at a time.
;  direction  - IDL's 'rotate' input to determine which rotation and 'flip' to apply
;
;
; Output:
;
;  new_buf    - an IDL structure containing the populated virtual 
;               variable 
;
; History: Written by TJK 01/03 for use w/ IDL RPI data
;          RCJ 29May2020  Added keyword direction to be able to use 
;                         options from idl's 'rotate'
;-

function flip_image, buf, org_names, index=idx, direction=dir
status=0
; Establish error handler
catch, error_status
if(error_status ne 0) then begin
   print, "ERROR= number: ",error_status," in flip_image"
   print, "ERROR= Message: ",!ERR_STRING
   status = -1
   return, status
endif

if not keyword_set(dir) then dir=4 
;  These are the options (mostly from idl's help) :
;  Read the IDL help page note, applying rotation to image and array are not quite the same...
; Direction, Transpose?, Rot CCW, x1, y1, what it does to an image?
; 0          No          None     X0  Y0  
; 1          No          90deg   -Y0  X0  rotate 90 deg CCW
; 2          No         180deg   -X0 -Y0  rotate 180 deg CCW
; 3          No         270deg    Y0 -X0  rotate 270 deg CCW
; 4          Yes         None     Y0  X0  rotate 90 deg CCW and flip on vert axis (default here since it was in the original flip_image)
; 5          Yes         90deg   -X0  Y0  rotate 180 deg CCW and flip on horiz axis
; 6          Yes        180deg   -Y0 -X0  rotate 270 deg CCW and flip on vert axis
; 7          Yes        270deg    X0 -Y0  no rotation, just flip on horiz axis


tagnames = tag_names(buf)
tagnames1=tag_names(buf.(idx))

; look for the COMPONENT_0 attribute tag for this VV.
if(tagindex('COMPONENT_0', tagnames1) ge 0) then $
   component0=buf.(idx).COMPONENT_0

; Check if the component0 variable exists (this is the parent variable)
index = tagindex(component0,tagnames)

if (index ge 0) then begin
; Check to see if HANDLE a tag name
 handle_found = 0
 wh=where(tagnames1 eq 'HANDLE',whn)
 if(whn) then begin
  handle_found = 1
  handle_value, buf.(index).HANDLE,idat 
  datsz=size(idat)
 endif else begin
  idat=buf.(index).dat
 endelse

 isize = size(idat) ; determine the number of images in the data
 if (isize[0] eq 2) then nimages = 1 else nimages = isize[isize[0]]

;print,'Flip_image DEBUG', min(idat, max=dmax) & print, dmax

 for i = 0L, nimages-1 do begin
   if (nimages eq 1) then begin 
       ;idat2 = rotate(idat,4)
       idat2 = rotate(idat,dir)
   endif else if ((nimages gt 1) and (i eq 0)) then begin
       ;set up an array to handle the "rotated images"
       dims = size(idat,/dimensions)
       dtype = size(idat,/type)
       ;TJK - 05/29/2003 originally just used this routine for images/byte arrays, 
       ;now expanding its use for any type of array.  Add the use of the /nozero
       ;keyword so that the make_array routine won't waste extra time setting every
       ;element to zero, since we're going to set the values in the next line.
       ;       idat2 = bytarr(dims(1),dims(0),dims(2))
       idat2 = make_array(dims[1],dims[0],dims[2], type=dtype, /nozero)
       ;idat2[*,*,i] = rotate(idat[*,*,i],4)
       idat2[*,*,i] = rotate(idat[*,*,i],dir)
    endif else begin
       ;idat2[*,*,i] = rotate(idat[*,*,i],4)
       idat2[*,*,i] = rotate(idat[*,*,i],dir)
    endelse
 endfor

;print, 'Flip_image DEBUG', min(idat2, max=dmax) & print, dmax

    idat = idat2
    idat2 = 0 ;clear this array out
  
  if (handle_found eq 1) then begin
    nu_dat_handle=handle_create(value=idat)
    buf.(idx).handle=nu_dat_handle
  endif else begin
    buf.(idx).dat=idat ;TJK this doesn't work (have to use a handle)
  endelse

; Check that all variables in the original variable list are declared as
; data otherwise set to support_data
; Find variables w/ var_type == data

status = check_myvartype(buf, org_names)
endif else buf = -1

return, buf
end

;---------------------------------------------------------------------------
function wind_plot, buf,org_names,index=index

status=0

; Establish error handler
catch, error_status
if(error_status ne 0) then begin
   print, "ERROR= number: ",error_status," in wind_plot"
   print, "ERROR= Message: ",!ERR_STRING
   status = -1
   return, status
endif

; Find virtual variables
vvtag_names=strarr(1) 
vvtag_indices = vv_names(buf,NAMES=vvtag_names)
if(vvtag_indices[0] lt 0) then begin
  print, "ERROR= No VIRTUAL variable found in wind_plot"
  print, "ERROR= Message: ",vvtag_indices[0]
  status = -1
  return, status
endif

tagnames = tag_names(buf)
tagnames1=tag_names(buf.(index))

;now look for the COMPONENT_0 and 1 attributes tag for this VV.
if(tagindex('COMPONENT_0', tagnames1) ge 0) then $
   component0=buf.(index).COMPONENT_0
if(tagindex('COMPONENT_1', tagnames1) ge 0) then $
   component1=buf.(index).COMPONENT_1
; Check if the component0 and 1 variables exist: 
component0_index = tagindex(component0,tagnames)
component1_index = tagindex(component1,tagnames)
if((component0_index ge 0 )and (component1_index ge 0)) then begin
   if(tagindex('HANDLE',tagnames1) ge 0) then begin
      handle_value,buf.(component0_index).handle,zone
      handle_value,buf.(component1_index).handle,meri
      sz=size(zone)
      wind=fltarr(2,sz[2])
      alt=(strtrim(strmid(org_names[index],strlen(org_names[index])-3,3),2))*1
      handle_value,buf.alt_retrieved.handle,altr
      q=where(altr eq alt)
      wind[0,*]=reform(zone[q[0],*])
      wind[1,*]=reform(meri[q[0],*])
      buf.(index).handle=handle_create()
      handle_value,buf.(index).HANDLE,wind,/set
   endif else print, "Set /NODATASTRUCT keyword in call to read_myCDF";
endif else begin
   print, "ERROR= No COMPONENT0 and/or 1 variable found in wind_plot"
   print, "ERROR= Message: ",component0_index, component1_index
   status = -1
   return, status
endelse 

   ; Check that all variables in the original variable list are declared as
   ; data otherwise set to support_data
   ; Find variables w/ var_type == data

   status = check_myvartype(buf, org_names)

return, buf
end ; end of wind_plot

FUNCTION comp_epoch, buf, org_names, index=index, DEBUG=DEBUG

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;  PURPOSE:
;
;Compute the epoch values from two other variables
;In the case of THEMIS, this is samp_time_sec (time in seconds
;since Jan 1, 2001) Plus samp_time_subsec, which is 1/65536 sec.
;
; CALLING SEQUENCE:
;
;          new_buf = comp_epoch(buf,org_names,index=index)
;
; VARIABLES:
;
; Input:
;
;  buf        - an IDL structure built w/in read_myCDF
;  org_names  - list of original variables input to read_myCDF. Any
;               variables in this list will remain tagged as 
;               VAR_TYPE= data otherwise VAR_TYPE = support_data.
;
; Output:
;
;  new_buf    - an IDL structure containing the populated virtual 
;               variable 
; Constants:
;
;
; Keyword Parameters: 
; index of variable to populate.
;
; REQUIRED PROCEDURES:
;
;   none 
; 
;-------------------------------------------------------------------
; History
;
;         1.0  T. Kovalick 5/15/2006
;		Initial version
;
;-------------------------------------------------------------------
print, 'DEBUG, In comp_epoch'
 status=0

; Establish error handler
 catch, error_status
 if(error_status ne 0) then begin
   print, "ERROR= number: ",error_status," in comp_epoch"
   print, "ERROR= Message: ",!ERR_STRING
   status = -1
   return, status
 endif
  
 org_names=strupcase(org_names)
 if keyword_set(DEBUG) then DEBUG=1L else DEBUG=0L

;Get the virtual variables index #.
 if (n_elements(INDEX) gt 0) then vvar_index = INDEX else print, 'No virtual variable specified.'

 if (vvar_index ge 0) then begin

  nbuf=buf 
  
  epoch_names = tag_names(buf.(vvar_index))
  handle_found = 0

; Check to see if HANDLE is a tag name
  wh=where(epoch_names eq 'HANDLE',whn)
  if(whn) then handle_found = 1

; Determine the "parent variable" component_0
  cond0=buf.(vvar_index).COMPONENT_0 
  if (handle_found) then x0=execute('handle_value, buf.'+cond0+'.HANDLE,parent_times') $
	else x0=execute('parent_times =  buf.'+cond0+'.DAT')

; Determine the "parent variable's sidekick" component_1
  cond1=buf.(vvar_index).COMPONENT_1 
  if (handle_found) then x0=execute('handle_value, buf.'+cond1+'.HANDLE,parent_subsec') $
	else x0=execute('parent_subsec =  buf.'+cond1+'.DAT')

  num = n_elements(parent_times)
  shifted_times = make_array(num, /double)
  subsec_times = make_array(num, /double)

  for i=0L, num-1 do begin
;get base THEMIS time (Jan, 1, 2001)
      cdf_epoch, base, 2001, 1, 1, 0, 0, 0, 0,/compute_epoch
      subsec_times[i] = ((double(parent_subsec[i])/65536)*1000D)
      shifted_times[i] = base + (double(parent_times[i])*1000D) + subsec_times[i]
      cdf_epoch, shifted_times[i], yr,mo,d,hr,mm,ss,mil,/breakdown
  endfor
  if (handle_found eq 1) then begin
    nu_dat_handle=handle_create(value=shifted_times)
    nbuf.(vvar_index).handle=nu_dat_handle
  endif else begin
    nbuf.(vvar_index).dat=shifted_times
  endelse

; Check that all variables in the original variable list are declared as
; data otherwise set to metadata 
; Find variables w/ var_type == data

   status = check_myvartype(nbuf, org_names)

   return, nbuf 

endif else begin
   print, 'No valid variable found in comp_epoch, returning -1'
   return, -1
endelse

end 

FUNCTION comp_themis_epoch, buf, org_names, index=index, DEBUG=DEBUG, $
                            sixteen=sixteen, MSEC=MSEC

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;  PURPOSE:
;
;Compute the epoch values from two other variables, a base date,
;e.g. Jan 1, 1970 and a time offset in seconds that will be added to
;the base.
;
; CALLING SEQUENCE:
;
;          new_buf = comp_themis_epoch(buf,org_names,index=index)
;
; VARIABLES:
;
; Input:
;
;  buf        - an IDL structure built w/in read_myCDF
;  org_names  - list of original variables input to read_myCDF. Any
;               variables in this list will remain tagged as 
;               VAR_TYPE= data otherwise VAR_TYPE = support_data.
;
; Output:
;
;  new_buf    - an IDL structure containing the populated virtual 
;               variable 
;
; Constants:
;
;
; Keyword Parameters: 
; index - index of variable to populate.
; sixteen   - if specified, epoch16 values will be computed and
;               returned
;             if not, regular epoch values are computed.
; MSEC - Set MSEC if the component_1 variable values are in
;        milliseconds instead of seconds (ICON).
; REQUIRED PROCEDURES:
;
;   none 
; 
;-------------------------------------------------------------------
; History
;
;         1.0  T. Kovalick 5/15/2006
;		Initial version
;
;-------------------------------------------------------------------
;print, 'DEBUG, In comp_themis_epoch'
 status=0

; Establish error handler
; catch, error_status
; if(error_status ne 0) then begin
;   print, "ERROR= number: ",error_status," in comp_themis_epoch"
;   print, "ERROR= Message: ",!ERR_STRING
;   status = -1
;   return, status
; endif
  
 org_names=strupcase(org_names)
 if keyword_set(DEBUG) then DEBUG=1L else DEBUG=0L

;Get the virtual variables index #.
 if (n_elements(INDEX) gt 0) then vvar_index = INDEX else print, 'No virtual variable specified.'
 if keyword_set(SIXTEEN) then sixteen = 1L else sixteen = 0L
 if keyword_set(MSEC) then MSEC = 1L else MSEC = 0L

 if (vvar_index ge 0) then begin

  nbuf=buf 

  epoch_names = tag_names(buf.(vvar_index))
  handle_found = 0

; Check to see if HANDLE is a tag name
  wh=where(epoch_names eq 'HANDLE',whn)

 if(whn) then handle_found = 1

; Determine the "parent variable" component_0
  cond0=buf.(vvar_index).COMPONENT_0 
  if (handle_found) then x0=execute('handle_value, buf.'+cond0+'.HANDLE,base_time') $
	else x0=execute('base_time =  buf.'+cond0+'.DAT')

; Determine the "parent variable's sidekick" component_1
  cond1=buf.(vvar_index).COMPONENT_1 

;TJK 11/21/2008 - add check for whether the seconds variable handle is
;                 valid (greater than 0) - if not no data exists, get out

  if (handle_found) then x0 = execute('hv = buf.'+cond1+'.HANDLE') $
	else x0=execute('hv =  buf.'+cond1+'.DAT')

  if (hv[0] gt 0) then begin
  if (handle_found) then x0=execute('handle_value, buf.'+cond1+'.HANDLE,seconds') $
	else x0=execute('seconds =  buf.'+cond1+'.DAT')

  num = n_elements(seconds)
  shifted_times = make_array(num, /double)
;  print, 'base_time = ', base_time
;  cdf_epoch, base_time, yr,mo,d,hr,mm,ss,mil,/breakdown
;  print, 'base date ',yr,mo,d,hr,mm,ss,mil
  if (sixteen) then begin
      shifted_times = make_array(num, /dcomplex)
      psec_scale=1.e12
      cdf_epoch, base_time, yr,mo,dd,hr,mm,ss,mil,/break
      cdf_epoch16, base_time16, yr,mo,dd,hr,mm,ss,mil,0,0,0,/compute
  endif
;  print, 'Inside comp_themis_epoch, number of records will be ',num

  eps=buf.(vvar_index).fillval*1d-6
  for i=0L, num-1 do begin
    ;subsec = (seconds[i]-LONG64(seconds[i]))
    ;  RCJ 08Feb2018  Added a test before calculating subsec to avoid IDL error
    ;        if seconds is fillval or NaN
    if (finite(seconds[i]) or $
       (seconds[i] gt buf.(vvar_index).fillval+eps or seconds[i] lt buf.(vvar_index).fillval-eps)) then $
              subsec = (seconds[i]-floor(seconds[i],/l64)) else subsec=0.d0
    
    if (sixteen) then begin ; compute the shifted time as epoch16      
      psecs = subsec*psec_scale
      ;shifted_times[i] = DCOMPLEX(REAL_PART(base_time16)+LONG64(seconds[i]), IMAGINARY(base_time16)+ psecs)
      shifted_times[i] = DCOMPLEX(REAL_PART(base_time16)+floor(seconds[i],/l64), IMAGINARY(base_time16)+ psecs)
                                  
;      cdf_epoch16, shifted_times[i], yr,mo,dd,hr,mm,ss,mil,micro,nano,pico,/break
;      print,yr,mo,dd,hr,mm,ss,mil,micro,nano,pico

    endif else begin
      ;TJK 11/21/2017 - add chec for MSEC keyword - if set seconds is really milliseconds
      if finite(seconds[i]) then begin ;test to see if the seconds value is good
        if (MSEC) then shifted_times[i] = base_time + seconds[i] $
                  else shifted_times[i] = base_time + (seconds[i]*1000D) 
      endif else begin
          shifted_times[i] =  -1.0e+31 ;set the value to fill
          cdf_epoch, shifted_times[i], yr,mo,dd,hr,mm,ss,mil,/break
          print, '** From comp_themis_epoch, seconds = ',seconds[i],' index = ', i
          print, '** Epoch being set to -1.0e+31, year, month, day, etc ',yr,mo,dd,hr,mm,ss,mil
      endelse

    endelse

endfor

;TJK 11/21/2008 add else to if no valid handle value found for the time variable
;get the fill value and set it to "shifted_times"
endif else begin
  shifted_times = buf.(vvar_index).fillval
  print, 'DEBUG - In comp_themis_epoch, no epoch found, set to fill ',shifted_times
endelse

  if (handle_found eq 1) then begin
   if hv eq 0 then begin
      ; RCJ 20Sep2018   If hv=0 -> component_1 has a handle of 0 ! This causes errors when listing data
      ;  So remove the var from the structure and also the var dependent on this component
      ;  but leave component_0 alone since it's needed for other vars
      ;  This came about because of dataset thg_l1_ask, where a given ground station
      ;  could simply not be present in the data cdf.
      print,'WARNING: Virtual_funcs: Var does not exist in cdf, removing var from structure'
      nbuf=create_struct(nbuf,remove=(where(tag_names(nbuf) eq strupcase(cond1)))[0])
      nbuf=create_struct(nbuf,remove=(where(tag_names(nbuf) eq strupcase(nbuf.(vvar_index).varname)))[0])
   endif else begin   
      nu_dat_handle=handle_create(value=shifted_times)
      nbuf.(vvar_index).handle=nu_dat_handle
   endelse
  endif else begin
    nbuf.(vvar_index).dat=shifted_times
  endelse

; Check that all variables in the original variable list are declared as
; data otherwise set to metadata 
; Find variables w/ var_type == data

   status = check_myvartype(nbuf, org_names)

   return, nbuf 

endif else begin
   print, 'No valid variable found in comp_themis_epoch, returning -1'
   return, -1
endelse

end 
;-------------------------------------------------------------
function error_bar_array, buf, index=index, value=value
;
; RCJ Apr 2008 Given a fixed uncertainty value, an array
; will be generated, the size of the component_0 var, and 
; the array will be populated w/ that value.
;
tagnames=tag_names(buf)
tagnames1=tag_names(buf.(index))
if(tagindex('COMPONENT_0', tagnames1) ge 0) then $
              component0=buf.(index).COMPONENT_0
component0_index = tagindex(component0,tagnames)
if(component0_index ge 0) then begin
   if(tagindex('HANDLE',tagnames1) ge 0) then begin
        handle_value,buf.(component0_index).HANDLE,comp0
	sz=size(comp0,/n_elements)
	er=fltarr(sz) & er[*]=value
	buf.(index).handle=handle_create()
	handle_value,buf.(index).handle,er,/set
   endif else begin
      print, "ERROR= No COMPONENT0 variable found in error_bar_array"
      print, "ERROR= Message: ",component0_index
      status = -1
      return, status
   endelse 
endif
return,buf
;
end


FUNCTION convert_toev, buf, org_names, index=index, DEBUG=DEBUG

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;  PURPOSE:
;
;Convert the Electron Velocity into Electron Energy
;
; CALLING SEQUENCE:
;
;          new_buf = convert_toeV(buf,org_names,index=index)
;
; VARIABLES:
;
; Input:
;
;  buf        - an IDL structure built w/in read_myCDF
;  org_names  - list of original variables input to read_myCDF. Any
;               variables in this list will remain tagged as 
;               VAR_TYPE= data otherwise VAR_TYPE = support_data.
;
; Output:
;
;  new_buf    - an IDL structure containing the populated virtual 
;               variable 
; Constants:
;
;
; Keyword Parameters: 
; index of variable to populate.
;
; REQUIRED PROCEDURES:
;
;   none 
; 
;-------------------------------------------------------------------
; History
;
;         1.0  T. Kovalick 7/1/2008
;		Initial version
;
;-------------------------------------------------------------------
print, 'DEBUG, In convert_toev'
 status=0

; Establish error handler
 catch, error_status
 if(error_status ne 0) then begin
   print, "ERROR= number: ",error_status," in convert_toev"
   print, "ERROR= Message: ",!ERR_STRING
   status = -1
   return, status
 endif
  
 org_names=strupcase(org_names)
 if keyword_set(DEBUG) then DEBUG=1L else DEBUG=0L

;Get the virtual variables index #.
 if (n_elements(INDEX) gt 0) then vvar_index = INDEX else print, 'No virtual variable specified.'

 if (vvar_index ge 0) then begin

  nbuf=buf 
  
  velh = tag_names(buf.(vvar_index))
  handle_found = 0

; Check to see if HANDLE is a tag name
  wh=where(velh eq 'HANDLE',whn)
  if(whn) then handle_found = 1

; Determine the "parent variable" component_0
  cond0=buf.(vvar_index).COMPONENT_0 
  if (handle_found) then begin
      x0=execute('handle_value, buf.'+cond0+'.HANDLE,velocity') 
      x0=execute('fillval = buf.'+cond0+'.fillval')
print, 'velocity fillvalu = ',fillval 
  endif else begin
      x0=execute('velocity =  buf.'+cond0+'.DAT')
  endelse

  num = n_elements(velocity)
  energy = velocity ;want the same data type and array sizes
  
  for i=0L, num-1 do begin
      if (velocity[i] ne fillval) then energy[i] = (velocity[i] / 0.593098E+08)^2
  endfor

  if (handle_found eq 1) then begin
    nu_dat_handle=handle_create(value=energy)
    nbuf.(vvar_index).handle=nu_dat_handle
  endif else begin
    nbuf.(vvar_index).dat=energy
  endelse

; Check that all variables in the original variable list are declared as
; data otherwise set to metadata 
; Find variables w/ var_type == data

   status = check_myvartype(nbuf, org_names)

   return, nbuf 

endif else begin
   print, 'No valid variable found in convert_toev, returning -1'
   return, -1
endelse

end 





FUNCTION spdf_compute_mean, buf, org_names, index=index, DEBUG=DEBUG

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;  PURPOSE:
;
;Compute mean value 
;
; CALLING SEQUENCE:
;
;          new_buf  = spdf_compute_mean(buf,org_names,index=index)
;
; VARIABLES:
;
; Input:
;
;  buf        - an IDL structure built w/in read_myCDF
;  org_names  - list of original variables input to read_myCDF. Any
;               variables in this list will remain tagged as 
;               VAR_TYPE= data otherwise VAR_TYPE = support_data.
;
; Output:
;
;  new_buf    - an IDL structure containing the populated virtual 
;               variable 
; Constants:
;
;
; Keyword Parameters: 
; index of variable to populate.
;
; REQUIRED PROCEDURES:
;
;   none 
; 
;-------------------------------------------------------------------
; History
;
;         1.0  C. Gladney 10/03/2018
;		Initial version
;
;-------------------------------------------------------------------

 ;print, 'DEBUG, In spdf_compute_mean'
 status=0
; Establish error handler
 catch, error_status
 if(error_status ne 0) then begin
   print, "ERROR= number: ",error_status," in spdf_compute_mean"
   print, "ERROR= Message: ",!ERR_STRING
   status = -1
   return, status
 endif
  
 org_names=strupcase(org_names)
 if keyword_set(DEBUG) then DEBUG=1L else DEBUG=0L
;Get the virtual variables index #.
 if (n_elements(INDEX) gt 0) then vvar_index = INDEX else print, 'No virtual variable specified.'

 if (vvar_index ge 0) then begin

  nbuf=buf 
  velh = tag_names(buf.(vvar_index))
  handle_found = 0
; Check to see if HANDLE is a tag name
  wh=where(velh eq 'HANDLE',whn)
  if(whn) then handle_found = 1

; Determine the "parent variable" component_0
  cond0=buf.(vvar_index).COMPONENT_0 
  if (handle_found) then begin
      x0=execute('handle_value, buf.'+cond0+'.HANDLE,dataVals') 
      x0=execute('fillval = buf.'+cond0+'.fillval')
      ;print, 'fillvalue = ',fillval 
  endif else begin
      x0=execute('dataVals =  buf.'+cond0+'.DAT')
  endelse
  
  meanDataVals = dataVals[0,*]
  meanDataVals = REFORM(meanDataVals)
  numRows = n_elements(meanDataVals) 
  arrSize = size(dataVals)
  numCols = arrSize[1] ;determine how many dimensions we are averaging across  
  validmin = buf.(index).validmin
  validmax = buf.(index).validmax
  
  for i=0L, numRows-1 do begin
      ;initialize variables
      sum = 0 
      summedCols = 0
      
      for j=0L, numCols-1 do begin
        if (dataVals[j,i] GE validmin) && (dataVals[j,i] LE validmax) then begin
          sum = sum + dataVals[j,i]
          summedCols = summedCols+1
        endif
      endfor
            
      if summedCols EQ 0 then meanDataVals[i] = fillval else meanDataVals[i] = sum/summedCols ;Setting meanDataVals = fillval whenever no values given to us are within the range of [validmin,validmax]
  endfor
 
  if (handle_found eq 1) then begin
    nu_dat_handle=handle_create(value=meanDataVals)
    nbuf.(vvar_index).handle=nu_dat_handle
  endif else begin
    nbuf.(vvar_index).dat=meanDataVals
  endelse

; Check that all variables in the original variable list are declared as
; data otherwise set to metadata 
; Find variables w/ var_type == data
   status = check_myvartype(nbuf, org_names)
   return, nbuf 

endif else begin
   print, 'No valid variable found in spdf_compute_mean, returning -1'
   return, -1
endelse

end 








FUNCTION convert_Ni, buf, org_names, index=index, DEBUG=DEBUG

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;  PURPOSE:
;
;Convert the Log of total ion density to regular ion density
;
; CALLING SEQUENCE:
;
;          new_buf = convert_Ni(buf,org_names,index=index)
;
; VARIABLES:
;
; Input:
;
;  buf        - an IDL structure built w/in read_myCDF
;  org_names  - list of original variables input to read_myCDF. Any
;               variables in this list will remain tagged as 
;               VAR_TYPE= data otherwise VAR_TYPE = support_data.
;
; Output:
;
;  new_buf    - an IDL structure containing the populated virtual 
;               variable 
; Constants:
;
;
; Keyword Parameters: 
; index of variable to populate.
;
; REQUIRED PROCEDURES:
;
;   none 
; 
;-------------------------------------------------------------------
; History
;
;         1.0  T. Kovalick 7/1/2008
;		Initial version
;
;-------------------------------------------------------------------
print, 'DEBUG, In convert_Ni'
 status=0

; Establish error handler
 catch, error_status
 if(error_status ne 0) then begin
   print, "ERROR= number: ",error_status," in convert_Ni"
   print, "ERROR= Message: ",!ERR_STRING
   status = -1
   return, status
 endif
  
 org_names=strupcase(org_names)
 if keyword_set(DEBUG) then DEBUG=1L else DEBUG=0L

;Get the virtual variables index #.
 if (n_elements(INDEX) gt 0) then vvar_index = INDEX else print, 'No virtual variable specified.'

 if (vvar_index ge 0) then begin

  nbuf=buf 
  
  var = tag_names(buf.(vvar_index))
  handle_found = 0

; Check to see if HANDLE is a tag name
  wh=where(var eq 'HANDLE',whn)
  if(whn) then handle_found = 1

; Determine the "parent variable" component_0
  cond0=buf.(vvar_index).COMPONENT_0 
  if (handle_found) then begin
      x0=execute('handle_value, buf.'+cond0+'.HANDLE,log_density') 
      x0=execute('fillval = buf.'+cond0+'.fillval')
print, 'log_density fillvalu = ',fillval 
  endif else begin
      x0=execute('log_density =  buf.'+cond0+'.DAT')
  endelse

  num = n_elements(log_density)
  density = log_density ;want the same data type and array sizes
  
  for i=0L, num-1 do begin
      if (density[i] ne fillval) then density[i] = 10^(log_density[i])
  endfor

  if (handle_found eq 1) then begin
    nu_dat_handle=handle_create(value=density)
    nbuf.(vvar_index).handle=nu_dat_handle
  endif else begin
    nbuf.(vvar_index).dat=density
  endelse

; Check that all variables in the original variable list are declared as
; data otherwise set to metadata 
; Find variables w/ var_type == data

   status = check_myvartype(nbuf, org_names)

   return, nbuf 

endif else begin
   print, 'No valid variable found in convert_Ni, returning -1'
   return, -1
endelse

end 


;---------------------------------------------------------------
;+
; NAME: Function CONV_POS_HUNGARIAN 
;
; PURPOSE: Convert cl_sp_aux positions x,y,z from GSE to GEI (GCI).
;          It could be confusing to the user that the GSE positions
;          are given in 'reference s/c position' and 'delta s/c positions'
;          while all GEI positions will be their real positions, ie, no
;          reference s/c and no deltas. 
;
; INPUT:
;    buf           an IDL structure
;    org_names     an array of original variables sent to read_myCDF
;    index	   variable position in buf
;
; CALLING SEQUENCE:
;
;         newbuf = conv_pos_hungarian(buf,org_names,index=index)
;

function conv_pos_hungarian, buf, org_names,INDEX=INDEX

status=0
; Establish error handler
;catch, error_status
;if(error_status ne 0) then begin
;   print, "ERROR= number: ",error_status," in conv_pos_hungarian.pro"
;   print, "ERROR= Message: ",!ERR_STRING
;   status = -1
;   return, status
;endif
tagnames = tag_names(buf)
tagnames1=tag_names(buf.(index))

; look for the COMPONENT_0 attribute tag for this VV.
if(tagindex('COMPONENT_0', tagnames1) ge 0) then begin
   component0=buf.(index).COMPONENT_0
   ; Check if the component0 variable exists 
   component0_index = tagindex(component0,tagnames)
   ; get coordinates
   handle_value,buf.(component0_index).handle,gse_xyz
endif

; look for the COMPONENT_1 attribute tag for this VV.
if(tagindex('COMPONENT_1', tagnames1) ge 0) then begin
   component1=buf.(index).COMPONENT_1
   component1_index = tagindex(component1,tagnames)
   if (component1_index ne -1) then handle_value,buf.(component1_index).handle,gse_dx_xyz
endif

; get time values
if(tagindex('DEPEND_0', tagnames1) ge 0) then $
   depend0=buf.(index).DEPEND_0
; Check if the depend0 variable exists 
depend0_index = tagindex(depend0,tagnames)
; get time
handle_value,buf.(depend0_index).handle,depend0

; calculate xyz in gei from gse. Add delta to gse if this is s/c 1,2, or 4
if (component1_index ne -1) then gse_xyz=gse_xyz+gse_dx_xyz
gei_xyz=gse_xyz  ; actual values will be replaced

year=0 & month=0 & day=0 & hour=0 & minute=0 & sec=0 ; init params for recalc
for i=0L,n_elements(gei_xyz[0,*])-1 do begin
   recalc,year,day,hour,min,sec,epoch=depend0[i] ; setup conversion values
   ; Create scalar variables required when calling geopack routines
   geigse,xgei,ygei,zgei,gse_xyz[0,i],gse_xyz[1,i],gse_xyz[2,i],-1,depend0[i]
   ;
   gei_xyz[0,i]=xgei
   gei_xyz[1,i]=ygei
   gei_xyz[2,i]=zgei
endfor

buf.(index).handle=handle_create()
handle_value,buf.(index).handle,gei_xyz,/set
;
; Check that all variables in the original variable list are declared as
; data otherwise set to support_data
; Find variables w/ var_type == data
status = check_myvartype(buf, org_names)

return, buf
;

end


;Correct FAST DCF By
FUNCTION correct_FAST_By, buf, org_names, INDEX=INDEX, DEBUG=DEBUG

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;  PURPOSE:
;
; Sign switch is required because Westward component has incorrect 
; sign for that portion of the FAST orbit where the spacecraft is 
; moving from high to low latitudes.
; For high to low latitude orbits the spin-axis is Westward
; For low to high latitude orbist the spin-axis is Eastward
; Magnetometer data in original key-parameter files appear to be 
; in the minus spin-axis direction.
; Algorithm developed by R. J. Strangeway (UCLA), March 27,2012
;
; CALLING SEQUENCE:
;
;          new_buf = convert_Ni(buf,org_names,index=index)
;
; VARIABLES:
;
; Input:
;
;  buf        - an IDL structure built w/in read_myCDF
;  org_names  - list of original variables input to read_myCDF. Any
;               variables in this list will remain tagged as 
;               VAR_TYPE= data otherwise VAR_TYPE = support_data.
;
; Output:
;
;  new_buf    - an IDL structure containing the populated virtual 
;               variable 
; Constants:
;
;
; Keyword Parameters: 
; index of variable to populate.
;
; REQUIRED PROCEDURES:
;
;   none 
; 
;-------------------------------------------------------------------
; History
;
;         1.0  T. Kovalick March 28, 2012
;		Initial version
;
;-------------------------------------------------------------------
print, 'DEBUG, In correct_FAST_By'
 status=0

; Establish error handler
 catch, error_status
 if(error_status ne 0) then begin
   print, "ERROR= number: ",error_status," in correct_FAST_By"
   print, "ERROR= Message: ",!ERR_STRING
   status = -1
   return, status
 endif
  
 org_names=strupcase(org_names)
 if keyword_set(DEBUG) then DEBUG=1L else DEBUG=0L

;Get the virtual variables index #.
 if (n_elements(INDEX) gt 0) then vvar_index = INDEX else print, 'No virtual variable specified.'

 if (vvar_index ge 0) then begin

  nbuf=buf 
  
  var = tag_names(buf.(vvar_index))
  handle_found = 0

; Check to see if HANDLE is a tag name
  wh=where(var eq 'HANDLE',whn)
  if(whn) then handle_found = 1

; Determine the "parent variable" component_0
  cond0=buf.(vvar_index).COMPONENT_0 ; BY
  cond1=buf.(vvar_index).COMPONENT_1 ; unix_time
  cond2=buf.(vvar_index).COMPONENT_2 ; ilat
  if (handle_found) then begin
      x0=execute('handle_value, buf.'+cond0+'.HANDLE,BY') 
      x0=execute('handle_value, buf.'+cond1+'.HANDLE,unix_time') 
      x0=execute('handle_value, buf.'+cond2+'.HANDLE,ilat') 
      x0=execute('fillval = buf.'+cond0+'.fillval')
      ;print, 'BY fillvalu = ',fillval 
  endif else begin
      x0=execute('BY =  buf.'+cond0+'.DAT')
      x0=execute('unix_time =  buf.'+cond1+'.DAT')
      x0=execute('ilat =  buf.'+cond2+'.DAT')
  endelse

  num = n_elements(BY)
  correct_BY = BY ;want the same data type and array sizes

;make the corrected values here
  
; set flagged data to nans
;TJK changed test for -1.e30 to fillval
bf = where (ilat lt fillval, nf)
if (nf gt 0) then ilat[bf]=!values.f_nan
bf = where (BY lt fillval, nf)
if (nf gt 0) then BY[bf]=!values.f_nan

; set up arrays
change_flag=intarr(n_elements(ilat))
bf = where(finite(ilat),nf)
; RCJ 05/22/2012  added this portion, in case n_elements(bf) eq 1
if n_elements(bf) eq 1 then begin
   dlat=ilat
   dt=unix_time
   nxt=ilat*0.
   prv=nxt
   nxt=dlat
   prv=dlat
   dtn=unix_time*0.d0
   dtp=dtn
   dtn=dt
   dtp=dt
endif else begin   
   dlat=ilat[bf[1:nf-1L]]-ilat[bf[0:nf-2L]]
   dt=unix_time[bf[1:nf-1L]]-unix_time[bf[0:nf-2L]]
   nxt=ilat*0.
   prv=nxt
   nxt[bf[0:nf-2L]]=dlat
   prv[bf[1:nf-1L]]=dlat
   dtn=unix_time*0.d0
   dtp=dtn
   dtn[bf[0:nf-2L]]=dt
   dtp[bf[1:nf-1L]]=dt
endelse

; now set the change_flag

bc = where((nxt lt 0) and (dtn lt 7.5d0),nc)
if (nc gt 0) then change_flag[bc]=1
bc = where((prv lt 0) and (dtp lt 7.5d0),nc)
if (nc gt 0) then change_flag[bc]=1

; switch the sign of the BY (Westward component)

BY=BY*(1.-2.*change_flag)

;finished with correction

  if (handle_found eq 1) then begin
    nu_dat_handle=handle_create(value=BY)
    nbuf.(vvar_index).handle=nu_dat_handle
  endif else begin
    nbuf.(vvar_index).dat=BY
  endelse

; Check that all variables in the original variable list are declared as
; data otherwise set to metadata 
; Find variables w/ var_type == data

   status = check_myvartype(nbuf, org_names)

   return, nbuf 

endif else begin
   print, 'No valid variable found in correct_FAST_By, returning -1'
   return, -1
endelse

end 


;---------------------------------------------------------------
;+
; NAME: Function compute_cadence
;
; PURPOSE: Determine the resolution between epoch values so that one
; can easily see where the "burst" data is located.  Originally
; implemented for the messenger_mag_rtn dataset.
;
;
; INPUT:
;    buf           an IDL structure
;    org_names     an array of original variables sent to read_myCDF
;    index	   variable position in buf
;
; CALLING SEQUENCE:
;
;         newbuf = compute_cadence(buf,org_names,index=index)
;

function compute_cadence, buf, org_names,INDEX=INDEX

status=0
; Establish error handler
catch, error_status
if(error_status ne 0) then begin
   print, "ERROR= number: ",error_status," in compute_cadence"
   print, "ERROR= Message: ",!ERR_STRING
   status = -1
   return, status
endif
tagnames = tag_names(buf)
tagnames1=tag_names(buf.(index))

; look for the COMPONENT_0 attribute tag for this VV.
if(tagindex('COMPONENT_0', tagnames1) ge 0) then begin
   component0=buf.(index).COMPONENT_0
   ; Check if the component0 variable exists 
   component0_index = tagindex(component0,tagnames)
   ; get epoch
   handle_value,buf.(component0_index).handle,epoch
endif

; calculate the cadence from one epoch to the next.
num_epochs = n_elements(epoch)

; Modification made by Ron Yurow (11/13/2014)
; Check to make sure that CDF contains at least three records in order to
; correctly compute a cadence.
; Removed by Ron Yurow (11/14/2014)
; So that an actual cadence will be returned no matter how many records are
; the CDF contains.
;if (num_epochs lt 3) then begin 
;   print, "ERROR= error detected in compute_cadence"
;   print, "ERROR= Message: Not enough epoch values to correctly compute cadence values."
;   status = -1
;   return, status
;endif

cadence = make_array(num_epochs, /double)
; Modification made by Ron Yurow (11/14/2014)
; Added special cases to handle when there are only 1 or 2 epochs in the CDF
; A single epoch will result in a cadence of the FILLVAL
; Two epochs will actually result in reasonable values for cadence.
; I think .... 
case num_epochs of 
1:   cadence [0] = buf.(component0_index).fillval
2:   begin
       cadence[0] = epoch[1]-epoch[0]
       cadence[1] = epoch[1]-epoch[0]
     end
else: begin
       cadence[0] = epoch[1]-epoch[0]
       cadence[num_epochs-1] = epoch[num_epochs-1]-epoch[num_epochs-2]

       for i=1L,num_epochs-2 do begin
           if(epoch[i+1]-epoch[i]) < (epoch[i]-epoch[i-1])then $
           cadence[i] = epoch[i+1]-epoch[i] else cadence[i] = epoch[i]-epoch[i-1]
       endfor
     end
endcase

buf.(index).handle=handle_create()
handle_value,buf.(index).handle,cadence,/set
;
; Check that all variables in the original variable list are declared as
; data otherwise set to support_data
; Find variables w/ var_type == data
status = check_myvartype(buf, org_names)

return, buf
;

end

;Function: Apply_rtn_qflag
;Purpose: To use the quality variable to "filter out bad messenger 
;data points"
;Author: Tami Kovalick, Adnet, May, 2012
;
;
function apply_rtn_qflag, astruct, orig_names, index=index

;Input: astruct: the structure, created by read_myCDF that should
;		 contain at least one Virtual variable.
;	orig_names: the list of varibles that exist in the structure.
;	index: the virtual variable (index number) for which this function
;		is being called to compute.  If this isn't defined, then
;		the function will find the 1st virtual variable.

;this code assumes that the Component_0 is the "parent" variable, 
;Component_1 should be the filter/quality variable.

;astruct will contain all of the variables and metadata necessary
;to filter out the bad flux values (based on the filter variables values -
;a value != 222 or 223. 

atags = tag_names(astruct) ;get the variable names.
vv_tagnames=strarr(1)
vv_tagindx = vv_names(astruct,names=vv_tagnames) ;find the virtual vars

if keyword_set(index) then begin
  index = index
endif else begin ;get the 1st vv

  index = vv_tagindx[0]
  if (vv_tagindx[0] lt 0) then return, -1

endelse

;print, 'In Apply_rtn_qflag'
;print, 'Index = ',index
;print, 'Virtual variable ', atags(index)
;print, 'original variables ',orig_names
;help, /struct, astruct
;stop;
c_0 = astruct.(index).COMPONENT_0 ;1st component var (real flux var)

if (c_0 ne '') then begin ;this should be the real data
  var_idx = tagindex(c_0, atags)
  itags = tag_names(astruct.(var_idx)) ;tags for the real data.

  d = tagindex('DAT',itags)
    if (d[0] ne -1) then  parent_data = astruct.(var_idx).DAT $
    else begin
      d = tagindex('HANDLE',itags)
      handle_value, astruct.(var_idx).HANDLE, parent_data
    endelse
  fill_val = astruct.(var_idx).fillval

endif else print, 'Apply_rtn_qflag - parent variable not found'

data_size = size(parent_data)

if (data_size[1] gt 0) then begin 

c_0 = astruct.(index).COMPONENT_1 ; should be the quality variable

if (c_0 ne '') then begin ;
  var_idx = tagindex(c_0, atags)
  itags = tag_names(astruct.(var_idx)) ;tags for the real data.

  d = tagindex('DAT',itags)
    if (d[0] ne -1) then  quality_data = astruct.(var_idx).DAT $
    else begin
      d = tagindex('HANDLE',itags)
      handle_value, astruct.(var_idx).HANDLE, quality_data
    endelse
  
endif else print, 'Quality variable not found'

;help, quality_data
;stop;

temp = where((quality_data ne 222 and quality_data ne 223), badcnt)
if (badcnt ge 1) then begin
  print, 'found some bad rtn data, replacing ',badcnt, ' out of ', data_size[1],' values with fill.'
  parent_data[temp] = fill_val
endif else begin
  print, 'All ',astruct.(index).COMPONENT_0,' data good'
endelse

;now, need to fill the virtual variable data structure with this new data array
;and "turn off" the original variable.

;
;print, 'badcnt',badcnt
;help, parent_data
;stop;

temp = handle_create(value=parent_data)

astruct.(index).HANDLE = temp

parent_data = 1B
quality_data = 1B

; Check astruct and reset variables not in orignal variable list to metadata,
; so that variables that weren't requested won't be plotted/listed.

   status = check_myvartype(astruct, orig_names)

return, astruct

endif else return, -1 ;if there's no rtn B radial/tangent/normal data return -1

end

;Function: Apply_rtn_cadence
;Purpose: To use the quality variable to "filter out values
;when the time cadence is less than 200.
;Author: Tami Kovalick, Adnet, May, 2012
;
;
function apply_rtn_cadence, astruct, orig_names, index=index

;Input: astruct: the structure, created by read_myCDF that should
;		 contain at least one Virtual variable.
;	orig_names: the list of varibles that exist in the structure.
;	index: the virtual variable (index number) for which this function
;		is being called to compute.  If this isn't defined, then
;		the function will find the 1st virtual variable.

;this code assumes that the Component_0 is the "parent" variable, 
;Component_1 should be the filter/quality variable.

;astruct will contain all of the variables and metadata necessary
;to filter out the values where the time cadence is less than 200. 

atags = tag_names(astruct) ;get the variable names.
vv_tagnames=strarr(1)
vv_tagindx = vv_names(astruct,names=vv_tagnames) ;find the virtual vars
if keyword_set(index) then begin
  index = index
endif else begin ;get the 1st vv

  index = vv_tagindx[0]
  if (vv_tagindx[0] lt 0) then return, -1

endelse

;print, 'In Apply_rtn_cadence'
;print, 'Index = ',index
;print, 'Virtual variable ', atags(index)
;print, 'original variables ',orig_names
;help, /struct, astruct
;stop;
c_0 = astruct.(index).COMPONENT_0 ;1st component var (real variable)

if (c_0 ne '') then begin ;this should be the real data
  var_idx = tagindex(c_0, atags)
  itags = tag_names(astruct.(var_idx)) ;tags for the real data.

  d = tagindex('DAT',itags)
    if (d[0] ne -1) then  parent_data = astruct.(var_idx).DAT $
    else begin
      d = tagindex('HANDLE',itags)
      if (astruct.(var_idx).HANDLE ne 0) then begin
        handle_value, astruct.(var_idx).HANDLE, parent_data
      endif else begin ;need to call the virtual function to compute the quality variables when they don't exist
          astruct = apply_rtn_qflag(temporary(astruct),orig_names,index=var_idx)
          handle_value, astruct.(var_idx).HANDLE, parent_data
      endelse

    endelse
  fill_val = astruct.(var_idx).fillval

endif else print, 'Apply_rtn_cadence - parent variable not found'


data_size = size(parent_data)
type_code = size(parent_data,/type)

if (data_size[1] gt 0) then begin 

c_0 = astruct.(index).COMPONENT_1 ; should be the time cadence variable

if (c_0 ne '') then begin ;
  var_idx = tagindex(c_0, atags)
  itags = tag_names(astruct.(var_idx)) ;tags for the real data.

  d = tagindex('DAT',itags)
    if (d[0] ne -1) then  cadence_data = astruct.(var_idx).DAT $
    else begin
      d = tagindex('HANDLE',itags)
      if (astruct.(var_idx).HANDLE ne 0) then begin
        handle_value, astruct.(var_idx).HANDLE, cadence_data
      endif else begin ;need to call the virtual function to compute the epoch_cadence when it doesn't exist yet.
          astruct = compute_cadence(temporary(astruct),orig_names,index=var_idx)
          handle_value, astruct.(var_idx).HANDLE, cadence_data

      endelse
    endelse
  
endif else print, 'Cadence variable not defined'
temp = where((cadence_data gt 200), tcnt)
ngood = data_size[1] - tcnt
;if (tcnt ge 1) then begin
if (ngood ge 1) then begin
  print, 'removing rtn data gt 200, making a smaller array, original = ',data_size[1],' new size = ', ngood
  new_data = make_array(ngood, type=type_code)
  new_data = parent_data[temp]
endif else begin
  new_data = make_array(1, type=type_code)
  new_data[0] = fill_val
  print, 'No cadence <200 data found for ',astruct.(index).COMPONENT_0
endelse

;now, need to fill the virtual variable data structure with this new data array
;and "turn off" the original variable.

;
;print, 'tcnt',tcnt
;help, new_data
;stop;


temp = handle_create(value=new_data)

astruct.(index).HANDLE = temp
parent_data = 1B
cadence_data = 1B

; Check astruct and reset variables not in orignal variable list to metadata,
; so that variables that weren't requested won't be plotted/listed.

   status = check_myvartype(astruct, orig_names)

return, astruct

endif else return, -1 ;if there's no rtn data return -1

end

;The following code was written by Tami Kovalick (ADNET) at GSFC 
;Written on 10/21/2019 in order to flatten data stored as 1-d, but the
;the data is meant to be plotted as a time series plot (the associated
;time stamps for the expanded data are in the data cdfs, so
;they don't need to be computed).
;

function flatten_plain, sdata

sdata_type = size(sdata, /type)
sdata_dims = size(sdata, /dimensions)
new_sdata = make_array(sdata_dims[1]*sdata_dims[0], type=sdata_type, value=0)

;lay out the Sdata into one long time series
;compute the new epochs based on the base_epoch plus time_offsets for
;each base

k = 0UL ; counter for the number of elements in the new arrays (needs to be big)
for i=0,sdata_dims[1]-1 do begin
   for j=0,sdata_dims[0]-1 do begin
       new_sdata[k] = sdata[j,i]
       k = k + 1
   endfor 
endfor
return, new_sdata
end ; flatten_plain

function flatten_data_gold, astruct, org_names, INDEX=index, DEBUG=DEBUG
;
;  PURPOSE:
;
;This routine computes TT2000 epochs from the base times and the
;timeoffsets.  NEED to define the computed epoch variable in the
;master to be of type tt2000.  Also restructures the data from 
;size N elements/record out to a single dimensioned array for 
;display as a timeseries (where the original/parent data is set 
;up for a spectrogram display)
;
;
; CALLING SEQUENCE:
;
;          new_buf = flatten_data_gold(buf,org_names, INDEX=INDEX)
;
; VARIABLES:
;
; Input:
;
;  buf        - an IDL structure built w/in read_myCDF
;  org_names  - list of original variables input to read_myCDF. Any
;               variables in this list will remain tagged as 
;               VAR_TYPE= data otherwise VAR_TYPE = support_data.
;
; Output:
;
;  new_buf    - an IDL structure containing the populated virtual 
;               variable 
; Constants:
;
;  none
;  
; Keyword Parameters: 
;	INDEX : this can be set the structure variable index # for which
;	you'd like this conversion.  If this isn't set we'll look for the
;	1st variable that's defined as "virtual".
;
; REQUIRED PROCEDURES:
;
;   none 
; 
;-------------------------------------------------------------------
;
; If the index of the Virtual variable is given, us it, if not, then
; find the 1st virtual variable in the structure.
atags = tag_names(astruct) ;get the variable names.
vv_tagnames=strarr(1)
vv_tagindx = vv_names(astruct,names=vv_tagnames) ;find the virtual vars
if keyword_set(index) then begin
  index = index
endif else begin ;get the 1st vv

  index = vv_tagindx[0]
  if (vv_tagindx[0] lt 0) then return, -1

endelse

print, 'In flatten_data_gold'
print, 'original variables ',org_names
c_0 = astruct.(index).COMPONENT_0 ;1st component var (real/parent variable)

if (c_0 ne '') then begin ;this should be the real data
  var_idx = tagindex(c_0, atags)
  itags = tag_names(astruct.(var_idx)) ;tags for the real data.

  d = tagindex('DAT',itags)
    if (d[0] ne -1) then  Samples = astruct.(var_idx).DAT $
    else begin
      d = tagindex('HANDLE',itags)
      if (astruct.(var_idx).HANDLE ne 0) then $
        handle_value, astruct.(var_idx).HANDLE, Samples
    endelse
  fill_val = astruct.(var_idx).fillval
endif else print, 'flatten_data_gold - parent variable not found'

;Get the datatype to determine how to process the different types of
;data.  Doesn't seem to be any other way to determine some of this.
datatype = astruct.(var_idx).data_type
dtype = 1
;if strcmp(datatype, 'emfisis', 7, /fold_case) then dtype = 1
;if strcmp(datatype, 'TDS', 3, /fold_case) then dtype = 2
print, 'flatten_datatype ',datatype, dtype

new_samples = flatten_plain(Samples)
;help, Samples
;help, new_samples
;stop;
;Populate the samples variable in the structure
temp = handle_create(value=new_samples)
astruct.(index).HANDLE = temp

; Check buf and reset variables not in orignal variable list to metadata

   status = check_myvartype(astruct, org_names)

   return, astruct

end


;+
; NAME: Function flatten_data
;
; PURPOSE: Remove any dimensionality from data array. 
;
; DETAILED DESCRIPTION:
;
;          The flatten_data function removes any dimensionality from the data, 
;          effectively turning every element into a record with a single value.
;
; CALLING SEQUENCE:
;
;          new_buf = flatten_data (buf, org_names)
;
; VARIABLES:
;
; Input:
;
;  buf        - an IDL structure built w/in read_myCDF
;  org_names  - list of original variables input to read_myCDF. Any
;               variables in this list will remain tagged as 
;               VAR_TYPE= data otherwise VAR_TYPE = support_data.
;
; Output:
;
;  new_buf    - an IDL structure containing the populated virtual 
;               variable 
;  
; Keyword Parameters: 
;
;
; REQUIRED PROCEDURES:
;
;   none
;
; History: Written by Ron Yurow 3/3/20, based on alternate_view
;-
;-------------------------------------------------------------------------------

FUNCTION flatten_data, astruct, org_names, INDEX=index, DEBUG=DEBUG 

; Establish error handler
  catch, error_status
  IF (error_status ne 0) THEN BEGIN
   print, "ERROR= number: ",error_status," in flatten_data"
   print, "ERROR= Message: ",!ERR_STRING
   status = -1
   return, status
  ENDIF

   tagnames = tag_names(astruct)
   tagnums = n_tags(astruct)


   tagnames1 = tag_names (astruct.(index))

; now look for the COMPONENT_0 attribute tag for this VV.

    component0_index = !NULL

    IF  (tagindex('COMPONENT_0', tagnames1) ge 0) THEN BEGIN

         component0 = astruct.(index).COMPONENT_0

; Get the index of the component 0 variable. 

         component0_index = tagindex (component0, tagnames)

    endif

; and get the fill value 

    fillval = !NULL 

    IF  (tagindex('FILLVAL', tagnames1) ge 0) THEN BEGIN

        fillval = astruct.(index).FILLVAL

    ENDIF

; Make sure we got a COMPONENT_0
    IF  (component0_index ne !NULL) THEN BEGIN

        ; WARNING if /NODATASTRUCT keyword not set an error will occur here
        IF  (tagindex ('HANDLE', tagnames1) ge 0) THEN BEGIN


             ; flatten  the data. 
             handle_value, astruct.(component0_index).handle, mydata

             mydata = mydata [*]
;help, mydata
;stop
             astruct.(index).HANDLE = handle_create ()
             HANDLE_VALUE, astruct.(index).HANDLE, mydata, /SET           

        ENDIF

    ENDIF

   status = check_myvartype (astruct, org_names)

   RETURN, astruct

END
;-------------------------------------------------------------------------------

;The following code was written by Tami Kovalick (ADNET) at GSFC 
;Written on 3/8/2013 in order to expand the waveform data and times
;for a time series plot (data is structured as a spectrogram in the
;data files).
;

function expand_wave_data, astruct, org_names, INDEX=index, DEBUG=DEBUG
;
;  PURPOSE:
;
;This routine computes TT2000 epochs from the base times and the
;timeoffsets.  NEED to define the computed epoch variable in the
;master to be of type tt2000.  Also restructures the data from 
;size N elements/record out to a single dimensioned array for 
;display as a timeseries (where the original/parent data is set 
;up for a spectrogram display)
;
;
; CALLING SEQUENCE:
;
;          new_buf = expand_wave_data(buf,org_names, INDEX=INDEX)
;
; VARIABLES:
;
; Input:
;
;  buf        - an IDL structure built w/in read_myCDF
;  org_names  - list of original variables input to read_myCDF. Any
;               variables in this list will remain tagged as 
;               VAR_TYPE= data otherwise VAR_TYPE = support_data.
;
; Output:
;
;  new_buf    - an IDL structure containing the populated virtual 
;               variable 
; Constants:
;
;  none
;  
; Keyword Parameters: 
;	INDEX : this can be set the structure variable index # for which
;	you'd like this conversion.  If this isn't set we'll look for the
;	1st variable that's defined as "virtual".
;
; REQUIRED PROCEDURES:
;
;   none 
; 
;-------------------------------------------------------------------
;
; If the index of the Virtual variable is given, us it, if not, then
; find the 1st virtual variable in the structure.
atags = tag_names(astruct) ;get the variable names.
vv_tagnames=strarr(1)
vv_tagindx = vv_names(astruct,names=vv_tagnames) ;find the virtual vars
if keyword_set(index) then begin
  index = index
endif else begin ;get the 1st vv

  index = vv_tagindx[0]
  if (vv_tagindx[0] lt 0) then return, -1

endelse

;print, 'In Expand_wave_data'
;print, 'original variables ',org_names
c_0 = astruct.(index).COMPONENT_0 ;1st component var (real/parent wave variable)

if (c_0 ne '') then begin ;this should be the real data
  var_idx = tagindex(c_0, atags)
  itags = tag_names(astruct.(var_idx)) ;tags for the real data.

  d = tagindex('DAT',itags)
    if (d[0] ne -1) then  Samples = astruct.(var_idx).DAT $
    else begin
      d = tagindex('HANDLE',itags)
      if (astruct.(var_idx).HANDLE ne 0) then $
        handle_value, astruct.(var_idx).HANDLE, Samples
    endelse
  fill_val = astruct.(var_idx).fillval
endif else print, 'expand_wave_data - parent variable not found'

;Get the datatype to determine how to process the different types of
;data.  Doesn't seem to be any other way to determine some of this.
datatype = astruct.(var_idx).data_type
dtype = 1
if strcmp(datatype, 'emfisis', 7, /fold_case) then dtype = 1
if strcmp(datatype, 'TDS', 3, /fold_case) then dtype = 2
print, 'Expand_wave_datatype ',datatype, dtype

c_0 = astruct.(index).COMPONENT_1 ;2nd component var (Epoch)

if (c_0 ne '') then begin ;this should be the Epoch base value
  var_idx = tagindex(c_0, atags)
  itags = tag_names(astruct.(var_idx)) ;tags for the real data.

  d = tagindex('DAT',itags)
  if (d[0] ne -1) then  Epoch_base = astruct.(var_idx).DAT $
  else begin
    d = tagindex('HANDLE',itags)
    if (astruct.(var_idx).HANDLE ne 0) then $
        handle_value, astruct.(var_idx).HANDLE, Epoch_base
  endelse
  ;
  ; RCJ 09/01/2015  Shouldn't make Epoch (depend_0) ignore_data w/o testing. It could be
  ;     used for another requested variable.  Make array of depend_0's for 
  ;     vars that are 'data' and see if any is Epoch.  More/different tests might be needed
  ;     later.
  qq=''
  for k=0,n_elements(atags)-1 do begin
     if astruct.(k).var_type eq 'data' then qq=[qq,strupcase(astruct.(k).depend_0)]
  endfor 
  q=where(qq eq c_0) ;  c_0 always Epoch here?  
  if q[0] eq -1 then astruct.(var_idx).var_type = 'ignore_data'
  ;
  ;
  ;astruct.(var_idx).var_type = 'ignore_data'
endif else print, 'expand_wave_data - Epoch_base variable not found'

;TJK made an NRV version of the timeOffsets variable - so using this
c_0 = astruct.(index).COMPONENT_2 ;3rd component var (time_offsets)

if (c_0 ne '') then begin ;this should be the time offset values
  var_idx = tagindex(c_0, atags)
  itags = tag_names(astruct.(var_idx)) ;tags for the real data.

  d = tagindex('DAT',itags)
  if (d[0] ne -1) then  time_offsets = astruct.(var_idx).DAT $
  else begin
    d = tagindex('HANDLE',itags)
    if (astruct.(var_idx).HANDLE ne 0) then $
      handle_value, astruct.(var_idx).HANDLE, time_offsets
  endelse
  ; RCJ 09/23/2015  Same as above for component_1, make component_2 'ignore_data' if not
  ;     used for another requested variable.
  qq=''
  for k=0,n_elements(atags)-1 do begin
     if astruct.(k).var_type eq 'data' then qq=[qq,strupcase(astruct.(k).depend_0)]
  endfor 
  q=where(qq eq c_0) ;  c_0 always Epoch here?  
  if q[0] eq -1 then astruct.(var_idx).var_type = 'ignore_data'
  ;
endif else print, 'expand_wave_data - time_offsets variable not found'

;New epoch variable to be computed/created
c_0 = astruct.(index).DEPEND_0 ;1st component var (real wave variable)

if (c_0 ne '') then begin ;this should be the new Epoch variable
  new_epoch_idx = tagindex(c_0, atags)
  itags = tag_names(astruct.(new_epoch_idx)) ;tags for the new Epoch variable.
  d = tagindex('CDFTYPE',itags)
  tt2k = 0
  if (d[0] ne -1) then begin
     new_e_dtype = astruct.(new_epoch_idx).CDFTYPE
     if (new_e_dtype eq 'CDF_TIME_TT2000') then tt2k = 1
  endif

endif
;

nrec = n_elements(Epoch_base)
;lenwave= n_elements(time_offsets) ;should be 4096 
time_size= size(time_offsets) ;can use above line w/ the time_offsets varys w/ time (2-d)
lenwave = time_size[1];need the size of the 2nd dimension
; number of result records
num_new_epoch= nrec*lenwave
;new_epoch = make_array(num_new_epoch+1, /double) ; regular epoch
new_epoch = make_array(num_new_epoch, /double) ; regular epoch
need_to_convert_base = 1
if (size(Epoch_base[0],/tname) eq 'LONG64') then need_to_convert_base = 0

if (tt2k) then begin ;checks for tt2k
  new_epoch = lon64arr(num_new_epoch, /nozero) ;tt2k epoch
  if (not need_to_convert_base) then time_offsets = long64(temporary(time_offsets)) ; convert so math will work below
endif 
print, 'In expand wave data '
;convert the cdf_epoch array to cdf_tt2000's if our new_epoch
;is going to be of type tt2000 and our base epoch is cdf_epoch
if (need_to_convert_base and tt2k) then begin

  ;CDF_Epoch, Epoch_base, year,month,day,hour,minute,second,milli,micro,nano,/TOINTEGER,/BREAK
  ; RCJ 25Jul2019  cdf_epoch does not return micro or nano
  CDF_Epoch, Epoch_base, year,month,day,hour,minute,second,milli,/TOINTEGER,/BREAK
  micro=(Epoch_base-floor(Epoch_base,/l64))*1.e3
  nano=(micro-floor(micro,/l64))*1.e3
;  print, 'Epoch base value = ', year,month,day,hour,minute,second,milli,micro,nano
  CDF_TT2000, tt_Epoch_base, year,month,day,hour,minute,second,milli,micro,nano,/COMPUTE
endif

samples_type = size(samples, /type)
;new_samples = make_array(num_new_epoch+1, type=samples_type, value=0)
new_samples = make_array(num_new_epoch, type=samples_type, value=0)

;lay out the Samples into one long time series
;compute the new epochs based on the base_epoch plus time_offsets for
;each base
;TJK debug open and write computed values to a file
;openw, Ounit, 'times.txt', /get_lun
;;printf,format='(a)', Ounit, 'new voyager epoch date :'
;printf, Ounit, '       year            month           day             hour            minute           second         milli           micro             nano'
k = 0UL ; counter for the number of elements in the new arrays (needs to be big)
for i=0,nrec-1 do begin
    time_varies = 0
    if (size(time_offsets, /n_dim) eq 2) then time_varies = 1
    if (time_varies) then begin  ;time_offsets, vary w/ time
      for j=0,lenwave-1 do begin
       if (tt2k and dtype eq 2) then begin
          ;for wind tds time_offsets are in seconds so *1000000000 to get nanoseconds
          offset = long64(1000000000*time_offsets[j,i]) ; and have to call long64 or else math below doesn't happen!
          new_epoch[k] = tt_Epoch_base[i]+offset
          ;CDF_EPOCH,new_epoch[k],year,month,day,hour,minute,second,milli,micro,nano,/TOINTEGER,/BREAK
          ; RCJ 25Jul2019  cdf_epoch does not return micro or nano
          CDF_EPOCH,new_epoch[k],year,month,day,hour,minute,second,milli,/TOINTEGER,/BREAK
          micro=(new_epoch[k]-floor(new_epoch[k],/l64))*1.e3
;          print, 'new epoch date : ',year,month,day,hour,minute,second,milli,micro,nano
;          print, new_epoch[k]
       endif else begin
          new_epoch[k] = Epoch_base[i]+time_offsets[j,i]
;          CDF_EPOCH,new_epoch[k],year,month,day,hour,minute,second,milli,/BREAK
;          print, 'new epoch date : ',year,month,day,hour,minute,second,milli
       endelse
       new_samples[k] = Samples[j,i]
       k = k + 1
      endfor 

    endif else begin ;time_offsets don't vary w/ time.  For the RBSP waveform emfisis cdfs 
                                ;just use the 1st records time_offsets
                                ; OR for when there's only one
                                ; real epoch value found for
                                ; the user's request
;       print, 'Multiplying time_offset by 1000000000 to get nanoseconds '

      for j=0,lenwave-1 do begin
;       print, 'time offset = ', time_offsets[j]
       if (tt2k) then begin  
          case dtype of
             1: begin   ; for voyager
                        ;offset for voyager only needs to
                        ;convert micro to nanoseconds (*1000) 

                  offset = long64(1000*time_offsets[j]) ;voyager
                  new_epoch[k] = Epoch_base[i] + offset ; voyager

;debug lines follow to show the values used to make the new_epoch
;            CDF_tt2000,new_epoch[k],year,month,day,hour,minute,second,milli, micro, nano,/BREAK
;            printf, Ounit, 'new date', year, month, day, hour, minute, second, milli, micro, nano
;TJK DEBUG          line = string(year)+ string(month)+ string(day) + string(hour) + string(minute) + string(second) +string(milli)+string(micro)+string(nano)
;          printf, Ounit, line ;debug

             end
             2: begin ;for wind_tds tds time_offsets are in
                      ;seconds so *1000000000 to get nanoseconds
                offset = long64(1000000000*time_offsets[j]) ; and have to call long64 or else math below doesn't happen!
                ; debug print, 'offset in microseconds to be added to base = ',offset
                new_epoch[k] = tt_Epoch_base+offset
                ;CDF_EPOCH,new_epoch[k],year,month,day,hour,minute,second,milli,micro,nano,/TOINTEGER,/BREAK
                ; RCJ 25Jul2019  cdf_epoch does not return micro or nano
                CDF_EPOCH,new_epoch[k],year,month,day,hour,minute,second,milli,/TOINTEGER,/BREAK
                micro=(new_epoch[k]-floor(new_epoch[k],/l64))*1.e3

             end
             else: begin  ; where timeoffsets are already in nanoseconds
                new_epoch[k] = Epoch_base[i] + time_offsets[j]
             end

          endcase
       endif else begin ;for rbsp original case (regular cdf_epoch, not tt2k)
          new_epoch[k] = Epoch_base[i] + time_offsets[j]
       endelse

       new_samples[k] = Samples[j,i]
       k = k + 1
      endfor 
   endelse
endfor
;free_lun, Ounit ; debug

;Populate the samples variable in the structure
temp = handle_create(value=new_samples)
astruct.(index).HANDLE = temp


;Populate the new_times associated variables (Depend_0/Epoch_exapanded)
; Create handles and populated data in existing structure

c_0 = astruct.(index).DEPEND_0 ;1st component var (real wave variable)

if (c_0 ne '') then begin ;this should be the new Epoch variable
  var_idx = tagindex(c_0, atags)
  itags = tag_names(astruct.(var_idx)) ;tags for the new Epoch variable.

  temp = handle_create(value=new_epoch)
  d = tagindex('HANDLE',itags)
    if (d[0] ne -1) then  astruct.(var_idx).HANDLE = temp
  d = tagindex('DAT',itags)
    if (d[0] ne -1) then  astruct.(var_idx).DAT = new_epoch

endif else print, 'expand_wave_data - new epoch variable not found'

; Check buf and reset variables not in orignal variable list to metadata

   status = check_myvartype(astruct, org_names)

   return, astruct

end

;+
; NAME: Function make_stack_array
;
; PURPOSE: take the array of data specified by component_0
; and apply the array reduction specified in the display_type
; place the result in the return buffer.
;
; CALLING SEQUENCE:
;
;          new_buf = make_stack_array(buf,org_names)
;
; VARIABLES:
;
; Input:
;
;  astruct    - an IDL structure built w/in read_myCDF
;  org_names  - list of original variables input to read_myCDF. Any
;               variables in this list will remain tagged as
;               VAR_TYPE= data otherwise VAR_TYPE = support_data.
;  index - keyword - if set use this index value to find the virtual 
;                    variable, otherwise, find the 1st vv in the structure.
;
; Output:
;
;  new_buf    - an IDL structure containing the populated virtual
;               variable
;
; Keyword Parameters:
;
;
; REQUIRED PROCEDURES:
;
;   none
;
;-------------------------------------------------------------------
; History
;
;         1.0  T. Kovalick  ADNET     6/19/2013
;               Initial version
;
;-------------------------------------------------------------------

function make_stack_array, astruct,org_names,index=index

status=0

; Establish error handler
  catch, error_status
  if(error_status ne 0) then begin
   print, "ERROR= number: ",error_status," in make_stack_array"
   print, "ERROR= Message: ",!ERR_STRING
   status = -1
   return, status
endif

; If the index of the Virtual variable is given, use it, if not, then
; find the 1st virtual variable in the structure.
atags = tag_names(astruct) ;get the variable names.
vv_tagnames=strarr(1)
vv_tagindx = vv_names(astruct,names=vv_tagnames) ;find the virtual vars
if keyword_set(index) then begin
  index = index
endif else begin ;get the 1st vv

  index = vv_tagindx[0]
  if (vv_tagindx[0] lt 0) then return, -1

endelse

;print, 'In make_stack_array'
;print, 'original variables ',org_names
c_0 = astruct.(index).COMPONENT_0 ;1st component var (real/parent wave variable)

if (c_0 ne '') then begin ;this should be the real data
  var_idx = tagindex(c_0, atags)
  itags = tag_names(astruct.(var_idx)) ;tags for the real data.

  d = tagindex('DAT',itags)
  if (d[0] ne -1) then  parent_array = astruct.(var_idx).DAT $
  else begin
    d = tagindex('HANDLE',itags)
    if (astruct.(var_idx).HANDLE ne 0) then $
      handle_value, astruct.(var_idx).HANDLE, parent_array
    endelse
;  help, parent_array

;don't think I need this...  fill_val = astruct.(var_idx).fillval
  d = tagindex('DISPLAY_TYPE',itags)
  if (d[0] ne -1) then begin
     display_string = astruct.(index).DISPLAY_TYPE
     a = break_mystring(display_string,delimiter='>')
     new_display_type=''
     ; Count the number of '=' to determine the number of instructions
     b=0 
     ;for i=0,strlen(a[1])-1 do if (strmid(a[1],i,1) eq '=') then b=b+1
     for j=0,n_elements(a)-1 do begin
        if strpos(a[j],'=') ne -1 then begin
           for i=0,strlen(a[j])-1 do if (strmid(a[j],i,1) eq '=') then b=b+1
	   eq_index=j  ; element of display_type for which '=' exists
	endif else begin
	   new_display_type=[new_display_type,a[j]]  ;  make array; add '>' later
	endelse 
     endfor	  
     if (b ge 1) then begin
        ilist = strarr(b) 
     endif else begin ;no y=var(*,1) instructions found, return the parents data
        astruct.(index).handle = astruct.(var_idx).handle
        return, astruct
     endelse
     ;if instructions are found, continue on
     ;looking for syntax like stack_plot>y=FLUX_SEL_ENERGY_STACK(*,1)
     ; Dissect the input string into its separate instructions
     inum = 0 & next_target=',' ; initialize
     for i=0,strlen(a[eq_index])-1 do begin
        c = strmid(a[eq_index],i,1)    ; get next character in string
        if (c eq next_target) then begin
           if (next_target eq ',') then inum = inum + 1
           if (next_target eq ')') then begin
              ilist[inum] = ilist[inum] + c & next_target = ','
           endif
        endif else begin
           ilist[inum] = ilist[inum] + c ; copy to instruction list
           if (c eq '(') then next_target = ')'
        endelse
     endfor

;we don't need this loop for y=var(*,n) or y=var(n,*) or y=var(n,n,*)
;but we do need the loop for y=var(1,1),y=var(1,5), etc.
;help, ilist
;stop;
     num_lists = n_elements(ilist)
     for inum=0,num_lists-1 do begin
        b=strpos(ilist[inum],'y=') &  c=strpos(ilist[inum],'Y=')
        if c gt b then b=c
        if (b ne -1) then begin ; extract the name of the y variable and elist
           c = break_mystring(ilist[inum],delimiter='(')
           if (n_elements(c) eq 2) then rem = strmid(c[1], 0,strlen(c[1])-1)
           if (rem ne '') then begin ;apply the reduction syntax to the parent array
              y0 = execute('new_array = parent_array['+rem+',*]') ;last dim. is records
;stop;
              if (num_lists eq 1) then begin
                new_array = reform(new_array) ;remove 1-d dimensions
              endif else begin
                 temp_array = append_mydata[new_array, temp_array]
                 if (inum eq num_lists-1) then new_array = reform(temp_array)
;print, 'check this syntax '
;stop;
              endelse
;              print, 'New reduced array ' & help, new_array
           endif
        endif
     endfor

  endif else print, 'make_stack_array - DISPLAY_TYPE needed'

endif else print, 'make_stack_array - parent variable not found'

;Put the reduced sized array in the virtual variables handle
temp = handle_create(value=new_array)
astruct.(index).HANDLE = temp
;astruct.(index).DISPLAY_TYPE = a[0] ; should be just stack_plot
ndt=''
; start at 1 because 1st element of new_display_type is ''
for i=1,n_elements(new_display_type)-2 do ndt=ndt+strtrim(new_display_type[i],2)+'>'
; last element:
ndt=ndt+strtrim(new_display_type[i])
astruct.(index).DISPLAY_TYPE = ndt ; should be just stack_plot

; Check that all variables in the original variable list are declared
; as data otherwise set to support_data

   status = check_myvartype(astruct, org_names)

return, astruct
end

;+
; NAME: Function fix_sparse
;
; PURPOSE: take the array of data specified by component_0
; and replace all fill values w/ the preceding non-fill value - 
; place the result in the return buffer.
;
; CALLING SEQUENCE:
;
;          new_buf = fix_sparse(buf,org_names)
;
; VARIABLES:
;
; Input:
;
;  astruct    - an IDL structure built w/in read_myCDF
;  org_names  - list of original variables input to read_myCDF. Any
;               variables in this list will remain tagged as
;               VAR_TYPE= data otherwise VAR_TYPE = support_data.
;  index - keyword - if set use this index value to find the virtual 
;                    variable, otherwise, find the 1st vv in the structure.
;
; Output:
;
;  new_buf    - an IDL structure containing the populated virtual
;               variable
;
; Keyword Parameters:
;
;
; REQUIRED PROCEDURES:
;
;   none
;
;-------------------------------------------------------------------
; History
;
;         1.0  T. Kovalick  ADNET     6/19/2013
;               Initial version
;
;-------------------------------------------------------------------

function fix_sparse, astruct,org_names,index=index

status=0

; Establish error handler
  catch, error_status
  if(error_status ne 0) then begin
   print, "ERROR= number: ",error_status," in fix_sparse"
   print, "ERROR= Message: ",!ERR_STRING
   status = -1
   return, status
endif

; If the index of the Virtual variable is given, use it, if not, then
; find the 1st virtual variable in the structure.
atags = tag_names(astruct) ;get the variable names.
vv_tagnames=strarr(1)
vv_tagindx = vv_names(astruct,names=vv_tagnames) ;find the virtual vars
if keyword_set(index) then begin
  index = index
endif else begin ;get the 1st vv
  index = vv_tagindx[0]
  if (vv_tagindx[0] lt 0) then return, -1

endelse

;print, 'In fix_sparse'
;print, 'original variables ',org_names
c_0 = astruct.(index).COMPONENT_0 ;1st component var (real/parent variable)

if (c_0 ne '') then begin ;this should be the real data
  var_idx = tagindex(c_0, atags)
  itags = tag_names(astruct.(var_idx)) ;tags for the real data.

  d = tagindex('DAT',itags)
  if (d[0] ne -1) then  parent_array = astruct.(var_idx).DAT $
  else begin
    d = tagindex('HANDLE',itags)
    if (astruct.(var_idx).HANDLE ne 0) then $
      handle_value, astruct.(var_idx).HANDLE, parent_array
    endelse
;  help, parent_array
;  print, 'parent_array', parent_array

  new_array = parent_array  ; initialize to be identical
  fill_is_nan = 0L
  d = tagindex('FILLVAL',itags)
  if (d[0] ne -1) then begin ; fillval is define
     fill_val = astruct.(var_idx).fillval
     if finite(fill_val, /nan) then fill_is_nan = 1
     dims = size(new_array,/dimensions)
     if (n_elements(dims) eq 2) then begin
       for i = 0, dims[0]-1 do begin
          column = parent_array[i,*]
;          save_value = (max(column, /nan) + min(column, /nan))/2 ; set an initial value if the array starts off w/ fill
          save_value = fill_val; set an initial value, Bob says to use the fill_value
          ; use finite, otherwise a value of NaN isn't caught
          if (fill_is_nan) then nogood = where(finite(column, /nan), n_nogood) else $
             nogood = where(column eq fill_val, n_nogood) 
          
          if (n_nogood gt 0 and (n_nogood ne n_elements(column))) then begin ;go through the column and replace values
            for j = 0, dims[1]-1 do begin
              if (finite(column[j]) and (column[j] ne fill_val)) then save_value = column[j] else new_array[i,j] = save_value
            endfor
         endif ; else don't replace any values
       endfor
    endif ;endif 2 dimensions
  endif else print, 'fix_sparse - fillval required'

endif else print, 'fix_sparse - parent variable not found'
;print, new_array

;Put the reduced sized array in the virtual variables handle
temp = handle_create(value=new_array)
astruct.(index).HANDLE = temp

; Check that all variables in the original variable list are declared
; as data otherwise set to support_data

   status = check_myvartype(astruct, org_names)

return, astruct
end

;Function: apply_filter_flag
;Purpose: To use the filter variable to "filter" out unwanted data points
;This one is different than the rest in that the user, through the
;master cdf can specify the value to be tested against by using
;the variable attribute COMPARE_VAL, if not defined, value defaults
;to zero. It also looks for COMPARE_OPERATOR, defaults to "eq".
;Author: Tami Kovalick, ADNET Inc, March 21, 2016
;
;
;Copyright 1996-2013 United States Government as represented by the 
;Administrator of the National Aeronautics and Space Administration. 
;All Rights Reserved.
;
;------------------------------------------------------------------
;
function apply_filter_flag, astruct, orig_names, index=index

;Input: astruct: the structure, created by read_myCDF that should
;		 contain at least one Virtual variable.
;	orig_names: the list of varibles that exist in the structure.
;	index: the virtual variable (index number) for which this function
;		is being called to compute.  If this isn't defined, then
;		the function will find the 1st virtual variable.

;this code assumes that the Component_0 is the original variable, and
;Component_1 should be the filter variable.
;COMPARE_VAL - this will be the value that the s/w will use to compare 
;the filter data against. If COMPARE_VAL is not found, then the value defaults to 0.
;It also looks for the operator to be used as another variable
;attribute called COMPARE_OPERATOR, default is "eq", other acceptable
;values are "ne", "gt", "ge", "lt", "le".

atags = tag_names(astruct) ;get the variable names.
vv_tagnames=strarr(1)
vv_tagindx = vv_names(astruct,names=vv_tagnames) ;find the virtual vars

if keyword_set(index) then begin
  index = index
endif else begin ;get the 1st vv

  index = vv_tagindx[0]
  if (vv_tagindx[0] lt 0) then return, -1

endelse

print, 'In apply_filter_flag'
;print, 'original variables ',orig_names

c_0 = astruct.(index).COMPONENT_0 ;1st component var (real flux var)

if (c_0 ne '') then begin ;this should be the real data
  var_idx = tagindex(c_0, atags)
  itags = tag_names(astruct.(var_idx)) ;tags for the real data.

  d = tagindex('DAT',itags)
    if (d[0] ne -1) then  z_data = astruct.(var_idx).DAT $
    else begin
      d = tagindex('HANDLE',itags)
      handle_value, astruct.(var_idx).HANDLE, z_data
    endelse
  fill_val = astruct.(var_idx).fillval

endif else print, 'Component_0 variable not found'


c_0 = astruct.(index).COMPONENT_1 ; should be the filter variable

if (c_0 ne '') then begin ;
  var_idx = tagindex(c_0, atags)
  itags = tag_names(astruct.(var_idx)) ;tags for the real data.

  d = tagindex('DAT',itags)
    if (d[0] ne -1) then  filter_data = astruct.(var_idx).DAT $
    else begin
      d = tagindex('HANDLE',itags)
      handle_value, astruct.(var_idx).HANDLE, filter_data
    endelse
  
endif else print, 'Filter variable not found'

;Next, get the value to compare against in order to apply the filter
c = tagindex('COMPARE_VAL',tag_names(astruct.(index))) ;if the COMPARE_VAL attribute and value exist
if (c[0] ne -1) then compare_val = astruct.(index).COMPARE_VAL else compare_val = 0
;handle the case where the attribute exists in the cdf, but no value defined for this variable
if (compare_val eq '') then compare_val = 0 

;if keyword_set(DEBUG) then
 print, 'DEBUG compare_val set to ',compare_val

;Next, get the operator, e.g. eq, gt, ge, lt, le to use, default will
;be eq (which in the logic below is "ne" since we need to turn the
;value ne to the campare_val to fill.
c = tagindex('COMPARE_OPERATOR',tag_names(astruct.(index))) ;if the COMPARE_OPERATOR attribute and value exist
if (c[0] ne -1) then compare_operator = astruct.(index).COMPARE_OPERATOR else compare_operator = 'eq'
;handle the case where the attribute exists in the cdf, but no value defined for this variable
if (compare_operator eq '') then compare_operator = 'eq'

print, 'DEBUG compare_operator set to ',compare_operator

;change values not matching the compare_val to the appropriate fill values
case (compare_operator) of
   'eq': begin temp = where(filter_data ne compare_val, badcnt)                      ;***
         end
   'ne': begin temp = where(filter_data eq compare_val, badcnt)                      ;***
         end
   'lt': begin temp = where(filter_data ge compare_val, badcnt)                      ;***
         end
   'le': begin temp = where(filter_data gt compare_val, badcnt)                      ;***
         end
   'gt': begin temp = where(filter_data le compare_val, badcnt)                      ;***
         end
   'ge': begin temp = where(filter_data lt compare_val, badcnt) ;***
   end
   else: print, 'no apply_filter_flag operator specified'
endcase


;help, temp
;print, badcnt

if (badcnt ge 1) then begin
   print, 'found ',badcnt, ' records of data turning to fill'
   dims = size(z_data, /n_dimensions)
   print, 'size of data = ',dims
;help, filter_data
;help, z_data

   if (dims eq 1) then z_data[temp] = fill_val
   if (dims eq 2) then z_data[*,temp] = fill_val
   if (dims eq 3) then z_data[*,*,temp] = fill_val
   if (dims eq 4) then z_data[*,*,*,temp] = fill_val
endif

;now, need to fill the virtual variable data structure with this new data array
;and "turn off" the original variable.

tempd = handle_create(value=z_data)

astruct.(index).HANDLE = tempd

z_data = 1B
filter_data = 1B

; Check astruct and reset variables not in orignal variable list to metadata,
; so that variables that weren't requested won't be plotted/listed.

   status = check_myvartype(astruct, orig_names)

return, astruct

;endif else return, -1 ;if there's no data return -1

end

;+
; NAME: Function REORDER_DATA
;
; PURPOSE: Reorder a variable in monotonic increasing order or based the
;          order of a dependent variable(s).
;
; CALLING SEQUENCE:
;
;          new_buf = reorder (buf, org_names, index)
;
; VARIABLES:
;
; Input:
;
;  buf        - an IDL structure built w/in read_myCDF
;  org_names  - list of original variables input to read_myCDF. Any
;               variables in this list will remain tagged as 
;               VAR_TYPE= data otherwise VAR_TYPE = support_data.
;
; Output:
;
;  new_buf    - an IDL structure containing the populated virtual 
;               variable 
;  
; Keyword Parameters: 
;
;
; REQUIRED PROCEDURES:
;
;   none
;
; History: Written by Ron Yurow 08/15, based on alternate_view
;-

FUNCTION rd_map_variable, dims, n_records 

    time_dim = WHERE (dims eq n_records, found)

    ; Make sure dimension matched the number of expected records.
    IF  found ne 1 THEN BEGIN
        print, "WARNING=Reorder failed."
        print, "WARNING=Data is record varying but could not identify time dimension."

        RETURN, 0

    ENDIF

    data_dim = time_dim xor 1 

    r = {time_dim: time_dim [0], data_dim: data_dim [0]}

    RETURN, r

END

FUNCTION rd_create_data_ordering, vstruct, $
                                  sz_time_vector, $
                                  data, $
                                  order, $
                                  NORMALIZED=normalized

    ; Get the prime data.  This is the data that will be monotonically sorted.
    HANDLE_VALUE, vstruct.handle, data

    ; Find out about the dimensions.
    dim = SIZE (data, /DIMENSIONS)
    
    ; And number of dimensions.
    ndim = N_ELEMENTS (dim) 

    ; Initialize exp_dim to 1.  May reset it later.
    exp_dim = 1 

    ; Determine if the variable has a DEPEND_0 (Epoch) and if it does, then set
    ; the number of expected dimensions to 2.
    sink = WHERE (STRUPCASE (TAG_NAMES (vstruct)) eq "DEPEND_0", found)

    IF  found ne 0 && STRLEN (vstruct.DEPEND_0) gt 0 THEN exp_dim = 2

    ; Check for vector data.    
    IF  ndim ne exp_dim THEN BEGIN
        ; OK, don't have vector data, but check if the numeber of expected dimensions
        ; is two, but the actual number dimensions is one.  
        ; This can happen if only a single record is available.
        ; In this case it will be processed as if it had no DEPEND_0.
        IF  ndim ne 1 && exp_dim ne 2 THEN BEGIN
            
           print, "WARNING=Reorder failed."
           print, "WARNING=Data to be reordered must be a vector or based on the sequence of " + $
                      "elements in a sorted vector."
           RETURN, 0 
        ENDIF
    ENDIF

    ; Check if the prime data variable is time depenent.  If it is, then sorting becomes more complex
    ; then just running through a SORT function.

    ; Note we are assuming this variable uses the same DEPEND_0 as that of the main variable we are
    ; trying to process (if it is a dependent variable).  It is possible that it would not, if the 
    ; CDF was not constructed correctly, but this is just too much work to actually check.
    IF  ndim eq 2 THEN BEGIN

        order = INTARR (dim)

        ; Call rd_map_variable to assign time and data dimensions.
        vmap = rd_map_variable (dim, sz_time_vector)

        ; Check for errors
        IF SIZE (vmap, /TYPE) ne 8 THEN RETURN, 0

        ; Decide how to rearrange the data array so that the time dimension will be
        ; the lowest order dimension.
        permutation = [vmap.data_dim, vmap.time_dim]

        ; Rearrange the data array and the ordering array into an 
        ; appropiate form to do the sort.
        data  = TRANSPOSE (TEMPORARY (data), permutation)
        order = TRANSPOSE (TEMPORARY (order), permutation)

        ; Find the correct sort order.
        FOR i = 0, sz_time_vector - 1 DO order [*,i] = SORT (data [*, i])

        normalized = order

        ; Put the data array and the ordering array back into their original form.
        data  = TRANSPOSE (TEMPORARY (data), SORT (permutation))    
        order = TRANSPOSE (TEMPORARY (order), SORT (permutation))    


    ENDIF ELSE BEGIN

        ; Get the sort order for the prime data set.
        order = SORT (data)
        normalized = order

    ENDELSE

    RETURN, 1

END

FUNCTION reorder_data, buf, org_names, index=index

    status=0

    ;  Establish error handler
    ;  catch, error_status
    ;  if (error_status ne 0) then begin
    if  (0) then begin
        print, "ERROR= number: ",error_status," in reorder"
        print, "ERROR= Message: ",!ERR_STRING
        status = -1
       return, status
    endif

    tagnames = tag_names(buf)
    tagnums = n_tags(buf)

;   for i=0, n_elements(vvtag_indices)-1 do begin
;    variable_name=arrayof_vvtags(i) 
;    tag_index = tagindex(variable_name, tagnames)

    tagnames1 = tag_names (buf.(index))

    ; now look for the COMPONENT_0 attribute tag for this VV.
    component0_index = -1

    IF  (tagindex('COMPONENT_0', tagnames1) ge 0) THEN BEGIN

        component0 = buf.(index).COMPONENT_0

        ; Get the index of the component 0 variable. 

        component0_index = tagindex (component0, tagnames)

    ENDIF

    ; and look for the COMPONENT_1 attribute tag for this VV.
    component1_index = -1

    IF  (tagindex('COMPONENT_1', tagnames1) ge 0) THEN BEGIN

        component1 = buf.(index).COMPONENT_1

        ; Get the index of the component 1 variable.
        component1_index = tagindex (component1, tagnames)

    ENDIF

    ; and look for the COMPONENT_2 attribute tag for this VV.
    component2_index = -1

    IF  (tagindex ('COMPONENT_2', tagnames1) ge 0) THEN BEGIN

        component2 = buf.(index).COMPONENT_2

        ; Get the index of the component 1 variable.
        component2_index = tagindex (component2 , tagnames)

    ENDIF

    ; Now look for the DEPEND_0 attribute tag for this VV.
    ; Theoretically, I suppose a variable and one of its depends could use different
    ; Depend_0s, but I don't see how this would possible, so lets not bother with it.
    depend0_index = -1

    IF  (tagindex('DEPEND_0', tagnames1) ge 0) THEN BEGIN

         depend0 = buf.(index).DEPEND_0

         ; Get the index of the depend 0 variable. 
         depend0_index = tagindex (depend0, tagnames)

    ENDIF

    ; and get the fill value 
    fillval = !NULL 

    IF  (tagindex('FILLVAL', tagnames1) ge 0) THEN BEGIN

        fillval = buf.(index).FILLVAL

    ENDIF

    IF  (component0_index ne !NULL) THEN BEGIN

        ; WARNING if /NODATASTRUCT keyword not set an error will occur here
        IF  (tagindex ('HANDLE', tagnames1) ge 0) THEN BEGIN

            ; There two types of reordeirng.  We will either sort the data of the 
            ; variable specified in COMPONENT 0 or reorder the data specified in
            ; COMPONENT 0 based on the sequence of elements of the data from 
            ; COMPONENT 1 (abd possibly COMPONENT 2) when sorted in ascending order 
            ; variable.

            ; In the later case, the attributes COMPONENT_1 and COMPONENT_2 should 
            ; specify the DEPEND_1 and DEPEND_2 of the variable in COMPONENT_0

            ; Prime is the name of the variable whose data will be sorted.
            ; Second, if it exists, is the name of a variable that will also be sorted.
            ; Depend, if it exists, is the variable whose data will be reordered based 
            ; on the sort of prime (and possibly second).

            ; Set prime and second and depend based on if there is a COMPONENT 1 and a
            ; COMPONENT 2 specified.
            prime      = component0
            prime_ind  = component0_index

            second     = ""
            second_ind = -1
 
            depend     = ""
            depend_ind = -1

            return_prime = 1

            ; Determine which type of sort we will be doing, a strait sort of a variable, or 
            ; sorting one variable based on the order of one (or two) other variables.

            ; By default, everything is already initialized just to so a simple sort of a
            ; a variable.  Other cases will be derived from this.
            SWITCH 1 OF

                ; Set up for sorting based on the ordeer of two variables.
                ; NB. We will also have to do the setup for for sorting base on a single
                ; variable.
                (component2_index ne -1) : BEGIN

                    second      = component2
                    second_ind  = component2_index

                    END

                ; Set up for sorting based on the order of a single variable.
                (component1_index ne -1) : BEGIN

                    prime      = component1
                    prime_ind  = component1_index

                    depend     = component0 
                    depend_ind = component0_index

                    return_prime = 0               

                    END

                ELSE :

            ENDSWITCH

            ; Check if we have depend 0.  If the data is time dependent, then we should.
            IF  depend0_index ne -1 THEN BEGIN
               
                ; Get the time vector and the size of the time vector.
                HANDLE_VALUE, buf.(depend0_index).handle, time_vector
                sz_time_vector = N_ELEMENTS (time_vector)

            ENDIF

            ; Process the prime data.  This may be the product in its own right, or it may
            ; be used to sort a second data set.
            IF  (~ rd_create_data_ordering (buf.(prime_ind), $
                                            sz_time_vector, $
                                            prime_data, $
                                            prime_order, $
                                            NORMALIZED=normalized_prime_order)) THEN BEGIN

                RETURN, -1

            ENDIF

            ; Check if we need to get a sort order from a secondary data set.  This will be needed
            ; if the COMPONENT_2 was specified.
            IF  (second ne "") THEN BEGIN


                IF  (~ rd_create_data_ordering (buf.(second_ind), $
                                                sz_time_vector, $
                                                second_data, $
                                                second_order, $
                                                NORMALIZED=normalized_sec_order)) THEN BEGIN

                  RETURN, -1

                ENDIF


            ENDIF

            ; Check if we are to return the prime data in sorted order. We can do that now.
            IF  return_prime THEN BEGIN

                buf.(index).HANDLE = handle_create ()
                HANDLE_VALUE, buf.(index).HANDLE, prime_data [prime_order], /SET

            ; Otherwise more work to do.
            ENDIF ELSE BEGIN

                ; Get the depend data.  This data will be sorted based on the component_1
                ; and possibly component_2 data.
                HANDLE_VALUE, buf.(depend_ind).handle, depend_data

                ; Find out about the dimensions.
                dim = SIZE (depend_data, /DIMENSIONS)
                 
                ; And number of dimensions.
                ndim = N_ELEMENTS (dim)

                ; Found is array with one element for each dimension of the data, we will use
                ; it to find the time dimension, by setting all dimensions that correspond to 
                ; dependent data to 0.
                found = INTARR (ndim) + 1

                ; check if on component_1 is specified, or if component_1 and component_2 
                ; are specified.

                ; This branch handles the sorting data with two depenendent (COMPONENT_1 and 
                ; COMPONENT_2) variables.
                IF  (second ne "") THEN BEGIN

                    IF  ndim ne 3 THEN BEGIN
                        ; OK, don't have array data, but check if the numeber of expected dimensions
                        ; is three, but the actual number dimensions is two.  
                        ; This can happen if only a single record is available.
                        ; In this case it will be processed as if it had no DEPEND_0.
                        IF  ndim ne 2 THEN BEGIN

                            print, "WARNING=Reorder failed."
                            print, "WARNING=Data to be reordered must be a three dimensional array " + $
                                          "if COMPONENT_1 and COMPONENT_2 are specified."
                            RETURN, -1
                        ENDIF

                    ENDIF

                    ; Determine which array dimension corresponds to the prime variable.
                    prime_dim = WHERE ((SIZE (normalized_prime_order, /dimensions)) [0] eq dim, cnt)

                    ; Make sure at least one dimension matches up. 
                    IF cnt eq 0 THEN BEGIN
                        print, "WARNING=Reorder failed."
                        print, "WARNING=" + prime + " does not appear to be a dependency of " + $
                                        depend + "."
                        RETURN, -1 
                         
                    ENDIF

                    ; Mark the dimension that corresponds to the first dependent variable 
                    ; in the found array.                          
                    found [prime_dim] = 0

                    ; Determine which array dimension corresponds to the second dependent variable.
                    second_dim = WHERE ((SIZE (normalized_sec_order, /dimensions)) [0] eq dim, cnt)

                    ; Make sure at least one dimension matches up. 
                    IF cnt eq 0 THEN BEGIN
                        print, "WARNING=Reorder failed."
                        print, "WARNING=" + second + " does not appear to be a dependency of " + $
                                        depend + "."

                        RETURN, -1 
                         
                    ENDIF
                  
                    ; Mark the dimension that corresponds to the second dependent variable 
                    ; in the found array.                          
                    found [second_dim] = 0

                    ; The time dimension will be the only one that is left.  If there is no
                    ; time axis (we are processing a single record) then the time_exist flag
                    ; will be 0.
                    time_dim = WHERE (found eq 1, time_exist)

                    ; Decide how to rearrange the date array so that the dimension that will be
                    ; sorted based on the variable based on COMPONENT_1 (primary) will be first
                    ; and COMPONENT_2 (secondary) will be second.  Note the special case if
                    ; time is not available.
                    IF time_exist THEN permutation = [prime_dim, second_dim, time_dim] ELSE permutation = [prime_dim, second_dim]
                    
                    ; Rearrange the data array into an appropiate form to do the sort.
                    depend_data = TRANSPOSE (TEMPORARY (depend_data), permutation)

                    ; Rewrite as loop sorting each time independently.
                    FOR i = 0, sz_time_vector - 1 DO BEGIN 
                        depend_data [*,*, i] = TEMPORARY (depend_data [normalized_prime_order [*,i],  $
                                                                       normalized_sec_order [*,i], i])
                    ENDFOR
                     
                    ; Put the data back into its original form.
                    depend_data = TRANSPOSE (TEMPORARY (depend_data), SORT (permutation))

                ; This branch handles the sorting data with one depenendent (COMPONENT_1)
                ; variables.

                ENDIF ELSE BEGIN  



                    IF  ndim ne 2 THEN BEGIN
                        ; Check if the numeber of expected dimensions is two, but the actual number
                        ; dimensions is one.  This can happen if only a single record is available.
                        ; In this case we will artificially create the required number of dimensions.
                        IF  ndim ne 1 THEN BEGIN
                            print, "WARNING=Reorder failed."
                            print, "WARNING=Data to be reordered must be a two dimensional array " + $
                                          "if only COMPONENT_1 is specified."

                            RETURN, -1 
                        ENDIF

                    ENDIF
                   
                    ; Determine which array dimension corresponds to prime variable.
                    prime_dim = WHERE (N_ELEMENTS (prime_order) eq dim, cnt)

                    ; Make sure at least one dimension matches up. 
                    IF cnt eq 0 THEN BEGIN
                        print, "WARNING=Reorder failed."
                        print, "WARNING=" + prime + " does not appear to be a dependency of " + $
                                        depend + "."

                        RETURN, -1 
                         
                    ENDIF

                    ; Mark the dimension that corresponds to the first dependent variable 
                    ; in the found array.                                                                    
                    found [prime_dim] = 0

                    ; The time dimension will be the only one that is left.  If there is no
                    ; time axis (we are processing a single record) then the time_exist flag
                    ; will be 0.
                    time_dim = WHERE (found eq 1, time_exist)

                    ; Do the sort.  how we do the sort will depend on if we have time values.
                    IF  time_exist THEN BEGIN
                        ; Decide how to rearrange the date array so that the dimension that will be
                        ; sorted based on the variable based on COMPONENT_1 (primary) will be first.
                        permutation = [prime_dim, time_dim]

                        ; Rearrange the data array into an appropiate form to do the sort.
                        depend_data = TRANSPOSE (TEMPORARY (depend_data), permutation)

                        ; Sort the data appropiately
                        depend_data = depend_data [prime_order, *]

                        ; Put the data back into its original form.
                        depend_data = TRANSPOSE (TEMPORARY (depend_data), SORT (permutation))  
                    ENDIF ELSE BEGIN
                        depend_data = depend_data [prime_order]
                    ENDELSE           

                ENDELSE

                ; Rese the handle of the virutal variable to point to the correctly sorted data.
                buf.(index).HANDLE = handle_create ()
                HANDLE_VALUE, buf.(index).HANDLE, depend_data, /SET
                 
            ENDELSE

        ENDIF ELSE BEGIN

            print, "Set /NODATASTRUCT keyword in call to read_myCDF" ;
            RETURN, -1 

        ENDELSE

    ENDIF ELSE BEGIN

        print, "ERROR= No COMPONENT0 variable found in reorder"
        print, "ERROR= Message: ", component0_index
        status = -1

        RETURN, status
   ENDELSE

; Check that all variables in the original variable list are declared as
; data otherwise set to support_data
; Find variables w/ var_type == data

    status = check_myvartype (buf, org_names)

    RETURN, buf

END


;-------------------------------------------------------------------

function spdf_3d_to_2d_avg, buf,org_names,index=index, avg_over_row=avg_over_row, avg_over_column=avg_over_column,debug=debug

; RCJ Jun/2020  Function created for dataset psp_isois-epilo_l2-ic
;        A virtual var was created to be plotted as a spectrogram
;
;Example of what we need for spectrogram:
;Epoch         LONG64    = Array[900]
;y             FLOAT     = Array[32, 900]
;z             FLOAT     = Array[32, 900]
;
; So, for this dataset we had:
;Epoch               LONG64    = Array[132] ---------->  ok
;Energy              FLOAT     = Array[80, 48, 132] -->  [48,132] -> use virt func arr_slice: index=1, dim=0
;Flux                FLOAT     = Array[80, 48, 132] -->  [48,132] -> for i=0,47 do ([1,i,0]+[2,i,0]...[79,i,0])/80
;                                                                 Repeat for 1...131 times -> [48,132]
;LookDirection       INT       = Array[80] -----> dimension averaged over.
;
; This function will handle the flux array only.
;

status=0

; Establish error handler
catch, error_status
if(error_status ne 0) then begin
 if (error_status eq -144) then begin
  if strlowcase(buf.(index).display_type) eq 'spectrogram' then begin
    print, "ERROR= In spdf_3d_to_2d_avg. Array dimensions do not agree with spectrogram plot."
  endif else begin
    print, "ERROR= In spdf_3d_to_2d_avg. Array dimensions less than 3, or 2 if only one time record"
  endelse  
 endif else begin
  print, "ERROR= number: ",error_status," in spdf_3d_to_2d_avg"
  print, "ERROR= Message: ",!ERR_STRING
 endelse
 status = -1
 return, status
endif

if not (keyword_set(avg_over_column) or keyword_set(avg_over_row)) then begin
   if (keyword_set(debug)) then print,'Spdf_3d_to_2d_avg: Setting averaging over column since keyword was not set.'
   avg_over_column=1
endif
tagnames = tag_names(buf)
tagnums = n_tags(buf)

tagnames1=tag_names(buf.(index))

;now look for the COMPONENT_0 attribute tag for this VV.
if(tagindex('COMPONENT_0', tagnames1) ge 0) then component0=buf.(index).COMPONENT_0

; Check if the component0 variable exists 
component0_index = tagindex(component0,tagnames)

if(component0_index ge 0) then begin
    ; WARNING if /NODATASTRUCT keyword not set an error will occur here
    if(tagindex('HANDLE',tagnames1) ge 0) then begin
        handle_value,buf.(component0_index).HANDLE,oarr
		
	fillval = buf.(component0_index).fillval
	
	;  RCJ 28Jul2020  The correction below was requested by the data provider. See emails from 17Jul2020.
        if buf.(index).varname eq 'H_Flux_ChanT_avg' then  begin
	   oarr[35,*,*]=(oarr[34,*,*]=(oarr[31,*,*]=fillval))
           if keyword_set(debug) then print,'WARNING= In function spdf_3d_to_2d_avg. Setting Look Directions 31,34,35 of H_Flux_ChanT_avg to fillval.'
        endif

	; RCJ 22Apr2021  Added this bit of logic if number of time records=1
	;  In this case there will be only one 2d array	
        arrSize = size(oarr)
	if arrSize[0] eq 2 then begin
	   print,'WARNING= In spdf_3d_to_2d. Nothing to do, returning 2d array'
	   narr=oarr
	   goto, nothing_to_do_return
	endif

	narr=reform(oarr[0,*,*]) ; place holder, oarr= [dir, energy, time]
        ;arrSize = size(oarr)
        ; For this example:   3 	 80	     48 	132	      4      506880	
	numtimes = arrSize[3]
	;
        numRows = arrSize[2] 
        numCols = arrSize[1]
	;help,numcols,numrows
	if keyword_set(avg_over_row) then begin
	  inloop=numRows
	  outloop=numCols
	endif else begin ; average over the column
	  inloop=numCols
	  outloop=numRows
	endelse 
	;  
        validmin = buf.(index).validmin
        validmax = buf.(index).validmax
	
        for tt=0,numtimes-1 do begin
          ;for k=0L, numRows-1 do begin
          for k=0L, outloop-1 do begin
            sum = 0 
            summedDim = 0 ; sum over the chosen dimension
            ;for j=0L, numCols-1 do begin
            for j=0L, inloop-1 do begin
              if keyword_set(avg_over_row) then begin
        	if ((oarr[k,j,tt] GE validmin) && (oarr[k,j,tt] LE validmax) && (oarr[k,j,tt] ne fillval)) then begin
        	  sum = sum + oarr[k,j,tt]
        	  summedDim = summedDim+1
        	endif
	      endif else begin ; average over the column 
        	if ((oarr[j,k,tt] GE validmin) && (oarr[j,k,tt] LE validmax) && (oarr[j,k,tt] ne fillval)) then begin
        	  sum = sum + oarr[j,k,tt]
        	  summedDim = summedDim+1
        	endif
              endelse
            endfor
            if keyword_set(avg_over_row) then begin
	      if summedDim EQ 0 then narr[j,tt] = fillval else narr[j,tt] = sum/summedDim 
	    endif else begin  
              if summedDim EQ 0 then narr[k,tt] = fillval else narr[k,tt] = sum/summedDim 
	    endelse
          endfor
        endfor

        nothing_to_do_return:
        buf.(index).HANDLE=handle_create(value=narr)

    endif else print, "In spdf_3d_to_2d_avg. Set /NODATASTRUCT keyword in call to read_myCDF";
endif else begin
   print, "ERROR= No COMPONENT0 variable: ",component0_index," found in spdf_3d_to_2d_avg"
   status = -1
   return, status
endelse 

; Check that all variables in the original variable list are declared as
; data otherwise set to support_data
; Find variables w/ var_type == data

   status = check_myvartype(buf, org_names)

return, buf
end
;-------------------------------------------------------------------

 function spdf_sum_avg_over_col_row_z, buf,org_names,index=index, $
                            avg_over_row=avg_over_row, avg_over_col=avg_over_col, $
                            sum_over_row=sum_over_row, sum_over_col=sum_over_col, $
			    avg_col_row=avg_col_row, avg_col_z=avg_col_z, avg_row_z=avg_row_z, $
			    sum_col_row=sum_col_row, sum_col_z=sum_col_z, sum_row_z=sum_row_z,$
			    debug=debug

;+
; NAME: Function SPDF_SUM_AVG_OVER_COL_ROW_Z
;
; PURPOSE: Sum or average a 2d, 3d or 4d array, which is an element of the structure
;            returned by spdf_read_data, over the columns, rows, and/or the 3rd dimension
;            (here called z for short. Also known as layer, depth, etc)
;
; PLEASE NOTE: These are consistent with IDL's column-major arrays.
;            So if you have a [80, 48, 132] array and you want to average over 
;            the 1st dimension you will "avg_over_col".
;
;            In addition, for 3d or 4d arrays the last dim is always treated as 'time' in this function
;            because that's what's returned by spdf_read_data.
;
;            Finally, I'm adding logic to this function as needed.
;
; CALLING SEQUENCE EXAMPLES:
;
;          new_buf = spdf_sum_avg_over_col_row_z(buf,org_names,index=vindex,/avg_over_col)
;          new_buf = spdf_sum_avg_over_col_row_z(buf,org_names,index=vindex,/sum_col_z)
;
; VARIABLES:
;
; Input:
;
;  buf        - an IDL structure built w/in read_myCDF
;  org_names  - list of original variables input to read_myCDF. Any
;               variables in this list will remain tagged as 
;               VAR_TYPE= data otherwise VAR_TYPE = support_data.
;  index      - listed as a keyword but is necessary. Indicates what variable
;               of the input structure we are populating.
;
; Output:
;
;  new_buf    - an IDL structure containing the populated virtual 
;               variable 
;  
; Keyword Parameters (one of these needs to be selected), all are 1/0 (set/not set): 
;
;   2D and 3D arrays can be:
;     avg_over_row -  
;     avg_over_col -
;     sum_over_row -
;     sum_over_col -
;
;   4D arrays can be:
;     avg_col_row -
;     avg_col_z - 
;     avg_row_z - 
;     sum_col_row - 
;     sum_col_z - 
;     sum_row_z -
;
; REQUIRED PROCEDURES:
;
;   check_myvartype
;
;-------------------------------------------------------------------
; History
;
; RCJ Jun/2020  Function created for dataset psp_isois-epilo_l2-ic
;        A virtual var was created to be plotted as a spectrogram
;
;Example of what we need for spectrogram:
;Epoch         LONG64    = Array[900]
;y             FLOAT     = Array[32, 900]
;z             FLOAT     = Array[32, 900]
;
; So, for this dataset we had:
;Epoch               LONG64    = Array[132] ---------->  ok
;Energy              FLOAT     = Array[80, 48, 132] -->  [48,132] -> use virt func arr_slice: index=1, dim=0
;Flux                FLOAT     = Array[80, 48, 132] -->  [48,132] -> for i=0,47 do ([1,i,0]+[2,i,0]...[79,i,0])/80
;                                                                 Repeat for 1...131 times -> [48,132]
;LookDirection       INT       = Array[80] -----> dimension averaged over.
;
; This function handles the flux array. Function arr_slice handles the energy.
;
;
;
;-------------------------------------------------------------------

status=0

;Establish error handler
catch, error_status
if(error_status ne 0) then begin 
 ;if (error_status eq -144) then begin
 ; if strlowcase(buf.(index).display_type) eq 'spectrogram' then begin
 ;   print, "ERROR= In spdf_sum_avg_over_col_row_z. Array dimensions do not agree with spectrogram plot."
 ; endif else begin
 ;   print, "ERROR= In spdf_sum_avg_over_col_row_z. Array dimensions less than 3, or 2 if only one time record"
 ; endelse  
 ;endif else begin
  print, "ERROR= number: ",error_status," in spdf_sum_avg_over_col_row_z"
  print, "ERROR= Message: ",!ERR_STRING
 ;endelse
 status = -1
 return, status
endif

;  Need some sanity checks here

tagnames = tag_names(buf)
tagnums = n_tags(buf)

tagnames1=tag_names(buf.(index))

;now look for the COMPONENT_0 attribute tag for this VV.
if(tagindex('COMPONENT_0', tagnames1) ge 0) then component0=buf.(index).COMPONENT_0

; Check if the component0 variable exists 
component0_index = tagindex(component0,tagnames)

if(component0_index ge 0) then begin
    ; WARNING if /NODATASTRUCT keyword not set an error will occur here
    if(tagindex('HANDLE',tagnames1) ge 0) then begin
        handle_value,buf.(component0_index).HANDLE,oarr
		
	fillval = buf.(component0_index).fillval
	
	;  RCJ 28Jul2020  The correction below was requested by the data provider. See emails from 17Jul2020.
        if buf.(index).varname eq 'H_Flux_ChanT_avg' then  begin
	   oarr[35,*,*]=(oarr[34,*,*]=(oarr[31,*,*]=fillval))
           if keyword_set(debug) then print,'WARNING= In function spdf_sum_avg_over_col_row. Setting Look Directions 31,34,35 of H_Flux_ChanT_avg to fillval.'
        endif

        arrSize = size(oarr)
	
   ;-----------------------------------------------------------------------------------------------------
	
	if arrSize[0] eq 2 then begin

	   if keyword_set(avg_over_row) or keyword_set(sum_over_row) then narr=oarr[*,0]
	   if keyword_set(avg_over_col) or keyword_set(sum_over_col) then narr=oarr[0,*]
	   numtimes = 1
	
        ;arrSize = size(oarr)
        ; Example:   2	     48 	132	      4      5068	

	;
        numRows = arrSize[2] 
        numCols = arrSize[1]
	
	if keyword_set(avg_over_row) or keyword_set(sum_over_row) then begin
	  inloop=numRows
	  outloop=numCols
	endif else begin ; avg_over_col or sum_over_col
	  inloop=numCols
	  outloop=numRows
	endelse 
	;  
	
        validmin = buf.(index).validmin
        validmax = buf.(index).validmax
	
          for k=0L, outloop-1 do begin
            sum = 0 
            summedDim = 0 ; sum over the chosen dimension
	    
            for j=0L, inloop-1 do begin
              if keyword_set(avg_over_row) or keyword_set(sum_over_row) then begin
        	if ((oarr[k,j] GE validmin) && (oarr[k,j] LE validmax) && (oarr[k,j] ne fillval)) then begin
        	  sum = sum + oarr[k,j]
        	  summedDim = summedDim+1
        	endif
	      endif else begin ; avg_over_col or sum_over_col
        	if ((oarr[j,k] GE validmin) && (oarr[j,k] LE validmax) && (oarr[j,k] ne fillval)) then begin
		  sum = sum + oarr[j,k]
        	  summedDim = summedDim+1
        	endif
              endelse
            endfor ; end j
	    
            if summedDim EQ 0 then narr[k] = fillval else begin
	      if keyword_set(sum_over_col) or keyword_set(sum_over_row) then $
	                  narr[k] = sum else narr[k] = sum/summedDim
	      endelse	  
	    	  
	 endfor ; end k
	  
  endif

   ;-----------------------------------------------------------------------------------------------------
	
	if arrSize[0] eq 3 then begin
	
	  if keyword_set(avg_over_row) or keyword_set(sum_over_row) then narr=reform(oarr[*,0,*]) ; place holder, oarr= [dir, energy, time]
	  if keyword_set(avg_over_col) or keyword_set(sum_over_col) then narr=reform(oarr[0,*,*]) ; place holder, oarr= [dir, energy, time]
	  numtimes = arrSize[3]
		
        ;arrSize = size(oarr)
        ; Example:   3 	 80	     48 	132	      4      506880	

        numRows = arrSize[2] 
        numCols = arrSize[1]
	
	if keyword_set(avg_over_row) or keyword_set(sum_over_row) then begin
	  inloop=numRows
	  outloop=numCols
	endif else begin ; average/sum over the column
	  inloop=numCols
	  outloop=numRows
	endelse 
	;  
	
        validmin = buf.(index).validmin
        validmax = buf.(index).validmax
	
        for tt=0L,numtimes-1 do begin
          for k=0L, outloop-1 do begin
            sum = 0 
            summedDim = 0 ; sum over the chosen dimension
	    	    
            for j=0L, inloop-1 do begin
	    
              if keyword_set(avg_over_row) or keyword_set(sum_over_row) then begin
	      
        	if ((oarr[k,j,tt] GE validmin) && (oarr[k,j,tt] LE validmax) && (oarr[k,j,tt] ne fillval)) then begin
        	  sum = sum + oarr[k,j,tt]
        	  summedDim = summedDim+1
		endif  
              endif else begin ; avg_over_col or sum_over_col
		if ((oarr[j,k,tt] GE validmin) && (oarr[j,k,tt] LE validmax) && (oarr[j,k,tt] ne fillval)) then begin
        	  sum = sum + oarr[j,k,tt]
        	  summedDim = summedDim+1
		endif  
	      endelse
		
	    endfor ; end j

	        if summedDim EQ 0 then narr[k,tt] = fillval else begin
	          if keyword_set(sum_over_col) or keyword_set(sum_over_row) then $
		            narr[k,tt] = sum else narr[k,tt] = sum/summedDim
	        endelse
	   
	  endfor ; end k
	  
        endfor ; end tt
  endif
  
   ;-----------------------------------------------------------------------------------------------------
	
	if arrSize[0] eq 4 then begin
	  if keyword_set(avg_col_row) or keyword_set(sum_col_row) then narr=reform(oarr[0,0,*,*]) ; place holder, oarr= [dir, energy, time]
	  if keyword_set(avg_col_z) or keyword_set(sum_col_z) then narr=reform(oarr[0,*,0,*]) ; place holder, oarr= [dir, energy, time]
	  if keyword_set(avg_row_z) or keyword_set(sum_row_z) then narr=reform(oarr[*,0,0,*]) ; place holder, oarr= [dir, energy, time]
	  numtimes = arrSize[4]
		
        ;arrSize = size(oarr)
        ; Example:    4  	 16	     3  	32     200	      4      506880	

	;
	numZ = arrSize[3]
        numRows = arrSize[2] 
        numCols = arrSize[1]
	
        if keyword_set(avg_col_row) or keyword_set(sum_col_row) then begin
	  inloop=numRows
	  outloop=numCols
	  outerloop=numZ
	endif
        if keyword_set(avg_col_z) or keyword_set(sum_col_z) then begin
	  inloop=numCols
	  outloop=numZ
	  outerloop=numRows
	endif
        if keyword_set(avg_row_z) or keyword_set(sum_row_z) then begin
	  inloop=numRows
	  outloop=numZ
	  outerloop=numCols
	endif
	
        ;help,oarr,inloop,outloop,outerloop
	
        validmin = buf.(index).validmin
        validmax = buf.(index).validmax
	
        for tt=0L,numtimes-1 do begin
	
          for m=0L, outerloop-1 do begin
            sum = 0 
            summedDim = 0 ; sum over the chosen dimension
	  
           for k=0L, outloop-1 do begin

            for j=0L, inloop-1 do begin
	    	      
              if keyword_set(avg_col_row) or keyword_set(sum_col_row) then begin
        	if ((oarr[k,j,m,tt] GE validmin) && (oarr[k,j,m,tt] LE validmax) && (oarr[k,j,m,tt] ne fillval)) then begin
        	  sum = sum + oarr[k,j,m,tt]
        	  summedDim = summedDim+1
        	endif	    
	      endif
              if keyword_set(avg_col_z) or keyword_set(sum_col_z) then begin
        	if ((oarr[j,m,k,tt] GE validmin) && (oarr[j,m,k,tt] LE validmax) && (oarr[j,m,k,tt] ne fillval)) then begin
        	  sum = sum + oarr[j,m,k,tt]
        	  summedDim = summedDim+1
        	endif	    
	      endif
              if keyword_set(avg_row_z) or keyword_set(sum_row_z) then begin
        	if ((oarr[m,j,k,tt] GE validmin) && (oarr[m,j,k,tt] LE validmax) && (oarr[m,j,k,tt] ne fillval)) then begin
        	  sum = sum + oarr[m,j,k,tt]
        	  summedDim = summedDim+1
        	endif	    
	      endif
	    
            endfor ; end j
	   
	   endfor ; end k

	        if summedDim EQ 0 then narr[m,tt] = fillval else begin
	          if keyword_set(sum_col_row) or $
		   keyword_set(sum_col_z) or $
		   keyword_set(sum_row_z) $
		  then narr[m,tt] = sum else narr[m,tt] = sum/summedDim
	        endelse

	  endfor ; end m
	  
        endfor ; end tt
	   

  endif

  ; ---------------------------------------------------------------------------------------------------------

        buf.(index).HANDLE=handle_create(value=reform(narr))

    endif else print, "In spdf_sum_avg_over_col_row_z. Set /NODATASTRUCT keyword in call to read_myCDF";
endif else begin
   print, "ERROR= No COMPONENT0 variable: ",component0_index," found in spdf_sum_avg_over_col_row_z"
   status = -1
   return, status
endelse 

; Check that all variables in the original variable list are declared as
; data otherwise set to support_data
; Find variables w/ var_type == data

   status = check_myvartype(buf, org_names)

return, buf
end

; ---------------------------------------------------------------------------------------------------------
pro virtual_funcs

end


