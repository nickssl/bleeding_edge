;+
;FUNCTION:   mvn_swe_flatfield
;PURPOSE:
;  Maintains the angular sensitivity calibration and provides a means to
;  enable and disable the correction.  See mvn_swe_fovcal for details.
;  You can choose only one action: ON, OFF, or SET.  If you don't specify
;  an action, no change is made, and the routine only reports its current
;  state.
;
;  Calibrations are performed in the solar wind, using the strahl as a
;  calibration beam.  As the magnetic field direction changes, different
;  parts of the FOV are "illuminated".  Electron 3D distributions are 
;  corrected for spacecraft potential and transformed to the plasma rest
;  frame (using SWIA data), where the gyrotropy condition applies.
;  Correction factors are then determined for each of the 96 angular bins
;  that symmetrizes the angular distribution with respect to the magnetic
;  field direction.  To date, the solar wind calibration periods are:
;
;      1 : 2014-10-27 to 2015-03-14
;      2 : 2015-06-10 to 2015-10-15
;      3 : 2015-12-13 to 2016-04-05
;      4 : 2016-05-29 to 2016-10-06
;      5 : 2016-11-28 to 2017-03-15
;      6 : 2017-06-13 to 2017-08-22
;      7 : 2017-12-10 to 2018-04-25
;      8 : 2018-06-23 to 2018-11-13 (break at MCP bump)
;      9 : 2018-11-13 to 2019-03-25
;     10 : 2019-05-08 to 2019-08-14
;     11 : 2019-10-23 to 2019-12-23
;     12 : 2020-03-03 to 2020-05-07
;     13 : 2020-07-25 to 2020-10-14
;     14 : 2021-01-10 to 2021-03-06
;     15 : 2021-06-05 to 2021-07-18
;     16 : 2021-10-06 to 2022-01-08
;     17 : 2022-06-23 to 2022-09-30
;     18 : 2022-11-25 to 2023-02-21
;     19 : 2023-05-11 to 2023-06-29
;     20 : 2023-09-16 to 2023-12-05
;     21 : 2024-02-29 to 2024-05-17
;     22 : 2024-08-08 to 2024-09-26
;     23 : 2024-12-13 to 2025-02-26
;     24 : 2025-05-02 to ???
;
;  Solar wind periods 1 and 3 yield calibrations that are very similar.
;  These are combined into a single FOV calibration.  Solar wind period
;  2 occurred when the SWEA MCP bias was not optimized.  The lower MCP
;  gain results in a measurably different FOV sensitivity.  Periods 9
;  and later all have the same MCP bias (2875 V).
;
;  Once set, a configuration is persistent within the current IDL session 
;  until changed with this routine.
;
;USAGE:
;  ff = mvn_swe_flatfield(time)
;
;INPUTS:
;       time:         Specify the time (in any format accepted by time_double)
;                     for calculating the flatfield correction.
;
;KEYWORDS:
;       NOMINAL:      Enable the nominal correction.
;
;       SET:          Set the flatfield to this 96-element array.
;
;       OFF:          Disable the correction.
;
;       SILENT:       Don't print any warnings or messages.
;
;       INIT:         Reinitialize the flatfield common block.
;
;       TEST:         Returns calibration used.  For testing.
;
; $LastChangedBy: dmitchell $
; $LastChangedDate: 2025-05-15 11:28:54 -0700 (Thu, 15 May 2025) $
; $LastChangedRevision: 33314 $
; $URL: svn+ssh://thmsvn@ambrosia.ssl.berkeley.edu/repos/spdsoft/trunk/projects/maven/swea/mvn_swe_flatfield.pro $
;
;CREATED BY:    David L. Mitchell  2016-09-28
;FILE: mvn_swe_flatfield.pro
;-
function mvn_swe_flatfield, time, nominal=nominal, off=off, set=set, silent=silent, $
                            calnum=calnum, init=init, test=test

  @mvn_swe_com
  common swe_flatfield_com, cc_t, tt, kmax, swe_ff

; Initialize the common block, if necessary

  if ((size(cc_t,/type) eq 0) or (keyword_set(init))) then begin
    kmax = 16
    swe_ff = replicate(1.,96,kmax+1)

