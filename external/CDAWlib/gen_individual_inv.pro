;
;Copyright 1996-2013 United States Government as represented by the 
;Administrator of the National Aeronautics and Space Administration. 
;All Rights Reserved.
;
;------------------------------------------------------------------
@compile_inventory.pro

;debug = 1

; Read the metadata file...
;datasets = ['AC_K0_EPM','AC_K1_EPM','AC_H1_EPM','AC_H2_EPM','AC_K0_MFI','AC_K1_MFI','AC_K2_MFI','AC_H0_MFI','AC_H1_MFI','AC_H2_MFI','AC_K0_SIS','AC_H2_SIS','AC_K0_SWE','AC_K1_SWE','AC_H0_SWE','AC_H2_SWE','AC_H2_ULE','AC_OR_SSC','AC_H2_SWI']
datasets = get_datasets('AC_', '/home/cdaweb/metadata/sp_phys_cdfmetafile.txt')
if (datasets[0] ne '') then print,'Generating ACE'
if (datasets[0] ne '') then a = ingest_database('/home/cdaweb/metadata/sp_phys_cdfmetafile.txt',DATASETS=datasets)
; Draw inventory graph...
if (datasets[0] ne '') then s=draw_inventory(a,TITLE='ACE CDAWeb Inventory',PNG='/var/www/cdaweb/htdocs/sc_inventory_plots/ACE_Inventory.png',/debug)
if (datasets[0] ne '') then delvar, a

; Read the metadata file...
datasets = get_datasets('AEROCUBE', '/home/cdaweb/metadata/sp_phys_cdfmetafile.txt')
if (datasets[0] ne '') then print,'Generating AEROCUBE'
if (datasets[0] ne '') then a = ingest_database('/home/cdaweb/metadata/sp_phys_cdfmetafile.txt',DATASETS=datasets)
; Draw inventory graph...
if (datasets[0] ne '') then s=draw_inventory(a,TITLE='AEROCUBE CDAWeb Inventory',PNG='/var/www/cdaweb/htdocs/sc_inventory_plots/AEROCUBE_Inventory.png',/debug)
if (datasets[0] ne '') then delvar, a

; Read the metadata file...
ds_list = ['AIM','SOFIE']
datasets = get_datasets(ds_list, '/home/cdaweb/metadata/sp_phys_cdfmetafile.txt')
if (datasets[0] ne '') then print,'Generating AIM'
if (datasets[0] ne '') then a = ingest_database('/home/cdaweb/metadata/sp_phys_cdfmetafile.txt',DATASETS=datasets)
; Draw inventory graph...
if (datasets[0] ne '') then s=draw_inventory(a,TITLE='AIM CDAWeb Inventory',PNG='/var/www/cdaweb/htdocs/sc_inventory_plots/AIM_Inventory.png',/debug)
if (datasets[0] ne '') then delvar, a

; Read the metadata file...
datasets = get_datasets('AMPTE', '/home/cdaweb/metadata/sp_phys_cdfmetafile.txt')
if (datasets[0] ne '') then print,'Generating AMPTE'
if (datasets[0] ne '') then a = ingest_database('/home/cdaweb/metadata/sp_phys_cdfmetafile.txt',DATASETS=datasets)
; Draw inventory graph...
if (datasets[0] ne '') then s=draw_inventory(a,TITLE='AMPTE CDAWeb Inventory',PNG='/var/www/cdaweb/htdocs/sc_inventory_plots/AMTPE_Inventory.png',/debug)
if (datasets[0] ne '') then delvar, a

; Read the metadata file...
datasets = get_datasets('ALOUETTE', '/home/cdaweb/metadata/sp_phys_cdfmetafile.txt')
if (datasets[0] ne '') then print,'Generating ALOUETTE'
if (datasets[0] ne '') then a = ingest_database('/home/cdaweb/metadata/sp_phys_cdfmetafile.txt',DATASETS=datasets)
; Draw inventory graph...
if (datasets[0] ne '') then s=draw_inventory(a,TITLE='Alouette2 CDAWeb Inventory',PNG='/var/www/cdaweb/htdocs/sc_inventory_plots/Alouette2_Inventory.png',/debug)
if (datasets[0] ne '') then delvar, a

; Read the metadata file...
datasets = get_datasets('APOLLO', '/home/cdaweb/metadata/sp_phys_cdfmetafile.txt')
if (datasets[0] ne '') then print,'Generating Apollo'
if (datasets[0] ne '') then a = ingest_database('/home/cdaweb/metadata/sp_phys_cdfmetafile.txt',DATASETS=datasets)
; Draw inventory graph...
if (datasets[0] ne '') then s=draw_inventory(a,TITLE='Apollo CDAWeb Inventory',PNG='/var/www/cdaweb/htdocs/sc_inventory_plots/Apollo_Inventory.png',/debug)
if (datasets[0] ne '') then delvar, a

; Read the metadata file...
datasets = get_datasets('BAR_', '/home/cdaweb/metadata/sp_phys_cdfmetafile.txt')
if (datasets[0] ne '') then print,'Generating BARREL'
if (datasets[0] ne '') then a = ingest_database('/home/cdaweb/metadata/sp_phys_cdfmetafile.txt',DATASETS=datasets)
; Draw inventory graph...
if (datasets[0] ne '') then s=draw_inventory(a,TITLE='BARREL CDAWeb Inventory',PNG='/var/www/cdaweb/htdocs/sc_inventory_plots/BARREL_Inventory.png',/debug)
if (datasets[0] ne '') then delvar, a

; Read the metadata file...
datasets = ['CN_K0_ASI','CN_K0_BARS','CN_K0_MARI','CN_K0_MPA','CN_K1_MARI']
if (datasets[0] ne '') then print,'Generating Canopus'
if (datasets[0] ne '') then a = ingest_database('/home/cdaweb/metadata/sp_phys_cdfmetafile.txt',DATASETS=datasets)
; Draw inventory graph...
if (datasets[0] ne '') then s=draw_inventory(a,TITLE='CANOPUS CDAWeb Inventory',PNG='/var/www/cdaweb/htdocs/sc_inventory_plots/CANOPUS_Inventory.png',/debug)
if (datasets[0] ne '') then delvar, a

