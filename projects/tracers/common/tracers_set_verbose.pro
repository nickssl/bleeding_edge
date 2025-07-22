;+
;NAME:
; tracers_set_verbose
;
;PURPOSE:
; Sets verbose level in !tracers.verbose and in tplot_options
;
;CALLING SEQUENCE:
; tracers_set_verbose, vlevel
;
;INPUT:
; vlevel = a verbosity level, if not set then !tracers.verbose is used
;          (this is how you would propagate the !tracers.verbose value
;          into tplot options)
;
;HISTORY:
; 21-aug-2012, jmm, jimm@ssl.berkeley.edu
; 12-oct-2012, jmm, Added this comment to test SVN
; 12-oct-2012, jmm, Added this comment to test SVN, again
; 18-oct-2012, jmm, Another SVN test
; 10-apr-2015, moka, adapted for elf from 'thm_set_verbose'
;
; $LastChangedBy: elfin_shared $
; $LastChangedDate: 2025-07-14 22:58:01 -0700 (Mon, 14 Jul 2025) $
; $LastChangedRevision: 33465 $
; $URL: svn+ssh://thmsvn@ambrosia.ssl.berkeley.edu/repos/spdsoft/trunk/projects/tracers/common/tracers_set_verbose.pro $
;-
Pro tracers_set_verbose, vlevel

  ;Need to check for !elf
  defsysv,'!tracers',exists=exists
  if not keyword_set(exists) then begin
    tracers_init
  endif

  If(n_elements(vlevel) Eq 0) Then vlev = !tracers.verbose Else vlev = vlevel[0]

  !tracers.verbose = vlev

  tplot_options, 'verbose', vlev

  Return
End
