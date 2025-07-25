;$Author: nikos $ 
;$Date: 2022-09-23 18:16:23 -0700 (Fri, 23 Sep 2022) $
;$Header: /home/cdaweb/dev/control/RCS/plot_plasmagram.pro,v 1.148 2022/05/10 15:13:57 tkovalic Exp tkovalic $
;$Locker: tkovalic $
;$Revision: 31135 $
;+
; NAME: PLOT_PLASMAGRAM
; PURPOSE: To plot the image as a plasmagram given the data structure
;	   as returned from read_myCDF.pro
;          Can plot as "thumbnails" or single frames.
; CALLING SEQUENCE:
;       out = plotmaster(astruct,zname)
; INPUTS:
;       astruct = structure returned by the read_mycdf procedure.
;	zname = name of z variable to plot as a plasmagram.
;
; KEYWORD PARAMETERS:
;       THUMBSIZE = size (pixels) of thumbnails, default = 50 (i.e. 50x50)
;       FRAME     = individual frame to plot
;       XSIZE     = x size of single frame
;       YSIZE     = y size of single frame
;       GIF       = name of gif file to send output to
;       PNG      = name of png file to send output to
;       REPORT    = name of report file to send output to
;       TSTART    = time of frame to begin imaging, default = first frame
;       TSTOP     = time of frame to stop imaging, default = last frame
;       NONOISE   = eliminate points outside 3sigma from the mean
;       CDAWEB    = being run in cdaweb context, extra report is generated
;       DEBUG    = if set, turns on additional debug output.
;       COLORBAR = calls function to include colorbar w/ image
;	MOVIE = if set, don't override the filename specified in the GIF 
;		keyword.
;       TOP_TITLE = if set, use this title for the window
;
; OUTPUTS:
;       out = status flag, 0=0k, -1 = problem occured.
; AUTHOR:
;	Tami Kovalick, RSTX, March 3, 1998
;	Based on plot_images.pro 
; MODIFICATION HISTORY:
;
;
;Copyright 1996-2013 United States Government as represented by the 
;Administrator of the National Aeronautics and Space Administration. 
;All Rights Reserved.
;
;------------------------------------------------------------------
;
; FUNCTION evaluate_plasmastruct, a, atags, labels=labels, symsize=symsize,$
; xsymsize=xsymsize, ysymsize=ysymsize, thumbsize=thumbsize
; PURPOSE: To evaluate the DISPLAY_TYPE attribute for the given variable
;	   if keyword labels is set, and if so find the label variables, 
;	   e.g. syntax will be plasmagram>labl=SM_position, labl=mode, etc.  
; Return a structure w/ these variable names.
; If not labels are set, then the string "none" is returned.
;	   If the keyword symsize is set, then look for the syntax:
;	   plasmagram>symsize=1	
;	   if set, then return the value of symsize
;	   if no symsize is found, the value of 2 is returned.
;           - 2/25/2014 change this to -1 so that the default in the
;             plot_plasmagram code will be used.  Otherwise, the
;             value in the master is getting overridden for ylog plots.
;
; CALLING SEQUENCE:
;       out = evaluate_plasmastruct, a, atags, /labels, /symsize, /thumbsize
; INPUTS:
;       a = structure returned by the read_mycdf procedure (of the plasmagram
;	variable).
;
; KEYWORD PARAMETERS:
;	lables - indicates the routine should return the lables
;	symsize - indicates the routine should return the value of symsize
;	xsymsize - indicates the routine should return the value of X symsize
;	ysymsize - indicates the routine should return the value of Y symsize
;	thumsize - indicates the routine should return the thumbsize value
;
FUNCTION evaluate_plasmastruct, a, atags, labels=labels, symsize=symsize,$
xsymsize=xsymsize, ysymsize=ysymsize, thumbsize=thumbsize
; determine if there's an display_type attribute for this structure
; and if so find the label variables, e.g. syntax will be 
; plasmagram>labl=SM_position, labl=mode, etc.  
;Return a structure w/ these variable names.
;
;If symsize is set, return the symsize or -1.
;
; Verify that the input variable is a structure
b = size(a)
if (b[n_elements(b)-2] ne 8) then begin
  print,'ERROR=Input parameter is not a valid structure.' & return,-1
endif

; evaluate the display_type attribute values.
if (keyword_set(symsize)) then sym_size = -1 ;set default
if (keyword_set(xsymsize)) then x_size = -1 ;set default
if (keyword_set(ysymsize)) then y_size = -1 ;set default
;TJK - 8/19/2003 changed from 40 to 50 to match thumbnail settings in 
;plotmaster... if (keyword_set(THUMBSIZE)) then thumb_size = 40; set default
if (keyword_set(THUMBSIZE)) then thumb_size = 50; set default

xcn = 1 ; initialize
b = tagindex('DISPLAY_TYPE',atags)
if (b[0] ne -1) then begin
  c = break_mystring(a.(b[0]),delimiter='>')
  csize = size(c)
  rest = 1
  wc=where(c eq 'THUMBSIZE',wcn)
  if(wcn ne 0) then begin
    thumb_size = fix(c[wc[0]+1])
    rest = 3
    if (keyword_set(THUMBSIZE)) then return, thumb_size
  endif
;TJK added this check to parse lables when symbol sizes are also defined

  if keyword_set(labels) then begin ; if labels and xsz/ysz are defined
     if ((strpos(a.(b[0]),'xsz',0) ne -1) or (strpos(a.(b[0]),'ysz',0) ne -1)) then begin ; if xsz or ysz is defined
        xcn = 1
        rest = 2
        if (strpos(a.(b[0]),'THUMBSIZE',0) ne -1) then rest = 4 ;TJK need this check as well - this is soo messy
     endif
  endif

  ;TJK 5/29/2003 add in "rest" variable, if THUMBSIZE is set, then the "rest"
  ;of the key=val values are shifted down by two


  ; RCJ 11Dec2019  Initialize num_found:
  num_found=-1
  
  if (csize[1] ge 2)then begin
    d = break_mystring(c[rest], delimiter=',')
    if (n_elements(d) ge 1)then begin
      vars = make_array(n_elements(d),/string,value=' ')
      num_found = -1
      for i=0L, n_elements(d)-1 do begin
      ;look for all "labl" keywords
        e = break_mystring(d[i], delimiter='=')
        if (n_elements(e) ge 1) then begin

	  if keyword_set(labels) then begin
 	    if (strpos(e[0],'labl',0) ne -1) then begin
	      num_found=num_found+1
              vars[num_found] =  e[1]
	    endif
	  endif else begin
	    if keyword_set(symsize) then begin
	      if (strpos(e[0],'symsize',0) ne -1) then sym_size = e[1]
           endif
	    if keyword_set(xsymsize) then begin
	      if (strpos(e[0],'xsz',0) ne -1) then x_size = e[1]
           endif
	    if keyword_set(ysymsize) then begin
	      if (strpos(e[0],'ysz',0) ne -1) then y_size = e[1]
	    endif
	  endelse

	endif
      endfor

    endif
  endif 
endif 
if keyword_set(symsize) then return, sym_size
if keyword_set(xsymsize) then return, x_size
if keyword_set(ysymsize) then return, y_size
if keyword_set(thumbsize) then return, thumb_size

if (num_found ge 0) then begin
  t = where(vars ne ' ', t_cnt) ; take out the possible blanks
  if (t_cnt ge 1) then vars = vars[t] ; redefine vars
endif else begin
  vars = 'none'
endelse


return, vars ;return the list of variables to be used as labels
end  


FUNCTION plot_plasmagram, astruct, zname, $
                      THUMBSIZE=THUMBSIZE, FRAME=FRAME, $
                      XSIZE=XSIZE, YSIZE=YSIZE, GIF=GIF,PNG=PNG, REPORT=REPORT,$
                      TSTART=TSTART,TSTOP=TSTOP,NONOISE=NONOISE,$
                      CDAWEB=CDAWEB,DEBUG=DEBUG,COLORBAR=COLORBAR, $
		      MOVIE=MOVIE, TOP_TITLE=TOP_TITLE

; Determine default x, y and z variables from depend attributes

atags = tag_names(astruct)
z_ax = tagindex(zname,atags) ;z axis
b = astruct.(z_ax).DEPEND_0 & epoch = tagindex(b[0],atags) ;epoch
b = astruct.(z_ax).DEPEND_1 & x_ax = tagindex(b[0],atags) ;x axis
b = astruct.(z_ax).DEPEND_2 & y_ax = tagindex(b[0],atags) ;y axis

;TJK 11/15/2012 - start using new attributes to allow us to switch the
;                 depend attributes for use w/ CDAWeb w/in IDL
alt = tagindex('ALT_CDAWEB_DEPEND_1',tag_names(astruct.(z_ax)))
if (alt[0] ne -1) then begin
   if (astruct.(z_ax).ALT_CDAWEB_DEPEND_1 ne '') then begin
      b = astruct.(z_ax).ALT_CDAWEB_DEPEND_1 
      x_ax = tagindex(b[0],atags) ;x axis
   endif   
endif
alt = tagindex('ALT_CDAWEB_DEPEND_2',tag_names(astruct.(z_ax)))
if (alt[0] ne -1) then begin
   if (astruct.(z_ax).ALT_CDAWEB_DEPEND_2 ne '') then begin
      b = astruct.(z_ax).ALT_CDAWEB_DEPEND_2 
      y_ax = tagindex(b[0],atags) ;y axis
   endif   
endif

estruct = astruct.(epoch)
xstruct = astruct.(x_ax)
ystruct = astruct.(y_ax)
zstruct = astruct.(z_ax)


;Look at the display_type to see if there are any special settings.
; Determine if the display type variable attribute is present for Z.
b = tagindex('DISPLAY_TYPE',tag_names(astruct.(z_ax)))
if (b[0] ne -1) then begin
; examine_spectrogram_dt looks at the DISPLAY_TYPE structure member in detail.
; for spectrograms and stacked time series the DISPLAY_TYPE can contain syntax
; like the following: SPECTROGRAM>y=flux(1),y=flux(3),y=flux(5),z=energy
; where this indicates that we only want to plot the 1st, 3rd and 5th energy 
; channel for the flux variable. This routine returns a structure of the form 

e = examine_spectrogram_dt(astruct.(z_ax).DISPLAY_TYPE) & esize=size(e)

  if (esize[n_elements(esize)-2] eq 8) then begin ; results confirmed
    if (e.x ne '') then x_ax = tagindex(e.x,atags)
    if (e.y ne '') then y_ax = tagindex(e.y,atags)
    ;TJK 4/26/2022 add the redefinition of xstruct and ystruct based on
    ;what's set in the display_type for x and y, so we don't have to use
    ;alt_cdaweb_depend_1 and 2

    xstruct = astruct.(x_ax)
    ystruct = astruct.(y_ax)

  endif
endif


vname = zstruct.VARNAME ; get the name of the image variable

 ;TJK 3/15/01 - added the check for the descriptor
; Check Descriptor Field for Instrument Specific Settings

tip = tagindex('DESCRIPTOR',tag_names(zstruct))
if (tip ne -1) then begin
  descriptor=str_sep(zstruct.descriptor,'>')
endif