; Read the metadata file...
;datasets = ['CL_SP_ASP','CL_SP_CIS','CL_SP_DWP','CL_SP_EDI','CL_SP_EFW','CL_SP_FGM','CL_SP_PEA','CL_SP_RAP','CL_SP_STA','CL_SP_WHI','CL_SP_AUX','CL_SP_WBD','CL_JP_PGP','CL_JP_PCY','C1_JP_PMP','C2_JP_PMP','C3_JP_PMP','C4_JP_PMP','C1_JP_PSE','C2_JP_PSE','C3_JP_PSE','C4_JP_PSE','CT_JP_PSE','CL_JP_PCY']
ds_list = ['CL_','C1_','C2_','C3_','C4_']
datasets = get_datasets(ds_list, '/home/cdaweb/metadata/sp_phys_cdfmetafile.txt')
if (datasets[0] ne '') then print,'Generating Cluster'
if (datasets[0] ne '') then a = ingest_database('/home/cdaweb/metadata/sp_phys_cdfmetafile.txt',DATASETS=datasets)
; Draw inventory graph...
if (datasets[0] ne '') then s=draw_inventory(a,TITLE='Cluster Public CDAWeb Inventory',PNG='/var/www/cdaweb/htdocs/sc_inventory_plots/Cluster_Public_Inventory.png',/debug)
if (datasets[0] ne '') then delvar, a

; Read the metadata file...
datasets = get_datasets('CNOFS', '/home/cdaweb/metadata/sp_phys_cdfmetafile.txt')
if (datasets[0] ne '') then print,'Generating CNOFS'
if (datasets[0] ne '') then a = ingest_database('/home/cdaweb/metadata/sp_phys_cdfmetafile.txt',DATASETS=datasets)
; Draw inventory graph...
if (datasets[0] ne '') then s=draw_inventory(a,TITLE='C/NOFS CDAWeb Inventory',PNG='/var/www/cdaweb/htdocs/sc_inventory_plots/CNOFS_Inventory.png',/debug)
if (datasets[0] ne '') then delvar, a

; Read the metadata file...
datasets = get_datasets('CSSWE', '/home/cdaweb/metadata/sp_phys_cdfmetafile.txt')
if (datasets[0] ne '') then print,'Generating CSSWE'
if (datasets[0] ne '') then a = ingest_database('/home/cdaweb/metadata/sp_phys_cdfmetafile.txt',DATASETS=datasets)
; Draw inventory graph...
if (datasets[0] ne '') then s=draw_inventory(a,TITLE='CSSWE CDAWeb Inventory',PNG='/var/www/cdaweb/htdocs/sc_inventory_plots/CSSWE_Inventory.png',/debug)
if (datasets[0] ne '') then delvar, a

; Read the metadata file...
datasets = ['DN_K0_GBAY','DN_K0_HANK','DN_K0_ICEW','DN_K0_KAPU','DN_K0_PACE','DN_K0_PYKK','DN_K0_SASK']
if (datasets[0] ne '') then print,'Generating Darn'
if (datasets[0] ne '') then a = ingest_database('/home/cdaweb/metadata/sp_phys_cdfmetafile.txt',DATASETS=datasets)
; Draw inventory graph...
if (datasets[0] ne '') then s=draw_inventory(a,TITLE='DARN CDAWeb Inventory',PNG='/var/www/cdaweb/htdocs/sc_inventory_plots/DARN_Inventory.png',/debug)
if (datasets[0] ne '') then delvar, a

; Read the metadata file...
datasets = get_datasets('DMSP-', '/home/cdaweb/metadata/sp_phys_cdfmetafile.txt')
if (datasets[0] ne '') then print,'Generating DMSP'
if (datasets[0] ne '') then a = ingest_database('/home/cdaweb/metadata/sp_phys_cdfmetafile.txt',DATASETS=datasets)
; Draw inventory graph...
if (datasets[0] ne '') then s=draw_inventory(a,TITLE='DMSP CDAWeb Inventory',PNG='/var/www/cdaweb/htdocs/sc_inventory_plots/DMSP_Inventory.png',/debug)
if (datasets[0] ne '') then delvar, a

; Read the metadata file...
datasets = get_datasets('DSCOVR', '/home/cdaweb/metadata/sp_phys_cdfmetafile.txt')
if (datasets[0] ne '') then print,'Generating DSCOVR'
if (datasets[0] ne '') then a = ingest_database('/home/cdaweb/metadata/sp_phys_cdfmetafile.txt',DATASETS=datasets)
; Draw inventory graph...
if (datasets[0] ne '') then s=draw_inventory(a,TITLE='DSCOVR CDAWeb Inventory',PNG='/var/www/cdaweb/htdocs/sc_inventory_plots/DSCOVR_Inventory.png',/debug)
if (datasets[0] ne '') then delvar, a

; Read the metadata file...
if (datasets[0] ne '') then print,'Generating Elfin'
ds_list = ['ELA_','ELB_']
datasets = get_datasets(ds_list, '/home/cdaweb/metadata/sp_phys_cdfmetafile.txt')
if (datasets[0] ne '') then a = ingest_database('/home/cdaweb/metadata/sp_phys_cdfmetafile.txt',DATASETS=datasets)
; Draw inventory graph...
if (datasets[0] ne '') then s=draw_inventory(a,TITLE='Elfin CDAWeb Inventory',PNG='/var/www/cdaweb/htdocs/sc_inventory_plots/Elfin_Inventory.png',/debug)
if (datasets[0] ne '') then delvar, a

; Read the metadata file...
datasets = ['EQ_SP_AUX','EQ_SP_EPI','EQ_SP_ICI','EQ_SP_MAM','EQ_SP_PCD','EQ_SP_SFD','EQ_PP_EDI','EQ_PP_ICI','EQ_PP_AUX','EQ_PP_EPI','EQ_PP_MAM','EQ_PP_PCD']
if (datasets[0] ne '') then print,'Generating Equator-s'
if (datasets[0] ne '') then a = ingest_database('/home/cdaweb/metadata/sp_phys_cdfmetafile.txt',DATASETS=datasets)
; Draw inventory graph...
if (datasets[0] ne '') then s=draw_inventory(a,TITLE='Equator-s CDAWeb Inventory',PNG='/var/www/cdaweb/htdocs/sc_inventory_plots/Equator-S_Inventory.png',/debug)
if (datasets[0] ne '') then delvar, a

