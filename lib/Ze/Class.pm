package Ze::Class;
use Mouse();
use Mouse::Exporter;
use utf8;

Mouse::Exporter->setup_import_methods(
    as_is => ['END_OF_CLASS'],
    also => ['Mouse'],
);

sub init_meta { utf8->import(); }


sub END_OF_CLASS {
    Mouse->unimport();
    caller->meta->make_immutable();
    return 1;
}


1;
