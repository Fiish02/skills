function audit=parameterized_geometry(model,cfg)
% DOC_CONFIRMED COMSOL5.6 Polygon; PENDING runtime. New feature on owned model.
% cfg: authorized, componentTag, geometryTag, featureTag, xy[Nx2].
assert(isequal(cfg.authorized,true),'Workflow:Authorization','Not authorized.');
xy=cfg.xy;
assert(size(xy,2)==2 && size(xy,1)>=3 && all(isfinite(xy(:))));
% Caller must validate contour self-intersection, units, closure and sampling.
g=model.component(cfg.componentTag).geom(cfg.geometryTag);
existingTags=cellfun(@char,cell(g.feature().tags()),'UniformOutput',false);
assert(~any(strcmp(existingTags,cfg.featureTag)), ...
    'Workflow:ExistingFeature','Do not overwrite a geometry feature.');
g.create(cfg.featureTag,'Polygon');p=g.feature(cfg.featureTag);
p.set('source','vectors');p.set('x',xy(:,1).');p.set('y',xy(:,2).');p.set('type','solid');
g.run();
audit=struct('status','BUILT_UNVALIDATED','feature',cfg.featureTag);
% This is a 2D contour, not a validated ABH/3D geometry recipe.
end
