
package Ze::Helper::Zplon;
use strict;
use warnings;
use base 'Module::Setup::Flavor';
1;

=head1

Ze::Helper::Zplon - pack from Ze::Helper::Zplon

=head1 SYNOPSIS

  Ze::Helper::Zplon-setup --init --flavor-class=+Ze::Helper::Zplon new_flavor

=cut

__DATA__

---
file: .gitignore
template: |
  cover_db
  META.yml
  Makefile
  blib
  inc
  pm_to_blib
  MANIFEST
  Makefile.old
  nytprof.out
  MANIFEST.bak
  *.sw[po]
  var
  *.DS_Store
  .carton
  MYMETA.json
  MYMETA.yml
  view-include/component
---
file: .proverc
template: |
  "--exec=perl -Ilib -I. -Mt::Util"
  --color
  -Pt::lib::App::Prove::Plugin::SchemaUpdater
---
file: Makefile.PL
template: |
  use inc::Module::Install;
  name '[% dist %]';
  all_from 'lib/[% module_unix_path %].pm';
  
  requires (
      'Ze' => '0.02',
      'Ukigumo::Client' => 0,
      'Plack::Middleware::ReverseProxy' => 0,
      'Aplon' => 0,
      'FormValidator::LazyWay' => 0,
      'YAML::Syck' => 0,
      'Data::Section::Simple' => 0,
      'DBI' => 0,
      'DBD::mysql' => 0,
      'Data::ObjectDriver' => 0,
      'List::Util'=>0,
      'Class::Singleton' => 0,
      'Cache::Memcached::IronPlate' => 0,
      'Cache::Memcached::Fast' => 0,
      'Devel::KYTProf'  => 0,
      'List::MoreUtils' => 0,
      'Data::Page' => 0,
      'Data::Page::Navigation' => 0,
      'URI::QueryParam' => 0,
      'Text::SimpleTable' => 0,
      'HTTP::Parser::XS' => 0,
      'FindBin::libs' => 0,
  );
  
  
  test_requires(
      'Test::LoadAllModules' => 0,
      'Test::TCP' => 0,
      'Proc::Guard' => 0,
      'Test::Output' => 0,
  );
  
  
  tests_recursive;
  
  build_requires 'Test::More';
  auto_include;
  WriteAll;
---
file: README
template: |
  * 準備
  
  - ./bin/devel/install.sh で依存モジュールをいれます。locallib等を利用したい場合は、ソースを手直しする必要があります。
  - [% dist | upper %]_ENV を指定してください。指定しない場合、後で述べますがsetup.sh で local を指定します。
  - [% dist | upper %]_ENVにlocal以外を指定した場合、etc/config_local.pl の ファイル名のlocal 部分を指定した名前に変更してください
  - mysqlを準備し、etc/config_local.pl 内の接続情報を更新(Databaseは作成しなくていいです)。
  - memcachedサーバを準備し、etc/config_local.pl 内の設定をお更新
  - ./bin/devel/setup.sh を実行し、環境変数設定と、データベース作成をおこなう
  - prove -lr t を実行しテストが通るか確認する
  - plackup etc/mix.psgi を実行しこのページが見えてるか確認してみる。
---
file: bin/filegenerator.pl
template: |+
  #!/usr/bin/env perl
  
  use strict;
  use warnings;
  use FindBin::libs ;
  use [% dist %]::FileGenerator;
  
  [% dist %]::FileGenerator->run();
  

---
file: bin/devel/install.sh
template: |
  #!/bin/sh
  
  install_ext() {
      if [ -e ~/work/$2 ]
      then
          cd ~/work/$2
          git pull
          cpanm --mirror ftp://ftp.kddilabs.jp/CPAN/ .
      else
          git clone $1 ~/work/$2
          cd ~/work/$2
          cpanm --mirror ftp://ftp.kddilabs.jp/CPAN/ .
      fi
  }
  
  cpanm --mirror ftp://ftp.kddilabs.jp/CPAN/ Module::Install
  cpanm --mirror ftp://ftp.kddilabs.jp/CPAN/ Module::Install::Repository
  
  install_ext git://github.com/tomyhero/p5-App-Home.git p5-App-Home
  install_ext git://github.com/tomyhero/Ze.git Ze
  install_ext git://github.com/tomyhero/p5-Aplon.git p5-Aplon
  install_ext git://github.com/kazeburo/Cache-Memcached-IronPlate.git Cache-Memcached-IronPlate
  install_ext git://github.com/onishi/perl5-devel-kytprof.git Devel-KYTProf
  
  
  
  cpanm --mirror ftp://ftp.kddilabs.jp/CPAN/ --installdeps .
---
file: bin/devel/setup.sh
template: |+
  #!/bin/bash
  
  
  APP_HOME='.'
  MYRC=$HOME/.`basename $SHELL`rc
  DATABASE_NAME=[% dist | lower %]_${[% dist | upper %]_ENV}
  
  
  if [ ! -f $APP_HOME/bin/devel/setup.sh ]; then
      echo 'you must excute this script from application home directory!! like a ./bin/devel/setup.sh'
      exit(0);
  fi
  
  
  
  #* 環境変数
  if [ ! $[% dist | upper %]_ENV ];then
  echo "export [% dist | upper %]_ENV=local" >> $MYRC
  source $MYRC
  fi
  
  
  
  HAS_DB=`echo 'show databases' | mysql -u root | grep $DATABASE_NAME | wc -l`
  
  if [ $HAS_DB == 1 ]
  then
      echo 'HAS database'
  else
      mysqladmin -u root create $DATABASE_NAME
      mysql -u root $DATABASE_NAME < $APP_HOME/misc/[% dist | lower %].sql
  fi
  
  

---
file: bin/devel/ukigumo-client.pl
template: |
  #!/usr/bin/env perl
  
  eval 'exec /usr/bin/env perl  -S $0 ${1+"$@"}'
      if 0; # not running under some shell
  use strict;
  use warnings;
  use utf8;
  use 5.008008;
  use File::Spec;
  use File::Basename;
  use lib File::Spec->catdir(dirname(__FILE__), '..', 'extlib', 'lib', 'perl5');
  use lib File::Spec->catdir(dirname(__FILE__), '..', 'lib');
  
  package main;
  use Getopt::Long;
  use Pod::Usage;
  
  use Ukigumo::Client;
  use Ukigumo::Client::VC::Git;
  use Ukigumo::Client::Executor::Auto;
  use Ukigumo::Client::Notify::Debug;
  use Ukigumo::Client::Notify::Ikachan;
  use Ukigumo::Constants;
  use Ukigumo::Client::Executor::Callback;
  
  GetOptions(
      'branch=s'          => \my $branch,
      'workdir=s'         => \my $workdir,
      'repo=s'            => \my $repo,
      'ikachan_url=s'     => \my $ikachan_url,
      'ikachan_channel=s' => \my $ikachan_channel,
      'server_url=s'      => \my $server_url,
      'project=s'         => \my $project,
  );
  $repo       or do { warn "Missing mandatory option: --repo\n\n"; pod2usage() };
  $server_url or do { warn "Missing mandatory option: --server_url\n\n"; pod2usage() };
  $branch='master' unless $branch;
  die "Bad branch name: $branch" unless $branch =~ m{^[A-Za-z0-9./_-]+$}; # guard from web
  $server_url =~ s!/$!! if defined $server_url;
  
  my $app = Ukigumo::Client->new(
      (defined($workdir) ? (workdir => $workdir) : ()),
      vc   => Ukigumo::Client::VC::Git->new(
          branch     => $branch,
          repository => $repo,
      ),
      executor => Ukigumo::Client::Executor::Callback->new(
          run_cb => sub {
              my $c = shift;
              $c->tee("prove -lr t")==0 ? STATUS_SUCCESS : STATUS_FAIL;
          }
      ),
      server_url => $server_url,
      ($project ? (project    => $project) : ()),
  );
  #$app->push_notifier( Ukigumo::Client::Notify::Debug->new());
  if ($ikachan_url) {
      if (!$ikachan_channel) {
          warn "You specified ikachan_url but ikachan_channel is not provided\n\n";
          pod2usage();
      }
      $app->push_notifier(
          Ukigumo::Client::Notify::Ikachan->new(
              url     => $ikachan_url,
              channel => $ikachan_channel,
          )
      );
  }
  $app->run();
  exit 0;
  
  __END__
  
  =head1 NAME
  
  ukigumo-client.pl - ukigumo client script
  
  =head1 SYNOPSIS
  
      % ukigumo-client.pl --repo=git://...
      % ukigumo-client.pl --repo=git://... --branch foo
  
          --repo=s            URL for git repository
          --workdir=s         workdir directory for working(optional)
          --branch=s          branch name('master' by default)
          --server_url=s      Ukigumo server url(using app.psgi)
          --ikachan_url=s     API endpoint URL for ikachan
          --ikachan_channel=s channel to post message
  
  =head1 DESCRIPTION
  
  This is a yet another continuous testing tools.
  
  =head1 EXAMPLE
  
      perl bin/ukigumo-client.pl --server_url=http://localhost:9044/ --repo=git://github.com/tokuhirom/Acme-Failing.git --branch=master
  
  Or use online demo.
  
      perl bin/ukigumo-client.pl --server_url=http://ukigumo-4z7a3pfx.dotcloud.com/ --repo=git://github.com/tokuhirom/Acme-Failing.git
  
  =head1 SEE ALSO
  
  L<https://github.com/yappo/p5-App-Ikachan>
  
  =cut
---
file: etc/api.psgi
template: |+
  use strict;
  use FindBin::libs;
  
  use Plack::Builder;
  use [% dist %]::API;
  use [% dist %]::Home;
  use [% dist %]::Validator;
  use [% dist %]::Config;
  
  
  [% dist %]::Validator->instance(); # compile
  my $home = [% dist %]::Home->get;
  
  my $webapp = [% dist %]::API->new;
  
  my $app = $webapp->to_app;
  
  my $config = [% dist %]::Config->instance();
  my $middlewares = $config->get('middleware') || {};
  
  if($middlewares){
      $middlewares = $middlewares->{api} || [];
  }
  
  
  builder {
      enable 'Plack::Middleware::Static',
          path => qr{^/static/}, root => $home->file('htdocs');
  
      enable_if { $_[0]->{REMOTE_ADDR} eq '127.0.0.1' } 
      "Plack::Middleware::ReverseProxy";
  
      for(@$middlewares){
          if($_->{opts}){
              enable $_->{name},%{$_->{opts}};
          }
          else {
              enable $_->{name};
          }
      }
  
      $app;
  };

---
file: etc/config.pl
template: |
  +{
      debug => 1,
      middleware => {
          pc => [
              {
                  name => 'StackTrace',
              },
  #            {
  #                name => 'ServerStatus::Lite',
  #                opts => {
  #                    path => '/___server-status',
  #                    allow => [ '127.0.0.1','10.0.0.0/8'],
  #                    sc[% dist | lower %]oard => '/var/run/server',
  #                },
  #            },
  #            {
  #                name => "ErrorDocument",
  #                opts => {
  #                    500 => $home->file('htdocs-static/pc/doc/500.html'),
  #                    502 => $home->file('htdocs-static/pc/doc/500.html')
  #                },
  #            },
              {
                  name => 'HTTPExceptions',
              },
          ],
      },
      cookie_session => {
          namespace => '[% dist | lower %]_session',
      },
  };
---
file: etc/config_local.pl
template: |
  +{
      cache => {
          servers => [ '127.0.0.1:11211' ],
      },
      cache_session => {
          servers => [ '127.0.0.1:11211' ],
      },
      database => {
          master => {
              dsn => "dbi:mysql:[% dist | lower %]_local",
              username => "dev_master",
              password => "oreb",
          },
          slaves => [
              {
                  dsn => "dbi:mysql:[% dist | lower %]_local",
                  username => "dev_slave",
                  password => "oreb",
              }
          ],
      },
  };
---
file: etc/mix.psgi
template: |
  use strict;
  use warnings;
  use FindBin::libs;
  use Plack::App::URLMap;
  use Plack::Util ;
  
  use [% dist %]::Home;
  my $home = [% dist %]::Home->get;
  
  my $pc = Plack::Util::load_psgi( $home->file('etc/pc.psgi'));
  my $api = Plack::Util::load_psgi( $home->file('etc/api.psgi'));
  
  my $urlmap = Plack::App::URLMap->new;
  $urlmap->map("/" => $pc);
  $urlmap->map("/api" => $api);
  
  $urlmap->to_app;
---
file: etc/pc.psgi
template: |+
  use strict;
  use FindBin::libs;
  
  use Plack::Builder;
  use [% dist %]::PC;
  use [% dist %]::Home;
  use [% dist %]::Validator;
  use [% dist %]::Config;
  
  
  [% dist %]::Validator->instance(); # compile
  my $home = [% dist %]::Home->get;
  
  my $webapp = [% dist %]::PC->new;
  
  my $app = $webapp->to_app;
  
  my $config = [% dist %]::Config->instance();
  my $middlewares = $config->get('middleware') || {};
  
  if($middlewares){
      $middlewares = $middlewares->{pc} || [];
  }
  
  
  builder {
      enable 'Plack::Middleware::Static',
          path => sub { s!^/static/!! }, 
          root => $home->file('htdocs')
      ;
  
      enable_if { $_[0]->{REMOTE_ADDR} eq '127.0.0.1' } 
      "Plack::Middleware::ReverseProxy";
  
      for(@$middlewares){
          if($_->{opts}){
              enable $_->{name},%{$_->{opts}};
          }
          else {
              enable $_->{name};
          }
      }
  
      $app;
  };

---
file: etc/router-api.pl
template: |2
  
  return router {
      submapper('/', {controller => 'Root'})
          ->connect('me', {action => 'me' }) 
          ;
  
  };
---
file: etc/router-pc.pl
template: |2
  
  return router {
      submapper('/', {controller => 'Root'})
          ->connect('', {action => 'index' }) 
          ;
  
  };
