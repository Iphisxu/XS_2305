function [ outfile ] = create_ncfile_mcip( gridcrofile,etype )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

% set ncid
gdnam=ncreadatt(gridcrofile,'/','GDNAM');
outfile=['../output/emis.',gdnam(1:5),'.',etype,'.ncf'];

% xlsfile
xlsfile='emis_fraction.xlsx';

% create variables
ingas={'NO2','NO','HONO','CO','SO2','SULF','NH3'};
[~,nin]=size(ingas);
[~,vocgas]=xlsread(xlsfile,'SAPRC-07TIC','b3:b48');
vocgas=vocgas';
[~,nvoc]=size(vocgas);
pmpm={'PSO4','PNO3','PCL','PNH4','PNA','PMG','PK','PCA','POC','PNCOM','PEC','PFE','PAL','PSI','PTI','PMN','PH2O','PMOTHR','PMC'};
[~,npm]=size(pmpm);
halogas={'HCL','CL2'};
[~,nha]=size(halogas);
species=[ingas,vocgas,pmpm,halogas];
[~,nspes]=size(species);

% get nlon from gridcrofile
nlon=ncread(gridcrofile,'LON');
[nx,ny]=size(nlon);
nlay=1;
[~,nvar]=size(species);
ntimes=12;

% create varlist
varlist(16*nvar)=' ';
varlist(:)=' ';
for i=1:nvar
    [~,nstr]=size(species{i});
    varlist((i-1)*16+1:(i-1)*16+nstr)=species{i};
end

%   set netcdf file parameters
ncid=netcdf.create(outfile,'CLASSIC_MODEL');
dimid1=netcdf.defDim(ncid,'TSTEP',netcdf.getConstant('UNLIMITED'));
dimid2=netcdf.defDim(ncid,'DATE-TIME',2);
dimid3=netcdf.defDim(ncid,'LAY',nlay);
dimid4=netcdf.defDim(ncid,'VAR',nvar);
dimid5=netcdf.defDim(ncid,'ROW',ny);
dimid6=netcdf.defDim(ncid,'COL',nx);

% write global attribute
varid=netcdf.getConstant('NC_GLOBAL');
netcdf.putAtt(ncid,varid,'IOAPI_VERSION',ncreadatt(gridcrofile,'/','IOAPI_VERSION'));
netcdf.putAtt(ncid,varid,'EXEC_ID',ncreadatt(gridcrofile,'/','EXEC_ID'));
netcdf.putAtt(ncid,varid,'FTYPE',ncreadatt(gridcrofile,'/','FTYPE'));
netcdf.putAtt(ncid,varid,'CDATE',ncreadatt(gridcrofile,'/','CDATE'));
netcdf.putAtt(ncid,varid,'CTIME',ncreadatt(gridcrofile,'/','CTIME'));
netcdf.putAtt(ncid,varid,'WDATE',ncreadatt(gridcrofile,'/','WDATE'));
netcdf.putAtt(ncid,varid,'WTIME',ncreadatt(gridcrofile,'/','WTIME'));
netcdf.putAtt(ncid,varid,'SDATE',int32(2010001));
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
netcdf.putAtt(ncid,varid,'VGLVLS',ncreadatt(gridcrofile,'/','VGLVLS'));
netcdf.putAtt(ncid,varid,'GDNAM',ncreadatt(gridcrofile,'/','GDNAM'));
netcdf.putAtt(ncid,varid,'UPNAM',ncreadatt(gridcrofile,'/','UPNAM'));
netcdf.putAtt(ncid,varid,'VAR-LIST',varlist);
netcdf.putAtt(ncid,varid,'FILEDESC',ncreadatt(gridcrofile,'/','FILEDESC'));
netcdf.putAtt(ncid,varid,'HISTORY',ncreadatt(gridcrofile,'/','HISTORY'));

%% TFLAG
varid=netcdf.defVar(ncid,'TFLAG','NC_INT',[dimid2,dimid4,dimid1]);
netcdf.putAtt(ncid,varid,'units','<YYYYDDD,HHMMSS>');
netcdf.putAtt(ncid,varid,'long_name','FLAG           ');
netcdf.putAtt(ncid,varid,'var_desc','Timestep-valid flags:  (1) YYYYDDD or (2) HHMMSS                                ');

%% inorganic gas
for i=1:nin
    varid=netcdf.defVar(ncid,ingas{i},'NC_FLOAT',[dimid6,dimid5,dimid3,dimid1]);
    netcdf.putAtt(ncid,varid,'long_name',ingas{i});
    netcdf.putAtt(ncid,varid,'units','10**6 moles/mon');
    netcdf.putAtt(ncid,varid,'var_desc',ingas{i});
end

%% voc gas
for i=1:nvoc
    varid=netcdf.defVar(ncid,vocgas{i},'NC_FLOAT',[dimid6,dimid5,dimid3,dimid1]);
    netcdf.putAtt(ncid,varid,'long_name',vocgas{i});
    netcdf.putAtt(ncid,varid,'units','10**6 moles/mon');
    netcdf.putAtt(ncid,varid,'var_desc',vocgas{i});
end

%% pm matter
for i=1:npm
    varid=netcdf.defVar(ncid,pmpm{i},'NC_FLOAT',[dimid6,dimid5,dimid3,dimid1]);
    netcdf.putAtt(ncid,varid,'long_name',pmpm{i});
    netcdf.putAtt(ncid,varid,'units','10**6 g/mon');
    netcdf.putAtt(ncid,varid,'var_desc',pmpm{i});
end

%% halogen gas
for i=1:nha
    varid=netcdf.defVar(ncid,halogas{i},'NC_FLOAT',[dimid6,dimid5,dimid3,dimid1]);
    netcdf.putAtt(ncid,varid,'long_name',halogas{i});
    netcdf.putAtt(ncid,varid,'units','10**6 moles/mon');
    netcdf.putAtt(ncid,varid,'var_desc',halogas{i});
end

netcdf.close(ncid);

%% save emis data
tflag(2,nvar,ntimes)=0;
tflag(1,:,:)=2010001;
for i=1:ntimes
    tflag(2,:,i)=(i-1)*10000;
end
tflag=int32(tflag);
ncwrite(outfile,'TFLAG',tflag);

data(nx,ny,nlay,ntimes)=0;
data(:)=0;
data=single(data);
for i=1:nspes
    eval(['ncwrite(outfile,''',species{i},''',data);']);
end

end

