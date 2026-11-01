function [model,audit]=create_geometry_from_scratch(cfg)
% DOC_CONFIRMED COMSOL5.6 Rectangle; PENDING runtime. Existing connection only.
% cfg: authorized, size[1x2], position[1x2], lengthUnit. No physical defaults.
assert(isequal(cfg.authorized,true),'Workflow:Authorization','Geometry creation not authorized.');
assert(numel(cfg.size)==2 && all(isfinite(cfg.size)) && all(cfg.size>0));
assert(numel(cfg.position)==2 && all(isfinite(cfg.position)));
model=javaMethod('createUnique','com.comsol.model.util.ModelUtil','research_');
c=model.component().create('comp1',true);
g=c.geom().create('geom1',2);g.lengthUnit(cfg.lengthUnit);
g.create('rect1','Rectangle');g.feature('rect1').set('size',cfg.size);
g.feature('rect1').set('pos',cfg.position);g.run();
audit=struct('tag',char(model.tag()),'status','BUILT_UNVALIDATED');
% Inspect actual dimensions/entities/selections before material/physics work.
end