;   Solar wind calibration period 1  (2014-10-27 to 2015-03-14).

    swe_ff[*,1] = [1.000000 , 1.000000 , 1.000000 , 1.000000 , 0.877457 , 0.811684 , $
                   0.974663 , 1.090681 , 0.827977 , 0.967138 , 0.909398 , 0.922703 , $
                   0.945339 , 0.948781 , 1.000000 , 1.000000 , 1.000000 , 1.000000 , $
                   1.000000 , 0.783953 , 0.799805 , 1.092878 , 1.146659 , 1.180665 , $
                   1.182206 , 1.184594 , 1.181406 , 1.187459 , 1.206050 , 1.207419 , $
                   1.047321 , 1.000000 , 1.143603 , 0.924350 , 1.062616 , 1.136479 , $
                   1.116603 , 1.066938 , 1.072600 , 1.103179 , 1.117220 , 1.131237 , $
                   1.139877 , 1.115340 , 1.163150 , 1.130877 , 1.161046 , 1.125834 , $
                   1.059624 , 1.052342 , 1.071056 , 1.041820 , 1.035182 , 1.006385 , $
                   1.006550 , 1.055105 , 1.036097 , 1.043844 , 1.038166 , 1.040221 , $
                   1.077861 , 1.084966 , 1.074460 , 1.061238 , 0.975567 , 0.895757 , $
                   0.951097 , 1.016743 , 0.968444 , 0.912867 , 0.882519 , 0.989250 , $
                   0.922384 , 0.934497 , 0.932417 , 0.982760 , 0.994461 , 0.962354 , $
                   0.937530 , 0.976744 , 0.905537 , 0.893543 , 1.010918 , 0.975263 , $
                   0.880372 , 0.875369 , 0.816213 , 0.848975 , 0.805380 , 0.804108 , $
                   0.827322 , 0.816978 , 0.853364 , 0.873930 , 0.807642 , 0.816381    ]

;   Solar wind calibration period 2  (2015-06-10 to 2015-10-15)

    swe_ff[*,2] = [1.000000 , 1.000000 , 1.000000 , 1.000000 , 0.843759 , 0.847640 , $
                   1.012098 , 1.040983 , 0.920816 , 0.891987 , 1.009085 , 0.941170 , $
                   0.956725 , 0.939590 , 1.000000 , 1.000000 , 1.000000 , 1.000000 , $
                   1.000000 , 0.800859 , 0.847728 , 1.114847 , 1.129818 , 1.180432 , $
                   1.238382 , 1.208319 , 1.288248 , 1.216799 , 1.231647 , 1.224439 , $
                   1.061229 , 1.000000 , 1.063657 , 0.915567 , 1.067387 , 1.159760 , $
                   1.115952 , 1.077909 , 1.038859 , 1.075989 , 1.147254 , 1.146370 , $
                   1.206158 , 1.133052 , 1.166090 , 1.135227 , 1.120028 , 1.131254 , $
                   0.969063 , 1.061918 , 1.076491 , 1.034339 , 1.063753 , 1.023416 , $
                   0.972541 , 1.052139 , 1.066577 , 1.045153 , 1.100232 , 1.049866 , $
                   1.073862 , 1.073398 , 1.026498 , 1.054168 , 0.882796 , 0.900291 , $
                   0.926829 , 1.004274 , 0.980802 , 0.925713 , 0.866614 , 0.972181 , $
                   0.930074 , 0.936041 , 1.018903 , 1.005275 , 0.980403 , 0.943584 , $
                   0.892110 , 0.946561 , 0.839612 , 0.854615 , 0.961791 , 0.964480 , $
                   0.845180 , 0.864971 , 0.795987 , 0.797220 , 0.837243 , 0.796571 , $
                   0.882287 , 0.838460 , 0.869388 , 0.861001 , 0.769619 , 0.813524    ]

;   Solar wind calibration period 3  (2015-12-13 to 2016-04-05)

    swe_ff[*,3] = swe_ff[*,1]

