;$Author: nikos $
;$Date: 2021-02-21 18:49:50 -0800 (Sun, 21 Feb 2021) $
;$Header: /home/cdaweb/dev/control/RCS/generate_inventory.pro,v 1.28 2016/04/14 16:33:20 johnson Exp rcjohns1 $
;$Locker: rcjohns1 $
;$Revision: 29691 $
;---------------------------------------------------------------------------
;Modifications: 2/4/98 - T. Kovalick - modified this to do what the inventory function
;in inventory.pro use to do, so that I can free up memory w/ delvar (has to be
;done at the main program level).

@compile_inventory.pro

;debug = 1

; Read the metadata file...
a = ingest_database('/home/cdaweb/metadata/istp_public_cdfmetafile.txt',DEBUG=DEBUG)

; Draw inventory graph...
;s=draw_inventory(a,TITLE='ISTP PUBLIC DATA',GIF='/home/cdaweb/metadata/istp_public_cdfmetafile.gif',$
;START_TIME='1992/07/01 00:00:00', STOP_TIME='2002/12/31 23:59:59', /debug)

aa=a

s=draw_inventory(a,TITLE='Active Mission Data 1960-2029', $
PNG='/home/cdaweb/metadata/istp_public_cdfmetafile.png',$
/long_line, /wide_margin, $
START_TIME='1960/01/01 00:00:00', STOP_TIME='2029/01/01 23:59:59', /BIGPLOT)
a=aa
s=draw_inventory(a,TITLE='ISTP PUBLIC DATA 1990-1994', $
PNG='/var/www/cdaweb/htdocs/istp_public/avail_1990-1994.png',$
/long_line, /wide_margin, $
START_TIME='1990/01/01 00:00:00', STOP_TIME='1994/12/31 23:59:59', /FIVEYEAR)
a=aa
s=draw_inventory(a,TITLE='ISTP PUBLIC DATA 1995-1999', $
PNG='/var/www/cdaweb/htdocs/istp_public/avail_1995-1999.png',$
/long_line, /wide_margin, $
START_TIME='1995/01/01 00:00:00', STOP_TIME='1999/12/31 23:59:59', /debug, /FIVEYEAR)
a=aa
s=draw_inventory(a,TITLE='ISTP PUBLIC DATA 2000-2004', $
PNG='/var/www/cdaweb/htdocs/istp_public/avail_2000-2004.png',$
/long_line, /wide_margin, $
START_TIME='2000/01/01 00:00:00', STOP_TIME='2004/12/31 23:59:59', /debug, /FIVEYEAR)
a=aa
s=draw_inventory(a,TITLE='ISTP PUBLIC DATA 2005-2009', $
PNG='/var/www/cdaweb/htdocs/istp_public/avail_2005-2009.png',$
/long_line, /wide_margin, $
START_TIME='2005/01/01 00:00:00', STOP_TIME='2009/12/31 23:59:59', /debug, /FIVEYEAR)
a=aa
s=draw_inventory(a,TITLE='ISTP PUBLIC DATA 2010-2014', $
PNG='/var/www/cdaweb/htdocs/istp_public/avail_2010-2014.png',$
/long_line, /wide_margin, $
START_TIME='2010/01/01 00:00:00', STOP_TIME='2014/12/31 23:59:59', /debug, /FIVEYEAR)
a=aa
s=draw_inventory(a,TITLE='ISTP PUBLIC DATA 2015-2019', $
PNG='/var/www/cdaweb/htdocs/istp_public/avail_2015-2019.png',$
/long_line, /wide_margin, $
START_TIME='2015/01/01 00:00:00', STOP_TIME='2019/12/31 23:59:59', /debug, /FIVEYEAR)
a=aa
s=draw_inventory(a,TITLE='ISTP PUBLIC DATA 2020-2024', $
PNG='/var/www/cdaweb/htdocs/istp_public/avail_2020-2024.png',$
/long_line, /wide_margin, $
START_TIME='2020/01/01 00:00:00', STOP_TIME='2024/12/31 23:59:59', /debug, /FIVEYEAR)
a=aa
s=draw_inventory(a,TITLE='ISTP PUBLIC DATA 2025-2029', $
PNG='/var/www/cdaweb/htdocs/istp_public/avail_2025-2029.png',$
/long_line, /wide_margin, $
START_TIME='2025/01/01 00:00:00', STOP_TIME='2029/12/31 23:59:59', /debug, /FIVEYEAR)
;
delvar, a,aa

; Read the metadata file... Added this back in w/ release of IDL 5.1 (won't work w/ previous versions)
a = ingest_database('/home/cdaweb/metadata/full_cdfmetafile.txt',DEBUG=DEBUG)
; Draw inventory graph...
s=draw_inventory(a,TITLE='FULL CDAWEB HOLDINGS',PNG='/home/cdaweb/metadata/full_cdfmetafile.png',$
/long_line, /wide_margin, $
/BIGPLOT, /debug)
delvar, a

;generation of the cluster, radiation,bowshock and cdaw9 being done in generate_inventory2.pro. TJK 6/3/98
;generation of the two space physics and one image files is done in generate_small.pro
;because we run out of memory at this point...TJK 2/11/98

exit







