clear
% function create_ncfile_with_info(input_nc_file, output_nc_file, xls_file)
gridfile = 'D:/data/Project_Xiaoshan/GRIDCRO2D_2022234.nc';
input_nc_file  = 'D:/data/Project_Xiaoshan/Local_emis_2020/for_matlab/emis.CN3XS_135X138.tra.ncf';
xls_file       = 'D:/data/Project_Xiaoshan/Local_emis_2020/for_matlab/saprc07tic_species.xlsx';
output_nc_file = 'D:/Download/matlabcreated_tra.ncf';

% 读取TSTEP、LAY、ROW、COL四个维度坐标信息
tstep = ncread(input_nc_file, 'TSTEP');
lay = ncread(input_nc_file, 'LAY');
row = ncread(input_nc_file, 'ROW');
col = ncread(input_nc_file, 'COL');

% 读取物种名称和单位信息
[~, ~, xls_data] = xlsread(xls_file, 'Sheet1');
species_names = xls_data(2:73, 1);
species_units = xls_data(2:73, 2);

% 创建新的NetCDF文件
ncid = netcdf.create(output_nc_file, 'CLASSIC_MODEL');

% create varlist
varlist(16*numel(species_names))=' ';
varlist(:)=' ';
for v=1:numel(species_names)
    [~,nstr]=size(species_names{v});
    varlist((v-1)*16+1:(v-1)*16+nstr)=species_names{v};
end

% 添加TSTEP、LAY、ROW、COL四个维度坐标
dim_tstep = netcdf.defDim(ncid, 'TSTEP', netcdf.getConstant('UNLIMITED'));
dim_date  = netcdf.defDim(ncid, 'DATE_TIME', 2);
dim_lay   = netcdf.defDim(ncid, 'LAY', numel(lay));
dim_var   = netcdf.defDim(ncid, 'VAR', numel(species_names));
dim_row   = netcdf.defDim(ncid, 'ROW', numel(row));
dim_col   = netcdf.defDim(ncid, 'COL', numel(col));

