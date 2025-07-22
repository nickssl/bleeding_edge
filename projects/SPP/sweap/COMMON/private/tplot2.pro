function tplot2_ticklabels,a,b,c,d
common tplot2_com2, tickvals, tickstring,nticks_last,cwindow,cgraph
if not keyword_set(tickvals) then tickvals = dblarr(30)
nticks_last = b
tickvals[b] = c
cwindow = getwindows(/current)
cgraph = cwindow.getselect()
ret = time_string(c)

if b ne 0 then diff = tickvals[b]-tickvals[b-1] else diff=0.

print,a,b,c,'  ',ret,'  ' ,diff; ,cwindow,cgraph

return,ret
end



function tplot2,names

get_data,names,data=d
jd = d.x/86400 + julday(1,1,1970,0,0,0)

;p = plot(jd,d.y[*,0],xtickunits=['Seconds','minutes','Hours','Days','month','year'],xticklayout=1)
p = plot(d.x,d.y[*,0],xtickformat='tplot2_ticklabels')


return,p
end