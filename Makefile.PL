use inc::Module::Install;
name 'Ze';
all_from 'lib/Ze.pm';


#git@github.com:tomyhero/p5-App-Home.git

requires (
    'Module::Install::AuthorTests' => 0, # App::Home
    'Test::Base' => 0, # App::Home
    'Mouse' => 0,
    'Plack' => 0,
    'Path::Class' => 0,
);


test_requires(
    'Test::LoadAllModules' => 0,
);



tests 't/*.t';

build_requires 'Test::More';
auto_include;
WriteAll;