;If RPI, then get the programspecs variable and use some of the values
;for labeling and determining the symbol size (since some of this data
;was recorded in log vs. linear scales. TJK 2/24/2003
rpi = 0 ; clear flag
if (descriptor[0] eq "RPI") then begin
  rpi = 1 ;set flag 
  a = tagindex('COMPONENT_1',tag_names(astruct.(z_ax)))
  if(a[0] ne -1) then begin
    d = astruct.(z_ax).COMPONENT_1 & p_ax = tagindex(d[0],atags) ;programspecs
    pstruct = astruct.(p_ax)
    a = tagindex('DAT',tag_names(pstruct))
    if (a[0] ne -1) then pdat = pstruct.DAT $
    else begin
      a = tagindex('HANDLE',tag_names(pstruct))
      if (a[0] ne -1) then handle_value,pstruct.HANDLE,pdat $
      else begin
        print,'ERROR= ProgramSpecs variable does not have DAT or HANDLE tag' & return,-1
      endelse
    endelse
   endif ;component_1 variable doesn't exist for this RPI variable (use defaults)
endif

if keyword_set(COLORBAR) then COLORBAR=1L else COLORBAR=0L
if COLORBAR  then xco=80 else xco=0 ; No colorbar

; Open report file if keyword is set
;if keyword_set(REPORT) then begin & reportflag=1L
; a=size(REPORT) & if (a(n_elements(a)-2) eq 7) then $
; OPENW,1,REPORT,132,WIDTH=132
;endif else reportflag=0L
 if keyword_set(REPORT) then reportflag=1L else reportflag=0L

; Verify the type of the first parameter and retrieve the data
a = size(zstruct)
if (a[n_elements(a)-2] ne 8) then begin
  print,'ERROR= Z parameter to plot_plasmagram not a structure' & return,-1
endif else begin
  a = tagindex('DAT',tag_names(zstruct))
  if (a[0] ne -1) then idat = zstruct.DAT $
  else begin
    a = tagindex('HANDLE',tag_names(zstruct))
    if (a[0] ne -1) then handle_value,zstruct.HANDLE,idat $
    else begin
      print,'ERROR= Z parameter does not have DAT or HANDLE tag' & return,-1
    endelse
  endelse
endelse

; Get 'Epoch' data and retrieve it

d = tagindex('DAT',tag_names(estruct))
if (d[0] ne -1) then edat = estruct.DAT $
else begin
  d = tagindex('HANDLE',tag_names(estruct))
  if (d[0] ne -1) then handle_value,estruct.HANDLE,edat $
  else begin
    print,'ERROR= Time parameter does not have DAT or HANDLE tag' & return,-1
  endelse
endelse

; Get 'X variable' data and retrieve it

xtags = tag_names(xstruct)
d = tagindex('DAT',xtags)
if (d[0] ne -1) then xdat = xstruct.DAT $
else begin
  d = tagindex('HANDLE',xtags)
  if (d[0] ne -1) then handle_value,xstruct.HANDLE,xdat $
  else begin
    print,'ERROR= X variable does not have DAT or HANDLE tag' & return,-1
  endelse
endelse

xlog = 1L ; initialize assuming logarithmic
a = tagindex('SCALETYP',xtags)
if (a[0] ne -1) then begin
   if (strupcase(Xstruct.SCALETYP) eq 'LINEAR') then xlog = 0L
endif

; determine validmin and validmax values for the x variable
a = tagindex('VALIDMIN',xtags)
if (a[0] ne -1) then begin & b=size(xstruct.VALIDMIN)
  if (b[0] eq 0) then xvmin = xstruct.VALIDMIN $
  else begin
    xvmin = 0 ; default for x data
    print,'WARNING=Unable to determine validmin for ',xstruct.varname
  endelse
endif

a = tagindex('VALIDMAX',xtags)
if (a[0] ne -1) then begin & b=size(xstruct.VALIDMAX)
  if (b[0] eq 0) then xvmax = xstruct.VALIDMAX $
  else begin
    xvmax = 2000 ; guesstimate
    print,'WARNING=Unable to determine validmax for ',xstruct.varname
  endelse
endif

;TJK 3/30/2016 add checking for scalemin/max (which when set, turn off
;auto-scaling for X) 
xscales = -1 ; initialize flag
; determine scalemin and scalemax values for the x variable
a = tagindex('SCALEMIN',xtags)
if (a[0] ne -1) then begin & b=size(xstruct.SCALEMIN)
  if (b[0] eq 0) then begin
     xsmin = xstruct.SCALEMIN 
     if (xsmin ne '') then xscales = 1
  endif
endif

a = tagindex('SCALEMAX',xtags)
if (a[0] ne -1) then begin & b=size(xstruct.SCALEMAX)
  if (b[0] eq 0) then xsmax = xstruct.SCALEMAX
endif

;determine x axis label
a = tagindex('LABLAXIS',xtags)
if (a[0] ne -1) then begin & b=size(xstruct.LABLAXIS)
  if (b[0] eq 0) then xtitle = xstruct.LABLAXIS $
  else begin
    xtitle = ' x axis' ; default for x data
    print,'WARNING=Unable to determine xtitle for ',xstruct.varname
  endelse
endif
;determine x axis units
a = tagindex('UNITS',xtags)
if (a[0] ne -1) then begin & b=size(xstruct.UNITS)
  if (b[0] eq 0) then xtitle = xtitle + ' in '+ xstruct.UNITS $
  else begin
    xtitle = xtitle  ; default for x data
    print,'WARNING=Unable to determine units for ',xstruct.varname
  endelse
endif


; Get 'Y variable' data and retrieve it

ytags = tag_names(ystruct)
d = tagindex('DAT',ytags)
if (d[0] ne -1) then ydat = ystruct.DAT $
else begin
  d = tagindex('HANDLE',ytags)
  if (d[0] ne -1) then handle_value,ystruct.HANDLE,ydat $
  else begin
    print,'ERROR= Y variable does not have DAT or HANDLE tag' & return,-1
  endelse
endelse

ylog = 1L ; initialize assuming logarithmic
a = tagindex('SCALETYP',ytags)
if (a[0] ne -1) then begin
   if (strupcase(Ystruct.SCALETYP) eq 'LINEAR') then ylog = 0L
endif


; determine validmin and validmax values for the y variable
a = tagindex('VALIDMIN',ytags)
if (a[0] ne -1) then begin & b=size(ystruct.VALIDMIN)
  if (b[0] eq 0) then yvmin = ystruct.VALIDMIN $
  else begin
    yvmin = 0 ; default for y data
    print,'WARNING=Unable to determine validmin for ',ystruct.varname
  endelse
endif

a = tagindex('VALIDMAX',ytags)
if (a[0] ne -1) then begin & b=size(ystruct.VALIDMAX)
  if (b[0] eq 0) then yvmax = ystruct.VALIDMAX $
  else begin
    yvmax = 2000 ; guesstimate
    print,'WARNING=Unable to determine validmax for ',ystruct.varname
  endelse
endif

yscales = -1 ; initialize flag
; determine scalemin and scalemax values for the y variable
a = tagindex('SCALEMIN',ytags)
if (a[0] ne -1) then begin & b=size(ystruct.SCALEMIN)
  if (b[0] eq 0) then begin
     ysmin = ystruct.SCALEMIN 
     if (ysmin ne '') then yscales = 1
  endif
endif

a = tagindex('SCALEMAX',ytags)
if (a[0] ne -1) then begin & b=size(ystruct.SCALEMAX)
  if (b[0] eq 0) then ysmax = ystruct.SCALEMAX
endif

;determine y axis label
a = tagindex('LABLAXIS',ytags)
if (a[0] ne -1) then begin & b=size(ystruct.LABLAXIS)
  if (b[0] eq 0) then ytitle = ystruct.LABLAXIS $
  else begin
    ytitle = ' y axis' ; default for x data
    print,'WARNING=Unable to determine ytitle for ',ystruct.varname
  endelse
endif
;determine y axis units
a = tagindex('UNITS',ytags)
if (a[0] ne -1) then begin & b=size(ystruct.UNITS)
  if (b[0] eq 0) then ytitle = ytitle + ' in '+ ystruct.UNITS $
  else begin
    ytitle = ytitle  ; default for y data
    print,'WARNING=Unable to determine units for ',ystruct.varname
  endelse
endif


; Determine the title for the window or gif file

ztags = tag_names(zstruct)
;a = tagindex('CATDESC',ztags)
;if (a(0) ne -1) then fn = '> ' + zstruct.CATDESC else fn = ''
;TJK - change from using CATDESC to FIELDNAM, the former is too long
a = tagindex('FIELDNAM',ztags)
if (a[0] ne -1) then field = zstruct.FIELDNAM else field = ''
if (field ne '') then fn = '> ' + field else fn = ''
a = tagindex('SOURCE_NAME',ztags)
if (a[0] ne -1) then begin
sn = break_mystring(zstruct.SOURCE_NAME,delimiter='>')
b = sn[0]
endif else b = ''
a = tagindex('DESCRIPTOR',ztags)
if (a[0] ne -1) then b = b + '  ' + zstruct.DESCRIPTOR
window_title = b + fn

; if nonoise is set, make title say so
if keyword_set(nonoise) then window_title = window_title+'!CFiltered to remove values >3-sigma from mean of all plotted values'
;check units to see if binning was allowed (can be overriden in the master)
a = tagindex('UNITS',ztags)
if (a[0] ne -1) then begin
   binned = strpos(zstruct.UNITS,'not binned')
   if (binned gt -1) then begin 
      top_title = ''
      zstruct.UNITS = strmid(zstruct.UNITS, 0, binned-1)
      status_string = 'STATUS=Binning not allowed and has not been applied to '+strtrim(field,2)
      print, format='(a)',status_string
   endif
endif
;if binning top_title will be set
if keyword_set(TOP_TITLE) then window_title = window_title+'!C'+top_title


; Get extra labels from the display type - if it exists

idx = -1 ;initialize idx
label_vars = evaluate_plasmastruct(zstruct, ztags, /labels)

thumbsize = evaluate_plasmastruct(zstruct, ztags, /thumbsize)
if (n_elements(label_vars) ge 1 and label_vars[0] ne 'none') then begin ; get all of the extra label data
  for l = 0L, n_elements(label_vars)-1 do begin
    ;TJK insert code here to look for an "indexed" label variable, e.g. 3/20/2003
    ;ProgramSpecs(0), so we need to look for "("
    idx_flag = 0 ;initialize flag
    d = break_mystring(label_vars[l],delimiter='(')
    if (n_elements(d) eq 2) then begin
      idx_flag = 1 ;set flag, we have an index variable
      label_vars[l] = d[0]
      c = strmid(d[1],0,(strlen(d[1])-1)) ; remove closing quote
      idx = long(c)
    endif  

    l_str = strtrim(string(l),2);convert the index to string
    lab = tagindex(label_vars[l],atags) ;find label variable in astruct
    comm=execute('lstruct'+l_str+' = astruct.(lab)')
    
    comm=execute('ltags = tag_names(lstruct'+l_str+')')
    d = tagindex('DAT',ltags)
    if (d[0] ne -1) then comm=execute('ldat = lstruct'+l_str+'.DAT') $
    else begin
      d = tagindex('HANDLE',ltags)
      if (d[0] ne -1) then comm=execute('handle_value,lstruct'+l_str+'.HANDLE,ldat'+l_str) $
      else begin
        print,'ERROR= Label variable does not have DAT or HANDLE tag' & return,-1
      endelse
    endelse

    if (not comm) then print, 'Error=execute for labels failed'

    ;now get the fieldname that goes w/ this data
    comm = execute('ltitle'+l_str+'=''')
    a = tagindex('FIELDNAM',ltags)
    if (a[0] ne -1) then comm = execute('ltitle'+l_str+' = lstruct'+l_str+'.FIELDNAM')

    a = tagindex('LABLAXIS',ltags)
    if (a[0] ne -1) then begin
	comm = execute('temp = lstruct'+l_str+'.LABLAXIS')
	if(temp[0] ne '') then comm = execute('ltitle'+l_str+' = lstruct'+l_str+'.LABLAXIS')
    endif

    a = tagindex('LABL_PTR_1',ltags)
    if (a[0] ne -1) then begin
	comm = execute('temp = lstruct'+l_str+'.LABL_PTR_1')
        if (temp[0] ne '') then comm = execute('ltitle'+l_str+' = lstruct'+l_str+'.LABL_PTR_1')
    endif

    ;Need to add code here to deal w/ indexed label values - TJK - 3/20/2003
    if (idx_flag and (idx ge 0)) then begin
      comm = execute('title = strtrim(ltitle'+l_str+',2)')
      comm = execute('ltitle'+l_str+' = title[idx]')
      comm = execute('ldata = strtrim(ldat'+l_str+',2)')
      if (size(ldata, /n_dimensions) eq 2) then begin
  	  comm = execute('ldat'+l_str+' = ldata[idx,*]')
          comm = execute('ldat'+l_str+' = reform(ldat'+l_str+')')
      endif else begin
	  comm = execute('ldat'+l_str+' = ldata[idx]')
      endelse
    endif

  endfor
endif ;getting label data

; Determine title for colorbar
if(COLORBAR) then begin
 ctitle=''
 a = tagindex('LABLAXIS',ztags)
 if (a[0] ne -1) then ctitle = zstruct.LABLAXIS
 a=tagindex('UNITS',ztags)
 if(a[0] ne -1) then ctitle = ctitle + ' in ' + zstruct.UNITS 
endif
if keyword_set(XSIZE) then xs=XSIZE else xs=560
if keyword_set(YSIZE) then ys=YSIZE else ys=560
;TJK debugging stuff for GOLD

; Determine if data is a single image, if so then set the frame
; keyword because a single thumbnail makes no sense
isize = size(idat)
;print, 'debug size of idat before reducing to 2-d (plus time)', isize
;help, idat
;TJK 3/17/2016 - new code to allow reducing 4-d to 3-d arrays (mms fpi)
if (isize[0] eq 4) then begin ;new code for 4-d data w/ display_type syntax z=(*,*,1)
   n_images= isize[4]
   varys = where((e.dvary eq 1), wc) ;look at what was returned by examine_spectrogram_dt (contents of e)
   i = 0 ; set this to 0, if we ever allow more than one set of plasmagrams to be defined, this would be a loop counter - see plot_spectrogram
;   print, 'DEBUG from plasmagram '
;   print, e.zelist1, e.zelist2, e.zelist3
   if (wc gt 0) then vary_dim = e.dvary
   if (vary_dim[0] and vary_dim[1]) then mydata = idat[*,*,e.zelist3[i]-1,*]                                                     
   if (vary_dim[1] and vary_dim[2]) then mydata = idat[e.zelist1[i]-1,*,*,*]                                                     
   if (vary_dim[0] and vary_dim[2]) then mydata = idat[*,e.zelist2[i]-1,*,*] 
   idat = reform(mydata) ;remove the size one dimension
;print, 'debug size of idat after reducing to 2-d (plus time)'
;help, idat
endif

isize = size(idat)
if (isize[0] eq 2) then n_images=1 else n_images=isize[isize[0]] ;original code

if (n_images eq 1) then FRAME=1

;Produce blown up single image plot

if keyword_set(FRAME) then begin ; produce plot of a single frame
   
;Kluge - if IBEX, make the plot window 1.5 times its normal width (only for
;        the large/single images, not for thumbnails)
if (strpos(window_title,'IBEX',0) ne -1) then xs = xs*1.5 

;print, 'size of idat before selecting just the one frame ',size(idat)

  if ((FRAME ge 1)AND(FRAME le n_images)) then begin ; valid frame value
    idat = idat[*,*,(FRAME-1)] ; grab the frame
    idat = reform(idat) ; remove extraneous dimensions
;print, 'one frame size:'
;help,idat

;TJK 2/14/2012 - check the descriptor, if isis, we need to rotate 270
;                deg. and since this is not a square image, must
;                rotate image by image.
    if(descriptor[0] eq 'MERGEDSTATIONS') then begin
;print, 'found ISIS Mergedstation data, rotating 90 deg for plasmagrams'
      ;set up an array to handle the "rotated images"
       idat2 = rotate(idat[*,*], 4)
       idat = idat2
       idat2 = 0  ;clear this array out
     endif ;if MERGEDSTATIONS

;print, 'size of xdat before selecting just the one frame ',size(xdat)
xdims = size(xdat, /n_dimensions)
ydims = size(ydat, /n_dimensions)
;GOLD has 2-d NRV latitude and longitude so need different logic
  walk2d_x = 0
  walk2d_y = 0
  if (xstruct.cdfrecvary eq 'NOVARY' and xdims eq 2) then walk2d_x = 1
  if (ystruct.cdfrecvary eq 'NOVARY' and ydims eq 2) then walk2d_y = 1
  if (not(walk2d_x) or not(walk2d_y)) then begin 
    if (xdims eq 2) then begin
	 xdat = xdat[*,(FRAME-1)] ; grab just the one frame
    endif ;otherwise assume its only one dimension
    xdat = reform(xdat) ; remove extraneous dimensions
    if (ydims eq 2) then begin
    	ydat = ydat[*,(FRAME-1)] ; grab just the one frame
    endif ;otherwise assume its only one dimension
    ydat = reform(ydat) ; remove extraneous dimensions
 endif

    isize = size(idat) ; get the dimensions of the image

; screen x axis non-positive data values if creating a logarithmic plot
;TJK 4/19/2019 need to check for nan (GOLD) down below - added "finite"

if (xlog eq 1L) then begin
  if (xvmin gt 0.0) then amin = xvmin else amin = 0.0
  w = where(xdat le amin,wc)
  if (wc gt 0) then begin
    w = where(xdat gt amin,wc)
    if (wc gt 0) then begin
     if keyword_set(DEBUG) then print,'Screening X ',wc, 'non-positive values.'
     xvmin = min(xdat[w], /nan, max=xvmax) ;TJK corrected - determine min/max w/o negative out of
				   ;range values or nan 
     if (xlog eq 1L and xvmin le 0) then xvmin = .0001 ;TJK corrected  - xvmin can't be zero
    endif
  endif
endif else begin
;print, 'DEBUG determining xmin and xmax'
;print, 'max = ',max(xdat),'min = ',min(xdat)

  w = where((xdat gt xvmin and xdat lt xvmax), wc)
  if (wc gt 0) then xvmin = min(xdat[w], /nan, max=xvmax)
  if (wc le 0) then begin
	xvmin = 0 & xvmax = 1
  endif
endelse

if keyword_set(DEBUG) then print, 'DEBUG,X min and max scales = ',xvmin, xvmax

; screen y axis non-positive data values if creating a logarithmic plot
if (ylog eq 1L) then begin
  if (yvmin gt 0.0) then amin = yvmin else amin = 0.0
  w = where(ydat le amin,wc)
  if (wc gt 0) then begin
    w = where(ydat gt amin,wc)
    if (wc gt 0) then begin
     if keyword_set(DEBUG) then print,'Screening Y ',wc, 'non-positive values.'
       ;get the actual min value
       yvmin = min(ydat[w], /nan, max=yvmax)
       if (ylog eq 1L and yvmin le 0) then yvmin = .0001 ;yvmin can't be zero
    endif
  endif
endif else begin
  w = where((ydat gt yvmin and ydat lt yvmax), wc)
  if (wc gt 0) then yvmin = min(ydat[w], /nan, max=yvmax)
  if (wc le 0) then begin
	yvmin = 0 & yvmax = 1
  endif
endelse

if keyword_set(DEBUG) then print, 'DEBUG, Y min and max scales = ',yvmin, yvmax

; Begin changes 12/11 RTB
    ; determine validmin and validmax values for the image
    a = tagindex('VALIDMIN',ztags)
    if (a[0] ne -1) then begin & b=size(zstruct.VALIDMIN)
      if (b[0] eq 0) then zvmin = zstruct.VALIDMIN $
      else begin
        zvmin = 0 ; default for image data
        print,'WARNING=Unable to determine validmin for ',vname
      endelse
    endif
    a = tagindex('VALIDMAX',ztags)
    if (a[0] ne -1) then begin & b=size(zstruct.VALIDMAX)
      if (b[0] eq 0) then zvmax = zstruct.VALIDMAX $
      else begin
        zvmax = 2000 ; guesstimate
        print,'WARNING=Unable to determine validmax for ',vname
      endelse
    endif
    a = tagindex('FILLVAL',tag_names(zstruct))
    if (a[0] ne -1) then begin & b=size(zstruct.FILLVAL)
      if (b[0] eq 0) then zfill = zstruct.FILLVAL $
      else begin
        zfill = -1 ; guesstimate
        print,'WARNING=Unable to determine the fillval for ',vname
      endelse
   endif

;TJK added checking of the image scale type 6/2/2003 since we're now
;trying to use this for other datasets, e.g. wind 3dp...
   logz = 0L ; initialize assuming linear
   a = tagindex('SCALETYP',ztags)
   if (a[0] ne -1) then begin
      if (strupcase(Zstruct.SCALETYP) eq 'LOG') then logz = 1L
   endif
;TJK 4/1/2014 - need to make any z values outside of validmin/max  eq
;to fill, so that they don't scue all of the adjustments below.

outofrange = where(idat lt zvmin or idat gt zvmax, ocnt)
if (ocnt gt 0) then idat[outofrange] = zfill 
if keyword_set(DEBUG) then print,'WARNING=Number of Z values outside of validmin/max range = ',ocnt

;TJK 8/19/2003 - new section of code added to deal w/ fill values and log scaling and low "valid" values
;a little differently than in the past...

  fdat = where(idat ne zfill, fc) 
  if (fc gt 0) then begin
    wmin = min(idat[fdat], /nan, MAX=wmax) ;do not include the fill value when determining the min/max
  endif else begin
    if keyword_set(DEBUG) then print,'WARNING=No data found - all data is fill or out of range!!'
    print,'STATUS=No data found - all data is fill or out of range!!' & return, -1
    wmin=1 & wmax = 1.1
  endelse     

; special check for when Z log scaling - set all values
; less than or equal to 0, to the next lowest actual value.
;TJK 4/18/2019 check for nan's (GOLD)

    if (logz and (wmin le 0.0)) then begin
	w = where((idat le 0.0 and idat ne zfill), wc)
	z = where((idat gt 0.0 and idat ne zfill), zc)
	if (wc gt 0 and zc gt 0) then begin
	  if keyword_set(DEBUG) then print, 'Z log scaling and min values being adjusted, '
         wmin = min(idat[z], /nan) ;need to set wmin because its used lower down
	  idat[w] = wmin
	endif
   endif


    w = where(((idat lt zvmin) and (idat ne zfill)),wc)
    if wc gt 0 then begin
      if keyword_set(DEBUG) then print, 'Setting ',wc,' out of range values in image data to lowest data value= ', wmin
      idat[w] = wmin ; set pixels to the lowest real value (for the current image)
      w = 0 ; free the data space
   endif

;reassign the fill values to a really low number to get them out of
;the way - setting to zero or 0.1 isn't right still...
;TJK 2/3/2014 - doing this differently down below
;    w = where((idat eq zfill),wc)
;    if wc gt 0 then begin
;      if keyword_set(DEBUG) then print, 'Number of fill values found, Setting ',wc, ' values to 0 or 0.1 (black)'
;      if (logz) then idat[w] = 0.1 else idat[w] = 0 ; set pixels to black
;      w = 0 ; free the data space
;    endif

;Don't take out the higher values, just scale them in.

    w = where((idat gt zvmax and idat ne zfill),wc)
    if wc gt 0 then begin
      if keyword_set(DEBUG) then print, 'Number of values above the valid max = ',wc, '. Setting them to red...'
;6/25/2004 see below         idat(w) = zvmax -1; set pixels to red
         ;TJK 6/25/2004 - added red_offset function to determine offset
         ;(to red) because of cases like log scaled timed guvi data
         ;where the diff is less than 1.
         diff = zvmax - zvmin
         if keyword_set(GIF) then coffset = red_offset(GIF=GIF,diff)
         if keyword_set(PNG) then coffset = red_offset(PNG=PNG,diff)
;         print, 'diff = ',diff, ' coffset = ',coffset
         idat[w] = zvmax - coffset; set pixels to red
      w = 0 ; free the data space
    endif

if keyword_set(DEBUG) then begin
  print, 'Defined in CDF/master, valid min and max: ',zvmin, ' ',zvmax 
  wmin = min(idat,/nan, MAX=wmax)
  print, 'Actual min and max of image data',wmin,' ', wmax
  print, 'Image fill value = ',zfill
endif


;TJK added this section to print out some statistics about the data distribution. 
    if keyword_set(DEBUG) then begin
      print, 'Statistics about the data distribution'
      w = where(((idat lt zvmax) and (idat ge (zvmax-10))),wc)
      if wc gt 0 then print, 'Number of values between ',zvmax,' and ',zvmax-10,' = ',wc
      w = where(((idat lt zvmax-10) and (idat ge (zvmax-20))),wc)
      if wc gt 0 then print, 'Number of values between ',zvmax-10,' and ',zvmax-20,' = ',wc
      w = where(((idat lt zvmax-20) and (idat ge (zvmax-30))),wc)
      if wc gt 0 then print, 'Number of values between ',zvmax-20,' and ',zvmax-30,' = ',wc
      w = where(((idat lt zvmax-30) and (idat ge (zvmax-40))),wc)
      if wc gt 0 then print, 'Number of values between ',zvmax-30,' and ',zvmax-40,' = ',wc
      w = where(((idat lt zvmax-40) and (idat ge (zvmax-50))),wc)
      if wc gt 0 then print, 'Number of values between ',zvmax-40,' and ',zvmax-50,' = ',wc
      w = where(((idat lt zvmax-50) and (idat ge (zvmax-60))),wc)
      if wc gt 0 then print, 'Number of values between ',zvmax-50,' and ',zvmax-60,' = ',wc

    endif

    ; filter out data values outside 3-sigma for better color spread
    if keyword_set(NONOISE) then begin
      semiMinMax,idat,zvmin,zvmax
      w = where((idat lt zvmin),wc)
      if wc gt 0 then begin
        if keyword_set(DEBUG) then print,'WARNING=filtering values less than 3-sigma from image data...'
        idat[w] = zvmin ; set pixels to black
        w = 0 ; free the data space
      endif
      w = where((idat gt zvmax),wc)
      if wc gt 0 then begin
        if keyword_set(DEBUG) then print,'WARNING=filtering values greater than 3-sigma from image data...'
;6/25/2004 see below        idat(w) = zvmax -2; set pixels to red
         ;TJK 6/25/2004 - added red_offset function to determine offset
         ;(to red) because of cases like log scaled timed guvi data
         ;where the diff is less than 1.
         diff = zvmax - zvmin
         if keyword_set(GIF) then coffset = red_offset(GIF=GIF,diff)
         if keyword_set(PNG) then coffset = red_offset(PNG=PNG,diff)
         print, 'DEBUG diff = ',diff, ' coffset = ',coffset
         idat[w] = zvmax - coffset; set pixels to red
        w = 0 ; free the data space
      endif
     endif

; scale to maximize color spread
;determine the image min/max excluding the fill value
    idmin = .00001
    idmax = idmin+1
    wfill = where((idat ne zfill),wcfill)
    if (wcfill gt 0) then begin
       idmax=max(idat[wfill], /nan, min=idmin) 
       ;print, 'DEBUG data is good'
    endif else begin
       ;print, 'DEBUG all data is fill'
       if keyword_set(MOVIE) then return, -1
    endelse


;test to see if min/max are equal
    if (idmin eq idmax) then begin
       if (logz) then idmin = .00001 ; just in case its zero for log scales
       idmax = idmin+1          ; add so the colobar will be happy
    endif

    if keyword_set(GIF) then begin
; RTB 9/96 Retrieve the Data set name from the Logical source or
;          the Logical file id
	atags=tag_names(zstruct)
	b = tagindex('LOGICAL_SOURCE',atags)
	b1 = tagindex('LOGICAL_FILE_ID',atags)
	b2 = tagindex('Logical_file_id',atags)
	if (b[0] ne -1) then psrce = strupcase(zstruct.LOGICAL_SOURCE)
;TJK 11/2012 - just use logical_source, file_id isn't really
;              appropriate, especially w/ the really long dataset names.
;	if (b1[0] ne -1) then $
;	  psrce = strupcase(zstruct.LOGICAL_FILE_ID)
;	if (b2[0] ne -1) then $
;	  psrce = strupcase(zstruct.Logical_file_id)


;TJK added MOVIE keyword so that the GIF name will not be overriden when
;generating mpg files, since the gif file generated here is just a temp.



 	if not keyword_set(MOVIE) then begin	
	    ;print, 'DATASET=',psrce

	    GIF=strmid(GIF,0,(strpos(GIF,'.gif')))+'_f000.gif'

	    if(FRAME lt 100) then gifn='0'+strtrim(string(FRAME),2) 
	    if(FRAME lt 10) then gifn='00'+strtrim(string(FRAME),2) 
	    if(FRAME ge 100) then gifn=strtrim(string(FRAME),2)

	    GIF=strmid(GIF,0,(strpos(GIF,'.gif')-3))+gifn+'.gif'
	endif

      deviceopen,6,fileOutput=GIF,sizeWindow=[xs+xco,ys+30]

      if not keyword_set(MOVIE) then begin ;don't print out GIF name if MOVIE
        ;print,'GIF=',GIF
        split=strsplit(gif,'/',/extract)
        outdir='/'
        for k=0L,n_elements(split)-2 do outdir=outdir+split[k]+'/'
        print, 'GIF_OUTDIR=',outdir
        print, 'LONG_GIF=',split[k]
        if (reportflag eq 1) then begin
          ;printf,1,'GIF=',GIF & close,1
	  printf,1,'GIF_OUTDIR=',outdir
	  printf,1,'LONG_GIF=',split[k] & close,1
        endif
      endif
   endif else if keyword_set(PNG) then begin
      ; RTB 9/96 Retrieve the Data set name from the Logical source or
;          the Logical file id
	atags=tag_names(zstruct)
	b = tagindex('LOGICAL_SOURCE',atags)
	b1 = tagindex('LOGICAL_FILE_ID',atags)
	b2 = tagindex('Logical_file_id',atags)
	if (b[0] ne -1) then psrce = strupcase(zstruct.LOGICAL_SOURCE)
;TJK added MOVIE keyword so that the GIF name will not be overriden when
;generating mpg files, since the gif file generated here is just a temp.

 	if not keyword_set(MOVIE) then begin	
	    ;print, 'DATASET=',psrce

	    PNG=strmid(PNG,0,(strpos(PNG,'.png')))+'_f000.png'

	    if(FRAME lt 100) then gifn='0'+strtrim(string(FRAME),2) 
	    if(FRAME lt 10) then gifn='00'+strtrim(string(FRAME),2) 
	    if(FRAME ge 100) then gifn=strtrim(string(FRAME),2)

	    PNG=strmid(PNG,0,(strpos(PNG,'.png')-3))+gifn+'.png'
	endif

      deviceopen,7,fileOutput=PNG,sizeWindow=[xs+xco,ys+30]

      if not keyword_set(MOVIE) then begin ;don't print out PNG name if MOVIE
        ;print,'GIF=',GIF
        split=strsplit(png,'/',/extract)
        outdir='/'
        for k=0L,n_elements(split)-2 do outdir=outdir+split[k]+'/'
        print, 'PNG_OUTDIR=',outdir
        print, 'LONG_PNG=',split[k]
        if (reportflag eq 1) then begin
          ;printf,1,'GIF=',GIF & close,1
	  printf,1,'PNG_OUTDIR=',outdir
	  printf,1,'LONG_PNG=',split[k] & close,1
        endif
      endif
   endif else begin             ; open the xwindow
      window,/FREE,XSIZE=xs+xco,YSIZE=ys+30,TITLE=window_title
    endelse

;print, 'image values before the top values are removed ',idat

;find out which values in the original idat image data are fill or
;outside validmin/max
;set them to zero below the call to bytscal
fill_idx = where((idat eq zfill),fillwc)
image2 = idat ;hold on to original image data (still contains fill data at this point) 
if (logZ) then begin ;if log convert data to log before bytscal, otherwise spread of data is lost
   idat = alog(image2) ; log version(can contain nan)
   logidmax=max(idat, /nan, min=logidmin) ; don't include nan or infinity
   idat = bytscl(idat,min=logidmin, max=logidmax, top=!d.table_size-2)
endif else begin
   idat = bytscl(idat,min=idmin, max=idmax, top=!d.table_size-2)
endelse

;2/3/2014 TJK Moved the check for fill data to set the index values to
;zero AFTER the call to bytscl.  Trying to set the image values to
;some appropriate small value before bytscl never works correctly.
    if fillwc gt 0 then begin
;      if keyword_set(DEBUG) then print, 'Number of fill values found, Setting ',fillwc, ' values to 0 (black)'
      idat[fill_idx] = 0 ; set pixels to black (on scale of 0-255) 
    endif

;save off the margins before mucking w/ them.
xmargin=!x.margin
ymargin=!y.margin
default_right = 20 ;change from 14 to 20 
if keyword_set(nonoise) then !y.margin[1] = 3 ;TJK make room for nonoise line of top title

if COLORBAR then begin 
  if (!x.omargin[1]+!x.margin[1]) lt default_right then !x.margin[1] = default_right
  !x.margin[1] = default_right
  !x.margin[0] = 10 ;TJK make room for yaxis scales and lables
  !y.margin[0] = 9 ;TJK make room for xaxis bottom scales 

  if (label_vars[0] ne 'none') then begin ; there are labels, set margins to allow 
				  ; for them.
    !y.margin[0] = 13 ;TJK make room for xaxis scales and lables
    !y.margin[1] = 3 ;TJK make room for xaxis scales and top title

    if (n_elements(label_vars) eq 1) then begin ; don't need as much space
      !y.margin[0] = 9 ;TJK make room for xaxis scales and lables
      !y.margin[1] = 3 ;TJK make room for xaxis scales and top title
    endif
  endif

  if keyword_set(TOP_TITLE) then !y.margin[1] = !y.margin[1] + 1.5 ; adjust slightly for binning labels
     plot,[0,1],[0,1],/noerase,/nodata,xstyle=4,ystyle=4

endif ;endif colorbar

;TJK add in code to explicitly define the labels when doing log scales
if (ylog eq 1) then begin
  if (yvmin le 0) then begin
     print,'WARNING, Log scaling request, change validmin from ',yvmin
     yvmin = 0.001 ;if yvmin isn't greater than 0, then loglevels returns too many values
  endif
  lblv = loglevels([yvmin,yvmax])
  ;do not plot labels lt or gt min/max 
  if (n_elements(lblv) ge 3) then begin
    if (lblv[0] lt yvmin) then lblv=lblv[1:*]
    if (lblv[n_elements(lblv)-1] gt yvmax) then lblv=lblv[0:n_elements(lblv)-2]
  endif
  axis, yaxis=0, color=!d.table_size-1,ylog=ylog, /nodata, yrange=[yvmin,yvmax], $
  ytitle=ytitle, ystyle=1+8, yticks=n_elements(lblv)-1, ytickv=lblv, /save
endif else begin
    if (yscales eq -1) then begin ;use validmin/max
      axis, yaxis=0, color=!d.table_size-1,ylog=ylog, /nodata, yrange=[yvmin,yvmax], $
        ytitle=ytitle, ystyle=1+8, /save
;TJK 2/27/2012 - use scalemin/max if defined
      endif else begin 
      axis, yaxis=0, color=!d.table_size-1,ylog=ylog, /nodata, yrange=[ysmin,ysmax], $
       ytitle=ytitle, ystyle=1+8, /save
    endelse
endelse

if (xlog eq 1) then begin
;TJK 7/24/2019 added this check for xvmin (was already being used for
;yvmin below)
  if (xvmin le 0) then begin
     print,'WARNING, Log scaling request, change validmin from ',xvmin
     xvmin = 0.001 ;if xvmin isn't greater than 0, then loglevels returns too many values
  endif
  lblv = loglevels([xvmin,xvmax])
  ;do not plot labels lt or gt min/max 
  if (n_elements(lblv) ge 3) then begin
    if (lblv[0] lt xvmin) then lblv=lblv[1:*]
    if (lblv[n_elements(lblv)-1] gt xvmax) then lblv=lblv[0:n_elements(lblv)-2]
  endif
  axis, xaxis=0, color=!d.table_size-1, xlog=xlog, /nodata, xrange=[xvmin,xvmax], $
  xtitle=xtitle, xstyle=1+8, xticks=n_elements(lblv)-1, xtickv=lblv, /save
endif else begin
;TJK 3/30/2016 add use of scalmin/max to override autoscaling
    if (xscales eq -1) then begin ;use validmin/max
      axis, xaxis=0, color=!d.table_size-1,xlog=xlog, /nodata, xrange=[xvmin,xvmax], $
        xtitle=xtitle, xstyle=1+8, /save
;use scalemin/max if defined
      endif else begin 
      axis, xaxis=0, color=!d.table_size-1,xlog=xlog, /nodata, xrange=[xsmin,xsmax], $
       xtitle=xtitle, xstyle=1+8, /save
    endelse
endelse

txmin = xdat[0] & txmax = xdat[0]
tymin = ydat[0] & tymax = ydat[0]

;TJK make the symbol sizing adjustable.9/24/2001
symbol = evaluate_plasmastruct(zstruct, ztags, /symsize)
;TJK 2/25/2014 look for xsz=# in display_type
x_symbol = evaluate_plasmastruct(zstruct, ztags, /xsymsize) 
y_symbol = evaluate_plasmastruct(zstruct, ztags, /ysymsize)

if (x_symbol gt 0 or y_symbol gt 0) then begin
  ;set default xsym and ysym same as symbol 2 below
  xsym = [-1.2,1.2,1.2,-1.2,-1.2] & ysym = [-1.4,-1.4,1.4,1.4,-1.4] 
  ;if caller has set either xsz or ysz in the master cdf then adjust
  if (x_symbol gt 0) then xsym = xsym*x_symbol
  if (y_symbol gt 0) then ysym = ysym*y_symbol
  noclip=0
endif else begin

  ;if ylog and no symbol size set, then go w/ 2, else use what's
  ;set in the master cdf.
  if (ylog eq 1L and symbol eq -1) then symbol = 2 ;TJK 2/27/2003 change from 1 to 2
  noclip=1
  case (symbol) of
  '1': begin
	 xsym = [-.4,.4,.4,-.4,-.4] & ysym = [-.4,-.4,.4,.4,-.4]
       end
  '2': begin
	 xsym = [-1.2,1.2,1.2,-1.2,-1.2] & ysym = [-1.4,-1.4,1.4,1.4,-1.4]
	 noclip = 0
       end
  '3': begin
	 xsym = [-1.8,1.8,1.8,-1.8,-1.8] & ysym = [-1.8,-1.8,1.8,1.8,-1.8]
	 noclip = 0
       end
  '4': begin
	 xsym = [-3.2,3.2,3.2,-3.2,-3.2] & ysym = [-3.2,-3.2,3.2,3.2,-3.2]
	 noclip = 0 ; setting no clip so that these really large boxes don't
		    ; fall outside the axes.
      end
  '8': begin ;make this one for rbsp hope-pa-l3
	 xsym = [-1.2,1.2,1.2,-1.2,-1.2] & ysym = [-8.4,-8.4,8.4,8.4,-8.4]
	 noclip = 0 ; setting no clip so that these really large boxes don't
		    ; fall outside the axes.
      end
  '28': begin ;make this one for Wind_sw-ion-dist_swe-farraday
	 xsym = [-2.4,2.4,2.4,-2.4,-2.4] & ysym = [-8.4,-8.4,8.4,8.4,-8.4]
	 noclip = 0 ; setting no clip so that these really large boxes don't
		    ; fall outside the axes.
       end
  else:begin
	 xsym = [-1.2,1.2,1.2,-1.2,-1.2] & ysym = [-1.4,-1.4,1.4,1.4,-1.4]
;	xsym = [-.4,.4,.4,-.4,-.4] change default to larger 
;	ysym = [-.4,-.4,.4,.4,-.4]
       end
  endcase

endelse

log_lin = 0 ;set a default

if (rpi) then begin ;if rpi flag is set then use the programspecs variable 
		    ;(pdat) data to help define the symbol sizes used below.
  if (n_elements(pdat) gt 0) then log_lin = pdat[3,(frame-1)]
  xsym_temp = xsym
  ysym_temp = ysym
  noclip = 0
endif

ysym_save = ysym

;section for 2-d x, y and image data 

if (walk2d_x or walk2d_y) then begin 

for x=0L, isize[1]-1 do begin
  for y=0L, isize[2]-1 do begin

;TJK 2/13/2014 Add logic to make top and bottom y symsize half
;height (so they don't over plot the boxes below/above it
;seems to cause problems        if ((y eq 0) or(y eq (n_elements(ydat) -1))) then ysym=ysym/2

   if ((idat[x,y] gt 0) and (xdat[x,y] ge xvmin) and (ydat[x,y] ge yvmin)) then begin

;     if keyword_set(DEBUG) then  print, 'DEBUG: At X=',xdat[x,y],', Y=', ydat[x,y],' Color=', idat[x,y], ' value=',image2[x,y]
	usersym, xsym, ysym, color=idat[x,y], /fill
	plots, xdat[x,y],ydat[x,y], psym=8, noclip=noclip
	if (xdat[x,y] lt txmin) then txmin = xdat[x,y]
 	if (xdat[x,y] gt txmax) then txmax = xdat[x,y]
	if (ydat[x,y] lt tymin) then tymin = ydat[x,y]
 	if (ydat[x,y] gt tymax) then tymax = ydat[x,y]

        ysym=ysym_save ;reset ysym

     endif ;else print, 'values out of range x,y, xdat, ydat, color = ',x, y, xdat[x,y], ydat[x,y], idat[x,y]
  endfor
endfor

endif else begin 

;section for 1-d x/y arrays w/ 2-d image data

for x=0L, n_elements(xdat)-1 do begin
  for y=0L, n_elements(ydat)-1 do begin
;      print,'Plotting ', xdat[x], ydat[x],'original
;      values',image2[x,y], 'byte ',idat[x,y] 

    if ((idat[x,y] gt 0) and (xdat[x] ge xvmin) and (ydat[y] ge yvmin)) then begin
;    if ((ilogdat[x,y] gt 0) and (xdat[x] ge xvmin) and (ydat[y] ge yvmin)) then begin
;Adjust size of symbol in the x direction
	if((rpi) and (log_lin gt 0) and (xdat[x] ge 20) and (xdat[x] lt 30)) then begin
	  xsym = xsym_temp*1.4
	endif
	if((rpi) and (log_lin gt 0) and (xdat[x] ge 30) and (xdat[x] lt 40)) then begin
	  xsym = xsym_temp*1.6
	endif
	if((rpi) and (log_lin gt 0) and (xdat[x] ge 40) and (xdat[x] lt 50)) then begin
	  xsym = xsym_temp*2.1
	endif
	if((rpi) and (log_lin gt 0) and (xdat[x] ge 50) and (xdat[x] lt 60)) then begin
	  xsym = xsym_temp*2.5
	endif

;Adjust size of symbol in the y direction
	if((rpi) and (log_lin gt 0) and (ydat[y] ge 40) and (ydat[y] lt 50)) then begin
	  ysym = ysym_temp*2.1
	endif
	if((rpi) and (log_lin gt 0) and (ydat[y] ge 50) and (ydat[y] lt 60)) then begin
	  ysym = ysym_temp*2.5
	endif

;TJK 2/13/2014 Add logic to make top and bottom y symsize half
;height (so they don't over plot the boxes below/above it
;seems to cause problems        if ((y eq 0) or(y eq (n_elements(ydat) -1))) then ysym=ysym/2

;if keyword_set(DEBUG) then  print, 'DEBUG: At X=',xdat[x],', Y=', ydat[y],' Color=', idat[x,y], ' value=',image[x,y]
	usersym, xsym, ysym, color=idat[x,y], /fill
	plots, xdat[x],ydat[y], psym=8, noclip=noclip
	if (xdat[x] lt txmin) then txmin = xdat[x]
 	if (xdat[x] gt txmax) then txmax = xdat[x]
	if (ydat[y] lt tymin) then tymin = ydat[y]
 	if (ydat[y] gt tymax) then tymax = ydat[y]

        ysym=ysym_save ;reset ysym

     endif ;else print, 'values out of range x,y, xdat, ydat, color = ',x, y, xdat[x], ydat[y], idat[x,y]
  endfor
endfor

endelse


;redraw the axes

;TJK add in code to explicitly define the labels when doing log scales
if (ylog eq 1) then begin
  if (yvmin le 0) then begin
     print,'WARNING, Log scaling request, change validmin from ',yvmin
     yvmin = 0.001 ;if yvmin isn't greater than 0, then loglevels returns too many values
  endif
  lblv = loglevels([yvmin,yvmax])
  ;do not plot labels lt or gt min/max 
  if (n_elements(lblv) ge 3) then begin
    if (lblv[0] lt yvmin) then lblv=lblv[1:*]
    if (lblv[n_elements(lblv)-1] gt yvmax) then lblv=lblv[0:n_elements(lblv)-2]
  endif
  axis, yaxis=0, color=!d.table_size-1,ylog=ylog, /nodata, yrange=[yvmin,yvmax], $
  ytitle=ytitle, ystyle=1+8, yticks=n_elements(lblv)-1, ytickv=lblv, /save
endif else begin
    if (yscales eq -1) then begin ;use valimin/max
        axis, yaxis=0, color=!d.table_size-1,ylog=ylog, /nodata, yrange=[yvmin,yvmax], $
        ytitle=ytitle, ystyle=1+8, /save
;TJK 2/27/2012 - use scalemin/max if defined
    endif else begin
      axis, yaxis=0, color=!d.table_size-1,ylog=ylog, /nodata, yrange=[ysmin,ysmax], $
        ytitle=ytitle, ystyle=1+8, /save
    endelse
endelse

if (xlog eq 1) then begin
  lblv = loglevels([xvmin,xvmax])
  ;do not plot labels lt or gt min/max 
  if (n_elements(lblv) ge 3) then begin
    if (lblv[0] lt xvmin) then lblv=lblv[1:*]
    if (lblv[n_elements(lblv)-1] gt xvmax) then lblv=lblv[0:n_elements(lblv)-2]
  endif
  axis, xaxis=0, color=!d.table_size-1, xlog=xlog, /nodata, xrange=[xvmin,xvmax], $
  xtitle=xtitle, xstyle=1+8, xticks=n_elements(lblv)-1, xtickv=lblv, /save
endif else begin
;TJK 3/30/2016 add use of scalmin/max to override autoscaling
    if (xscales eq -1) then begin ;use validmin/max
      axis, xaxis=0, color=!d.table_size-1,xlog=xlog, /nodata, xrange=[xvmin,xvmax], $
        xtitle=xtitle, xstyle=1+8, /save
;use scalemin/max if defined
      endif else begin 
      axis, xaxis=0, color=!d.table_size-1,xlog=xlog, /nodata, xrange=[xsmin,xsmax], $
       xtitle=xtitle, xstyle=1+8, /save
    endelse
;  axis, xaxis=0, color=!d.table_size-1, xlog=xlog, $
;  /nodata, xrange=[xvmin,xvmax], xtitle=xtitle, xstyle=1+8, /save
endelse

;original axis generation code - replaced by above by TJK on 1/24/2003
;axis, yaxis=0, color=!d.n_colors,ylog=ylog, /nodata, $
;yrange=[yvmin,yvmax], ytitle=ytitle, ystyle=1+8, /save
;;TJK try forcing the axis scales - for some reason this wasn't being
;;done on the x axis...
;;axis, xaxis=0, color=!d.n_colors, xlog=xlog, $
;;/nodata, xrange=[xvmin,xvmax], xtitle=xtitle, xstyle=8, /save
;axis, xaxis=0, color=!d.n_colors, xlog=xlog, $
;/nodata, xrange=[xvmin,xvmax], xtitle=xtitle, xstyle=1+8, /save

num_columns=1
x_fourth = !d.x_size/4
extra_labels = 6 ;number of extra labels in each column
if (n_elements(label_vars) ge 1 and label_vars[0] ne 'none') then begin ; print all of the extra label data
  if (n_elements(label_vars) ge extra_labels) then num_columns=2

  for l = 0L, n_elements(label_vars)-1 do begin

    l_str = strtrim(string(l),2);convert the index to string
    comm = execute('labl_val = ldat'+l_str)
    l_size = size(labl_val)
    if (l_size[0] eq 2) then comm = execute('labl_val = ldat'+l_str+'(*,FRAME-1)')
    if (l_size[0] eq 1) then comm = execute('labl_val = ldat'+l_str+'(FRAME-1)')
    if (not comm) then print, 'Error=execute for labels failed'
    
    ;now get the lablaxis that goes w/ this data
    comm = execute('title = strtrim(ltitle'+l_str+',2)')
    new_title=''
;TJK changed of 3/16/01 because there's only one title at a time and we need to
;be able to convert the whole value of labl_val at once...
;
;    for t=0,n_elements(title)-1 do begin
;      new_title = new_title +' '+title(t)+': '+strtrim(string(labl_val(t)),2)
;    endfor

;TJK 5/7/01 - added special check for "byte" data 

    l_struct = size(labl_val, /structure)

    if (l_struct.type eq 1 and l_struct.n_elements eq 1) then begin ; int byte data found
      new_title = new_title +' '+title+': '+strtrim(string(labl_val,/print),2)
    endif else begin
       new_title = new_title +' '+title+': '+strtrim(string(labl_val),2)
    endelse

    line = l+1
    alignment = 0.0
    xl = 0.0

    if (num_columns eq 2) then begin
	if (l le extra_labels-1) then begin
          xl = 0.0 ;was x_fourth
	endif else begin
          xl = !d.x_size/2 ;was x_fourth*3
	  line = l - (extra_labels-1)
	  alignment = 0.0
	endelse
    endif
    ;TJK 9/26/2017 if just one label center it under the x axis
    if (n_elements(label_vars) eq 1) then begin
       aligment = 0.5
       line = 2
       xl = !d.x_size/10
    endif

      xyouts,xl, (!d.y_ch_size*(line+2)+3), new_title,/DEVICE,ALIGNMENT=alignment, $
       color=!d.table_size-1

      ; RCJ 07/21/2015  Changed value of color.   This change had already been made in other programs.
      ;color=244
  endfor
endif ;printing label data

    ; subtitle the plot
  ; project_subtitle,astruct.(0),'',/IMAGE,TIMETAG=edat[FRAME-1]
    ;  RCJ 07/23/2015 Added tcolor to call to project_subtitle.  W/o it the plot title was red.
    project_subtitle,zstruct,window_title,/IMAGE, $ 
       TIMETAG=edat[FRAME-1], tcolor=!d.table_size-1

; RTB 10/96 add colorbar
if COLORBAR then begin
  if (n_elements(cCharSize) eq 0) then cCharSize = 0.
  cscale = [idmin, idmax] ; RTB 12/11
  xwindow = !x.window
  offset = 0.01
;TJK 12/18/2018 Let colorbar determine placement/width
;  colorbar, cscale, ctitle, logZ=logZ, cCharSize=cCharSize, $
;        position=[!x.window[1]+offset,      !y.window[0],$
;                  !x.window[1]+offset+0.03, !y.window[1]],$
;        fcolor=!d.table_size-1, /image
  colorbar, cscale, ctitle, logZ=logZ, cCharSize=cCharSize, $
         fcolor=!d.table_size-1, /image
	; RCJ 07/21/2015  Made this change to match similar change in DeviceOpen
        ;fcolor=244, /image
  !x.window = xwindow
endif ; colorbar

;reset the margins
!x.margin=xmargin
!y.margin=ymargin

    if keyword_set(GIF) or keyword_set(PNG) then deviceclose

  endif  ; valid frame value
endif else begin ; Else, produce thumnails of all images



;;;; rotate ISIS MERGEDData images 270 degress
    if(descriptor[0] eq 'MERGEDSTATIONS') then begin
;print, 'found ISIS Mergedstation data, rotating 270 deg'
	for j=0,n_images-1 do begin
          if (j eq 0 ) then begin
            ;set up an array to handle the "rotated images"
            dims = size(idat,/dimensions)
            idat2 = bytarr(dims[1],dims[0],dims[2]); 
	    idat2[*,*,j] = rotate(idat[*,*,j], 3)
          endif else begin
	    idat2[*,*,j] = rotate(idat[*,*,j],3)
	  endelse
        endfor
	idat = idat2
	idat2 = 0 ;clear this array out
     endif ;if MERGEDSTATIONS


;;;;;
  if keyword_set(THUMBSIZE) then tsize = THUMBSIZE else tsize = 50
  isize = size(idat) ; determine the number of images in the data
  if (isize[0] eq 2) then begin
    nimages = 1 & npixels = double(isize[1]*isize[2])
  endif else begin
    nimages = isize[isize[0]] & npixels = double(isize[1]*isize[2]*nimages)
  endelse

;TJK - 8/20/2003 add check for number of images gt 300 and large thumbnails - the
; web browsers don't seem to be able to handle gif's much larger than this.
  ;if((nimages gt 5000) and (tsize gt 50)) then begin
 ;  print, 'ERROR= Too many plasmagram frames '
 ;  nimages_string = strtrim(string(nimages),2)
 ;  print, 'STATUS=Select a shorter time range; image limit is 5000. This request: ',nimages_string
 ;  return, -1
 ; endif


;Added section to deal with limiting
;the requestable number of PNG
;thumbnails (for both large and small
;thumbnails) - CWG 11/06/2017
  if ((tsize lt 166) and (nimages gt 2000)) then begin
     print, 'STATUS= You have requested ',nimages,' frames.'
     print, 'STATUS= Small thumbnail plots are limited to 2000 images, select a shorter time range.'
     return, 0
  endif

  if ((tsize ge 166) and (nimages gt 1000)) then begin
     print, 'STATUS= You have requested ',nimages,' frames.'
     print, 'STATUS= Large thumbnail plots are limited to 1000 images, select a shorter time range.'
     return, 0
  endif

  ; screen out frames which are outside time range, if any
  if NOT keyword_set(TSTART) then start_frame = 0 $
  else begin
    w = where(edat ge TSTART,wc)
    if wc eq 0 then begin
      print,'ERROR=No image frames after requested start time.' & return,-1
    endif else start_frame = w[0]
  endelse
  if NOT keyword_set(TSTOP) then stop_frame = nimages $
  else begin
    w = where(edat le TSTOP,wc)
    if wc eq 0 then begin
      print,'ERROR=No image frames before requested stop time.' & return,-1
    endif else stop_frame = w[wc-1]
  endelse
  if (start_frame gt stop_frame) then no_data_avail = 1L $
  else begin
    no_data_avail = 0L
    if ((start_frame ne 0)OR(stop_frame ne nimages)) then begin
      idat = idat[*,*,start_frame:stop_frame]
      isize = size(idat) ; determine the number of images in the data
      if (isize[0] eq 2) then nimages = 1 else nimages = isize[isize[0]]
      edat = edat[start_frame:stop_frame]
    endif
  endelse

  ; calculate number of columns and rows of images
  ncols = xs / tsize & nrows = (nimages / ncols) + 1
  if (tsize lt 80) then ncols = xs / tsize & nrows = (nimages / ncols) + 2 ;TJK 5/10/2022 add 2 instead of 1 to get more space at the bottom for labels
  label_space = 12 ; TJK added constant for label spacing
  boxsize = tsize+label_space;TJK added for allowing time labels for each image.
  ys = (nrows*boxsize) + 15
  if keyword_set(TOP_TITLE) then begin ; Adjust the window size for binning labels on thumbnails
   ys = ys + 10
  endif

  ; Perform data filtering and color enhancement if any data exists
  if (no_data_avail eq 0) then begin
; Begin changes 12/11 RTB
;   ; determine validmin and validmax values
    a = tagindex('VALIDMIN',tag_names(zstruct))
    if (a[0] ne -1) then begin & b=size(zstruct.VALIDMIN)
      if (b[0] eq 0) then zvmin = zstruct.VALIDMIN $
      else begin
        zvmin = 0 ; default for image data
        print,'WARNING=Unable to determine validmin for ',vname
      endelse
    endif
    a = tagindex('VALIDMAX',tag_names(zstruct))
    if (a[0] ne -1) then begin & b=size(zstruct.VALIDMAX)
      if (b[0] eq 0) then zvmax = zstruct.VALIDMAX $
      else begin
        zvmax = 2000 ; guesstimate
        print,'WARNING=Unable to determine validmax for ',vname
      endelse
    endif
    a = tagindex('FILLVAL',tag_names(zstruct))
    if (a[0] ne -1) then begin & b=size(zstruct.FILLVAL)
      if (b[0] eq 0) then zfill = zstruct.FILLVAL $
      else begin
        zfill = 2000 ; guesstimate
        print,'WARNING=Unable to determine the fillval for ',vname
      endelse
    endif

;TJK added checking of the image scale type 6/2/2003 since we're now
;trying to use this for other datasets, e.g. wind 3dp...
   logz = 0L ; initialize assuming linear
   a = tagindex('SCALETYP',ztags)
   if (a[0] ne -1) then begin
      if (strupcase(zstruct.SCALETYP) eq 'LOG') then logz = 1L
   endif

;   ; filter out data values outside validmin/validmax limits

;TJK 4/1/2014 - need to make any z values outside of validmin/max  eq
;to fill, so that they don't scue all of the adjustments below.

outofrange = where(idat lt zvmin or idat gt zvmax, ocnt)
if (ocnt gt 0) then idat[outofrange] = zfill 
if keyword_set(DEBUG) then print,'WARNING=Number of Z values outside of validmin/max range = ',ocnt


  wmin = min(idat,/nan, MAX=wmax)

;*****
;TJK 8/19/2003 - new section of code added to deal w/ fill values and log scaling and low "valid" values
;a little differently than in the past...
  fdat = where(idat ne zfill, fc)
  if (fc gt 0) then begin
    wmin = min(idat[fdat],/nan, MAX=wmax) ;do not include the fill value when determining the min/max
  endif else begin
    if keyword_set(DEBUG) then print,'WARNING=No data found - all data is fill or out of range!!'
    print,'STATUS=No data found - all data is fill or out of range!!' & return,-1
    wmin=1 & wmax = 1.1
  endelse     

; special check for when Z log scaling - set all values
; less than or equal to 0, to the next lowest actual value.

    if (logz and (wmin le 0.0)) then begin
	w = where((idat le 0.0 and idat ne zfill), wc)
	z = where((idat gt 0.0 and idat ne zfill), zc)
	if (wc gt 0 and zc gt 0) then begin
	  if keyword_set(DEBUG) then print, 'Z log scaling and min values being adjusted, '
	  wmin = min(idat[z], /nan)
	  idat[w] = wmin
	endif
    endif

    w = where(((idat lt zvmin) and (idat ne zfill)),wc)
    if wc gt 0 then begin
      if keyword_set(DEBUG) then print, 'Setting ',wc,' out of range values in image data to lowest data value= ', wmin
      idat[w] = wmin ; set pixels to the lowest real value (for the current image)
      w = 0 ; free the data space
    endif

;determine the image min/max excluding the fill value
    wfill = where((idat ne zfill),wcfill)
    ;if (wcfill gt 0) then idmax=max(idat[wfill], /nan, min=idmin) else print, 'all image data is fill'
    ;;test to see if min/max are equal
    ;if (idmin eq idmax) then begin
    ;   if (logz) then idmin = .00001 ; just in case its zero for log scales
    ;   idmax = idmin+1          ; add so the colobar will be happy
    ;endif
    ;  RCJ 05Sep2017  Changed order of lines above. We could still have case where
    ; all data is fill but idmax and idmin were not defined, causing error on next line. 
    idmax=max(idat[wfill], /nan, min=idmin) 
    if (wcfill gt 0) then begin
       ;test to see if min/max are equal
       if (idmin eq idmax) then begin
          if (logz) then idmin = .00001 ; just in case its zero for log scales
          idmax = idmin+1          ; add so the colobar will be happy
       endif
    endif else print, 'all image data is fill'   

;print, 'debug idmin and max without fill ',idmin, idmax
;stop;
;2/3/2014 TJK changed this to the above code and then assign the
;replacement value for the fill data down below the call to bytscl
;    w = where((idat eq zfill),wc)
;    if wc gt 0 then begin
;      if keyword_set(DEBUG) then print, 'Number of fill values found, Setting ',wc, ' values to 0 or 0.1 (black)'
;      if (logz) then idat[w] = 0.1 else idat[w] = 0 ; set pixels to black
;      w = 0 ; free the data space
;    endif

;TJK - end of 8/19/2003 changes
;****

;Scale in the higher values instead of throwing them out (don't
;include the fill values though).

    w = where((idat gt zvmax and idat ne zfill),wc)
;    w = where((idat gt zvmax),wc)
    if wc gt 0 then begin
      if keyword_set(DEBUG) then print, 'Number of values above the valid max = ',wc, '. Setting them to red...'
;6/25/2004 see below         idat(w) = zvmax -1; set pixels to red
      ;TJK 6/25/2004 - added red_offset function to determine offset
      ;(to red) because of cases like log scaled timed guvi data
      ;where the diff is less than 1.
      diff = zvmax - zvmin
      if keyword_set(GIF) then coffset = red_offset(GIF=GIF,diff)
      if keyword_set(PNG) then coffset = red_offset(PNG=PNG,diff)
      print, 'diff = ',diff, ' coffset = ',coffset
      idat[w] = zvmax - coffset; set pixels to red
      w = 0 ; free the data space
      if wc eq npixels then print,'WARNING=All data outside min/max!!'
   endif

if keyword_set(DEBUG) then begin
  print, 'Image valid min and max: ',zvmin, ' ',zvmax 
  print, 'Actual min and max of data',wmin,' ', wmax
  print, 'Image fill values = ',zfill
endif
;TJK added this section to print out some statistics about the data distribution. 
    if keyword_set(DEBUG) then begin
      print, 'Statistics about the data distribution'
      w = where(((idat lt zvmax) and (idat ge (zvmax-10))),wc)
      if wc gt 0 then print, 'Number of values between ',zvmax,' and ',zvmax-10,' = ',wc
      w = where(((idat lt zvmax-10) and (idat ge (zvmax-20))),wc)
      if wc gt 0 then print, 'Number of values between ',zvmax-10,' and ',zvmax-20,' = ',wc
      w = where(((idat lt zvmax-20) and (idat ge (zvmax-30))),wc)
      if wc gt 0 then print, 'Number of values between ',zvmax-20,' and ',zvmax-30,' = ',wc
      w = where(((idat lt zvmax-30) and (idat ge (zvmax-40))),wc)
      if wc gt 0 then print, 'Number of values between ',zvmax-30,' and ',zvmax-40,' = ',wc
      w = where(((idat lt zvmax-40) and (idat ge (zvmax-50))),wc)
      if wc gt 0 then print, 'Number of values between ',zvmax-40,' and ',zvmax-50,' = ',wc
      w = where(((idat lt zvmax-50) and (idat ge (zvmax-60))),wc)
      if wc gt 0 then print, 'Number of values between ',zvmax-50,' and ',zvmax-60,' = ',wc
    endif

;TJK - 8/1/2003 - for images that we'd like to enlarge to e.g. 160x160
;the congrid function that we're using to resize also does interpolation
;by default... use the cubic keyword to turn this off.
    ; rebin image data to fit thumbnail size
;    if (nimages eq 1) then idat = congrid(idat,tsize,tsize) $
;    else idat = congrid(idat,tsize,tsize,nimages)
;help, idat
    if (nimages eq 1) then idat = congrid(idat,tsize,tsize,cubic=0) $
    else begin
       sidat=idat
       data_type = size(idat,/type)
       ;make the same type of idat array as
       ;the original vs. assuming float
       ;otherwise, the comparison w/ zfill doesn't work!
;       idat=fltarr(tsize,tsize,nimages)
       idat=make_array(tsize,tsize,nimages,type=data_type)
       for ii=0L,nimages-1 do $
          idat[*,*,ii] = congrid(sidat[*,*,ii],tsize,tsize,cubic=0)
    endelse

    ; filter out data values outside 3-sigma for better color spread
    if keyword_set(NONOISE) then begin
;      print, 'before semiminmax min and max = ', zvmin, zvmax
      semiMinMax,idat,zvmin,zvmax
      w = where((idat lt zvmin),wc)
      if wc gt 0 then begin
        print,'WARNING=filtering values less than 3-sigma from image data...'
        idat[w] = zvmin ; set pixels to black
        w = 0 ; free the data space
      endif
      w = where((idat gt zvmax),wc)
      if wc gt 0 then begin
        print,'WARNING=filtering values greater than 3-sigma from image data...'
;6/25/2004 see below         idat(w) = zvmax -1; set pixels to red
         ;TJK 6/25/2004 - added red_offset function to determine offset
         ;(to red) because of cases like log scaled timed guvi data
         ;where the diff is less than 1.
         diff = zvmax - zvmin
         if keyword_set(GIF) then coffset = red_offset(GIF=GIF,diff)
         if keyword_set(PNG) then coffset = red_offset(PNG=PNG,diff)
         print, 'diff = ',diff, ' coffset = ',coffset
         idat[w] = zvmax - coffset; set pixels to red
        w = 0 ; free the data space
      endif
    endif
; Moved this block
;   ; rebin image data to fit thumbnail size
;   if (nimages eq 1) then idat = congrid(idat,tsize,tsize) $
;   else idat = congrid(idat,tsize,tsize,nimages)

;TJK - moved bytscl code down below the deviceopen block, so that the number of colors
; is set BEFORE we use it...

  ; open the window or gif file
  axis_size = 0 ;add extra space on bottom and left for x/y axes - TJK

  if keyword_set(GIF) then begin

    deviceopen,6,fileOutput=GIF,sizeWindow=[xs+xco+axis_size,ys+40+axis_size]
      if (no_data_avail eq 0) then begin
;TJK 5/26/2016 - changed this to use a formatted print to force the
;                string to be printed all on one line (otherwise IDL
;                will print long strings on two lines which breaks our
;                cgi code)
;       if(reportflag eq 1) then printf,1,'IMAGE=',GIF
;       print,'IMAGE=',GIF
       image_string = 'IMAGE='+GIF
       if(reportflag eq 1) then printf,1,format='(a)',image_string
       print,format='(a)',image_string
      endif else begin
        split=strsplit(gif,'/',/extract)
        outdir='/'
        for k=0L,n_elements(split)-2 do outdir=outdir+split[k]+'/'
        print, 'GIF_OUTDIR=',outdir
        print, 'LONG_GIF=',split[k]
       ;if(reportflag eq 1) then printf,1,'GIF=',GIF
       if(reportflag eq 1) then begin
          printf,1,'GIF_OUTDIR=',outdir
          printf,1,'LONG_GIF=',split[k]
       endif  
      endelse
  endif else if keyword_set(PNG) then begin
     deviceopen,7,fileOutput=PNG,sizeWindow=[xs+xco+axis_size,ys+40+axis_size]
     if (no_data_avail eq 0) then begin
        image_string = 'IMAGE='+PNG
        if(reportflag eq 1) then printf,1,format='(a)',image_string
        print,format='(a)',image_string
     endif else begin
        split=strsplit(png,'/',/extract)
        outdir='/'
        for k=0L,n_elements(split)-2 do outdir=outdir+split[k]+'/'
          print, 'PNG_OUTDIR=',outdir
          print, 'LONG_PNG=',split[k]
                                ;if(reportflag eq 1) then printf,1,'GIF=',GIF
          if(reportflag eq 1) then begin
            printf,1,'PNG_OUTDIR=',outdir
            printf,1,'LONG_PNG=',split[k]
          endif    
       endelse
  endif else begin ; open the xwindow
    window,/FREE,XSIZE=xs+xco+axis_size,YSIZE=ys+40+axis_size,TITLE=window_title
  endelse

;*******2/3/2014 TJK new section
;find out which values in the original idat image data are fill
;set them to zero below the call to bytscal.
fill_idx = where((idat eq zfill),fillwc)

image2 = idat ;hold on to original image data (still contains fill data at this point) 
if (logZ) then begin ;if log, convert data to log before bytscl, otherwise spread of data is lost
   idat = alog(image2) ; log version(can contain nan)
   logidmax=max(idat, /nan, min=logidmin) ; don't include nan 
   idat = bytscl(idat,min=logidmin, max=logidmax, top=!d.table_size-2)
endif else begin
   idat = bytscl(idat,min=idmin, max=idmax, top=!d.table_size-2)
endelse

;2/3/2014 TJK Moved the check for fill data to set the index values to
;zero AFTER the call to bytscl.  Trying to set the image values to
;some appropriate small value before bytscl never works correctly.
    if fillwc gt 0 then begin
;      if keyword_set(DEBUG) then print, 'Number of fill values found, Setting ',fillwc, ' values to 0 (black)'
      idat[fill_idx] = 0 ; set pixels to black (on scale of 0-255) 
    endif

;********* end of new section


;;TJK shouldn't need -8 due to the better logic for determining the color
;;offset (at the top of the scale)
;;    idat = bytscl(idat,min=idmin, max=idmax, top=!d.n_colors-8)
;2/3/2014 changed this one line to the above new section because data
;with a wide range that is plotted on a log scal was loosing all of it
;high and low data in the bytscal conversion.  New code converts to
;log before calling bytscl
;    idat = bytscl(idat,min=idmin, max=idmax, top=!d.n_colors-2)

xmargin=!x.margin
ymargin=!y.margin

if COLORBAR then begin
 if (!x.omargin[1]+!x.margin[1]) lt 10 then !x.margin[1] = 10
 !x.margin[1] = 3
 plot,[0,1],[0,1],/noerase,/nodata,xstyle=4,ystyle=4
endif
  !y.margin[0] = 10 ;TJK make room for xaxis scales and lables

; generate the thumbnail plots

; Position each image individually to control layout
    irow=0
    icol=0
    for j=0L,nimages-1 do begin
     if(icol eq ncols) then begin
       icol=0 
       irow=irow+1
     endif
     xpos=icol*tsize+axis_size
     ypos=ys-(irow*tsize+30)
     if (irow gt 0) then ypos = ypos-(label_space*irow) ;TJK modify position for labels


;Added Rich's code for dealing w/ large thumbnails, below...


;# Test code for Large Format
; Scale images  RTB 3/98
      xthb=tsize
      ythb=tsize+label_space
      xsp=float(xthb)/float(xs+80)  ; size of x frame in normalized units
      ysp=float(ythb)/float(ys+30)  ; size of y frame in normalized units
      yi= 1.0 - 10.0/ys             ; initial y point in normalized units
      x0i=0.0095                    ; initial x point in normalized units
      y0i=yi-ysp         ;y0i=0.65
      x1i=0.0095+xsp             ;x1i=.10
      y1i=yi
; Set new positions for each column and row
      x0=x0i+icol*xsp
      y0=y0i-irow*ysp
      x1=x1i+icol*xsp
      y1=y1i-irow*ysp

; 2nd test rescale
      xpimg=xthb
      ypimg=ythb-label_space
; Use device coordinates for Map overlay thumbnails
      xspm=float(xthb)
      yspm=float(ythb-label_space)
      yi= (ys+30) - label_space ; initial y point
      x0i=2.5         ; initial x point
      y0i=yi-yspm
      x1i=2.5+xspm
      y1i=yi
; Set new positions for each column and row
      x0=x0i+icol*xspm
      y0=y0i-(irow*yspm+irow*label_space)
      x1=x1i+icol*xspm
      y1=y1i-(irow*yspm+irow*label_space)
      position=[x0,y0,x1,y1]

      xpos=x0
      ypos=y0

;end of Rich's code for larger thumbnails
     if keyword_set(TOP_TITLE) then ypos = ypos -10 ; move each row down 10 to allow for binning labels

     tv,idat[*,*,j],xpos,ypos,/DEVICE

;original code for labeling the thumbnails, replace with new code that
;will print the date and time, when the date has changed

;     ;TJK get date for this record
;     if (thumbsize gt 100) then edate = decode_cdfepoch(edat(j),/incl_mmm) else edate = decode_cdfepoch(edat(j))
;     shortdate = strtrim(strmid(edate, 10, strlen(edate)), 2) ; shorten it & remove blanks
;     xyouts, xpos, ypos-10, shortdate, color=!d.table_size-1, /DEVICE ;

; TJK 12/21/2018 New section of code  
; Print time tag                                                                               
     foreground = !d.table_size-1 
     if (j eq 0) then begin                                                                         
        prevdate = decode_cdfepoch(edat[j]) ;TJK get date for this record                           
     endif else prevdate = decode_cdfepoch(edat[j-1]) ;TJK get date for this record                 
     edate = decode_cdfepoch(edat[j]) ;TJK get date for this record                                 
     shortdate = strmid(edate, 10, strlen(edate)) ; shorten it                                      
     yyyymmdd = strmid(edate, 0,10) ; yyyymmdd portion of current                                   
     prev_yyyymmdd = strmid(prevdate, 0,10) ; yyyymmdd portion of previous                          
    
    ;TJK 9/19/2019 for data sets like IBEX, that only have one image per 6 months,
    ;don't need the hh:mm:ss portion of the label on the small thumbnails

     zeros = strpos(edate, '00:00:00') ; for data sets with very sparse data, just print the yyyymmdd (no hhmmss)
     if (zeros gt 9 and tsize lt 90) then shortdate = strmid(edate, 0, zeros)  

     if (((yyyymmdd ne prev_yyyymmdd) or (j eq 0)) and tsize gt 90 ) then begin                     
         xyouts, xpos, ypos-10, edate, color=foreground, charsize=1.0,/DEVICE                       
      endif else xyouts, xpos, ypos-10, shortdate, color=foreground,/DEVICE       

     icol=icol+1
    endfor


    ; done with the image
    if ((reportflag eq 1)AND(no_data_avail eq 0)) then begin
      PRINTF,1,'VARNAME=',zstruct.varname 
      PRINTF,1,'NUMFRAMES=',nimages
      PRINTF,1,'NUMROWS=',nrows & PRINTF,1,'NUMCOLS=',ncols
      PRINT,1,'THUMB_HEIGHT=',tsize+label_space
      PRINT,1,'THUMB_WIDTH=',tsize
      PRINTF,1,'START_REC=', start_frame
      PRINTF,1,'ISPNG=' + STRING (KEYWORD_SET (PNG), FORMAT='(I0)')
      PRINTF,1,'PLASMAGRAM=1'
      ; Added line to print out the top title so that its value can be passed to eval4
      ; Ron Yurow (May 3, 2016) 
      IF keyword_set (TOP_TITLE) THEN PRINTF,1,'TOP_TITLE=', top_title

    endif
    if (no_data_avail eq 0) then begin
      PRINT,'VARNAME=',zstruct.varname
      PRINT,'NUMFRAMES=',nimages
      PRINT,'NUMROWS=',nrows & PRINT,'NUMCOLS=',ncols
      PRINT,'THUMB_HEIGHT=',tsize+label_space
      PRINT,'THUMB_WIDTH=',tsize
      PRINT,'START_REC=', start_frame
      PRINT,'ISPNG=' + STRING (KEYWORD_SET (PNG), FORMAT='(I0)')
      PRINT,'PLASMAGRAM=1'
      ; Added line to print out the top title so that its value can be passed to eval4
      ; Ron Yurow (May 3, 2016) 
      IF keyword_set (TOP_TITLE) THEN PRINT,'TOP_TITLE=', top_title

    endif


    if ((keyword_set(CDAWEB))AND(no_data_avail eq 0)) then begin
      if keyword_set(GIF) then begin
         fname = GIF + '.sav' & save_mystruct,astruct,fname
      endif
      if keyword_set(PNG) then begin
         fname = PNG + '.sav' & save_mystruct,astruct,fname
      endif
    endif
    ; subtitle the plot
    ;  RCJ 07/21/2015 Added tcolor to call to project_subtitle.  W/o it the plot title was red.
    project_subtitle,zstruct,window_title,/IMAGE, $
       TIMETAG=[edat[0],edat[nimages-1]], tcolor=!d.table_size-1

; RTB 10/96 add colorbar
if COLORBAR then begin
  if (n_elements(cCharSize) eq 0) then cCharSize = 0.
   cscale = [idmin, idmax]  ; RTB 12/11
;print, 'DEBUG, colorscale min/max ',cscale
;  cscale = [zvmin, zvmax]
  xwindow = !x.window

  !x.window[1]=0.858   ; TJK added these window sizes 5/4/01
  !y.window=[0.13,0.9]

  offset = 0.01 
  if (logZ) then offset = -0.03

;TJK changed logz to take log scaling if specified in the master
;6/9/2003  colorbar, cscale, ctitle, logZ=0, cCharSize=cCharSize, $ 
;TJK 4/15/2016 adjust position of colortable down just little to allow
;space for binning labels.
if keyword_set(TOP_TITLE) then cadjust = 0.1 else cadjust = 0
 colorbar, cscale, ctitle, logZ=logz, cCharSize=cCharSize, $ 
        position=[!x.window[1]+offset,      !y.window[0],$
                  !x.window[1]+offset+0.03, !y.window[1]-cadjust],$
        fcolor=!d.table_size-1, /image
        ; RCJ 07/21/2015  Made this change to match similar change in DeviceOpen
        ;fcolor=244, /image

  !x.window = xwindow
endif ; colorbar

!x.margin=xmargin
!y.margin=ymargin

    if keyword_set(GIF) or keyword_set(PNG) then deviceclose
  endif else begin
    ; no data available - write message to gif file and exit
    print,'STATUS=No data in specified time period.'
    if keyword_set(GIF) or keyword_set(PNG) then begin
      xyouts,xs/2,ys/2,/device,alignment=0.5, 'NO DATA IN SPECIFIED TIME PERIOD',$
        color=!d.table_size-1
        ; RCJ 07/21/2015  Changed value of color.  This change had already been made in other programs.
        ;color=244
      deviceclose
    endif else begin
      xyouts,xs/2,ys/2,/device,alignment=0.5,'NO DATA IN SPECIFIED TIME PERIOD'
    endelse
  endelse
endelse
; blank image (Try to clear)
if keyword_set(GIF) or keyword_set(PNG) then device,/close

return,0
end