; Read the metadata file...
ds_list = ['ERG']
datasets = get_datasets(ds_list, '/home/cdaweb/metadata/sp_phys_cdfmetafile.txt')
if (datasets[0] ne '') then print,'Generating Arase (ERG) public'
if (datasets[0] ne '') then a = ingest_database('/home/cdaweb/metadata/sp_phys_cdfmetafile.txt',DATASETS=datasets)
; Draw inventory graph...
if (datasets[0] ne '') then s=draw_inventory(a,TITLE='Arase (ERG) Public CDAWeb Inventory',PNG='/var/www/cdaweb/htdocs/sc_inventory_plots/Arase-ERG_Public_Inventory.png',/debug)
if (datasets[0] ne '') then delvar, a

; Read the metadata file...
ds_list = ['FA_','FAST_']
datasets = get_datasets(ds_list, '/home/cdaweb/metadata/sp_phys_cdfmetafile.txt')
if (datasets[0] ne '') then print,'Generating Fast'
if (datasets[0] ne '') then a = ingest_database('/home/cdaweb/metadata/sp_phys_cdfmetafile.txt',DATASETS=datasets)
; Draw inventory graph...
if (datasets[0] ne '') then s=draw_inventory(a,TITLE='FAST CDAWeb Inventory',PNG='/var/www/cdaweb/htdocs/sc_inventory_plots/FAST_Inventory.png',/debug)
if (datasets[0] ne '') then delvar, a

; Read the metadata file...
ds_list = ['HK_', 'HAWKEYE']
datasets = get_datasets(ds_list, '/home/cdaweb/metadata/sp_phys_cdfmetafile.txt')
if (datasets[0] ne '') then print,'Generating Hawkeye'
if (datasets[0] ne '') then a = ingest_database('/home/cdaweb/metadata/sp_phys_cdfmetafile.txt',DATASETS=datasets)
; Draw inventory graph...
if (datasets[0] ne '') then s=draw_inventory(a,TITLE='Hawkeye CDAWeb Inventory',PNG='/var/www/cdaweb/htdocs/sc_inventory_plots/Hawkeye_Inventory.png',/debug)
if (datasets[0] ne '') then delvar, a

; Read the metadata file...
ds_list = ['GE_']
datasets = get_datasets(ds_list, '/home/cdaweb/metadata/sp_phys_cdfmetafile.txt')
if (datasets[0] ne '') then print,'Generating Geotail'
if (datasets[0] ne '') then a = ingest_database('/home/cdaweb/metadata/sp_phys_cdfmetafile.txt',DATASETS=datasets)
; Draw inventory graph...
if (datasets[0] ne '') then s=draw_inventory(a,TITLE='Geotail CDAWeb Inventory',PNG='/var/www/cdaweb/htdocs/sc_inventory_plots/Geotail_Inventory.png',/debug)
if (datasets[0] ne '') then delvar, a

; Read the metadata file...
;datasets =
;['G6_K0_EPS','G6_K0_MAG','G7_K0_EPS','G7_K0_MAG','G7_K1_MAG','G8_K0_EP8','G8_K0_MAG','G9_K0_EP8','G9_K0_MAG','G0_K0_EP8','G0_K0_MAG','GOES12_K0_MAG','GOES12_K0_EPS']
;TJK 2/12/2021 add all of the new GOES data sets that have the DN_MAGN* name
ds_list = ['G6_','G7_','G8_','G9_','G0_','GOES12','DN_MAGN-L2-HIRES']
datasets = get_datasets(ds_list, '/home/cdaweb/metadata/sp_phys_cdfmetafile.txt')
if (datasets[0] ne '') then print,'Generating Goes'
if (datasets[0] ne '') then a = ingest_database('/home/cdaweb/metadata/sp_phys_cdfmetafile.txt',DATASETS=datasets)
; Draw inventory graph...
if (datasets[0] ne '') then s=draw_inventory(a,TITLE='GOES CDAWeb Inventory',PNG='/var/www/cdaweb/htdocs/sc_inventory_plots/GOES_Inventory.png',/debug)
if (datasets[0] ne '') then delvar, a

; Read the metadata file...
ds_list = ['GOLD']
datasets = get_datasets(ds_list, '/home/cdaweb/metadata/sp_phys_cdfmetafile.txt')
if (datasets[0] ne '') then print,'Generating Gold public'
if (datasets[0] ne '') then a = ingest_database('/home/cdaweb/metadata/sp_phys_cdfmetafile.txt',DATASETS=datasets)
; Draw inventory graph...
if (datasets[0] ne '') then s=draw_inventory(a,TITLE='GOLD Public CDAWeb Inventory',PNG='/var/www/cdaweb/htdocs/sc_inventory_plots/GOLD_Inventory.png',/debug)
if (datasets[0] ne '') then delvar, a

; Read the metadata file...
ds_list = ['GPS']
datasets = get_datasets(ds_list, '/home/cdaweb/metadata/sp_phys_cdfmetafile.txt')
if (datasets[0] ne '') then print,'Generating GPS public'
if (datasets[0] ne '') then a = ingest_database('/home/cdaweb/metadata/sp_phys_cdfmetafile.txt',DATASETS=datasets)
; Draw inventory graph...
if (datasets[0] ne '') then s=draw_inventory(a,TITLE='GPS Public CDAWeb Inventory',PNG='/var/www/cdaweb/htdocs/sc_inventory_plots/GPS_Public_Inventory.png',/debug)
if (datasets[0] ne '') then delvar, a

