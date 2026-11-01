function audit = study_and_solver(model, mode, tag, authorized)
% DOC_VERIFIED: model.study()/model.sol() 5.6. RUNTIME_NOT_TESTED.
% Choose the already approved sequence; never fall back to a different mode.
assert(isequal(authorized,true),'Workflow:Authorization','Solve must be authorized.');
audit = struct('mode',mode,'tag',tag,'validation','NOT TESTED');
switch mode
    case 'existing-study-solver'
        model.study(tag).runNoGen();
    case 'existing-solver'
        model.sol(tag).runAll();
    case 'study-with-generation'
        model.study(tag).run();
    otherwise
        error('Workflow:Mode','Select a documented, explicitly approved execution mode.');
end
% Returning normally is not proof of convergence or numerical acceptance.
end
