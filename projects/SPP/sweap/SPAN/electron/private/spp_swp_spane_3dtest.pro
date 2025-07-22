; $LastChangedBy: phyllisw2 $
; $LastChangedDate: 2018-11-08 10:37:04 -0800 (Thu, 08 Nov 2018) $
; $LastChangedRevision: 26070 $
; $URL: svn+ssh://thmsvn@ambrosia.ssl.berkeley.edu/repos/spdsoft/trunk/projects/SPP/sweap/SPAN/electron/private/spp_swp_spane_3dtest.pro $


pro spp_swp_spane_3dtest,trange,spane=spane,timesort=timesort_flag,plotit,test

  if ~keyword_set(plotit) then plotit = 0 else plotit = 1
  if ~keyword_set(test) then test = 0 else test = 1
  spe = spp_swp_spe_param();reset=reset)

  emode = 21
  etable = spe.etables[emode]
  
  fsindex = reform(etable.fsindex,4,256)   ; full sweep
  fsindex = reform(etable.fsindex,4,8,32)   ; full sweep
  ;fsindex = reform(fi,4,8,32)

  sweepv_dac_fs= etable.sweepv_dac[fsindex]  ; * etable.k / etable.hvgain
  defv_dac_fs  = etable.defv1_dac[fsindex]  -  etable.defv2_dac[fsindex]  ;* 1.
  spv_dac_fs   = etable.spv_dac[fsindex]
  
  tsindex = reform(etable.tsindex,256,256)
  tsindex_i = [1,1,1,1] # reform(tsindex[*,128])
  ind = tsindex_i
  sweepv_dac_ts= etable.sweepv_dac[ind]  ; * etable.k / etable.hvgain
  defv_dac_ts = etable.defv1_dac[ind] - etable.defv2_dac[ind]  ;* 1.
  spv_dac_ts = etable.spv_dac[ind]

  if plotit then begin
    wi,4
    plot,etable.sweepv_dac, etable.defv1_dac - etable.defv2_dac,/xlog,ps=-4,symsize=.2,xrange=[2,6000.],xstyle=3
    oplot,sweepv_dac_fs,defv_dac_fs ,psym=-1,color=6
    oplot,sweepv_dac_ts,defv_dac_ts,psym=-4,color=2
  endif

  ; move from dacs to energy and defl  average over substeps
  defConvEst = 0.0025
  sweepv = average(sweepv_dac_fs * .5, 1)    ;  approximate,  average over substeps
  deflv  = average((defv_dac_fs ) *defConvEst, 1)   ; approximate & only good for tables less than 4keV.

  if 0 then begin
    print,deflv    ; 256 deflector values in time order
    print,sweepv   ; 256 hemisphere values in time order
  endif
  
  anodes = indgen(16)

  timesort = indgen(8,32)
  timesort = reform( replicate(1,16) # indgen(256), 16,8,32 )
  deflv_all = deflv[timesort]
  sweep_all = sweepv[timesort]
  anode_all = reform(anodes # replicate(1,8*32), 16,8,32 )


  defsort = indgen(8,2,16)
  if not keyword_set(timesort_flag) then for i = 0,15 do defsort[*,1,i] = reverse(defsort[*,1,i])           ; reverse direction of every other deflector sweep
  defsort = reform(defsort,8,32)                                       ; defsort will reorder data so that it is no longer in time order - but deflector values are regular

  dacsort = reform( replicate(1,16) # defsort[*] , 16,8,32 )           ; sweeps don't vary with anode

  if 0 then begin
    print,deflv[defsort]      ;   all anodes
    print,sweepv[defsort]     ;   all anodes    
  endif

  datsort = reform( replicate(1,16) # defsort[*]*16 , 16,8,32 ) + reform( indgen(16) # replicate(1,8*32) , 16,8,32 )                ; data varies with anode

  time_all = indgen(16,8,32)
  if 0 then begin
    print,deflv_all[datsort]
    print,sweep_all[datsort]
    print,anode_all[datsort]
    print,time_all[datsort]    
  endif


  if keyword_set(spane) then begin
    sf0 = spp_apdat('364'x)  ; spa_sf0
    dphi =  [1,1,1,1,1,1,1,1,4,4,4,4,4,4,4,4] * 240./40.
    phi = total(dphi,/cumulative)
  endif else begin
    sf0 = spp_apdat('374'x)  ; spb_sf0
    dphi =  [4,4,4,4,1,1,1,1,1,1,1,1,4,4,4,4] * 240./40.
    phi = total(dphi,/cumulative) - 120 - 12
  endelse

  print,phi
  print,sf0.name
  geom_all = dphi[anode_all] / 6.

  datarray = sf0.data.array
  if not keyword_set(trange) then ctime,trange
  tindex = round(interp(lindgen(n_elements(datarray)),datarray.time,trange))
  irange = minmax(tindex)
  timebar,trange

  nrgs = sweep_all[datsort]
  defs = deflv_all[datsort]
  geom = geom_all[datsort]
  anode = anode_all[datsort]

  ;geom=1

  dat_all = 0
  nsum=0
  
  for i = irange[0],irange[1] do begin
    di = datarray[i]
    if di.ndat eq 4096  then  begin
      dat_all += reform( *(di.pdata), 16,8,32 )  
      nsum +=1
    endif    else dprint,'bad data'
  endfor
  
  dat_all /= nsum
  printdat,nsum

  ;dat_all = shift(dat_all,16)


  dat3d = dat_all[datsort]
  flx = dat3d / geom  > .001

  col = indgen(8)*32 +16

  if plotit then begin
    title = sf0.name
    wi,1
    xlim,lim1,1,5000,1
    ylim,lim1,.01,2000,1
    options,lim1,title=title
    box,lim1
    cols = bytescale(defs)
    cols = bytescale(anode)
    printdat,cols
    for a=0,15 do for d=0,7 do oplot,reform(nrgs[a,d,*]),reform(flx[a,d,*]),color=cols[a,d,0] ;col[d]
   
    wi,2
    xlim,lim2,-65,65
    ylim,lim2,.01,2000,1
    options,lim2,title=title
    box,lim2
    for a=0,15 do for e=0,31,3 do oplot,reform(defs[a,*,e]),reform(flx[a,*,e]),color=col[e mod 8],psym=-1

    wi,3
    xlim,lim3,-5,260
    xlim,lim3,120,210
    ylim,lim3,.01,2000,1
    options,lim3,title=title
    box,lim3
    col16 = indgen(16) *16 + 8
    flx256 = reform(flx,16,256)
    nrg256 = reform(nrgs,16,256)
    dfl256 = reform(defs,16,256)
    for a=0,15 do   oplot, flx256[a,*], psym=-1, color=col16[a]
    for a=0,15 do   oplot, nrg256[a,*], psym=-1, color=col16[a]
    for a=0,15 do   oplot, dfl256[a,*], psym=-1, color=2
    for a=0,15 do   oplot, -dfl256[a,*], psym=-1, color=6
  endif
  
  ;;;-----CAUTION!!!!!-----;;;;
  ;;;----COPY FROM SWIA----;;;;
  if test then begin 
    dat =   {data_name:   'SPE_TEST',      $
      valid:      1,        $
      project_name:   'PSP',      $
      units_name:     units,        $
      units_procedure:  'spp_swp_spe_convert_units', $
      time:       startt,       $
      end_time:     startt+4.0,       $
      integ_t:    dt_int,       $
      dt:       4.0,        $
      dt_arr:     dt_arr,       $
      nbins:      nbins,        $
      nenergy:    nenergy,      $
      data:       data,       $
      energy:     energy,       $
      theta:      theta,        $
      phi:      phi,        $
      denergy:    denergy,            $
      dtheta:     dtheta,       $
      dphi:     dphi,       $
      domega:     domega,       $
      eff:      eff,        $
      charge:     1.,       $
      sc_pot:     scpot,        $
      magf:     magf,       $
      mass:       5.68566e-06*1836.,    $
      geom_factor:    geom_factor,      $
      gf:       gf,       $
      dead:     100e-9,       $
      bins:       replicate(1,nenergy,nbins)  $
    }
  endif
  
end