; Read the metadata file...
ds_list = ['MARS_HELIO1DAY_POSITION','NEW_HORIZONS_HELIO1DAY_POSITION','VENUS_HELIO1DAY_POSITION','SOHO_HELIO1DAY_POSITION','GIOTTO_HELIO1DAY_POSITION','SATURN_HELIO1DAY_POSITION','COMETGS_HELIO1DAY_POSITION','PHOBOS2_HELIO1DAY_POSITION','STA_HELIO1DAY_POSITION','HALEBOPP_HELIO1DAY_POSITION','THC_HELIO1DAY_POSITION','MERCURY_HELIO1DAY_POSITION','BORRELLY_HELIO1DAY_POSITION','ROSETTA_HELIO1DAY_POSITION','ISEE-3_HELIO1DAY_POSITION','ULYSSES_HELIO1DAY_POSITION','THB_HELIO1DAY_POSITION','JUPITER_HELIO1DAY_POSITION','JUNO_HELIO1DAY_POSITION','MESSENGER_HELIO1DAY_POSITION','MSL_HELIO1DAY_POSITION','VOYAGER2_HELIO1DAY_POSITION','GIACOBINI_HELIO1DAY_POSITION','EARTH_HELIO1DAY_POSITION','SAKIGAKE_HELIO1DAY_POSITION','DAWN_HELIO1DAY_POSITION','PIONEER11_HELIO1DAY_POSITION','WILD2_HELIO1DAY_POSITION','CASSINI_HELIO1DAY_POSITION','PIONEER10_HELIO1DAY_POSITION','GALILEO_HELIO1DAY_POSITION','SUISEI_HELIO1DAY_POSITION','HELIOS2_HELIO1DAY_POSITION','COMETHMP_HELIO1DAY_POSITION','HELIOS1_HELIO1DAY_POSITION','PLUTO_HELIO1DAY_POSITION','HALLEY_HELIO1DAY_POSITION','MAVEN_HELIO1DAY_POSITION','VOYAGER1_HELIO1DAY_POSITION','HYAKUTAKE_HELIO1DAY_POSITION','STB_HELIO1DAY_POSITION','NEPTUNE_HELIO1DAY_POSITION','URANUS_HELIO1DAY_POSITION','PSP_HELIO1DAY_POSITION','BEPICOLOMBO_HELIO1DAY_POSITION','SOLAR-ORBITER_HELIO1DAY_POSITION']
datasets = get_datasets(ds_list, '/home/cdaweb/metadata/sp_phys_cdfmetafile.txt')
if (datasets[0] ne '') then print,'Generating Helio1Day public'
if (datasets[0] ne '') then a = ingest_database('/home/cdaweb/metadata/sp_phys_cdfmetafile.txt',DATASETS=datasets)
; Draw inventory graph...
if (datasets[0] ne '') then s=draw_inventory(a,TITLE='Helio1Day_Position Public CDAWeb Inventory',PNG='/var/www/cdaweb/htdocs/sc_inventory_plots/Helio1Day_Public_Inventory.png',/debug)
if (datasets[0] ne '') then delvar, a

; Read the metadata file...
ds_list = ['HELIOS']
datasets = get_datasets(ds_list, '/home/cdaweb/metadata/sp_phys_cdfmetafile.txt')
if (datasets[0] ne '') then print,'Generating Helios public'
if (datasets[0] ne '') then a = ingest_database('/home/cdaweb/metadata/sp_phys_cdfmetafile.txt',DATASETS=datasets)
; Draw inventory graph...
if (datasets[0] ne '') then s=draw_inventory(a,TITLE='Helios Public CDAWeb Inventory',PNG='/var/www/cdaweb/htdocs/sc_inventory_plots/Helios_Public_Inventory.png',/debug)
if (datasets[0] ne '') then delvar, a

; Read the metadata file...
ds_list = ['IBEX']
datasets = get_datasets(ds_list, '/home/cdaweb/metadata/sp_phys_cdfmetafile.txt')
if (datasets[0] ne '') then print,'Generating IBEX public'
if (datasets[0] ne '') then a = ingest_database('/home/cdaweb/metadata/sp_phys_cdfmetafile.txt',DATASETS=datasets)
; Draw inventory graph...
if (datasets[0] ne '') then s=draw_inventory(a,TITLE='IBEX Public CDAWeb Inventory',PNG='/var/www/cdaweb/htdocs/sc_inventory_plots/IBEX_Public_Inventory.png',/debug)
if (datasets[0] ne '') then delvar, a

; Read the metadata file...
ds_list = ['ICON']
datasets = get_datasets(ds_list, '/home/cdaweb/metadata/sp_phys_cdfmetafile.txt')
if (datasets[0] ne '') then print,'Generating ICON public'
if (datasets[0] ne '') then a = ingest_database('/home/cdaweb/metadata/sp_phys_cdfmetafile.txt',DATASETS=datasets)
; Draw inventory graph...
if (datasets[0] ne '') then s=draw_inventory(a,TITLE='ICON Public CDAWeb Inventory',PNG='/var/www/cdaweb/htdocs/sc_inventory_plots/ICON_Public_Inventory.png',/debug)
if (datasets[0] ne '') then delvar, a

; Read the metadata file...
datasets = get_datasets('ISS_', '/home/cdaweb/metadata/sp_phys_cdfmetafile.txt')
if (datasets[0] ne '') then print,'Generating ISS public'
if (datasets[0] ne '') then a = ingest_database('/home/cdaweb/metadata/sp_phys_cdfmetafile.txt',DATASETS=datasets)
; Draw inventory graph...
if (datasets[0] ne '') then s=draw_inventory(a,TITLE='ISS Public CDAWeb Inventory',PNG='/var/www/cdaweb/htdocs/sc_inventory_plots/ISS_Public_Inventory.png',/debug)
if (datasets[0] ne '') then delvar, a

; Read the metadata file...
datasets = ['IM_OR_PRE','IM_OR_DEF','IM_K0_EUV','IM_K0_HENA','IM_K0_LENA','IM_K0_MENA','IM_K0_RPI','IM_K1_RPI','IM_K0_SIE','IM_K0_SIP','IM_K0_WIC','IM_HK_ADS','IM_HK_AST','IM_HK_COM','IM_HK_FSW','IM_HK_PWR','IM_HK_TML']
if (datasets[0] ne '') then print,'Generating IMAGE'
if (datasets[0] ne '') then a = ingest_database('/home/cdaweb/metadata/sp_phys_cdfmetafile.txt',DATASETS=datasets)
; Draw inventory graph...
if (datasets[0] ne '') then s=draw_inventory(a,TITLE='IMAGE CDAWeb Inventory',PNG='/var/www/cdaweb/htdocs/sc_inventory_plots/IMAGE_Inventory.png',/debug)
if (datasets[0] ne '') then delvar, a

; Read the metadata file...
;datasets = ['I8_K0_MAG','I8_H0_MAG','I8_K0_PLA','I8_H0_GME','I8_OR_SSC']
ds_list = ['I8_']
datasets = get_datasets(ds_list, '/home/cdaweb/metadata/sp_phys_cdfmetafile.txt')
if (datasets[0] ne '') then print,'Generating IMP8'
if (datasets[0] ne '') then a = ingest_database('/home/cdaweb/metadata/sp_phys_cdfmetafile.txt',DATASETS=datasets)
; Draw inventory graph...
if (datasets[0] ne '') then s=draw_inventory(a,TITLE='IMP8 CDAWeb Inventory',PNG='/var/www/cdaweb/htdocs/sc_inventory_plots/IMP8_Inventory.png',/debug)
if (datasets[0] ne '') then delvar, a

