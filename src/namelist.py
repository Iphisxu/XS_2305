
datadir   = 'D:/data/Project_Xiaoshan/'

# local emis
emisdir   = datadir + 'Local_emis_2020/original_emis/'
emisfile  = emisdir + 'XS_emis_inventory_2020.xlsx'
emispoint = emisdir + 'point_source.xlsx'
emisarea  = emisdir + 'area_source.xlsx'

# local emis netcdf
emis_point_dir = datadir + 'Local_emis_2020/preliminary_emis/point_source/'
local_ind_point = emis_point_dir + 'industry.nc'
local_agr_point = emis_point_dir + 'agriculture.nc'

emis_area_dir = datadir + 'Local_emis_2020/preliminary_emis/area_source/'
local_ind_area = emis_area_dir + ''

# meic emis
meicdir = datadir + 'Local_emis_2020/MEIC_XS/'
meic_ind_file = meicdir + 'emis.CN3XS_135X138.ind.ncf'
meic_pow_file = meicdir + 'emis.CN3XS_135X138.pow.ncf'
meic_res_file = meicdir + 'emis.CN3XS_135X138.res.ncf'
meic_tra_file = meicdir + 'emis.CN3XS_135X138.tra.ncf'
meic_agr_file = meicdir + 'emis.CN3XS_135X138.agr.ncf'
meic_shp_file = meicdir + 'emis.CN3XS_135X138.shp.ncf'