;   Solar wind calibration periods 4 and 5  (2016-05-29 to 2017-03-15)
;   Results for periods 4 and 5 are very similar, so take the average and use for both.

    swe_ff[*,4] = [1.000000 , 1.000000 , 1.000000 , 1.000000 , 0.798163 , 0.808012 , $
                   0.992406 , 0.950617 , 0.876472 , 0.787930 , 0.953732 , 0.852237 , $
                   0.912070 , 0.901292 , 1.000000 , 1.000000 , 1.000000 , 1.000000 , $
                   1.000000 , 0.834263 , 0.810969 , 1.124497 , 1.127557 , 1.150475 , $
                   1.170787 , 1.149840 , 1.218544 , 1.189635 , 1.207079 , 1.192402 , $
                   1.003308 , 1.000000 , 0.970352 , 0.900612 , 1.089938 , 1.189959 , $
                   1.136835 , 1.093950 , 1.066742 , 1.082937 , 1.111103 , 1.119639 , $
                   1.155815 , 1.113576 , 1.153024 , 1.115599 , 1.124175 , 1.099895 , $
                   0.902138 , 1.055424 , 1.060409 , 1.066833 , 1.043402 , 1.043368 , $
                   1.000236 , 1.049426 , 1.036941 , 1.035782 , 1.082483 , 1.048728 , $
                   1.092556 , 1.085310 , 1.038241 , 1.034077 , 0.871543 , 0.911349 , $
                   0.944749 , 1.018215 , 1.000593 , 0.965242 , 0.903822 , 0.998244 , $
                   0.929005 , 0.936736 , 1.004803 , 1.040540 , 1.027748 , 0.989425 , $
                   0.960017 , 1.032292 , 0.865536 , 0.880691 , 0.997307 , 1.011359 , $
                   0.888254 , 0.913448 , 0.855490 , 0.848276 , 0.850046 , 0.814710 , $
                   0.921029 , 0.872874 , 0.934441 , 0.924436 , 0.836592 , 0.881278    ]

;   Solar wind calibration periods 4 and 5  (2016-05-29 to 2017-03-15)

    swe_ff[*,5] = swe_ff[*,4]

;   Solar wind calibration period 6 (2017-06-13 to 2017-08-22)

    swe_ff[*,6] = [1.000000 , 1.000000 , 1.000000 , 1.000000 , 0.920653 , 0.905603 , $
                   1.055325 , 1.125814 , 0.922363 , 1.007165 , 1.052942 , 1.062421 , $
                   1.047355 , 1.078589 , 1.000000 , 1.000000 , 1.000000 , 1.000000 , $
                   1.000000 , 0.875645 , 0.876079 , 1.151663 , 1.190861 , 1.225228 , $
                   1.205628 , 1.272357 , 1.324324 , 1.341160 , 1.363010 , 1.286093 , $
                   1.096406 , 1.000000 , 0.886535 , 0.890125 , 1.073771 , 1.110285 , $
                   1.083552 , 1.062879 , 1.081455 , 1.116896 , 1.110129 , 1.151852 , $
                   1.215135 , 1.170782 , 1.206371 , 1.155624 , 1.122229 , 1.112117 , $
                   0.811266 , 0.969495 , 0.987332 , 0.986065 , 1.019033 , 0.997037 , $
                   0.976763 , 1.008488 , 0.995645 , 1.024118 , 1.066638 , 1.029193 , $
                   1.074978 , 1.037592 , 0.956857 , 1.010420 , 0.730332 , 0.846291 , $
                   0.884903 , 0.948798 , 0.967243 , 0.918950 , 0.825930 , 0.893100 , $
                   0.858518 , 0.905677 , 0.968644 , 0.993661 , 0.984572 , 0.937099 , $
                   0.887494 , 0.953622 , 0.789998 , 0.755985 , 0.989610 , 0.938570 , $
                   0.886700 , 0.848482 , 0.803069 , 0.834783 , 0.816239 , 0.848178 , $
                   0.849890 , 0.888701 , 0.869474 , 0.890123 , 0.792140 , 0.802523    ]

