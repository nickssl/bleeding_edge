;+
;PROCEDURE:	mvn_sta_gen_kp,pathname=pathname,files=files,test=test,def_min=def_min,all=all
;PURPOSE:	
;	To generate tplotsave files of static KP data, if pathname or files not set, will query the user 
;
;INPUT:		
;
;KEYWORDS:
;	all		0/1		if not set, housekeeping and raw variables 'mvn_STA_*' are deleted from tplot after data is loaded
;	test		1/0		If set, will make plots while running and makepng files 
;	def_min		float		minimum number of counts before KP data set to NANs
;
;CREATED BY:	J. McFadden	  14-04-25
;VERSION:	1
;LAST MODIFICATION:  14-03-17
;MOD HISTORY:
;
;NOTES:	  
;	Once MAVEN arrives at Mars, change def_min to 100. or an appropriate value
;	
;-

pro mvn_sta_gen_kp,pathname=pathname,files=files,test=test,def_min=def_min,all=all

if not keyword_set(def_min) then def_min=10.

if keyword_set(test) then def_min=10. 

mvn_sta_l0_load,pathname=pathname,files=files,all=all

	get_data,'mvn_sta_C6_P1D_tot',data=tmp,dtype=dtype

	if dtype eq 0 then print,'Error in mvn_sta_gen_kp : No data available."
	if dtype eq 0 then return

; load spice kernels

	mkernels = mvn_spice_kernels(/load)
	if keyword_set(test) then spice_qrot_to_tplot,'MAVEN_STATIC','MAVEN_SSO',get_omega=3,res=500d,names=tn,check_obj='MAVEN_SPACECRAFT' ,error=  1. *!pi/180  ; 1 degree error

; Color plan: total=black, H+=blue He++=green, O+=cyan  O2+=red  CO2=magenta

	loadct2,43,previous_ct=previous_ct
	cols=get_colors()

	tt_str = time_string(tmp.x[0])
	date = strmid(tt_str,0,4)+strmid(tt_str,5,2)+strmid(tt_str,8,2)

if keyword_set(test) then window,0,xsize=900,ysize=1000
if keyword_set(test) then tplot,['MAVEN_STATIC_QROT_MAVEN_SSO','mvn_sta_C0_P1A_tot','mvn_sta_C0_P1A_E','mvn_sta_C6_P1D_M','mvn_sta_A','mvn_sta_D'],title='MAVEN STATIC KP '+date

;*********************************************************************************************
;*********************************************************************************************
; RAM-Conic modes - periapsis KP

; Note - mass ranges, like "mass_co2", should be adjusted when observations are seen at Mars

; CO2+ RAM-Conic modes 

	mass_co2 = [44,54]
	engy_co2 = [1.0,14.]

	get_4dt,'n_4d','mvn_sta_get_c6',mass=mass_co2,name='mvn_sta_CO2+_raw_density',energy=engy_co2
		options,'mvn_sta_CO2+_raw_density',ytitle='sta C6!C CO2+!C!C1/cm!U3',colors=cols.magenta
		ylim,'mvn_sta_CO2+_raw_density',1,100000,1

	get_4dt,'tb_4d','mvn_sta_get_c6',mass=mass_co2,name='mvn_sta_CO2+_raw_temp',energy=engy_co2
		options,'mvn_sta_CO2+_raw_temp',ytitle='sta C6!C CO2+!C!CeV!U3',colors=cols.magenta
		ylim,'mvn_sta_CO2+_raw_temp',.01,1.,1

	get_4dt,'c_4d','mvn_sta_get_c6',mass=mass_co2,name='mvn_sta_CO2+_raw_density_cnts',energy=engy_co2
		options,'mvn_sta_CO2+_raw_density_cnts',ytitle='sta C6!C CO2+!C!Ccnts/s',colors=cols.magenta
		ylim,'mvn_sta_CO2+_raw_density_cnts',1,10000,1

	get_data,'mvn_sta_CO2+_raw_density_cnts',data=tmp1
	store_data,'mvn_sta_CO2+_raw_temp_cnts',data=tmp1

