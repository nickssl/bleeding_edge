


function mvn_sep_test1,x,param=p
  if n_params() eq 0 then begin
    p = {  $
      func:'mvn_sep_test1', $
      h0: 100d, $
      scht:  10d, $
      bkg: 5.d, $
      xflx:  5d, $
      flag:0  }
    return , p
  endif

  y = (p.bkg+p.xflx)*((1+erf((x-p.h0)/p.scht))/2)+p.bkg
  return,y
end

pro mvn_sep_fov_xray_fit

  !p.charsize=1.5

  if not keyword_set(x) then begin
    f='/Users/davin/Downloads/sepxray.dat'
    f1='C:\Users\rahmati\Desktop\sepxray.dat'
    restore,/verbose,f1
    w = where(atal00 gt -50 and atal00 lt 200)
    x = atal00[w]
    y = crl00[w]*2

    dx = x - shift(x,1)
    dx[0] = dx[1]
    orbit = total(/cum,dx gt 0)

  endif
  old = 0
  if old then begin
    plot,x,y,psym=2,symsize=.2,yrange=minmax(y)+[-1,2],/ystyle,title='SEP SCOX1 Xray flux (11 consecutive orbits)',xtitle='Tangent Altitude (km)',ytitle='Counts per 2sec Accumulation'
    xv = dgen()
  endif else begin
    win = window(/current)
    win.erase
    plt = plot(/current,x,y,'r1.',title='SEP SCOX1 Xray flux (11 consecutive orbits)',xtitle='Tangent Altitude (km)',ytitle='Counts per 2sec Accumulation',yrange=minmax(y)+[-1,1])
    xv = dgen(range=plt.xrange)
  endelse

  if not keyword_set(binsize) then binsize=5.

  yavg = average_hist(y,x,binsize=binsize,xbins=xb,stdev=stdev,hist=hist)
  stdevmn = stdev/sqrt(hist)

  if old then begin
    oplot,xb,yavg,psym=4,color=6
    Errplot, Xb, yavg-stdevmn, yavg+stdevmn ,color=6 ;, Width = width, $
  endif else begin
    plterr = errorplot(/overplot,xb,yavg,stdevmn,color='b',symbol='D',linestyle=' ')
  endelse


  p = mvn_sep_test1()

  fit,x,y,param=p
  dy = sqrt(func(x,param=p))


  fit,x,y,param=p,dy = dy

  if old then begin
    oplot,xv,func(xv,param=p)
  endif else begin
    plt_theory = plot(/overplot,xv,func(xv,param=p))
  endelse


  pbin = p
  fit,xb,yavg,param=pbin,dy=stdevmn,res=res
  ;oplot,xv,func(xv,param=pbin),color=6

  pp1 = p
  pp2 = p
  pp1.h0 = res.par.h0 -res.dpar.h0
  pp2.h0 = res.par.h0 +res.dpar.h0

  if old then begin
    oplot,xv,func(xv,param=pp),color=2,linestyle=2
    oplot,xv,func(xv,param=pp),color=2,linestyle=2
  endif else begin
    plt_1 = plot(/overplot,xv,func(xv,param=pp1),color=2,linestyle=2)
    plt_2 = plot(/overplot,xv,func(xv,param=pp2),color=2,linestyle=2)
  endelse


  if 0 then begin
    for ht=68,76,4 do begin
      pp = p
      pp.h0 =ht
      print,ht
      fit,x,y,param=pp,names='scht bkg xflx',res=res
      pf,pp

    endfor
  endif

end