;   Solar wind calibration period 7 (2017-12-10 to 2018-04-25)

    swe_ff[*,7] = [1.000000 , 1.000000 , 1.000000 , 1.000000 , 0.883934 , 0.866610 , $
                   1.076006 , 1.070016 , 0.950840 , 0.903989 , 1.054658 , 0.940007 , $
                   0.980929 , 0.957955 , 1.000000 , 1.000000 , 1.000000 , 1.000000 , $
                   1.000000 , 0.862562 , 0.858093 , 1.149360 , 1.187354 , 1.223421 , $
                   1.215382 , 1.247493 , 1.289155 , 1.242795 , 1.249771 , 1.203466 , $
                   1.026466 , 1.000000 , 0.867205 , 0.893865 , 1.084233 , 1.180903 , $
                   1.150791 , 1.095980 , 1.076597 , 1.096898 , 1.100496 , 1.142389 , $
                   1.174091 , 1.104485 , 1.138047 , 1.078532 , 1.070247 , 1.053556 , $
                   0.788928 , 0.995529 , 1.025851 , 1.034381 , 1.037377 , 1.004243 , $
                   0.996489 , 1.034756 , 0.995001 , 1.028859 , 1.066164 , 1.010911 , $
                   1.066895 , 1.048115 , 0.992087 , 0.986865 , 0.728686 , 0.869276 , $
                   0.931256 , 1.000276 , 0.981294 , 0.922596 , 0.893118 , 0.977773 , $
                   0.902593 , 0.930151 , 0.989843 , 1.006665 , 1.008243 , 0.967980 , $
                   0.893788 , 0.940672 , 0.805022 , 0.806295 , 1.018766 , 1.005918 , $
                   0.887518 , 0.894144 , 0.846486 , 0.852343 , 0.849357 , 0.842190 , $
                   0.915408 , 0.889495 , 0.913418 , 0.913407 , 0.808462 , 0.839137    ]

;   Solar wind calibration period 8 (2018-06-25 to 2018-11-13)

    swe_ff[*,8] = [1.000000 , 1.000000 , 1.000000 , 1.000000 , 0.850090 , 0.820116 , $
                   0.972734 , 1.044244 , 0.855566 , 0.925280 , 1.026892 , 1.021561 , $
                   1.008799 , 0.991689 , 1.000000 , 1.000000 , 1.000000 , 1.000000 , $
                   1.000000 , 0.846584 , 0.823201 , 1.129745 , 1.145896 , 1.169003 , $
                   1.153876 , 1.270898 , 1.357536 , 1.336150 , 1.361999 , 1.297590 , $
                   1.057107 , 1.000000 , 0.793402 , 0.884892 , 1.093278 , 1.200655 , $
                   1.191259 , 1.104203 , 1.051277 , 1.074739 , 1.057306 , 1.158002 , $
                   1.265665 , 1.183022 , 1.237446 , 1.159314 , 1.134682 , 1.096605 , $
                   0.721022 , 0.983286 , 1.040845 , 1.047219 , 1.069509 , 1.009117 , $
                   0.950093 , 1.003687 , 0.954594 , 1.035456 , 1.112754 , 1.077886 , $
                   1.089106 , 1.064884 , 1.007781 , 0.998064 , 0.643500 , 0.818447 , $
                   0.881961 , 0.984983 , 0.984382 , 0.907811 , 0.843280 , 0.956221 , $
                   0.869749 , 0.920328 , 1.027763 , 1.043339 , 1.049765 , 0.971460 , $
                   0.907124 , 0.935712 , 0.735161 , 0.719550 , 0.990624 , 0.966725 , $
                   0.889893 , 0.886348 , 0.799016 , 0.836979 , 0.801924 , 0.825729 , $
                   0.933840 , 0.928346 , 0.937634 , 0.926391 , 0.806271 , 0.804032    ]

;   Solar wind calibration period 9 (2018-11-13 to 2019-03-25)

    swe_ff[*,9] = [1.000000 , 1.000000 , 1.000000 , 1.000000 , 0.889212 , 0.882780 , $
                   1.074255 , 1.066362 , 0.966614 , 0.905223 , 1.025112 , 0.967523 , $
                   1.004944 , 1.038017 , 1.000000 , 1.000000 , 1.000000 , 1.000000 , $
                   1.000000 , 0.889494 , 0.854438 , 1.153962 , 1.223405 , 1.192871 , $
                   1.196544 , 1.210261 , 1.227626 , 1.243615 , 1.268985 , 1.267719 , $
                   1.117061 , 1.000000 , 1.013798 , 0.950412 , 1.085561 , 1.167746 , $
                   1.126260 , 1.085526 , 1.111002 , 1.077673 , 1.060870 , 1.090947 , $
                   1.126782 , 1.079210 , 1.137134 , 1.119479 , 1.172324 , 1.148227 , $
                   0.903631 , 1.030658 , 1.036729 , 1.040860 , 1.013371 , 0.998277 , $
                   0.983311 , 1.013190 , 0.960369 , 0.964837 , 1.004293 , 0.996153 , $
                   1.009697 , 1.019428 , 1.031835 , 1.045179 , 0.819421 , 0.892857 , $
                   0.936698 , 1.016705 , 0.964237 , 0.907574 , 0.858807 , 0.941562 , $
                   0.855905 , 0.884849 , 0.911865 , 0.954546 , 0.962757 , 0.930338 , $
                   0.925609 , 0.986219 , 0.885904 , 0.866444 , 1.048843 , 1.028637 , $
                   0.889272 , 0.899972 , 0.834049 , 0.846926 , 0.829116 , 0.816002 , $
                   0.869161 , 0.848463 , 0.879173 , 0.897340 , 0.847910 , 0.883038    ]