; Read the metadata file...
datasets = ['IA_K0_EPI','IA_K0_MFI','IA_K0_ENF','IA_OR_DEF','IG_K0_PCI','IT_H0_MFI','IT_K0_MFI','IT_K0_AKR','IT_K0_COR','IT_K0_ELE','IT_K0_EPI','IT_K0_ICD','IT_K0_VDP','IT_K0_WAV','IT_OR_DEF']
if (datasets[0] ne '') then print,'Generating Interball'
if (datasets[0] ne '') then a = ingest_database('/home/cdaweb/metadata/sp_phys_cdfmetafile.txt',DATASETS=datasets)
; Draw inventory graph...
if (datasets[0] ne '') then s=draw_inventory(a,TITLE='Interball CDAWeb Inventory',PNG='/var/www/cdaweb/htdocs/sc_inventory_plots/Interball_Inventory.png',/debug)
if (datasets[0] ne '') then delvar, a

; Read the metadata file...
ds_list = ['ISEE']
datasets = get_datasets(ds_list, '/home/cdaweb/metadata/sp_phys_cdfmetafile.txt')
if (datasets[0] ne '') then print,'Generating ISEE'
if (datasets[0] ne '') then a = ingest_database('/home/cdaweb/metadata/sp_phys_cdfmetafile.txt',DATASETS=datasets)
; Draw inventory graph...
if (datasets[0] ne '') then s=draw_inventory(a,TITLE='ISEE CDAWeb Inventory',PNG='/var/www/cdaweb/htdocs/sc_inventory_plots/ISEE_Inventory.png',/debug)
if (datasets[0] ne '') then delvar, a

; Read the metadata file...
datasets = ['I1_AV_KER','I1_AV_KSH','I1_AV_KWA','I1_AV_ODG','I1_AV_ORR','I1_AV_OTT','I1_AV_QUI','I1_AV_RES','I1_AV_SNT','I1_AV_TRO','I1_AV_ULA','I1_AV_WNK','I2_AV_SYO','I2_AV_ACN','I2_AV_ADL','I2_AV_AME','I2_AV_BRZ','I2_AV_BUR','I2_AV_CNA','I2_AV_KER','I2_AV_KSH','I2_AV_KRU','I2_AV_KWA','I2_AV_LAU','I2_AV_ODG','I2_AV_ORR','I2_AV_OTT','I2_AV_QUI','I2_AV_RES','I2_AV_SNT','I2_AV_SOL','I2_AV_SYO','I2_AV_TRO','I2_AV_ULA','I2_AV_WNK']
if (datasets[0] ne '') then print,'Generating ISIS'
if (datasets[0] ne '') then a = ingest_database('/home/cdaweb/metadata/sp_phys_cdfmetafile.txt',DATASETS=datasets)
; Draw inventory graph...
if (datasets[0] ne '') then s=draw_inventory(a,TITLE='ISIS CDAWeb Inventory',PNG='/var/www/cdaweb/htdocs/sc_inventory_plots/ISIS_Inventory.png',/debug)
if (datasets[0] ne '') then delvar, a

; Read the metadata file...
datasets = ['A1_K0_MPA','A2_K0_MPA','L9_H0_MPA','L9_K0_MPA','L9_K0_SPA','L0_K0_MPA','L0_K0_SPA','L1_K0_MPA','L1_K0_SPA','L4_K0_MPA','L4_K0_SPA','L7_H0_MPA','L7_K0_MPA','L7_K0_SPA']
if (datasets[0] ne '') then print,'Generating LANL'
if (datasets[0] ne '') then a = ingest_database('/home/cdaweb/metadata/sp_phys_cdfmetafile.txt',DATASETS=datasets)
; Draw inventory graph...
if (datasets[0] ne '') then s=draw_inventory(a,TITLE='LANL CDAWeb Inventory',PNG='/var/www/cdaweb/htdocs/sc_inventory_plots/LANL_Inventory.png',/debug)
if (datasets[0] ne '') then delvar, a

; Read the metadata file...
ds_list = ['MAVEN','MVN']
datasets = get_datasets(ds_list, '/home/cdaweb/metadata/sp_phys_cdfmetafile.txt')
if (datasets[0] ne '') then print,'Generating Maven public'
if (datasets[0] ne '') then a = ingest_database('/home/cdaweb/metadata/sp_phys_cdfmetafile.txt',DATASETS=datasets)
; Draw inventory graph...
if (datasets[0] ne '') then s=draw_inventory(a,TITLE='Maven Public CDAWeb Inventory',PNG='/var/www/cdaweb/htdocs/sc_inventory_plots/Maven_Public_Inventory.png',/debug)
if (datasets[0] ne '') then delvar, a

; Read the metadata file...
ds_list = ['MMS']
datasets = get_datasets(ds_list, '/home/cdaweb/metadata/sp_phys_cdfmetafile.txt')
if (datasets[0] ne '') then print,'Generating MMS public'
if (datasets[0] ne '') then a = ingest_database('/home/cdaweb/metadata/sp_phys_cdfmetafile.txt',DATASETS=datasets)
; Draw inventory graph...
if (datasets[0] ne '') then s=draw_inventory(a,TITLE='MMS CDAWeb Inventory',PNG='/var/www/cdaweb/htdocs/sc_inventory_plots/MMS_Public_Inventory.png',/debug)
if (datasets[0] ne '') then delvar, a
; Read the metadata file...

ds_list = ['MUNIN']
datasets = get_datasets(ds_list, '/home/cdaweb/metadata/sp_phys_cdfmetafile.txt')
if (datasets[0] ne '') then print,'Generating MUNIN public'
if (datasets[0] ne '') then a = ingest_database('/home/cdaweb/metadata/sp_phys_cdfmetafile.txt',DATASETS=datasets)
; Draw inventory graph...
if (datasets[0] ne '') then s=draw_inventory(a,TITLE='MUNIN CDAWeb Inventory',PNG='/var/www/cdaweb/htdocs/sc_inventory_plots/MUNIN_Public_Inventory.png',/debug)
if (datasets[0] ne '') then delvar, a

