package Ze::WAF::Plugin::Profiler;
use Ze::Role;
use Time::HiRes qw(gettimeofday tv_interval );

has '__Profiler_tool' => ( is => 'rw');

before 'BUILD' => sub {
    my $c = shift;
    my $tool = Ze::WAF::Profiler::Tool->new();
    $tool->parent($c);
    $c->__Profiler_tool($tool);
    $tool->begin_method('BUILD');
};

before ['dispatch','INITIALIZE','FINALIZE','PREPARE','RENDER','FINALIZE'] => sub {
    my $c = shift;
    my @caller = caller(1);
    my ($method) = $caller[3] =~ m/::([^:]+)$/;
    my $tool = $c->__Profiler_tool;
    $tool->begin_method($method);

};

after ['dispatch','INITIALIZE','FINALIZE','PREPARE','RENDER','FINALIZE'] => sub {
    my $c = shift;
    my @caller = caller(1);
    my ($method) = $caller[3] =~ m/::([^:]+)$/;
    my $tool = $c->__Profiler_tool;
    $tool->end_method($method);
};

after 'dispatch' => sub {
    my $c = shift;
    my $tool = $c->__Profiler_tool;
    $tool->notice_context();

};


1;