;   Solar wind calibration period 10 (2019-05-08 to 2019-08-14)

    swe_ff[*,10] = [1.000000 , 1.000000 , 1.000000 , 1.000000 , 0.879317 , 0.911964 , $
                    1.119803 , 1.089289 , 0.974893 , 0.907796 , 1.087458 , 0.983816 , $
                    1.045203 , 0.990710 , 1.000000 , 1.000000 , 1.000000 , 1.000000 , $
                    1.000000 , 0.925228 , 0.856489 , 1.183096 , 1.254560 , 1.251888 , $
                    1.234085 , 1.257150 , 1.322369 , 1.331628 , 1.344390 , 1.273163 , $
                    1.031949 , 1.000000 , 0.873847 , 0.928697 , 1.105439 , 1.221594 , $
                    1.152546 , 1.114096 , 1.117735 , 1.126462 , 1.129613 , 1.166267 , $
                    1.238657 , 1.196397 , 1.260691 , 1.162982 , 1.148050 , 1.100743 , $
                    0.808588 , 1.033537 , 1.069124 , 1.077329 , 1.052633 , 1.004840 , $
                    1.000538 , 1.049602 , 1.007458 , 1.054204 , 1.120719 , 1.107281 , $
                    1.163547 , 1.143893 , 1.074953 , 1.051125 , 0.772270 , 0.937954 , $
                    0.932228 , 1.055673 , 1.003829 , 0.943967 , 0.920940 , 1.018618 , $
                    0.931103 , 0.980243 , 1.027508 , 1.079944 , 1.088126 , 1.043308 , $
                    0.989818 , 1.037328 , 0.877905 , 0.884132 , 1.053104 , 1.095095 , $
                    0.923548 , 0.972435 , 0.917691 , 0.929452 , 0.915833 , 0.894578 , $
                    1.001139 , 0.952609 , 1.041941 , 0.994645 , 0.940149 , 0.930939    ]

;   Solar wind calibration period 11 (2019-10-23 to 2019-12-23)
;     November shows no measurable difference between SW10 and SW11

    swe_ff[*,11] = swe_ff[*,10]
    
;   Solar wind calibration period 13 (2020-08-14 to 2020-09-11)

    swe_ff[*,12] = [1.000000 , 1.000000 , 1.000000 , 1.000000 , 1.024911 , 1.032964 , $
                    1.264660 , 1.368876 , 1.072616 , 1.116870 , 1.192010 , 1.190440 , $
                    1.127156 , 1.127782 , 1.000000 , 1.000000 , 1.000000 , 1.000000 , $
                    1.000000 , 0.977172 , 0.930743 , 1.357261 , 1.463590 , 1.482224 , $
                    1.396518 , 1.395535 , 1.426129 , 1.385134 , 1.385207 , 1.310357 , $
                    1.070194 , 1.000000 , 0.741867 , 0.944793 , 1.170627 , 1.310740 , $
                    1.258065 , 1.294402 , 1.318295 , 1.326533 , 1.248815 , 1.256087 , $
                    1.247237 , 1.213663 , 1.244269 , 1.131063 , 1.150391 , 1.119341 , $
                    0.673268 , 1.035465 , 1.123729 , 1.139578 , 1.116220 , 1.154876 , $
                    1.152133 , 1.210154 , 1.087648 , 1.117564 , 1.141061 , 1.081699 , $
                    1.124102 , 1.063686 , 1.035025 , 1.016730 , 0.597681 , 0.884295 , $
                    0.957789 , 1.020959 , 0.976471 , 0.947713 , 0.919464 , 1.020711 , $
                    0.932505 , 0.992881 , 1.055043 , 1.037052 , 1.039794 , 0.975648 , $
                    0.923803 , 0.973841 , 0.791736 , 0.735910 , 1.064427 , 1.004119 , $
                    0.887019 , 0.921851 , 0.832345 , 0.907756 , 0.841722 , 0.873526 , $
                    0.968586 , 0.962502 , 0.938008 , 0.939996 , 0.846337 , 0.838772 ]
                    