; O+ RAM-Conic modes

	mass_o = [16,31]
	engy_o = [0.3,7.]

	get_4dt,'n_4d','mvn_sta_get_c6',mass=mass_o,name='mvn_sta_O+_raw_density',energy=engy_o
		options,'mvn_sta_O+_raw_density',ytitle='sta C6!C  O+!C!C1/cm!U3',colors=cols.cyan
		ylim,'mvn_sta_O+_raw_density',10,100000,1

	get_4dt,'tb_4d','mvn_sta_get_c6',mass=mass_o,name='mvn_sta_O+_raw_temp',energy=engy_o
		options,'mvn_sta_O+_raw_temp',ytitle='sta C6!C  O+!C!C1/cm!U3',colors=cols.cyan
		ylim,'mvn_sta_O+_raw_temp',.01,1.,1

	get_4dt,'c_4d','mvn_sta_get_c6',mass=mass_o,name='mvn_sta_O+_raw_density_cnts',energy=engy_o
		options,'mvn_sta_O+_raw_density_cnts',ytitle='sta C6!C  O+!C!Ccnts/s',colors=cols.cyan
		ylim,'mvn_sta_O+_raw_density_cnts',1,10000,1

	get_data,'mvn_sta_O+_raw_density_cnts',data=tmp2
	store_data,'mvn_sta_O+_raw_temp_cnts',data=tmp2

; O2+ RAM-Conic modes

	mass_o2 = [32,43]
	engy_o2 = [0.7,10.]

	get_4dt,'n_4d','mvn_sta_get_c6',mass=mass_o2,name='mvn_sta_O2+_raw_density',energy=engy_o2
		options,'mvn_sta_O2+_raw_density',ytitle='sta C6!C O2+!C!C1/cm!U3',colors=cols.red
		ylim,'mvn_sta_O2+_raw_density',10,100000,1

	get_4dt,'tb_4d','mvn_sta_get_c6',mass=mass_o2,name='mvn_sta_O2+_raw_temp',energy=engy_o2
		options,'mvn_sta_O2+_raw_temp',ytitle='sta C6!C O2+!C!C1/cm!U3',colors=cols.red
		ylim,'mvn_sta_O2+_raw_temp',.01,1.,1

	get_4dt,'c_4d','mvn_sta_get_c6',mass=mass_o2,name='mvn_sta_O2+_raw_density_cnts',energy=engy_o2
		options,'mvn_sta_O2+_raw_density_cnts',ytitle='sta C6!C O2+!C!Ccnts/s',colors=cols.red,psym=-1
		ylim,'mvn_sta_O2+_raw_density_cnts',.1,10000,1

; Note that most of the quality error bars are just counts from 'mvn_sta_O2+_raw_density_cnts'

	get_data,'mvn_sta_O2+_raw_density_cnts',data=tmp3
	store_data,'mvn_sta_O2+_raw_temp_cnts',data=tmp3
	store_data,'mvn_sta_O2+_vx_cnts',data=tmp3
	store_data,'mvn_sta_O2+_vy_cnts',data=tmp3
	store_data,'mvn_sta_O2+_vz_cnts',data=tmp3
	store_data,'mvn_sta_O2+_V-Vsc_MAVEN_MSO_vx_cnts',data=tmp3
	store_data,'mvn_sta_O2+_V-Vsc_MAVEN_MSO_vy_cnts',data=tmp3
	store_data,'mvn_sta_O2+_V-Vsc_MAVEN_MSO_vz_cnts',data=tmp3

; combine plots of density, temp and counts - need to add lables

	store_data,'mvn_sta_raw_density',data=['mvn_sta_CO2+_raw_density','mvn_sta_O+_raw_density','mvn_sta_O2+_raw_density']
		options,'mvn_sta_raw_density',ytitle='sta C6!C Ni!C!C1/cm!U3'
		ylim,'mvn_sta_raw_density',1,100000,1

	store_data,'mvn_sta_raw_temp',data=['mvn_sta_CO2+_raw_temp','mvn_sta_O+_raw_temp','mvn_sta_O2+_raw_temp']
		options,'mvn_sta_raw_temp',ytitle='sta C6!C Ti!C!C1/cm!U3'
		ylim,'mvn_sta_raw_temp',.01,1.,1

	store_data,'mvn_sta_raw_counts',data=['mvn_sta_CO2+_raw_density_cnts','mvn_sta_O+_raw_density_cnts','mvn_sta_O2+_raw_density_cnts']
		options,'mvn_sta_raw_counts',ytitle='sta C6!C!Ccnts/s'
		ylim,'mvn_sta_raw_counts',.1,10000,1

		options,'mvn_sta_raw_counts',psym=-1
		options,'mvn_sta_raw_density',psym=-1

if keyword_set(test) then tplot,/add,['mvn_sta_raw_density','mvn_sta_raw_temp','mvn_sta_raw_counts']

