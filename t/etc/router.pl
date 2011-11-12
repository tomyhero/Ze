return router {
    submapper('/', {controller => 'Root'})
        ->connect('', {action => 'index'})
        ->connect('ja', {action => 'ja'})
        ->connect('test', {action => 'test'});
};