;   Solar wind calibration period 16 (2021-11-02 to 2021-12-28)

    swe_ff[*, 13] = [1.000000 , 1.000000 , 1.000000 , 1.000000 , 0.918167 , 0.922948 , $
                     1.094426 , 1.093735 , 1.001968 , 0.932016 , 1.198234 , 1.109733 , $
                     1.073716 , 1.073833 , 1.000000 , 1.000000 , 1.000000 , 1.000000 , $
                     1.000000 , 0.973809 , 0.911649 , 1.261984 , 1.296183 , 1.283596 , $
                     1.210317 , 1.397233 , 1.534952 , 1.468990 , 1.422778 , 1.334651 , $
                     1.113037 , 1.000000 , 0.655427 , 0.935971 , 1.222948 , 1.356364 , $
                     1.291376 , 1.237213 , 1.192551 , 1.161683 , 1.126442 , 1.282438 , $
                     1.414906 , 1.305108 , 1.302260 , 1.249079 , 1.205451 , 1.097619 , $
                     0.606422 , 1.058229 , 1.169417 , 1.190154 , 1.135937 , 1.098222 , $
                     1.089238 , 1.107640 , 1.022379 , 1.136780 , 1.265942 , 1.182701 , $
                     1.174639 , 1.131380 , 1.058468 , 1.038988 , 0.551355 , 0.880138 , $
                     1.011440 , 1.099705 , 1.010875 , 0.966523 , 0.957615 , 1.078787 , $
                     0.942897 , 1.034556 , 1.131470 , 1.135345 , 1.121493 , 1.024211 , $
                     0.958367 , 0.941802 , 0.752285 , 0.725049 , 1.114147 , 1.076188 , $
                     0.943486 , 0.964687 , 0.894626 , 0.933002 , 0.899525 , 0.921083 , $
                     1.041015 , 1.026530 , 0.998244 , 0.993570 , 0.834428 , 0.845106 ]

;   Solar wind calibration period 19 (2022-12-16 to 2023-02-09)

    swe_ff[*, 14] = [1.000000 , 1.000000 , 1.000000 , 1.000000 , 0.955766 , 0.980145 , $
                     1.163400 , 1.187223 , 0.994762 , 0.945703 , 1.244975 , 1.103980 , $
                     1.093341 , 1.025958 , 1.000000 , 1.000000 , 1.000000 , 1.000000 , $
                     1.000000 , 0.995955 , 0.922921 , 1.399167 , 1.384934 , 1.382391 , $
                     1.258651 , 1.469705 , 1.634867 , 1.562773 , 1.554302 , 1.422467 , $
                     1.113786 , 1.000000 , 0.647571 , 0.908612 , 1.265760 , 1.393596 , $
                     1.315333 , 1.313103 , 1.256286 , 1.228607 , 1.180845 , 1.391293 , $
                     1.576431 , 1.479460 , 1.525691 , 1.433444 , 1.305508 , 1.105916 , $
                     0.561934 , 1.010234 , 1.149402 , 1.173961 , 1.135049 , 1.149493 , $
                     1.085150 , 1.115663 , 1.032040 , 1.202768 , 1.360380 , 1.289203 , $
                     1.376684 , 1.317786 , 1.148082 , 0.995130 , 0.510114 , 0.834450 , $
                     0.963927 , 1.098168 , 1.035643 , 0.992336 , 0.948250 , 1.028509 , $
                     0.890591 , 1.060014 , 1.160120 , 1.155967 , 1.196540 , 1.106238 , $
                     0.963660 , 0.905806 , 0.665736 , 0.666842 , 1.103282 , 1.069834 , $
                     0.977189 , 0.972475 , 0.904273 , 0.891102 , 0.896324 , 0.871563 , $
                     1.049923 , 1.021530 , 1.010078 , 1.037852 , 0.777153 , 0.840176 ]

