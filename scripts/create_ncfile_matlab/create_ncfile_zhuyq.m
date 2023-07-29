clear


%% 地理位置文件
gridcrofile='I:\CMAQ_PRE\mcip\EA_zyq\EA36EA_230_200\GRIDCRO2D_2013141.nc';
gridtag='_d01';
% get nlon from gridcrofile
nlon=ncread(gridcrofile,'LON');
[nx,ny]=size(nlon);
nlay=11;

%% Excle文件读取变量名称以及单位类型
% create variables
[type,var]=xlsread('I:\GFED\GFED_SAPRC07.xlsx',1,'J2:K79');
species=var';
% 垂直层的分配
vert_fac=[0.25,0.03,0.12,0.1,0.05,0.1,0.08,0.06,0.08,0.1,0.04];
vertical_levels=[1.0, 0.995, 0.992, 0.98, 0.96, 0.95, 0.93, 0.91, 0.89, 0.85, 0.80, 0.75];
vertical_levels=single(vertical_levels);
%% input file
for i=1:123
    sdate=120+i;
    inputfile=['I:\GFED\output\GFED_2013',num2str(sdate),'.nc'];

    %% CMAQ文件
    gdnam='EA36EA';
    % sdate=120+21; % 如果要加循环，这里还要再算
    tnam=['2013',num2str(sdate)];
    % tnam='2013141'; % 添加日期
    outfile=['GFED_',gdnam,'_',tnam,'.ncf'];

    % create varlist
    [~,nvar]=size(species);
    varlist(16*nvar)=' ';
    varlist(:)=' ';
    for v=1:nvar
        [~,nstr]=size(species{v});
        varlist((v-1)*16+1:(v-1)*16+nstr)=species{v};
    end

    %   set netcdf file parameters
    ncid=netcdf.create(outfile,'CLASSIC_MODEL');
    dimid1=netcdf.defDim(ncid,'TSTEP',netcdf.getConstant('UNLIMITED'));
    dimid2=netcdf.defDim(ncid,'DATE-TIME',2);
    dimid3=netcdf.defDim(ncid,'LAY',nlay);
    dimid4=netcdf.defDim(ncid,'VAR',nvar);
    dimid5=netcdf.defDim(ncid,'ROW',ny);
    dimid6=netcdf.defDim(ncid,'COL',nx);

    % write global attribut
    varid=netcdf.getConstant('NC_GLOBAL');
    netcdf.putAtt(ncid,varid,'IOAPI_VERSION',ncreadatt(gridcrofile,'/','IOAPI_VERSION'));
    netcdf.putAtt(ncid,varid,'EXEC_ID',ncreadatt(gridcrofile,'/','EXEC_ID'));
    netcdf.putAtt(ncid,varid,'FTYPE',ncreadatt(gridcrofile,'/','FTYPE'));
    netcdf.putAtt(ncid,varid,'CDATE',ncreadatt(gridcrofile,'/','CDATE'));
    netcdf.putAtt(ncid,varid,'CTIME',ncreadatt(gridcrofile,'/','CTIME'));
    netcdf.putAtt(ncid,varid,'WDATE',ncreadatt(gridcrofile,'/','WDATE'));
    netcdf.putAtt(ncid,varid,'WTIME',ncreadatt(gridcrofile,'/','WTIME'));
    netcdf.putAtt(ncid,varid,'SDATE',int32(str2num(tnam)));
    netcdf.putAtt(ncid,varid,'STIME',ncreadatt(gridcrofile,'/','STIME'));
    netcdf.putAtt(ncid,varid,'TSTEP',int32(10000));
    netcdf.putAtt(ncid,varid,'NTHIK',ncreadatt(gridcrofile,'/','NTHIK'));
    netcdf.putAtt(ncid,varid,'NCOLS',ncreadatt(gridcrofile,'/','NCOLS'));
    netcdf.putAtt(ncid,varid,'NROWS',ncreadatt(gridcrofile,'/','NROWS'));
    netcdf.putAtt(ncid,varid,'NLAYS',int32(nlay));
    netcdf.putAtt(ncid,varid,'NVARS',int32(nvar));
    netcdf.putAtt(ncid,varid,'GDTYP',ncreadatt(gridcrofile,'/','GDTYP'));
    netcdf.putAtt(ncid,varid,'P_ALP',ncreadatt(gridcrofile,'/','P_ALP'));
    netcdf.putAtt(ncid,varid,'P_BET',ncreadatt(gridcrofile,'/','P_BET'));
    netcdf.putAtt(ncid,varid,'P_GAM',ncreadatt(gridcrofile,'/','P_GAM'));
    netcdf.putAtt(ncid,varid,'XCENT',ncreadatt(gridcrofile,'/','XCENT'));
    netcdf.putAtt(ncid,varid,'YCENT',ncreadatt(gridcrofile,'/','YCENT'));
    netcdf.putAtt(ncid,varid,'XORIG',ncreadatt(gridcrofile,'/','XORIG'));
    netcdf.putAtt(ncid,varid,'YORIG',ncreadatt(gridcrofile,'/','YORIG'));
    netcdf.putAtt(ncid,varid,'XCELL',ncreadatt(gridcrofile,'/','XCELL'));
    netcdf.putAtt(ncid,varid,'YCELL',ncreadatt(gridcrofile,'/','YCELL'));
    netcdf.putAtt(ncid,varid,'VGTYP',ncreadatt(gridcrofile,'/','VGTYP'));
    netcdf.putAtt(ncid,varid,'VGTOP',ncreadatt(gridcrofile,'/','VGTOP'));
    % netcdf.putAtt(ncid,varid,'VGLVLS',ncreadatt(gridcrofile,'/','VGLVLS'));
    netcdf.putAtt(ncid, varid, 'VGLVLS', vertical_levels);
    
    netcdf.putAtt(ncid,varid,'GDNAM',ncreadatt(gridcrofile,'/','GDNAM'));
    netcdf.putAtt(ncid,varid,'UPNAM',ncreadatt(gridcrofile,'/','UPNAM'));
    netcdf.putAtt(ncid,varid,'VAR-LIST',varlist);
    netcdf.putAtt(ncid,varid,'FILEDESC',ncreadatt(gridcrofile,'/','FILEDESC'));
    netcdf.putAtt(ncid,varid,'HISTORY',ncreadatt(gridcrofile,'/','HISTORY'));

    %% TFLAG
    varid=netcdf.defVar(ncid,'TFLAG','NC_INT',[dimid2,dimid4,dimid1]);
    netcdf.putAtt(ncid,varid,'units','<YYYYDDD,HHMMSS>');
    netcdf.putAtt(ncid,varid,'long_name','TFLAG           ');
    netcdf.putAtt(ncid,varid,'var_desc','Timestep-valid flags:  (1) YYYYDDD or (2) HHMMSS                                ');


    %% 填写变量
    s1=0;
    for v=1:nvar
        if type(v)==1
            s1=s1 + 1;
        end
    end
    % gas
    for v=1:s1
        varid=netcdf.defVar(ncid,species{v},'NC_FLOAT',[dimid6,dimid5,dimid3,dimid1]);
        netcdf.putAtt(ncid,varid,'long_name',species{v});
        netcdf.putAtt(ncid,varid,'units','moles/s');
        netcdf.putAtt(ncid,varid,'var_desc',species{v});

    end
