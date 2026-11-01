function audit = physics_and_boundary_conditions(model, componentTag, physicsTag, featureTag, property, approvedValue, authorized)
% DOC_VERIFIED: physics feature.set / PropFeature.getString 5.6.
% RUNTIME_NOT_TESTED. Only a previously inspected STRING property is handled.
% Do not infer interface types, feature types, boundary IDs or property names.
assert(isequal(authorized,true),'Workflow:Authorization','Physics change must be authorized.');
assert(ischar(approvedValue),'Workflow:Type','This example handles scalar string properties only.');
feature = model.component(componentTag).physics(physicsTag).feature(featureTag);
before = char(feature.getString(property)); % Fails before mutation for incompatible properties.
audit = struct('component',componentTag,'physics',physicsTag,'feature',featureTag, ...
    'property',property,'before',before,'after',approvedValue);
feature.set(property,approvedValue);
% The feature's existing selection is preserved. Any selection change needs
% a separately reviewed mapping from actual entities to the physical boundary.
end