;   Solar wind calibration period 21 (2023-09-30 to 2023-10-30)

    swe_ff[*, 15] = [1.000000 , 1.000000 , 1.000000 , 1.000000 , 0.896273 , 0.886541 , $
                     1.081345 , 1.064313 , 0.895131 , 0.850151 , 1.040655 , 0.973815 , $
                     1.077251 , 1.034949 , 1.000000 , 1.000000 , 1.000000 , 1.000000 , $
                     1.000000 , 1.020625 , 0.938726 , 1.325265 , 1.346617 , 1.323238 , $
                     1.225638 , 1.348874 , 1.440571 , 1.473647 , 1.557898 , 1.493899 , $
                     1.189180 , 1.000000 , 0.780972 , 1.033496 , 1.265799 , 1.416662 , $
                     1.394891 , 1.331487 , 1.283056 , 1.266376 , 1.206718 , 1.331746 , $
                     1.428071 , 1.413332 , 1.506012 , 1.454307 , 1.385432 , 1.240536 , $
                     0.705763 , 1.120554 , 1.184745 , 1.198814 , 1.170128 , 1.199803 , $
                     1.187047 , 1.182468 , 1.092150 , 1.214096 , 1.290974 , 1.290581 , $
                     1.361703 , 1.321161 , 1.226761 , 1.159629 , 0.620061 , 0.915397 , $
                     0.969908 , 1.099432 , 1.058324 , 1.021515 , 1.008483 , 1.093832 , $
                     0.968724 , 1.020124 , 1.117098 , 1.171770 , 1.174616 , 1.088552 , $
                     1.029517 , 1.037867 , 0.725988 , 0.734716 , 1.067887 , 1.066734 , $
                     0.907256 , 0.924691 , 0.882955 , 0.889861 , 0.840278 , 0.816307 , $
                     0.946400 , 0.922229 , 0.965200 , 0.956521 , 0.828224 , 0.851105 ]

;   Solar wind calibration periods 22-24 (2024-02-29 to 2025-02-28), averaged together

    swe_ff[*, 16] = [1.000000 , 1.000000 , 1.000000 , 1.000000 , 0.965904 , 0.950738 , $
                     1.076071 , 1.175934 , 0.895147 , 0.987717 , 1.115211 , 1.140802 , $
                     1.144608 , 1.143917 , 1.000000 , 1.000000 , 1.000000 , 1.000000 , $
                     1.000000 , 1.004717 , 0.952379 , 1.285871 , 1.284509 , 1.263156 , $
                     1.139525 , 1.342309 , 1.452531 , 1.503671 , 1.534654 , 1.472809 , $
                     1.213920 , 1.000000 , 0.603569 , 0.902148 , 1.182969 , 1.340292 , $
                     1.305642 , 1.229493 , 1.175503 , 1.161240 , 1.032172 , 1.203404 , $
                     1.336031 , 1.339429 , 1.372190 , 1.288802 , 1.253651 , 1.120688 , $
                     0.538435 , 1.022809 , 1.147127 , 1.161464 , 1.130208 , 1.112621 , $
                     1.092723 , 1.094090 , 0.943299 , 1.099376 , 1.203999 , 1.185398 , $
                     1.213705 , 1.170964 , 1.104865 , 1.008440 , 0.500546 , 0.883752 , $
                     1.013755 , 1.107989 , 1.043951 , 1.000453 , 0.971733 , 1.058915 , $
                     0.868332 , 1.019958 , 1.103459 , 1.162836 , 1.134350 , 1.058643 , $
                     0.990306 , 0.945787 , 0.768794 , 0.711637 , 1.192852 , 1.117951 , $
                     1.002949 , 1.012578 , 0.929354 , 0.983107 , 0.880603 , 0.918427 , $
                     1.031121 , 1.022609 , 1.007088 , 1.020813 , 0.857638 , 0.883399 ]

;   Centers of solar wind calibration periods 1-24

    tt = time_double(['2014-12-22', $    ; Solar Wind 1    (0)
                      '2015-08-02', $    ; Solar Wind 2    (1)
                      '2016-01-28', $    ; Solar Wind 3    (2)
                      '2016-08-22', $    ; Solar Wind 4    (3)
                      '2017-01-13', $    ; Solar Wind 5    (4)
                      '2017-06-29', $    ; Solar Wind 6    (5)
                      '2018-02-17', $    ; Solar Wind 7    (6)
                      '2018-08-13', $    ; Solar Wind 8    (7)
                      '2019-01-22', $    ; Solar Wind 9    (8)
                      '2019-06-23', $    ; Solar Wind 10   (9)
                      '2019-11-22', $    ; Solar Wind 11  (10)
                      '2020-09-01', $    ; Solar Wind 13  (11)
                      '2021-11-30', $    ; Solar Wind 16  (12)
                      '2023-01-01', $    ; Solar Wind 19  (13)
                      '2023-10-15', $    ; Solar Wind 21  (14)
                      '2024-04-08', $    ; Solar Wind 22  (15)
                      '2024-09-02', $    ; Solar Wind 23  (16)
                      '2025-01-21'  $    ; Solar Wind 24  (17)
                      ])  

    cc_t = mvn_swe_crosscal(tt,/silent)

  endif