; O2+ velocity

	get_4dt,'vb_4d','mvn_sta_get_c6',mass=mass_o2,name='mvn_sta_O2+_vx',energy=engy_o2,m_int=32.
		options,'mvn_sta_O2+_vx',ytitle='sta C6!C O2+!C!Ckm/s',colors=cols.blue
		ylim,'mvn_sta_O2+_vx',0.,5,0

	get_4dt,'vp_4d','mvn_sta_get_ca',mass=32.,name='mvn_sta_O2+_vy',energy=engy_o2
		options,'mvn_sta_O2+_vy',ytitle='sta C6!C O2+!C!Ckm/s',colors=cols.green
		ylim,'mvn_sta_O2+_vy',0.,1,0

;	get_4dt,'c_4d','mvn_sta_get_ca',name='mvn_sta_O2+_vy_cnts',energy=engy_o2
;		options,'mvn_sta_O2+_vy_cnts',ytitle='sta CA!C O2+!C!Ccnts/s',colors=cols.green,psym=-1
;		ylim,'mvn_sta_O2+_vy_cnts',.1,10000,1

	get_4dt,'vp_4d','mvn_sta_get_c8',mass=32.,name='mvn_sta_O2+_vz',energy=engy_o2
		options,'mvn_sta_O2+_vz',ytitle='sta C8!C O2+!C!Ckm/s',colors=cols.red
		ylim,'mvn_sta_O2+_vz',0.,1,0

;	get_4dt,'c_4d','mvn_sta_get_c8',name='mvn_sta_O2+_vz_cnts',energy=engy_o2
;		options,'mvn_sta_O2+_vz_cnts',ytitle='sta C8!C O2+!C!Ccnts/s',colors=cols.red,psym=-1
;		ylim,'mvn_sta_O2+_vz_cnts',.1,10000,1

		get_data,'mvn_sta_O2+_vx',data=tmp0
		get_data,'mvn_sta_O2+_vy',data=tmp1
		get_data,'mvn_sta_O2+_vz',data=tmp2
		tmp1a=interp(tmp1.y,tmp1.x,tmp0.x)
		tmp2a=interp(tmp2.y,tmp2.x,tmp0.x)
	store_data,'mvn_sta_O2+_V',data={x:tmp0.x,y:[[tmp0.y],[tmp1a],[tmp2a]]}
		options,'mvn_sta_O2+_V',ytitle='sta O2+!C Vi!C!Ckm/s',colors=[cols.blue,cols.green,cols.red]
		ylim,'mvn_sta_O2+_V',-5.,15,0
		options,'mvn_sta_O2+_V',SPICE_FRAME='MAVEN_STATIC'

	store_data,'mvn_sta_O2+_vy_interp',data={x:tmp0.x,y:tmp1a}
	store_data,'mvn_sta_O2+_vz_interp',data={x:tmp0.x,y:tmp2a}



if keyword_set(test) then tplot,/add,['mvn_sta_O2+_V']

; for testing
	npts=n_elements(tmp0.x)
	if keyword_set(test) then store_data,'mvn_sta_O2+_V',data={x:tmp0.x,y:[[replicate(4.,npts)],[replicate(1.,npts)],[replicate(0.,npts)]]}


; rotate ram ion velocity to MSO

	spice_vector_rotate_tplot,'mvn_sta_O2+_V','MAVEN_MSO',check_obj='MAVEN_SPACECRAFT'
		ylim,'mvn_sta_O2+_V_MAVEN_MSO',-5.,15,0
		options,'mvn_sta_O2+_V_MAVEN_MSO',ytitle='sta O2+!CVi MSO!C!Ckm/s'

; get s/c velocity in MSO
; the below code could be replaced with a TBD spice_velocity_to_tplot.pro routine

	scale = 1.
	spice_position_to_tplot,'MAVEN','MARS',frame='MSO',res=4d,scale=scale,name='mvn_pos_MSO'
	get_data,'MAVEN_POS_(MARS-MSO)',data=tmp
	npts=n_elements(tmp.x)
	store_data,'MAVEN_VEL_(MARS-MSO)',data={x:tmp.x[0:(npts-2)]+2.d,y:(tmp.y[1:(npts-1),*]-tmp.y[0:(npts-2),*])/4.d}
		ylim,'MAVEN_VEL_(MARS-MSO)',-5.,15,0

