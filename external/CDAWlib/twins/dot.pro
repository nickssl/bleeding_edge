;  $Source: /usr/local/share/cvsroot/cdaweb/IDL/twins/dot.pro,v $
;  $Revision: 29691 $
;  $Date: 2021-02-21 18:49:50 -0800 (Sun, 21 Feb 2021) $

function dot, x, y

;+
;  Purpose:
;	
;  Arguments:
;  Preconditions:
;  Postconditions:
;  Invariants:
;  Example:
;  Notes:
;
;  Author:	Pontus Brandt at APL?
;  Modification $Author: nikos $
;-
 Compile_Opt StrictArr
 return, total(x*y)
end