; Process keywords to determine configuration

  blab = ~keyword_set(silent)
  test = 0.

; Only one configuration at a time.  Precedence: off, set, nominal.

  if keyword_set(nominal) then swe_ff_state = 1
  if (n_elements(set) eq 96) then begin
    swe_ff_state = 2
    swe_ff[*,0] = float(reform(set,96))/mean(set,/nan)
  endif
  if keyword_set(off) then swe_ff_state = 0

; Handle the easy cases first

  if (swe_ff_state eq 2) then swe_ogf = swe_ff[*,0] else swe_ogf = replicate(1.,96)

; Set the correction factors based on in-flight calibrations

  if ((swe_ff_state eq 1) and (size(time,/type) ne 0)) then begin

;   Interpolate between angular calibrations based on SWEA MCP gain, as inferred
;   from SWE-SWI cross calibration factor.

    t = time_double(time)
    cc = (mvn_swe_crosscal(t,/silent))[0]

;   Cruise to the beginning of Solar Wind 3.
;   (Note that calibrations for SW1 and SW3 are identical.)

    if (t lt t_mcp[5]) then begin
      frac = (((cc - cc_t[0])/(cc_t[1] - cc_t[0])) > 0.) < 1.
      swe_ogf = swe_ff[*,1]*(1. - frac) + swe_ff[*,2]*frac
      test = frac + 1.
    endif

;   Beginning of Solar Wind 3 to the end of Solar Wind 4.

    if ((t ge t_mcp[5]) and (t lt t_mcp[6])) then begin
      frac = (((cc - cc_t[2])/(cc_t[3] - cc_t[2])) > 0.) < 1.
      swe_ogf = swe_ff[*,3]*(1. - frac) + swe_ff[*,4]*frac
      test = frac + 3.
    endif

;   Beginning of Solar Wind 5 through Solar Wind 6.

    if ((t ge t_mcp[6]) and (t lt t_mcp[7])) then begin
      frac = (((cc - cc_t[4])/(cc_t[5] - cc_t[4])) > 0.) < 1.
      swe_ogf = swe_ff[*,5]*(1. - frac) + swe_ff[*,6]*frac
      test = frac + 5.
    endif

;   End of Solar Wind 6 through Solar Wind 8.

    if ((t ge t_mcp[7]) and (t lt t_mcp[8])) then begin
      frac = (((cc - cc_t[6])/(cc_t[7] - cc_t[6])) > 0.) < 1.
      swe_ogf = swe_ff[*,7]*(1. - frac) + swe_ff[*,8]*frac
      test = frac + 7.
    endif

;   Solar Wind 9 through first month of Solar Wind 21.

    if ((t ge t_mcp[8]) and (t lt t_mcp[9])) then begin
      frac = (((cc - cc_t[8])/(cc_t[13] - cc_t[8])) > 0.) < 1.
      swe_ogf = swe_ff[*,9]*(1. - frac) + swe_ff[*,14]*frac
      test = frac + 13.
    endif

;   The rest of Solar Wind 21 through Solar Wind 24 and beyond.
;   For this period, we interpolate in time instead of cross calibration factor,
;   because the cross calibration factor is nearly constant while the angular
;   calibration changes.

    if (t ge t_mcp[9]) then begin
      frac = (((t - tt[14])/(tt[16] - tt[14])) > 0.) < 1.
      swe_ogf = swe_ff[*,15]*(1. - frac) + swe_ff[*,16]*frac
      test = frac + 16.
    endif

;   Override this with a specific calibration, if requested --> for testing

    if keyword_set(calnum) then swe_ogf = swe_ff[*,(calnum > 0) < kmax]

;   Enforce normalization to unity

    swe_ogf /= mean(swe_ogf)

  endif

; Report the flatfield configuration

  if (blab) then begin
    case swe_ff_state of
      0 : print,"Flatfield correction disabled"
      1 : print,"Flatfield correction enabled"
      2 : print,"User-defined flatfield correction"
    endcase
  endif

  return, swe_ogf

end