; subtract s/c velocity from ion ram velocity

	get_data,'mvn_sta_O2+_V_MAVEN_MSO',data=tmp1
	get_data,'MAVEN_VEL_(MARS-MSO)',data=tmp2
	sc_vel=interp(tmp2.y,tmp2.x,tmp1.x)

	store_data,'mvn_sta_O2+_V-Vsc_MAVEN_MSO',data={x:tmp1.x,y:tmp1.y-sc_vel}
		ylim,'mvn_sta_O2+_V-Vsc_MAVEN_MSO',-5.,15,0
		options,'mvn_sta_O2+_V-Vsc_MAVEN_MSO',ytitle='sta O2+!CVi-Vsc MSO!C!Ckm/s',colors=[cols.blue,cols.green,cols.red]

	get_data,'mvn_sta_O2+_V-Vsc_MAVEN_MSO',data=tmp5
	store_data,'mvn_sta_O2+_V-Vsc_MAVEN_MSO_vx',data={x:tmp5.x,y:reform(tmp5.y[*,0])}
	store_data,'mvn_sta_O2+_V-Vsc_MAVEN_MSO_vy',data={x:tmp5.x,y:reform(tmp5.y[*,1])}
	store_data,'mvn_sta_O2+_V-Vsc_MAVEN_MSO_vz',data={x:tmp5.x,y:reform(tmp5.y[*,2])}

if keyword_set(test) then tplot,/add,'mvn_sta_O2+_V-Vsc_MAVEN_MSO'

if keyword_set(test) then tplot,[$
	'mvn_sta_O2+_raw_counts','mvn_sta_C6_mode','mvn_sta_C6_att'$
	,'mvn_sta_raw_density','mvn_sta_raw_temp','mvn_sta_raw_counts'$
	,'mvn_sta_O2+_V','mvn_sta_O2+_V_MAVEN_MSO','mvn_sta_O2+_V-Vsc_MAVEN_MSO'$				
	],title=title



	sta_low=['mvn_sta_CO2+_raw_density','mvn_sta_CO2+_raw_density_cnts','mvn_sta_O+_raw_density',$
		'mvn_sta_O+_raw_density_cnts','mvn_sta_O2+_raw_density','mvn_sta_O2+_raw_density_cnts',$
		'mvn_sta_CO2+_raw_temp','mvn_sta_CO2+_raw_temp_cnts','mvn_sta_O+_raw_temp',$
		'mvn_sta_O+_raw_temp_cnts','mvn_sta_O2+_raw_temp','mvn_sta_O2+_raw_temp_cnts',$
		'mvn_sta_O2+_vx','mvn_sta_O2+_vx_cnts','mvn_sta_O2+_vy_interp',$
		'mvn_sta_O2+_vy_cnts','mvn_sta_O2+_vz_interp','mvn_sta_O2+_vz_cnts',$
		'mvn_sta_O2+_V-Vsc_MAVEN_MSO_vx','mvn_sta_O2+_V-Vsc_MAVEN_MSO_vx_cnts','mvn_sta_O2+_V-Vsc_MAVEN_MSO_vy',$
		'mvn_sta_O2+_V-Vsc_MAVEN_MSO_vy_cnts','mvn_sta_O2+_V-Vsc_MAVEN_MSO_vz','mvn_sta_O2+_V-Vsc_MAVEN_MSO_vz_cnts']

if keyword_set(test) then tplot,sta_low

if keyword_set(test) then makepng,'mvn_sta_kp_periapsis_all_'+date


; Mask the tplot data when certain rules are violated for mode or quality (counts)

; If the average counts in O2+ smoothed are not at least "def_min", throw it out. 
	tsmooth2,'mvn_sta_O2+_raw_density_cnts',10
	get_data,'mvn_sta_O2+_raw_density_cnts_sm',data=tmp
	ind = where (tmp.y lt def_min,nind)

; If the mode is not 1 or 2, blank the data
	get_data,'mvn_sta_C6_mode',data=tmp1
	ind1 = where (tmp1.y ne 1 and tmp1.y ne 2,nind1)
	

	def = !values.f_nan

	for i=0,23 do begin
		name = sta_low[i]
		get_data,name,data=tmp2 
		if (nind gt 0) then tmp2.y[ind]=def 
		if (nind1 gt 0) then tmp2.y[ind1]=def 
		store_data,name,data=tmp2
	endfor


; generate plot title

	tt = timerange()
	tt_str = time_string(tt[0])
	date = strmid(tt_str,0,4)+strmid(tt_str,5,2)+strmid(tt_str,8,2)
	title = 'MAVEN STATIC Key Parameter '+date
	options,'mvn_sta_mode',panel_size=.5
	options,'mvn_sta_C0_att',panel_size=.5
	If(!d.name NE 'Z') Then window,0,xsize=900,ysize=1000

; summary low altitude plot

if keyword_set(test) then tplot,sta_low

if keyword_set(test) then makepng,'mvn_sta_kp_periapsis_'+date




;*********************************************************************************************
;*********************************************************************************************
; Color plan: total=black, H+=blue He++=green, O+=cyan  O2+=red  CO2=magenta