; Read the metadata file...
ds_list = ['NEW_HORIZONS']
datasets = get_datasets(ds_list, '/home/cdaweb/metadata/sp_phys_cdfmetafile.txt')
if (datasets[0] ne '') then print,'Generating New Horizons public'
if (datasets[0] ne '') then a = ingest_database('/home/cdaweb/metadata/sp_phys_cdfmetafile.txt',DATASETS=datasets)
; Draw inventory graph...
if (datasets[0] ne '') then s=draw_inventory(a,TITLE='New Horizons Public CDAWeb Inventory',PNG='/var/www/cdaweb/htdocs/sc_inventory_plots/New_Horizons_Public_Inventory.png',/debug)
if (datasets[0] ne '') then delvar, a

; Read the metadata file...
ds_list = ['NOAA']
datasets = get_datasets(ds_list, '/home/cdaweb/metadata/sp_phys_cdfmetafile.txt')
if (datasets[0] ne '') then print,'Generating NOAA public'
if (datasets[0] ne '') then a = ingest_database('/home/cdaweb/metadata/sp_phys_cdfmetafile.txt',DATASETS=datasets)
; Draw inventory graph...
if (datasets[0] ne '') then s=draw_inventory(a,TITLE='NOAA Public CDAWeb Inventory',PNG='/var/www/cdaweb/htdocs/sc_inventory_plots/NOAA_Public_Inventory.png',/debug)
if (datasets[0] ne '') then delvar, a

; Read the metadata file...
ds_list = ['OMNI']
datasets = get_datasets(ds_list, '/home/cdaweb/metadata/sp_phys_cdfmetafile.txt')
if (datasets[0] ne '') then print,'Generating OMNI public'
if (datasets[0] ne '') then a = ingest_database('/home/cdaweb/metadata/sp_phys_cdfmetafile.txt',DATASETS=datasets)
; Draw inventory graph...
if (datasets[0] ne '') then s=draw_inventory(a,TITLE='OMNI Public CDAWeb Inventory',PNG='/var/www/cdaweb/htdocs/sc_inventory_plots/OMNI_Public_Inventory.png',/debug)
if (datasets[0] ne '') then delvar, a

;; Read the metadata file...
ds_list = ['PIONEER']
datasets = get_datasets(ds_list, '/home/cdaweb/metadata/sp_phys_cdfmetafile.txt')
if (datasets[0] ne '') then print,'Generating Pioneer public'
if (datasets[0] ne '') then a = ingest_database('/home/cdaweb/metadata/sp_phys_cdfmetafile.txt',DATASETS=datasets)
; Draw inventory graph...
if (datasets[0] ne '') then s=draw_inventory(a,TITLE='Pioneer Public CDAWeb Inventory',PNG='/var/www/cdaweb/htdocs/sc_inventory_plots/Pioneer_Public_Inventory.png',/debug)
if (datasets[0] ne '') then delvar, a

; Read the metadata file...
ds_list = ['PO_','POLAR']
datasets = get_datasets(ds_list, '/home/cdaweb/metadata/sp_phys_cdfmetafile.txt')
if (datasets[0] ne '') then print,'Generating Polar public'
if (datasets[0] ne '') then a = ingest_database('/home/cdaweb/metadata/sp_phys_cdfmetafile.txt',DATASETS=datasets)
; Draw inventory graph...
if (datasets[0] ne '') then s=draw_inventory(a,TITLE='Polar Public CDAWeb Inventory',PNG='/var/www/cdaweb/htdocs/sc_inventory_plots/Polar_Public_Inventory.png',/debug)
if (datasets[0] ne '') then delvar, a

;; Read the metadata file...
ds_list = ['PSP_']
datasets = get_datasets(ds_list, '/home/cdaweb/metadata/sp_phys_cdfmetafile.txt')
if (datasets[0] ne '') then print,'Generating PSP'
if (datasets[0] ne '') then a = ingest_database('/home/cdaweb/metadata/sp_phys_cdfmetafile.txt',DATASETS=datasets)
; Draw inventory graph...
;if (datasets[0] ne '') then s=draw_inventory(a2,TITLE='PSP CDAWeb Inventory',GIF='/var/www/cdaweb/htdocs/sc_inventory_plots/PSP_Inventory.gif',/debug)
;; TJK 2/26/2020 change to draw inventory graph, draw 4 for PSP, one for each
;; year... Lan wanted more detail
a2 = a
if (datasets[0] ne '') then s=draw_inventory(a,TITLE='PSP Full CDAWeb Inventory',PNG='/var/www/cdaweb/htdocs/sc_inventory_plots/PSP_Inventory.png',/debug)
a = a2
if (datasets[0] ne '') then s=draw_inventory(a,TITLE='PSP 2018 CDAWeb Inventory',PNG='/var/www/cdaweb/htdocs/sc_inventory_plots/PSP-2018_Inventory.png', START_TIME='2018/10/01 00:00:00', STOP_TIME='2019/01/01 00:00:00', /debug)
a = a2
if (datasets[0] ne '') then s=draw_inventory(a,TITLE='PSP 2019 CDAWeb Inventory',PNG='/var/www/cdaweb/htdocs/sc_inventory_plots/PSP-2019_Inventory.png', START_TIME='2019/01/01 00:00:00', STOP_TIME='2020/01/01 00:00:00', /debug)
a = a2
if (datasets[0] ne '') then s=draw_inventory(a,TITLE='PSP 2020 CDAWeb Inventory',PNG='/var/www/cdaweb/htdocs/sc_inventory_plots/PSP-2020_Inventory.png', START_TIME='2020/01/01 00:00:00', STOP_TIME='2021/01/01 00:00:00', /debug)
a = a2
if (datasets[0] ne '') then s=draw_inventory(a,TITLE='PSP 2021 CDAWeb Inventory',PNG='/var/www/cdaweb/htdocs/sc_inventory_plots/PSP-2021_Inventory.png', START_TIME='2021/01/01 00:00:00', STOP_TIME='2022/01/01 00:00:00', /debug)
a = a2
if (datasets[0] ne '') then s=draw_inventory(a,TITLE='PSP 2022 CDAWeb Inventory',PNG='/var/www/cdaweb/htdocs/sc_inventory_plots/PSP-2022_Inventory.png', START_TIME='2022/01/01 00:00:00', STOP_TIME='2023/01/01 00:00:00', /debug)
if (datasets[0] ne '') then delvar, a

