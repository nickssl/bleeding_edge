;$Author: nikos $ 
;$Date: 2021-02-21 18:49:50 -0800 (Sun, 21 Feb 2021) $
;$Header: /home/cdaweb/dev/control/RCS/plasma_movie.pro,v 1.18 2018/12/19 20:11:35 kovalick Exp kovalick $
;$Locker: kovalick $
;$Revision: 29691 $
;+------------------------------------------------------------------------
; NAME: PLASMA_MOVIE
; PURPOSE: To plot plasmagram image data given in the input parameter astruct
;          as a mpeg movie.
; CALLING SEQUENCE:
;       out = plasma_movie(astruct,vname)
; INPUTS:
;       astruct = structure returned by the read_mycdf procedure.
;       vname   = name of the image variable in the structure to plot
;
; KEYWORD PARAMETERS:
;       XSIZE     = x size of single frame
;       YSIZE     = y size of single frame
;       GIF       = name of gif file to send output to
;       REPORT    = name of report file to send output to
;       TSTART    = time of frame to begin imaging, default = first frame
;       TSTOP     = time of frame to stop imaging, default = last frame
;       NONOISE   = eliminate points outside 3sigma from the mean
;       CDAWEB    = being run in cdaweb context, extra report is generated
;       DEBUG    = if set, turns on additional debug output.
;       COLORBAR = calls function to include colorbar w/ image
;
; OUTPUTS:
;       out = status flag, 0=0k, -1 = problem occured.
; AUTHOR:
;       Richard Baldwin, NASA/GSFC/Code 632.0, 
; MODIFICATION HISTORY:
;      09/30/98 : R. Baldwin   : Initial version 
;
;Copyright 1996-2013 United States Government as represented by the 
;Administrator of the National Aeronautics and Space Administration. 
;All Rights Reserved.
;
;------------------------------------------------------------------
;
FUNCTION plasma_movie, astruct, zname, $
                      XSIZE=XSIZE, YSIZE=YSIZE, GIF=GIF, REPORT=REPORT,$
                      TSTART=TSTART,TSTOP=TSTOP,NONOISE=NONOISE,$
                      MOVIE_FRAME_RATE=MOVIE_FRAME_RATE, MOVIE_LOOP=MOVIE_LOOP, $
                      CDAWEB=CDAWEB,DEBUG=DEBUG,COLORBAR=COLORBAR

top = 255
bottom = 0
common colors, r_orig, g_orig, b_orig, r_curr, g_curr, b_curr

if n_elements(movie_frame_rate) eq 0 then movie_frame_rate = 3
if n_elements(movie_loop) eq 0 then movie_loop = 1 ; default is "on"

; Get the Image variable's structure
atags = tag_names(astruct)
z_ax = tagindex(zname,atags) ;z axis
zstruct = astruct.(z_ax)

vname = zstruct.VARNAME ; get the name of the image variable

 ;TJK 3/15/01 - added the check for the descriptor
; Check Descriptor Field for Instrument Specific Settings
tip = tagindex('DESCRIPTOR',tag_names(zstruct))
if (tip ne -1) then begin
  descriptor=str_sep(zstruct.descriptor,'>')
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
  print,'ERROR= Z parameter to plasma_movie not a structure' & return,-1
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

;----------------

if keyword_set(XSIZE) then xs=XSIZE else xs=512
if keyword_set(YSIZE) then ys=YSIZE else ys=512

; mpegID=mpeg_open([xs+xco,ys+40])

; Determine if data is a single image, if so then set the frame
; keyword because a single thumbnail makes no sense
isize = size(idat)
if (isize[0] eq 2) then n_images=1 else n_images=isize[isize[0]]
if (n_images eq 1) then FRAME=1

if keyword_set(FRAME) then begin ; produce plot of a single frame
  if ((FRAME ge 1)AND(FRAME le n_images)) then begin ; valid frame value
   print, 'ERROR= Single movie frame found'
   print, 'STATUS= Single movie frame; select longer time range.'
   return, -1
  endif

endif else begin ; produce movie of all images
;TJK increase limit below from 120 to 300
; if the number of frames exceeds 120 send a error message to the user to
; reselect smaller time
;3/28/2016 - TJK - allow 5000 frames for testing
;  if(n_images gt 120) then begin
  if(n_images gt 5000) then begin
   print, 'ERROR= Too many movie frames '
   print, 'STATUS= Movies limited to 5000 frames; select a shorter time range.'
   return, -1
  endif

;Generate the gif file for a single frame open the window or gif file
  if keyword_set(GIF) then begin
     GIF1=GIF+"junk" ;this is just a temp filename for each frame of the movie
;12/19/2018 TJK added formatted print to force IDL to print on one line (needed
;for parsing the output for the web site)
     image_string = 'MGIF='+GIF
     if(reportflag eq 1) then printf,1,format='(a)',image_string
     print,format='(a)',image_string
   endif 

  ttime = systime(1) ;TJK add a timer
  bad_count = 0
  for j = 0, n_images-1 do begin

    s=plot_plasmagram(astruct, zname , FRAME=j+1, GIF=GIF1, $
 		       /COLORBAR, /MOVIE) 
; read the image from the gif into an array, then write to mpeg file and save
; TJK 3/29/2016 check to see if there was an image returned
    if (s eq 0) then begin
     read_gif, GIF1, image, r, g, b
     dims = size(image,/dimensions)

;     ii=bytarr(3,dims(0),dims(1))
;     ii(0,*,*)=r[image]
;     ii(1,*,*)=g[image]
;     ii(2,*,*)=b[image]
;     mpeg_put, mpegID, IMAGE=ii, FRAME=j, ORDER=1
     write_mgif, GIF, image, r, g, b, delay=(100/movie_frame_rate), loop=movie_loop
     

     if keyword_set(GIF) then begin
	deviceclose
	device,/close
        ; delete temporary gif file
	cmd = strarr(2)
	cmd[0] = "rm"
	cmd[1] = GIF1
	spawn, cmd, /noshell
     endif
     ii = 0 ;clear out array
  endif else begin bad_count = bad_count + 1 ; if good image returned
  endelse

  endfor

  write_mgif, GIF, /close
  nimages_string = strtrim(string(n_images),2)
  if (bad_count gt 0) then begin
     print, 'STATUS=Movie did not include ',strtrim(string(bad_count),2),' empty images out of ',nimages_string
     n_good = n_images - bad_count
     nimages_string = strtrim(string(n_good),2)
  endif

  if keyword_set(DEBUG) then print, 'plasma_movie took ',systime(1)-ttime, ' seconds to generate the movie file containing ',nimages_string,' images'

endelse

; blank image (Try to clear)
if keyword_set(GIF) then device,/close

return,0
end