if keyword_set(test) then tplot,['MAVEN_STATIC_QROT_MAVEN_SSO','mvn_sta_C0_P1A_tot','mvn_sta_C0_P1A_E','mvn_sta_C6_P1D_M','mvn_sta_A','mvn_sta_D']

	mass_p = [.3,1.6]
	mass_he = [1.6,3.0]

; Flux

	get_4dt,'j_4d','mvn_sta_get_c6',mass=mass_p,name='mvn_sta_H+_flux'
		options,'mvn_sta_H+_flux',ytitle='sta C6!C H+!C!C1/s-cm!U2',colors=cols.blue
		ylim,'mvn_sta_H+_flux',1.e5,1.e9,1

	get_4dt,'j_4d','mvn_sta_get_c6',mass=mass_he,name='mvn_sta_He++_flux'
		options,'mvn_sta_He++_flux',ytitle='sta C6!CHe++!C!C1/s-cm!U2',colors=cols.green
		ylim,'mvn_sta_He++_flux',1.e5,1.e9,1

	get_4dt,'j_4d','mvn_sta_get_c6',mass=mass_o,name='mvn_sta_O+_flux'
		options,'mvn_sta_O+_flux',ytitle='sta C6!C O+!C!C1/s-cm!U2',colors=cols.cyan
		ylim,'mvn_sta_O+_flux',1.e5,1.e9,1

	get_4dt,'j_4d','mvn_sta_get_c6',mass=mass_o2,name='mvn_sta_O2+_flux'
		options,'mvn_sta_O2+_flux',ytitle='sta C6!C O2+!C!C1/s-cm!U2',colors=cols.magenta
		ylim,'mvn_sta_O2+_flux',1.e5,1.e9,1

	store_data,'mvn_sta_flux',data=['mvn_sta_H+_flux','mvn_sta_He++_flux','mvn_sta_O+_flux','mvn_sta_O2+_flux']
		options,'mvn_sta_flux',ytitle='sta C6!C flux!C!C1/s-cm!U2'
		ylim,'mvn_sta_flux',1.e5,1.e9,1

if keyword_set(test) then tplot,/add,'mvn_sta_flux'

; Characteristic Energy

	get_4dt,'ec_4d','mvn_sta_get_c6',mass=mass_p,name='mvn_sta_H+_ec'
		options,'mvn_sta_H+_ec',ytitle='sta C6!CEc H+!C!CeV',colors=cols.blue
		ylim,'mvn_sta_H+_ec',10,10000,1

	get_4dt,'ec_4d','mvn_sta_get_c6',mass=mass_he,name='mvn_sta_He++_ec'
		options,'mvn_sta_He++_ec',ytitle='sta C6!CEc He++!C!CeV',colors=cols.green
		ylim,'mvn_sta_He++_ec',10,10000,1

	get_4dt,'ec_4d','mvn_sta_get_c6',mass=mass_o,name='mvn_sta_O+_ec'
		options,'mvn_sta_O+_ec',ytitle='sta C6!CEc O+!C!CeV',colors=cols.cyan
		ylim,'mvn_sta_O+_ec',10,10000,1

	get_4dt,'ec_4d','mvn_sta_get_c6',mass=mass_o2,name='mvn_sta_O2+_ec'
		options,'mvn_sta_O2+_ec',ytitle='sta C6!CEc O2+!C!CeV',colors=cols.magenta
		ylim,'mvn_sta_O2+_ec',10,10000,1

	store_data,'mvn_sta_ec',data=['mvn_sta_H+_ec','mvn_sta_He++_ec','mvn_sta_O+_ec','mvn_sta_O2+_ec']
		options,'mvn_sta_ec',ytitle='sta C6!C Ec!C!CeV'
		ylim,'mvn_sta_ec',10,10000,1

if keyword_set(test) then tplot,/add,'mvn_sta_ec'