; Read the metadata file...
ds_list = ['RBSP']
datasets = get_datasets(ds_list, '/home/cdaweb/metadata/sp_phys_cdfmetafile.txt')
if (datasets[0] ne '') then print,'Generating RBSP'
if (datasets[0] ne '') then a = ingest_database('/home/cdaweb/metadata/sp_phys_cdfmetafile.txt',DATASETS=datasets)
; Draw inventory graph...
if (datasets[0] ne '') then s=draw_inventory(a,/wide_margin,TITLE='RBSP CDAWeb Inventory',PNG='/var/www/cdaweb/htdocs/sc_inventory_plots/RBSP_Inventory.png',/debug)
if (datasets[0] ne '') then delvar, a

; Read the metadata file...
datasets = ['SX_K0_30F','SX_K0_POF']
if (datasets[0] ne '') then print,'Generating Sampex'
if (datasets[0] ne '') then a = ingest_database('/home/cdaweb/metadata/sp_phys_cdfmetafile.txt',DATASETS=datasets)
; Draw inventory graph...
if (datasets[0] ne '') then s=draw_inventory(a,TITLE='SAMPEX CDAWeb Inventory',PNG='/var/www/cdaweb/htdocs/sc_inventory_plots/SAMPEX_Inventory.png',/debug)
if (datasets[0] ne '') then delvar, a

; Read the metadata file...
datasets = ['SE_K0_AIS,','SE_K0_FPI','SE_K0_MAG','SE_K0_RIO','SE_K0_VLF']
if (datasets[0] ne '') then print,'Generating Sesame'
if (datasets[0] ne '') then a = ingest_database('/home/cdaweb/metadata/sp_phys_cdfmetafile.txt',DATASETS=datasets)
; Draw inventory graph...
if (datasets[0] ne '') then s=draw_inventory(a,TITLE='Sesame CDAWeb Inventory',PNG='/var/www/cdaweb/htdocs/sc_inventory_plots/SESAME_Inventory.png',/debug)
if (datasets[0] ne '') then delvar, a

; Read the metadata file...
;datasets = ['SO_K0_CEL','SO_K0_CST','SO_K0_ERN','SO_OR_DEF','SO_OR_PRE','SO_AT_DEF']
;TJK 3/15/2022 look for the additional new data sets starting w/ soho_
ds_list = ['SO_','SOHO_']
datasets = get_datasets(ds_list, '/home/cdaweb/metadata/sp_phys_cdfmetafile.txt')
if (datasets[0] ne '') then print,'Generating SOHO'
if (datasets[0] ne '') then a = ingest_database('/home/cdaweb/metadata/sp_phys_cdfmetafile.txt',DATASETS=datasets)
; Draw inventory graph...
if (datasets[0] ne '') then s=draw_inventory(a,TITLE='SOHO CDAWeb Inventory',PNG='/var/www/cdaweb/htdocs/sc_inventory_plots/SOHO_Inventory.png',/debug)
if (datasets[0] ne '') then delvar, a

; Read the metadata file...
ds_list = ['RENU2_'] ;  sounding rockets
datasets = get_datasets(ds_list, '/home/cdaweb/metadata/sp_phys_cdfmetafile.txt')
if (datasets[0] ne '') then print,'Generating Sounding Rockets'
if (datasets[0] ne '') then a = ingest_database('/home/cdaweb/metadata/sp_phys_cdfmetafile.txt',DATASETS=datasets)
; Draw inventory graph...
if (datasets[0] ne '') then s=draw_inventory(a,TITLE='Sounding Rockets CDAWeb Inventory',PNG='/var/www/cdaweb/htdocs/sc_inventory_plots/SOUNDING_ROCKETS_Inventory.png', START_TIME='2015/12/01 00:00:00', STOP_TIME= '2015/12/31 00:00:00',/debug)
if (datasets[0] ne '') then delvar, a

; Read the metadata file...
ds_list = ['STEREO_','STA_','STB_']
datasets = get_datasets(ds_list, '/home/cdaweb/metadata/sp_phys_cdfmetafile.txt')
if (datasets[0] ne '') then print,'Generating Stereo'
if (datasets[0] ne '') then a = ingest_database('/home/cdaweb/metadata/sp_phys_cdfmetafile.txt',DATASETS=datasets)
; Draw inventory graph...
if (datasets[0] ne '') then s=draw_inventory(a,TITLE='STEREO CDAWeb Inventory',PNG='/var/www/cdaweb/htdocs/sc_inventory_plots/STEREO_Inventory.png',/debug)
if (datasets[0] ne '') then delvar, a

; Read the metadata file...
ds_list = ['SOLO_']
datasets = get_datasets(ds_list, '/home/cdaweb/metadata/sp_phys_cdfmetafile.txt')
if (datasets[0] ne '') then print,'Generating Solar-Orbiter'
if (datasets[0] ne '') then a = ingest_database('/home/cdaweb/metadata/sp_phys_cdfmetafile.txt',DATASETS=datasets)
; Draw inventory graph...
; Lan wants more yearly too if (datasets[0] ne '') then s=draw_inventory(a,TITLE='Solar-Orbiter CDAWeb Inventory',PNG='/var/www/cdaweb/htdocs/sc_inventory_plots/SOLO_Inventory.png',/debug)
a2 = a
if (datasets[0] ne '') then s=draw_inventory(a,TITLE='Solar-Orbiter Full CDAWeb Inventory',PNG='/var/www/cdaweb/htdocs/sc_inventory_plots/SOLO_Inventory.png',/debug)
a = a2
if (datasets[0] ne '') then s=draw_inventory(a,TITLE='Solar-Orbiter 2020 CDAWeb Inventory',PNG='/var/www/cdaweb/htdocs/sc_inventory_plots/SOLO-2020_Inventory.png', START_TIME='2020/01/01 00:00:00', STOP_TIME='2021/01/01 00:00:00', /debug)
a = a2
if (datasets[0] ne '') then s=draw_inventory(a,TITLE='Solar-Orbiter 2021 CDAWeb Inventory',PNG='/var/www/cdaweb/htdocs/sc_inventory_plots/SOLO-2021_Inventory.png', START_TIME='2021/01/01 00:00:00', STOP_TIME='2022/01/01 00:00:00', /debug)
a = a2
if (datasets[0] ne '') then s=draw_inventory(a,TITLE='Solar-Orbiter 2022 CDAWeb Inventory',PNG='/var/www/cdaweb/htdocs/sc_inventory_plots/SOLO-2022_Inventory.png', START_TIME='2022/01/01 00:00:00', STOP_TIME='2023/01/01 00:00:00', /debug)
if (datasets[0] ne '') then delvar, a