% PM
    for v=s1+1:nvar  
        varid=netcdf.defVar(ncid,species{v},'NC_FLOAT',[dimid6,dimid5,dimid3,dimid1]);
        netcdf.putAtt(ncid,varid,'long_name',species{v});
        netcdf.putAtt(ncid,varid,'units','g/s');
        netcdf.putAtt(ncid,varid,'var_desc',species{v});

    end

    netcdf.close(ncid);

    sdata=['2013',num2str(sdate)];
    sdata=str2num(sdata);
    tflag(2,nvar,25)=0;
    tflag(1,:,1:24)=sdata;
    tflag(1,:,25)=sdata+1;
    for tt=1:24
        tflag(2,:,tt)=(tt-1)*10000;
    end
    tflag(2,:,25)=0;
    tflag=int32(tflag);
    ncwrite(outfile,'TFLAG',tflag);

    for v=1:nvar
        new_var=genvarname(species{v}); % 设置变量名
        var_00=ncread(inputfile,species{v});
        var_11(nx,ny,nlay,25)=0;
        for k=1:nlay
            var_11(:,:,k,:)=var_00*vert_fac(k);
        end
        ncwrite(outfile,species{v},var_11);
        % new_var=ncread(inputfile,species{v});
        % ncwrite(outfile,species{v},new_var);
    end
end