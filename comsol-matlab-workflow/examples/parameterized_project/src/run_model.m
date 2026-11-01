function runDir=run_model(projectRoot)
% PENDING / RUNTIME_NOT_TESTED. Existing LiveLink only. Geometry-only example.
% Copy project outside the Skill folder; edit config/model_config.m only.
if nargin==0,projectRoot=fileparts(fileparts(mfilename('fullpath')));end
id=[char(datetime('now','Format','yyyyMMdd_HHmmss_SSS')) '_' strrep(char(java.util.UUID.randomUUID()),'-','')];
runDir=fullfile(projectRoot,'output',['run_' id]);assert(~isfolder(runDir));mkdir(runDir);
mkdir(fullfile(runDir,'source'));mkdir(fullfile(runDir,'logs'));
configSource=fullfile(projectRoot,'config','model_config.m');assert(isfile(configSource));
copyfile(configSource,fullfile(runDir,'source','model_config.m'));
copyfile([mfilename('fullpath') '.m'],fullfile(runDir,'source','run_model.m'));
oldPath=path;pc=onCleanup(@()path(oldPath));addpath(fullfile(runDir,'source'),'-begin');
assert(strcmpi(which('model_config'),fullfile(runDir,'source','model_config.m')));
state=struct('status','RUNNING','stage','configuration');cfg=struct();derived=struct();sync=[];tag='';
oldDiary=get(0,'Diary');oldFile=get(0,'DiaryFile');diary(fullfile(runDir,'logs','matlab_execution.log'));
dc=onCleanup(@()restore_diary(oldDiary,oldFile));
try
 cfg=model_config();catalog=cfg.meta;
 for k=1:numel(catalog)
  p=catalog(k);key=strsplit(p.path,'.');v=cfg.(key{1}).(key{2});
  assert(isnumeric(v)&&isscalar(v)&&isreal(v)&&isfinite(v),'Parameters:Type','Invalid %s',p.path);
  assert(v<=p.upper && ((p.lower_inclusive&&v>=p.lower)||(~p.lower_inclusive&&v>p.lower)),'Parameters:Range','Invalid range %s',p.path);
  assert(any(strcmp(p.unit,{'m','1'})),'Parameters:Unit','Explicit SI conversion required.');
 end
 derived=struct('area',cfg.geometry.L*cfg.geometry.h,'unit','m^2','type','derived','formula','L*h','dependency','geometry.L,geometry.h');
 assert(isfinite(derived.area)&&derived.area>0,'Parameters:Derived','Derived area must be finite and positive.');
 snapshot=struct('model_name',cfg.model_name,'model_tag',tag,'source',configSource,'cfg',cfg, ...
  'derived',derived,'matlab_version',version,'comsol_version','NOT TESTED','run_utc',utc_now(), ...
  'geometry_discretization','NOT APPLICABLE: analytic Rectangle','validation',cfg.validation,'parameter_sync',sync);
 snapshot.configuration_snapshot=fullfile(runDir,'source','model_config.m');
 fid=fopen(fullfile(runDir,'README.md'),'w','n','UTF-8');assert(fid>=0);rc=onCleanup(@()fclose(fid));
 fprintf(fid,'%s',strjoin({'# Actual run parameter table',['Edit only: ' configSource], ...
  ['Run: run_model(''' projectRoot ''')'], ...
  'Geometry changes regenerate the unique rectangle; this example has no mesh or solve.', ...
  'Derived Aref=L*h is computed automatically, not an editable independent input.', ...
  '|Parameter|Description|Value|Unit|Type|Range|Dependency|Effect|', ...
  '|---|---|---:|---|---|---|---|---|'},newline));fprintf(fid,'%s',newline);
 for k=1:numel(catalog)
  p=catalog(k);key=strsplit(p.path,'.');v=cfg.(key{1}).(key{2});
  fprintf(fid,['|%s|%s|%.17g|%s|%s|%g to %g (lower inclusive=%d)|%s|%s|' newline], ...
   p.name,p.description,v,p.unit,p.type,p.lower,p.upper,p.lower_inclusive,p.dependency,p.effect);
 end
 clear rc
 jsonfile(fullfile(runDir,'parameters.json'),snapshot);
 state.stage='connection';assert(strcmp(version('-release'),'2023a'));
 assert(strcmpi(matlabroot,'D:Program FilesMATLABR2023a'));
 javaMethod('tags','com.comsol.model.util.ModelUtil');cv=char(mphversion);assert(contains(cv,'5.6')&&contains(cv,'280'));
 model=javaMethod('createUnique','com.comsol.model.util.ModelUtil','Parameterized_');tag=char(model.tag());model.label(cfg.model_name);
 snapshot.model_tag=tag;snapshot.comsol_version=cv;state.stage='sync';
 sync=struct('name',{},'expression',{},'stored_expression',{},'evaluated_si',{},'source',{});
 for k=1:numel(catalog)
  p=catalog(k);key=strsplit(p.path,'.');v=cfg.(key{1}).(key{2});
  if strcmp(p.unit,'1'),expr=sprintf('%.17g',v);else,expr=sprintf('%.17g[%s]',v,p.unit);end
  model.param().set(p.name,expr);stored=char(model.param().get(p.name));actual=double(model.param().evaluate(p.name));
  assert(strcmp(stored,expr)&&isfinite(actual)&&abs(actual-v)<=64*eps(max(1,abs(v))),'Parameters:Mismatch','Sync mismatch: %s',p.name);
  sync(k)=struct('name',p.name,'expression',expr,'stored_expression',stored,'evaluated_si',actual,'source',p.path);
 end
 model.param().set('Aref',derived.formula);assert(abs(double(model.param().evaluate('Aref'))-derived.area)<=64*eps(max(1,derived.area)));
 snapshot.parameter_sync=sync;jsonfile(fullfile(runDir,'parameters.json'),snapshot);
 state.stage='geometry';comp=model.component().create('comp1',true);g=comp.geom().create('geom1',2);g.lengthUnit('m');
 g.create('rect1','Rectangle');rect=g.feature('rect1');rect.set('base','corner');rect.set('size',{'L','h'});rect.set('pos',{'x0','y0'});g.run();
 state.stage='actual_geometry_validation';assert(g.getSDim()==2&&g.getNDomains()==1&&g.getNBoundaries()==4&&g.getNVertices()==4);
 xy=zeros(4,2);for k=1:4,c=double(mphgetcoords(model,'geom1','point',k));assert(numel(c)==2);xy(k,:)=c(:).';end
 center=mean(xy,1);[~,idx]=sort(atan2(xy(:,2)-center(2),xy(:,1)-center(1)));q=xy(idx,:);n=q([2:end 1],:);
 area=abs(sum(q(:,1).*n(:,2)-n(:,1).*q(:,2)))/2;
 bbox=double(g.getBoundingBox());expected=[cfg.geometry.x0 cfg.geometry.x0+cfg.geometry.L cfg.geometry.y0 cfg.geometry.y0+cfg.geometry.h];
 assert(all(isfinite(xy(:)))&&all(abs(bbox(:).'-expected)<cfg.validation.bbox_tol));
 assert(abs(area-derived.area)/derived.area<cfg.validation.area_tol);
 measurement=g.measureFinal();measurement.selection().geom('geom1',2);measurement.selection().set(1);nativeArea=double(measurement.getVolume());
 state.metrics=struct('coordinate_area',area,'native_area',nativeArea,'native_relative_error',abs(nativeArea-derived.area)/derived.area,'bbox',bbox);
 state.stage='exports';fig=figure('Visible','off');fc=onCleanup(@()close(fig));ax=axes('Parent',fig);
 mphgeom(model,'geom1','build','on','parent',ax);axis(ax,'equal');xlabel(ax,'X (m)');ylabel(ax,'Y (m)');
 exportgraphics(fig,fullfile(runDir,'geometry.png'));clear fc
 mphsave(model,fullfile(runDir,'model.mph'));
 fid=fopen(fullfile(runDir,'geometry.csv'),'w','n','UTF-8');assert(fid>=0);cc=onCleanup(@()fclose(fid));
 fprintf(fid,'x_m,y_m%s',newline);fprintf(fid,['%.17g,%.17g' newline],xy.');clear cc
 snapshot.completed_utc=utc_now();snapshot.actual_geometry=state.metrics;jsonfile(fullfile(runDir,'parameters.json'),snapshot);
 state.status='COMPLETED_UNVALIDATED';state.stage='finished';jsonfile(fullfile(runDir,'run_status.json'),state);
 fid=fopen(fullfile(runDir,'report.md'),'w','n','UTF-8');assert(fid>=0);cc=onCleanup(@()fclose(fid));
 fprintf(fid,'%s',strjoin({'# Parameterized Rectangle','COMPLETED_UNVALIDATED: external artifact review required.', ...
  ['Configuration: ' configSource],['Model: ' tag],['Coordinate area: ' num2str(area,17)], ...
  ['Native area relative error (not certified): ' num2str(state.metrics.native_relative_error,17)],'Actual parameters: parameters.json'},newline));clear cc
catch ME
 state.status='FAIL';state.error=getReport(ME,'extended','hyperlinks','off');jsonfile(fullfile(runDir,'run_status.json'),state);
 jsonfile(fullfile(runDir,'failure_parameters.json'),struct('cfg',cfg,'derived',derived,'model_tag',tag,'sync',sync));
 fid=fopen(fullfile(runDir,'logs','matlab_error.txt'),'w','n','UTF-8');if fid>=0,fprintf(fid,'%s',state.error);fclose(fid);end
 rethrow(ME);
end
end
function jsonfile(file,value)
fid=fopen(file,'w','n','UTF-8');assert(fid>=0);c=onCleanup(@()fclose(fid));fprintf(fid,'%s',jsonencode(json_safe(value),'PrettyPrint',true));
end
function t=utc_now()
t=char(datetime('now','TimeZone','UTC','Format',"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"));
end
function restore_diary(s,file)
diary off
if strcmp(s,'on'),diary(file);end
end

function value=json_safe(value)
% Preserve explicit unbounded metadata rather than jsonencode silently making null.
if isstruct(value)
 names=fieldnames(value);
 for k=1:numel(value),for j=1:numel(names),value(k).(names{j})=json_safe(value(k).(names{j}));end,end
elseif iscell(value)
 for k=1:numel(value),value{k}=json_safe(value{k});end
elseif isnumeric(value)&&isscalar(value)&&~isfinite(value)
 value=num2str(value);
end
end
