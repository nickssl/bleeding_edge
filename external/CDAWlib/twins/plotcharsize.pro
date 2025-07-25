;  $Source: /usr/local/share/cvsroot/cdaweb/IDL/twins/plotcharsize.pro,v $
;  $Revision: 29691 $
;  $Date: 2021-02-21 18:49:50 -0800 (Sun, 21 Feb 2021) $

FUNCTION PlotCharSize 

;+
;  Purpose:
;	Return a structure containing the normalized average character 
;	size in the x and y dimensions of a single character on the 
;	current plotting device.
;
;  Arguments:  None:
;  Preconditions:
;  Postconditions:
;	Return an anonymous structure with fields x and y.  Both
;	fields hold floating point values representing the 
;	normalized width and height, respectively, of a 
;	character cell.
;
;  Invariants:
;  Example:
;	cs = PlotCharSize()
;	margin.top = 1.0 - 2*cs.y
;
;  Author:	Randy Bremmer (rrb), January, 2002
;  Modification $Author: nikos $
;-
 Compile_Opt StrictArr

 on_error, 2	;Errors not our fault
 if !d.y_ch_size GT !d.y_vsize then Message, "No plot device."

 cs = (convert_coord(!d.x_ch_size, !d.y_ch_size, /device, /to_normal))[0:1] 
 return, {x:cs[0], y:cs[1]}

End