; Counts

	get_4dt,'c_4d','mvn_sta_get_c6',mass=mass_p,name='mvn_sta_H+_cnts'
		options,'mvn_sta_H+_cnts',ytitle='sta C6!C H+!C!C#/s',colors=cols.blue
		ylim,'mvn_sta_H+_cnts',1,1.e5,1

	get_4dt,'c_4d','mvn_sta_get_c6',mass=mass_he,name='mvn_sta_He++_cnts'
		options,'mvn_sta_He++_cnts',ytitle='sta C6!C He++!C!C#/s',colors=cols.green
		ylim,'mvn_sta_He++_cnts',1,1.e5,1

	get_4dt,'c_4d','mvn_sta_get_c6',mass=mass_o,name='mvn_sta_O+_cnts'
		options,'mvn_sta_O+_cnts',ytitle='sta C6!C O+!C!C#/s',colors=cols.cyan
		ylim,'mvn_sta_O+_cnts',1,1.e5,1

	get_4dt,'c_4d','mvn_sta_get_c6',mass=mass_o2,name='mvn_sta_O2+_cnts'
		options,'mvn_sta_O2+_cnts',ytitle='sta C6!C O2+!C!C#/s',colors=cols.magenta
		ylim,'mvn_sta_O2+_cnts',1,1.e5,1

	store_data,'mvn_sta_counts',data=['mvn_sta_H+_cnts','mvn_sta_He++_cnts','mvn_sta_O+_cnts','mvn_sta_O2+_cnts']
		options,'mvn_sta_counts',ytitle='sta C6!C!Ccounts',psym=-1
		ylim,'mvn_sta_counts',.1,1.e5,1

if keyword_set(test) then tplot,/add,'mvn_sta_counts'

; get mode data and determine 
	get_data,'mvn_sta_C6_mode',data=tmp
		time = tmp.x
		ind1 = where (tmp.y ne 2) 
		ind2 = where (tmp.y ne 3) 

; H+ Characteristic Direction

	get_4dt,'vc_4d','mvn_sta_get_ce',mass=mass_p,name='mvn_sta_H+_vc_ce'
		options,'mvn_sta_H+_vc_ce',ytitle='sta CE!C H+!C!Cvec'
		ylim,'mvn_sta_H+_vc_ce',-1.1,1.1,0
		options,'mvn_sta_H+_vc_ce',colors=[cols.blue,cols.green,cols.red]
		options,'mvn_sta_H+_vc_ce',SPICE_FRAME='MAVEN_STATIC'

	get_4dt,'vc_4d','mvn_sta_get_d0',mass=mass_p,name='mvn_sta_H+_vc_d0'
		options,'mvn_sta_H+_vc_d0',ytitle='sta CE!C H+!C!Cvec'
		ylim,'mvn_sta_H+_vc_d0',-1,1,0
		options,'mvn_sta_H+_vc_d0',colors=[cols.blue,cols.green,cols.red]
		options,'mvn_sta_H+_vc_d0',SPICE_FRAME='MAVEN_STATIC'


; combine apid CE and D0 H+ Characteristic Direction

	tmp1=0 & tmp2=0
	get_data,'mvn_sta_H+_vc_ce',data=tmp1
	get_data,'mvn_sta_H+_vc_d0',data=tmp2
		tmp1a = interp(tmp1.y,tmp1.x,time)
		tmp1a[ind1,*]=0.
		tmp2a = interp(tmp2.y,tmp2.x,time)
		tmp2a[ind2,*]=0.

	store_data,'mvn_sta_H+_vc',data={x:time,y:tmp1a+tmp2a}
		options,'mvn_sta_H+_vc',SPICE_FRAME='MAVEN_STATIC'

; rotate to MSO H+ Characteristic Direction

	spice_vector_rotate_tplot,'mvn_sta_H+_vc','MAVEN_MSO',check_obj='MAVEN_SPACECRAFT' 
		options,'mvn_sta_H+_vc_MAVEN_MSO',ytitle='sta !CH+ MSO!C!Cvec'

	get_data,'mvn_sta_H+_vc_MAVEN_MSO',data=tmp3
		store_data,'mvn_sta_H+_vcx_MAVEN_MSO',data={x:time,y:reform(tmp3.y[*,0])}
		store_data,'mvn_sta_H+_vcy_MAVEN_MSO',data={x:time,y:reform(tmp3.y[*,1])}
		store_data,'mvn_sta_H+_vcz_MAVEN_MSO',data={x:time,y:reform(tmp3.y[*,2])}
	

; H+ Anisotropy

	get_4dt,'wc_4d','mvn_sta_get_ce',mass=mass_p,name='mvn_sta_H+_wc_ce'
		options,'mvn_sta_H+_wc_ce',ytitle='sta CE!C H+!C!Caniso',colors=cols.blue
		ylim,'mvn_sta_H+_wc_ce',-.1,1.1,0

	get_4dt,'wc_4d','mvn_sta_get_d0',mass=mass_p,name='mvn_sta_H+_wc_d0'
		options,'mvn_sta_H+_wc_d0',ytitle='sta CE!C H+!C!Caniso',colors=cols.blue
		ylim,'mvn_sta_H+_wc_d0',-.1,1.1,0

