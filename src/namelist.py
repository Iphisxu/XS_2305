
datadir   = 'D:/data/Project_Xiaoshan/'

# local emis
emisdir   = datadir + 'Local_emis_2020/original_emis/'
emisfile  = emisdir + 'XS_emis_inventory_2020.xlsx'
emispoint = emisdir + 'point_source.xlsx'
emisarea  = emisdir + 'area_source.xlsx'

# sector mapping file
secmap = datadir + 'Local_emis_2020/SectorMapping.xlsx'

# local emis netcdf
emis_nc_dir = datadir + 'Local_emis_2020/preliminary_emis/meic_category/sum/'
local_ind_file = emis_nc_dir + 'Industry.nc'
local_pow_file = emis_nc_dir + 'Power.nc'
local_tra_file = emis_nc_dir + 'Transportation.nc'
local_res_file = emis_nc_dir + 'Residential.nc'
local_agr_file = emis_nc_dir + 'Agriculture.nc'

# meic emis
meicdir = datadir + 'Local_emis_2020/MEIC_XS/'
meic_ind_file = meicdir + 'emis.CN3XS_135X138.ind.ncf'
meic_pow_file = meicdir + 'emis.CN3XS_135X138.pow.ncf'
meic_res_file = meicdir + 'emis.CN3XS_135X138.res.ncf'
meic_tra_file = meicdir + 'emis.CN3XS_135X138.tra.ncf'
meic_agr_file = meicdir + 'emis.CN3XS_135X138.agr.ncf'
meic_shp_file = meicdir + 'emis.CN3XS_135X138.shp.ncf'

# allocated emis
allocated_dir = datadir + 'Local_emis_2020/allocated_emis/'
lex_ind_file = allocated_dir + 'ind.nc'
lex_pow_file = allocated_dir + 'pow.nc'
lex_tra_file = allocated_dir + 'tra.nc'
lex_res_file = allocated_dir + 'res.nc'
lex_agr_file = allocated_dir + 'agr.nc'

# for TEST_SIM
timestart = '2023-06-11T00'
timeend   = '2023-06-16T23'

mcip_file   = datadir + 'TEST_SIM/XS_test_mcip.nc'
meic_ncfile = datadir + 'TEST_SIM/XS_test_meic.nc'
lex_ncfile  = datadir + 'TEST_SIM/XS_test_lex.nc'

# shapefile
shphz   = datadir + 'shapefile/杭州市/杭州市.shp'
shpxs = datadir + 'shapefile/萧山区/萧山区.shp'
shpmap   = datadir + 'shapefile/杭州市各区/杭州市各区.shp'