function audit = geometry_and_mesh(model, componentTag, geometryTag, meshTag, authorized)
% DOC_VERIFIED: model.geom()/model.mesh() 5.6. RUNTIME_NOT_TESTED.
% Rebuild existing, previously inspected sequences without changing strategy.
assert(isequal(authorized,true),'Workflow:Authorization','Rebuild must be authorized.');
c = model.component(componentTag);
g = c.geom(geometryTag);
m = c.mesh(meshTag);
audit = struct('component',componentTag,'geometry',geometryTag,'mesh',meshTag);
g.run();
m.run();
% Recheck entity selections/material coverage/mesh quality before solving.
end
