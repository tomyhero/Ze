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
    'JSON::XS' => 0,
    'Encode::JavaScript::UCS' => 0,
    'Text::Xslate' => 0,
    'Class::Data::Inheritable' => 0,
    'Router::Simple' => 0,
    'String::Random' => 0,
    'HTML::FillInForm::Lite' => 0,
    'Devel::Size' => 0,
    'Text::SimpleTable' => 0,
    'Term::Size::Any' => 0, # remocmend..
    'Term::ANSIColor' => 0,
);


test_requires(
    'Test::LoadAllModules' => 0,
);


tests_recursive;

build_requires 'Test::More';
auto_include;
WriteAll;
