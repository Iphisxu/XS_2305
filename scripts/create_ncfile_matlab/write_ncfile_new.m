clear
% Specify file paths
sections = {'ind','pow','tra','res','agr'};
gridname = 'CN3XS_135X138';
input_path = 'D:/data/Project_Xiaoshan/Local_emis_2020/integrated_emis/';
output_path = 'D:/data/Project_Xiaoshan/Local_emis_2020/to_upload/';

gridfile = 'D:/data/Project_Xiaoshan/GRIDCRO2D_2022234.nc';

for sec = sections
    input_nc_file = [input_path,'emis.',gridname,'.',sec{1},'.ncf'];
    xls_file = [input_path,'saprc07tic_species.xlsx'];
    output_nc_file = [output_path,'emis.',gridname,'.',sec{1},'.ncf'];

    % Read TSTEP, LAY, ROW, COL dimension coordinates
    tstep = ncread(input_nc_file, 'TSTEP');
    lay   = ncread(input_nc_file, 'LAY');
    row   = ncread(input_nc_file, 'ROW');
    col   = ncread(input_nc_file, 'COL');

    % Read species names and units from Excel file
    [~, ~, xls_data] = xlsread(xls_file, 'Sheet1');
    species_names = xls_data(2:75, 1);
    species_units = xls_data(2:75, 2);

    % Create a new NetCDF file
    ncid = netcdf.create(output_nc_file, 'CLASSIC_MODEL');

    % Create varlist
    varlist = repmat(' ', 1, 16 * numel(species_names));
    for v = 1:numel(species_names)
        [~, nstr] = size(species_names{v});
        varlist((v-1)*16+1:(v-1)*16+nstr) = species_names{v};
    end

    % Add TSTEP, LAY, ROW, COL dimensions
    dim_tstep = netcdf.defDim(ncid, 'TSTEP', netcdf.getConstant('UNLIMITED'));
    dim_date  = netcdf.defDim(ncid, 'DATE_TIME', 2);
    dim_lay   = netcdf.defDim(ncid, 'LAY', numel(lay));
    dim_var   = netcdf.defDim(ncid, 'VAR', numel(species_names));
    dim_row   = netcdf.defDim(ncid, 'ROW', numel(row));
    dim_col   = netcdf.defDim(ncid, 'COL', numel(col));

    % Write global attributes
    varid = netcdf.getConstant('NC_GLOBAL');
    global_atts = {'IOAPI_VERSION', 'EXEC_ID', 'FTYPE', 'CDATE', 'CTIME', 'WDATE', 'WTIME', 'SDATE', 'STIME', 'TSTEP', 'NTHIK', ...
        'NCOLS', 'NROWS', 'NLAYS', 'NVARS', 'GDTYP', 'P_ALP', 'P_BET', 'P_GAM', 'XCENT', 'YCENT', 'XORIG', 'YORIG', 'XCELL', ...
        'YCELL', 'VGTYP', 'VGTOP', 'VGLVLS', 'GDNAM', 'UPNAM', 'VAR-LIST', 'FILEDESC', 'HISTORY'};
    for i = 1:numel(global_atts)
        att_name = global_atts{i};
        att_value = ncreadatt(gridfile, '/', att_name);
        
        if strcmp(att_name, 'SDATE')
            att_value = int32(2010001);
        elseif strcmp(att_name, 'TSTEP')
            att_value = int32(10000);
        elseif strcmp(att_name, 'NVARS')
            att_value = int32(numel(species_names));
        elseif strcmp(att_name, 'VAR-LIST')
            att_value = varlist;
        end
        
        netcdf.putAtt(ncid, varid, att_name, att_value);
    end

    % Create TFLAG variable
    varid = netcdf.defVar(ncid, 'TFLAG', 'NC_INT', [dim_date, dim_var, dim_tstep]);
    netcdf.putAtt(ncid, varid, 'units', '<YYYYDDD,HHMMSS>');
    netcdf.putAtt(ncid, varid, 'long_name', 'TFLAG');
    netcdf.putAtt(ncid, varid, 'var_desc', 'Timestep-valid flags:  (1) YYYYDDD or (2) HHMMSS');

    % Add emis variables
    for i = 1:numel(species_names)
        varid = netcdf.defVar(ncid, species_names{i}, 'NC_FLOAT', [dim_col, dim_row, dim_lay, dim_tstep]);
        netcdf.putAtt(ncid, varid, 'long_name', species_names{i});
        netcdf.putAtt(ncid, varid, 'units', species_units{i});
        netcdf.putAtt(ncid, varid, 'var_desc', species_names{i});
    end

    netcdf.endDef(ncid);
    netcdf.close(ncid);

    % Read existing NetCDF file
    info = ncinfo(input_nc_file);

    % Read emis variable information and data
    emis_vars = {info.Variables.Name};
    emis_data = cell(1, numel(emis_vars));
    for i = 1:numel(emis_vars)
        emis_data{i} = ncread(input_nc_file, emis_vars{i});
    end

    % Remove dimension variables
    emis_vars(1:4) = [];
    emis_data(1:4) = [];

    % Create and write TFLAG data
    tflag = zeros(2, numel(species_names), 12);
    tflag(1, :, :) = 2010001;
    for i = 1:12
        tflag(2, :, i) = (i - 1) * 10000;
    end
    tflag = int32(tflag);
    ncwrite(output_nc_file, 'TFLAG', tflag);

    % Write variable data
    for i = 1:numel(emis_vars)
        ncwrite(output_nc_file, species_names{i}, emis_data{i});
    end

    disp(['Processing ',sec{1}]);
end
disp('Completed');