; combine apid CE and D0 H+ Anisotropy

	tmp1=0 & tmp2=0
	get_data,'mvn_sta_H+_wc_ce',data=tmp1
	get_data,'mvn_sta_H+_wc_d0',data=tmp2
		tmp1a = interp(tmp1.y,tmp1.x,time)
		tmp1a[ind1,*]=0.
		tmp2a = interp(tmp2.y,tmp2.x,time)
		tmp2a[ind2,*]=0.

	store_data,'mvn_sta_H+_wc',data={x:tmp0.x,y:tmp1a+tmp2a}


; H+ Counts

	get_4dt,'c_4d','mvn_sta_get_ce',mass=mass_p,name='mvn_sta_H+_cnts_ce'
		options,'mvn_sta_H+_cnts_ce',ytitle='sta D0!C H+!C!Ccnts',colors=cols.blue
		ylim,'mvn_sta_H+_cnts_ce',.1,1.e5,1

	get_4dt,'c_4d','mvn_sta_get_d0',mass=mass_p,name='mvn_sta_H+_cnts_d0'
		options,'mvn_sta_H+_cnts_d0',ytitle='sta D0!C H+!C!Ccnts',colors=cols.blue
		ylim,'mvn_sta_H+_cnts_d0',.1,1.e5,1

; combine apid CE and D0 H+ Counts

	tmp1=0 & tmp2=0
	get_data,'mvn_sta_H+_cnts_ce',data=tmp1
	get_data,'mvn_sta_H+_cnts_d0',data=tmp2
		tmp1a = interp(tmp1.y,tmp1.x,time)
		tmp1a[ind1,*]=0.
		tmp2a = interp(tmp2.y,tmp2.x,time)
		tmp2a[ind2,*]=0.

	store_data,'mvn_sta_H+_cnts_ced0',data={x:time,y:tmp1a+tmp2a}

; Dominant Pickup ion Characteristic Direction

	get_4dt,'vc_4d','mvn_sta_get_ce',mass=[16,64],name='mvn_sta_PU_vc_ce'
		options,'mvn_sta_PU_vc_ce',ytitle='sta CE!C PU!C!Cvec'
		ylim,'mvn_sta_PU_vc_ce',-.1,1.1,0
		options,'mvn_sta_PU_vc_ce',colors=[cols.blue,cols.green,cols.red]
		options,'mvn_sta_PU_vc_ce',SPICE_FRAME='MAVEN_STATIC'

	get_4dt,'vc_4d','mvn_sta_get_d0',mass=[16,64],name='mvn_sta_PU_vc_d0'
		options,'mvn_sta_PU_vc_d0',ytitle='sta CE!C PU!C!Cvec'
		ylim,'mvn_sta_PU_vc_d0',-.1,1.1,0
		options,'mvn_sta_PU_vc_d0',colors=[cols.blue,cols.green,cols.red]
		options,'mvn_sta_PU_vc_d0',SPICE_FRAME='MAVEN_STATIC'

; combine apid CE and D0 PU Characteristic Direction

	tmp1=0 & tmp2=0
	get_data,'mvn_sta_PU_vc_ce',data=tmp1
	get_data,'mvn_sta_PU_vc_d0',data=tmp2
		tmp1a = interp(tmp1.y,tmp1.x,time)
		tmp1a[ind1,*]=0.
		tmp2a = interp(tmp2.y,tmp2.x,time)
		tmp2a[ind2,*]=0.

	store_data,'mvn_sta_PU_vc',data={x:time,y:tmp1a+tmp2a}
		options,'mvn_sta_PU_vc',SPICE_FRAME='MAVEN_STATIC'

; rotate to MSO PU Characteristic Direction

	spice_vector_rotate_tplot,'mvn_sta_PU_vc','MAVEN_MSO',check_obj='MAVEN_SPACECRAFT' 
		options,'mvn_sta_PU_vc_MAVEN_MSO',ytitle='sta !CPU MSO!C!Cvec'

	get_data,'mvn_sta_PU_vc_MAVEN_MSO',data=tmp3
		store_data,'mvn_sta_PU_vcx_MAVEN_MSO',data={x:time,y:reform(tmp3.y[*,0])}
		store_data,'mvn_sta_PU_vcy_MAVEN_MSO',data={x:time,y:reform(tmp3.y[*,1])}
		store_data,'mvn_sta_PU_vcz_MAVEN_MSO',data={x:time,y:reform(tmp3.y[*,2])}
	

