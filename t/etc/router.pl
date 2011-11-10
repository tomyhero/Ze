return router {
    submapper('/', {controller => 'Root'})
        ->connect('', {action => 'index'})
        ->connect('test', {action => 'test'});
};