---
file: htdocs/common/css/bootstrap.min.css
template: |
  html,body{margin:0;padding:0;}
  h1,h2,h3,h4,h5,h6,p,blockquote,pre,a,abbr,acronym,address,cite,code,del,dfn,em,img,q,s,samp,small,strike,strong,sub,sup,tt,var,dd,dl,dt,li,ol,ul,fieldset,form,label,legend,button,table,caption,tbody,tfoot,thead,tr,th,td{margin:0;padding:0;border:0;font-weight:normal;font-style:normal;font-size:100%;line-height:1;font-family:inherit;}
  table{border-collapse:collapse;border-spacing:0;}
  ol,ul{list-style:none;}
  q:before,q:after,blockquote:before,blockquote:after{content:"";}
  html{overflow-y:scroll;font-size:100%;-webkit-text-size-adjust:100%;-ms-text-size-adjust:100%;}
  a:focus{outline:thin dotted;}
  a:hover,a:active{outline:0;}
  article,aside,details,figcaption,figure,footer,header,hgroup,nav,section{display:block;}
  audio,canvas,video{display:inline-block;*display:inline;*zoom:1;}
  audio:not([controls]){display:none;}
  sub,sup{font-size:75%;line-height:0;position:relative;vertical-align:baseline;}
  sup{top:-0.5em;}
  sub{bottom:-0.25em;}
  img{border:0;-ms-interpolation-mode:bicubic;}
  button,input,select,textarea{font-size:100%;margin:0;vertical-align:baseline;*vertical-align:middle;}
  button,input{line-height:normal;*overflow:visible;}
  button::-moz-focus-inner,input::-moz-focus-inner{border:0;padding:0;}
  button,input[type="button"],input[type="reset"],input[type="submit"]{cursor:pointer;-webkit-appearance:button;}
  input[type="search"]{-webkit-appearance:textfield;-webkit-box-sizing:content-box;-moz-box-sizing:content-box;box-sizing:content-box;}
  input[type="search"]::-webkit-search-decoration{-webkit-appearance:none;}
  textarea{overflow:auto;vertical-align:top;}
  body{background-color:#ffffff;margin:0;font-family:"Helvetica Neue",Helvetica,Arial,sans-serif;font-size:13px;font-weight:normal;line-height:18px;color:#404040;}
  .container{width:940px;margin-left:auto;margin-right:auto;zoom:1;}.container:before,.container:after{display:table;content:"";zoom:1;}
  .container:after{clear:both;}
  .container-fluid{position:relative;min-width:940px;padding-left:20px;padding-right:20px;zoom:1;}.container-fluid:before,.container-fluid:after{display:table;content:"";zoom:1;}
  .container-fluid:after{clear:both;}
  .container-fluid>.sidebar{position:absolute;top:0;left:20px;width:220px;}
  .container-fluid>.content{margin-left:240px;}
  a{color:#0069d6;text-decoration:none;line-height:inherit;font-weight:inherit;}a:hover{color:#00438a;text-decoration:underline;}
  .pull-right{float:right;}
  .pull-left{float:left;}
  .hide{display:none;}
  .show{display:block;}
  .row{zoom:1;margin-left:-20px;}.row:before,.row:after{display:table;content:"";zoom:1;}
  .row:after{clear:both;}
  .row>[class*="span"]{display:inline;float:left;margin-left:20px;}
  .span1{width:40px;}
  .span2{width:100px;}
  .span3{width:160px;}
  .span4{width:220px;}
  .span5{width:280px;}
  .span6{width:340px;}
  .span7{width:400px;}
  .span8{width:460px;}
  .span9{width:520px;}
  .span10{width:580px;}
  .span11{width:640px;}
  .span12{width:700px;}
  .span13{width:760px;}
  .span14{width:820px;}
  .span15{width:880px;}
  .span16{width:940px;}
  .span17{width:1000px;}
  .span18{width:1060px;}
  .span19{width:1120px;}
  .span20{width:1180px;}
  .span21{width:1240px;}
  .span22{width:1300px;}
  .span23{width:1360px;}
  .span24{width:1420px;}
  .row>.offset1{margin-left:80px;}
  .row>.offset2{margin-left:140px;}
  .row>.offset3{margin-left:200px;}
  .row>.offset4{margin-left:260px;}
  .row>.offset5{margin-left:320px;}
  .row>.offset6{margin-left:380px;}
  .row>.offset7{margin-left:440px;}
  .row>.offset8{margin-left:500px;}
  .row>.offset9{margin-left:560px;}
  .row>.offset10{margin-left:620px;}
  .row>.offset11{margin-left:680px;}
  .row>.offset12{margin-left:740px;}
  .span-one-third{width:300px;}
  .span-two-thirds{width:620px;}
  .row>.offset-one-third{margin-left:340px;}
  .row>.offset-two-thirds{margin-left:660px;}
  p{font-size:13px;font-weight:normal;line-height:18px;margin-bottom:9px;}p small{font-size:11px;color:#bfbfbf;}
  h1,h2,h3,h4,h5,h6{font-weight:bold;color:#404040;}h1 small,h2 small,h3 small,h4 small,h5 small,h6 small{color:#bfbfbf;}
  h1{margin-bottom:18px;font-size:30px;line-height:36px;}h1 small{font-size:18px;}
  h2{font-size:24px;line-height:36px;}h2 small{font-size:14px;}
  h3,h4,h5,h6{line-height:36px;}
  h3{font-size:18px;}h3 small{font-size:14px;}
  h4{font-size:16px;}h4 small{font-size:12px;}
  h5{font-size:14px;}
  h6{font-size:13px;color:#bfbfbf;text-transform:uppercase;}
  ul,ol{margin:0 0 18px 25px;}
  ul ul,ul ol,ol ol,ol ul{margin-bottom:0;}
  ul{list-style:disc;}
  ol{list-style:decimal;}
  li{line-height:18px;color:#808080;}
  ul.unstyled{list-style:none;margin-left:0;}
  dl{margin-bottom:18px;}dl dt,dl dd{line-height:18px;}
  dl dt{font-weight:bold;}
  dl dd{margin-left:9px;}
  hr{margin:20px 0 19px;border:0;border-bottom:1px solid #eee;}
  strong{font-style:inherit;font-weight:bold;}
  em{font-style:italic;font-weight:inherit;line-height:inherit;}
  .muted{color:#bfbfbf;}
  blockquote{margin-bottom:18px;border-left:5px solid #eee;padding-left:15px;}blockquote p{font-size:14px;font-weight:300;line-height:18px;margin-bottom:0;}
  blockquote small{display:block;font-size:12px;font-weight:300;line-height:18px;color:#bfbfbf;}blockquote small:before{content:'\2014 \00A0';}
  address{display:block;line-height:18px;margin-bottom:18px;}
  code,pre{padding:0 3px 2px;font-family:Monaco, Andale Mono, Courier New, monospace;font-size:12px;-webkit-border-radius:3px;-moz-border-radius:3px;border-radius:3px;}
  code{background-color:#fee9cc;color:rgba(0, 0, 0, 0.75);padding:1px 3px;}
  pre{background-color:#f5f5f5;display:block;padding:8.5px;margin:0 0 18px;line-height:18px;font-size:12px;border:1px solid #ccc;border:1px solid rgba(0, 0, 0, 0.15);-webkit-border-radius:3px;-moz-border-radius:3px;border-radius:3px;white-space:pre;white-space:pre-wrap;word-wrap:break-word;}
  form{margin-bottom:18px;}
  fieldset{margin-bottom:18px;padding-top:18px;}fieldset legend{display:block;padding-left:150px;font-size:19.5px;line-height:1;color:#404040;*padding:0 0 5px 145px;*line-height:1.5;}
  form .clearfix{margin-bottom:18px;zoom:1;}form .clearfix:before,form .clearfix:after{display:table;content:"";zoom:1;}
  form .clearfix:after{clear:both;}
  label,input,select,textarea{font-family:"Helvetica Neue",Helvetica,Arial,sans-serif;font-size:13px;font-weight:normal;line-height:normal;}
  label{padding-top:6px;font-size:13px;line-height:18px;float:left;width:130px;text-align:right;color:#404040;}
  form .input{margin-left:150px;}
  input[type=checkbox],input[type=radio]{cursor:pointer;}
  input,textarea,select,.uneditable-input{display:inline-block;width:210px;height:18px;padding:4px;font-size:13px;line-height:18px;color:#808080;border:1px solid #ccc;-webkit-border-radius:3px;-moz-border-radius:3px;border-radius:3px;}
  select{padding:initial;}
  input[type=checkbox],input[type=radio]{width:auto;height:auto;padding:0;margin:3px 0;*margin-top:0;line-height:normal;border:none;}
  input[type=file]{background-color:#ffffff;padding:initial;border:initial;line-height:initial;-webkit-box-shadow:none;-moz-box-shadow:none;box-shadow:none;}
  input[type=button],input[type=reset],input[type=submit]{width:auto;height:auto;}
  select,input[type=file]{height:27px;*height:auto;line-height:27px;*margin-top:4px;}
  select[multiple]{height:inherit;background-color:#ffffff;}
  textarea{height:auto;}
  .uneditable-input{background-color:#ffffff;display:block;border-color:#eee;-webkit-box-shadow:inset 0 1px 2px rgba(0, 0, 0, 0.025);-moz-box-shadow:inset 0 1px 2px rgba(0, 0, 0, 0.025);box-shadow:inset 0 1px 2px rgba(0, 0, 0, 0.025);cursor:not-allowed;}
  :-moz-placeholder{color:#bfbfbf;}
  ::-webkit-input-placeholder{color:#bfbfbf;}
  input,textarea{-webkit-transition:border linear 0.2s,box-shadow linear 0.2s;-moz-transition:border linear 0.2s,box-shadow linear 0.2s;-ms-transition:border linear 0.2s,box-shadow linear 0.2s;-o-transition:border linear 0.2s,box-shadow linear 0.2s;transition:border linear 0.2s,box-shadow linear 0.2s;-webkit-box-shadow:inset 0 1px 3px rgba(0, 0, 0, 0.1);-moz-box-shadow:inset 0 1px 3px rgba(0, 0, 0, 0.1);box-shadow:inset 0 1px 3px rgba(0, 0, 0, 0.1);}
  input:focus,textarea:focus{outline:0;border-color:rgba(82, 168, 236, 0.8);-webkit-box-shadow:inset 0 1px 3px rgba(0, 0, 0, 0.1),0 0 8px rgba(82, 168, 236, 0.6);-moz-box-shadow:inset 0 1px 3px rgba(0, 0, 0, 0.1),0 0 8px rgba(82, 168, 236, 0.6);box-shadow:inset 0 1px 3px rgba(0, 0, 0, 0.1),0 0 8px rgba(82, 168, 236, 0.6);}
  input[type=file]:focus,input[type=checkbox]:focus,select:focus{-webkit-box-shadow:none;-moz-box-shadow:none;box-shadow:none;outline:1px dotted #666;}
  form .clearfix.error>label,form .clearfix.error .help-block,form .clearfix.error .help-inline{color:#b94a48;}
  form .clearfix.error input,form .clearfix.error textarea{color:#b94a48;border-color:#ee5f5b;}form .clearfix.error input:focus,form .clearfix.error textarea:focus{border-color:#e9322d;-webkit-box-shadow:0 0 6px #f8b9b7;-moz-box-shadow:0 0 6px #f8b9b7;box-shadow:0 0 6px #f8b9b7;}
  form .clearfix.error .input-prepend .add-on,form .clearfix.error .input-append .add-on{color:#b94a48;background-color:#fce6e6;border-color:#b94a48;}
  form .clearfix.warning>label,form .clearfix.warning .help-block,form .clearfix.warning .help-inline{color:#c09853;}
  form .clearfix.warning input,form .clearfix.warning textarea{color:#c09853;border-color:#ccae64;}form .clearfix.warning input:focus,form .clearfix.warning textarea:focus{border-color:#be9a3f;-webkit-box-shadow:0 0 6px #e5d6b1;-moz-box-shadow:0 0 6px #e5d6b1;box-shadow:0 0 6px #e5d6b1;}
  form .clearfix.warning .input-prepend .add-on,form .clearfix.warning .input-append .add-on{color:#c09853;background-color:#d2b877;border-color:#c09853;}
  form .clearfix.success>label,form .clearfix.success .help-block,form .clearfix.success .help-inline{color:#468847;}
  form .clearfix.success input,form .clearfix.success textarea{color:#468847;border-color:#57a957;}form .clearfix.success input:focus,form .clearfix.success textarea:focus{border-color:#458845;-webkit-box-shadow:0 0 6px #9acc9a;-moz-box-shadow:0 0 6px #9acc9a;box-shadow:0 0 6px #9acc9a;}
  form .clearfix.success .input-prepend .add-on,form .clearfix.success .input-append .add-on{color:#468847;background-color:#bcddbc;border-color:#468847;}
  .input-mini,input.mini,textarea.mini,select.mini{width:60px;}
  .input-small,input.small,textarea.small,select.small{width:90px;}
  .input-medium,input.medium,textarea.medium,select.medium{width:150px;}
  .input-large,input.large,textarea.large,select.large{width:210px;}
  .input-xlarge,input.xlarge,textarea.xlarge,select.xlarge{width:270px;}
  .input-xxlarge,input.xxlarge,textarea.xxlarge,select.xxlarge{width:530px;}
  textarea.xxlarge{overflow-y:auto;}
  input.span1,textarea.span1{display:inline-block;float:none;width:30px;margin-left:0;}
  input.span2,textarea.span2{display:inline-block;float:none;width:90px;margin-left:0;}
  input.span3,textarea.span3{display:inline-block;float:none;width:150px;margin-left:0;}
  input.span4,textarea.span4{display:inline-block;float:none;width:210px;margin-left:0;}
  input.span5,textarea.span5{display:inline-block;float:none;width:270px;margin-left:0;}
  input.span6,textarea.span6{display:inline-block;float:none;width:330px;margin-left:0;}
  input.span7,textarea.span7{display:inline-block;float:none;width:390px;margin-left:0;}
  input.span8,textarea.span8{display:inline-block;float:none;width:450px;margin-left:0;}
  input.span9,textarea.span9{display:inline-block;float:none;width:510px;margin-left:0;}
  input.span10,textarea.span10{display:inline-block;float:none;width:570px;margin-left:0;}
  input.span11,textarea.span11{display:inline-block;float:none;width:630px;margin-left:0;}
  input.span12,textarea.span12{display:inline-block;float:none;width:690px;margin-left:0;}
  input.span13,textarea.span13{display:inline-block;float:none;width:750px;margin-left:0;}
  input.span14,textarea.span14{display:inline-block;float:none;width:810px;margin-left:0;}
  input.span15,textarea.span15{display:inline-block;float:none;width:870px;margin-left:0;}
  input.span16,textarea.span16{display:inline-block;float:none;width:930px;margin-left:0;}
  input[disabled],select[disabled],textarea[disabled],input[readonly],select[readonly],textarea[readonly]{background-color:#f5f5f5;border-color:#ddd;cursor:not-allowed;}
  .actions{background:#f5f5f5;margin-top:18px;margin-bottom:18px;padding:17px 20px 18px 150px;border-top:1px solid #ddd;-webkit-border-radius:0 0 3px 3px;-moz-border-radius:0 0 3px 3px;border-radius:0 0 3px 3px;}.actions .secondary-action{float:right;}.actions .secondary-action a{line-height:30px;}.actions .secondary-action a:hover{text-decoration:underline;}
  .help-inline,.help-block{font-size:13px;line-height:18px;color:#bfbfbf;}
  .help-inline{padding-left:5px;*position:relative;*top:-5px;}
  .help-block{display:block;max-width:600px;}
  .inline-inputs{color:#808080;}.inline-inputs span{padding:0 2px 0 1px;}
  .input-prepend input,.input-append input{-webkit-border-radius:0 3px 3px 0;-moz-border-radius:0 3px 3px 0;border-radius:0 3px 3px 0;}
  .input-prepend .add-on,.input-append .add-on{position:relative;background:#f5f5f5;border:1px solid #ccc;z-index:2;float:left;display:block;width:auto;min-width:16px;height:18px;padding:4px 4px 4px 5px;margin-right:-1px;font-weight:normal;line-height:18px;color:#bfbfbf;text-align:center;text-shadow:0 1px 0 #ffffff;-webkit-border-radius:3px 0 0 3px;-moz-border-radius:3px 0 0 3px;border-radius:3px 0 0 3px;}
  .input-prepend .active,.input-append .active{background:#a9dba9;border-color:#46a546;}
  .input-prepend .add-on{*margin-top:1px;}
  .input-append input{float:left;-webkit-border-radius:3px 0 0 3px;-moz-border-radius:3px 0 0 3px;border-radius:3px 0 0 3px;}
  .input-append .add-on{-webkit-border-radius:0 3px 3px 0;-moz-border-radius:0 3px 3px 0;border-radius:0 3px 3px 0;margin-right:0;margin-left:-1px;}
  .inputs-list{margin:0 0 5px;width:100%;}.inputs-list li{display:block;padding:0;width:100%;}
  .inputs-list label{display:block;float:none;width:auto;padding:0;margin-left:20px;line-height:18px;text-align:left;white-space:normal;}.inputs-list label strong{color:#808080;}
  .inputs-list label small{font-size:11px;font-weight:normal;}
  .inputs-list .inputs-list{margin-left:25px;margin-bottom:10px;padding-top:0;}
  .inputs-list:first-child{padding-top:6px;}
  .inputs-list li+li{padding-top:2px;}
  .inputs-list input[type=radio],.inputs-list input[type=checkbox]{margin-bottom:0;margin-left:-20px;float:left;}
  .form-stacked{padding-left:20px;}.form-stacked fieldset{padding-top:9px;}
  .form-stacked legend{padding-left:0;}
  .form-stacked label{display:block;float:none;width:auto;font-weight:bold;text-align:left;line-height:20px;padding-top:0;}
  .form-stacked .clearfix{margin-bottom:9px;}.form-stacked .clearfix div.input{margin-left:0;}
  .form-stacked .inputs-list{margin-bottom:0;}.form-stacked .inputs-list li{padding-top:0;}.form-stacked .inputs-list li label{font-weight:normal;padding-top:0;}
  .form-stacked div.clearfix.error{padding-top:10px;padding-bottom:10px;padding-left:10px;margin-top:0;margin-left:-10px;}
  .form-stacked .actions{margin-left:-20px;padding-left:20px;}
  table{width:100%;margin-bottom:18px;padding:0;font-size:13px;border-collapse:collapse;}table th,table td{padding:10px 10px 9px;line-height:18px;text-align:left;}
  table th{padding-top:9px;font-weight:bold;vertical-align:middle;}
  table td{vertical-align:top;border-top:1px solid #ddd;}
  table tbody th{border-top:1px solid #ddd;vertical-align:top;}
  .condensed-table th,.condensed-table td{padding:5px 5px 4px;}
  .bordered-table{border:1px solid #ddd;border-collapse:separate;*border-collapse:collapse;-webkit-border-radius:4px;-moz-border-radius:4px;border-radius:4px;}.bordered-table th+th,.bordered-table td+td,.bordered-table th+td{border-left:1px solid #ddd;}
  .bordered-table thead tr:first-child th:first-child,.bordered-table tbody tr:first-child td:first-child{-webkit-border-radius:4px 0 0 0;-moz-border-radius:4px 0 0 0;border-radius:4px 0 0 0;}
  .bordered-table thead tr:first-child th:last-child,.bordered-table tbody tr:first-child td:last-child{-webkit-border-radius:0 4px 0 0;-moz-border-radius:0 4px 0 0;border-radius:0 4px 0 0;}
  .bordered-table tbody tr:last-child td:first-child{-webkit-border-radius:0 0 0 4px;-moz-border-radius:0 0 0 4px;border-radius:0 0 0 4px;}
  .bordered-table tbody tr:last-child td:last-child{-webkit-border-radius:0 0 4px 0;-moz-border-radius:0 0 4px 0;border-radius:0 0 4px 0;}
  table .span1{width:20px;}
  table .span2{width:60px;}
  table .span3{width:100px;}
  table .span4{width:140px;}
  table .span5{width:180px;}
  table .span6{width:220px;}
  table .span7{width:260px;}
  table .span8{width:300px;}
  table .span9{width:340px;}
  table .span10{width:380px;}
  table .span11{width:420px;}
  table .span12{width:460px;}
  table .span13{width:500px;}
  table .span14{width:540px;}
  table .span15{width:580px;}
  table .span16{width:620px;}
  .zebra-striped tbody tr:nth-child(odd) td,.zebra-striped tbody tr:nth-child(odd) th{background-color:#f9f9f9;}
  .zebra-striped tbody tr:hover td,.zebra-striped tbody tr:hover th{background-color:#f5f5f5;}
  table .header{cursor:pointer;}table .header:after{content:"";float:right;margin-top:7px;border-width:0 4px 4px;border-style:solid;border-color:#000 transparent;visibility:hidden;}
  table .headerSortUp,table .headerSortDown{background-color:rgba(141, 192, 219, 0.25);text-shadow:0 1px 1px rgba(255, 255, 255, 0.75);}
  table .header:hover:after{visibility:visible;}
  table .headerSortDown:after,table .headerSortDown:hover:after{visibility:visible;filter:alpha(opacity=60);-khtml-opacity:0.6;-moz-opacity:0.6;opacity:0.6;}
  table .headerSortUp:after{border-bottom:none;border-left:4px solid transparent;border-right:4px solid transparent;border-top:4px solid #000;visibility:visible;-webkit-box-shadow:none;-moz-box-shadow:none;box-shadow:none;filter:alpha(opacity=60);-khtml-opacity:0.6;-moz-opacity:0.6;opacity:0.6;}
  table .blue{color:#049cdb;border-bottom-color:#049cdb;}
  table .headerSortUp.blue,table .headerSortDown.blue{background-color:#ade6fe;}
  table .green{color:#46a546;border-bottom-color:#46a546;}
  table .headerSortUp.green,table .headerSortDown.green{background-color:#cdeacd;}
  table .red{color:#9d261d;border-bottom-color:#9d261d;}
  table .headerSortUp.red,table .headerSortDown.red{background-color:#f4c8c5;}
  table .yellow{color:#ffc40d;border-bottom-color:#ffc40d;}
  table .headerSortUp.yellow,table .headerSortDown.yellow{background-color:#fff6d9;}
  table .orange{color:#f89406;border-bottom-color:#f89406;}
  table .headerSortUp.orange,table .headerSortDown.orange{background-color:#fee9cc;}
  table .purple{color:#7a43b6;border-bottom-color:#7a43b6;}
  table .headerSortUp.purple,table .headerSortDown.purple{background-color:#e2d5f0;}
  .topbar{height:40px;position:fixed;top:0;left:0;right:0;z-index:10000;overflow:visible;}.topbar a{color:#bfbfbf;text-shadow:0 -1px 0 rgba(0, 0, 0, 0.25);}
  .topbar h3 a:hover,.topbar .brand:hover,.topbar ul .active>a{background-color:#333;background-color:rgba(255, 255, 255, 0.05);color:#ffffff;text-decoration:none;}
  .topbar h3{position:relative;}
  .topbar h3 a,.topbar .brand{float:left;display:block;padding:8px 20px 12px;margin-left:-20px;color:#ffffff;font-size:20px;font-weight:200;line-height:1;}
  .topbar p{margin:0;line-height:40px;}.topbar p a:hover{background-color:transparent;color:#ffffff;}
  .topbar form{float:left;margin:5px 0 0 0;position:relative;filter:alpha(opacity=100);-khtml-opacity:1;-moz-opacity:1;opacity:1;}
  .topbar form.pull-right{float:right;}
  .topbar input{background-color:#444;background-color:rgba(255, 255, 255, 0.3);font-family:"Helvetica Neue",Helvetica,Arial,sans-serif;font-size:normal;font-weight:13px;line-height:1;padding:4px 9px;color:#ffffff;color:rgba(255, 255, 255, 0.75);border:1px solid #111;-webkit-border-radius:4px;-moz-border-radius:4px;border-radius:4px;-webkit-box-shadow:inset 0 1px 2px rgba(0, 0, 0, 0.1),0 1px 0px rgba(255, 255, 255, 0.25);-moz-box-shadow:inset 0 1px 2px rgba(0, 0, 0, 0.1),0 1px 0px rgba(255, 255, 255, 0.25);box-shadow:inset 0 1px 2px rgba(0, 0, 0, 0.1),0 1px 0px rgba(255, 255, 255, 0.25);-webkit-transition:none;-moz-transition:none;-ms-transition:none;-o-transition:none;transition:none;}.topbar input:-moz-placeholder{color:#e6e6e6;}
  .topbar input::-webkit-input-placeholder{color:#e6e6e6;}
  .topbar input:hover{background-color:#bfbfbf;background-color:rgba(255, 255, 255, 0.5);color:#ffffff;}
  .topbar input:focus,.topbar input.focused{outline:0;background-color:#ffffff;color:#404040;text-shadow:0 1px 0 #ffffff;border:0;padding:5px 10px;-webkit-box-shadow:0 0 3px rgba(0, 0, 0, 0.15);-moz-box-shadow:0 0 3px rgba(0, 0, 0, 0.15);box-shadow:0 0 3px rgba(0, 0, 0, 0.15);}
  .topbar-inner,.topbar .fill{background-color:#222;background-color:#222222;background-repeat:repeat-x;background-image:-khtml-gradient(linear, left top, left bottom, from(#333333), to(#222222));background-image:-moz-linear-gradient(top, #333333, #222222);background-image:-ms-linear-gradient(top, #333333, #222222);background-image:-webkit-gradient(linear, left top, left bottom, color-stop(0%, #333333), color-stop(100%, #222222));background-image:-webkit-linear-gradient(top, #333333, #222222);background-image:-o-linear-gradient(top, #333333, #222222);background-image:linear-gradient(top, #333333, #222222);filter:progid:DXImageTransform.Microsoft.gradient(startColorstr='#333333', endColorstr='#222222', GradientType=0);-webkit-box-shadow:0 1px 3px rgba(0, 0, 0, 0.25),inset 0 -1px 0 rgba(0, 0, 0, 0.1);-moz-box-shadow:0 1px 3px rgba(0, 0, 0, 0.25),inset 0 -1px 0 rgba(0, 0, 0, 0.1);box-shadow:0 1px 3px rgba(0, 0, 0, 0.25),inset 0 -1px 0 rgba(0, 0, 0, 0.1);}
  .topbar div>ul,.nav{display:block;float:left;margin:0 10px 0 0;position:relative;left:0;}.topbar div>ul>li,.nav>li{display:block;float:left;}
  .topbar div>ul a,.nav a{display:block;float:none;padding:10px 10px 11px;line-height:19px;text-decoration:none;}.topbar div>ul a:hover,.nav a:hover{color:#ffffff;text-decoration:none;}
  .topbar div>ul .active>a,.nav .active>a{background-color:#222;background-color:rgba(0, 0, 0, 0.5);}
  .topbar div>ul.secondary-nav,.nav.secondary-nav{float:right;margin-left:10px;margin-right:0;}.topbar div>ul.secondary-nav .menu-dropdown,.nav.secondary-nav .menu-dropdown,.topbar div>ul.secondary-nav .dropdown-menu,.nav.secondary-nav .dropdown-menu{right:0;border:0;}
  .topbar div>ul a.menu:hover,.nav a.menu:hover,.topbar div>ul li.open .menu,.nav li.open .menu,.topbar div>ul .dropdown-toggle:hover,.nav .dropdown-toggle:hover,.topbar div>ul .dropdown.open .dropdown-toggle,.nav .dropdown.open .dropdown-toggle{background:#444;background:rgba(255, 255, 255, 0.05);}
  .topbar div>ul .menu-dropdown,.nav .menu-dropdown,.topbar div>ul .dropdown-menu,.nav .dropdown-menu{background-color:#333;}.topbar div>ul .menu-dropdown a.menu,.nav .menu-dropdown a.menu,.topbar div>ul .dropdown-menu a.menu,.nav .dropdown-menu a.menu,.topbar div>ul .menu-dropdown .dropdown-toggle,.nav .menu-dropdown .dropdown-toggle,.topbar div>ul .dropdown-menu .dropdown-toggle,.nav .dropdown-menu .dropdown-toggle{color:#ffffff;}.topbar div>ul .menu-dropdown a.menu.open,.nav .menu-dropdown a.menu.open,.topbar div>ul .dropdown-menu a.menu.open,.nav .dropdown-menu a.menu.open,.topbar div>ul .menu-dropdown .dropdown-toggle.open,.nav .menu-dropdown .dropdown-toggle.open,.topbar div>ul .dropdown-menu .dropdown-toggle.open,.nav .dropdown-menu .dropdown-toggle.open{background:#444;background:rgba(255, 255, 255, 0.05);}
  .topbar div>ul .menu-dropdown li a,.nav .menu-dropdown li a,.topbar div>ul .dropdown-menu li a,.nav .dropdown-menu li a{color:#999;text-shadow:0 1px 0 rgba(0, 0, 0, 0.5);}.topbar div>ul .menu-dropdown li a:hover,.nav .menu-dropdown li a:hover,.topbar div>ul .dropdown-menu li a:hover,.nav .dropdown-menu li a:hover{background-color:#191919;background-repeat:repeat-x;background-image:-khtml-gradient(linear, left top, left bottom, from(#292929), to(#191919));background-image:-moz-linear-gradient(top, #292929, #191919);background-image:-ms-linear-gradient(top, #292929, #191919);background-image:-webkit-gradient(linear, left top, left bottom, color-stop(0%, #292929), color-stop(100%, #191919));background-image:-webkit-linear-gradient(top, #292929, #191919);background-image:-o-linear-gradient(top, #292929, #191919);background-image:linear-gradient(top, #292929, #191919);filter:progid:DXImageTransform.Microsoft.gradient(startColorstr='#292929', endColorstr='#191919', GradientType=0);color:#ffffff;}
  .topbar div>ul .menu-dropdown .active a,.nav .menu-dropdown .active a,.topbar div>ul .dropdown-menu .active a,.nav .dropdown-menu .active a{color:#ffffff;}
  .topbar div>ul .menu-dropdown .divider,.nav .menu-dropdown .divider,.topbar div>ul .dropdown-menu .divider,.nav .dropdown-menu .divider{background-color:#222;border-color:#444;}
  .topbar ul .menu-dropdown li a,.topbar ul .dropdown-menu li a{padding:4px 15px;}
  li.menu,.dropdown{position:relative;}
  a.menu:after,.dropdown-toggle:after{width:0;height:0;display:inline-block;content:"&darr;";text-indent:-99999px;vertical-align:top;margin-top:8px;margin-left:4px;border-left:4px solid transparent;border-right:4px solid transparent;border-top:4px solid #ffffff;filter:alpha(opacity=50);-khtml-opacity:0.5;-moz-opacity:0.5;opacity:0.5;}
  .menu-dropdown,.dropdown-menu{background-color:#ffffff;float:left;display:none;position:absolute;top:40px;z-index:900;min-width:160px;max-width:220px;_width:160px;margin-left:0;margin-right:0;padding:6px 0;zoom:1;border-color:#999;border-color:rgba(0, 0, 0, 0.2);border-style:solid;border-width:0 1px 1px;-webkit-border-radius:0 0 6px 6px;-moz-border-radius:0 0 6px 6px;border-radius:0 0 6px 6px;-webkit-box-shadow:0 2px 4px rgba(0, 0, 0, 0.2);-moz-box-shadow:0 2px 4px rgba(0, 0, 0, 0.2);box-shadow:0 2px 4px rgba(0, 0, 0, 0.2);-webkit-background-clip:padding-box;-moz-background-clip:padding-box;background-clip:padding-box;}.menu-dropdown li,.dropdown-menu li{float:none;display:block;background-color:none;}
  .menu-dropdown .divider,.dropdown-menu .divider{height:1px;margin:5px 0;overflow:hidden;background-color:#eee;border-bottom:1px solid #ffffff;}
  .topbar .dropdown-menu a,.dropdown-menu a{display:block;padding:4px 15px;clear:both;font-weight:normal;line-height:18px;color:#808080;text-shadow:0 1px 0 #ffffff;}.topbar .dropdown-menu a:hover,.dropdown-menu a:hover,.topbar .dropdown-menu a.hover,.dropdown-menu a.hover{background-color:#dddddd;background-repeat:repeat-x;background-image:-khtml-gradient(linear, left top, left bottom, from(#eeeeee), to(#dddddd));background-image:-moz-linear-gradient(top, #eeeeee, #dddddd);background-image:-ms-linear-gradient(top, #eeeeee, #dddddd);background-image:-webkit-gradient(linear, left top, left bottom, color-stop(0%, #eeeeee), color-stop(100%, #dddddd));background-image:-webkit-linear-gradient(top, #eeeeee, #dddddd);background-image:-o-linear-gradient(top, #eeeeee, #dddddd);background-image:linear-gradient(top, #eeeeee, #dddddd);filter:progid:DXImageTransform.Microsoft.gradient(startColorstr='#eeeeee', endColorstr='#dddddd', GradientType=0);color:#404040;text-decoration:none;-webkit-box-shadow:inset 0 1px 0 rgba(0, 0, 0, 0.025),inset 0 -1px rgba(0, 0, 0, 0.025);-moz-box-shadow:inset 0 1px 0 rgba(0, 0, 0, 0.025),inset 0 -1px rgba(0, 0, 0, 0.025);box-shadow:inset 0 1px 0 rgba(0, 0, 0, 0.025),inset 0 -1px rgba(0, 0, 0, 0.025);}
  .open .menu,.dropdown.open .menu,.open .dropdown-toggle,.dropdown.open .dropdown-toggle{color:#ffffff;background:#ccc;background:rgba(0, 0, 0, 0.3);}
  .open .menu-dropdown,.dropdown.open .menu-dropdown,.open .dropdown-menu,.dropdown.open .dropdown-menu{display:block;}
  .tabs,.pills{margin:0 0 18px;padding:0;list-style:none;zoom:1;}.tabs:before,.pills:before,.tabs:after,.pills:after{display:table;content:"";zoom:1;}
  .tabs:after,.pills:after{clear:both;}
  .tabs>li,.pills>li{float:left;}.tabs>li>a,.pills>li>a{display:block;}
  .tabs{border-color:#ddd;border-style:solid;border-width:0 0 1px;}.tabs>li{position:relative;margin-bottom:-1px;}.tabs>li>a{padding:0 15px;margin-right:2px;line-height:34px;border:1px solid transparent;-webkit-border-radius:4px 4px 0 0;-moz-border-radius:4px 4px 0 0;border-radius:4px 4px 0 0;}.tabs>li>a:hover{text-decoration:none;background-color:#eee;border-color:#eee #eee #ddd;}
  .tabs .active>a,.tabs .active>a:hover{color:#808080;background-color:#ffffff;border:1px solid #ddd;border-bottom-color:transparent;cursor:default;}
  .tabs .menu-dropdown,.tabs .dropdown-menu{top:35px;border-width:1px;-webkit-border-radius:0 6px 6px 6px;-moz-border-radius:0 6px 6px 6px;border-radius:0 6px 6px 6px;}
  .tabs a.menu:after,.tabs .dropdown-toggle:after{border-top-color:#999;margin-top:15px;margin-left:5px;}
  .tabs li.open.menu .menu,.tabs .open.dropdown .dropdown-toggle{border-color:#999;}
  .tabs li.open a.menu:after,.tabs .dropdown.open .dropdown-toggle:after{border-top-color:#555;}
  .pills a{margin:5px 3px 5px 0;padding:0 15px;line-height:30px;text-shadow:0 1px 1px #ffffff;-webkit-border-radius:15px;-moz-border-radius:15px;border-radius:15px;}.pills a:hover{color:#ffffff;text-decoration:none;text-shadow:0 1px 1px rgba(0, 0, 0, 0.25);background-color:#00438a;}
  .pills .active a{color:#ffffff;text-shadow:0 1px 1px rgba(0, 0, 0, 0.25);background-color:#0069d6;}
  .pills-vertical>li{float:none;}
  .tab-content>.tab-pane,.pill-content>.pill-pane,.tab-content>div,.pill-content>div{display:none;}
  .tab-content>.active,.pill-content>.active{display:block;}
  .breadcrumb{padding:7px 14px;margin:0 0 18px;background-color:#f5f5f5;background-repeat:repeat-x;background-image:-khtml-gradient(linear, left top, left bottom, from(#ffffff), to(#f5f5f5));background-image:-moz-linear-gradient(top, #ffffff, #f5f5f5);background-image:-ms-linear-gradient(top, #ffffff, #f5f5f5);background-image:-webkit-gradient(linear, left top, left bottom, color-stop(0%, #ffffff), color-stop(100%, #f5f5f5));background-image:-webkit-linear-gradient(top, #ffffff, #f5f5f5);background-image:-o-linear-gradient(top, #ffffff, #f5f5f5);background-image:linear-gradient(top, #ffffff, #f5f5f5);filter:progid:DXImageTransform.Microsoft.gradient(startColorstr='#ffffff', endColorstr='#f5f5f5', GradientType=0);border:1px solid #ddd;-webkit-border-radius:3px;-moz-border-radius:3px;border-radius:3px;-webkit-box-shadow:inset 0 1px 0 #ffffff;-moz-box-shadow:inset 0 1px 0 #ffffff;box-shadow:inset 0 1px 0 #ffffff;}.breadcrumb li{display:inline;text-shadow:0 1px 0 #ffffff;}
  .breadcrumb .divider{padding:0 5px;color:#bfbfbf;}
  .breadcrumb .active a{color:#404040;}
  .hero-unit{background-color:#f5f5f5;margin-bottom:30px;padding:60px;-webkit-border-radius:6px;-moz-border-radius:6px;border-radius:6px;}.hero-unit h1{margin-bottom:0;font-size:60px;line-height:1;letter-spacing:-1px;}
  .hero-unit p{font-size:18px;font-weight:200;line-height:27px;}
  footer{margin-top:17px;padding-top:17px;border-top:1px solid #eee;}
  .page-header{margin-bottom:17px;border-bottom:1px solid #ddd;-webkit-box-shadow:0 1px 0 rgba(255, 255, 255, 0.5);-moz-box-shadow:0 1px 0 rgba(255, 255, 255, 0.5);box-shadow:0 1px 0 rgba(255, 255, 255, 0.5);}.page-header h1{margin-bottom:8px;}
  .btn.danger,.alert-message.danger,.btn.danger:hover,.alert-message.danger:hover,.btn.error,.alert-message.error,.btn.error:hover,.alert-message.error:hover,.btn.success,.alert-message.success,.btn.success:hover,.alert-message.success:hover,.btn.info,.alert-message.info,.btn.info:hover,.alert-message.info:hover{color:#ffffff;}
  .btn .close,.alert-message .close{font-family:Arial,sans-serif;line-height:18px;}
  .btn.danger,.alert-message.danger,.btn.error,.alert-message.error{background-color:#c43c35;background-repeat:repeat-x;background-image:-khtml-gradient(linear, left top, left bottom, from(#ee5f5b), to(#c43c35));background-image:-moz-linear-gradient(top, #ee5f5b, #c43c35);background-image:-ms-linear-gradient(top, #ee5f5b, #c43c35);background-image:-webkit-gradient(linear, left top, left bottom, color-stop(0%, #ee5f5b), color-stop(100%, #c43c35));background-image:-webkit-linear-gradient(top, #ee5f5b, #c43c35);background-image:-o-linear-gradient(top, #ee5f5b, #c43c35);background-image:linear-gradient(top, #ee5f5b, #c43c35);filter:progid:DXImageTransform.Microsoft.gradient(startColorstr='#ee5f5b', endColorstr='#c43c35', GradientType=0);text-shadow:0 -1px 0 rgba(0, 0, 0, 0.25);border-color:#c43c35 #c43c35 #882a25;border-color:rgba(0, 0, 0, 0.1) rgba(0, 0, 0, 0.1) rgba(0, 0, 0, 0.25);}
  .btn.success,.alert-message.success{background-color:#57a957;background-repeat:repeat-x;background-image:-khtml-gradient(linear, left top, left bottom, from(#62c462), to(#57a957));background-image:-moz-linear-gradient(top, #62c462, #57a957);background-image:-ms-linear-gradient(top, #62c462, #57a957);background-image:-webkit-gradient(linear, left top, left bottom, color-stop(0%, #62c462), color-stop(100%, #57a957));background-image:-webkit-linear-gradient(top, #62c462, #57a957);background-image:-o-linear-gradient(top, #62c462, #57a957);background-image:linear-gradient(top, #62c462, #57a957);filter:progid:DXImageTransform.Microsoft.gradient(startColorstr='#62c462', endColorstr='#57a957', GradientType=0);text-shadow:0 -1px 0 rgba(0, 0, 0, 0.25);border-color:#57a957 #57a957 #3d773d;border-color:rgba(0, 0, 0, 0.1) rgba(0, 0, 0, 0.1) rgba(0, 0, 0, 0.25);}
  .btn.info,.alert-message.info{background-color:#339bb9;background-repeat:repeat-x;background-image:-khtml-gradient(linear, left top, left bottom, from(#5bc0de), to(#339bb9));background-image:-moz-linear-gradient(top, #5bc0de, #339bb9);background-image:-ms-linear-gradient(top, #5bc0de, #339bb9);background-image:-webkit-gradient(linear, left top, left bottom, color-stop(0%, #5bc0de), color-stop(100%, #339bb9));background-image:-webkit-linear-gradient(top, #5bc0de, #339bb9);background-image:-o-linear-gradient(top, #5bc0de, #339bb9);background-image:linear-gradient(top, #5bc0de, #339bb9);filter:progid:DXImageTransform.Microsoft.gradient(startColorstr='#5bc0de', endColorstr='#339bb9', GradientType=0);text-shadow:0 -1px 0 rgba(0, 0, 0, 0.25);border-color:#339bb9 #339bb9 #22697d;border-color:rgba(0, 0, 0, 0.1) rgba(0, 0, 0, 0.1) rgba(0, 0, 0, 0.25);}
  .btn{cursor:pointer;display:inline-block;background-color:#e6e6e6;background-repeat:no-repeat;background-image:-webkit-gradient(linear, 0 0, 0 100%, from(#ffffff), color-stop(25%, #ffffff), to(#e6e6e6));background-image:-webkit-linear-gradient(#ffffff, #ffffff 25%, #e6e6e6);background-image:-moz-linear-gradient(top, #ffffff, #ffffff 25%, #e6e6e6);background-image:-ms-linear-gradient(#ffffff, #ffffff 25%, #e6e6e6);background-image:-o-linear-gradient(#ffffff, #ffffff 25%, #e6e6e6);background-image:linear-gradient(#ffffff, #ffffff 25%, #e6e6e6);filter:progid:DXImageTransform.Microsoft.gradient(startColorstr='#ffffff', endColorstr='#e6e6e6', GradientType=0);padding:5px 14px 6px;text-shadow:0 1px 1px rgba(255, 255, 255, 0.75);color:#333;font-size:13px;line-height:normal;border:1px solid #ccc;border-bottom-color:#bbb;-webkit-border-radius:4px;-moz-border-radius:4px;border-radius:4px;-webkit-box-shadow:inset 0 1px 0 rgba(255, 255, 255, 0.2),0 1px 2px rgba(0, 0, 0, 0.05);-moz-box-shadow:inset 0 1px 0 rgba(255, 255, 255, 0.2),0 1px 2px rgba(0, 0, 0, 0.05);box-shadow:inset 0 1px 0 rgba(255, 255, 255, 0.2),0 1px 2px rgba(0, 0, 0, 0.05);-webkit-transition:0.1s linear all;-moz-transition:0.1s linear all;-ms-transition:0.1s linear all;-o-transition:0.1s linear all;transition:0.1s linear all;}.btn:hover{background-position:0 -15px;color:#333;text-decoration:none;}
  .btn:focus{outline:1px dotted #666;}
  .btn.primary{color:#ffffff;background-color:#0064cd;background-repeat:repeat-x;background-image:-khtml-gradient(linear, left top, left bottom, from(#049cdb), to(#0064cd));background-image:-moz-linear-gradient(top, #049cdb, #0064cd);background-image:-ms-linear-gradient(top, #049cdb, #0064cd);background-image:-webkit-gradient(linear, left top, left bottom, color-stop(0%, #049cdb), color-stop(100%, #0064cd));background-image:-webkit-linear-gradient(top, #049cdb, #0064cd);background-image:-o-linear-gradient(top, #049cdb, #0064cd);background-image:linear-gradient(top, #049cdb, #0064cd);filter:progid:DXImageTransform.Microsoft.gradient(startColorstr='#049cdb', endColorstr='#0064cd', GradientType=0);text-shadow:0 -1px 0 rgba(0, 0, 0, 0.25);border-color:#0064cd #0064cd #003f81;border-color:rgba(0, 0, 0, 0.1) rgba(0, 0, 0, 0.1) rgba(0, 0, 0, 0.25);}
  .btn.active,.btn:active{-webkit-box-shadow:inset 0 2px 4px rgba(0, 0, 0, 0.25),0 1px 2px rgba(0, 0, 0, 0.05);-moz-box-shadow:inset 0 2px 4px rgba(0, 0, 0, 0.25),0 1px 2px rgba(0, 0, 0, 0.05);box-shadow:inset 0 2px 4px rgba(0, 0, 0, 0.25),0 1px 2px rgba(0, 0, 0, 0.05);}
  .btn.disabled{cursor:default;background-image:none;filter:progid:DXImageTransform.Microsoft.gradient(enabled = false);filter:alpha(opacity=65);-khtml-opacity:0.65;-moz-opacity:0.65;opacity:0.65;-webkit-box-shadow:none;-moz-box-shadow:none;box-shadow:none;}
  .btn[disabled]{cursor:default;background-image:none;filter:progid:DXImageTransform.Microsoft.gradient(enabled = false);filter:alpha(opacity=65);-khtml-opacity:0.65;-moz-opacity:0.65;opacity:0.65;-webkit-box-shadow:none;-moz-box-shadow:none;box-shadow:none;}
  .btn.large{font-size:15px;line-height:normal;padding:9px 14px 9px;-webkit-border-radius:6px;-moz-border-radius:6px;border-radius:6px;}
  .btn.small{padding:7px 9px 7px;font-size:11px;}
  :root .alert-message,:root .btn{border-radius:0 \0;}
  button.btn::-moz-focus-inner,input[type=submit].btn::-moz-focus-inner{padding:0;border:0;}
  .close{float:right;color:#000000;font-size:20px;font-weight:bold;line-height:13.5px;text-shadow:0 1px 0 #ffffff;filter:alpha(opacity=25);-khtml-opacity:0.25;-moz-opacity:0.25;opacity:0.25;}.close:hover{color:#000000;text-decoration:none;filter:alpha(opacity=40);-khtml-opacity:0.4;-moz-opacity:0.4;opacity:0.4;}
  .alert-message{position:relative;padding:7px 15px;margin-bottom:18px;color:#404040;background-color:#eedc94;background-repeat:repeat-x;background-image:-khtml-gradient(linear, left top, left bottom, from(#fceec1), to(#eedc94));background-image:-moz-linear-gradient(top, #fceec1, #eedc94);background-image:-ms-linear-gradient(top, #fceec1, #eedc94);background-image:-webkit-gradient(linear, left top, left bottom, color-stop(0%, #fceec1), color-stop(100%, #eedc94));background-image:-webkit-linear-gradient(top, #fceec1, #eedc94);background-image:-o-linear-gradient(top, #fceec1, #eedc94);background-image:linear-gradient(top, #fceec1, #eedc94);filter:progid:DXImageTransform.Microsoft.gradient(startColorstr='#fceec1', endColorstr='#eedc94', GradientType=0);text-shadow:0 -1px 0 rgba(0, 0, 0, 0.25);border-color:#eedc94 #eedc94 #e4c652;border-color:rgba(0, 0, 0, 0.1) rgba(0, 0, 0, 0.1) rgba(0, 0, 0, 0.25);text-shadow:0 1px 0 rgba(255, 255, 255, 0.5);border-width:1px;border-style:solid;-webkit-border-radius:4px;-moz-border-radius:4px;border-radius:4px;-webkit-box-shadow:inset 0 1px 0 rgba(255, 255, 255, 0.25);-moz-box-shadow:inset 0 1px 0 rgba(255, 255, 255, 0.25);box-shadow:inset 0 1px 0 rgba(255, 255, 255, 0.25);}.alert-message .close{margin-top:1px;*margin-top:0;}
  .alert-message a{font-weight:bold;color:#404040;}
  .alert-message.danger p a,.alert-message.error p a,.alert-message.success p a,.alert-message.info p a{color:#ffffff;}
  .alert-message h5{line-height:18px;}
  .alert-message p{margin-bottom:0;}
  .alert-message div{margin-top:5px;margin-bottom:2px;line-height:28px;}
  .alert-message .btn{-webkit-box-shadow:0 1px 0 rgba(255, 255, 255, 0.25);-moz-box-shadow:0 1px 0 rgba(255, 255, 255, 0.25);box-shadow:0 1px 0 rgba(255, 255, 255, 0.25);}
  .alert-message.block-message{background-image:none;background-color:#fdf5d9;filter:progid:DXImageTransform.Microsoft.gradient(enabled = false);padding:14px;border-color:#fceec1;-webkit-box-shadow:none;-moz-box-shadow:none;box-shadow:none;}.alert-message.block-message ul,.alert-message.block-message p{margin-right:30px;}
  .alert-message.block-message ul{margin-bottom:0;}
  .alert-message.block-message li{color:#404040;}
  .alert-message.block-message .alert-actions{margin-top:5px;}
  .alert-message.block-message.error,.alert-message.block-message.success,.alert-message.block-message.info{color:#404040;text-shadow:0 1px 0 rgba(255, 255, 255, 0.5);}
  .alert-message.block-message.error{background-color:#fddfde;border-color:#fbc7c6;}
  .alert-message.block-message.success{background-color:#d1eed1;border-color:#bfe7bf;}
  .alert-message.block-message.info{background-color:#ddf4fb;border-color:#c6edf9;}
  .alert-message.block-message.danger p a,.alert-message.block-message.error p a,.alert-message.block-message.success p a,.alert-message.block-message.info p a{color:#404040;}
  .pagination{height:36px;margin:18px 0;}.pagination ul{float:left;margin:0;border:1px solid #ddd;border:1px solid rgba(0, 0, 0, 0.15);-webkit-border-radius:3px;-moz-border-radius:3px;border-radius:3px;-webkit-box-shadow:0 1px 2px rgba(0, 0, 0, 0.05);-moz-box-shadow:0 1px 2px rgba(0, 0, 0, 0.05);box-shadow:0 1px 2px rgba(0, 0, 0, 0.05);}
  .pagination li{display:inline;}
  .pagination a{float:left;padding:0 14px;line-height:34px;border-right:1px solid;border-right-color:#ddd;border-right-color:rgba(0, 0, 0, 0.15);*border-right-color:#ddd;text-decoration:none;}
  .pagination a:hover,.pagination .active a{background-color:#c7eefe;}
  .pagination .disabled a,.pagination .disabled a:hover{background-color:transparent;color:#bfbfbf;}
  .pagination .next a{border:0;}
  .well{background-color:#f5f5f5;margin-bottom:20px;padding:19px;min-height:20px;border:1px solid #eee;border:1px solid rgba(0, 0, 0, 0.05);-webkit-border-radius:4px;-moz-border-radius:4px;border-radius:4px;-webkit-box-shadow:inset 0 1px 1px rgba(0, 0, 0, 0.05);-moz-box-shadow:inset 0 1px 1px rgba(0, 0, 0, 0.05);box-shadow:inset 0 1px 1px rgba(0, 0, 0, 0.05);}.well blockquote{border-color:#ddd;border-color:rgba(0, 0, 0, 0.15);}
  .modal-backdrop{background-color:#000000;position:fixed;top:0;left:0;right:0;bottom:0;z-index:10000;}.modal-backdrop.fade{opacity:0;}
  .modal-backdrop,.modal-backdrop.fade.in{filter:alpha(opacity=80);-khtml-opacity:0.8;-moz-opacity:0.8;opacity:0.8;}
  .modal{position:fixed;top:50%;left:50%;z-index:11000;width:560px;margin:-250px 0 0 -280px;background-color:#ffffff;border:1px solid #999;border:1px solid rgba(0, 0, 0, 0.3);*border:1px solid #999;-webkit-border-radius:6px;-moz-border-radius:6px;border-radius:6px;-webkit-box-shadow:0 3px 7px rgba(0, 0, 0, 0.3);-moz-box-shadow:0 3px 7px rgba(0, 0, 0, 0.3);box-shadow:0 3px 7px rgba(0, 0, 0, 0.3);-webkit-background-clip:padding-box;-moz-background-clip:padding-box;background-clip:padding-box;}.modal .close{margin-top:7px;}
  .modal.fade{-webkit-transition:opacity .3s linear, top .3s ease-out;-moz-transition:opacity .3s linear, top .3s ease-out;-ms-transition:opacity .3s linear, top .3s ease-out;-o-transition:opacity .3s linear, top .3s ease-out;transition:opacity .3s linear, top .3s ease-out;top:-25%;}
  .modal.fade.in{top:50%;}
  .modal-header{border-bottom:1px solid #eee;padding:5px 15px;}
  .modal-body{padding:15px;}
  .modal-body form{margin-bottom:0;}
  .modal-footer{background-color:#f5f5f5;padding:14px 15px 15px;border-top:1px solid #ddd;-webkit-border-radius:0 0 6px 6px;-moz-border-radius:0 0 6px 6px;border-radius:0 0 6px 6px;-webkit-box-shadow:inset 0 1px 0 #ffffff;-moz-box-shadow:inset 0 1px 0 #ffffff;box-shadow:inset 0 1px 0 #ffffff;zoom:1;margin-bottom:0;}.modal-footer:before,.modal-footer:after{display:table;content:"";zoom:1;}
  .modal-footer:after{clear:both;}
  .modal-footer .btn{float:right;margin-left:5px;}
  .modal .popover,.modal .twipsy{z-index:12000;}
  .twipsy{display:block;position:absolute;visibility:visible;padding:5px;font-size:11px;z-index:1000;filter:alpha(opacity=80);-khtml-opacity:0.8;-moz-opacity:0.8;opacity:0.8;}.twipsy.fade.in{filter:alpha(opacity=80);-khtml-opacity:0.8;-moz-opacity:0.8;opacity:0.8;}
  .twipsy.above .twipsy-arrow{bottom:0;left:50%;margin-left:-5px;border-left:5px solid transparent;border-right:5px solid transparent;border-top:5px solid #000000;}
  .twipsy.left .twipsy-arrow{top:50%;right:0;margin-top:-5px;border-top:5px solid transparent;border-bottom:5px solid transparent;border-left:5px solid #000000;}
  .twipsy.below .twipsy-arrow{top:0;left:50%;margin-left:-5px;border-left:5px solid transparent;border-right:5px solid transparent;border-bottom:5px solid #000000;}
  .twipsy.right .twipsy-arrow{top:50%;left:0;margin-top:-5px;border-top:5px solid transparent;border-bottom:5px solid transparent;border-right:5px solid #000000;}
  .twipsy-inner{padding:3px 8px;background-color:#000000;color:white;text-align:center;max-width:200px;text-decoration:none;-webkit-border-radius:4px;-moz-border-radius:4px;border-radius:4px;}
  .twipsy-arrow{position:absolute;width:0;height:0;}
  .popover{position:absolute;top:0;left:0;z-index:1000;padding:5px;display:none;}.popover.above .arrow{bottom:0;left:50%;margin-left:-5px;border-left:5px solid transparent;border-right:5px solid transparent;border-top:5px solid #000000;}
  .popover.right .arrow{top:50%;left:0;margin-top:-5px;border-top:5px solid transparent;border-bottom:5px solid transparent;border-right:5px solid #000000;}
  .popover.below .arrow{top:0;left:50%;margin-left:-5px;border-left:5px solid transparent;border-right:5px solid transparent;border-bottom:5px solid #000000;}
  .popover.left .arrow{top:50%;right:0;margin-top:-5px;border-top:5px solid transparent;border-bottom:5px solid transparent;border-left:5px solid #000000;}
  .popover .arrow{position:absolute;width:0;height:0;}
  .popover .inner{background:#000000;background:rgba(0, 0, 0, 0.8);padding:3px;overflow:hidden;width:280px;-webkit-border-radius:6px;-moz-border-radius:6px;border-radius:6px;-webkit-box-shadow:0 3px 7px rgba(0, 0, 0, 0.3);-moz-box-shadow:0 3px 7px rgba(0, 0, 0, 0.3);box-shadow:0 3px 7px rgba(0, 0, 0, 0.3);}
  .popover .title{background-color:#f5f5f5;padding:9px 15px;line-height:1;-webkit-border-radius:3px 3px 0 0;-moz-border-radius:3px 3px 0 0;border-radius:3px 3px 0 0;border-bottom:1px solid #eee;}
  .popover .content{background-color:#ffffff;padding:14px;-webkit-border-radius:0 0 3px 3px;-moz-border-radius:0 0 3px 3px;border-radius:0 0 3px 3px;-webkit-background-clip:padding-box;-moz-background-clip:padding-box;background-clip:padding-box;}.popover .content p,.popover .content ul,.popover .content ol{margin-bottom:0;}
  .fade{-webkit-transition:opacity 0.15s linear;-moz-transition:opacity 0.15s linear;-ms-transition:opacity 0.15s linear;-o-transition:opacity 0.15s linear;transition:opacity 0.15s linear;opacity:0;}.fade.in{opacity:1;}
  .label{padding:1px 3px 2px;font-size:9.75px;font-weight:bold;color:#ffffff;text-transform:uppercase;white-space:nowrap;background-color:#bfbfbf;-webkit-border-radius:3px;-moz-border-radius:3px;border-radius:3px;}.label.important{background-color:#c43c35;}
  .label.warning{background-color:#f89406;}
  .label.success{background-color:#46a546;}
  .label.notice{background-color:#62cffc;}
  .media-grid{margin-left:-20px;margin-bottom:0;zoom:1;}.media-grid:before,.media-grid:after{display:table;content:"";zoom:1;}
  .media-grid:after{clear:both;}
  .media-grid li{display:inline;}
  .media-grid a{float:left;padding:4px;margin:0 0 18px 20px;border:1px solid #ddd;-webkit-border-radius:4px;-moz-border-radius:4px;border-radius:4px;-webkit-box-shadow:0 1px 1px rgba(0, 0, 0, 0.075);-moz-box-shadow:0 1px 1px rgba(0, 0, 0, 0.075);box-shadow:0 1px 1px rgba(0, 0, 0, 0.075);}.media-grid a img{display:block;}
  .media-grid a:hover{border-color:#0069d6;-webkit-box-shadow:0 1px 4px rgba(0, 105, 214, 0.25);-moz-box-shadow:0 1px 4px rgba(0, 105, 214, 0.25);box-shadow:0 1px 4px rgba(0, 105, 214, 0.25);}
---
file: htdocs/common/js/bootstrap-modal.js
template: |
  /* =========================================================
   * bootstrap-modal.js v1.4.0
   * http://twitter.github.com/bootstrap/javascript.html#modal
   * =========================================================
   * Copyright 2011 Twitter, Inc.
   *
   * Licensed under the Apache License, Version 2.0 (the "License");
   * you may not use this file except in compliance with the License.
   * You may obtain a copy of the License at
   *
   * http://www.apache.org/licenses/LICENSE-2.0
   *
   * Unless required by applicable law or agreed to in writing, software
   * distributed under the License is distributed on an "AS IS" BASIS,
   * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   * See the License for the specific language governing permissions and
   * limitations under the License.
   * ========================================================= */
  
  
  !function( $ ){
  
    "use strict"
  
   /* CSS TRANSITION SUPPORT (https://gist.github.com/373874)
    * ======================================================= */
  
    var transitionEnd
  
    $(document).ready(function () {
  
      $.support.transition = (function () {
        var thisBody = document.body || document.documentElement
          , thisStyle = thisBody.style
          , support = thisStyle.transition !== undefined || thisStyle.WebkitTransition !== undefined || thisStyle.MozTransition !== undefined || thisStyle.MsTransition !== undefined || thisStyle.OTransition !== undefined
        return support
      })()
  
      // set CSS transition event type
      if ( $.support.transition ) {
        transitionEnd = "TransitionEnd"
        if ( $.browser.webkit ) {
        	transitionEnd = "webkitTransitionEnd"
        } else if ( $.browser.mozilla ) {
        	transitionEnd = "transitionend"
        } else if ( $.browser.opera ) {
        	transitionEnd = "oTransitionEnd"
        }
      }
  
    })
  
  
   /* MODAL PUBLIC CLASS DEFINITION
    * ============================= */
  
    var Modal = function ( content, options ) {
      this.settings = $.extend({}, $.fn.modal.defaults, options)
      this.$element = $(content)
        .delegate('.close', 'click.modal', $.proxy(this.hide, this))
  
      if ( this.settings.show ) {
        this.show()
      }
  
      return this
    }
  
    Modal.prototype = {
  
        toggle: function () {
          return this[!this.isShown ? 'show' : 'hide']()
        }
  
      , show: function () {
          var that = this
          this.isShown = true
          this.$element.trigger('show')
  
          escape.call(this)
          backdrop.call(this, function () {
            var transition = $.support.transition && that.$element.hasClass('fade')
  
            that.$element
              .appendTo(document.body)
              .show()
  
            if (transition) {
              that.$element[0].offsetWidth // force reflow
            }
  
            that.$element.addClass('in')
  
            transition ?
              that.$element.one(transitionEnd, function () { that.$element.trigger('shown') }) :
              that.$element.trigger('shown')
  
          })
  
          return this
        }
  
      , hide: function (e) {
          e && e.preventDefault()
  
          if ( !this.isShown ) {
            return this
          }
  
          var that = this
          this.isShown = false
  
          escape.call(this)
  
          this.$element
            .trigger('hide')
            .removeClass('in')
  
          $.support.transition && this.$element.hasClass('fade') ?
            hideWithTransition.call(this) :
            hideModal.call(this)
  
          return this
        }
  
    }
  
  
   /* MODAL PRIVATE METHODS
    * ===================== */
  
    function hideWithTransition() {
      // firefox drops transitionEnd events :{o
      var that = this
        , timeout = setTimeout(function () {
            that.$element.unbind(transitionEnd)
            hideModal.call(that)
          }, 500)
  
      this.$element.one(transitionEnd, function () {
        clearTimeout(timeout)
        hideModal.call(that)
      })
    }
  
    function hideModal (that) {
      this.$element
        .hide()
        .trigger('hidden')
  
      backdrop.call(this)
    }
  
    function backdrop ( callback ) {
      var that = this
        , animate = this.$element.hasClass('fade') ? 'fade' : ''
      if ( this.isShown && this.settings.backdrop ) {
        var doAnimate = $.support.transition && animate
  
        this.$backdrop = $('<div class="modal-backdrop ' + animate + '" />')
          .appendTo(document.body)
  
        if ( this.settings.backdrop != 'static' ) {
          this.$backdrop.click($.proxy(this.hide, this))
        }
  
        if ( doAnimate ) {
          this.$backdrop[0].offsetWidth // force reflow
        }
  
        this.$backdrop.addClass('in')
  
        doAnimate ?
          this.$backdrop.one(transitionEnd, callback) :
          callback()
  
      } else if ( !this.isShown && this.$backdrop ) {
        this.$backdrop.removeClass('in')
  
        $.support.transition && this.$element.hasClass('fade')?
          this.$backdrop.one(transitionEnd, $.proxy(removeBackdrop, this)) :
          removeBackdrop.call(this)
  
      } else if ( callback ) {
         callback()
      }
    }
  
    function removeBackdrop() {
      this.$backdrop.remove()
      this.$backdrop = null
    }
  
    function escape() {
      var that = this
      if ( this.isShown && this.settings.keyboard ) {
        $(document).bind('keyup.modal', function ( e ) {
          if ( e.which == 27 ) {
            that.hide()
          }
        })
      } else if ( !this.isShown ) {
        $(document).unbind('keyup.modal')
      }
    }
  
  
   /* MODAL PLUGIN DEFINITION
    * ======================= */
  
    $.fn.modal = function ( options ) {
      var modal = this.data('modal')
  
      if (!modal) {
  
        if (typeof options == 'string') {
          options = {
            show: /show|toggle/.test(options)
          }
        }
  
        return this.each(function () {
          $(this).data('modal', new Modal(this, options))
        })
      }
  
      if ( options === true ) {
        return modal
      }
  
      if ( typeof options == 'string' ) {
        modal[options]()
      } else if ( modal ) {
        modal.toggle()
      }
  
      return this
    }
  
    $.fn.modal.Modal = Modal
  
    $.fn.modal.defaults = {
      backdrop: false
    , keyboard: false
    , show: false
    }
  
  
   /* MODAL DATA- IMPLEMENTATION
    * ========================== */
  
    $(document).ready(function () {
      $('body').delegate('[data-controls-modal]', 'click', function (e) {
        e.preventDefault()
        var $this = $(this).data('show', true)
        $('#' + $this.attr('data-controls-modal')).modal( $this.data() )
      })
    })
  
  }( window.jQuery || window.ender );
---
file: htdocs/common/js/jquery.cookie.js
template: |
  /**
   * jQuery Cookie plugin
   *
   * Copyright (c) 2010 Klaus Hartl (stilbuero.de)
   * Dual licensed under the MIT and GPL licenses:
   * http://www.opensource.org/licenses/mit-license.php
   * http://www.gnu.org/licenses/gpl.html
   *
   */
  jQuery.cookie = function (key, value, options) {
  
      // key and at least value given, set cookie...
      if (arguments.length > 1 && String(value) !== "[object Object]") {
          options = jQuery.extend({}, options);
  
          if (value === null || value === undefined) {
              options.expires = -1;
          }
  
          if (typeof options.expires === 'number') {
              var days = options.expires, t = options.expires = new Date();
              t.setDate(t.getDate() + days);
          }
  
          value = String(value);
  
          return (document.cookie = [
              encodeURIComponent(key), '=',
              options.raw ? value : encodeURIComponent(value),
              options.expires ? '; expires=' + options.expires.toUTCString() : '', // use expires attribute, max-age is not supported by IE
              options.path ? '; path=' + options.path : '',
              options.domain ? '; domain=' + options.domain : '',
              options.secure ? '; secure' : ''
          ].join(''));
      }
  
      // key and possibly options given, get cookie...
      options = value || {};
      var result, decode = options.raw ? function (s) { return s; } : decodeURIComponent;
      return (result = new RegExp('(?:^|; )' + encodeURIComponent(key) + '=([^;]*)').exec(document.cookie)) ? decode(result[1]) : null;
  };
---
file: htdocs/common/js/jquery.ze.js
template: |+2
  
  jQuery.fn.extend({
      template : function(data){
          var tmpl_data = $(this).html();
  
          var fn = new Function("obj",
                       "var p=[];" +
  
                       // Introduce the data as local variables using with(){}
                       "with(obj){p.push('" +
  
                       // Convert the template into pure JavaScript
                      tmpl_data 
                       .replace(/[\r\t\n]/g, " ")
                       .split("<%").join("\t")
                       .replace(/(^|%>)[^\t]*?(\t|$)/g, function(){return arguments[0].split("'").join("\\'");})
                       .replace(/\t==(.*?)%>/g,"',$1,'")
                       .replace(/\t=(.*?)%>/g, "',(($1)+'').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/\"/g,'&quot;'),'")
                       .split("\t").join("');")
                       .split("%>").join("p.push('")
                       + "');}return p.join('');");
          return fn( data );
              
      }
  
  });
  
  // firebug console..
  if (window.console && window.console.log ) {
      window.log = window.console.log
  } else {
      window.console = {
  log: function () {}
      }
  }

---
file: htdocs/common/js/less-1.1.3.min.js
template: |-
  //
  // LESS - Leaner CSS v1.1.3
  // http://lesscss.org
  // 
  // Copyright (c) 2009-2011, Alexis Sellier
  // Licensed under the Apache 2.0 License.
  //
  //
  // LESS - Leaner CSS v1.1.3
  // http://lesscss.org
  // 
  // Copyright (c) 2009-2011, Alexis Sellier
  // Licensed under the Apache 2.0 License.
  //
  (function(a,b){function v(a,b){var c="less-error-message:"+p(b),e=["<ul>",'<li><label>[-1]</label><pre class="ctx">{0}</pre></li>',"<li><label>[0]</label><pre>{current}</pre></li>",'<li><label>[1]</label><pre class="ctx">{2}</pre></li>',"</ul>"].join("\n"),f=document.createElement("div"),g,h;f.id=c,f.className="less-error-message",h="<h3>"+(a.message||"There is an error in your .less file")+"</h3>"+'<p><a href="'+b+'">'+b+"</a> ",a.extract&&(h+="on line "+a.line+", column "+(a.column+1)+":</p>"+e.replace(/\[(-?\d)\]/g,function(b,c){return parseInt(a.line)+parseInt(c)||""}).replace(/\{(\d)\}/g,function(b,c){return a.extract[parseInt(c)]||""}).replace(/\{current\}/,a.extract[1].slice(0,a.column)+'<span class="error">'+a.extract[1].slice(a.column)+"</span>")),f.innerHTML=h,q([".less-error-message ul, .less-error-message li {","list-style-type: none;","margin-right: 15px;","padding: 4px 0;","margin: 0;","}",".less-error-message label {","font-size: 12px;","margin-right: 15px;","padding: 4px 0;","color: #cc7777;","}",".less-error-message pre {","color: #ee4444;","padding: 4px 0;","margin: 0;","display: inline-block;","}",".less-error-message pre.ctx {","color: #dd4444;","}",".less-error-message h3 {","font-size: 20px;","font-weight: bold;","padding: 15px 0 5px 0;","margin: 0;","}",".less-error-message a {","color: #10a","}",".less-error-message .error {","color: red;","font-weight: bold;","padding-bottom: 2px;","border-bottom: 1px dashed red;","}"].join("\n"),{title:"error-message"}),f.style.cssText=["font-family: Arial, sans-serif","border: 1px solid #e00","background-color: #eee","border-radius: 5px","-webkit-border-radius: 5px","-moz-border-radius: 5px","color: #e00","padding: 15px","margin-bottom: 15px"].join(";"),d.env=="development"&&(g=setInterval(function(){document.body&&(document.getElementById(c)?document.body.replaceChild(f,document.getElementById(c)):document.body.insertBefore(f,document.body.firstChild),clearInterval(g))},10))}function u(a){d.env=="development"&&typeof console!="undefined"&&console.log("less: "+a)}function t(a){return a&&a.parentNode.removeChild(a)}function s(){if(a.XMLHttpRequest)return new XMLHttpRequest;try{return new ActiveXObject("MSXML2.XMLHTTP.3.0")}catch(b){u("browser doesn't support AJAX.");return null}}function r(a,b,c,e){function i(b,c,d){b.status>=200&&b.status<300?c(b.responseText,b.getResponseHeader("Last-Modified")):typeof d=="function"&&d(b.status,a)}var f=s(),h=g?!1:d.async;typeof f.overrideMimeType=="function"&&f.overrideMimeType("text/css"),f.open("GET",a,h),f.setRequestHeader("Accept",b||"text/x-less, text/css; q=0.9, */*; q=0.5"),f.send(null),g?f.status===0?c(f.responseText):e(f.status,a):h?f.onreadystatechange=function(){f.readyState==4&&i(f,c,e)}:i(f,c,e)}function q(a,b,c){var d,e=b.href?b.href.replace(/\?.*$/,""):"",f="less:"+(b.title||p(e));(d=document.getElementById(f))===null&&(d=document.createElement("style"),d.type="text/css",d.media=b.media||"screen",d.id=f,document.getElementsByTagName("head")[0].appendChild(d));if(d.styleSheet)try{d.styleSheet.cssText=a}catch(g){throw new Error("Couldn't reassign styleSheet.cssText.")}else(function(a){d.childNodes.length>0?d.firstChild.nodeValue!==a.nodeValue&&d.replaceChild(a,d.firstChild):d.appendChild(a)})(document.createTextNode(a));c&&h&&(u("saving "+e+" to cache."),h.setItem(e,a),h.setItem(e+":timestamp",c))}function p(a){return a.replace(/^[a-z]+:\/\/?[^\/]+/,"").replace(/^\//,"").replace(/\?.*$/,"").replace(/\.[^\.\/]+$/,"").replace(/[^\.\w-]+/g,"-").replace(/\./g,":")}function o(b,c,e,f){var g=a.location.href.replace(/[#?].*$/,""),i=b.href.replace(/\?.*$/,""),j=h&&h.getItem(i),k=h&&h.getItem(i+":timestamp"),l={css:j,timestamp:k};/^(https?|file):/.test(i)||(i.charAt(0)=="/"?i=a.location.protocol+"//"+a.location.host+i:i=g.slice(0,g.lastIndexOf("/")+1)+i),r(b.href,b.type,function(a,g){if(!e&&l&&g&&(new Date(g)).valueOf()===(new Date(l.timestamp)).valueOf())q(l.css,b),c(null,b,{local:!0,remaining:f});else try{(new d.Parser({optimization:d.optimization,paths:[i.replace(/[\w\.-]+$/,"")],mime:b.type})).parse(a,function(a,d){if(a)return v(a,i);try{c(d,b,{local:!1,lastModified:g,remaining:f}),t(document.getElementById("less-error-message:"+p(i)))}catch(a){v(a,i)}})}catch(h){v(h,i)}},function(a,b){throw new Error("Couldn't load "+b+" ("+a+")")})}function n(a,b){for(var c=0;c<d.sheets.length;c++)o(d.sheets[c],a,b,d.sheets.length-(c+1))}function m(){var a=document.getElementsByTagName("style");for(var b=0;b<a.length;b++)a[b].type.match(k)&&(new d.Parser).parse(a[b].innerHTML||"",function(c,d){a[b].type="text/css",a[b].innerHTML=d.toCSS()})}function c(b){return a.less[b.split("/")[1]]}Array.isArray||(Array.isArray=function(a){return Object.prototype.toString.call(a)==="[object Array]"||a instanceof Array}),Array.prototype.forEach||(Array.prototype.forEach=function(a,b){var c=this.length>>>0;for(var d=0;d<c;d++)d in this&&a.call(b,this[d],d,this)}),Array.prototype.map||(Array.prototype.map=function(a){var b=this.length>>>0,c=Array(b),d=arguments[1];for(var e=0;e<b;e++)e in this&&(c[e]=a.call(d,this[e],e,this));return c}),Array.prototype.filter||(Array.prototype.filter=function(a){var b=[],c=arguments[1];for(var d=0;d<this.length;d++)a.call(c,this[d])&&b.push(this[d]);return b}),Array.prototype.reduce||(Array.prototype.reduce=function(a){var b=this.length>>>0,c=0;if(b===0&&arguments.length===1)throw new TypeError;if(arguments.length>=2)var d=arguments[1];else for(;;){if(c in this){d=this[c++];break}if(++c>=b)throw new TypeError}for(;c<b;c++)c in this&&(d=a.call(null,d,this[c],c,this));return d}),Array.prototype.indexOf||(Array.prototype.indexOf=function(a){var b=this.length,c=arguments[1]||0;if(!b)return-1;if(c>=b)return-1;c<0&&(c+=b);for(;c<b;c++){if(!Object.prototype.hasOwnProperty.call(this,c))continue;if(a===this[c])return c}return-1}),Object.keys||(Object.keys=function(a){var b=[];for(var c in a)Object.prototype.hasOwnProperty.call(a,c)&&b.push(c);return b}),String.prototype.trim||(String.prototype.trim=function(){return String(this).replace(/^\s\s*/,"").replace(/\s\s*$/,"")});var d,e;typeof a=="undefined"?(d=exports,e=c("less/tree")):(typeof a.less=="undefined"&&(a.less={}),d=a.less,e=a.less.tree={}),d.Parser=function(a){function t(a){return typeof a=="string"?b.charAt(c)===a:a.test(j[f])?!0:!1}function s(a){var d,e,g,h,i,m,n,o;if(a instanceof Function)return a.call(l.parsers);if(typeof a=="string")d=b.charAt(c)===a?a:null,g=1,r();else{r();if(d=a.exec(j[f]))g=d[0].length;else return null}if(d){o=c+=g,m=c+j[f].length-g;while(c<m){h=b.charCodeAt(c);if(h!==32&&h!==10&&h!==9)break;c++}j[f]=j[f].slice(g+(c-o)),k=c,j[f].length===0&&f<j.length-1&&f++;return typeof d=="string"?d:d.length===1?d[0]:d}}function r(){c>k&&(j[f]=j[f].slice(c-k),k=c)}function q(){j[f]=g,c=h,k=c}function p(){g=j[f],h=c,k=c}var b,c,f,g,h,i,j,k,l,m=this,n=function(){},o=this.imports={paths:a&&a.paths||[],queue:[],files:{},mime:a&&a.mime,push:function(b,c){var e=this;this.queue.push(b),d.Parser.importer(b,this.paths,function(a){e.queue.splice(e.queue.indexOf(b),1),e.files[b]=a,c(a),e.queue.length===0&&n()},a)}};this.env=a=a||{},this.optimization="optimization"in this.env?this.env.optimization:1,this.env.filename=this.env.filename||null;return l={imports:o,parse:function(d,g){var h,l,m,o,p,q,r=[],t,u=null;c=f=k=i=0,j=[],b=d.replace(/\r\n/g,"\n"),j=function(c){var d=0,e=/[^"'`\{\}\/\(\)]+/g,f=/\/\*(?:[^*]|\*+[^\/*])*\*+\/|\/\/.*/g,g=0,h,i=c[0],j,k;for(var l=0,m,n;l<b.length;l++){e.lastIndex=l,(h=e.exec(b))&&h.index===l&&(l+=h[0].length,i.push(h[0])),m=b.charAt(l),f.lastIndex=l,!k&&!j&&m==="/"&&(n=b.charAt(l+1),(n==="/"||n==="*")&&(h=f.exec(b))&&h.index===l&&(l+=h[0].length,i.push(h[0]),m=b.charAt(l)));if(m==="{"&&!k&&!j)g++,i.push(m);else if(m==="}"&&!k&&!j)g--,i.push(m),c[++d]=i=[];else if(m==="("&&!k&&!j)i.push(m),j=!0;else if(m===")"&&!k&&j)i.push(m),j=!1;else{if(m==='"'||m==="'"||m==="`")k?k=k===m?!1:k:k=m;i.push(m)}}if(g>0)throw{type:"Syntax",message:"Missing closing `}`",filename:a.filename};return c.map(function(a){return a.join("")})}([[]]),h=new e.Ruleset([],s(this.parsers.primary)),h.root=!0,h.toCSS=function(c){var d,f,g;return function(g,h){function n(a){return a?(b.slice(0,a).match(/\n/g)||"").length:null}var i=[];g=g||{},typeof h=="object"&&!Array.isArray(h)&&(h=Object.keys(h).map(function(a){var b=h[a];b instanceof e.Value||(b instanceof e.Expression||(b=new e.Expression([b])),b=new e.Value([b]));return new e.Rule("@"+a,b,!1,0)}),i=[new e.Ruleset(null,h)]);try{var j=c.call(this,{frames:i}).toCSS([],{compress:g.compress||!1})}catch(k){f=b.split("\n"),d=n(k.index);for(var l=k.index,m=-1;l>=0&&b.charAt(l)!=="\n";l--)m++;throw{type:k.type,message:k.message,filename:a.filename,index:k.index,line:typeof d=="number"?d+1:null,callLine:k.call&&n(k.call)+1,callExtract:f[n(k.call)],stack:k.stack,column:m,extract:[f[d-1],f[d],f[d+1]]}}return g.compress?j.replace(/(\s)+/g,"$1"):j}}(h.eval);if(c<b.length-1){c=i,q=b.split("\n"),p=(b.slice(0,c).match(/\n/g)||"").length+1;for(var v=c,w=-1;v>=0&&b.charAt(v)!=="\n";v--)w++;u={name:"ParseError",message:"Syntax Error on line "+p,index:c,filename:a.filename,line:p,column:w,extract:[q[p-2],q[p-1],q[p]]}}this.imports.queue.length>0?n=function(){g(u,h)}:g(u,h)},parsers:{primary:function(){var a,b=[];while((a=s(this.mixin.definition)||s(this.rule)||s(this.ruleset)||s(this.mixin.call)||s(this.comment)||s(this.directive))||s(/^[\s\n]+/))a&&b.push(a);return b},comment:function(){var a;if(b.charAt(c)==="/"){if(b.charAt(c+1)==="/")return new e.Comment(s(/^\/\/.*/),!0);if(a=s(/^\/\*(?:[^*]|\*+[^\/*])*\*+\/\n?/))return new e.Comment(a)}},entities:{quoted:function(){var a,d=c,f;b.charAt(d)==="~"&&(d++,f=!0);if(b.charAt(d)==='"'||b.charAt(d)==="'"){f&&s("~");if(a=s(/^"((?:[^"\\\r\n]|\\.)*)"|'((?:[^'\\\r\n]|\\.)*)'/))return new e.Quoted(a[0],a[1]||a[2],f)}},keyword:function(){var a;if(a=s(/^[A-Za-z-]+/))return new e.Keyword(a)},call:function(){var a,b,d=c;if(!!(a=/^([\w-]+|%)\(/.exec(j[f]))){a=a[1].toLowerCase();if(a==="url")return null;c+=a.length;if(a==="alpha")return s(this.alpha);s("("),b=s(this.entities.arguments);if(!s(")"))return;if(a)return new e.Call(a,b,d)}},arguments:function(){var a=[],b;while(b=s(this.expression)){a.push(b);if(!s(","))break}return a},literal:function(){return s(this.entities.dimension)||s(this.entities.color)||s(this.entities.quoted)},url:function(){var a;if(b.charAt(c)==="u"&&!!s(/^url\(/)){a=s(this.entities.quoted)||s(this.entities.variable)||s(this.entities.dataURI)||s(/^[-\w%@$\/.&=:;#+?~]+/)||"";if(!s(")"))throw new Error("missing closing ) for url()");return new e.URL(a.value||a.data||a instanceof e.Variable?a:new e.Anonymous(a),o.paths)}},dataURI:function(){var a;if(s(/^data:/)){a={},a.mime=s(/^[^\/]+\/[^,;)]+/)||"",a.charset=s(/^;\s*charset=[^,;)]+/)||"",a.base64=s(/^;\s*base64/)||"",a.data=s(/^,\s*[^)]+/);if(a.data)return a}},variable:function(){var a,d=c;if(b.charAt(c)==="@"&&(a=s(/^@@?[\w-]+/)))return new e.Variable(a,d)},color:function(){var a;if(b.charAt(c)==="#"&&(a=s(/^#([a-fA-F0-9]{6}|[a-fA-F0-9]{3})/)))return new e.Color(a[1])},dimension:function(){var a,d=b.charCodeAt(c);if(!(d>57||d<45||d===47))if(a=s(/^(-?\d*\.?\d+)(px|%|em|pc|ex|in|deg|s|ms|pt|cm|mm|rad|grad|turn)?/))return new e.Dimension(a[1],a[2])},javascript:function(){var a,d=c,f;b.charAt(d)==="~"&&(d++,f=!0);if(b.charAt(d)==="`"){f&&s("~");if(a=s(/^`([^`]*)`/))return new e.JavaScript(a[1],c,f)}}},variable:function(){var a;if(b.charAt(c)==="@"&&(a=s(/^(@[\w-]+)\s*:/)))return a[1]},shorthand:function(){var a,b;if(!!t(/^[@\w.%-]+\/[@\w.-]+/)&&(a=s(this.entity))&&s("/")&&(b=s(this.entity)))return new e.Shorthand(a,b)},mixin:{call:function(){var a=[],d,f,g,h=c,i=b.charAt(c);if(i==="."||i==="#"){while(d=s(/^[#.](?:[\w-]|\\(?:[a-fA-F0-9]{1,6} ?|[^a-fA-F0-9]))+/))a.push(new e.Element(f,d)),f=s(">");s("(")&&(g=s(this.entities.arguments))&&s(")");if(a.length>0&&(s(";")||t("}")))return new e.mixin.Call(a,g,h)}},definition:function(){var a,d=[],f,g,h,i;if(!(b.charAt(c)!=="."&&b.charAt(c)!=="#"||t(/^[^{]*(;|})/)))if(f=s(/^([#.](?:[\w-]|\\(?:[a-fA-F0-9]{1,6} ?|[^a-fA-F0-9]))+)\s*\(/)){a=f[1];while(h=s(this.entities.variable)||s(this.entities.literal)||s(this.entities.keyword)){if(h instanceof e.Variable)if(s(":"))if(i=s(this.expression))d.push({name:h.name,value:i});else throw new Error("Expected value");else d.push({name:h.name});else d.push({value:h});if(!s(","))break}if(!s(")"))throw new Error("Expected )");g=s(this.block);if(g)return new e.mixin.Definition(a,d,g)}}},entity:function(){return s(this.entities.literal)||s(this.entities.variable)||s(this.entities.url)||s(this.entities.call)||s(this.entities.keyword)||s(this.entities.javascript)||s(this.comment)},end:function(){return s(";")||t("}")},alpha:function(){var a;if(!!s(/^\(opacity=/i))if(a=s(/^\d+/)||s(this.entities.variable)){if(!s(")"))throw new Error("missing closing ) for alpha()");return new e.Alpha(a)}},element:function(){var a,b,c;c=s(this.combinator),a=s(/^(?:[.#]?|:*)(?:[\w-]|\\(?:[a-fA-F0-9]{1,6} ?|[^a-fA-F0-9]))+/)||s("*")||s(this.attribute)||s(/^\([^)@]+\)/);if(a)return new e.Element(c,a)},combinator:function(){var a,d=b.charAt(c);if(d===">"||d==="&"||d==="+"||d==="~"){c++;while(b.charAt(c)===" ")c++;return new e.Combinator(d)}if(d===":"&&b.charAt(c+1)===":"){c+=2;while(b.charAt(c)===" ")c++;return new e.Combinator("::")}return b.charAt(c-1)===" "?new e.Combinator(" "):new e.Combinator(null)},selector:function(){var a,d,f=[],g,h;while(d=s(this.element)){g=b.charAt(c),f.push(d);if(g==="{"||g==="}"||g===";"||g===",")break}if(f.length>0)return new e.Selector(f)},tag:function(){return s(/^[a-zA-Z][a-zA-Z-]*[0-9]?/)||s("*")},attribute:function(){var a="",b,c,d;if(!!s("[")){if(b=s(/^[a-zA-Z-]+/)||s(this.entities.quoted))(d=s(/^[|~*$^]?=/))&&(c=s(this.entities.quoted)||s(/^[\w-]+/))?a=[b,d,c.toCSS?c.toCSS():c].join(""):a=b;if(!s("]"))return;if(a)return"["+a+"]"}},block:function(){var a;if(s("{")&&(a=s(this.primary))&&s("}"))return a},ruleset:function(){var a=[],b,d,g;p();if(g=/^([.#: \w-]+)[\s\n]*\{/.exec(j[f]))c+=g[0].length-1,a=[new e.Selector([new e.Element(null,g[1])])];else while(b=s(this.selector)){a.push(b),s(this.comment);if(!s(","))break;s(this.comment)}if(a.length>0&&(d=s(this.block)))return new e.Ruleset(a,d);i=c,q()},rule:function(){var a,d,g=b.charAt(c),k,l;p();if(g!=="."&&g!=="#"&&g!=="&")if(a=s(this.variable)||s(this.property)){a.charAt(0)!="@"&&(l=/^([^@+\/'"*`(;{}-]*);/.exec(j[f]))?(c+=l[0].length-1,d=new e.Anonymous(l[1])):a==="font"?d=s(this.font):d=s(this.value),k=s(this.important);if(d&&s(this.end))return new e.Rule(a,d,k,h);i=c,q()}},"import":function(){var a;if(s(/^@import\s+/)&&(a=s(this.entities.quoted)||s(this.entities.url))&&s(";"))return new e.Import(a,o)},directive:function(){var a,d,f,g;if(b.charAt(c)==="@"){if(d=s(this["import"]))return d;if(a=s(/^@media|@page|@-[-a-z]+/)){g=(s(/^[^{]+/)||"").trim();if(f=s(this.block))return new e.Directive(a+" "+g,f)}else if(a=s(/^@[-a-z]+/))if(a==="@font-face"){if(f=s(this.block))return new e.Directive(a,f)}else if((d=s(this.entity))&&s(";"))return new e.Directive(a,d)}},font:function(){var a=[],b=[],c,d,f,g;while(g=s(this.shorthand)||s(this.entity))b.push(g);a.push(new e.Expression(b));if(s(","))while(g=s(this.expression)){a.push(g);if(!s(","))break}return new e.Value(a)},value:function(){var a,b=[],c;while(a=s(this.expression)){b.push(a);if(!s(","))break}if(b.length>0)return new e.Value(b)},important:function(){if(b.charAt(c)==="!")return s(/^! *important/)},sub:function(){var a;if(s("(")&&(a=s(this.expression))&&s(")"))return a},multiplication:function(){var a,b,c,d;if(a=s(this.operand)){while((c=s("/")||s("*"))&&(b=s(this.operand)))d=new e.Operation(c,[d||a,b]);return d||a}},addition:function(){var a,d,f,g;if(a=s(this.multiplication)){while((f=s(/^[-+]\s+/)||b.charAt(c-1)!=" "&&(s("+")||s("-")))&&(d=s(this.multiplication)))g=new e.Operation(f,[g||a,d]);return g||a}},operand:function(){var a,d=b.charAt(c+1);b.charAt(c)==="-"&&(d==="@"||d==="(")&&(a=s("-"));var f=s(this.sub)||s(this.entities.dimension)||s(this.entities.color)||s(this.entities.variable)||s(this.entities.call);return a?new e.Operation("*",[new e.Dimension(-1),f]):f},expression:function(){var a,b,c=[],d;while(a=s(this.addition)||s(this.entity))c.push(a);if(c.length>0)return new e.Expression(c)},property:function(){var a;if(a=s(/^(\*?-?[-a-z_0-9]+)\s*:/))return a[1]}}}},typeof a!="undefined"&&(d.Parser.importer=function(a,b,c,d){a.charAt(0)!=="/"&&b.length>0&&(a=b[0]+a),o({href:a,title:a,type:d.mime},c,!0)}),function(a){function d(a){return Math.min(1,Math.max(0,a))}function c(b){if(b instanceof a.Dimension)return parseFloat(b.unit=="%"?b.value/100:b.value);if(typeof b=="number")return b;throw{error:"RuntimeError",message:"color functions take numbers as parameters"}}function b(b){return a.functions.hsla(b.h,b.s,b.l,b.a)}a.functions={rgb:function(a,b,c){return this.rgba(a,b,c,1)},rgba:function(b,d,e,f){var g=[b,d,e].map(function(a){return c(a)}),f=c(f);return new a.Color(g,f)},hsl:function(a,b,c){return this.hsla(a,b,c,1)},hsla:function(a,b,d,e){function h(a){a=a<0?a+1:a>1?a-1:a;return a*6<1?g+(f-g)*a*6:a*2<1?f:a*3<2?g+(f-g)*(2/3-a)*6:g}a=c(a)%360/360,b=c(b),d=c(d),e=c(e);var f=d<=.5?d*(b+1):d+b-d*b,g=d*2-f;return this.rgba(h(a+1/3)*255,h(a)*255,h(a-1/3)*255,e)},hue:function(b){return new a.Dimension(Math.round(b.toHSL().h))},saturation:function(b){return new a.Dimension(Math.round(b.toHSL().s*100),"%")},lightness:function(b){return new a.Dimension(Math.round(b.toHSL().l*100),"%")},alpha:function(b){return new a.Dimension(b.toHSL().a)},saturate:function(a,c){var e=a.toHSL();e.s+=c.value/100,e.s=d(e.s);return b(e)},desaturate:function(a,c){var e=a.toHSL();e.s-=c.value/100,e.s=d(e.s);return b(e)},lighten:function(a,c){var e=a.toHSL();e.l+=c.value/100,e.l=d(e.l);return b(e)},darken:function(a,c){var e=a.toHSL();e.l-=c.value/100,e.l=d(e.l);return b(e)},fadein:function(a,c){var e=a.toHSL();e.a+=c.value/100,e.a=d(e.a);return b(e)},fadeout:function(a,c){var e=a.toHSL();e.a-=c.value/100,e.a=d(e.a);return b(e)},spin:function(a,c){var d=a.toHSL(),e=(d.h+c.value)%360;d.h=e<0?360+e:e;return b(d)},mix:function(b,c,d){var e=d.value/100,f=e*2-1,g=b.toHSL().a-c.toHSL().a,h=((f*g==-1?f:(f+g)/(1+f*g))+1)/2,i=1-h,j=[b.rgb[0]*h+c.rgb[0]*i,b.rgb[1]*h+c.rgb[1]*i,b.rgb[2]*h+c.rgb[2]*i],k=b.alpha*e+c.alpha*(1-e);return new a.Color(j,k)},greyscale:function(b){return this.desaturate(b,new a.Dimension(100))},e:function(b){return new a.Anonymous(b instanceof a.JavaScript?b.evaluated:b)},escape:function(b){return new a.Anonymous(encodeURI(b.value).replace(/=/g,"%3D").replace(/:/g,"%3A").replace(/#/g,"%23").replace(/;/g,"%3B").replace(/\(/g,"%28").replace(/\)/g,"%29"))},"%":function(b){var c=Array.prototype.slice.call(arguments,1),d=b.value;for(var e=0;e<c.length;e++)d=d.replace(/%[sda]/i,function(a){var b=a.match(/s/i)?c[e].value:c[e].toCSS();return a.match(/[A-Z]$/)?encodeURIComponent(b):b});d=d.replace(/%%/g,"%");return new a.Quoted('"'+d+'"',d)},round:function(b){if(b instanceof a.Dimension)return new a.Dimension(Math.round(c(b)),b.unit);if(typeof b=="number")return Math.round(b);throw{error:"RuntimeError",message:"math functions take numbers as parameters"}}}}(c("less/tree")),function(a){a.Alpha=function(a){this.value=a},a.Alpha.prototype={toCSS:function(){return"alpha(opacity="+(this.value.toCSS?this.value.toCSS():this.value)+")"},eval:function(a){this.value.eval&&(this.value=this.value.eval(a));return this}}}(c("less/tree")),function(a){a.Anonymous=function(a){this.value=a.value||a},a.Anonymous.prototype={toCSS:function(){return this.value},eval:function(){return this}}}(c("less/tree")),function(a){a.Call=function(a,b,c){this.name=a,this.args=b,this.index=c},a.Call.prototype={eval:function(b){var c=this.args.map(function(a){return a.eval(b)});if(!(this.name in a.functions))return new a.Anonymous(this.name+"("+c.map(function(a){return a.toCSS()}).join(", ")+")");try{return a.functions[this.name].apply(a.functions,c)}catch(d){throw{message:"error evaluating function `"+this.name+"`",index:this.index}}},toCSS:function(a){return this.eval(a).toCSS()}}}(c("less/tree")),function(a){a.Color=function(a,b){Array.isArray(a)?this.rgb=a:a.length==6?this.rgb=a.match(/.{2}/g).map(function(a){return parseInt(a,16)}):a.length==8?(this.alpha=parseInt(a.substring(0,2),16)/255,this.rgb=a.substr(2).match(/.{2}/g).map(function(a){return parseInt(a,16)})):this.rgb=a.split("").map(function(a){return parseInt(a+a,16)}),this.alpha=typeof b=="number"?b:1},a.Color.prototype={eval:function(){return this},toCSS:function(){return this.alpha<1?"rgba("+this.rgb.map(function(a){return Math.round(a)}).concat(this.alpha).join(", ")+")":"#"+this.rgb.map(function(a){a=Math.round(a),a=(a>255?255:a<0?0:a).toString(16);return a.length===1?"0"+a:a}).join("")},operate:function(b,c){var d=[];c instanceof a.Color||(c=c.toColor());for(var e=0;e<3;e++)d[e]=a.operate(b,this.rgb[e],c.rgb[e]);return new a.Color(d,this.alpha+c.alpha)},toHSL:function(){var a=this.rgb[0]/255,b=this.rgb[1]/255,c=this.rgb[2]/255,d=this.alpha,e=Math.max(a,b,c),f=Math.min(a,b,c),g,h,i=(e+f)/2,j=e-f;if(e===f)g=h=0;else{h=i>.5?j/(2-e-f):j/(e+f);switch(e){case a:g=(b-c)/j+(b<c?6:0);break;case b:g=(c-a)/j+2;break;case c:g=(a-b)/j+4}g/=6}return{h:g*360,s:h,l:i,a:d}}}}(c("less/tree")),function(a){a.Comment=function(a,b){this.value=a,this.silent=!!b},a.Comment.prototype={toCSS:function(a){return a.compress?"":this.value},eval:function(){return this}}}(c("less/tree")),function(a){a.Dimension=function(a,b){this.value=parseFloat(a),this.unit=b||null},a.Dimension.prototype={eval:function(){return this},toColor:function(){return new a.Color([this.value,this.value,this.value])},toCSS:function(){var a=this.value+this.unit;return a},operate:function(b,c){return new a.Dimension(a.operate(b,this.value,c.value),this.unit||c.unit)}}}(c("less/tree")),function(a){a.Directive=function(b,c){this.name=b,Array.isArray(c)?this.ruleset=new a.Ruleset([],c):this.value=c},a.Directive.prototype={toCSS:function(a,b){if(this.ruleset){this.ruleset.root=!0;return this.name+(b.compress?"{":" {\n  ")+this.ruleset.toCSS(a,b).trim().replace(/\n/g,"\n  ")+(b.compress?"}":"\n}\n")}return this.name+" "+this.value.toCSS()+";\n"},eval:function(a){a.frames.unshift(this),this.ruleset=this.ruleset&&this.ruleset.eval(a),a.frames.shift();return this},variable:function(b){return a.Ruleset.prototype.variable.call(this.ruleset,b)},find:function(){return a.Ruleset.prototype.find.apply(this.ruleset,arguments)},rulesets:function(){return a.Ruleset.prototype.rulesets.apply(this.ruleset)}}}(c("less/tree")),function(a){a.Element=function(b,c){this.combinator=b instanceof a.Combinator?b:new a.Combinator(b),this.value=c.trim()},a.Element.prototype.toCSS=function(a){return this.combinator.toCSS(a||{})+this.value},a.Combinator=function(a){a===" "?this.value=" ":this.value=a?a.trim():""},a.Combinator.prototype.toCSS=function(a){return{"":""," ":" ","&":"",":":" :","::":"::","+":a.compress?"+":" + ","~":a.compress?"~":" ~ ",">":a.compress?">":" > "}[this.value]}}(c("less/tree")),function(a){a.Expression=function(a){this.value=a},a.Expression.prototype={eval:function(b){return this.value.length>1?new a.Expression(this.value.map(function(a){return a.eval(b)})):this.value.length===1?this.value[0].eval(b):this},toCSS:function(a){return this.value.map(function(b){return b.toCSS(a)}).join(" ")}}}(c("less/tree")),function(a){a.Import=function(b,c){var d=this;this._path=b,b instanceof a.Quoted?this.path=/\.(le?|c)ss$/.test(b.value)?b.value:b.value+".less":this.path=b.value.value||b.value,this.css=/css$/.test(this.path),this.css||c.push(this.path,function(a){if(!a)throw new Error("Error parsing "+d.path);d.root=a})},a.Import.prototype={toCSS:function(){return this.css?"@import "+this._path.toCSS()+";\n":""},eval:function(b){var c;if(this.css)return this;c=new a.Ruleset(null,this.root.rules.slice(0));for(var d=0;d<c.rules.length;d++)c.rules[d]instanceof a.Import&&Array.prototype.splice.apply(c.rules,[d,1].concat(c.rules[d].eval(b)));return c.rules}}}(c("less/tree")),function(a){a.JavaScript=function(a,b,c){this.escaped=c,this.expression=a,this.index=b},a.JavaScript.prototype={eval:function(b){var c,d=this,e={},f=this.expression.replace(/@\{([\w-]+)\}/g,function(c,e){return a.jsify((new a.Variable("@"+e,d.index)).eval(b))});try{f=new Function("return ("+f+")")}catch(g){throw{message:"JavaScript evaluation error: `"+f+"`",index:this.index}}for(var h in b.frames[0].variables())e[h.slice(1)]={value:b.frames[0].variables()[h].value,toJS:function(){return this.value.eval(b).toCSS()}};try{c=f.call(e)}catch(g){throw{message:"JavaScript evaluation error: '"+g.name+": "+g.message+"'",index:this.index}}return typeof c=="string"?new a.Quoted('"'+c+'"',c,this.escaped,this.index):Array.isArray(c)?new a.Anonymous(c.join(", ")):new a.Anonymous(c)}}}(c("less/tree")),function(a){a.Keyword=function(a){this.value=a},a.Keyword.prototype={eval:function(){return this},toCSS:function(){return this.value}}}(c("less/tree")),function(a){a.mixin={},a.mixin.Call=function(b,c,d){this.selector=new a.Selector(b),this.arguments=c,this.index=d},a.mixin.Call.prototype={eval:function(a){var b,c,d=[],e=!1;for(var f=0;f<a.frames.length;f++)if((b=a.frames[f].find(this.selector)).length>0){c=this.arguments&&this.arguments.map(function(b){return b.eval(a)});for(var g=0;g<b.length;g++)if(b[g].match(c,a))try{Array.prototype.push.apply(d,b[g].eval(a,this.arguments).rules),e=!0}catch(h){throw{message:h.message,index:h.index,stack:h.stack,call:this.index}}if(e)return d;throw{message:"No matching definition was found for `"+this.selector.toCSS().trim()+"("+this.arguments.map(function(a){return a.toCSS()}).join(", ")+")`",index:this.index}}throw{message:this.selector.toCSS().trim()+" is undefined",index:this.index}}},a.mixin.Definition=function(b,c,d){this.name=b,this.selectors=[new a.Selector([new a.Element(null,b)])],this.params=c,this.arity=c.length,this.rules=d,this._lookups={},this.required=c.reduce(function(a,b){return!b.name||b.name&&!b.value?a+1:a},0),this.parent=a.Ruleset.prototype,this.frames=[]},a.mixin.Definition.prototype={toCSS:function(){return""},variable:function(a){return this.parent.variable.call(this,a)},variables:function(){return this.parent.variables.call(this)},find:function(){return this.parent.find.apply(this,arguments)},rulesets:function(){return this.parent.rulesets.apply(this)},eval:function(b,c){var d=new a.Ruleset(null,[]),e,f=[];for(var g=0,h;g<this.params.length;g++)if(this.params[g].name)if(h=c&&c[g]||this.params[g].value)d.rules.unshift(new a.Rule(this.params[g].name,h.eval(b)));else throw{message:"wrong number of arguments for "+this.name+" ("+c.length+" for "+this.arity+")"};for(var g=0;g<Math.max(this.params.length,c&&c.length);g++)f.push(c[g]||this.params[g].value);d.rules.unshift(new a.Rule("@arguments",(new a.Expression(f)).eval(b)));return(new a.Ruleset(null,this.rules.slice(0))).eval({frames:[this,d].concat(this.frames,b.frames)})},match:function(a,b){var c=a&&a.length||0,d;if(c<this.required)return!1;if(this.required>0&&c>this.params.length)return!1;d=Math.min(c,this.arity);for(var e=0;e<d;e++)if(!this.params[e].name&&a[e].eval(b).toCSS()!=this.params[e].value.eval(b).toCSS())return!1;return!0}}}(c("less/tree")),function(a){a.Operation=function(a,b){this.op=a.trim(),this.operands=b},a.Operation.prototype.eval=function(b){var c=this.operands[0].eval(b),d=this.operands[1].eval(b),e;if(c instanceof a.Dimension&&d instanceof a.Color)if(this.op==="*"||this.op==="+")e=d,d=c,c=e;else throw{name:"OperationError",message:"Can't substract or divide a color from a number"};return c.operate(this.op,d)},a.operate=function(a,b,c){switch(a){case"+":return b+c;case"-":return b-c;case"*":return b*c;case"/":return b/c}}}(c("less/tree")),function(a){a.Quoted=function(a,b,c,d){this.escaped=c,this.value=b||"",this.quote=a.charAt(0),this.index=d},a.Quoted.prototype={toCSS:function(){return this.escaped?this.value:this.quote+this.value+this.quote},eval:function(b){var c=this,d=this.value.replace(/`([^`]+)`/g,function(d,e){return(new a.JavaScript(e,c.index,!0)).eval(b).value}).replace(/@\{([\w-]+)\}/g,function(d,e){var f=(new a.Variable("@"+e,c.index)).eval(b);return f.value||f.toCSS()});return new a.Quoted(this.quote+d+this.quote,d,this.escaped,this.index)}}}(c("less/tree")),function(a){a.Rule=function(b,c,d,e){this.name=b,this.value=c instanceof a.Value?c:new a.Value([c]),this.important=d?" "+d.trim():"",this.index=e,b.charAt(0)==="@"?this.variable=!0:this.variable=!1},a.Rule.prototype.toCSS=function(a){return this.variable?"":this.name+(a.compress?":":": ")+this.value.toCSS(a)+this.important+";"},a.Rule.prototype.eval=function(b){return new a.Rule(this.name,this.value.eval(b),this.important,this.index)},a.Shorthand=function(a,b){this.a=a,this.b=b},a.Shorthand.prototype={toCSS:function(a){return this.a.toCSS(a)+"/"+this.b.toCSS(a)},eval:function(){return this}}}(c("less/tree")),function(a){a.Ruleset=function(a,b){this.selectors=a,this.rules=b,this._lookups={}},a.Ruleset.prototype={eval:function(b){var c=new a.Ruleset(this.selectors,this.rules.slice(0));c.root=this.root,b.frames.unshift(c);if(c.root)for(var d=0;d<c.rules.length;d++)c.rules[d]instanceof a.Import&&Array.prototype.splice.apply(c.rules,[d,1].concat(c.rules[d].eval(b)));for(var d=0;d<c.rules.length;d++)c.rules[d]instanceof a.mixin.Definition&&(c.rules[d].frames=b.frames.slice(0));for(var d=0;d<c.rules.length;d++)c.rules[d]instanceof a.mixin.Call&&Array.prototype.splice.apply(c.rules,[d,1].concat(c.rules[d].eval(b)));for(var d=0,e;d<c.rules.length;d++)e=c.rules[d],e instanceof a.mixin.Definition||(c.rules[d]=e.eval?e.eval(b):e);b.frames.shift();return c},match:function(a){return!a||a.length===0},variables:function(){return this._variables?this._variables:this._variables=this.rules.reduce(function(b,c){c instanceof a.Rule&&c.variable===!0&&(b[c.name]=c);return b},{})},variable:function(a){return this.variables()[a]},rulesets:function(){return this._rulesets?this._rulesets:this._rulesets=this.rules.filter(function(b){return b instanceof a.Ruleset||b instanceof a.mixin.Definition})},find:function(b,c){c=c||this;var d=[],e,f,g=b.toCSS();if(g in this._lookups)return this._lookups[g];this.rulesets().forEach(function(e){if(e!==c)for(var g=0;g<e.selectors.length;g++)if(f=b.match(e.selectors[g])){b.elements.length>1?Array.prototype.push.apply(d,e.find(new a.Selector(b.elements.slice(1)),c)):d.push(e);break}});return this._lookups[g]=d},toCSS:function(b,c){var d=[],e=[],f=[],g=[],h,i;if(!this.root)if(b.length===0)g=this.selectors.map(function(a){return[a]});else for(var j=0;j<this.selectors.length;j++)for(var k=0;k<b.length;k++)g.push(b[k].concat([this.selectors[j]]));for(var l=0;l<this.rules.length;l++)i=this.rules[l],i.rules||i instanceof a.Directive?f.push(i.toCSS(g,c)):i instanceof a.Comment?i.silent||(this.root?f.push(i.toCSS(c)):e.push(i.toCSS(c))):i.toCSS&&!i.variable?e.push(i.toCSS(c)):i.value&&!i.variable&&e.push(i.value.toString());f=f.join(""),this.root?d.push(e.join(c.compress?"":"\n")):e.length>0&&(h=g.map(function(a){return a.map(function(a){return a.toCSS(c)}).join("").trim()}).join(c.compress?",":g.length>3?",\n":", "),d.push(h,(c.compress?"{":" {\n  ")+e.join(c.compress?"":"\n  ")+(c.compress?"}":"\n}\n"))),d.push(f);return d.join("")+(c.compress?"\n":"")}}}(c("less/tree")),function(a){a.Selector=function(a){this.elements=a,this.elements[0].combinator.value===""&&(this.elements[0].combinator.value=" ")},a.Selector.prototype.match=function(a){return this.elements[0].value===a.elements[0].value?!0:!1},a.Selector.prototype.toCSS=function(a){if(this._css)return this._css;return this._css=this.elements.map(function(b){return typeof b=="string"?" "+b.trim():b.toCSS(a)}).join("")}}(c("less/tree")),function(b){b.URL=function(b,c){b.data?this.attrs=b:(!/^(?:https?:\/|file:\/|data:\/)?\//.test(b.value)&&c.length>0&&typeof a!="undefined"&&(b.value=c[0]+(b.value.charAt(0)==="/"?b.value.slice(1):b.value)),this.value=b,this.paths=c)},b.URL.prototype={toCSS:function(){return"url("+(this.attrs?"data:"+this.attrs.mime+this.attrs.charset+this.attrs.base64+this.attrs.data:this.value.toCSS())+")"},eval:function(a){return this.attrs?this:new b.URL(this.value.eval(a),this.paths)}}}(c("less/tree")),function(a){a.Value=function(a){this.value=a,this.is="value"},a.Value.prototype={eval:function(b){return this.value.length===1?this.value[0].eval(b):new a.Value(this.value.map(function(a){return a.eval(b)}))},toCSS:function(a){return this.value.map(function(b){return b.toCSS(a)}).join(a.compress?",":", ")}}}(c("less/tree")),function(a){a.Variable=function(a,b){this.name=a,this
  .index=b},a.Variable.prototype={eval:function(b){var c,d,e=this.name;e.indexOf("@@")==0&&(e="@"+(new a.Variable(e.slice(1))).eval(b).value);if(c=a.find(b.frames,function(a){if(d=a.variable(e))return d.value.eval(b)}))return c;throw{message:"variable "+e+" is undefined",index:this.index}}}}(c("less/tree")),c("less/tree").find=function(a,b){for(var c=0,d;c<a.length;c++)if(d=b.call(a,a[c]))return d;return null},c("less/tree").jsify=function(a){return Array.isArray(a.value)&&a.value.length>1?"["+a.value.map(function(a){return a.toCSS(!1)}).join(", ")+"]":a.toCSS(!1)};var g=location.protocol==="file:"||location.protocol==="chrome:"||location.protocol==="chrome-extension:"||location.protocol==="resource:";d.env=d.env||(location.hostname=="127.0.0.1"||location.hostname=="0.0.0.0"||location.hostname=="localhost"||location.port.length>0||g?"development":"production"),d.async=!1,d.poll=d.poll||(g?1e3:1500),d.watch=function(){return this.watchMode=!0},d.unwatch=function(){return this.watchMode=!1},d.env==="development"?(d.optimization=0,/!watch/.test(location.hash)&&d.watch(),d.watchTimer=setInterval(function(){d.watchMode&&n(function(a,b,c){a&&q(a.toCSS(),b,c.lastModified)})},d.poll)):d.optimization=3;var h;try{h=typeof a.localStorage=="undefined"?null:a.localStorage}catch(i){h=null}var j=document.getElementsByTagName("link"),k=/^text\/(x-)?less$/;d.sheets=[];for(var l=0;l<j.length;l++)(j[l].rel==="stylesheet/less"||j[l].rel.match(/stylesheet/)&&j[l].type.match(k))&&d.sheets.push(j[l]);d.refresh=function(a){var b,c;b=c=new Date,n(function(a,d,e){e.local?u("loading "+d.href+" from cache."):(u("parsed "+d.href+" successfully."),q(a.toCSS(),d,e.lastModified)),u("css for "+d.href+" generated in "+(new Date-c)+"ms"),e.remaining===0&&u("css generated in "+(new Date-b)+"ms"),c=new Date},a),m()},d.refreshStyles=m,d.refresh(d.env==="development")})(window)
---
file: htdocs/common/less/bootstrap.less
template: |-
  /*!
   * Bootstrap @VERSION
   *
   * Copyright 2011 Twitter, Inc
   * Licensed under the Apache License v2.0
   * http://www.apache.org/licenses/LICENSE-2.0
   *
   * Designed and built with all the love in the world @twitter by @mdo and @fat.
   * Date: @DATE
   */
  
  // CSS Reset
  @import "reset.less";
  
  // Core variables and mixins
  @import "variables.less"; // Modify this for custom colors, font-sizes, etc
  @import "mixins.less";
  
  // Grid system and page structure
  @import "scaffolding.less";
  
  // Styled patterns and elements
  @import "type.less";
  @import "forms.less";
  @import "tables.less";
  @import "patterns.less";
---
file: htdocs/common/less/forms.less
template: |
  /* Forms.less
   * Base styles for various input types, form layouts, and states
   * ------------------------------------------------------------- */
  
  
  // FORM STYLES
  // -----------
  
  form {
    margin-bottom: @baseline;
  }
  
  // Groups of fields with labels on top (legends)
  fieldset {
    margin-bottom: @baseline;
    padding-top: @baseline;
    legend {
      display: block;
      padding-left: 150px;
      font-size: @basefont * 1.5;
      line-height: 1;
      color: @grayDark;
      *padding: 0 0 5px 145px; /* IE6-7 */
      *line-height: 1.5; /* IE6-7 */
    }
  }
  
  // Parent element that clears floats and wraps labels and fields together
  form .clearfix {
    margin-bottom: @baseline;
    .clearfix()
  }
  
  // Set font for forms
  label,
  input,
  select,
  textarea {
    #font > .sans-serif(normal,13px,normal);
  }
  
  // Float labels left
  label {
    padding-top: 6px;
    font-size: @basefont;
    line-height: @baseline;
    float: left;
    width: 130px;
    text-align: right;
    color: @grayDark;
  }
  
  // Shift over the inside div to align all label's relevant content
  form .input {
    margin-left: 150px;
  }
  
  // Checkboxs and radio buttons
  input[type=checkbox],
  input[type=radio] {
    cursor: pointer;
  }
  
  // Inputs, Textareas, Selects
  input,
  textarea,
  select,
  .uneditable-input {
    display: inline-block;
    width: 210px;
    height: @baseline;
    padding: 4px;
    font-size: @basefont;
    line-height: @baseline;
    color: @gray;
    border: 1px solid #ccc;
    .border-radius(3px);
  }
  
  // remove padding from select
  select {
    padding: initial;
  }
  
  // mini reset for non-html5 file types
  input[type=checkbox],
  input[type=radio] {
    width: auto;
    height: auto;
    padding: 0;
    margin: 3px 0;
    *margin-top: 0; /* IE6-7 */
    line-height: normal;
    border: none;
  }
  
  input[type=file] {
    background-color: @white;
    padding: initial;
    border: initial;
    line-height: initial;
    .box-shadow(none);
  }
  
  input[type=button],
  input[type=reset],
  input[type=submit] {
    width: auto;
    height: auto;
  }
  
  select,
  input[type=file] {
    height: @baseline * 1.5; // In IE7, the height of the select element cannot be changed by height, only font-size
    *height: auto; // Reset for IE7
    line-height: @baseline * 1.5;
    *margin-top: 4px; /* For IE7, add top margin to align select with labels */
  }
  
  // Make multiple select elements height not fixed
  select[multiple] {
    height: inherit;
    background-color: @white; // Fixes Chromium bug of unreadable items
  }
  
  textarea {
    height: auto;
  }
  
  // For text that needs to appear as an input but should not be an input
  .uneditable-input {
    background-color: @white;
    display: block;
    border-color: #eee;
    .box-shadow(inset 0 1px 2px rgba(0,0,0,.025));
    cursor: not-allowed;
  }
  
  // Placeholder text gets special styles; can't be bundled together though for some reason
  :-moz-placeholder {
    color: @grayLight;
  }
  ::-webkit-input-placeholder {
    color: @grayLight;
  }
  
  // Focus states
  input,
  textarea {
    @transition: border linear .2s, box-shadow linear .2s;
    .transition(@transition);
    .box-shadow(inset 0 1px 3px rgba(0,0,0,.1));
  }
  input:focus,
  textarea:focus {
    outline: 0;
    border-color: rgba(82,168,236,.8);
    @shadow: inset 0 1px 3px rgba(0,0,0,.1), 0 0 8px rgba(82,168,236,.6);
    .box-shadow(@shadow);
  }
  input[type=file]:focus,
  input[type=checkbox]:focus,
  select:focus {
    .box-shadow(none); // override for file inputs
    outline: 1px dotted #666; // Selet elements don't get box-shadow styles, so instead we do outline
  }
  
  
  // FORM FIELD FEEDBACK STATES
  // --------------------------
  
  // Mixin for form field states
  .formFieldState(@textColor: #555, @borderColor: #ccc, @backgroundColor: #f5f5f5) {
    // Set the text color
    > label,
    .help-block,
    .help-inline {
      color: @textColor;
    }
    // Style inputs accordingly
    input,
    textarea {
      color: @textColor;
      border-color: @borderColor;
      &:focus {
        border-color: darken(@borderColor, 10%);
        .box-shadow(0 0 6px lighten(@borderColor, 20%));
      }
    }
    // Give a small background color for input-prepend/-append
    .input-prepend .add-on,
    .input-append .add-on {
      color: @textColor;
      background-color: @backgroundColor;
      border-color: @textColor;
    }
  }
  // Error
  form .clearfix.error {
    .formFieldState(#b94a48, #ee5f5b, lighten(#ee5f5b, 30%));
  }
  // Warning
  form .clearfix.warning {
    .formFieldState(#c09853, #ccae64, lighten(#CCAE64, 5%));
  }
  // Success
  form .clearfix.success {
    .formFieldState(#468847, #57a957, lighten(#57a957, 30%));
  }
  
  
  // Form element sizes
  // TODO v2: remove duplication here and just stick to .input-[size] in light of adding .spanN sizes
  .input-mini,
  input.mini,
  textarea.mini,
  select.mini {
    width: 60px;
  }
  .input-small,
  input.small,
  textarea.small,
  select.small {
    width: 90px;
  }
  .input-medium,
  input.medium,
  textarea.medium,
  select.medium {
    width: 150px;
  }
  .input-large,
  input.large,
  textarea.large,
  select.large {
    width: 210px;
  }
  .input-xlarge,
  input.xlarge,
  textarea.xlarge,
  select.xlarge {
    width: 270px;
  }
  .input-xxlarge,
  input.xxlarge,
  textarea.xxlarge,
  select.xxlarge {
    width: 530px;
  }
  textarea.xxlarge {
    overflow-y: auto;
  }
  
  // Grid style input sizes
  // This is a duplication of the main grid .columns() mixin, but subtracts 10px to account for input padding and border
  .formColumns(@columnSpan: 1) {
    display: inline-block;
    float: none;
    width: ((@gridColumnWidth) * @columnSpan) + (@gridGutterWidth * (@columnSpan - 1)) - 10;
    margin-left: 0;
  }
  input,
  textarea {
    // Default columns
    &.span1     { .formColumns(1); }
    &.span2     { .formColumns(2); }
    &.span3     { .formColumns(3); }
    &.span4     { .formColumns(4); }
    &.span5     { .formColumns(5); }
    &.span6     { .formColumns(6); }
    &.span7     { .formColumns(7); }
    &.span8     { .formColumns(8); }
    &.span9     { .formColumns(9); }
    &.span10    { .formColumns(10); }
    &.span11    { .formColumns(11); }
    &.span12    { .formColumns(12); }
    &.span13    { .formColumns(13); }
    &.span14    { .formColumns(14); }
    &.span15    { .formColumns(15); }
    &.span16    { .formColumns(16); }
  }
  
  // Disabled and read-only inputs
  input[disabled],
  select[disabled],
  textarea[disabled],
  input[readonly],
  select[readonly],
  textarea[readonly] {
    background-color: #f5f5f5;
    border-color: #ddd;
    cursor: not-allowed;
  }
  
  // Actions (the buttons)
  .actions {
    background: #f5f5f5;
    margin-top: @baseline;
    margin-bottom: @baseline;
    padding: (@baseline - 1) 20px @baseline 150px;
    border-top: 1px solid #ddd;
    .border-radius(0 0 3px 3px);
    .secondary-action {
      float: right;
      a {
        line-height: 30px;
        &:hover {
          text-decoration: underline;
        }
      }
    }
  }
  
  // Help Text
  // TODO: Do we need to set basefont and baseline here?
  .help-inline,
  .help-block {
    font-size: @basefont;
    line-height: @baseline;
    color: @grayLight;
  }
  .help-inline {
    padding-left: 5px;
    *position: relative; /* IE6-7 */
    *top: -5px; /* IE6-7 */
  }
  
  // Big blocks of help text
  .help-block {
    display: block;
    max-width: 600px;
  }
  
  // Inline Fields (input fields that appear as inline objects
  .inline-inputs {
    color: @gray;
    span {
      padding: 0 2px 0 1px;
    }
  }
  
  // Allow us to put symbols and text within the input field for a cleaner look
  .input-prepend,
  .input-append {
    input {
      .border-radius(0 3px 3px 0);
    }
    .add-on {
      position: relative;
      background: #f5f5f5;
      border: 1px solid #ccc;
      z-index: 2;
      float: left;
      display: block;
      width: auto;
      min-width: 16px;
      height: 18px;
      padding: 4px 4px 4px 5px;
      margin-right: -1px;
      font-weight: normal;
      line-height: 18px;
      color: @grayLight;
      text-align: center;
      text-shadow: 0 1px 0 @white;
      .border-radius(3px 0 0 3px);
    }
    .active {
      background: lighten(@green, 30);
      border-color: @green;
    }
  }
  .input-prepend {
    .add-on {
      *margin-top: 1px; /* IE6-7 */
    }
  }
  .input-append {
    input {
      float: left;
      .border-radius(3px 0 0 3px);
    }
    .add-on {
      .border-radius(0 3px 3px 0);
      margin-right: 0;
      margin-left: -1px;
    }
  }
  
  // Stacked options for forms (radio buttons or checkboxes)
  .inputs-list {
    margin: 0 0 5px;
    width: 100%;
    li {
      display: block;
      padding: 0;
      width: 100%;
    }
    label {
      display: block;
      float: none;
      width: auto;
      padding: 0;
      margin-left: 20px;
      line-height: @baseline;
      text-align: left;
      white-space: normal;
      strong {
        color: @gray;
      }
      small {
        font-size: @basefont - 2;
        font-weight: normal;
      }
    }
    .inputs-list {
      margin-left: 25px;
      margin-bottom: 10px;
      padding-top: 0;
    }
    &:first-child {
      padding-top: 6px;
    }
    li + li {
      padding-top: 2px;
    }
    input[type=radio],
    input[type=checkbox] {
      margin-bottom: 0;
      margin-left: -20px;
      float: left;
    }
  }
  
  // Stacked forms
  .form-stacked {
    padding-left: 20px;
    fieldset {
      padding-top: @baseline / 2;
    }
    legend {
      padding-left: 0;
    }
    label {
      display: block;
      float: none;
      width: auto;
      font-weight: bold;
      text-align: left;
      line-height: 20px;
      padding-top: 0;
    }
    .clearfix {
      margin-bottom: @baseline / 2;
      div.input {
        margin-left: 0;
      }
    }
    .inputs-list {
      margin-bottom: 0;
      li {
        padding-top: 0;
        label {
          font-weight: normal;
          padding-top: 0;
        }
      }
    }
    div.clearfix.error {
      padding-top: 10px;
      padding-bottom: 10px;
      padding-left: 10px;
      margin-top: 0;
      margin-left: -10px;
    }
    .actions {
      margin-left: -20px;
      padding-left: 20px;
    }
  }
---
file: htdocs/common/less/mixins.less
template: |-
  /* Mixins.less
   * Snippets of reusable CSS to develop faster and keep code readable
   * ----------------------------------------------------------------- */
  
  
  // Clearfix for clearing floats like a boss h5bp.com/q
  .clearfix() {
    zoom: 1;
    &:before,
    &:after {
      display: table;
      content: "";
      zoom: 1;
    }
    &:after {
      clear: both;
    }
  }
  
  // Center-align a block level element
  .center-block() {
    display: block;
    margin-left: auto;
    margin-right: auto;
  }
  
  // Sizing shortcuts
  .size(@height: 5px, @width: 5px) {
    height: @height;
    width: @width;
  }
  .square(@size: 5px) {
    .size(@size, @size);
  }
  
  // Input placeholder text
  .placeholder(@color: @grayLight) {
    :-moz-placeholder {
      color: @color;
    }
    ::-webkit-input-placeholder {
      color: @color;
    }
  }
  
  // Font Stacks
  #font {
    .shorthand(@weight: normal, @size: 14px, @lineHeight: 20px) {
      font-size: @size;
      font-weight: @weight;
      line-height: @lineHeight;
    }
    .sans-serif(@weight: normal, @size: 14px, @lineHeight: 20px) {
      font-family: "Helvetica Neue", Helvetica, Arial, sans-serif;
      font-size: @size;
      font-weight: @weight;
      line-height: @lineHeight;
    }
    .serif(@weight: normal, @size: 14px, @lineHeight: 20px) {
      font-family: "Georgia", Times New Roman, Times, serif;
      font-size: @size;
      font-weight: @weight;
      line-height: @lineHeight;
    }
    .monospace(@weight: normal, @size: 12px, @lineHeight: 20px) {
      font-family: "Monaco", Courier New, monospace;
      font-size: @size;
      font-weight: @weight;
      line-height: @lineHeight;
    }
  }
  
  // Grid System
  .fixed-container() {
    width: @siteWidth;
    margin-left: auto;
    margin-right: auto;
    .clearfix();
  }
  .columns(@columnSpan: 1) {
    width: (@gridColumnWidth * @columnSpan) + (@gridGutterWidth * (@columnSpan - 1));
  }
  .offset(@columnOffset: 1) {
    margin-left: (@gridColumnWidth * @columnOffset) + (@gridGutterWidth * (@columnOffset - 1)) + @extraSpace;
  }
  // Necessary grid styles for every column to make them appear next to each other horizontally
  .gridColumn() {
    display: inline;
    float: left;
    margin-left: @gridGutterWidth;
  }
  // makeColumn can be used to mark any element (e.g., .content-primary) as a column without changing markup to .span something
  .makeColumn(@columnSpan: 1) {
    .gridColumn();
    .columns(@columnSpan);
  }
  
  // Border Radius
  .border-radius(@radius: 5px) {
    -webkit-border-radius: @radius;
       -moz-border-radius: @radius;
            border-radius: @radius;
  }
  
  // Drop shadows
  .box-shadow(@shadow: 0 1px 3px rgba(0,0,0,.25)) {
    -webkit-box-shadow: @shadow;
       -moz-box-shadow: @shadow;
            box-shadow: @shadow;
  }
  
  // Transitions
  .transition(@transition) {
       -webkit-transition: @transition;
          -moz-transition: @transition;
           -ms-transition: @transition;
            -o-transition: @transition;
               transition: @transition;
  }
  
  // Background clipping
  .background-clip(@clip) {
    -webkit-background-clip: @clip;
       -moz-background-clip: @clip;
            background-clip: @clip;
  }
  
  // CSS3 Content Columns
  .content-columns(@columnCount, @columnGap: 20px) {
    -webkit-column-count: @columnCount;
       -moz-column-count: @columnCount;
            column-count: @columnCount;
    -webkit-column-gap: @columnGap;
       -moz-column-gap: @columnGap;
            column-gap: @columnGap;
  }
  
  // Make any element resizable for prototyping
  .resizable(@direction: both) {
    resize: @direction; // Options are horizontal, vertical, both
    overflow: auto; // Safari fix
  }
  
  // Add an alphatransparency value to any background or border color (via Elyse Holladay)
  #translucent {
    .background(@color: @white, @alpha: 1) {
      background-color: hsla(hue(@color), saturation(@color), lightness(@color), @alpha);
    }
    .border(@color: @white, @alpha: 1) {
      border-color: hsla(hue(@color), saturation(@color), lightness(@color), @alpha);
      background-clip: padding-box;
    }
  }
  
  // Gradient Bar Colors for buttons and allerts
  .gradientBar(@primaryColor, @secondaryColor) {
    #gradient > .vertical(@primaryColor, @secondaryColor);
    text-shadow: 0 -1px 0 rgba(0,0,0,.25);
    border-color: @secondaryColor @secondaryColor darken(@secondaryColor, 15%);
    border-color: rgba(0,0,0,.1) rgba(0,0,0,.1) fadein(rgba(0,0,0,.1), 15%);
  }
  
  // Gradients
  #gradient {
    .horizontal (@startColor: #555, @endColor: #333) {
      background-color: @endColor;
      background-repeat: repeat-x;
      background-image: -khtml-gradient(linear, left top, right top, from(@startColor), to(@endColor)); // Konqueror
      background-image: -moz-linear-gradient(left, @startColor, @endColor); // FF 3.6+
      background-image: -ms-linear-gradient(left, @startColor, @endColor); // IE10
      background-image: -webkit-gradient(linear, left top, right top, color-stop(0%, @startColor), color-stop(100%, @endColor)); // Safari 4+, Chrome 2+
      background-image: -webkit-linear-gradient(left, @startColor, @endColor); // Safari 5.1+, Chrome 10+
      background-image: -o-linear-gradient(left, @startColor, @endColor); // Opera 11.10
      background-image: linear-gradient(left, @startColor, @endColor); // Le standard
      filter: e(%("progid:DXImageTransform.Microsoft.gradient(startColorstr='%d', endColorstr='%d', GradientType=1)",@startColor,@endColor)); // IE9 and down
    }
    .vertical (@startColor: #555, @endColor: #333) {
      background-color: @endColor;
      background-repeat: repeat-x;
      background-image: -khtml-gradient(linear, left top, left bottom, from(@startColor), to(@endColor)); // Konqueror
      background-image: -moz-linear-gradient(top, @startColor, @endColor); // FF 3.6+
      background-image: -ms-linear-gradient(top, @startColor, @endColor); // IE10
      background-image: -webkit-gradient(linear, left top, left bottom, color-stop(0%, @startColor), color-stop(100%, @endColor)); // Safari 4+, Chrome 2+
      background-image: -webkit-linear-gradient(top, @startColor, @endColor); // Safari 5.1+, Chrome 10+
      background-image: -o-linear-gradient(top, @startColor, @endColor); // Opera 11.10
      background-image: linear-gradient(top, @startColor, @endColor); // The standard
      filter: e(%("progid:DXImageTransform.Microsoft.gradient(startColorstr='%d', endColorstr='%d', GradientType=0)",@startColor,@endColor)); // IE9 and down
    }
    .directional (@startColor: #555, @endColor: #333, @deg: 45deg) {
      background-color: @endColor;
      background-repeat: repeat-x;
      background-image: -moz-linear-gradient(@deg, @startColor, @endColor); // FF 3.6+
      background-image: -ms-linear-gradient(@deg, @startColor, @endColor); // IE10
      background-image: -webkit-linear-gradient(@deg, @startColor, @endColor); // Safari 5.1+, Chrome 10+
      background-image: -o-linear-gradient(@deg, @startColor, @endColor); // Opera 11.10
      background-image: linear-gradient(@deg, @startColor, @endColor); // The standard
    }
    .vertical-three-colors(@startColor: #00b3ee, @midColor: #7a43b6, @colorStop: 50%, @endColor: #c3325f) {
      background-color: @endColor;
      background-repeat: no-repeat;
      background-image: -webkit-gradient(linear, 0 0, 0 100%, from(@startColor), color-stop(@colorStop, @midColor), to(@endColor));
      background-image: -webkit-linear-gradient(@startColor, @midColor @colorStop, @endColor);
      background-image: -moz-linear-gradient(top, @startColor, @midColor @colorStop, @endColor);
      background-image: -ms-linear-gradient(@startColor, @midColor @colorStop, @endColor);
      background-image: -o-linear-gradient(@startColor, @midColor @colorStop, @endColor);
      background-image: linear-gradient(@startColor, @midColor @colorStop, @endColor);
      filter: e(%("progid:DXImageTransform.Microsoft.gradient(startColorstr='%d', endColorstr='%d', GradientType=0)",@startColor,@endColor)); // IE9 and down, gets no color-stop at all for proper fallback
    }
  }
  
  // Reset filters for IE
  .reset-filter() {
    filter: e(%("progid:DXImageTransform.Microsoft.gradient(enabled = false)"));
  }
  
  // Opacity
  .opacity(@opacity: 100) {
    filter: e(%("alpha(opacity=%d)", @opacity));
    -khtml-opacity: @opacity / 100;
      -moz-opacity: @opacity / 100;
           opacity: @opacity / 100;
  }
---
file: htdocs/common/less/patterns.less
template: |
  /* Patterns.less
   * Repeatable UI elements outside the base styles provided from the scaffolding
   * ---------------------------------------------------------------------------- */
  
  
  // TOPBAR
  // ------
  
  // Topbar for Branding and Nav
  .topbar {
    height: 40px;
    position: fixed;
    top: 0;
    left: 0;
    right: 0;
    z-index: 10000;
    overflow: visible;
  
    // Links get text shadow
    a {
      color: @grayLight;
      text-shadow: 0 -1px 0 rgba(0,0,0,.25);
    }
  
    // Hover and active states
    // h3 for backwards compatibility
    h3 a:hover,
    .brand:hover,
    ul .active > a {
      background-color: #333;
      background-color: rgba(255,255,255,.05);
      color: @white;
      text-decoration: none;
    }
  
    // Website name
    // h3 left for backwards compatibility
    h3 {
      position: relative;
    }
    h3 a,
    .brand {
      float: left;
      display: block;
      padding: 8px 20px 12px;
      margin-left: -20px; // negative indent to left-align the text down the page
      color: @white;
      font-size: 20px;
      font-weight: 200;
      line-height: 1;
    }
  
    // Plain text in topbar
    p {
      margin: 0;
      line-height: 40px;
      a:hover {
        background-color: transparent;
        color: @white;
      }
    }
  
    // Search Form
    form {
      float: left;
      margin: 5px 0 0 0;
      position: relative;
      .opacity(100);
    }
    // Todo: remove from v2.0 when ready, added for legacy
    form.pull-right {
      float: right;
    }
    input {
      background-color: #444;
      background-color: rgba(255,255,255,.3);
      #font > .sans-serif(13px, normal, 1);
      padding: 4px 9px;
      color: @white;
      color: rgba(255,255,255,.75);
      border: 1px solid #111;
      .border-radius(4px);
      @shadow: inset 0 1px 2px rgba(0,0,0,.1), 0 1px 0px rgba(255,255,255,.25);
      .box-shadow(@shadow);
      .transition(none);
  
      // Placeholder text gets special styles; can't be bundled together though for some reason
      &:-moz-placeholder {
        color: @grayLighter;
      }
      &::-webkit-input-placeholder {
        color: @grayLighter;
      }
      // Hover states
      &:hover {
        background-color: @grayLight;
        background-color: rgba(255,255,255,.5);
        color: @white;
      }
      // Focus states (we use .focused since IE8 and down doesn't support :focus)
      &:focus,
      &.focused {
        outline: 0;
        background-color: @white;
        color: @grayDark;
        text-shadow: 0 1px 0 @white;
        border: 0;
        padding: 5px 10px;
        .box-shadow(0 0 3px rgba(0,0,0,.15));
      }
    }
  }
  
  // gradient is applied to it's own element because overflow visible is not honored by ie when filter is present
  // For backwards compatibility, include .topbar .fill
  .topbar-inner,
  .topbar .fill {
    background-color: #222;
    #gradient > .vertical(#333, #222);
    @shadow: 0 1px 3px rgba(0,0,0,.25), inset 0 -1px 0 rgba(0,0,0,.1);
    .box-shadow(@shadow);
  }
  
  
  // NAVIGATION
  // ----------
  
  // Topbar Nav
  // ul.nav for all topbar based navigation to avoid inheritance issues and over-specificity
  // For backwards compatibility, leave in .topbar div > ul
  .topbar div > ul,
  .nav {
    display: block;
    float: left;
    margin: 0 10px 0 0;
    position: relative;
    left: 0;
    > li {
      display: block;
      float: left;
    }
    a {
      display: block;
      float: none;
      padding: 10px 10px 11px;
      line-height: 19px;
      text-decoration: none;
      &:hover {
        color: @white;
        text-decoration: none;
      }
    }
    .active > a {
      background-color: #222;
      background-color: rgba(0,0,0,.5);
    }
  
    // Secondary (floated right) nav in topbar
    &.secondary-nav {
      float: right;
      margin-left: 10px;
      margin-right: 0;
      // backwards compatibility
      .menu-dropdown,
      .dropdown-menu {
        right: 0;
        border: 0;
      }
    }
    // Dropdowns within the .nav
    // a.menu:hover and li.open .menu for backwards compatibility
    a.menu:hover,
    li.open .menu,
    .dropdown-toggle:hover,
    .dropdown.open .dropdown-toggle {
      background: #444;
      background: rgba(255,255,255,.05);
    }
    // .menu-dropdown for backwards compatibility
    .menu-dropdown,
    .dropdown-menu {
      background-color: #333;
      // a.menu for backwards compatibility
      a.menu,
      .dropdown-toggle {
        color: @white;
        &.open {
          background: #444;
          background: rgba(255,255,255,.05);
        }
      }
      li a {
        color: #999;
        text-shadow: 0 1px 0 rgba(0,0,0,.5);
        &:hover {
          #gradient > .vertical(#292929,#191919);
          color: @white;
        }
      }
      .active a {
        color: @white;
      }
      .divider {
        background-color: #222;
        border-color: #444;
      }
    }
  }
  
  // For backwards compatibility with new dropdowns, redeclare dropdown link padding
  .topbar ul .menu-dropdown li a,
  .topbar ul .dropdown-menu li a {
    padding: 4px 15px;
  }
  
  // Dropdown Menus
  // Use the .menu class on any <li> element within the topbar or ul.tabs and you'll get some superfancy dropdowns
  // li.menu for backwards compatibility
  li.menu,
  .dropdown {
    position: relative;
  }
  // The link that is clicked to toggle the dropdown
  // a.menu for backwards compatibility
  a.menu:after,
  .dropdown-toggle:after {
    width: 0;
    height: 0;
    display: inline-block;
    content: "&darr;";
    text-indent: -99999px;
    vertical-align: top;
    margin-top: 8px;
    margin-left: 4px;
    border-left: 4px solid transparent;
    border-right: 4px solid transparent;
    border-top: 4px solid @white;
    .opacity(50);
  }
  // The dropdown menu (ul)
  // .menu-dropdown for backwards compatibility
  .menu-dropdown,
  .dropdown-menu {
    background-color: @white;
    float: left;
    display: none; // None by default, but block on "open" of the menu
    position: absolute;
    top: 40px;
    z-index: 900;
    min-width: 160px;
    max-width: 220px;
    _width: 160px;
    margin-left: 0; // override default ul styles
    margin-right: 0;
    padding: 6px 0;
    zoom: 1; // do we need this?
    border-color: #999;
    border-color: rgba(0,0,0,.2);
    border-style: solid;
    border-width: 0 1px 1px;
    .border-radius(0 0 6px 6px);
    .box-shadow(0 2px 4px rgba(0,0,0,.2));
    .background-clip(padding-box);
  
    // Unfloat any li's to make them stack
    li {
      float: none;
      display: block;
      background-color: none;
    }
    // Dividers (basically an hr) within the dropdown
    .divider {
      height: 1px;
      margin: 5px 0;
      overflow: hidden;
      background-color: #eee;
      border-bottom: 1px solid @white;
    }
  }
  
  .topbar .dropdown-menu,
  .dropdown-menu {
    // Links within the dropdown menu
    a {
      display: block;
      padding: 4px 15px;
      clear: both;
      font-weight: normal;
      line-height: 18px;
      color: @gray;
      text-shadow: 0 1px 0 @white;
      // Hover state
      &:hover,
      &.hover {
        #gradient > .vertical(#eeeeee, #dddddd);
        color: @grayDark;
        text-decoration: none;
        @shadow: inset 0 1px 0 rgba(0,0,0,.025), inset 0 -1px rgba(0,0,0,.025);
        .box-shadow(@shadow);
      }
    }
  }
  
  // Open state for the dropdown
  // .open for backwards compatibility
  .open,
  .dropdown.open {
    // .menu for backwards compatibility
    .menu,
    .dropdown-toggle {
      color: @white;
      background: #ccc;
      background: rgba(0,0,0,.3);
    }
    // .menu-dropdown for backwards compatibility
    .menu-dropdown,
    .dropdown-menu {
      display: block;
    }
  }
  
  
  // TABS AND PILLS
  // --------------
  
  // Common styles
  .tabs,
  .pills {
    margin: 0 0 @baseline;
    padding: 0;
    list-style: none;
    .clearfix();
    > li {
      float: left;
      > a {
        display: block;
      }
    }
  }
  
  // Tabs
  .tabs {
    border-color: #ddd;
    border-style: solid;
    border-width: 0 0 1px;
    > li {
      position: relative; // For the dropdowns mostly
      margin-bottom: -1px;
      > a {
        padding: 0 15px;
        margin-right: 2px;
        line-height: (@baseline * 2) - 2;
        border: 1px solid transparent;
        .border-radius(4px 4px 0 0);
        &:hover {
          text-decoration: none;
          background-color: #eee;
          border-color: #eee #eee #ddd;
        }
      }
    }
    // Active state, and it's :hover to override normal :hover
    .active > a,
    .active > a:hover {
      color: @gray;
      background-color: @white;
      border: 1px solid #ddd;
      border-bottom-color: transparent;
      cursor: default;
    }
  }
  
  // Dropdowns in tabs
  .tabs {
    // first one for backwards compatibility
    .menu-dropdown,
    .dropdown-menu {
      top: 35px;
      border-width: 1px;
      .border-radius(0 6px 6px 6px);
    }
    // first one for backwards compatibility
    a.menu:after,
    .dropdown-toggle:after {
      border-top-color: #999;
      margin-top: 15px;
      margin-left: 5px;
    }
    // first one for backwards compatibility
    li.open.menu .menu,
    .open.dropdown .dropdown-toggle {
      border-color: #999;
    }
    // first one for backwards compatibility
    li.open a.menu:after,
    .dropdown.open .dropdown-toggle:after {
      border-top-color: #555;
    }
  }
  
  // Pills
  .pills {
    a {
      margin: 5px 3px 5px 0;
      padding: 0 15px;
      line-height: 30px;
      text-shadow: 0 1px 1px @white;
      .border-radius(15px);
      &:hover {
        color: @white;
        text-decoration: none;
        text-shadow: 0 1px 1px rgba(0,0,0,.25);
        background-color: @linkColorHover;
      }
    }
    .active a {
      color: @white;
      text-shadow: 0 1px 1px rgba(0,0,0,.25);
      background-color: @linkColor;
    }
  }
  
  // Stacked pills
  .pills-vertical > li {
    float: none;
  }
  
  // Tabbable areas
  .tab-content,
  .pill-content {
  }
  .tab-content > .tab-pane,
  .pill-content > .pill-pane,
  .tab-content > div,
  .pill-content > div {
    display: none;
  }
  .tab-content > .active,
  .pill-content > .active {
    display: block;
  }
  
  
  // BREADCRUMBS
  // -----------
  
  .breadcrumb {
    padding: 7px 14px;
    margin: 0 0 @baseline;
    #gradient > .vertical(#ffffff, #f5f5f5);
    border: 1px solid #ddd;
    .border-radius(3px);
    .box-shadow(inset 0 1px 0 @white);
    li {
      display: inline;
      text-shadow: 0 1px 0 @white;
    }
    .divider {
      padding: 0 5px;
      color: @grayLight;
    }
    .active a {
      color: @grayDark;
    }
  }
  
  
  // PAGE HEADERS
  // ------------
  
  .hero-unit {
    background-color: #f5f5f5;
    margin-bottom: 30px;
    padding: 60px;
    .border-radius(6px);
    h1 {
      margin-bottom: 0;
      font-size: 60px;
      line-height: 1;
      letter-spacing: -1px;
    }
    p {
      font-size: 18px;
      font-weight: 200;
      line-height: @baseline * 1.5;
    }
  }
  footer {
    margin-top: @baseline - 1;
    padding-top: @baseline - 1;
    border-top: 1px solid #eee;
  }
  
  
  // PAGE HEADERS
  // ------------
  
  .page-header {
    margin-bottom: @baseline - 1;
    border-bottom: 1px solid #ddd;
    .box-shadow(0 1px 0 rgba(255,255,255,.5));
    h1 {
      margin-bottom: (@baseline / 2) - 1px;
    }
  }
  
  
  // BUTTON STYLES
  // -------------
  
  // Shared colors for buttons and alerts
  .btn,
  .alert-message {
    // Set text color
    &.danger,
    &.danger:hover,
    &.error,
    &.error:hover,
    &.success,
    &.success:hover,
    &.info,
    &.info:hover {
      color: @white
    }
    // Sets the close button to the middle of message
    .close{
      font-family: Arial, sans-serif;
      line-height: 18px;
    }
    // Danger and error appear as red
    &.danger,
    &.error {
      .gradientBar(#ee5f5b, #c43c35);
    }
    // Success appears as green
    &.success {
      .gradientBar(#62c462, #57a957);
    }
    // Info appears as a neutral blue
    &.info {
      .gradientBar(#5bc0de, #339bb9);
    }
  }
  
  // Base .btn styles
  .btn {
    // Button Base
    cursor: pointer;
    display: inline-block;
    #gradient > .vertical-three-colors(#ffffff, #ffffff, 25%, darken(#ffffff, 10%)); // Don't use .gradientbar() here since it does a three-color gradient
    padding: 5px 14px 6px;
    text-shadow: 0 1px 1px rgba(255,255,255,.75);
    color: #333;
    font-size: @basefont;
    line-height: normal;
    border: 1px solid #ccc;
    border-bottom-color: #bbb;
    .border-radius(4px);
    @shadow: inset 0 1px 0 rgba(255,255,255,.2), 0 1px 2px rgba(0,0,0,.05);
    .box-shadow(@shadow);
  
    &:hover {
      background-position: 0 -15px;
      color: #333;
      text-decoration: none;
    }
  
    // Focus state for keyboard and accessibility
    &:focus {
      outline: 1px dotted #666;
    }
  
    // Primary Button Type
    &.primary {
      color: @white;
      .gradientBar(@blue, @blueDark)
    }
  
     // Transitions
    .transition(.1s linear all);
  
    // Active and Disabled states
    &.active,
    &:active {
      @shadow: inset 0 2px 4px rgba(0,0,0,.25), 0 1px 2px rgba(0,0,0,.05);
      .box-shadow(@shadow);
    }
    &.disabled {
      cursor: default;
      background-image: none;
      .reset-filter();
      .opacity(65);
      .box-shadow(none);
    }
    &[disabled] {
      // disabled pseudo can't be included with .disabled
      // def because IE8 and below will drop it ;_;
      cursor: default;
      background-image: none;
      .reset-filter();
      .opacity(65);
      .box-shadow(none);
    }
  
    // Button Sizes
    &.large {
      font-size: @basefont + 2px;
      line-height: normal;
      padding: 9px 14px 9px;
      .border-radius(6px);
    }
    &.small {
      padding: 7px 9px 7px;
      font-size: @basefont - 2px;
    }
  }
  // Super jank hack for removing border-radius from IE9 so we can keep filter gradients on alerts and buttons
  :root .alert-message,
  :root .btn {
    border-radius: 0 \0;
  }
  
  // Help Firefox not be a jerk about adding extra padding to buttons
  button.btn,
  input[type=submit].btn {
    &::-moz-focus-inner {
    	padding: 0;
    	border: 0;
    }
  }
  
  
  // CLOSE ICONS
  // -----------
  .close {
    float: right;
    color: @black;
    font-size: 20px;
    font-weight: bold;
    line-height: @baseline * .75;
    text-shadow: 0 1px 0 rgba(255,255,255,1);
    .opacity(25);
    &:hover {
      color: @black;
      text-decoration: none;
      .opacity(40);
    }
  }
  
  
  // ERROR STYLES
  // ------------
  
  // Base alert styles
  .alert-message {
    position: relative;
    padding: 7px 15px;
    margin-bottom: @baseline;
    color: @grayDark;
    .gradientBar(#fceec1, #eedc94); // warning by default
    text-shadow: 0 1px 0 rgba(255,255,255,.5);
    border-width: 1px;
    border-style: solid;
    .border-radius(4px);
    .box-shadow(inset 0 1px 0 rgba(255,255,255,.25));
  
    // Adjust close icon
    .close {
      margin-top: 1px;
      *margin-top: 0; // For IE7
    }
  
    // Make links same color as text and stand out more
    a {
      font-weight: bold;
      color: @grayDark;
    }
    &.danger p a,
    &.error p a,
    &.success p a,
    &.info p a {
      color: @white;
    }
  
    // Remove extra margin from content
    h5 {
      line-height: @baseline;
    }
    p {
      margin-bottom: 0;
    }
    div {
      margin-top: 5px;
      margin-bottom: 2px;
      line-height: 28px;
    }
    .btn {
      // Provide actions with buttons
      .box-shadow(0 1px 0 rgba(255,255,255,.25));
    }
  
    &.block-message {
      background-image: none;
      background-color: lighten(#fceec1, 5%);
      .reset-filter();
      padding: 14px;
      border-color: #fceec1;
      .box-shadow(none);
      ul, p {
        margin-right: 30px;
      }
      ul {
        margin-bottom: 0;
      }
      li {
        color: @grayDark;
      }
      .alert-actions {
        margin-top: 5px;
      }
      &.error,
      &.success,
      &.info {
        color: @grayDark;
        text-shadow: 0 1px 0 rgba(255,255,255,.5);
      }
      &.error {
        background-color: lighten(#f56a66, 25%);
        border-color: lighten(#f56a66, 20%);
      }
      &.success {
        background-color: lighten(#62c462, 30%);
        border-color: lighten(#62c462, 25%);
      }
      &.info {
        background-color: lighten(#6bd0ee, 25%);
        border-color: lighten(#6bd0ee, 20%);
      }
      // Change link color back
      &.danger p a,
      &.error p a,
      &.success p a,
      &.info p a {
        color: @grayDark;
      }
  
    }
  }
  
  
  // PAGINATION
  // ----------
  
  .pagination {
    height: @baseline * 2;
    margin: @baseline 0;
    ul {
      float: left;
      margin: 0;
      border: 1px solid #ddd;
      border: 1px solid rgba(0,0,0,.15);
      .border-radius(3px);
      .box-shadow(0 1px 2px rgba(0,0,0,.05));
    }
    li {
      display: inline;
    }
    a {
      float: left;
      padding: 0 14px;
      line-height: (@baseline * 2) - 2;
      border-right: 1px solid;
      border-right-color: #ddd;
      border-right-color: rgba(0,0,0,.15);
      *border-right-color: #ddd; /* IE6-7 */
      text-decoration: none;
    }
    a:hover,
    .active a {
      background-color: lighten(@blue, 45%);
    }
    .disabled a,
    .disabled a:hover {
      background-color: transparent;
      color: @grayLight;
    }
    .next a {
      border: 0;
    }
  }
  
  
  // WELLS
  // -----
  
  .well {
    background-color: #f5f5f5;
    margin-bottom: 20px;
    padding: 19px;
    min-height: 20px;
    border: 1px solid #eee;
    border: 1px solid rgba(0,0,0,.05);
    .border-radius(4px);
    .box-shadow(inset 0 1px 1px rgba(0,0,0,.05));
    blockquote {
      border-color: #ddd;
      border-color: rgba(0,0,0,.15);
    }
  }
  
  
  // MODALS
  // ------
  
  .modal-backdrop {
    background-color: @black;
    position: fixed;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    z-index: 10000;
    // Fade for backdrop
    &.fade { opacity: 0; }
  }
  
  .modal-backdrop,
  .modal-backdrop.fade.in {
    .opacity(80);
  }
  
  .modal {
    position: fixed;
    top: 50%;
    left: 50%;
    z-index: 11000;
    width: 560px;
    margin: -250px 0 0 -280px;
    background-color: @white;
    border: 1px solid #999;
    border: 1px solid rgba(0,0,0,.3);
    *border: 1px solid #999; /* IE6-7 */
    .border-radius(6px);
    .box-shadow(0 3px 7px rgba(0,0,0,0.3));
    .background-clip(padding-box);
    .close { margin-top: 7px; }
    &.fade {
      .transition(e('opacity .3s linear, top .3s ease-out'));
      top: -25%;
    }
    &.fade.in { top: 50%; }
  }
  .modal-header {
    border-bottom: 1px solid #eee;
    padding: 5px 15px;
  }
  .modal-body {
    padding: 15px;
  }
  .modal-body form {
    margin-bottom: 0;
  }
  .modal-footer {
    background-color: #f5f5f5;
    padding: 14px 15px 15px;
    border-top: 1px solid #ddd;
    .border-radius(0 0 6px 6px);
    .box-shadow(inset 0 1px 0 @white);
    .clearfix();
    margin-bottom: 0;
    .btn {
      float: right;
      margin-left: 5px;
    }
  }
  
  // Fix the stacking of these components when in modals
  .modal .popover,
  .modal .twipsy {
    z-index: 12000;
  }
  
  
  // POPOVER ARROWS
  // --------------
  
  #popoverArrow {
    .above(@arrowWidth: 5px) {
      bottom: 0;
      left: 50%;
      margin-left: -@arrowWidth;
      border-left: @arrowWidth solid transparent;
      border-right: @arrowWidth solid transparent;
      border-top: @arrowWidth solid @black;
    }
    .left(@arrowWidth: 5px) {
      top: 50%;
      right: 0;
      margin-top: -@arrowWidth;
      border-top: @arrowWidth solid transparent;
      border-bottom: @arrowWidth solid transparent;
      border-left: @arrowWidth solid @black;
    }
    .below(@arrowWidth: 5px) {
      top: 0;
      left: 50%;
      margin-left: -@arrowWidth;
      border-left: @arrowWidth solid transparent;
      border-right: @arrowWidth solid transparent;
      border-bottom: @arrowWidth solid @black;
    }
    .right(@arrowWidth: 5px) {
      top: 50%;
      left: 0;
      margin-top: -@arrowWidth;
      border-top: @arrowWidth solid transparent;
      border-bottom: @arrowWidth solid transparent;
      border-right: @arrowWidth solid @black;
    }
  }
  
  // TWIPSY
  // ------
  
  .twipsy {
    display: block;
    position: absolute;
    visibility: visible;
    padding: 5px;
    font-size: 11px;
    z-index: 1000;
    .opacity(80);
    &.fade.in {
      .opacity(80);
    }
    &.above .twipsy-arrow   { #popoverArrow > .above(); }
    &.left .twipsy-arrow    { #popoverArrow > .left(); }
    &.below .twipsy-arrow   { #popoverArrow > .below(); }
    &.right .twipsy-arrow   { #popoverArrow > .right(); }
  }
  .twipsy-inner {
    padding: 3px 8px;
    background-color: @black;
    color: white;
    text-align: center;
    max-width: 200px;
    text-decoration: none;
    .border-radius(4px);
  }
  .twipsy-arrow {
    position: absolute;
    width: 0;
    height: 0;
  }
  
  
  // POPOVERS
  // --------
  
  .popover {
    position: absolute;
    top: 0;
    left: 0;
    z-index: 1000;
    padding: 5px;
    display: none;
    &.above .arrow { #popoverArrow > .above(); }
    &.right .arrow { #popoverArrow > .right(); }
    &.below .arrow { #popoverArrow > .below(); }
    &.left .arrow  { #popoverArrow > .left(); }
    .arrow {
      position: absolute;
      width: 0;
      height: 0;
    }
    .inner {
      background: @black;
      background: rgba(0,0,0,.8);
      padding: 3px;
      overflow: hidden;
      width: 280px;
      .border-radius(6px);
      .box-shadow(0 3px 7px rgba(0,0,0,0.3));
    }
    .title {
      background-color: #f5f5f5;
      padding: 9px 15px;
      line-height: 1;
      .border-radius(3px 3px 0 0);
      border-bottom:1px solid #eee;
    }
    .content {
      background-color: @white;
      padding: 14px;
      .border-radius(0 0 3px 3px);
      .background-clip(padding-box);
      p, ul, ol {
        margin-bottom: 0;
      }
    }
  }
  
  
  // PATTERN ANIMATIONS
  // ------------------
  
  .fade {
    .transition(opacity .15s linear);
    opacity: 0;
    &.in {
      opacity: 1;
    }
  }
  
  
  // LABELS
  // ------
  
  .label {
    padding: 1px 3px 2px;
    font-size: @basefont * .75;
    font-weight: bold;
    color: @white;
    text-transform: uppercase;
    white-space: nowrap;
    background-color: @grayLight;
    .border-radius(3px);
    &.important { background-color: #c43c35; }
    &.warning   { background-color: @orange; }
    &.success   { background-color: @green; }
    &.notice    { background-color: lighten(@blue, 25%); }
  }
  
  
  // MEDIA GRIDS
  // -----------
  
  .media-grid {
    margin-left: -@gridGutterWidth;
    margin-bottom: 0;
    .clearfix();
    li {
      display: inline;
    }
    a {
      float: left;
      padding: 4px;
      margin: 0 0 @baseline @gridGutterWidth;
      border: 1px solid #ddd;
      .border-radius(4px);
      .box-shadow(0 1px 1px rgba(0,0,0,.075));
      img {
        display: block;
      }
      &:hover {
        border-color: @linkColor;
        .box-shadow(0 1px 4px rgba(0,105,214,.25));
      }
    }
  }
---
file: htdocs/common/less/reset.less
template: |-
  /* Reset.less
   * Props to Eric Meyer (meyerweb.com) for his CSS reset file. We're using an adapted version here	that cuts out some of the reset HTML elements we will never need here (i.e., dfn, samp, etc).
   * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- */
  
  
  // ERIC MEYER RESET
  // --------------------------------------------------
  
  html, body { margin: 0; padding: 0; }
  h1, h2, h3, h4, h5, h6, p, blockquote, pre, a, abbr, acronym, address, cite, code, del, dfn, em, img, q, s, samp, small, strike, strong, sub, sup, tt, var, dd, dl, dt, li, ol, ul, fieldset, form, label, legend, button, table, caption, tbody, tfoot, thead, tr, th, td { margin: 0; padding: 0; border: 0; font-weight: normal; font-style: normal; font-size: 100%; line-height: 1; font-family: inherit; }
  table { border-collapse: collapse; border-spacing: 0; }
  ol, ul { list-style: none; }
  q:before, q:after, blockquote:before, blockquote:after { content: ""; }
  
  
  // Normalize.css
  // Pulling in select resets form the normalize.css project
  // --------------------------------------------------
  
  // Display in IE6-9 and FF3
  // -------------------------
  // Source: http://github.com/necolas/normalize.css
  html {
    overflow-y: scroll;
    font-size: 100%;
    -webkit-text-size-adjust: 100%;
        -ms-text-size-adjust: 100%;
  }
  // Focus states
  a:focus {
    outline: thin dotted;
  }
  // Hover & Active
  a:hover,
  a:active {
    outline: 0;
  }
  
  // Display in IE6-9 and FF3
  // -------------------------
  // Source: http://github.com/necolas/normalize.css
  article,
  aside,
  details,
  figcaption,
  figure,
  footer,
  header,
  hgroup,
  nav,
  section {
    display: block;
  }
  
  // Display block in IE6-9 and FF3
  // -------------------------
  // Source: http://github.com/necolas/normalize.css
  audio,
  canvas,
  video {
    display: inline-block;
    *display: inline;
    *zoom: 1;
  }
  
  // Prevents modern browsers from displaying 'audio' without controls
  // -------------------------
  // Source: http://github.com/necolas/normalize.css
  audio:not([controls]) {
      display: none;
  }
  
  // Prevents sub and sup affecting line-height in all browsers
  // -------------------------
  // Source: http://github.com/necolas/normalize.css
  sub,
  sup {
    font-size: 75%;
    line-height: 0;
    position: relative;
    vertical-align: baseline;
  }
  sup {
    top: -0.5em;
  }
  sub {
    bottom: -0.25em;
  }
  
  // Img border in a's and image quality
  // -------------------------
  // Source: http://github.com/necolas/normalize.css
  img {
      border: 0;
      -ms-interpolation-mode: bicubic;
  }
  
  // Forms
  // -------------------------
  // Source: http://github.com/necolas/normalize.css
  
  // Font size in all browsers, margin changes, misc consistency
  button,
  input,
  select,
  textarea {
    font-size: 100%;
    margin: 0;
    vertical-align: baseline;
    *vertical-align: middle;
  }
  button,
  input {
    line-height: normal; // FF3/4 have !important on line-height in UA stylesheet
    *overflow: visible; // Inner spacing ie IE6/7
  }
  button::-moz-focus-inner,
  input::-moz-focus-inner { // Inner padding and border oddities in FF3/4
    border: 0;
    padding: 0;
  }
  button,
  input[type="button"],
  input[type="reset"],
  input[type="submit"] {
    cursor: pointer; // Cursors on all buttons applied consistently
    -webkit-appearance: button; // Style clicable inputs in iOS
  }
  input[type="search"] { // Appearance in Safari/Chrome
    -webkit-appearance: textfield;
    -webkit-box-sizing: content-box;
       -moz-box-sizing: content-box;
            box-sizing: content-box;
  }
  input[type="search"]::-webkit-search-decoration {
    -webkit-appearance: none; // Inner-padding issues in Chrome OSX, Safari 5
  }
  textarea {
    overflow: auto; // Remove vertical scrollbar in IE6-9
    vertical-align: top; // Readability and alignment cross-browser
  }
---
file: htdocs/common/less/scaffolding.less
template: |-
  /*
   * Scaffolding
   * Basic and global styles for generating a grid system, structural layout, and page templates
   * ------------------------------------------------------------------------------------------- */
  
  
  // STRUCTURAL LAYOUT
  // -----------------
  
  body {
    background-color: @white;
    margin: 0;
    #font > .sans-serif(normal,@basefont,@baseline);
    color: @grayDark;
  }
  
  // Container (centered, fixed-width layouts)
  .container {
    .fixed-container();
  }
  
  // Fluid layouts (left aligned, with sidebar, min- & max-width content)
  .container-fluid {
    position: relative;
    min-width: 940px;
    padding-left: 20px;
    padding-right: 20px;
    .clearfix();
    > .sidebar {
      position: absolute;
      top: 0;
      left: 20px;
      width: 220px;
    }
    // TODO in v2: rename this and .popover .content to be more specific
    > .content {
      margin-left: 240px;
    }
  }
  
  
  // BASE STYLES
  // -----------
  
  // Links
  a {
    color: @linkColor;
    text-decoration: none;
    line-height: inherit;
    font-weight: inherit;
    &:hover {
      color: @linkColorHover;
      text-decoration: underline;
    }
  }
  
  // Quick floats
  .pull-right {
    float: right;
  }
  .pull-left {
    float: left;
  }
  
  // Toggling content
  .hide {
    display: none;
  }
  .show {
    display: block;
  }
  
  
  // GRID SYSTEM
  // -----------
  // To customize the grid system, bring up the variables.less file and change the column count, size, and gutter there
  
  .row {
    .clearfix();
    margin-left: -@gridGutterWidth;
  }
  
  // Find all .span# classes within .row and give them the necessary properties for grid columns (supported by all browsers back to IE7)
  // Credit to @dhg for the idea
  .row > [class*="span"] {
    .gridColumn();
  }
  
  // Default columns
  .span1     { .columns(1); }
  .span2     { .columns(2); }
  .span3     { .columns(3); }
  .span4     { .columns(4); }
  .span5     { .columns(5); }
  .span6     { .columns(6); }
  .span7     { .columns(7); }
  .span8     { .columns(8); }
  .span9     { .columns(9); }
  .span10    { .columns(10); }
  .span11    { .columns(11); }
  .span12    { .columns(12); }
  .span13    { .columns(13); }
  .span14    { .columns(14); }
  .span15    { .columns(15); }
  .span16    { .columns(16); }
  
  // For optional 24-column grid
  .span17    { .columns(17); }
  .span18    { .columns(18); }
  .span19    { .columns(19); }
  .span20    { .columns(20); }
  .span21    { .columns(21); }
  .span22    { .columns(22); }
  .span23    { .columns(23); }
  .span24    { .columns(24); }
  
  // Offset column options
  .row {
    > .offset1   { .offset(1); }
    > .offset2   { .offset(2); }
    > .offset3   { .offset(3); }
    > .offset4   { .offset(4); }
    > .offset5   { .offset(5); }
    > .offset6   { .offset(6); }
    > .offset7   { .offset(7); }
    > .offset8   { .offset(8); }
    > .offset9   { .offset(9); }
    > .offset10  { .offset(10); }
    > .offset11  { .offset(11); }
    > .offset12  { .offset(12); }
  }
  
  // Unique column sizes for 16-column grid
  .span-one-third     { width: 300px; }
  .span-two-thirds    { width: 620px; }
  .row {
    > .offset-one-third   { margin-left: 340px; }
    > .offset-two-thirds  { margin-left: 660px; }
  }
---
file: htdocs/common/less/tables.less
template: |-
  /*
   * Tables.less
   * Tables for, you guessed it, tabular data
   * ---------------------------------------- */
  
  
  // BASELINE STYLES
  // ---------------
  
  table {
    width: 100%;
    margin-bottom: @baseline;
    padding: 0;
    font-size: @basefont;
    border-collapse: collapse;
    th,
    td {
      padding: 10px 10px 9px;
      line-height: @baseline;
      text-align: left;
    }
    th {
      padding-top: 9px;
      font-weight: bold;
      vertical-align: middle;
    }
    td {
      vertical-align: top;
      border-top: 1px solid #ddd;
    }
    // When scoped to row, fix th in tbody
    tbody th {
      border-top: 1px solid #ddd;
      vertical-align: top;
    }
  }
  
  
  // CONDENSED VERSION
  // -----------------
  .condensed-table {
    th,
    td {
      padding: 5px 5px 4px;
    }
  }
  
  
  // BORDERED VERSION
  // ----------------
  
  .bordered-table {
    border: 1px solid #ddd;
    border-collapse: separate; // Done so we can round those corners!
    *border-collapse: collapse; /* IE7, collapse table to remove spacing */
    .border-radius(4px);
    th + th,
    td + td,
    th + td {
      border-left: 1px solid #ddd;
    }
    thead tr:first-child th:first-child,
    tbody tr:first-child td:first-child {
      .border-radius(4px 0 0 0);
    }
    thead tr:first-child th:last-child,
    tbody tr:first-child td:last-child {
      .border-radius(0 4px 0 0);
    }
    tbody tr:last-child td:first-child {
      .border-radius(0 0 0 4px);
    }
    tbody tr:last-child td:last-child {
      .border-radius(0 0 4px 0);
    }
  }
  
  
  // TABLE CELL SIZES
  // ----------------
  
  // This is a duplication of the main grid .columns() mixin, but subtracts 20px to account for input padding and border
  .tableColumns(@columnSpan: 1) {
    width: ((@gridColumnWidth - 20) * @columnSpan) + ((@gridColumnWidth - 20) * (@columnSpan - 1));
  }
  table {
    // Default columns
    .span1     { .tableColumns(1); }
    .span2     { .tableColumns(2); }
    .span3     { .tableColumns(3); }
    .span4     { .tableColumns(4); }
    .span5     { .tableColumns(5); }
    .span6     { .tableColumns(6); }
    .span7     { .tableColumns(7); }
    .span8     { .tableColumns(8); }
    .span9     { .tableColumns(9); }
    .span10    { .tableColumns(10); }
    .span11    { .tableColumns(11); }
    .span12    { .tableColumns(12); }
    .span13    { .tableColumns(13); }
    .span14    { .tableColumns(14); }
    .span15    { .tableColumns(15); }
    .span16    { .tableColumns(16); }
  }
  
  
  // ZEBRA-STRIPING
  // --------------
  
  // Default zebra-stripe styles (alternating gray and transparent backgrounds)
  .zebra-striped {
    tbody {
      tr:nth-child(odd) td,
      tr:nth-child(odd) th {
        background-color: #f9f9f9;
      }
      tr:hover td,
      tr:hover th {
        background-color: #f5f5f5;
      }
    }
  }
  
  table {
    // Tablesorting styles w/ jQuery plugin
    .header {
      cursor: pointer;
      &:after {
        content: "";
        float: right;
        margin-top: 7px;
        border-width: 0 4px 4px;
        border-style: solid;
        border-color: #000 transparent;
        visibility: hidden;
      }
    }
    // Style the sorted column headers (THs)
    .headerSortUp,
    .headerSortDown {
      background-color: rgba(141,192,219,.25);
      text-shadow: 0 1px 1px rgba(255,255,255,.75);
    }
    // Style the ascending (reverse alphabetical) column header
    .header:hover {
      &:after {
        visibility:visible;
      }
    }
    // Style the descending (alphabetical) column header
    .headerSortDown,
    .headerSortDown:hover {
      &:after {
        visibility:visible;
        .opacity(60);
      }
    }
    // Style the ascending (reverse alphabetical) column header
    .headerSortUp {
      &:after {
        border-bottom: none;
        border-left: 4px solid transparent;
        border-right: 4px solid transparent;
        border-top: 4px solid #000;
        visibility:visible;
        .box-shadow(none); //can't add boxshadow to downward facing arrow :(
        .opacity(60);
      }
    }
    // Blue Table Headings
    .blue {
      color: @blue;
      border-bottom-color: @blue;
    }
    .headerSortUp.blue,
    .headerSortDown.blue {
      background-color: lighten(@blue, 40%);
    }
    // Green Table Headings
    .green {
      color: @green;
      border-bottom-color: @green;
    }
    .headerSortUp.green,
    .headerSortDown.green {
      background-color: lighten(@green, 40%);
    }
    // Red Table Headings
    .red {
      color: @red;
      border-bottom-color: @red;
    }
    .headerSortUp.red,
    .headerSortDown.red {
      background-color: lighten(@red, 50%);
    }
    // Yellow Table Headings
    .yellow {
      color: @yellow;
      border-bottom-color: @yellow;
    }
    .headerSortUp.yellow,
    .headerSortDown.yellow {
      background-color: lighten(@yellow, 40%);
    }
    // Orange Table Headings
    .orange {
      color: @orange;
      border-bottom-color: @orange;
    }
    .headerSortUp.orange,
    .headerSortDown.orange {
      background-color: lighten(@orange, 40%);
    }
    // Purple Table Headings
    .purple {
      color: @purple;
      border-bottom-color: @purple;
    }
    .headerSortUp.purple,
    .headerSortDown.purple {
      background-color: lighten(@purple, 40%);
    }
  }
---
file: htdocs/common/less/type.less
template: |-
  /* Typography.less
   * Headings, body text, lists, code, and more for a versatile and durable typography system
   * ---------------------------------------------------------------------------------------- */
  
  
  // BODY TEXT
  // ---------
  
  p {
    #font > .shorthand(normal,@basefont,@baseline);
    margin-bottom: @baseline / 2;
    small {
      font-size: @basefont - 2;
      color: @grayLight;
    }
  }
  
  
  // HEADINGS
  // --------
  
  h1, h2, h3, h4, h5, h6 {
    font-weight: bold;
    color: @grayDark;
    small {
      color: @grayLight;
    }
  }
  h1 {
    margin-bottom: @baseline;
    font-size: 30px;
    line-height: @baseline * 2;
    small {
      font-size: 18px;
    }
  }
  h2 {
    font-size: 24px;
    line-height: @baseline * 2;
    small {
      font-size: 14px;
    }
  }
  h3, h4, h5, h6 {
    line-height: @baseline * 2;
  }
  h3 {
    font-size: 18px;
    small {
      font-size: 14px;
    }
  }
  h4 {
    font-size: 16px;
    small {
      font-size: 12px;
    }
  }
  h5 {
    font-size: 14px;
  }
  h6 {
    font-size: 13px;
    color: @grayLight;
    text-transform: uppercase;
  }
  
  
  // COLORS
  // ------
  
  // Unordered and Ordered lists
  ul, ol {
    margin: 0 0 @baseline 25px;
  }
  ul ul,
  ul ol,
  ol ol,
  ol ul {
    margin-bottom: 0;
  }
  ul {
    list-style: disc;
  }
  ol {
    list-style: decimal;
  }
  li {
    line-height: @baseline;
    color: @gray;
  }
  ul.unstyled {
    list-style: none;
    margin-left: 0;
  }
  
  // Description Lists
  dl {
    margin-bottom: @baseline;
    dt, dd {
      line-height: @baseline;
    }
    dt {
      font-weight: bold;
    }
    dd {
      margin-left: @baseline / 2;
    }
  }
  
  // MISC
  // ----
  
  // Horizontal rules
  hr {
    margin: 20px 0 19px;
    border: 0;
    border-bottom: 1px solid #eee;
  }
  
  // Emphasis
  strong {
    font-style: inherit;
    font-weight: bold;
  }
  em {
    font-style: italic;
    font-weight: inherit;
    line-height: inherit;
  }
  .muted {
    color: @grayLight;
  }
  
  // Blockquotes
  blockquote {
    margin-bottom: @baseline;
    border-left: 5px solid #eee;
    padding-left: 15px;
    p {
      #font > .shorthand(300,14px,@baseline);
      margin-bottom: 0;
    }
    small {
      display: block;
      #font > .shorthand(300,12px,@baseline);
      color: @grayLight;
      &:before {
        content: '\2014 \00A0';
      }
    }
  }
  
  // Addresses
  address {
    display: block;
    line-height: @baseline;
    margin-bottom: @baseline;
  }
  
  // Inline and block code styles
  code, pre {
    padding: 0 3px 2px;
    font-family: Monaco, Andale Mono, Courier New, monospace;
    font-size: 12px;
    .border-radius(3px);
  }
  code {
    background-color: lighten(@orange, 40%);
    color: rgba(0,0,0,.75);
    padding: 1px 3px;
  }
  pre {
    background-color: #f5f5f5;
    display: block;
    padding: (@baseline - 1) / 2;
    margin: 0 0 @baseline;
    line-height: @baseline;
    font-size: 12px;
    border: 1px solid #ccc;
    border: 1px solid rgba(0,0,0,.15);
    .border-radius(3px);
    white-space: pre;
    white-space: pre-wrap;
    word-wrap: break-word;
  
  }
---
file: htdocs/common/less/variables.less
template: |-
  /* Variables.less
   * Variables to customize the look and feel of Bootstrap
   * ----------------------------------------------------- */
  
  
  // Links
  @linkColor:         #0069d6;
  @linkColorHover:    darken(@linkColor, 15);
  
  // Grays
  @black:             #000;
  @grayDark:          lighten(@black, 25%);
  @gray:              lighten(@black, 50%);
  @grayLight:         lighten(@black, 75%);
  @grayLighter:       lighten(@black, 90%);
  @white:             #fff;
  
  // Accent Colors
  @blue:              #049CDB;
  @blueDark:          #0064CD;
  @green:             #46a546;
  @red:               #9d261d;
  @yellow:            #ffc40d;
  @orange:            #f89406;
  @pink:              #c3325f;
  @purple:            #7a43b6;
  
  // Baseline grid
  @basefont:          13px;
  @baseline:          18px;
  
  // Griditude
  // Modify the grid styles in mixins.less
  @gridColumns:       16;
  @gridColumnWidth:   40px;
  @gridGutterWidth:   20px;
  @extraSpace:        (@gridGutterWidth * 2); // For our grid calculations
  @siteWidth:         (@gridColumns * @gridColumnWidth) + (@gridGutterWidth * (@gridColumns - 1));
  
  // Color Scheme
  // Use this to roll your own color schemes if you like (unused by Bootstrap by default)
  @baseColor:         @blue;                  // Set a base color
  @complement:        spin(@baseColor, 180);  // Determine a complementary color
  @split1:            spin(@baseColor, 158);  // Split complements
  @split2:            spin(@baseColor, -158);
  @triad1:            spin(@baseColor, 135);  // Triads colors
  @triad2:            spin(@baseColor, -135);
  @tetra1:            spin(@baseColor, 90);   // Tetra colors
  @tetra2:            spin(@baseColor, -90);
  @analog1:           spin(@baseColor, 22);   // Analogs colors
  @analog2:           spin(@baseColor, -22);
  
  
  
  // More variables coming soon:
  // - @basefont to @baseFontSize
  // - @baseline to @baseLineHeight
  // - @baseFontFamily
  // - @primaryButtonColor
  // - anything else? File an issue on GitHub
---
file: lib/____var-dist-var____.pm
template: |
  package [% dist %];
  use strict;
  use warnings;
  our $VERSION = '0.01';
  1;
---
file: lib/____var-dist-var____/API.pm
template: |
  package [% dist %]::API;
  use Ze::Class;
  extends 'Ze::WAF';
  use [% dist %]::Config;
  
  if( [% dist %]::Config->instance->get('debug') ) {
      with 'Ze::WAF::Profiler';
  };
  
  EOC;
---
file: lib/____var-dist-var____/Cache.pm
template: |
  package [% dist %]::Cache;
  use strict;
  use warnings;
  use base qw(Cache::Memcached::IronPlate Class::Singleton);
  use [% dist %]::Config();
  use Cache::Memcached::Fast();
  
  sub _new_instance {
      my $class = shift;
  
      my $config = [% dist %]::Config->instance->get('cache');
  
      my $cache = Cache::Memcached::Fast->new({
              utf8 => 1,
              servers => $config->{servers},
              compress_threshold => 5000,
              ketama_points => 150, 
              namespace => '[% appname %]', 
          });
      my $self = $class->SUPER::new( cache => $cache );
      return $self;
  }
  
  1;
---
file: lib/____var-dist-var____/Config.pm
template: |
  package [% dist %]::Config;
  use parent 'Ze::Config';
  1;
---
file: lib/____var-dist-var____/Constants.pm
template: |
  package [% dist %]::Constants;
  use strict;
  use warnings;
  use parent qw(Exporter);
  our @EXPORT_OK = ();
  our %EXPORT_TAGS = (
      common => [qw(FAIL SUCCESS)],
  );
  
  our $DATA = {};
  __PACKAGE__->build_export_ok();
  __PACKAGE__->make_hash_ref();
  
  use constant FAIL => 0;
  use constant SUCCESS => 0;
  
  sub build_export_ok {
      for my $tag  (keys %EXPORT_TAGS ){
          for my $key (@{$EXPORT_TAGS{$tag}}){
              push @EXPORT_OK,$key;
          }
      }
  }
  
  sub make_hash_ref {
      no strict 'refs';
      for my $key(@EXPORT_OK) {
          $DATA->{$key} = $key->();
      }
      1;
  }
  
  sub as_hashref {
      return $DATA;
  }
  
  1;
---
file: lib/____var-dist-var____/DateTime.pm
template: |
  package [% dist %]::DateTime;
  use strict;
  use warnings;
  use base qw( DateTime );
  use DateTime::TimeZone;
  use DateTime::Format::Strptime;
  
  our $DEFAULT_TIMEZONE = DateTime::TimeZone->new( name => 'local' );
  
  sub new {
      my ( $class, %opts ) = @_;
      $opts{ time_zone } ||= $DEFAULT_TIMEZONE;
      return $class->SUPER::new( %opts );
  }
  
  sub now {
      my ( $class, %opts ) = @_;
      $opts{ time_zone } ||= $DEFAULT_TIMEZONE;
      return $class->SUPER::now( %opts );
  }
  
  sub from_epoch {
      my $class = shift;
      my %p = @_ == 1 ? (epoch => $_[0]) : @_;
      $p{ time_zone } ||= $DEFAULT_TIMEZONE;
      return $class->SUPER::from_epoch( %p );
  }
  
  sub parse {
      my ( $class, $format, $date ) = @_;
      $format ||= 'MySQL';
  
      my $module;
      if ( ref $format ) {
          $module = $format;
      }
      else {
          $module = "DateTime::Format::$format";
          eval "require $module";
          die $@ if $@;
      }
  
      my $dt = $module->parse_datetime( $date ) or return;
      # If parsed datetime is floating, don't set timezone here.
      # It should be "fixed" in caller plugins
      $dt->set_time_zone( $DEFAULT_TIMEZONE || 'local' )
          unless $dt->time_zone->is_floating;
  
      return bless $dt, $class;
  }
  
  sub strptime {
      my($class, $pattern, $date) = @_;
      my $format = DateTime::Format::Strptime->new(
          pattern   => $pattern,
          time_zone => $DEFAULT_TIMEZONE || 'local',
      );
      $class->parse($format, $date);
  }
  
  sub set_time_zone {
      my $self = shift;
      eval { $self->SUPER::set_time_zone( @_ ) };
      if ( $@ ) {
          $self->SUPER::set_time_zone( 'UTC' );
      }
      return $self;
  }
  
  sub sql_now {
      my($class, %options) = @_;
      my $self = $class->now( %options );
      $self->strftime( '%Y-%m-%d %H:%M:%S' );
  }
  
  sub yesterday {
      my $class = shift;
      my $now = $class->now();
      return $now->subtract( days => 1 );
  }
  
  1;
---
file: lib/____var-dist-var____/FileGenerator.pm
template: |
  package [% dist %]::FileGenerator;
  use strict;
  use warnings;
  use parent 'Ze::FileGenerator';
  
  sub _module_pluggable_options {
      return (
          except => ['[% dist %]::FileGenerator::Base'],
      );
  };
  
  
  1;
---
file: lib/____var-dist-var____/Home.pm
template: |
  package [% dist %]::Home;
  use parent 'Ze::Home';
  1;
---
file: lib/____var-dist-var____/Pager.pm
template: |
  package [% dist %]::Pager;
  
  use strict;
  use warnings;
  use base qw(Data::Page);
  use Data::Page::Navigation;
  use URI::QueryParam ;
  
  sub build_uri {
      my $self = shift;
      my $p    = shift;
      my $uri  = $self->uri->clone();
      $uri->query_param_append( p => $p );
      return $uri;
  }
  
  sub pages_in_navigation {
      my $self = shift;
      my @arr = $self->SUPER::pages_in_navigation(shift);
      return \@arr;
  }
  
  sub uri {
      my $self = shift;
      my $uri = shift;
      if( $uri ) {
          my $u = $uri->clone();    
          $u->query_param_delete('p');
          $self->{__uri} = $u;
      }
      else {
          $self->{__uri};    
      }
  }
  
  1;
---
file: lib/____var-dist-var____/PC.pm
template: |
  package [% dist %]::PC;
  use Ze::Class;
  extends 'Ze::WAF';
  use [% dist %]::Config;
  
  if( [% dist %]::Config->instance->get('debug') ) {
      with 'Ze::WAF::Profiler';
  };
  
  EOC;
---
file: lib/____var-dist-var____/Session.pm
template: |
  package [% dist %]::Session;
  use strict;
  use warnings;
  use HTTP::Session;
  use HTTP::Session::State::Cookie;
  use [% dist %]::Cache::Session;
  use [% dist %]::Config;
  
  
  
  BEGIN {
      no warnings;
      use HTTP::Session::Store::Memcached;
      *HTTP::Session::Store::Memcached::new = sub {
          my $class = shift;
          my %args = ref($_[0]) ? %{$_[0]} : @_;
          # check required parameters
          for (qw/memd/) {
              Carp::croak "missing parameter $_" unless $args{$_};
          }
  
      # XXX : skiped..
      #
      #    unless (ref $args{memd} && index(ref($args{memd}), 'Memcached') >= 0) {
      #        Carp::croak "memd requires instance of Cache::Memcached::Fast or Cache::Memcached";
      #    }
  
          bless {%args}, $class;
      };
  }
  
  
  sub create {
      my $class = shift;
      my $req = shift;
      my $res = shift;
      my $cookie_config =  [% dist %]::Config->instance()->get('cookie_session');
  
      my $session = HTTP::Session->new(
          store => HTTP::Session::Store::Memcached->new( memd =>  [% dist %]::Cache::Session->instance ),
          state => HTTP::Session::State::Cookie->new( name => $cookie_config->{namespace} ),
          request => $req,
      );
  
  
      # http headerをセットしてる程度なのでとりあえずここでもおk
      $session->response_filter($res);
      return $session;
  }
  
  1;
---
file: lib/____var-dist-var____/Util.pm
template: |
  package [% dist %]::Util;
  use strict;
  use warnings;
  use JSON::XS();
  use Encode();
  use parent qw(Exporter);
  
  our @EXPORT = qw(to_json from_json);
  
  sub from_json {
      my $json = shift; 
       $json = Encode::encode('utf8',$json);
       return JSON::XS::decode_json( $json );
  }
  
  sub to_json {
      my $data = shift; 
       Encode::decode('utf8',JSON::XS::encode_json( $data ) );
  }
  
  
  1;
---
file: lib/____var-dist-var____/Validator.pm
template: |
  package [% dist %]::Validator;
  use warnings;
  use strict;
  use utf8;
  use FormValidator::LazyWay;
  use YAML::Syck();
  use Data::Section::Simple;
  use [% dist %]::Validator::Result;
  
  sub create_config {
      my $reader = Data::Section::Simple->new(__PACKAGE__);
      my $yaml = $reader->get_data_section('validate.yaml');
      my $data = YAML::Syck::Load( $yaml);
      return $data;
  }
  
  sub instance {
      my $class = shift;
      no strict 'refs';
      my $instance = \${ "$class\::_instance" };
      defined $$instance ? $$instance : ($$instance = $class->_new);
  }
  
  sub _new {
      my $class = shift;
      my $self = bless {}, $class;
      return $self->create_validator();
  }
  
  sub create_validator {
      my $self = shift;
      my $config = $self->create_config();
      FormValidator::LazyWay->new( config => $config ,result_class => '[% dist %]::Validator::Result' );
  }
  
  1;
  
  =head1 NAME
  
  [% dist %]::Validator - Validatorクラス
  
  =head1 SYNOPSIS
  
  my $validator = [% dist %]::Validator->instance();
  
  =head1 DESCRIPTION
  
  L<FormValidator::LazyWay>のオブジェクトををシングルトン化し取得することができます。
  
  =cut
  
  __DATA__
  @@ validate.yaml
  --- 
  lang: ja
  rules: 
    - Number
    - String
    - Net
    - Email
  setting: 
      regex_map :
        '_id$': 
          rule: 
            - Number#uint
      strict:
        url: 
          rule:
              - Net#url_loose
        member_name:
          rule:
              - String#length:
                  max : 55
                  min : 1
        p: 
          rule: 
            - Number#uint
---
file: lib/____var-dist-var____/API/Context.pm
template: |
  package [% dist %]::API::Context;
  use Ze::Class;
  extends '[% dist %]::WAF::Context';
  
  __PACKAGE__->load_plugins( 'Ze::WAF::Plugin::Encode','Ze::WAF::Plugin::JSON', 'Ze::WAF::Plugin::AntiCSRF');
  
  
  sub not_found {
      my $c = shift;
      $c->view_type('JSON');
      $c->res->status( 404 );
      $c->res->body('{"error":1}');
      $c->res->content_type( 'text/html;charset=utf-8' );
      $c->finished(1);
  }
  
  EOC;
---
file: lib/____var-dist-var____/API/Dispatcher.pm
template: |
  package [% dist %]::API::Dispatcher;
  use Ze::Class;
  extends 'Ze::WAF::Dispatcher::Router';
  
  sub _build_config_file {
      my $self = shift;
      $self->home->file('etc/router-api.pl');
  }
  
  EOC;
---
file: lib/____var-dist-var____/API/View.pm
template: |
  package [% dist %]::API::View;
  use Ze::Class;
  extends 'Ze::WAF::View';
  use Ze::View;
  
  sub _build_engine {
      my $self = shift;
  
      return Ze::View->new(
          engines => [
              { engine => 'Ze::View::JSON', config  => {} } 
          ]
      );
  
  }
  
  
  EOC;
---
file: lib/____var-dist-var____/API/Controller/Base.pm
template: |
  package [% dist %]::API::Controller::Base;
  use Ze::Class;
  extends '[% dist %]::WAF::Controller';
  with 'Ze::WAF::Controller::Role::JSON';
  
  
  EOC;
---
file: lib/____var-dist-var____/API/Controller/Root.pm
template: |
  package [% dist %]::API::Controller::Root;
  use Ze::Class;
  extends '[% dist %]::API::Controller::Base';
  
  use [% dist %]::Authorizer::Member;
  
  sub me {
      my ($self,$c) = @_;
      my $authorizer = [% dist %]::Authorizer::Member->new( c => $c ); 
      my $member_obj  = $authorizer->authorize();
  
      my $item = {};
      my $is_login = 0;
      if($member_obj){
          for(qw/member_id member_name/){
              $item->{$_} = $member_obj->$_;
          }
          $is_login = 1;
      }
  
      $c->set_json_stash({ item => $item , is_login => $is_login });
  
  }
  
  EOC;
---
file: lib/____var-dist-var____/Authorizer/Base.pm
template: |
  package [% module %]::Authorizer::Base;
  use Ze::Class;
  
  has c => ( is => 'rw', required => 1 );
  
  sub authorize  { die 'ABSTRACT METHOD' } 
  sub logout_url { die 'ABSTRACT METHOD' }
  
  
  EOC;
---
file: lib/____var-dist-var____/Authorizer/Member.pm
template: |+
  package [% module %]::Authorizer::Member;
  use Ze::Class;
  extends '[% module %]::Authorizer::Base';
  use [% module %]::Session;
  use [% module %]::Model::Member;
  
  sub logout {
      my $self = shift;
      my $session = [% module %]::Session->create($self->c->req,$self->c->res);
      $session->remove('member_id');
      $session->finalize();
  }
  sub authorize {
      my $self = shift;
      my $session = [% module %]::Session->create($self->c->req,$self->c->res);
  
      if( my $member_id = $session->get('member_id') ){
          return [% module %]::Model::Member->new->lookup($member_id);
      }
      return;
  }
  
  EOC;

---
file: lib/____var-dist-var____/Cache/Session.pm
template: |
  package [% dist %]::Cache::Session;
  use strict;
  use warnings;
  use base qw(Cache::Memcached::IronPlate Class::Singleton);
  use [% dist %]::Config();
  use Cache::Memcached::Fast();
  
  sub _new_instance {
      my $class = shift;
  
      my $config = [% dist %]::Config->instance->get('cache_session');
  
      my $cache = Cache::Memcached::Fast->new({
              utf8 => 1,
              servers => $config->{servers},
              compress_threshold => 5000,
              ketama_points => 150, 
              namespace => '[% appname %]s', 
          });
      my $self = $class->SUPER::new( cache => $cache );
      return $self;
  }
  
  1;
---
file: lib/____var-dist-var____/Controller/Root.pm
template: |
  package [% dist %]::Controller::Root;
  use Ze::Class;
  extends '[% dist %]::WAF::Controller';
  use [% dist %]::ObjectDriver::DBI;
  use [% dist %]::Cache;
  
  sub index {
      my ($self,$c) = @_;
  
      eval {
          my $dbh = [% dist %]::ObjectDriver::DBI->driver->rw_handle;
          $c->stash->{ok_db} = $dbh->ping;
      };
      if($@){
          $c->stash->{ok_db} = 0;
      }
  
  
      my $cache =  [% dist %]::Cache->instance();
  
      my $time = time;
      $cache->set($time,'ok');
      $c->stash->{ok_cache} = $cache->get($time);
  
  }
  
  EOC;
---
file: lib/____var-dist-var____/Data/Base.pm
template: |
  package [% dist %]::Data::Base;
  use strict;
  use warnings;
  use base qw(Data::ObjectDriver::BaseObject Class::Data::Inheritable);
  use Data::ObjectDriver::SQL;
  use Sub::Install;
  use UNIVERSAL::require;
  use [% dist %]::DateTime;
  
  __PACKAGE__->add_trigger( pre_insert => sub {
          my ( $obj, $orig ) = @_;
  
          my $now = [% dist %]::DateTime->sql_now ;
          if ( $obj->has_column('created_at') && !$obj->created_at ) {
          $obj->created_at( $now );
          $orig->created_at( $now );
          }
  
          if ( $obj->has_column('updated_at') ) {
          $obj->updated_at( $now );
          $orig->updated_at( $now );
          }
  
          my $class = ref $obj;
              my $values = $class->default_values;
              for my $key (keys %{$values}) {
                  unless (defined $obj->$key()) {
                      $obj->$key( $values->{$key} );
                      $orig->$key( $values->{$key} );
                  }
              }
          },
  );
  
  __PACKAGE__->add_trigger( pre_update => sub {
          my ( $obj, $orig ) = @_;
          if ( $obj->has_column('updated_at') ) {
              my $now = [% dist %]::DateTime->sql_now ;
              $obj->updated_at( $now );
              $orig->updated_at( $now );
          }
      }
  );
  
  __PACKAGE__->add_trigger( pre_search => sub {
          my ( $class, $terms, $args ) = @_;
          if ( $args && ( my $pager = delete $args->{pager} ) ) {
              $pager->total_entries($class->count( $terms ));
              $args->{limit}  = $pager->entries_per_page;
              $args->{offset} = $pager->skipped;
          }
      },
  );
  
  
  # always return array ref.
  sub get_primary_keys {
      my $class = shift;
      my $primary_key = $class->properties->{'primary_key'};
  
      if( ref $primary_key ) {
          return $primary_key;
      }
      else {
          return [ $primary_key ];
      }
  }
  
  sub install_plugins {
      my $class = shift;
      my $plugins = shift;
  
      for my $plugin ( @$plugins ) {
          $plugin = '[% dist %]::Data::Plugin::' . $plugin;
          $plugin->require or die $@;
          for my $method ( @{$plugin->methods} ) {
              Sub::Install::install_sub({
                  code => $method,
                  from => $plugin,
                  into => $class
              });
          }
      }
  }
  
  
  sub setup_alias {
      my $class = shift;
      my $map   = shift;
  
      for my $alias ( keys %$map ) {
          my $method_name  = $map->{$alias};
          Sub::Install::install_sub({
              code => sub { 
                  my $self = shift;
                  my $value = shift;
                  if( defined $value ) {
                      $self->$method_name( $value ) ;
                  }
                  else {
                      $self->$method_name ;
                  }
              } ,
              as   => $alias,
              into => $class
          });
      }
  }
  
  sub default_values {+{}}
  
  
  
  sub dbi_select {
      my $self  = shift;
      my $query = shift;
      my $bind  = shift || [];
      my $dbh = $self->driver->r_handle;
      my $sth = $dbh->prepare($query) or die $dbh->errstr;
      my @rows = ();
      $sth->execute( @{$bind} );
      while(my $row = $sth->fetchrow_hashref()){
          push @rows,$row;
      }
      $sth->finish;
      return \@rows;
  }
  sub dbi_search {
      my ( $self,$terms,$args,$select ) = @_;
      $select ||= '*';
      $terms ||= {};
      my $stmt = Data::ObjectDriver::SQL->new;
      $stmt->add_select($select);
      $stmt->from( [ $self->driver->table_for($self) ] );
      if ( ref($terms) eq 'ARRAY' ) {
          $stmt->add_complex_where($terms);
      }
      else {
          for my $col ( keys %$terms ) {
              $stmt->add_where( $col => $terms->{$col} );
          }
      }
  
      ## Set statement's ORDER clause if any.
      if ($args->{sort} || $args->{direction}) {
          my @order;
          my $sort = $args->{sort} || 'id';
          unless (ref $sort) {
              $sort = [{column    => $sort,
                  direction => $args->{direction}||''}];
          }
  
          my $dbd = $self->driver->dbd;
          foreach my $pair (@$sort) {
              my $col = $dbd->db_column_name( $self->driver->table_for($self) , $pair->{column} || 'id');
              my $dir = $pair->{direction} || '';
              push @order, {column => $col,
                  desc   => ($dir eq 'descend') ? 'DESC' : 'ASC',
              }
          }
  
          $stmt->order(\@order);
      }
      $stmt->limit( $args->{limit} )     if $args->{limit};
      $stmt->offset( $args->{offset} )   if $args->{offset};
      $stmt->comment( $args->{comment} ) if $args->{comment};
      if (my $terms = $args->{having}) {
          for my $col (keys %$terms) {
              $stmt->add_having($col => $terms->{$col});
          }
      }
  
      my $dbh = $self->driver->r_handle;
      my $sth = $dbh->prepare($stmt->as_sql) or die $dbh->errstr;
      my @rows = ();
      $sth->execute( @{$stmt->{bind}});
      while(my $row = $sth->fetchrow_hashref()){
          push @rows,$row;
      }
      $sth->finish;
      return \@rows;
  }
  
  sub count {
      my ( $self, $terms ) = @_;
      $terms ||= {};
      my $stmt = Data::ObjectDriver::SQL->new;
      $stmt->add_select('COUNT(*)');
      $stmt->from( [ $self->driver->table_for($self) ] );
      if ( ref($terms) eq 'ARRAY' ) {
          $stmt->add_complex_where($terms);
      }
      else {
          for my $col ( keys %$terms ) {
              $stmt->add_where( $col => $terms->{$col} );
          }
      }
      $self->driver->select_one( $stmt->as_sql, $stmt->{bind} );
  }
  sub single {
      my ( $self, $terms, $options ) = @_;
      $options ||= {};
      $options->{limit} = 1;
      my $res = $self->search( $terms, $options );
      return $res->next;
  }
  
  sub as_fdat {
      my $self = shift;
      my $column_names  = shift || $self->column_names;
      my %fdat = map { $_ => $self->$_() } @{ $column_names };
      \%fdat;
  }
  
  
  sub find_or_create {
      my $class = shift;
      my $data = shift;
      my $keys = shift;
  
      my $obj ;
      if($keys) {
          my $cond = {};
          for(@$keys) {
              $cond->{$_} = $data->{$_};
          }
          $obj = $class->single($cond);
      }
      else {
          my @cond = ();
          for(@{$class->get_primary_keys}){
              push @cond , $data->{$_};
          }
          $obj = $class->lookup(\@cond);
      }
  
      if($obj){
          return $obj;
      }else {
          $obj = $class->new(%$data);
          $obj->save();
          return $obj;
      }
  }
  
  sub update_or_create {
      my $class = shift;
      my $data = shift;
  
      my $primary_key  = $class->properties('primary_key')->{primary_key};
      my $cond ;
  
      my $pkeys = {};
      if(ref $primary_key eq 'ARRAY'){
          $cond = [];
          for(@$primary_key){
             $pkeys->{$_} = 1;
             push @$cond , $data->{$_};
          }
      }
      else {
          $cond = $data->{$primary_key};
          $pkeys->{$primary_key} = 1;
      }
  
      my $obj = $class->lookup($cond);
      if($obj){
          my $is_modified = 0;
          for my $key (keys %{$data} ) {
              next if $pkeys->{$key};
              # 同じ値のときはsetしない
  
              # undefined compair error.
              $data->{$key} = '' unless defined $data->{$key};
              my $value = $obj->$key();
              $value = '' unless defined $obj->$key();
  
              next if( $obj->$key() eq $data->{$key});
              #debugf('modified_key:[ %s ] now:%s new:%s',$key,$obj->$key,$data->{$key});
              $is_modified = 1 ;
              $obj->$key($data->{$key});
          }
  
          # 変更が無い時は書き込み処理をしない
          unless ($is_modified){
              #debugf('SAME DATA IS SET. NOT SAVED');
              return $obj ;
          }
  
      }else {
          $obj = $class->new(%$data) ;
      }
      
      $obj->save;
      return $obj;
  }
  
  # lookup_multiはデータが見つからないとレコードにNULLをいれてくるのでそれを取り除く処理付きのメソッド
  sub lookup_multi_filterd {
      my $self = shift;
      my $tmp = $self->lookup_multi(@_);
      my @objs = ();
  
      for(@$tmp){
          next unless $_;
          push @objs,$_;
      }
      return \@objs;
  }
  
  sub to_datetime {
      my($self, $column) = @_;
      my $val = $self->$column();
      return unless length $val;
  
      if ($val =~ /^\d{4}-\d{2}-\d{2}$/) {
          $val .= ' 00:00:00';
      }
  
      my $dt = [% dist %]::DateTime->parse_mysql($val) or return;
      return $dt;
  }
  
  
  
  1;
---
file: lib/____var-dist-var____/Data/Member.pm
template: |
  package [% module %]::Data::Member;
  use strict;
  use warnings;
  use base qw([% module %]::Data::Base);
  use [% module %]::ObjectDriver::Cache;
  
  __PACKAGE__->install_properties({
      columns => [qw( member_id member_name updated_at created_at)],
      datasource => 'member',
      primary_key => 'member_id',
      driver => [% module %]::ObjectDriver::Cache->driver,
  });
  
  __PACKAGE__->setup_alias({
      id => 'member_id',
      name => 'member_name',
  });
  
  sub default_values {
      return +{
          member_name => 'member',
      };
  }
  
  
  1;
---
file: lib/____var-dist-var____/Data/Plugin/AttributesDump.pm
template: |
  package [% dist %]::Data::Plugin::AttributesDump;
  
  use strict;
  use warnings;
  use base qw([% dist %]::Data::Plugin::Base);
  use [% dist %]::Util qw(from_json to_json);
  
  __PACKAGE__->methods([qw/attributes set_attributes/]);
  
  sub attributes {
      my $self = shift;
      return length $self->attributes_dump ? from_json($self->attributes_dump) : {};
  }
  
  sub set_attributes {
      my $self = shift;
      my $data = shift;
      $self->attributes_dump( to_json( $data ) );
  }
  
  1;
---
file: lib/____var-dist-var____/Data/Plugin/Base.pm
template: |+
  package [% dist %]::Data::Plugin::Base;
  use strict;
  use warnings;
  use base qw(Class::Data::Inheritable);
  __PACKAGE__->mk_classdata('methods');
  __PACKAGE__->methods([]);
  
  1;

---
file: lib/____var-dist-var____/FileGenerator/Base.pm
template: |
  package [% dist %]::FileGenerator::Base;
  use warnings;
  use strict;
  use [% dist %]::FileGenerator -command;
  use parent 'Ze::FileGenerator::Base';
  use Ze::View;
  use [% dist %]::Home;
  
  my $home = [% dist %]::Home->get();
  
  __PACKAGE__->in_path( $home->subdir("view-component/base") );
  __PACKAGE__->out_path( $home->subdir("view-include/component") );
  
  
  sub create_view {
  
      my $path = [ [% dist %]::Home->get()->subdir('view-component') , [% dist %]::Home->get()->subdir('view-include') ];
  
      return Ze::View->new(
          engines => [
              { engine => 'Ze::View::Xslate' , config => { path => $path , module => ['Text::Xslate::Bridge::Star' ] } }, 
              { engine => 'Ze::View::JSON', config  => {} } 
          ]
      );
  
  }
  
  sub execute {
      my ($self, $opt, $args) = @_;
      $self->setup();
      $self->run( $opt , $args );
  }
  1;
---
file: lib/____var-dist-var____/FileGenerator/sample.pm
template: |+
  package [% dist %]::FileGenerator::sample;
  use strict;
  use warnings;
  use base qw/[% dist %]::FileGenerator::Base/;
  
  sub run {
      my ($self, $opts) = @_;
      $self->echo();
  }
  
  sub echo {
      my $self = shift;
      my $args = shift;
  
      $self->generate(['pc'],{
          name => "sample/echo",
          vars => { 
              name => 'sample',
          },
      });
      return 1;
  }
  
  
  1;
  __END__

---
file: lib/____var-dist-var____/Model/Base.pm
template: |
  package [% module %]::Model::Base;
  use Ze::Class;
  extends 'Aplon';
  use [% module %]::Validator;
  use [% module %]::Pager;
  
  with 'Aplon::Validator::FormValidator::LazyWay';
  has '+error_class' => ( default => '[% module %]::Validator::Error' );
  
  has 'pager' => (  is => 'rw' );
  
  
  
  sub FL_instance {
      [% module %]::Validator->instance();
  }
  
  sub create_pager {
      my $self = shift;
      my $p    = shift;
      my $entries_per_page = shift || 10;
      my $pager = [% module %]::Pager->new();
      $pager->entries_per_page( $entries_per_page );
      $pager->current_page($p);
  }
  
  
  EOC;
---
file: lib/____var-dist-var____/Model/Member.pm
template: |
  package [% module %]::Model::Member;
  use Ze::Class;
  extends '[% module %]::Model::Base';
  with '[% module %]::Model::Role::DataObject';
  
  sub profiles {
      return +{ 
          create => {
              required => [qw/member_name/],
          },
      };
  }
  
  
  EOC;
---
file: lib/____var-dist-var____/Model/Role/DataObject.pm
template: |
  package [% module %]::Model::Role::DataObject;
  use Ze::Role;
  use Mouse::Util;
  
  has 'data_class' => (
      is => 'rw',
      lazy_build => 1
  );
  
  sub _build_data_class {
      my $self = shift;
      my $class = ref $self;
      my @a = split('::',$class);
      my $name = $a[-1];
      my $pkg =  '[% module %]::Data::' . $name;
      Mouse::Util::load_class($pkg); #XXX
      return $pkg;
  }
  
  sub create {
      my $self = shift;
      my $args = shift || {};
      my $profile_name = shift;
      my $v = $self->assert_with($args);
      my $obj = $self->data_class->new( %$v ) ;
      $obj->save();
      return $obj;
  }
  
  sub lookup {
      my $self = shift;
      return $self->data_class->lookup( @_ );
  }
  
  1;
---
file: lib/____var-dist-var____/ObjectDriver/Cache.pm
template: |+
  package [% dist %]::ObjectDriver::Cache;
  use warnings;
  use strict;
  use [% dist %]::Cache;
  use [% dist %]::ObjectDriver::DBI;
  use Data::ObjectDriver::Driver::Cache::Memcached;
  
  sub driver {
      Data::ObjectDriver::Driver::Cache::Memcached->new(
          cache => [% dist %]::Cache->instance(),
          fallback =>  [% dist %]::ObjectDriver::DBI->driver,
      );
  }
  
  1;

---
file: lib/____var-dist-var____/ObjectDriver/DBI.pm
template: |+
  package [% dist %]::ObjectDriver::DBI;
  use strict;
  use warnings;
  use base qw([% dist %]::ObjectDriver::Replication);
  use Ze;
  use DBI;
  use List::Util;
  use [% dist %]::Config;
  
  sub _get_dbh_master {
      if( $Ze::GLOBAL->{dbh} &&  $Ze::GLOBAL->{dbh}{master} && $Ze::GLOBAL->{dbh}{master}->ping){
          return $Ze::GLOBAL->{dbh}{master};
      }
      else {
          my $config = [% dist %]::Config->instance()->get('database')->{master};
          my $dbh = DBI->connect( $config->{dsn},$config->{username},$config->{password} ,
                             {
                                 RaiseError => 1,
                                 PrintError => 1,
                                 AutoCommit => 1,
                                 mysql_enable_utf8 => 1,
                                 mysql_connect_timeout=>4,
                             }) or die $DBI::errstr;
  
          $Ze::GLOBAL->{dbh}{master} = $dbh;
          return $dbh;
      }
  }
  
  sub _get_dbh_slave {
      my $config = [% dist %]::Config->instance()->get('database')->{slaves};
      my @slaves = List::Util::shuffle @{$config};
      for my $slave (@slaves) {
          if( $Ze::GLOBAL->{dbh} &&  $Ze::GLOBAL->{dbh}{slave} && $Ze::GLOBAL->{dbh}{slave}->ping){
              return  $Ze::GLOBAL->{dbh}{slave}; 
          }
          else {
              my $dbh = eval { DBI->connect($slave->{dsn},$slave->{username},$slave->{password},
                                        {
                                            RaiseError => 1,
                                            PrintError => 1,
                                            AutoCommit => 1,
                                            mysql_enable_utf8 => 1,
                                            mysql_connect_timeout=>4,
                                            on_connect_do => [
  #                                              "SET NAMES 'utf8'",
                                                "SET CHARACTER SET 'utf8'"
                                            ],
                                        }) or die $DBI::errstr;
                       };
              if ($@ || !$dbh) {
                  warn $@;
                  next;
              }
              $Ze::GLOBAL->{dbh}{slave} = $dbh;
              return $dbh;
          }
      }
      warn "fail connect all slaves. try connect to master";
      return _get_dbh_master();
  }
  
  sub driver {
      my $class = shift;
      $class->new(
          get_dbh => \&_get_dbh_master,
          get_dbh_slave => \&_get_dbh_slave,
      );
  }
  
  1;

---
file: lib/____var-dist-var____/ObjectDriver/Replication.pm
template: |
  package [% dist %]::ObjectDriver::Replication;
  use strict;
  use warnings;
  
  use base qw( Data::ObjectDriver::Driver::DBI );
  __PACKAGE__->mk_accessors(qw(dbh_slave get_dbh_slave));
  
  sub init {
      my $driver = shift;
      my %param = @_;
      if (my $get_dbh_slave = delete $param{get_dbh_slave}) {
          $driver->get_dbh_slave($get_dbh_slave);
      }
      $driver->SUPER::init(%param);
      return $driver;
  }
  
  sub r_handle {
      my $driver = shift;
      my $db = shift || 'main';
  
      $driver->dbh_slave(undef) if $driver->dbh_slave and !$driver->dbh_slave->ping;
      my $dbh_slave = $driver->dbh_slave;
      unless ($dbh_slave) {
          if (my $getter = $driver->get_dbh_slave) {
              $dbh_slave = $getter->();
              return $dbh_slave if $dbh_slave;
          }
      }
      $driver->rw_handle($db);
  }
  
  
  1;
---
file: lib/____var-dist-var____/PC/Context.pm
template: |
  package [% dist %]::PC::Context;
  use Ze::Class;
  extends '[% dist %]::WAF::Context';
  
  __PACKAGE__->load_plugins( 'Ze::WAF::Plugin::Encode','Ze::WAF::Plugin::AntiCSRF','Ze::WAF::Plugin::FillInForm');
  
  
  EOC;
---
file: lib/____var-dist-var____/PC/Dispatcher.pm
template: |
  package [% dist %]::PC::Dispatcher;
  use Ze::Class;
  extends 'Ze::WAF::Dispatcher::Router';
  
  sub _build_config_file {
      my $self = shift;
      $self->home->file('etc/router-pc.pl');
  }
  
  EOC;
---
file: lib/____var-dist-var____/PC/View.pm
template: |
  package [% dist %]::PC::View;
  use Ze::Class;
  extends 'Ze::WAF::View';
  use [% dist %]::Home;
  use Ze::View;
  
  sub _build_engine {
      my $self = shift;
      my $path = [ [% dist %]::Home->get()->subdir('view-pc'), [% dist %]::Home->get()->subdir('view-include/pc') ];
  
      return Ze::View->new(
          engines => [
              { engine => 'Ze::View::Xslate' , config => { path => $path , module => ['Text::Xslate::Bridge::Star' ] } }, 
              { engine => 'Ze::View::JSON', config  => {} } 
          ]
      );
  
  }
  
  
  EOC;
---
file: lib/____var-dist-var____/PC/Controller/Root.pm
template: |
  package [% dist %]::PC::Controller::Root;
  use Ze::Class;
  extends '[% dist %]::Controller::Root';
  
  
  EOC;
---
file: lib/____var-dist-var____/Validator/Error.pm
template: |
  package [% dist %]::Validator::Error;
  use Ze::Class;
  extends 'Aplon::Error';
  with 'Aplon::Error::Role::LazyWay';
  
  EOC;
---
file: lib/____var-dist-var____/Validator/Profiler.pm
template: |
  package [% dist %]::Validator::Profiler;
  
  use strict;
  use warnings;
  use Text::SimpleTable;
  use Ze::Util;
  use Term::ANSIColor;;
  use Data::Dumper;
  
  sub import {
      my $class = shift;
      my $args = shift;
      if($args){
          $SIG{__DIE__} = \&message;
      }
  }
  
  sub message {
      my $error = shift;
  
      if (ref $error eq "[% dist %]::Validator::Error"){
          my $column_width = Ze::Util::term_width() - 30;
          my $t1 =Text::SimpleTable->new([20,'VALIDATE ERROR'],[$column_width,'VALUE']);
          $t1->row('custom_invalid' , Dumper ($error->{custom_invalid}));
          $t1->row('missing' , Dumper ($error->{missing}));
          $t1->row('invalid' , Dumper ($error->{invalid}));
          $t1->row('error_keys' , Dumper ($error->{error_keys}));
          $t1->row('valid' , Dumper ($error->{valid}));
  
          print color 'yellow';
          print $t1->draw;
          print color 'reset';
  
      }
  };
  
  1;
---
file: lib/____var-dist-var____/Validator/Result.pm
template: |
  package [% dist %]::Validator::Result;
  use strict;
  use warnings;
  use parent qw(FormValidator::LazyWay::Result);
  
  sub error_fields {
      my $self = shift;
      my @f = ();
  
      if(ref $self->missing ){ 
          for(@{$self->missing}){
              push @f,$_;
          }
      }
  
      if(ref $self->invalid ){ 
          for my $key (keys %{$self->invalid} ){
              push @f,$key;
          }
      }
      return \@f;
  }
  
  
  1;
---
file: lib/____var-dist-var____/WAF/Context.pm
template: |
  package [% dist %]::WAF::Context;
  use Ze::Class;
  extends 'Ze::WAF::Context';
  use [% dist %]::Session;
  use Module::Pluggable::Object;
  
  has 'member_obj' => ( is => 'rw' );
  
  sub create_session {
      my $c = shift;
      [% dist %]::Session->create( $c->req,$c->res);
  }
  
  my $MODELS ;
  BEGIN {
      # PRE LOAD API
      $MODELS = {}; 
      my $finder = Module::Pluggable::Object->new(
          search_path => ['[% dist %]::Model'],
          except => qr/^([% dist %]::Model::Base$|[% dist %]::Model::Role::)/, 
          'require' => 1,
      );
      my @classes = $finder->plugins;
  
      for my $class (@classes) {
          (my $moniker = $class) =~ s/^[% dist %]::Model:://;
          $MODELS->{$moniker} = $class;
      }
  }
  
  sub model {
      my $c =  shift;
      my $moniker= shift;
      my $args   = shift || {};
      return $MODELS->{$moniker}->new( $args );
  }
  
  sub not_found {
      my $c = shift;
      $c->res->status( 404 );
      $c->template('404');
      $c->res->content_type( 'text/html;charset=utf-8' );
      $c->RENDER();
      $c->finished(1);
  }
  
  
  
  EOC;
---
file: lib/____var-dist-var____/WAF/Controller.pm
template: |
  package [% dist %]::WAF::Controller;
  use Ze::Class;
  use Try::Tiny;
  extends 'Ze::WAF::Controller';
  
  sub EXCECUTE {
      my( $self, $c, $action ) = @_;
  
      try {
          $self->$action( $c );
      }
      catch {
          if( ref $_ && ref $_ eq '[% dist %]::Validator::Error') {
  
              if($c->view_type && $c->view_type eq 'JSON') {
                  $c->set_json_error($_);
              }
              else {
                  $c->stash->{fdat} = $_->valid;
                  $c->stash->{error_obj} = $_;
              }
          }
          else {
              die $_; 
          }
      };
  
      return 1;
  }
  
  
  EOC;
---
file: lib/____var-dist-var____/WAF/Dispatcher.pm
template: |
  package [% dist %]::WAF::Dispatcher;
  use Ze::Class;
  extends 'Ze::WAF::Dispatcher::Router';
  EOC;
---
file: misc/____var-appname-var____.sql
template: |
  create table member (
     member_id int unsigned not null auto_increment,
     member_name varchar(255) not null,
     updated_at TIMESTAMP NOT NULL,
     created_at DATETIME NOT NULL,
     PRIMARY KEY (member_id)
  ) ENGINE=InnoDB DEFAULT CHARACTER SET = 'utf8';
---
file: t/001_t_util.t
template: |
  use Test::More;
  use_ok('t::Util');
  use [% module %]::Config;
  use Test::TCP;
  use [% module %]::Util;
  
  subtest 'memcahced' => sub {
      my $cache_config =  [% module %]::Config->instance()->get('cache');
      my ($original_port) =  $cache_config->{servers}[0] =~ /(\d+)$/;
      like($cache_config->{servers}[0] ,qr/^127\.0\.0\.1:\d+$/, 'memcached conifg serversの差し替え');
      my ($port) =  $cache_config->{servers}[0] =~ /(\d+)$/;
      sleep 1; # memcached があがるのをを待つ感じ
      is(Test::TCP::_check_port($port),1, 'memcachedたぶんあがってる');
  };
  
  
  subtest 'login' => sub {
      login();
      test_api(sub {
          my $cb  = shift;
          my $res = $cb->(GET "/me");
          is($res->code,200);
          my $data = [% module %]::Util::from_json($res->content);
          is($data->{is_login} , 1 );
      });
  
  };
  
  
  done_testing();
---
file: t/00_compile.t
template: |+
  use strict;
  use warnings;
  use Test::LoadAllModules;
  
  BEGIN {
      all_uses_ok( search_path => '[% module %]'); 
  }

---
file: t/Cache-Session.t
template: |
  use Test::More;
  use t::Util;
  
  use [% module %]::Cache::Session;
  my $session = [% module %]::Cache::Session->instance();
  
  $session->set('a','b');
  
  is($session->get('a'),'b');;
  
  
  done_testing();
---
file: t/Cache.t
template: |
  use Test::More;
  use t::Util;
  
  use [% module %]::Cache;
  my $cache = [% module %]::Cache->instance();
  
  $cache->set('a','b');
  
  is($cache->get('a'),'b');;
  
  
  done_testing();
---
file: t/Data-Member.t
template: |
  use Test::More;
  use t::Util;
  use lib 't/lib';
  use Test::[% module %]::Data;
  
  cleanup_database();
  
  use_ok('[% module %]::Data::Member');
  columns_ok('[% module %]::Data::Member');
  
  subtest 'alias' => sub {
      my $member_obj = [% module %]::Data::Member->new(
          member_id   => 1,
          member_name => 'hoge',
      );
      is($member_obj->id, 1);
      is($member_obj->name, 'hoge');
  };
  
  
  
  done_testing();
---
file: t/Model-Member.t
template: |
  use Test::More;
  use t::Util;
  
  cleanup_database;
  
  use_ok('[% module %]::Model::Member');
  
  my $model = [% module %]::Model::Member->new();
  
  subtest 'create' => sub {
      my $member_obj = $model->create({ member_name => 'teranishi' });
      isa_ok($member_obj,'[% module %]::Data::Member');
      is($member_obj->name,'teranishi');
  };
  
  done_testing();
---
file: t/Util.pm
template: |
  use strict;
  use warnings;
  use utf8;
  use lib 't/lib';
  
  package t::Util;
  use parent qw/Exporter/;
  use Plack::Test;
  use Plack::Util;
  use [% dist %]::Home;
  use Test::More();
  use HTTP::Request::Common;
  use Test::TCP qw(empty_port);
  use Proc::Guard;
  use [% dist %]::Config;
  use [% dist %]::Session;
  use HTTP::Request;
  use HTTP::Response;
  use HTTP::Message::PSGI;
  use Ze::WAF::Request;
  
  our @EXPORT = qw(
  test_pc 
  test_api
  cleanup_database
  login
  GET HEAD PUT POST);
  
  
  {
      # $? がリークすると、prove が
      #   Dubious, test returned 15 (wstat 3840, 0xf00)
      # というので $? を localize する。
      package t::Proc::Guard;
      use parent qw(Proc::Guard);
      sub stop {
          my $self = shift;
          local $?;
          $self->SUPER::stop(@_);
      }
  }
  
  our $CACHE_MEMCACHED;
  
  BEGIN {
      die 'Do not use this script on production' if $ENV{[% dist | upper %]_ENV} && $ENV{[% dist | upper %]_ENV} eq 'production';  
      my $config = [% dist %]::Config->instance();
  
      # debug off
      $config->{debug} = 0;
  
      # TEST用memcached設定　
  
       my $memcached_port = empty_port();
  
      # XXX 強制上書き
      $config->{cache} = {
          servers => ['127.0.0.1:' . $memcached_port  ],
      };
      $config->{cache_session} = {
          servers => ['127.0.0.1:' . $memcached_port  ],
      };
  
      $CACHE_MEMCACHED = t::Proc::Guard->new(
          command => ['/usr/bin/env','memcached', '-p', $memcached_port]
      );
  
      # database接続先の上書き
      my $database_config = $config->get('database');
      $database_config->{master}{dsn} =  "dbi:mysql:[% dist | lower %]_test_" . $ENV{[% dist | upper %]_ENV};
      for(@{$database_config->{slaves}}){
          $_->{dsn} =  "dbi:mysql:[% dist | lower %]_test_" . $ENV{[% dist | upper %]_ENV};
      } 
  
      #  middlware書き換え
  
      my $middleware = $config->get('middleware')->{pc} || [];
      my @middleware_new  = ();
  
      for(@$middleware){
          if( $_->{name} eq '+[% dist %]::WAF::Middleware::KYTProf') {
  
          }
          else {
              push @middleware_new,$_;
          }
      }
  
       $config->get('middleware')->{pc} = \@middleware_new;
  }
  
  
  sub test_pc {
      my $cb = shift;
      test_psgi(
          app => Plack::Util::load_psgi( [% dist %]::Home->get->file('etc/pc.psgi') ),
          client => $cb,
      );
  }
  
  sub test_api {
      my $cb = shift;
      test_psgi(
          app => Plack::Util::load_psgi( [% dist %]::Home->get->file('etc/api.psgi') ),
          client => $cb,
      );
  }
  
  sub cleanup_database {
      Test::More::note("TRUNCATING DATABASE");
      my $conf = [% dist %]::Config->instance->get('database')->{'master'};
      my @driver = ($conf->{dsn},$conf->{username},$conf->{password});
      require DBI;
      $driver[0] =~ /test/ or die "This is not in a test mode.";
      my $dbh = DBI->connect(@driver , {RaiseError => 1}) or die;
  
      my $tables = _get_tables($dbh);
      for my $table (@$tables) {
          $dbh->do(qq{DELETE FROM } . $table);
      }
      $dbh->disconnect;
  }
  sub _get_tables {
      my $dbh = shift;
      my $data = $dbh->selectall_arrayref('show tables');
      my @tables = ();
      for(@$data){
          push @tables,$_->[0];
      }
  
      return \@tables;
  }
  
  # sample
  sub create_member {
      my %args = @_;
      $args{member_name} ||= '"<xmp>テスト';
      require [% dist %]::Model::Member;
      my $member_obj = [% dist %]::Model::Member->new()->create( \%args );
      return $member_obj;
  }
  
  sub login {
      my $member_obj = shift || create_member();
  
      my $env = HTTP::Request->new(GET => "http://localhost/")->to_psgi;
      my $req  = Ze::WAF::Request->new($env);
      my $res  = $req->new_response;
      my $session = [% dist %]::Session->create($req,$res );
      
      $session->set('member_id',$member_obj->id); 
      $session->finalize();
      $ENV{HTTP_COOKIE} = $res->headers->header('SET-COOKIE');
  }
  
  1;
---
file: t/lib/App/Prove/Plugin/SchemaUpdater.pm
template: |
  # DB スキーマに変更があったら、テスト用のデータベースをまるっと作り替える
  # mysqldump --opt -d -uroot [% dist | lower %]_$ENV} | mysql -uroot [% dist | lower %]_test_${ENV}
  
  # として、データベースを作成。スキーマ定義がちがくてうごかないときも同様。
  package t::lib::App::Prove::Plugin::SchemaUpdater;
  use strict;
  use warnings;
  use Test::More;
  #use [% dist | lower %]::Home;
  
  sub run { system(@_)==0 or die "Cannot run: @_\n-- $!\n"; }
  
  sub get_[% dist | lower %]_env {
      return $ENV{[% dist | upper %]_ENV}; 
  }
  
  sub create_database {
      my ($target, $[% dist | lower %]_env) = @_;
      diag("CREATE DATABASE ${target}_test_${[% dist | lower %]_env}");
      run("mysqladmin -uroot create ${target}_test_${[% dist | lower %]_env}");
  }
  sub drop_database {
      my ($target, $[% dist | lower %]_env) = @_;
      diag("DROP DATABASE ${target}_test_${[% dist | lower %]_env}");
      run("mysqladmin --force -uroot drop ${target}_test_${[% dist | lower %]_env}");
  }
  sub copy_database {
      my ($target, $[% dist | lower %]_env) = @_;
      diag("COPY DATABASE ${target}_${[% dist | lower %]_env} to ${target}_test_${[% dist | lower %]_env}");
      run("mysqldump --opt -d -uroot ${target}_${[% dist | lower %]_env} | mysql -uroot ${target}_test_${[% dist | lower %]_env}");
  }
  sub has_database {
      my ($target, $[% dist | lower %]_env) = @_;
      return (`echo 'show databases' | mysql -u root|grep ${target}_test_${[% dist | lower %]_env} |wc -l` =~ /1/);
  }
  sub filter_dumpdata {
      my $data = join "", @_;
      $data =~ s{^/\*.*\*/;$}{}gm;
      $data =~ s{^--.*$}{}gm;
      $data =~ s{^\n$}{}gm;
      $data =~ s{ AUTO_INCREMENT=\d+}{}g;
      $data;
  }
  sub changed_database {
      my ($target, $[% dist | lower %]_env) = @_;
      my $orig = filter_dumpdata(`mysqldump --opt -d -uroot ${target}_${[% dist | lower %]_env}`);
      my $test = filter_dumpdata(`mysqldump --opt -d -uroot ${target}_test_${[% dist | lower %]_env}`);
      return ($orig ne $test);
  }
  
  
  sub load {
      my $[% dist | lower %]_env = get_[% dist | lower %]_env or die '[% dist | upper %]_ENV is not set';
      for my $target (qw/ [% dist | lower %] /) {
          if (has_database($target, $[% dist | lower %]_env)) {
              if (changed_database($target, $[% dist | lower %]_env)) {
                  drop_database($target, $[% dist | lower %]_env);
                  create_database($target, $[% dist | lower %]_env);
                  copy_database($target, $[% dist | lower %]_env);
              } else {
                  diag("NO CHANGE DATABASE ${target}_test_${[% dist | lower %]_env}");
              }
          } else {
              create_database($target, $[% dist | lower %]_env);
              copy_database($target, $[% dist | lower %]_env);
          }
      }
  }
  
  1;
---
file: t/lib/Test/____var-dist-var____/Data.pm
template: |
  package Test::[% dist %]::Data;
  use strict;
  use warnings;
  use parent qw/Exporter/;
  use Test::More();
  use [% dist %]::ObjectDriver::DBI;
  our @EXPORT = qw(columns_ok);
  
  
  sub columns_ok {
      my $pkg =  shift or die 'please set data class name';
  
      my $dbh = [% dist %]::ObjectDriver::DBI->driver->rw_handle;
  
      my %columns = map {$_ => 1 } @{$pkg->column_names};
  
      my $database_name = get_database_name($dbh);
      my $table_name = $pkg->datasource();
  
  
      my $sql = "select COLUMN_NAME from information_schema.columns c where c.table_schema = ? and c.table_name = ?";
  
  
      my $data = $dbh->selectall_arrayref($sql,{},$database_name,$table_name);
  
      my $mysql_columns = {};
      for(@$data){
          $mysql_columns->{$_->[0]} = 1; 
      }
  
      Test::More::is_deeply(\%columns,$mysql_columns,sprintf("%s's columns does not much with database and source code",$table_name));
  
  }
  
  sub get_database_name {
      my $dbh = shift;
      return $dbh->private_data->{database};
  }
  
  1;
---
file: t/PC-Controller-Root/index.t
template: |
  use Test::More;
  use t::Util;
  
  test_pc(sub {
          my $cb  = shift;
          my $res = $cb->(GET "/");
  
          is($res->code,200);
  });
  
  
  done_testing();
---
file: view-component/pc/sample/echo.tx
template: "ECHO [% \"[%\" %] name [% \"%\" %][% \"]\" %]\n"
---
file: view-include/pc/footer.inc
template: |2
          <footer>
              <p>[% dist %] powerd by Ze</p>
          </footer>
          <script src="http://ajax.googleapis.com/ajax/libs/jquery/1.7.0/jquery.min.js"></script>
          <script src="/static/common/js/jquery.cookie.js"></script>
          <script src="/static/common/js/jquery.ze.js"></script>
  [% "[%" %] footer_content [% "%" %][% "]" %]
  </body>
  </html>
---
file: view-include/pc/header.inc
template: |
  <!DOCTYPE html>
  <html lang="en">
  <head>
  <title>[% dist %]</title>
  
  <!-- Le HTML5 shim, for IE6-8 support of HTML elements -->
  <!--[if lt IE 9]>
  <script src="http://html5shim.googlecode.com/svn/trunk/html5.js"></script>
  <![endif]-->
  
  <link rel="stylesheet/less" href="/static/common/less/bootstrap.less" />
  <script src="/static/common/js/less-1.1.3.min.js"></script>
  
  <style type="text/css">
  body {
      padding : 60px;
  
  }
  </style>
  
  </head>
  <body>
      <div class="topbar">
        <div class="topbar-inner">
          <div class="container-fluid">
            <a class="brand" href="/">[% dist %]</a>
          </div>
        </div>
      </div>
---
file: view-pc/404.tx
template: |+
  [% "[%" %] INCLUDE 'header.inc' [% "%" %][% "]" %]
  
  <h3>NOT FOUND</h3>
  
  [% "[%" %] INCLUDE 'footer.inc' [% "%" %][% "]" %]

---
file: view-pc/index.tx
template: |+
  [% "[%" %] INCLUDE 'header.inc' [% "%" %][% "]" %]
  
  <h3>[% dist %]</h3>
  
  
  <table>
  <tr>
      <th>DB</th>
      <td>[% "[%" %] IF ok_db [% "%" %][% "]" %]OK[% "[%" %] ELSE [% "%" %][% "]" %]NG[% "[%" %] END [% "%" %][% "]" %]</td>
  </tr>
  <tr>
      <th>API</th>
      <td><div id="container-member_status">Loading...</div></td>
  </tr>
  <tr>
      <th>CACHE</th>
      <td>[% "[%" %] IF ok_cache [% "%" %][% "]" %]OK[% "[%" %] ELSE [% "%" %][% "]" %]NG[% "[%" %] END [% "%" %][% "]" %]</td>
  </tr>
  </table>
  
  <h4>準備</h4>
  <ul>
  <li>./bin/devel/install.sh で依存モジュールをいれます。locallib等を利用したい場合は、ソースを手直しする必要があります。</li>
  <li>[% dist | upper %]_ENV を指定してください。指定しない場合、後で述べますがsetup.sh で local を指定します。</li>
  <li>[% dist | upper %]_ENVにlocal以外を指定した場合、etc/config_local.pl の ファイル名のlocal 部分を指定した名前に変更してください</li>
  <li>mysqlを準備し、etc/config_local.pl 内の接続情報を更新(Databaseは作成しなくていいです)。</li>
  <li>memcachedサーバを準備し、etc/config_local.pl 内の設定をお更新</li>
  <li>./bin/devel/setup.sh を実行し、環境変数設定と、データベース作成をおこなう</li>
  <li>prove -lr t を実行しテストが通るか確認する</li>
  <li>plackup etc/mix.psgi を実行しこのページが見えてるか確認してみる。</li>
  </ul>
  <p>
  
  
  </p>
  
  
  
  
  
  [% "[%" %] MACRO footer_content_block  BLOCK -[% "%" %][% "]" %]
  <script>
  
          $.ajax({
              type: "get",
              url: "/api/me",
              dataType:"json",
              success: function(json){
                  $('#container-member_status').html( $('#tmpl_member_status').template(json) );
              }
          });
  
  
  </script>
  [% "[%" %] END -[% "%" %][% "]" %]
  
  <script type="text/html" id="tmpl_member_status">
  <% if ( is_login ) { %>
  OK <%= item.member_name %>
  <% } else { %>
  OK
  <% } %>
  </script>
  
  
  [% "[%" %] INCLUDE 'footer.inc' WITH
      footer_content = footer_content_block()
  [% "%" %][% "]" %]

---
plugin: Zplon.pm
template: |
  package Ze::_::Helpper::Zplon;
  use strict;
  use warnings;
  use base 'Module::Setup::Plugin';
  
  
  sub register {
      my ( $self, ) = @_;
      $self->add_trigger( 'after_setup_template_vars' => \&after_setup_template_vars );
  }
  
  sub after_setup_template_vars {
      my ( $self, $config ) = @_;
  
      my $name = $self->distribute->{module};
  
      $config->{appname} = lc $config->{module};
  
      $config;
  
  }
  1;
---
config:
  class: Ze::Helper::Zplon
  module_setup_flavor_devel: 1
  plugins:
    - Config::Basic
    - Template
    - Additional
    - VC::Git
    - +Ze::_::Helpper::Zplon