; Read the metadata file...
ds_list = ['TH']
datasets = get_datasets(ds_list, '/home/cdaweb/metadata/sp_phys_cdfmetafile.txt')
if (datasets[0] ne '') then print,'Generating THEMIS'
if (datasets[0] ne '') then a = ingest_database('/home/cdaweb/metadata/sp_phys_cdfmetafile.txt',DATASETS=datasets)
; Draw inventory graph...
if (datasets[0] ne '') then s=draw_inventory(a,TITLE='THEMIS CDAWeb Inventory',PNG='/var/www/cdaweb/htdocs/sc_inventory_plots/THEMIS_Inventory.png',/debug)
if (datasets[0] ne '') then delvar, a

; Read the metadata file...
;datasets = ['TIMED_L1CDISK_GUVI','TIMED_WINDVECTORSNCAR_TIDI','TIMED_R0_SABER','TIMED_L3A_SEE']
ds_list = ['TIMED_']
datasets = get_datasets(ds_list, '/home/cdaweb/metadata/sp_phys_cdfmetafile.txt')
if (datasets[0] ne '') then print,'Generating Timed'
if (datasets[0] ne '') then a = ingest_database('/home/cdaweb/metadata/sp_phys_cdfmetafile.txt',DATASETS=datasets)
; Draw inventory graph...
if (datasets[0] ne '') then s=draw_inventory(a,TITLE='TIMED CDAWeb Inventory',PNG='/var/www/cdaweb/htdocs/sc_inventory_plots/TIMED_Inventory.png',/debug)
if (datasets[0] ne '') then delvar, a

; Read the metadata file...
ds_list = ['TSS']
datasets = get_datasets(ds_list, '/home/cdaweb/metadata/sp_phys_cdfmetafile.txt')
if (datasets[0] ne '') then print,'Generating TSS'
if (datasets[0] ne '') then a = ingest_database('/home/cdaweb/metadata/sp_phys_cdfmetafile.txt',DATASETS=datasets)
; Draw inventory graph...
if (datasets[0] ne '') then s=draw_inventory(a,TITLE='TSS-1R CDAWeb Inventory',PNG='/var/www/cdaweb/htdocs/sc_inventory_plots/TSS_Inventory.png',/debug)
if (datasets[0] ne '') then delvar, a

; Read the metadata file...
ds_list = ['TWINS']
datasets = get_datasets(ds_list, '/home/cdaweb/metadata/sp_phys_cdfmetafile.txt')
if (datasets[0] ne '') then print,'Generating TWINS'
if (datasets[0] ne '') then a = ingest_database('/home/cdaweb/metadata/sp_phys_cdfmetafile.txt',DATASETS=datasets)
; Draw inventory graph...
if (datasets[0] ne '') then s=draw_inventory(a,TITLE='TWINS CDAWeb Inventory',PNG='/var/www/cdaweb/htdocs/sc_inventory_plots/TWINS_Inventory.png',/debug)
if (datasets[0] ne '') then delvar, a

; Read the metadata file...
;datasets = ['UY_1SEC_VHM','UY_1MIN_VHM','UY_H0_GLG','UY_M0_LET','UY_M0_HET','UY_M0_KET','UY_M0_HFT','UY_M0_AT1','UY_M0_AT2','UY_M0_BAI','UY_M0_BAE','UY_M0_PFRA','UY_M0_PFRP','UY_M0_R144','UY_M0_RARA','UY_M0_RARP','UY_M0_WFBA','UY_M0_WFBP','UY_M0_WFEA','UY_M0_WFEP','UY_M1_BAI','UY_M1_SWI','UY_M1_VHM','UY_M1_EPA','UY_M1_LF15','UY_M1_LM12','UY_M1_LMDE','UY_M1_WRTD','UY_M1_LF60','UY_M1_LM30','UY_M1_WART']
ds_list = ['UY_']
datasets = get_datasets(ds_list, '/home/cdaweb/metadata/sp_phys_cdfmetafile.txt')
if (datasets[0] ne '') then print,'Generating Ulysses'
if (datasets[0] ne '') then a = ingest_database('/home/cdaweb/metadata/sp_phys_cdfmetafile.txt',DATASETS=datasets)
; Draw inventory graph...
if (datasets[0] ne '') then s=draw_inventory(a,TITLE='Ulysses CDAWeb Inventory',PNG='/var/www/cdaweb/htdocs/sc_inventory_plots/Ulysses_Inventory.png',/debug)
if (datasets[0] ne '') then delvar, a

;; Read the metadata file...
ds_list = ['VOYAGER']
datasets = get_datasets(ds_list, '/home/cdaweb/metadata/sp_phys_cdfmetafile.txt')
if (datasets[0] ne '') then print,'Generating VOYAGER'
if (datasets[0] ne '') then a = ingest_database('/home/cdaweb/metadata/sp_phys_cdfmetafile.txt',DATASETS=datasets)
;; Draw inventory graph...
if (datasets[0] ne '') then s=draw_inventory(a,TITLE='Voyager CDAWeb Inventory',PNG='/var/www/cdaweb/htdocs/sc_inventory_plots/Voyager_Inventory.png',/debug)
if (datasets[0] ne '') then delvar, a
; Read the metadata file...
;datasets = ['WI_H0_MFI','WI_H0_MFI','WI_K0_MFI','WI_H0_SWE','WI_H1_SWE','WI_K0_SWE','WI_K0_3DP','WI_ELSP_3DP','WI_PM_3DP','WI_K0_EPA','WI_K0_SMS','WI_H0_WAV','WI_H1_WAV','WI_K0_WAV','WI_OR_DEF','WI_OR_PRE','WI_AT_DEF','WI_AT_PRE','WI_K0_SPHA']
ds_list = ['WI_']
datasets = get_datasets(ds_list, '/home/cdaweb/metadata/sp_phys_cdfmetafile.txt')
if (datasets[0] ne '') then print,'Generating Wind'
if (datasets[0] ne '') then a = ingest_database('/home/cdaweb/metadata/sp_phys_cdfmetafile.txt',DATASETS=datasets)
; Draw inventory graph...
if (datasets[0] ne '') then s=draw_inventory(a,TITLE='Wind CDAWeb Inventory',PNG='/var/www/cdaweb/htdocs/sc_inventory_plots/Wind_Inventory.png',/debug)
if (datasets[0] ne '') then delvar, a


exit




