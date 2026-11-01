function cfg=model_config()
% PENDING runtime. All editable numerical inputs are SI. Defaults defined once.
cfg.model_name='Parameterized rectangle';
cfg.geometry.L=1.0;  % Independent span [m], default 1.0, strictly positive.
cfg.geometry.h=0.05; % Independent height [m], default 0.05, strictly positive.
cfg.geometry.x0=0;   % Independent left coordinate [m], default 0, finite.
cfg.geometry.y0=0;   % Independent bottom coordinate [m], default 0, finite.
cfg.validation.area_tol=1e-9; % Numerical relative tolerance [1], default 1e-9, >0.
cfg.validation.bbox_tol=1e-9; % Numerical absolute tolerance [m], default 1e-9, >0.
% Metadata only; values are resolved from the paths, not duplicated.
cfg.meta=[entry('geometry.L','L','Span','m','independent',0,false,'geometry,mesh,study,results'), ...
 entry('geometry.h','h','Height','m','independent',0,false,'geometry,mesh,study,results'), ...
 entry('geometry.x0','x0','Left position','m','independent',-Inf,true,'geometry,selections,mesh,study,results'), ...
 entry('geometry.y0','y0','Bottom position','m','independent',-Inf,true,'geometry,selections,mesh,study,results'), ...
 entry('validation.area_tol','tol_area','Area tolerance','1','numerical',0,false,'validation'), ...
 entry('validation.bbox_tol','tol_bbox','Coordinate tolerance','m','numerical',0,false,'validation')];
end
function p=entry(path,name,description,unit,type,lower,inclusive,effect)
p=struct('path',path,'name',name,'description',description,'unit',unit,'type',type, ...
 'lower',lower,'upper',Inf,'lower_inclusive',inclusive,'dependency','','effect',effect);
end