% 写入全局属性
varid=netcdf.getConstant('NC_GLOBAL');
netcdf.putAtt(ncid,varid,'IOAPI_VERSION',ncreadatt(gridfile,'/','IOAPI_VERSION'));
netcdf.putAtt(ncid,varid,'EXEC_ID',ncreadatt(gridfile,'/','EXEC_ID'));
netcdf.putAtt(ncid,varid,'FTYPE',ncreadatt(gridfile,'/','FTYPE'));
netcdf.putAtt(ncid,varid,'CDATE',ncreadatt(gridfile,'/','CDATE'));
netcdf.putAtt(ncid,varid,'CTIME',ncreadatt(gridfile,'/','CTIME'));
netcdf.putAtt(ncid,varid,'WDATE',ncreadatt(gridfile,'/','WDATE'));
netcdf.putAtt(ncid,varid,'WTIME',ncreadatt(gridfile,'/','WTIME'));
netcdf.putAtt(ncid,varid,'SDATE',ncreadatt(gridfile,'/','SDATE'));
netcdf.putAtt(ncid,varid,'STIME',ncreadatt(gridfile,'/','STIME'));
netcdf.putAtt(ncid,varid,'TSTEP',int32(10000));
netcdf.putAtt(ncid,varid,'NTHIK',ncreadatt(gridfile,'/','NTHIK'));
netcdf.putAtt(ncid,varid,'NCOLS',ncreadatt(gridfile,'/','NCOLS'));
netcdf.putAtt(ncid,varid,'NROWS',ncreadatt(gridfile,'/','NROWS'));
netcdf.putAtt(ncid,varid,'NLAYS',ncreadatt(gridfile,'/','NLAYS'));
netcdf.putAtt(ncid,varid,'NVARS',int32(numel(species_names)));
netcdf.putAtt(ncid,varid,'GDTYP',ncreadatt(gridfile,'/','GDTYP'));
netcdf.putAtt(ncid,varid,'P_ALP',ncreadatt(gridfile,'/','P_ALP'));
netcdf.putAtt(ncid,varid,'P_BET',ncreadatt(gridfile,'/','P_BET'));
netcdf.putAtt(ncid,varid,'P_GAM',ncreadatt(gridfile,'/','P_GAM'));
netcdf.putAtt(ncid,varid,'XCENT',ncreadatt(gridfile,'/','XCENT'));
netcdf.putAtt(ncid,varid,'YCENT',ncreadatt(gridfile,'/','YCENT'));
netcdf.putAtt(ncid,varid,'XORIG',ncreadatt(gridfile,'/','XORIG'));
netcdf.putAtt(ncid,varid,'YORIG',ncreadatt(gridfile,'/','YORIG'));
netcdf.putAtt(ncid,varid,'XCELL',ncreadatt(gridfile,'/','XCELL'));
netcdf.putAtt(ncid,varid,'YCELL',ncreadatt(gridfile,'/','YCELL'));
netcdf.putAtt(ncid,varid,'VGTYP',ncreadatt(gridfile,'/','VGTYP'));
netcdf.putAtt(ncid,varid,'VGTOP',ncreadatt(gridfile,'/','VGTOP'));
netcdf.putAtt(ncid,varid,'VGLVLS',ncreadatt(gridfile,'/','VGLVLS'));
netcdf.putAtt(ncid,varid,'GDNAM',ncreadatt(gridfile,'/','GDNAM'));
netcdf.putAtt(ncid,varid,'UPNAM',ncreadatt(gridfile,'/','UPNAM'));
netcdf.putAtt(ncid,varid,'VAR-LIST',varlist);
netcdf.putAtt(ncid,varid,'FILEDESC',ncreadatt(gridfile,'/','FILEDESC'));
netcdf.putAtt(ncid,varid,'HISTORY',ncreadatt(gridfile,'/','HISTORY'));

% TFLAG
varid=netcdf.defVar(ncid,'TFLAG','NC_INT',[dim_date,dim_var,dim_tstep]);
netcdf.putAtt(ncid,varid,'units','<YYYYDDD,HHMMSS>');
netcdf.putAtt(ncid,varid,'long_name','TFLAG           ');
netcdf.putAtt(ncid,varid,'var_desc','Timestep-valid flags:  (1) YYYYDDD or (2) HHMMSS                                ');

% 添加emis变量
for i = 1:numel(species_names)
    varid = netcdf.defVar(ncid, species_names{i}, 'NC_FLOAT', [dim_col, dim_row, dim_lay, dim_tstep]);
    netcdf.putAtt(ncid, varid, 'long_name', species_names{i});
    netcdf.putAtt(ncid, varid, 'units', species_units{i});
    netcdf.putAtt(ncid, varid, 'var_desc', species_names{i});
end

netcdf.endDef(ncid);
netcdf.close(ncid);

% 读取已有的NetCDF文件
info = ncinfo(input_nc_file);

% 读取emis变量信息和数据
emis_vars = cell(1, numel(info.Variables));
for i = 1:numel(info.Variables)
    emis_vars{i} = info.Variables(i).Name;
    emis_data{i} = ncread(input_nc_file, emis_vars{i});
end
% 删掉维度变量
emis_vars(1:4)=[];
emis_data(1:4)=[];

% TFLAG
tflag(2,numel(species_names),12)=0;
tflag(1,:,:)=2023001;
for i=1:12
    tflag(2,:,i)=(i-1)*10000;
end
tflag=int32(tflag);
ncwrite(output_nc_file,'TFLAG',tflag);

% 写入变量数据
for i = 1:numel(emis_vars)
    temp_var_data = ncread(input_nc_file, species_names{i});
    ncwrite(output_nc_file,species_names{i},temp_var_data);
end

disp('New NetCDF file created successfully!');
% end