; Pickup ion Anisotropy

	get_4dt,'wc_4d','mvn_sta_get_ce',mass=[16,64],name='mvn_sta_PU_wc_ce'
		options,'mvn_sta_PU_wc_ce',ytitle='sta CE!C PU!C!Ciso',colors=cols.blue
		ylim,'mvn_sta_PU_wc_ce',-.1,1.1,0

	get_4dt,'wc_4d','mvn_sta_get_d0',mass=[16,64],name='mvn_sta_PU_wc_d0'
		options,'mvn_sta_PU_wc_d0',ytitle='sta CE!C PU!C!Ciso',colors=cols.blue
		ylim,'mvn_sta_PU_wc_d0',-.1,1.1,0

; combine apid CE and D0 PU Anisotropy

	tmp1=0 & tmp2=0
	get_data,'mvn_sta_PU_wc_ce',data=tmp1
	get_data,'mvn_sta_PU_wc_d0',data=tmp2
		tmp1a = interp(tmp1.y,tmp1.x,time)
		tmp1a[ind1,*]=0.
		tmp2a = interp(tmp2.y,tmp2.x,time)
		tmp2a[ind2,*]=0.

	store_data,'mvn_sta_PU_wc',data={x:time,y:tmp1a+tmp2a}


; Pickup ion counts

	get_4dt,'c_4d','mvn_sta_get_ce',mass=[16,64],name='mvn_sta_PU_cnts_ce'
		options,'mvn_sta_PU_cnts_ce',ytitle='sta D0!C PU!C!Ccnts',colors=cols.red
		ylim,'mvn_sta_PU_cnts_ce',1,1.e5,1

	get_4dt,'c_4d','mvn_sta_get_d0',mass=[16,64],name='mvn_sta_PU_cnts_d0'
		options,'mvn_sta_PU_cnts_d0',ytitle='sta D0!C PU!C!Ccnts',colors=cols.red
		ylim,'mvn_sta_PU_cnts_d0',1,1.e5,1

; combine apid CE and D0 PU Counts

	tmp1=0 & tmp2=0
	get_data,'mvn_sta_PU_cnts_ce',data=tmp1
	get_data,'mvn_sta_PU_cnts_d0',data=tmp2
		tmp1a = interp(tmp1.y,tmp1.x,time)
		tmp1a[ind1,*]=0.
		tmp2a = interp(tmp2.y,tmp2.x,time)
		tmp2a[ind2,*]=0.

	store_data,'mvn_sta_PU_cnts_ced0',data={x:time,y:tmp1a+tmp2a}

; plot the data

	sta_high = ['mvn_sta_H+_flux','mvn_sta_H+_ec','mvn_sta_H+_cnts',$
	'mvn_sta_He++_flux','mvn_sta_He++_ec','mvn_sta_He++_cnts',$
	'mvn_sta_O+_flux','mvn_sta_O+_ec','mvn_sta_O+_cnts',$
	'mvn_sta_O2+_flux','mvn_sta_O2+_ec','mvn_sta_O2+_cnts',$
	'mvn_sta_H+_vcx_MAVEN_MSO','mvn_sta_H+_vcy_MAVEN_MSO','mvn_sta_H+_vcz_MAVEN_MSO','mvn_sta_H+_wc','mvn_sta_H+_cnts_ced0',$
	'mvn_sta_PU_vcx_MAVEN_MSO','mvn_sta_PU_vcy_MAVEN_MSO','mvn_sta_PU_vcz_MAVEN_MSO','mvn_sta_PU_wc','mvn_sta_PU_cnts_ced0']

if keyword_set(test) then tplot,sta_high

if keyword_set(test) then makepng,'mvn_sta_kp_apoapsis_all_'+date


; Mask the tplot data when certain rules are violated for mode or quality (counts)

; If the average counts in H+ smoothed are not at least "def_min", throw it out. 
	tsmooth2,'mvn_sta_H+_cnts',10
	get_data,'mvn_sta_H+_cnts_sm',data=tmp
	ind = where (tmp.y lt def_min,nind)

; If the mode is not 2 or 3, blank the data
	get_data,'mvn_sta_C6_mode',data=tmp1
	ind1 = where (tmp1.y ne 2 and tmp1.y ne 3,nind1)
	
	def = !values.f_nan

	for i=0,21 do begin
		name = sta_high[i]
		get_data,name,data=tmp2 
		if (nind gt 0) then tmp2.y[ind]=def 
		if (nind1 gt 0) then tmp2.y[ind1]=def 
		store_data,name,data=tmp2
	endfor


if keyword_set(test) then tplot,sta_high

if keyword_set(test) then makepng,'mvn_sta_kp_apoapsis_'+date


;*********************************************************************************************
;*********************************************************************************************

 	tplot_save,[sta_low,sta_high],filename='mvn_sta_kp_'+date,/compress

;*********************************************************************************************
;*********************************************************************************************
	loadct2,previous_ct



end