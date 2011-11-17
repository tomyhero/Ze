package Ze::Class;
use Mouse();
use Mouse::Exporter;
use utf8;

Mouse::Exporter->setup_import_methods(
    as_is => ['EOC'],
    also => ['Mouse'],
);

sub init_meta { utf8->import(); }


sub EOC {
    Mouse->unimport();
    caller->meta->make_immutable();
    return 1;
}


1;

=head1 NAME

Ze::Class - this is Mouse 

=cut
