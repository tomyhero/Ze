
package Ze::Helper::API;
use strict;
use warnings;
use base 'Module::Setup::Flavor';
1;

=head1

Ze::Helper::API - pack from Ze::Helper::API

=head1 SYNOPSIS

  Ze::Helper::API-setup --init --flavor-class=+Ze::Helper::API new_flavor

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
  /view-component
---
file: .proverc
template: |
  "--exec=perl -Ilib -It/lib -I. -Mt::Util"
  --color
  -Pt::lib::App::Prove::Plugin::SchemaUpdater
---
file: Changes
is_binary: 1
template: ''
---
file: Makefile.PL
template: |
  use inc::Module::Install;
  name '<+ dist +>';
  all_from 'lib/<+ dist +>.pm';
  
  requires (
    "Ze" => 0.04,
    "Aplon" => 0,
    "DBD::mysql" => 0,
    "Devel::KYTProf" => 0,
    "Proc::Guard" => 0,
    "HTTP::Session" => 0,
    "POSIX::AtFork" => 0,
    "File::RotateLogs" => 0,
    "Plack::Middleware::ServerStatus::Lite" => 0,
    "Plack::Middleware::ReverseProxy" => 0,
    "FormValidator::LazyWay" => 0,
    "Data::Page" => 0,
    "Data::Page::Navigation" => 0,
    "URI::QueryParam" => 0,
    "Data::Section::Simple" => 0,
    "DBIx::TransactionManager" => 0,
    "Data::ObjectDriver" => 0,
    "DateTime::Format::MySQL" => 0,
    "Data::GUID" => 0,
    "Data::GUID::URLSafe" => 0,
    "Digest::SHA" => 0,
    "Data::LazyACL" => 0,
    "Locale::Maketext::Lexicon" => 0,
  );
  
  test_requires(
      'Test::LoadAllModules' => 0,
  );
  
  tests_recursive;
  
  build_requires 'Test::More';
  auto_include;
  WriteAll;
---
file: README
template: "READ ME HERE\n"
---
file: bin/cli.pl
template: |
  #!/usr/bin/env perl
  
  use strict;
  use warnings;
  use FindBin::libs;
  use <+ dist +>::CLI;
  
  <+ dist +>::CLI->run();
---
file: bin/filegenerator.pl
template: |+
  #!/usr/bin/env perl
  
  use strict;
  use warnings;
  use FindBin::libs ;
  use <+ dist +>::FileGenerator;
  
  <+ dist +>::FileGenerator->run();
  

---
file: bin/devel/install.sh
template: |
  #!/bin/sh
  
  install_ext() {
      if [ -e ~/work/$2 ]
      then
          cd ~/work/$2
          git pull
          cpanm --installdeps .
          cpanm .
      else
          git clone $1 ~/work/$2
          cd ~/work/$2
          cpanm --installdeps .
          cpanm .
      fi
  }
  
  cpanm Module::Install
  cpanm Module::Install::Repository
  
  install_ext git://github.com/tomyhero/p5-App-Home.git p5-App-Home
  install_ext git://github.com/tomyhero/Ze.git Ze
  install_ext git://github.com/tomyhero/p5-Aplon.git p5-Aplon
  install_ext git://github.com/kazeburo/Cache-Memcached-IronPlate.git Cache-Memcached-IronPlate
  install_ext git://github.com/onishi/perl5-devel-kytprof.git Devel-KYTProf
  
  
  cpanm --installdeps .
---
file: bin/devel/setup.sh
template: |
  #!/bin/sh
  
  ln -s ./../../../asset/lib/<+ dist +>X/Overwrite lib/<+ dist +>X/
  ln -s ./../asset/config .
  ln -s ./../asset/data .
  
  ln -s ./../../po ./t/root/
  ln -s ./../../psgi ./t/root/
  ln -s ./../../router ./t/root/ 
  ln -s ./../../view-include ./t/root/ 
  ln -s ./../../view-op ./t/root/
---
file: bin/tool/op_i18n.pl
template: |
  #!/usr/bin/env perl
  
  system( 'xgettext.pl -D view-include/op -D view-op-D -o po/op/ja_JP.po' );
---
file: doc/api.pl
template: |
  use utf8;
  use strict;
  use warnings; 
  
  return +[
      {
        name => "Basic",
        list => 
        [
          {
            description => "get application information such as versions",
            path => '/app/info',
            requests => {},
            response => {},
            custom_errors => {}
          }  
        ],
      },
      {
        name => "Member Basic",
        list => 
        [
        {
          description => "make member account on system",
          path => "/app/auth_terminal/register",
          requests => {
              member_name => 'member name',
              language => 'language',
              timezone  => 'timezone',
              terminal_type  => 'terminal type',
              terminal_info => 'terminal info'
          },
          response => {
            'item.member_id' => '',
            'item.language' => '',
            'item.terminal_code' => ''
          },
          custom_errors => {}
        },
        {
          description => "login and get access_token",
          path => "/app/auth_terminal/login",
          requests => {
            terminal_code => '', 
          },
          response => {
            'item.access_token' => 'access token', 
          },
          custom_errors => {
            login_fail => 'throw when login fail',
          }
        },
        {
          description => "get member current basic info",
          path => "/app/member/me",
          requests => {},
          response => {
              "item.member_id" => "member id",
          }, 
          custom_errors => {}
        },
      ]
    },
  ];
---
file: htdocs-internal/static/common/js/jquery.cookie.js
template: |
  /**
   *  * jQuery Cookie plugin
   *   *
   *    * Copyright (c) 2010 Klaus Hartl (stilbuero.de)
   *     * Dual licensed under the MIT and GPL licenses:
   *      * http://www.opensource.org/licenses/mit-license.php
   *       * http://www.gnu.org/licenses/gpl.html
   *        *
   *         */
  jQuery.cookie = function (key, value, options) {
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
  
      options = value || {};
      var result, decode = options.raw ? function (s) { return s; } : decodeURIComponent;
      return (result = new RegExp('(?:^|; )' + encodeURIComponent(key) + '=([^;]*)').exec(document.cookie)) ? decode(result[1]) : null;
  };
---
file: htdocs-internal/static/common/js/jquery.ze.js
template: |
  jQuery.fn.extend({
      template : function(data){
          var tmpl_data = $(this).html();
  
          var fn = new Function("obj",
              "var p=[];" +
  
              "with(obj){p.push('" +
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
  
  if (window.console && window.console.log ) {
      window.log = window.console.log
  } else {
      window.console = {
          log: function () {}
      }
  }
---
file: htdocs-internal/static/css/base.css
template: |+
  m_info-container
  html,
  button,
  input,
  select,
  textarea {
      color: #222;
  }
  
  html {
      font-size: 1em;
      line-height: 1.4;
  }
  
  /*
   *  * Remove text-shadow in selection highlight: h5bp.com/i
   *   * These selection rule sets have to be separate.
   *    * Customize the background color to match your design.
   *     */
  
  ::-moz-selection {
      background: #b3d4fc;
      text-shadow: none;
  }
  
  ::selection {
      background: #b3d4fc;
      text-shadow: none;
  }
  
  /*
   *  * A better looking default horizontal rule
   *   */
  
  hr {
      display: block;
      height: 1px;
      border: 0;
      border-top: 1px solid #ccc;
      margin: 1em 0;
      padding: 0;
  }
  
  /*
   *  * Remove the gap between images, videos, audio and canvas and the bottom of
   *   * their containers: h5bp.com/i/440
   *    */
  
  audio,
  canvas,
  img,
  video {
      vertical-align: middle;
  }
  
  /*
   *  * Remove default fieldset styles.
   *   */
  
  fieldset {
      border: 0;
      margin: 0;
      padding: 0;
  }
  
  /*
   *  * Allow only vertical resizing of textareas.
   *   */
  
  textarea {
      resize: vertical;
  }
  
  /* ==========================================================================
   *    Browse Happy prompt
   *       ========================================================================== */
  
  .browsehappy {
      margin: 0.2em 0;
      background: #ccc;
      color: #000;
      padding: 0.2em 0;
  }
  
  /* ==========================================================================
   *    Author's custom styles
   *       ========================================================================== */
  
  body {
      color: #333;
      line-height: 1.4;
      font-size: 14px;
  }
  
  a {
      color: #069;
  }
  a:link,
  a:visited {
      text-decoration: none;
  }
  a:hover,
  a:active {
      text-decoration: underline;
  }
  input[type="text"] { width:300}
  textarea { width:300 ; height:100 }
  input[type="submit"] {
      padding: 4px 10px;
      margin: 4px;
      border-radius: 3px;
      border: solid 1px #ccc;
      background: #ddd;
  }
  input[type="submit"]:hover {
      background: #eee;
  }
  
  .login-bar {
      border-bottom: solid 1px #e3e3e3;
      padding: 1em;
      text-align: right;
      min-width: 900px;
      font-size: 12px;
  }
  #menu_container {
      border-bottom: solid 1px #e3e3e3;
      font-size: 12px;
      padding: 1em;
      background: #EEE;
      margin-bottom: 1em;
      min-width: 900px;
  }
  ul#menu {
      list-style: none;
      margin: 0;
      margin-bottom: 10px;
      padding: 0 8px;
  }
  ul#menu li {
      display: inline-block;
  }
  ul#menu li b {
      display: inline-block;
      padding: 4px;
      background: #ddd;
  }
  ul#menu li a {
      display: inline-block;
      padding: 4px;
  }
  ul#sub_menu {
      list-style: none;
      margin: 0;
      padding: 0;
      font-size: 12px;
      width: 900px;
  }
  ul#sub_menu li {
      display: inline-block;
      width: 200px;
      margin: 4px;
      line-height: 1;
  }
  ul#sub_menu li b {
      display: block;
      width: 200px;
      padding: 4px;
  }
  ul#sub_menu li a {
      display: block;
      padding: 4px;
  }
  ul#sub_menu li a:hover {
      background: #ddd;
      text-decoration: none;
  }
  
  table.search {
      border-collapse: separate;
      border-spacing: 2px;
      margin: 1em;
  }
  table.search input[type="text"] {
      width: 400px;
  }
  .search th {
      /* font-size : x-small ; */
      background-color: #aceebe;
      padding: 4px 10px;
      text-align: right;
  }
  .search td {
      /* font-size : x-small; */
      padding: 4px 10px;
  }
  
  
  table.form {
      border-collapse: separate;
      border-spacing: 2px;
      margin: 1em;
  }
  table.form input[type="text"] {
      width: 400px;
  }
  table.form textarea {
      width: 400px;
      height: 100px;
  }
  table.form th {
      /* font-size : x-small ; */
      background-color: rgba(57.3%, 94.1%, 67.5%, 1.0);
      padding: 4px 10px;
      text-align: right;
  }
  table.form td {
      /* font-size : x-small; */
      padding: 4px 10px;
  }
  
  
  table.detail {
      border-collapse: separate;
      border-spacing: 2px;
      margin: 1em;
  }
  table.detail th {
      font-size: x-small;
      background-color: rgba(65,131,196,0.4);
      padding: 4px 10px;
      text-align: right;
      width: 200px;
      border: solid 1px transparent;
  }
  table.detail td {
      padding: 4px 10px;
      font-size: 12px;
      width: 400px;
      border: solid 1px #eee;
  }
  
  .detail-wrapper {
      position: relative;
      min-width: 700px;
      padding: 0 10px;
  }
  .detail-sub-container {
      position: absolute;
      top: 0;
      right: 10px;
      width: 200px;
  }
  .detail-main-container {
      margin-right: 220px;
  }
  ul.detail-nav {
      font-size: 14px;
      list-style: none;
      margin: 0;
      padding: 10px;
      font-size: 20px;
      margin-bottom: 10px;
      background: #eee;
      border: solid 1px #e3e3e3;
      margin-right: 10px;
  }
  ul.detail-nav.type-l {
      font-size: 14px;
  }
  ul.detail-nav.type-l li a:before {
      content: "[ ";
  }
  ul.detail-nav.type-l li a:after {
      content: " ]";
  }
  ul.detail-nav.type-s {
      font-size: 12px;
  }
  ul.detail-nav li a {
      display: block;
      padding: 4px;
  }
  ul.detail-nav li a:hover {
      background: #ddd;
      text-decoration: none;
  }
  
  
  table.listing {
      width: 100%;
  }
  table.listing tr:nth-child(even) {
      background:#fff;
  }
  table.listing tr:nth-child(odd) {
      background:#eee;
  }
  table.listing tr:hover {
      background: #ffffcc;
  }
  .listing th {
      font-size : x-small;
      background-color: rgba(65,131,196,0.4);
      padding: 10px 4px;
      border-left: dotted 1px #ccc;
  }
  .listing td {
      font-size : 11px;
      padding: 8px;
      border-left: dotted 1px #ccc;
  }
  .listing th.notice { background-color : #ff689a; }
  .listing td.num { text-align : right;}
  
  
  table th.operation_memo { background-color : #7cc0ff; }
  
  .pager {
      padding: 1em;
      text-align: center;
      font-size: 12px;
  }
  .pager li {
      display: inline-block;
      margin: 4px;
  }
  .pager li:before {
      content: " | ";
  }
  .pager li:first-child:before {
      content: "";
  }
  .pager .input-mysize {
      width: 4em;
  }
  
  .copyright {
      text-align: center;
      font-size: 10px;
      margin: 10em 0;
      font-family: Helvetica, verdana;
  }
  
  .sys-msg-finish {
      margin: 0 1em;
      padding-top: 20px;
      padding-bottom: 20px;
      border-radius: 6px;
      box-shadow: 0 0 4px #ccc;
      border: solid 2px #00CCA3;
      display: inline-block;
  }
  .sys-msg-finish li {
      padding-right: 4em;
  }
  
  .bold {
      font-weight: bold;
  }
  
  
  .m_info-container {
      padding: 10px;
      border: solid 1px #e5e5e5;
      border-radius: 3px;
      margin: 10px 0;
      font-size: 11px;
      color: #333;
      box-shadow: 0 0 3px rgba(152,152,152,0.2);
      font-family: Arial,sans-serif;
  }
  .m_info-container table {
      border-collapse: collapse;
      border-spacing: 0;
      width: 100%;
      margin-bottom: 15px;
      border: solid 1px #eee;
  }
  .m_info-container table th,
  .m_info-container table td {
      padding: 8px 8px;
      border-bottom: solid 1px #e5e5e5;
  }
  .m_info-container table th {
      text-align: left;
      background: #fafafa;
      border-right: solid 1px #e5e5e5;
      color: #666;
  }
  .m_info-container table td {
      vertical-align: top;
  }
  .m_info-container table thead th {
      vertical-align: bottom;
  }
  .m_info-container table caption,
  .m_info-container table tfoot {
      font-size: 12px;
      font-style: italic;
  }
  .m_info-container table caption {
      text-align: left;
      color: #999999;
  }
  
  .m_info-container ul {
      padding: 0;
      list-style: none;
  }
  .m_info-container ul ul li  {
      border-left: 3px solid #CACDD0;
      margin-bottom: 3px;
      padding-left: 10px;
      -webkit-transition: all 0.3s ease;
      -moz-transition: all 0.3s ease;
      -o-transition: all 0.3s ease;
      transition: all  0.3s ease;
  }
  .m_info-container ul ul li:hover  {
      border-left: 3px solid #1FA2D6;
      background: #fafafa;
  }
  .m_info-container ul ul li a {
      display: block;
  }
  .m_info-container ul > li > :last-child {
      margin-bottom: 0;
  }
  .m_info-container ul ul {
      margin: 0;
      padding-left: 20px;
      list-style: none;
      margin-bottom: 10px;
  }
  .m_info-container ul > li {
      padding: 5px 5px;
  }
  
  
  
  /* ==========================================================================
   *    Helper classes
   *       ========================================================================== */
  
  /*
   *  * Image replacement
   *   */
  
  .ir {
      background-color: transparent;
      border: 0;
      overflow: hidden;
      /* IE 6/7 fallback */
                *text-indent: -9999px;
            }
  
            .ir:before {
                content: "";
                display: block;
                width: 0;
                height: 150%;
            }
  
            /*
             *  * Hide from both screenreaders and browsers: h5bp.com/u
             *   */
  
  .hidden {
      display: none !important;
      visibility: hidden;
  }
  
  /*
   *  * Hide only visually, but have it available for screenreaders: h5bp.com/v
   *   */
  
  .visuallyhidden {
      border: 0;
      clip: rect(0 0 0 0);
      height: 1px;
      margin: -1px;
      overflow: hidden;
      padding: 0;
      position: absolute;
      width: 1px;
  }
  
  /*
   *  * Extends the .visuallyhidden class to allow the element to be focusable
   *   * when navigated to via the keyboard: h5bp.com/p
   *    */
  
  .visuallyhidden.focusable:active,
  .visuallyhidden.focusable:focus {
      clip: auto;
      height: auto;
      margin: 0;
      overflow: visible;
      position: static;
      width: auto;
  }
  
  /*
   *  * Hide visually and from screenreaders, but maintain layout
   *   */
  
  .invisible {
      visibility: hidden;
  }
  
  /*
   *  * Clearfix: contain floats
   *   *
   *    * For modern browsers
   *     * 1. The space content is one way to avoid an Opera bug when the
   *      *    `contenteditable` attribute is included anywhere else in the document.
   *       *    Otherwise it causes space to appear at the top and bottom of elements
   *        *    that receive the `clearfix` class.
   *         * 2. The use of `table` rather than `block` is only necessary if using
   *          *    `:before` to contain the top-margins of child elements.
   *           */
  
  .clearfix:before,
  .clearfix:after {
      content: " "; /* 1 */
      display: table; /* 2 */
  }
  
  .clearfix:after {
      clear: both;
  }
  
  /*
   *  * For IE 6/7 only
   *   * Include this rule to trigger hasLayout and contain floats.
   *    */
  
  .clearfix {
      *zoom: 1;
  }
  
  /* ==========================================================================
   *    EXAMPLE Media Queries for Responsive Design.
   *       These examples override the primary ('mobile first') styles.
   *          Modify as content requires.
   *             ========================================================================== */
  
  @media only screen and (min-width: 35em) {
      /* Style adjustments for viewports that meet the condition */
  }
  
  @media print,
  (-o-min-device-pixel-ratio: 5/4),
  (-webkit-min-device-pixel-ratio: 1.25),
  (min-resolution: 120dpi) {
      /* Style adjustments for high resolution devices */
  }
  
  /* ==========================================================================
   *    Print styles.
   *       Inlined to avoid required HTTP connection: h5bp.com/r
   *          ========================================================================== */
  
  @media print {
      * {
          *     background: transparent !important;
          *         color: #000 !important; /* Black prints faster: h5bp.com/s */
          box-shadow: none !important;
          text-shadow: none !important;
      }
  
      a,
      a:visited {
          text-decoration: underline;
      }
  
      a[href]:after {
          content: " (" attr(href) ")";
      }
  
      abbr[title]:after {
          content: " (" attr(title) ")";
      }
  
      /*
       *   * Don't show links for images, or javascript/internal links
       *     */
  
  .ir a:after,
  a[href^="javascript:"]:after,
  a[href^="#"]:after {
      content: "";
  }
  
  pre,
  blockquote {
      border: 1px solid #999;
      page-break-inside: avoid;
  }
  
  thead {
      display: table-header-group; /* h5bp.com/t */
  }
  
  tr,
  img {
      page-break-inside: avoid;
  }
  
  img {
      max-width: 100% !important;
  }
  
  @page {
      margin: 0.5cm;
  }
  
  p,
  h2,
  h3 {
      orphans: 3;
      widows: 3;
  }
  
  h2,
  h3 {
      page-break-after: avoid;
  }
  }

---
file: htdocs-internal/static/css/normalize.css
template: |
  /*! normalize.css v1.1.3 | MIT License | git.io/normalize */
  
  /* ==========================================================================
     HTML5 display definitions
     ========================================================================== */
  
  /**
   * Correct `block` display not defined in IE 6/7/8/9 and Firefox 3.
   */
  
  article,
  aside,
  details,
  figcaption,
  figure,
  footer,
  header,
  hgroup,
  main,
  nav,
  section,
  summary {
      display: block;
  }
  
  /**
   * Correct `inline-block` display not defined in IE 6/7/8/9 and Firefox 3.
   */
  
  audio,
  canvas,
  video {
      display: inline-block;
      *display: inline;
      *zoom: 1;
  }
  
  /**
   * Prevent modern browsers from displaying `audio` without controls.
   * Remove excess height in iOS 5 devices.
   */
  
  audio:not([controls]) {
      display: none;
      height: 0;
  }
  
  /**
   * Address styling not present in IE 7/8/9, Firefox 3, and Safari 4.
   * Known issue: no IE 6 support.
   */
  
  [hidden] {
      display: none;
  }
  
  /* ==========================================================================
     Base
     ========================================================================== */
  
  /**
   * 1. Correct text resizing oddly in IE 6/7 when body `font-size` is set using
   *    `em` units.
   * 2. Prevent iOS text size adjust after orientation change, without disabling
   *    user zoom.
   */
  
  html {
      font-size: 100%; /* 1 */
      -ms-text-size-adjust: 100%; /* 2 */
      -webkit-text-size-adjust: 100%; /* 2 */
  }
  
  /**
   * Address `font-family` inconsistency between `textarea` and other form
   * elements.
   */
  
  html,
  button,
  input,
  select,
  textarea {
      font-family: sans-serif;
  }
  
  /**
   * Address margins handled incorrectly in IE 6/7.
   */
  
  body {
      margin: 0;
  }
  
  /* ==========================================================================
     Links
     ========================================================================== */
  
  /**
   * Address `outline` inconsistency between Chrome and other browsers.
   */
  
  a:focus {
      outline: thin dotted;
  }
  
  /**
   * Improve readability when focused and also mouse hovered in all browsers.
   */
  
  a:active,
  a:hover {
      outline: 0;
  }
  
  /* ==========================================================================
     Typography
     ========================================================================== */
  
  /**
   * Address font sizes and margins set differently in IE 6/7.
   * Address font sizes within `section` and `article` in Firefox 4+, Safari 5,
   * and Chrome.
   */
  
  h1 {
      font-size: 2em;
      margin: 0.67em 0;
  }
  
  h2 {
      font-size: 1.5em;
      margin: 0.83em 0;
  }
  
  h3 {
      font-size: 1.17em;
      margin: 1em 0;
  }
  
  h4 {
      font-size: 1em;
      margin: 1.33em 0;
  }
  
  h5 {
      font-size: 0.83em;
      margin: 1.67em 0;
  }
  
  h6 {
      font-size: 0.67em;
      margin: 2.33em 0;
  }
  
  /**
   * Address styling not present in IE 7/8/9, Safari 5, and Chrome.
   */
  
  abbr[title] {
      border-bottom: 1px dotted;
  }
  
  /**
   * Address style set to `bolder` in Firefox 3+, Safari 4/5, and Chrome.
   */
  
  b,
  strong {
      font-weight: bold;
  }
  
  blockquote {
      margin: 1em 40px;
  }
  
  /**
   * Address styling not present in Safari 5 and Chrome.
   */
  
  dfn {
      font-style: italic;
  }
  
  /**
   * Address differences between Firefox and other browsers.
   * Known issue: no IE 6/7 normalization.
   */
  
  hr {
      -moz-box-sizing: content-box;
      box-sizing: content-box;
      height: 0;
  }
  
  /**
   * Address styling not present in IE 6/7/8/9.
   */
  
  mark {
      background: #ff0;
      color: #000;
  }
  
  /**
   * Address margins set differently in IE 6/7.
   */
  
  p,
  pre {
      margin: 1em 0;
  }
  
  /**
   * Correct font family set oddly in IE 6, Safari 4/5, and Chrome.
   */
  
  code,
  kbd,
  pre,
  samp {
      font-family: monospace, serif;
      _font-family: 'courier new', monospace;
      font-size: 1em;
  }
  
  /**
   * Improve readability of pre-formatted text in all browsers.
   */
  
  pre {
      white-space: pre;
      white-space: pre-wrap;
      word-wrap: break-word;
  }
  
  /**
   * Address CSS quotes not supported in IE 6/7.
   */
  
  q {
      quotes: none;
  }
  
  /**
   * Address `quotes` property not supported in Safari 4.
   */
  
  q:before,
  q:after {
      content: '';
      content: none;
  }
  
  /**
   * Address inconsistent and variable font size in all browsers.
   */
  
  small {
      font-size: 80%;
  }
  
  /**
   * Prevent `sub` and `sup` affecting `line-height` in all browsers.
   */
  
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
  
  /* ==========================================================================
     Lists
     ========================================================================== */
  
  /**
   * Address margins set differently in IE 6/7.
   */
  
  dl,
  menu,
  ol,
  ul {
      margin: 1em 0;
  }
  
  dd {
      margin: 0 0 0 40px;
  }
  
  /**
   * Address paddings set differently in IE 6/7.
   */
  
  menu,
  ol,
  ul {
      padding: 0 0 0 40px;
  }
  
  /**
   * Correct list images handled incorrectly in IE 7.
   */
  
  nav ul,
  nav ol {
      list-style: none;
      list-style-image: none;
  }
  
  /* ==========================================================================
     Embedded content
     ========================================================================== */
  
  /**
   * 1. Remove border when inside `a` element in IE 6/7/8/9 and Firefox 3.
   * 2. Improve image quality when scaled in IE 7.
   */
  
  img {
      border: 0; /* 1 */
      -ms-interpolation-mode: bicubic; /* 2 */
  }
  
  /**
   * Correct overflow displayed oddly in IE 9.
   */
  
  svg:not(:root) {
      overflow: hidden;
  }
  
  /* ==========================================================================
     Figures
     ========================================================================== */
  
  /**
   * Address margin not present in IE 6/7/8/9, Safari 5, and Opera 11.
   */
  
  figure {
      margin: 0;
  }
  
  /* ==========================================================================
     Forms
     ========================================================================== */
  
  /**
   * Correct margin displayed oddly in IE 6/7.
   */
  
  form {
      margin: 0;
  }
  
  /**
   * Define consistent border, margin, and padding.
   */
  
  fieldset {
      border: 1px solid #c0c0c0;
      margin: 0 2px;
      padding: 0.35em 0.625em 0.75em;
  }
  
  /**
   * 1. Correct color not being inherited in IE 6/7/8/9.
   * 2. Correct text not wrapping in Firefox 3.
   * 3. Correct alignment displayed oddly in IE 6/7.
   */
  
  legend {
      border: 0; /* 1 */
      padding: 0;
      white-space: normal; /* 2 */
      *margin-left: -7px; /* 3 */
  }
  
  /**
   * 1. Correct font size not being inherited in all browsers.
   * 2. Address margins set differently in IE 6/7, Firefox 3+, Safari 5,
   *    and Chrome.
   * 3. Improve appearance and consistency in all browsers.
   */
  
  button,
  input,
  select,
  textarea {
      font-size: 100%; /* 1 */
      margin: 0; /* 2 */
      vertical-align: baseline; /* 3 */
      *vertical-align: middle; /* 3 */
  }
  
  /**
   * Address Firefox 3+ setting `line-height` on `input` using `!important` in
   * the UA stylesheet.
   */
  
  button,
  input {
      line-height: normal;
  }
  
  /**
   * Address inconsistent `text-transform` inheritance for `button` and `select`.
   * All other form control elements do not inherit `text-transform` values.
   * Correct `button` style inheritance in Chrome, Safari 5+, and IE 6+.
   * Correct `select` style inheritance in Firefox 4+ and Opera.
   */
  
  button,
  select {
      text-transform: none;
  }
  
  /**
   * 1. Avoid the WebKit bug in Android 4.0.* where (2) destroys native `audio`
   *    and `video` controls.
   * 2. Correct inability to style clickable `input` types in iOS.
   * 3. Improve usability and consistency of cursor style between image-type
   *    `input` and others.
   * 4. Remove inner spacing in IE 7 without affecting normal text inputs.
   *    Known issue: inner spacing remains in IE 6.
   */
  
  button,
  html input[type="button"], /* 1 */
  input[type="reset"],
  input[type="submit"] {
      -webkit-appearance: button; /* 2 */
      cursor: pointer; /* 3 */
      *overflow: visible;  /* 4 */
  }
  
  /**
   * Re-set default cursor for disabled elements.
   */
  
  button[disabled],
  html input[disabled] {
      cursor: default;
  }
  
  /**
   * 1. Address box sizing set to content-box in IE 8/9.
   * 2. Remove excess padding in IE 8/9.
   * 3. Remove excess padding in IE 7.
   *    Known issue: excess padding remains in IE 6.
   */
  
  input[type="checkbox"],
  input[type="radio"] {
      box-sizing: border-box; /* 1 */
      padding: 0; /* 2 */
      *height: 13px; /* 3 */
      *width: 13px; /* 3 */
  }
  
  /**
   * 1. Address `appearance` set to `searchfield` in Safari 5 and Chrome.
   * 2. Address `box-sizing` set to `border-box` in Safari 5 and Chrome
   *    (include `-moz` to future-proof).
   */
  
  input[type="search"] {
      -webkit-appearance: textfield; /* 1 */
      -moz-box-sizing: content-box;
      -webkit-box-sizing: content-box; /* 2 */
      box-sizing: content-box;
  }
  
  /**
   * Remove inner padding and search cancel button in Safari 5 and Chrome
   * on OS X.
   */
  
  input[type="search"]::-webkit-search-cancel-button,
  input[type="search"]::-webkit-search-decoration {
      -webkit-appearance: none;
  }
  
  /**
   * Remove inner padding and border in Firefox 3+.
   */
  
  button::-moz-focus-inner,
  input::-moz-focus-inner {
      border: 0;
      padding: 0;
  }
  
  /**
   * 1. Remove default vertical scrollbar in IE 6/7/8/9.
   * 2. Improve readability and alignment in all browsers.
   */
  
  textarea {
      overflow: auto; /* 1 */
      vertical-align: top; /* 2 */
  }
  
  /* ==========================================================================
     Tables
     ========================================================================== */
  
  /**
   * Remove most spacing between table cells.
   */
  
  table {
      border-collapse: collapse;
      border-spacing: 0;
  }
---
file: lib/____var-dist-var____.pm
template: |
  package <+ dist +>;
  use strict;
  use warnings;
  
  our $VERSION = "0.0.1";
  
  
  1;
---
file: lib/____var-dist-var____/API.pm
template: |
  package <+ dist +>::API;
  use Ze::Class;
  extends 'Ze::WAF';
  use POSIX::AtFork;
  
  sub BUILD {
      # For true random. once execute srand() per fork child.
      POSIX::AtFork->add_to_child(sub { srand() });
  }
      
  EOC;
---
file: lib/____var-dist-var____/Cache.pm
template: |
  package <+ dist +>::Cache;
  use strict;
  use warnings;
  use base qw(Cache::Memcached::IronPlate Class::Singleton);
  use <+ dist +>X::Config();
  use Cache::Memcached::Fast();
  
  sub _new_instance {
      my $class = shift;
  
      my $config = <+ dist +>X::Config->instance->get('cache');
  
      my $cache = Cache::Memcached::Fast->new({
              utf8 => 1,
              servers => $config->{servers},
              compress_threshold => 5000,
              ketama_points => 150, 
              namespace => '<+ dist | lower +>', 
          });
      my $self = $class->SUPER::new( cache => $cache );
      return $self;
  }
  
  1;
---
file: lib/____var-dist-var____/CLI.pm
template: |
  package <+ dist +>::CLI;
  use App::Cmd::Setup -app;
  
  sub plugin_search_path {shift}
  
  sub _module_pluggable_options {
      return (
          except => ['<+ dist +>::CLI::Base'],
      );
  };
  
  
  1;
---
file: lib/____var-dist-var____/ClientDetector.pm
template: |
  package <+ dist +>::ClientDetector;
  use strict;
  use Ze::Class;
  use <+ dist +>X::Config;
  use <+ dist +>X::Constants qw(:version_status :terminal_type);
  
  has 'application_version' => ( is=> 'rw',required => 1 );
  has 'client_name' => ( is => 'rw');
  has 'version' => ( is => 'rw');
  
  sub BUILD {
      my $self = shift;
      $self->_parse_application_version($self->application_version);
  }
  
  sub _parse_application_version {
      my $self = shift;
      my $application_version = shift or die 'application_version not found';
      my ($client,$version) = split('_',$application_version);
      die 'Client Not Found' unless $client =~ /^(iOS|Android)$/;
      die 'not version' unless $version =~ /^[0-9]*$/;
  
      $self->client_name($client);
      $self->version($version);
  }
  
  sub is_iOS {
      my $self = shift;
      return $self->client_name eq 'iOS' ? 1 : 0;
  }
  
  sub get_version_status {
      my $self = shift;
      my $config = <+ dist +>X::Config->instance()->get('application_version')->{$self->client_name};
      return VERSION_STATUS_REQUIRE_TO_UPDATE if $self->version < $config->{min};
      return VERSION_STATUS_RECOMMEND_TO_UPDATE  if $self->version < $config->{current};
      return VERSION_STATUS_OK;
  }
  
  sub is_required_to_update {
      my $self = shift;
      my $status = $self->get_version_status();
      return $status == VERSION_STATUS_REQUIRE_TO_UPDATE ? 1 : 0;
  }
  
  sub terminal_type {
      my $self = shift;
      return TERMINAL_TYPE_IOS if $self->client_name eq 'iOS';
      return TERMINAL_TYPE_ANDROID  if $self->client_name eq 'Android';
  }
  
  EOC;
---
file: lib/____var-dist-var____/Explorer.pm
template: |
  package <+ dist +>::Explorer;
  use Ze::Class;
  extends 'Ze::WAF';
  use POSIX::AtFork;
  use <+ dist +>X::Config;
  
  if( <+ dist +>X::Config->instance->get('debug') ) {
      with 'Ze::WAF::Profiler';
  };
  
  sub BUILD {
      # For true random. once execute srand() per fork child.
      POSIX::AtFork->add_to_child(sub { srand() });
  }
      
  EOC;
---
file: lib/____var-dist-var____/FileGenerator.pm
template: |
  package <+ dist +>::FileGenerator;
  use strict;
  use warnings;
  use parent 'Ze::FileGenerator';
  
  sub _module_pluggable_options {
      return (
          except => ['<+ dist +>::FileGenerator::Base'],
      );
  };
  
  
  1;
---
file: lib/____var-dist-var____/OP.pm
template: |
  package <+ dist +>::OP;
  use Ze::Class;
  extends 'Ze::WAF';
  use <+ dist +>X::Config;
  use POSIX::AtFork;
  
  sub BUILD {
    # For true random. once execute srand() per fork child.
    POSIX::AtFork->add_to_child(sub { srand() });
  }
  
  
  EOC;
---
file: lib/____var-dist-var____/Pager.pm
template: |
  package <+ dist +>::Pager;
  
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
file: lib/____var-dist-var____/Validator.pm
template: |
  package <+ dist +>::Validator;
  use warnings;
  use strict;
  use utf8;
  use FormValidator::LazyWay;
  use YAML::Syck();
  use Data::Section::Simple;
  use <+ dist +>::Validator::Result;
  
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
      FormValidator::LazyWay->new( config => $config ,result_class => '<+ dist +>::Validator::Result' );
  }
  
  1;
  
  __DATA__
  
  
  @@ validate.yaml
  ---
  lang: ja
  filters:
    - <+ dist +>=+<+ dist +>::Validator::Filter
  rules:
    - Number
    - String
    - Net
    - Email
    - DateTime
    - <+ dist +>=+<+ dist +>::Validator::Rule
  setting:
    regex_map :
      '_id$':
        rule:
          - Number#uint
      '^on_':
        rule:
          - <+ dist +>#range:
                max : 1
                min : 0
    strict:
      timezone:
        rule:
          - <+ dist +>#timezone
      language: 
        rule:
          - <+ dist +>#language
      member_name: 
        filter:
          - <+ dist +>#trim_space
        rule:
          - String#length:
              max : 55
              min : 1
      terminal_type: 
        rule:
          - <+ dist +>#terminal_type
      terminal_info:
        rule:
          - String#length:
              max : 255
              min : 1
      access_token:
        rule:
          - String#length:
              max : 255
              min : 1
      op_name: 
        rule:
          - String#length:
              max : 100
              min : 1
      password:
        rule:
          - String#length:
              max : 55
              min : 4
      confirm_password:
        rule:
          - String#length:
              max : 55
              min : 4
      email:
        rule:
          - Email#email_loose
      p:
        rule:
          - Number#uint
      op_access_key:
        rule:
          - <+ dist +>#op_access_key
      op_timezone:
        rule:
          - <+ dist +>#op_timezone
      op_language:
        rule:
          - <+ dist +>#op_language
      operation_memo:
        rule:
          - String#length:
              max : 1000
              min : 1
      sort:
        rule:
          - <+ dist +>#order_by
      direction:
        rule:
          - <+ dist +>#order_direction
      operation_type:
        rule:
          - <+ dist +>#operation_type
---
file: lib/____var-dist-var____/API/Context.pm
template: |
  package <+ dist +>::API::Context;
  use Ze::Class;
  extends '<+ dist +>::WAF::Context';
  use <+ dist +>X::Util;
  use <+ dist +>X::Constants;
  use <+ dist +>X::Config;
  use <+ dist +>::ClientDetector;
  
  has 'member_obj' => ( is => 'rw' );
  has 'requested_at' => ( is => 'rw');
  has 'language' => ( is=>'rw', default => sub { <+ dist +>X::Util::default_language() } );
  
  __PACKAGE__->load_plugins(qw(
      Ze::WAF::Plugin::AntiCSRF
      Ze::WAF::Plugin::Encode
      Ze::WAF::Plugin::FillInForm
      Ze::WAF::Plugin::JSON
      ));
  
  sub frontend {
    my $c = shift;
    return $c->args->{frontend};
  }
  
  sub set_json_stash {
      my( $c , $args ) = @_;
      $args->{error} ||= 0;
      my $vars = {
        error => delete $args->{error},
        data => $args
      };
      $c->view_type('JSON');
      $c->stash->{VIEW_TEMPLATE_VARS} = $vars;
      $c->_set_json_callback_if();
  }
  
  sub set_json_error {
      my( $c , $v_res , $addition ) = @_;
      $c->view_type('JSON');
      my $args = { error => 1};
      if($addition){
          $args = $addition;
          $args->{error} = 1;
      }
      if($v_res && ref $v_res){
          $args->{error_keys} = $v_res->error_keys;
      }
      elsif($v_res) {
          $args->{error_keys} = [ $v_res ];
      }
  
      my $error_code = 'error';
      for(@{$args->{error_keys}}){
          if( $_ =~ '^model\.custom_invalid\.'){
              $error_code = $_ ;
              $error_code =~ s/^model\.custom_invalid\.//;
          }
      }
  
      $args->{error_code} = $error_code;
      delete $args->{error_keys} unless <+ dist +>X::Config->instance->get('debug') ;
  
      $c->stash->{VIEW_TEMPLATE_VARS} = $args;
      $c->_set_json_callback_if();
  }
  
  
  sub client_version_fail {
    my $c = shift;
    $c->view_type('JSON');
    $c->res->status( 200 );
    $c->res->body('{"error":'. <+ dist +>X::Constants::API_ERROR_CLIENT_VERSION . ',"version_status":'. <+ dist +>X::Constants::VERSION_STATUS_REQUIRE_TO_UPDATE . '}');
    $c->res->content_type( 'text/html;charset=utf-8' );
    $c->finished(1);
  }
  
  sub client_master_fail {
    my $c = shift;
    $c->view_type('JSON');
    $c->res->status( 200 );
    $c->res->body('{"error":'. <+ dist +>X::Constants::API_ERROR_CLIENT_MASTER .'}');
    $c->res->content_type( 'text/html;charset=utf-8' );
    $c->finished(1);
  }
  
  sub authorized_fail {
      my $c = shift;
      $c->view_type('JSON');
      $c->res->status( 401 );
      $c->res->body('{"error":'. <+ dist +>X::Constants::API_ERROR .',"code":401}');
      $c->res->content_type( 'text/html;charset=utf-8' );
      $c->finished(1);
  }
  
  sub forbidden_fail {
      my $c = shift;
      $c->view_type('JSON');
      $c->res->status( 403 );
      $c->res->body('{"error":'. <+ dist +>X::Constants::API_ERROR .',"code":403}');
      $c->res->content_type( 'text/html;charset=utf-8' );
      $c->finished(1);
  }
  
  sub not_found {
      my $c = shift;
      $c->view_type('JSON');
      $c->res->status( 404 );
      $c->res->body('{"error":'. <+ dist +>X::Constants::API_ERROR .'}');
      $c->res->content_type( 'text/html;charset=utf-8' );
      $c->finished(1);
  }
  
  
  
  EOC;
---
file: lib/____var-dist-var____/API/Dispatcher.pm
template: |
  package <+ dist +>::API::Dispatcher;
  use Ze::Class;
  extends 'Ze::WAF::Dispatcher::Router';
  use <+ dist +>X::Home;
  
  sub _build_config_file {
      my $self = shift;
      $self->home->file('router/api.pl');
  }
  
  sub _build_home {
      my $self = shift;
      return <+ dist +>X::Home->get;
  }
  
  EOC;
---
file: lib/____var-dist-var____/API/View.pm
template: |
  package <+ dist +>::API::View;
  use Ze::Class;
  extends "Ze::WAF::View";
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
file: lib/____var-dist-var____/API/Controller/AuthTerminal.pm
template: |
  package <+ dist +>::API::Controller::AuthTerminal;
  use Ze::Class;
  use <+ dist +>X::Util;
  extends '<+ dist +>::API::Controller::Base';
  
  sub register {
      my ($self,$c) = @_;
      my $args = $c->req->as_fdat;
      $args->{language} = <+ dist +>X::Util::available_language($args->{language});
      my $obj = $c->model('AuthTerminal')->register($args);
      my $member_obj = $obj->member_obj;
  
      $c->set_json_stash(
          { item => {
                  member_id        => $obj->member_id,
                  language         => $member_obj->language,
                  terminal_code    => $obj->terminal_code,
              }
          }
      );
  }
  
  sub login {
      my ($self,$c) = @_;
      my $access_token = $c->model('AuthTerminal')->login($c->req->param('terminal_code'));
      $c->set_json_stash({ item => { access_token => $access_token }});
  }
  
  EOC;
---
file: lib/____var-dist-var____/API/Controller/Base.pm
template: |
  package <+ dist +>::API::Controller::Base;
  use strict;
  use Ze::Class;
  extends '<+ dist +>::WAF::Controller';
  with 'Ze::WAF::Controller::Role::JSON';
  use <+ dist +>::Authorizer::TerminalMember;
  use <+ dist +>::ClientDetector;
  use <+ dist +>X::Config;
  use <+ dist +>X::DateTime;
  use <+ dist +>::OP::ACL;
  
  __PACKAGE__->add_trigger(
      BEFORE_EXECUTE => sub {
          my ($self,$c,$action) = @_;
  
          my $now = <+ dist +>X::DateTime->now();
          $c->requested_at($now);
  
          if( $c->req->method ne 'POST'){
              $c->authorized_fail();
              $c->abort();
          }
  
          return if $c->req->path =~ /^\/(app|web)\/auth_terminal\//;
          return if $c->req->path =~ /^\/(app|web)\/master\//;
  
          if ($c->frontend eq 'app') {
              if(my $application_version = $c->req->headers->header('x-application-version')){
                  my $client_detector = <+ dist +>::ClientDetector->new({application_version => $application_version});
                  $c->client_detector($client_detector);
                  if($client_detector->is_required_to_update){
                      $c->client_version_fail();
                      $c->abort();
                  }
              }
  
              if(my $master_version = $c->req->headers->header('x-master-version')){
                  my $sheet = Cream::Structure->get_basic_info_sheet();
                  if( $sheet->{master_version} > $master_version ){
                      $c->client_master_fail();
                      $c->abort();
                  }
  
              }
  
              my $authorizer = <+ dist +>::Authorizer::TerminalMember->new(c=>$c);
  
              if( my $member_obj = $authorizer->authorize() ) {
                  $c->member_obj($member_obj);
                  $c->language( $c->member_obj->language );
              }
              else {
                  $c->authorized_fail();
                  $c->abort();
              }
          }
          elsif( $c->frontend eq 'web' ){
  
              my $authorizer = <+ dist +>::Authorizer::TerminalMember->new(c=>$c);
  
              if( my $member_obj = $authorizer->authorize_from_cookie() ) {
                  $c->member_obj($member_obj);
                  $c->language( $c->member_obj->language );
              }
              else {
                  $c->authorized_fail();
                  $c->abort();
              }
          }
      });
  
  EOC;
---
file: lib/____var-dist-var____/API/Controller/Member.pm
template: |
  package <+ dist +>::API::Controller::Member;
  use Ze::Class;
  extends '<+ dist +>::API::Controller::Base';
  
  sub me {
    my ($self,$c) = @_;
    $c->set_json_stash({ item => { member_id => $c->member_obj->id } });
  }
  
  EOC;
---
file: lib/____var-dist-var____/API/Controller/Root.pm
template: |
  package <+ dist +>::API::Controller::Root;
  use Ze::Class;
  extends '<+ dist +>::WAF::Controller';
  with 'Ze::WAF::Controller::Role::JSON';
  
  sub info {
    my ($self,$c)  = @_;
    my $sheet = shift;
    $c->set_json_stash({});
  }
  
  
  
  1;
---
file: lib/____var-dist-var____/Authorizer/Base.pm
template: |
  package <+ dist +>::Authorizer::Base;
  use Ze::Class;
  
  has c => ( is => 'rw', required => 1 );
  
  sub authorize  { die 'ABSTRACT METHOD' } 
  sub logout_url { die 'ABSTRACT METHOD' }
  
  
  EOC;
---
file: lib/____var-dist-var____/Authorizer/Operator.pm
template: |
  package <+ dist +>::Authorizer::Operator;
  use Ze::Class;
  extends '<+ dist +>::Authorizer::Base';
  use <+ dist +>::Session::OP;
  use <+ dist +>::Model::Operator;
  
  sub logout {
      my $self = shift;
  
  }
  
  sub authorize {
      my $self = shift;
      my $session = <+ dist +>::Session::OP->create($self->c->req,$self->c->res);
  
      if( my $operator_id = $session->get('operator_id') ){
          my $obj = <+ dist +>::Model::Operator->new->lookup($operator_id) or return;
          return unless $obj->on_active;
          return $obj;
      }
      return;
  }
  
  EOC;
---
file: lib/____var-dist-var____/Authorizer/TerminalMember.pm
template: |
  package <+ dist +>::Authorizer::TerminalMember;
  use Ze::Class;
  extends '<+ dist +>::Authorizer::Base';
  use <+ dist +>::Model::AuthAccessToken;
  use <+ dist +>X::Config;
  use Try::Tiny;
  
  sub authorize_from_cookie {
      my $self = shift;
      my $member_obj ;
      try {
          my $access_token = $self->c->req->cookies->{'access_token'};
          $member_obj = <+ dist +>::Model::AuthAccessToken->new->auth({ access_token => $access_token });
      } catch {
  
      };
      return $member_obj;
  
  }
  sub authorize {
      my $self = shift;
      my $member_obj ;
      try {
          my $access_token = $self->c->req->headers->header('x-access-token');
          if( !$access_token && <+ dist +>X::Config->instance->get('debug') ){
              $access_token = $self->c->req->param('access_token') || '';
          }
          $member_obj = <+ dist +>::Model::AuthAccessToken->new->auth({ access_token => $access_token });
          $member_obj = undef unless $member_obj->on_active;
      } catch {
  
      };
      return $member_obj;
  }
  
  EOC;
---
file: lib/____var-dist-var____/Cache/Session.pm
template: |
  package <+ dist +>::Cache::Session;
  use strict;
  use warnings;
  use base qw(Cache::Memcached::IronPlate Class::Singleton);
  use <+ dist +>X::Config();
  use Cache::Memcached::Fast();
  
  sub _new_instance {
      my $class = shift;
  
      my $config = <+ dist +>X::Config->instance->get('cache_session');
  
      my $cache = Cache::Memcached::Fast->new({
              utf8 => 1,
              servers => $config->{servers},
              compress_threshold => 5000,
              ketama_points => 150, 
              namespace => '<+ dist | lower +>_s', 
          });
      my $self = $class->SUPER::new( cache => $cache );
      return $self;
  }
  
  1;
---
file: lib/____var-dist-var____/Cache/Session/OP.pm
template: |
  package <+ dist +>::Cache::Session::OP;
  use strict;
  use warnings;
  use base qw(Cache::Memcached::IronPlate Class::Singleton);
  use <+ dist +>X::Config();
  use Cache::Memcached::Fast();
  
  sub _new_instance {
      my $class = shift;
  
      my $config = <+ dist +>X::Config->instance->get('cache_session_op');
  
      my $cache = Cache::Memcached::Fast->new({
              utf8 => 1,
              servers => $config->{servers},
              compress_threshold => 5000,
              ketama_points => 150, 
              namespace => '<+ dist | lower +>_s_op', 
          });
      my $self = $class->SUPER::new( cache => $cache );
      return $self;
  }
  
  1;
---
file: lib/____var-dist-var____/CLI/add_admin_operator.pm
template: |
  package <+ dist +>::CLI::add_admin_operator;
  use strict;
  use Ze::Class;
  extends '<+ dist +>::CLI::Base';
  use <+ dist +>::Model::Operator;
  
  sub run {
      my ($self, $opt, $args) = @_;
      print "your email: ";
      my $email= <STDIN>;
      chomp($email);
  
      print "your name:";
      my $op_name = <STDIN>;
      chomp($op_name);
  
      print "password: ";
      system("stty -echo");
      my $password = <STDIN>;
      chomp($password);
      system("stty echo");
  
      print "\nconfirm password: ";
      system("stty -echo");
      my $re_password = <STDIN>;
      chomp($re_password);
      system("stty echo");
      unless ($password eq $re_password) {
          die "\npassword is invalid.";
      }
      print "\n";
  
      <+ dist +>::Model::Operator->new->create_admin_operator({
          email => $email,
          password => $password,
          op_name => $op_name,
      });
      print "registered.\n";
  }
  
  
  
  EOC;
---
file: lib/____var-dist-var____/CLI/Base.pm
template: |
  package <+ dist +>::CLI::Base;
  use Ze::Class;
  use <+ dist +>::CLI -command;
  with '<+ dist +>::Role::Config';
  use Try::Tiny;
  use Data::Dumper;
  
  
  sub execute {
      my ($self, $opt, $args) = @_;
  
      try {
          $self->run($opt,$args);
      } 
      catch {
          warn Dumper $_;
      };
  }
  
  EOC;
---
file: lib/____var-dist-var____/CLI/sample.pm
template: |
  package <+ dist +>::CLI::sample;
  use Ze::Class;
  extends '<+ dist +>::CLI::Base';
  
  sub execute {
      my ($self, $opt, $args) = @_;
      if( scalar @$args ) {
          print $args->[0] . "\n";
      }
      else {
          print "Hi!\n";
      }
  }
  
  
  EOC;
---
file: lib/____var-dist-var____/Data/AuthAccessToken.pm
template: |
  package <+ dist +>::Data::AuthAccessToken;
  use strict;
  use warnings;
  use base qw(<+ dist +>::Data::Base);
  use <+ dist +>::ObjectDriver::DBI;
  use <+ dist +>X::Util;
  use <+ dist +>::Data::Member;
  
  __PACKAGE__->install_properties({
          columns => [qw(member_id access_token updated_at created_at)],
          datasource => 'auth_access_token',
          primary_key => 'access_token',
          driver => <+ dist +>::ObjectDriver::DBI->driver,
      });
  
  __PACKAGE__->has_a({ 
          class => '<+ dist +>::Data::Member', 
          column => 'member_id' ,
      });
  
  sub default_values {
      return +{
          access_token => <+ dist +>X::Util::generate_access_token(),
      };
  }
  
  1;
---
file: lib/____var-dist-var____/Data/AuthTerminal.pm
template: |
  package <+ dist +>::Data::AuthTerminal;
  use strict;
  use warnings;
  use base qw(<+ dist +>::Data::Base);
  use <+ dist +>::ObjectDriver::DBI;
  use <+ dist +>X::Util;
  use <+ dist +>::Data::AuthAccessToken;
  use <+ dist +>::Data::Member;
  
  __PACKAGE__->install_properties({
          columns => [qw(member_id terminal_code terminal_type terminal_info updated_at created_at)],
          datasource => 'auth_terminal',
          primary_key => ['terminal_code'],
          driver => <+ dist +>::ObjectDriver::DBI->driver,
      });
  
  __PACKAGE__->has_a({ 
          class => '<+ dist +>::Data::Member', 
          column => 'member_id' ,
      });
  
  sub default_values {
      return +{
          terminal_code => <+ dist +>X::Util::generate_terminal_code(),
      };
  }
  
  
  sub reset_access_token {
      my $self = shift;
      my $access_token = <+ dist +>X::Util::generate_access_token();
      if( my $auth_access_token_obj = <+ dist +>::Data::AuthAccessToken->single({member_id => $self->member_id}) ){
          $auth_access_token_obj->access_token( $access_token);
          $auth_access_token_obj->save();
      }
      else {
          my $obj = <+ dist +>::Data::AuthAccessToken->new();
          $obj->member_id( $self->member_id );
          $obj->access_token( $access_token );
          $obj->save();
      }
      return $access_token;
  }
  
  1;
---
file: lib/____var-dist-var____/Data/Base.pm
template: |
  package <+ dist +>::Data::Base;
  use strict;
  use warnings;
  use base qw(Data::ObjectDriver::BaseObject Class::Data::Inheritable);
  use Data::ObjectDriver::SQL;
  use Sub::Install;
  use UNIVERSAL::require;
  use <+ dist +>X::DateTime;
  use <+ dist +>::Pager;
  use <+ dist +>::ObjectDriver::DBI;
  
  __PACKAGE__->add_trigger( pre_insert => sub {
          my ( $obj, $orig ) = @_;
  
          my $now = <+ dist +>X::DateTime->sql_now ;
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
              my $now = <+ dist +>X::DateTime->sql_now ;
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
          $plugin = '<+ dist +>::Data::Plugin::' . $plugin;
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
  
  sub lookup_master {
      my $class = shift;
      my $values = shift;
  
      my $primary_key  = $class->properties('primary_key')->{primary_key};
      my $terms = {};
      if(ref $primary_key eq 'ARRAY'){
          for(my $i = 0 ; $i < scalar @$primary_key;$i++){
              $terms->{ $primary_key->[$i] } = $values->[$i];
          }
      }
      else {
          $terms->{ $primary_key } = $values ;
      }
      my $stmt = Data::ObjectDriver::SQL->new;
      $stmt->add_select("*");
      $stmt->from( [ $class->driver->table_for($class) ] );
      for my $col ( keys %$terms ) {
          $stmt->add_where( $col => $terms->{$col} );
      }
      my $dbh = $class->driver->rw_handle;
      my $sth = $dbh->prepare($stmt->as_sql) or die $dbh->errstr;
      $sth->execute( @{$stmt->{bind}});
      my $row = $sth->fetchrow_hashref() or return ;
      $sth->finish;
      my $obj = $class->new(%$row);
      $obj->{changed_cols} = {};
      return $obj;
  
  }
  sub renew_for_update {
      my $self = shift;
      my $primary_key  = $self->properties('primary_key')->{primary_key};
      my $terms = {};
      if(ref $primary_key eq 'ARRAY'){
          for(@$primary_key){
              $terms->{ $_ } = $self->$_();
          }
      }
      else {
          $terms->{ $primary_key } = $self->$primary_key() ;
      }
      my $stmt = Data::ObjectDriver::SQL->new;
      $stmt->add_select("*");
      $stmt->from( [ $self->driver->table_for($self) ] );
      for my $col ( keys %$terms ) {
          $stmt->add_where( $col => $terms->{$col} );
      }
      my $dbh = $self->driver->rw_handle;
      my $sth = $dbh->prepare($stmt->as_sql . " FOR UPDATE") or die $dbh->errstr;
      $sth->execute( @{$stmt->{bind}});
      my $row = $sth->fetchrow_hashref() or die "CRITICAL NOT FOUND RECORD FROM MASTER";
      $sth->finish;
      my $class = ref $self;
      my $obj = $class->new(%$row);
      $obj->{changed_cols} = {};
      return $obj;
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
              $data->{$key} = '' unless defined $data->{$key};
              my $value = $obj->$key();
              $value = '' unless defined $obj->$key();
  
              next if( $obj->$key() eq $data->{$key});
              $is_modified = 1 ;
              $obj->$key($data->{$key});
          }
  
          unless ($is_modified){
              return $obj ;
          }
  
      }else {
          $obj = $class->new(%$data) ;
      }
  
      $obj->save;
      return $obj;
  }
  
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
  
      my $dt = <+ dist +>X::DateTime->parse_mysql_datetime($val) or return;
      return $dt;
  }
  
  sub to_localized_datetime {
      my ($self,$column,$timezone) = @_;
      my $dt = $self->to_datetime($column);
      $dt->set_time_zone('UTC');
      return $dt->set_time_zone($timezone);
  }
  
  sub search_with_pager {
      my $self = shift;
      my $args = shift || {};
      my $opts = shift || {};
      my $p = delete $args->{p} || 1;
      my $limit = $opts->{limit} || 50;
  
      my $pager = <+ dist +>::Pager->new();
      $pager->entries_per_page( $limit );
      $pager->current_page($p);
      $opts->{pager} = $pager;
      my @objs = $self->search($args,$opts);
  
      return ($pager,\@objs);
  }
  
  
  
  
  1;
---
file: lib/____var-dist-var____/Data/Member.pm
template: |
  package <+ dist +>::Data::Member;
  use strict;
  use warnings;
  use base qw(<+ dist +>::Data::Base);
  
  __PACKAGE__->install_properties({
          columns => [qw( member_id member_name language timezone last_active_at on_active updated_at created_at)],
          datasource => 'member',
          primary_key => 'member_id',
          driver => <+ dist +>::ObjectDriver::DBI->driver,
      });
  
  __PACKAGE__->setup_alias({
      id => 'member_id',
      name => 'member_name',
  });
  
  sub default_values {
      my $now = <+ dist +>X::DateTime->now();
      return +{
        last_active_at => $now->strftime( '%Y-%m-%d %H:%M:%S' ),
        on_active => 1,
      };
  }
  
  sub update_last_active_at {
    my $self = shift;
    my $args = shift || { on_save => 0 };
    $self->last_active_at( <+ dist +>X::DateTime->sql_now );
    $self->save() if $args->{on_save};
  }
  1;
---
file: lib/____var-dist-var____/Data/OperationLog.pm
template: |
  package <+ dist +>::Data::OperationLog;
  use strict;
  use warnings;
  use base qw(<+ dist +>::Data::Base);
  use <+ dist +>::Data::Operator;
  
  __PACKAGE__->install_properties({
      columns => [qw( operation_log_id operator_id operation_type criteria_code attributes_dump operation_memo updated_at created_at)],
      datasource => 'operation_log',
      primary_key => 'operation_log_id',
      driver => <+ dist +>::ObjectDriver::DBI->driver,
  });
  
  __PACKAGE__->install_plugins ([qw/AttributesDump/]);
  
  __PACKAGE__->setup_alias({
      id => 'operation_log_id',
  });
  
  __PACKAGE__->has_a({
    class => '<+ dist +>::Data::Operator', 
    column => 'operator_id',
  });
  
  sub default_values {
      return +{
        attributes_dump => '{}',
        criteria_code => '',
        operation_memo => '',
      };
  }
  
  1;
---
file: lib/____var-dist-var____/Data/Operator.pm
template: |
  package <+ dist +>::Data::Operator;
  use strict;
  use warnings;
  use base qw(<+ dist +>::Data::Base);
  use <+ dist +>::ObjectDriver::DBI;
  use <+ dist +>::OP::ACL;
  use <+ dist +>X::Util;
  
  __PACKAGE__->install_properties(
      {
          columns => [
              qw(operator_id op_name email password op_timezone op_language acl_token on_active updated_at created_at)
          ],
          datasource  => 'operator',
          primary_key => 'operator_id',
          driver      => <+ dist +>::ObjectDriver::DBI->driver,
      }
  );
  
  __PACKAGE__->setup_alias({ id => 'operator_id'  });
  
  sub default_values {
     my $acl = <+ dist +>::OP::ACL->new();
    +{
      op_timezone => <+ dist +>X::Util::default_op_timezone(),
      op_language => <+ dist +>X::Util::default_op_language(),
      acl_token => $acl->get_token_for_operator(),
      on_active => 1,
    };
  }
  
  sub access_keys {
    my $self = shift;
    my $keys = $self->acl_obj->retrieve_access_keys_for($self->acl_token);
    @$keys = sort @$keys;
    return $keys;
  }
  
  sub acl_obj {
    my $self = shift;
    my $acl = <+ dist +>::OP::ACL->new();
    return $acl->set_token( $self->acl_token );
  }
  sub has_privilege {
    my $self = shift;
    my $access_key = shift;
    $self->acl_obj->has_privilege( $access_key );
  }
  
  1;
---
file: lib/____var-dist-var____/Data/Plugin/AttributesDump.pm
template: |
  package <+ dist +>::Data::Plugin::AttributesDump;
  
  use strict;
  use warnings;
  use base qw(<+ dist +>::Data::Plugin::Base);
  use <+ dist +>X::Util ;
  
  __PACKAGE__->methods([qw/attributes set_attributes/]);
  
  sub attributes {
      my $self = shift;
      return length $self->attributes_dump ? <+ dist +>X::Util::from_json($self->attributes_dump) : {};
  }
  
  sub set_attributes {
      my $self = shift;
      my $data = shift;
      $self->attributes_dump( <+ dist +>X::Util::to_json( $data ) );
  }
  
  1;
---
file: lib/____var-dist-var____/Data/Plugin/Base.pm
template: |+
  package <+ dist +>::Data::Plugin::Base;
  use strict;
  use warnings;
  use base qw(Class::Data::Inheritable);
  __PACKAGE__->mk_classdata('methods');
  __PACKAGE__->methods([]);
  
  1;

---
file: lib/____var-dist-var____/Explorer/Context.pm
template: |
  package <+ dist +>::Explorer::Context;
  use Ze::Class;
  extends '<+ dist +>::WAF::Context';
  with '<+ dist +>::Role::Config';
  
  __PACKAGE__->load_plugins(qw(
      Ze::WAF::Plugin::Encode
      Ze::WAF::Plugin::FillInForm
      Ze::WAF::Plugin::JSON
      ));
  
  
  EOC;
---
file: lib/____var-dist-var____/Explorer/Dispatcher.pm
template: |
  package <+ dist +>::Explorer::Dispatcher;
  use Ze::Class;
  extends 'Ze::WAF::Dispatcher::Router';
  use <+ dist +>X::Home;
  
  sub _build_config_file {
      my $self = shift;
      $self->home->file('router/explorer.pl');
  }
  
  sub _build_home {
      my $self = shift;
      return <+ dist +>X::Home->get;
  }
  
  EOC;
---
file: lib/____var-dist-var____/Explorer/View.pm
template: |
  package <+ dist +>::Explorer::View;
  use Ze::Class;
  extends "Ze::WAF::View";
  use Ze::View;
  
  
  sub _build_engine {
      my $self = shift;
      my $path = [
          <+ dist +>X::Home->get()->subdir('view-explorer'),
          <+ dist +>X::Home->get()->subdir('view-include/explorer')
      ];
      return Ze::View->new(
          engines => [
              { 
                engine => 'Ze::View::Xslate', 
                config  => {
                  path => $path
                } 
              }, 
              { 
                engine => 'Ze::View::JSON', 
              }
          ]
      );
  }
  
  
  EOC;
---
file: lib/____var-dist-var____/Explorer/Controller/Root.pm
template: |
  package <+ dist +>::Explorer::Controller::Root;
  use Ze::Class;
  extends '<+ dist +>::WAF::Controller';
  
  use <+ dist +>X::Config;
  use <+ dist +>X::Util;
  use <+ dist +>X::Home;
  use <+ dist +>::Data::AuthAccessToken;
  use Furl;
  use <+ dist +>X::Doc::API;
  
  sub index {
    my ($self,$c)  = @_;
    my $doc = <+ dist +>X::Doc::API->new();
    $c->stash->{doc} = $doc->get_list;
  }
  
  sub proxy {
    my ($self,$c) = @_; 
  
    my $furl = Furl->new();
    my $config = <+ dist +>X::Config->instance();
    my $url = $config->get('url')->{api} .   $c->req->param('path');
  
  
    my $data = <+ dist +>X::Util::from_json($c->req->param('args') || '{}');
  
    my $res = $furl->post(
       $url,  
       [ 
           'X-ACCESS-TOKEN' => $c->req->param('access_token'),
           'X-INTERNAL-ACCESS-TOKEN' => $c->req->param('internal_token'),
  
       ],
       $data,
    );
    $c->res->body($res->body);
  }
  
  sub doc {
    my ($self,$c) = @_; 
    $c->view_type('JSON');
    my $doc = <+ dist +>X::Doc::API->new();
    my $item = $doc->get($c->req->as_fdat->{path} || '') || {};
    $c->set_json_stash({item => $item });
  }
  
  1;
---
file: lib/____var-dist-var____/FileGenerator/Base.pm
template: |
  package <+ dist +>::FileGenerator::Base;
  use warnings;
  use strict;
  use <+ dist +>::FileGenerator -command;
  use parent 'Ze::FileGenerator::Base';
  use Ze::View;
  use <+ dist +>X::Home;
  
  my $home = <+ dist +>X::Home->get();
  
  __PACKAGE__->in_path( $home->subdir("view-component") );
  __PACKAGE__->out_path( $home->subdir("view-include/component") );
  
  
  sub create_view {
  
      my $path = [ $home->subdir('view-component') , $home->subdir('view-include') ];
  
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
template: |
  package <+ dist +>::FileGenerator::sample;
  use strict;
  use warnings;
  use base qw/<+ dist +>::FileGenerator::Base/;
  
  sub run {
      my ($self, $opts) = @_;
      $self->echo();
  }
  
  sub echo {
      my $self = shift;
      my $args = shift;
  
      $self->generate(['sp','pc'],{
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
file: lib/____var-dist-var____/Model/AuthAccessToken.pm
template: |
  package <+ dist +>::Model::AuthAccessToken;
  use Ze::Class;
  extends '<+ dist +>::Model::Base';
  with '<+ dist +>::Model::Role::DataObject';
  
  sub profiles {
      return +{
          auth => {
              required => [qw/access_token/],
          }
      }
  }
  
  sub auth {
      my $self = shift;
      my $args = shift;
      my $v = $self->assert_with($args);
      my $obj 
      = $self->data_class->lookup($v->{access_token})
          or $self->abort_with('access_fail')
      ;
    return $obj->member_obj();
    }
  
  
  EOC;
---
file: lib/____var-dist-var____/Model/AuthTerminal.pm
template: |
  package <+ dist +>::Model::AuthTerminal;
  use Ze::Class;
  use strict;
  use warnings;
  use <+ dist +>::Model::Member;
  extends '<+ dist +>::Model::Base';
  with '<+ dist +>::Model::Role::DataObject';
  use Try::Tiny;
  
  sub profiles {
      return +{
          register => { required => [qw/member_name language timezone terminal_type terminal_info/], },
          create   => { required => [qw/member_id terminal_type terminal_info/], }
      };
  }
  
  
  sub register {
      my $self = shift;
      my $args = shift;
      my $v    = $self->assert_with($args);
  
      my $tm = $self->get_tm();
      my $obj;
      try {
          my $model      = <+ dist +>::Model::Member->new;
          my $txn        = $tm->txn_scope;
          my $member_obj = $model->create($v);
          $obj = $self->create( { member_id => $member_obj->id, terminal_type => $v->{terminal_type}, terminal_info => $v->{terminal_info} } );
          $member_obj->update();
          $txn->commit;
      }
      catch {
          if ( ref $_ eq '<+ dist +>::Validator::Error' ) {
              die $_;
          }
          else {
              die $_;
          }
      };
  
      return $obj;
  }
  
  sub login {
      my $self          = shift;
      my $terminal_code = shift or $self->abort_with('login_fail');
      my $obj           = $self->data_class->lookup($terminal_code) or $self->abort_with('login_fail');
      $obj->member_obj->update_last_active_at( { on_save => 1 } );
      my $access_token = $obj->reset_access_token();
      return $access_token;
  }
  
  EOC;
---
file: lib/____var-dist-var____/Model/Base.pm
template: |
  package <+ dist +>::Model::Base;
  use Ze::Class;
  extends 'Aplon';
  use <+ dist +>::Validator;
  use <+ dist +>::Pager;
  use Try::Tiny;
  
  with 'Aplon::Validator::FormValidator::LazyWay';
  has '+error_class' => ( default => '<+ dist +>::Validator::Error' );
  
  has 'pager' => (  is => 'rw' );
  
  
  
  sub FL_instance {
      <+ dist +>::Validator->instance();
  }
  
  sub create_pager {
      my $self = shift;
      my $p    = shift;
      my $entries_per_page = shift || 10;
      my $pager = <+ dist +>::Pager->new();
      $pager->entries_per_page( $entries_per_page );
      $pager->current_page($p);
  }
  
  
  EOC;
---
file: lib/____var-dist-var____/Model/Member.pm
template: |
  package <+ dist +>::Model::Member;
  use Ze::Class;
  use strict;
  use warnings;
  extends '<+ dist +>::Model::Base';
  with '<+ dist +>::Model::Role::DataObject';
  use Try::Tiny;
  
  sub profiles {
        return +{
          create => { required => [qw/member_name language timezone/], },
        }
    }
  
  EOC;
---
file: lib/____var-dist-var____/Model/OperationLog.pm
template: |
  package <+ dist +>::Model::OperationLog;
  use Ze::Class;
  extends '<+ dist +>::Model::Base';
  with '<+ dist +>::Model::Role::DataObject';
  
  sub profiles {
    return +{
      search_for_op => {
        optional => [qw/p operation_log_id operator_id operation_type direction sort/],
        defaults => { 
          p => 1,
          sort      => 'operation_log_id',
          direction => 'descend',
        }
      },
    };
  }
  
  sub search_for_operation {
    my $self = shift;
    my $operation_type = shift;
    my $criteria_code = shift;
  
    my $cond = {
      operation_type => $operation_type
    };
    if($criteria_code){
      $cond->{criteria_code} = $criteria_code;
    }
    my ($pager,$objs) = $self->data_class->search_with_pager($cond,{ sort =>'operation_log_id',direction => 'descend'});
    return ($pager,$objs);
  }
  
  EOC;
---
file: lib/____var-dist-var____/Model/Operator.pm
template: |
  package <+ dist +>::Model::Operator;
  use Ze::Class;
  use <+ dist +>X::Util;
  use <+ dist +>::OP::ACL;
  use <+ dist +>X::Constants qw(:operation_type);
  use <+ dist +>::Data::OperationLog;
  extends '<+ dist +>::Model::Base';
  with '<+ dist +>::Model::Role::DataObject';
  
  sub profiles {
    return +{
      search_for_op => {
        optional => [qw/p operator_id on_active direction sort/],
        defaults => { 
          p => 1,
          sort      => 'operator_id',
          direction => 'descend',
        }
      },
      login => {
        required => [qw/email password/],
      },
      create_from_op => {
        required => [qw/email op_name password op_timezone op_language operation_memo/],
        optional => [qw/op_access_key/],
        want_array => [qw/op_access_key/]
      },
      update_from_op => {
        required => [qw/on_active operation_memo/],
        optional => [qw/op_access_key/],
        want_array => [qw/op_access_key/]
      },
      update_password => {
        required => [qw/password confirm_password/],
      },
      update_from_op_for_operator => {
        required => [qw/op_name op_timezone op_language/],
      },
      create_admin_operator => {
        required => [qw/email op_name password/],
      },
    }
  }
  
  
  sub login {
    my $self = shift;
    my $args = shift;
    my $v = $self->assert_with($args);
    my $obj 
      = $self->data_class->single({ email => $v->{email}, password => <+ dist +>X::Util::hashed_password( $v->{password} ), on_active => 1 }) 
        or $self->abort_with('login_error');
  
    return $obj;
  }
  
  
  sub create_admin_operator {
      my ($self, $args) = @_;
      my $v = $self->assert_with($args);
  
      $self->data_class->single({ email => $v->{email} }) and $self->abort_with("already_registered");
  
      my $acl = <+ dist +>::OP::ACL->new();
      my $obj = $self->data_class->new(
          email => $v->{email},
          op_name => $v->{op_name},
          password => <+ dist +>X::Util::hashed_password( $v->{password} ),
          acl_token => $acl->get_token_for_admin(),
      );
      $obj->save;
      return $obj;
  }
  
  sub create_from_op {
      my ($self, $args,$operator_obj) = @_;
      $self->abort_with("you_must_be_admin") unless $operator_obj->has_privilege(OP_ACL_ADMIN);
  
      my $v = $self->assert_with($args);
      my $operation_memo = delete $v->{operation_memo};
  
      $self->data_class->single({ email => $v->{email} }) and $self->abort_with("alreaady_registered");
  
      my $acl = <+ dist +>::OP::ACL->new(); 
      my $acl_token = $acl->get_token_from_op_access_keys( $v->{op_access_key} );
  
  
      my $obj = $self->data_class->new(
          email => $v->{email},
          op_name => $v->{op_name},
          op_timezone => $v->{op_timezone},
          op_language => $v->{op_language},
          password => <+ dist +>X::Util::hashed_password( $v->{password} ),
          acl_token => $acl_token,
      );
      $obj->save;
  
      my $log_obj = <+ dist +>::Data::OperationLog->new(
        operator_id    => $operator_obj->id,
        operation_type => OPERATION_TYPE_OPERATOR_CREATE,
        operation_memo => $operation_memo,
      );
  
      $log_obj->criteria_code( $obj->id );
      $log_obj->save();
  
      return $obj;
  }
  
  sub update_from_op_for_operator {
      my ($self,$obj,$args) = @_;
      my $v = $self->assert_with($args);
  
      for my $key (keys %$v ){
        $obj->$key( $v->{$key} );
      }
  
      $obj->save();
  }
  
  sub update_from_op {
      my ($self,$obj,$args,$operator_obj) = @_;
      $self->abort_with("you_must_be_admin") unless $operator_obj->has_privilege(OP_ACL_ADMIN);
      my $v = $self->assert_with($args);
  
      my $acl = <+ dist +>::OP::ACL->new(); 
      my $acl_token = $acl->get_token_from_op_access_keys( $v->{op_access_key} );
      my $backup = {
        acl_token => $obj->acl_token,
        on_active => $obj->on_active,
      };
  
      $obj->acl_token($acl_token);
      $obj->on_active($v->{on_active});
  
      my $operation_memo = delete $v->{operation_memo};
      my $log_obj = <+ dist +>::Data::OperationLog->new(
        operator_id    => $operator_obj->id,
        operation_type => OPERATION_TYPE_OPERATOR_UPDATE,
        operation_memo => $operation_memo,
      );
      $log_obj->set_attributes($backup);
      $log_obj->criteria_code( $obj->id );
      $log_obj->save();
  
      $obj->save;
      return $obj;
  }
  
  sub update_password {
      my ($self, $obj,$args) = @_;
      my $v = $self->assert_with($args);
      unless ($v->{password} eq $v->{confirm_password}) {
        $self->abort_with('invalid_confirm_password');
      }
      $obj->password( <+ dist +>X::Util::hashed_password( $v->{password}) );
      $obj->save;
      return $obj;
  }
  
  EOC;
---
file: lib/____var-dist-var____/Model/Role/DataObject.pm
template: |
  package <+ dist +>::Model::Role::DataObject;
  use Ze::Role;
  use Mouse::Util;
  use DBIx::TransactionManager;
  use <+ dist +>::ObjectDriver::DBI;
  
  has 'data_class' => (
      is => 'rw',
      lazy_build => 1
  );
  
  sub get_tm {
      if ( !$Ze::GLOBAL->{TM} ) {
          $Ze::GLOBAL->{TM} = DBIx::TransactionManager->new( <+ dist +>::ObjectDriver::DBI->driver->rw_handle );
      }
      return $Ze::GLOBAL->{TM};
  }
  
  sub _build_data_class {
      my $self = shift;
      my $class = ref $self;
      my @a = split('::',$class);
      my $name = $a[-1];
      my $pkg =  '<+ dist +>::Data::' . $name;
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
  sub lookup_or_abort {
      my $self = shift;
      my $obj = $self->lookup(@_) or $self->abort_with('not_found');
      return $obj;
  }
  
  sub search_with_pager {
      my $self  = shift;
      my $args  = shift || {};
      my $opts  = shift || {};
      my $p     = delete $args->{p} || 1;
      my $limit = $opts->{limit} || 50;
      my $v = $self->assert_with($args);
  
      my $pager = $self->create_pager($p);
      $pager->entries_per_page($limit);
      $pager->current_page($p);
      $opts->{pager} = $pager;
      my @objs = $self->data_class->search( $v, $opts );
  
      return ( $pager, \@objs );
  }
  
  sub update {
      my $self = shift;
      my $obj_or_id = shift;
      my $args = shift;
      my $opts = shift || {};
  
      my $profile_name = $opts->{profile_name} || 'update';
  
      my $obj ;
      {
          if(ref $obj_or_id ) {
              $obj = $obj_or_id;
          }
          else {
              $obj = $self->data_class->lookup( $obj_or_id ) 
                  or $self->abort_with( 'obj_not_found' );
          }
      }
  
      my $v = $self->assert_with($args,$profile_name);
      for my $field (keys %$v){
          $obj->$field( $v->{$field} );
      }
      $obj->save();
      return $obj;
  }
  
  sub search_for_op {
      my $self = shift;
      my $args = shift;
      my $opts = shift;
      my $v =  $self->assert_with($args);
  
      $opts->{direction} = delete $v->{direction} if $v->{direction} ;
      $opts->{sort} = delete $v->{sort} if $v->{sort} ;
  
      my ($pager,$objs) = $self->data_class->search_with_pager($v,$opts);
      return ($pager,$objs);
  }
  
  
  1;
---
file: lib/____var-dist-var____/ObjectDriver/DBI.pm
template: |
  package <+ dist +>::ObjectDriver::DBI;
  use strict;
  use warnings;
  use base qw(<+ dist +>::ObjectDriver::Replication);
  use Ze;
  use DBI;
  use List::Util;
  use <+ dist +>X::Config;
  
  sub _get_dbh_master {
      if( $Ze::GLOBAL->{dbh} &&  $Ze::GLOBAL->{dbh}{master} && $Ze::GLOBAL->{dbh}{master}->ping){
          return $Ze::GLOBAL->{dbh}{master};
      }
      else {
          my $config = <+ dist +>X::Config->instance()->get('database')->{master};
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
      if( $Ze::GLOBAL->{TM} ){
          return _get_dbh_master();
      }
  
      my $config = <+ dist +>X::Config->instance()->get('database')->{slaves};
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
  package <+ dist +>::ObjectDriver::Replication;
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
file: lib/____var-dist-var____/OP/ACL.pm
template: |
  package <+ dist +>::OP::ACL;
  use strict;
  use warnings;
  use parent qw(Exporter);
  use Ze::Class;
  use Data::LazyACL;
  
  use constant OP_ACL_ADMIN => 'admin'; # special
  use constant OP_ACL_REPORT => 'report';
  use constant OP_ACL_OPERATION => 'operation';
  
  our @EXPORT = ("OP_ACL_ADMIN","OP_ACL_REPORT","OP_ACL_OPERATION");
  
  my $DATA = {};
  
  sub make_hash_ref {
      no strict 'refs';
      for my $key(@EXPORT) {
          $DATA->{$key} = $key->();
      }
      1;
  }
  __PACKAGE__->make_hash_ref();
  
  # TODO rename to master_access_keys
  sub as_hashref {
      return $DATA;
  }
  
  has 'acl' => (
      is => 'rw',
    lazy_build => 1,
  );
  
  sub _build_acl {
    my $acl = Data::LazyACL->new();
    # never change order of the array.
    $acl->set_all_access_keys([OP_ACL_REPORT,OP_ACL_OPERATION]);
    return $acl;
  }
  
  sub get_token_for_admin { return -1; }
  
  sub get_token_for_operator { 
    my $self = shift;
    return $self->acl->generate_token( [OP_ACL_REPORT,OP_ACL_OPERATION] );
  }
  
  sub generate_token {
    my $self = shift;
    my $access_keys =  shift || [];
    $self->acl->generate_token($access_keys);
  }
  
  sub get_token_from_op_access_keys {
    my $self = shift;
    my $access_keys =  shift || [];
  
    for(@$access_keys){
      if( $_ eq OP_ACL_ADMIN ){
        return $self->get_token_for_admin(); 
      }
    }
    return $self->acl->generate_token($access_keys);
  }
  
  sub set_token {
    my $self = shift;
    my $token = shift;
    $self->acl->set_token($token);
    return $self->acl;
  }
  
  
  EOC;
---
file: lib/____var-dist-var____/OP/Context.pm
template: |
  package <+ dist +>::OP::Context;
  use Ze::Class;
  use <+ dist +>::Session::OP;
  extends '<+ dist +>::WAF::Context';
  
  has 'requested_at' => ( is => 'rw');
  has 'operator_obj' => ( is => 'rw');
  
  __PACKAGE__->load_plugins(
      'Ze::WAF::Plugin::Encode',
      'Ze::WAF::Plugin::FillInForm',
      # 'Ze::WAF::Plugin::JSON'
  );
  
  sub create_session {
      my $c = shift;
    return <+ dist +>::Session::OP->create($c->req,$c->res);
  }
  
  sub abort_if_no_privilege {
      my $c = shift;
      my $access_key = shift;
      unless ( $c->operator_obj->has_privilege( $access_key ) ){
          $c->redirect('/auth/login');
          $c->abort();
      }
  }
  
  sub NOT_FOUND {
    my $c = shift;
    $c->not_found();
    $c->abort();
  }
  
  sub redirect {
      my( $c, $url, $code ) = @_;
      $code ||= 302;
      $c->res->status( $code );
      $url = ($url =~ m{^https?://}) ? $url : $c->uri_for( $url );
      $c->res->redirect( $url );
      $c->finished(1);
   }
  
   sub uri_for {
      my $c = shift;
      my $path = shift;
      my $config = <+ dist +>X::Config->instance();
      my $url = $config->get('url')->{op} . $path;
      return $url;
  }
  
  EOC;
---
file: lib/____var-dist-var____/OP/Dispatcher.pm
template: |
  package <+ dist +>::OP::Dispatcher;
  use Ze::Class;
  extends 'Ze::WAF::Dispatcher::Router';
  use <+ dist +>X::Home;
  
  sub _build_config_file {
      my $self = shift;
      $self->home->file('router/op.pl');
  }
  
  sub _build_home {
      my $self = shift;
      return <+ dist +>X::Home->get;
  }
  
  EOC;
---
file: lib/____var-dist-var____/OP/I18N.pm
template: |
  package <+ dist +>::OP::I18N;
  use strict;
  use warnings;
  use base 'Locale::Maketext';
  
  my $home;
  
  BEGIN  {
  
  use <+ dist +>X::Home;
      $home = <+ dist +>X::Home->get();
  }
  
  
  use Locale::Maketext::Lexicon {
      en_US => ['Auto'],
      ja_JP => [ Gettext => $home->file('po/op/ja_JP.po')->stringify ,'Auto'],
      _preload => 1,
      _auto    => 1, # XXX
      _style   => 'gettext',
      _decode  => 1,
  };
  
  1;
---
file: lib/____var-dist-var____/OP/View.pm
template: |
  package <+ dist +>::OP::View;
  use Ze::Class;
  extends 'Ze::WAF::View';
  use <+ dist +>X::Home;
  use Ze::View;
  
  sub _build_engine {
      my $self = shift;
      my $path = [
          <+ dist +>X::Home->get()->subdir('view-op'),
          <+ dist +>X::Home->get()->subdir('view-include/op')
      ];
  
      return Ze::View->new(
          engines => [
              {
                  engine => 'Ze::View::Xslate',
                  config => {
                      path   => $path,
                      module => [
                          'Text::Xslate::Bridge::Star',
                          '<+ dist +>::OP::View::Util'
                      ],
                      macro => ['macro.inc'],
                      function => {
                      },
                  }
              },
              { engine => 'Ze::View::JSON', config => {} }
          ]
      );
  
  }
  
  EOC;
---
file: lib/____var-dist-var____/OP/Controller/Auth.pm
template: |
  package <+ dist +>::OP::Controller::Auth ;
  use Ze::Class;
  extends '<+ dist +>::OP::Controller::Base';
  
  sub login {
      my ( $self, $c ) = @_;
      if($c->req->method eq 'POST'){
          $self->do_login($c);
      }
  }
  
  sub logout {
      my ( $self, $c ) = @_;
    my $session = $c->create_session;
    $session->set("operator_id" => undef );
    $session->finalize;
    $c->redirect("/");
  }
  
  sub do_login {
    my $self = shift;
    my $c = shift;
    my $obj = $c->model('Operator')->login($c->req->as_fdat);
    my $session = $c->create_session;
    $session->set("operator_id" => $obj->id);
    $session->finalize;
    $c->redirect("/");
  }
  
  EOC;
---
file: lib/____var-dist-var____/OP/Controller/Base.pm
template: |
  package <+ dist +>::OP::Controller::Base;
  
  use Ze::Class;
  extends '<+ dist +>::WAF::Controller';
  use <+ dist +>::Authorizer::Operator;
  use <+ dist +>X::Config;
  use <+ dist +>X::DateTime;
  use <+ dist +>X::Constants;
  use <+ dist +>::OP::I18N;
  use Text::Xslate::Util;
  
  __PACKAGE__->add_trigger(
    BEFORE_EXECUTE => sub {
      my ( $self, $c, $action ) = @_;
    my $now = <+ dist +>X::DateTime->now();
    $c->requested_at($now);
    $c->stash->{requested_at} = $now;
    %{$c->stash->{constants}} = ( %{<+ dist +>X::Constants::as_hashref()}, %{<+ dist +>::OP::ACL::as_hashref()} );
    $c->stash->{config} = <+ dist +>X::Config->instance;
    $c->stash->{support_op_timezones} = <+ dist +>X::Util::support_op_timezones;
    $c->stash->{support_op_languages} = <+ dist +>X::Util::support_op_languages;
  
  
    # default. do nothing
    $c->stash->{loc} = sub { return shift; };
    $c->stash->{loc_row} = sub { return shift; };
      
    return if ($c->req->path =~ /^\/auth\//);
  
  
    my $authorizer = <+ dist +>::Authorizer::Operator->new( c => $c );
    if( my $operator_obj = $authorizer->authorize() ){
        $c->operator_obj($operator_obj);
        $c->stash->{operator_obj} = $operator_obj;
  
  
        my $i18n = <+ dist +>::OP::I18N->get_handle($operator_obj->op_language);
  
        $c->stash->{loc} = sub {
            my $text = shift;
            my @args = @_;
            return $i18n->maketext( $text, @args ) ;
        };
  
        $c->stash->{loc_raw} = Text::Xslate::Util::html_builder {
            my $format = shift;
            my @args = map { Text::Xslate::Util::html_escape($_) } @_;
            return $i18n->maketext($format, @args);
        };
  
    }
    else {
        $c->redirect('/auth/login');
        $c->abort();
    }
  
    $c->on_fillin(1);
    $c->stash->{fdat} = $c->req;
  
  
  });
  
  
  EOC;
---
file: lib/____var-dist-var____/OP/Controller/Member.pm
template: |
  package <+ dist +>::OP::Controller::Member;
  use Ze::Class;
  extends '<+ dist +>::OP::Controller::Base';
  use <+ dist +>::OP::ACL;
  
  __PACKAGE__->add_trigger(
    BEFORE_EXECUTE => sub {
      my ( $self, $c, $action ) = @_;
      $c->abort_if_no_privilege(OP_ACL_OPERATION);
    }
  );
  
  sub index {
      my ( $self, $c ) = @_;
  }
  
  
  EOC;
---
file: lib/____var-dist-var____/OP/Controller/Root.pm
template: |
  package <+ dist +>::OP::Controller::Root;
  use Ze::Class;
  extends '<+ dist +>::OP::Controller::Base';
  
  sub index {
      my ( $self, $c ) = @_;
  }
  
  
  EOC;
---
file: lib/____var-dist-var____/OP/Controller/Admin/Base.pm
template: |
  package <+ dist +>::OP::Controller::Admin::Base ;
  use Ze::Class;
  extends '<+ dist +>::OP::Controller::Base';
  use <+ dist +>::OP::ACL;
  
  __PACKAGE__->add_trigger(
    BEFORE_EXECUTE => sub {
      my ( $self, $c, $action ) = @_;
      $c->abort_if_no_privilege(OP_ACL_ADMIN);
    }
  );
  
  EOC;
---
file: lib/____var-dist-var____/OP/Controller/Admin/OperationLog.pm
template: |
  package <+ dist +>::OP::Controller::Admin::OperationLog;
  use Ze::Class;
  extends '<+ dist +>::OP::Controller::Admin::Base';
  use <+ dist +>::OP::ACL;
  
  __PACKAGE__->add_trigger(
    BEFORE_EXECUTE => sub {
      my ($self,$c,$action ) = @_;
  
      if (  $action =~ m/^(detail)$/ ){ 
        my $obj = $c->model('OperationLog')->lookup($c->args->{operation_log_id}) or return $c->NOT_FOUND() ;
        $c->stash->{obj} = $obj;
      }
  
    },
  );
  
  sub index {
    my ($self,$c) = @_;
    my ($pager,$objs) = $c->model("OperationLog")->search_for_op($c->req->as_fdat);
    $c->stash->{pager} = $pager;
    $c->stash->{objs} = $objs;
  }
  
  sub detail {
    my ($self,$c) = @_;
    $c->template( 'admin/operation_log/detail');
  
  }
  
  EOC;
---
file: lib/____var-dist-var____/OP/Controller/Admin/Operator.pm
template: |
  package <+ dist +>::OP::Controller::Admin::Operator ;
  use Ze::Class;
  extends '<+ dist +>::OP::Controller::Admin::Base';
  use <+ dist +>::OP::ACL;
  
  __PACKAGE__->add_trigger(
    BEFORE_EXECUTE => sub {
      my ($self,$c,$action ) = @_;
  
      if (  $action =~ m/^(edit|detail)$/ ){ 
        my $obj = $c->model('Operator')->lookup($c->args->{operator_id}) or return $c->NOT_FOUND() ;
        $c->stash->{obj} = $obj;
      }
  
    },
  );
  
  sub index {
    my ($self,$c) = @_;
    my ($pager,$objs) = $c->model("Operator")->search_for_op($c->req->as_fdat);
    $c->stash->{pager} = $pager;
    $c->stash->{objs} = $objs;
  }
  
  sub detail {
    my ($self,$c) = @_;
    $c->template( 'admin/operator/detail');
  
  
  }
  
  sub add {
    my ($self,$c) = @_;
    my $acl = <+ dist +>::OP::ACL->new();
    $c->stash->{access_keys} = $acl->as_hashref;
    if ( $c->req->method eq 'POST' ){
      $self->do_add($c);
    }
  }
  
  sub do_add {
    my ($self,$c) = @_;
    $c->model("Operator")->create_from_op( $c->req->as_fdat,$c->operator_obj);
    return $c->redirect('/admin/operator/');
  }
  
  sub edit {
    my ($self,$c) = @_;
    $c->template( 'admin/operator/edit');
    my $obj = $c->stash->{obj};
    my $acl = <+ dist +>::OP::ACL->new();
    $c->stash->{access_keys} = $acl->as_hashref;
  
    if( $c->req->method eq 'POST' ) {
      $self->do_edit($c,$obj);
    }
  
    my $fdat = $obj->as_fdat;
    $fdat->{op_access_key} = $obj->access_keys;
    $c->stash->{fdat} = $fdat;
  }
  
  sub do_edit {
    my ($self,$c,$obj) = @_;
    $c->model('Operator')->update_from_op($obj,$c->req->as_fdat,$c->operator_obj);
    return $c->redirect('/admin/operator/?operator_id=' . $obj->id);
  }
  
  sub operation_log {
    my ($self,$c) = @_;
    my ($pager,$objs) = $c->model("OperationLog")->search_for_op($c->req->as_fdat);
    $c->stash->{pager} = $pager;
    $c->stash->{objs} = $objs;
  }
  
  EOC;
---
file: lib/____var-dist-var____/OP/Controller/My/Operator.pm
template: |
  package <+ dist +>::OP::Controller::My::Operator;
  use Ze::Class;
  extends '<+ dist +>::OP::Controller::Base';
  use <+ dist +>::OP::ACL;
  
  sub index {
      my ( $self, $c ) = @_;
  
  }
  
  sub edit {
      my ( $self, $c ) = @_;
    my $acl = <+ dist +>::OP::ACL->new();
    my $obj = $c->operator_obj;
    $c->stash->{access_keys} = $acl->as_hashref;
  
    if( $c->req->method eq 'POST' ) {
      $self->do_edit($c,$obj);
    }
  
    my $fdat = $obj->as_fdat;
    $fdat->{op_access_key} = $obj->access_keys;
    $c->stash->{fdat} = $fdat;
  }
  
  sub do_edit {
    my ($self,$c,$obj) = @_;
    $c->model('Operator')->update_from_op_for_operator($obj,$c->req->as_fdat);
    return $c->redirect('/my/operator/');
  }
  
  sub edit_password {
    my ( $self, $c ) = @_;
    $c->on_fillin(0);
    my $obj = $c->operator_obj;
    if( $c->req->method eq 'POST' ) {
      $self->do_edit_password($c,$obj);
    }
  
  }
  sub do_edit_password {
    my ( $self,$c,$obj) = @_;
    $c->model('Operator')->update_password($obj,$c->req->as_fdat);
    return $c->redirect('/my/operator/');
  }
  
  EOC;
---
file: lib/____var-dist-var____/OP/View/Util.pm
template: |
  package <+ dist +>::OP::View::Util;
  
  use strict;
  use warnings;
  use parent 'Text::Xslate::Bridge';
  use <+ dist +>X::Config;
  use <+ dist +>X::Constants;
  use JSON::XS;
  use Encode;
  
  __PACKAGE__->bridge(
      function => { 
        lookup_const => \&lookup_const, 
        json => \&json,
      },
  );
  
  sub lookup_const {
    my $tag = shift;
    my $items = <+ dist +>X::Constants::lookup($tag);
    my $TAG = uc($tag);
    my $i = {};
    for my $value (keys %$items){
      my $new_key = $items->{$value};
      $new_key =~ s/$TAG\_//;
      $i->{$value} = $new_key;
    }
    return $i;
  }
  
  sub json {
      my $value = shift || {};
      return Text::Xslate::Util::mark_raw( Encode::decode('utf8',JSON::XS::encode_json( $value )));
  }
  
  1;
---
file: lib/____var-dist-var____/Role/Config.pm
template: |
  package <+ dist +>::Role::Config;
  use strict;
  use Ze::Role;
  use <+ dist +>X::Config;
  
  sub config {
      return <+ dist +>X::Config->instance();
  }
  
  1;
---
file: lib/____var-dist-var____/Session/OP.pm
template: |
  package <+ dist +>::Session::OP;
  use strict;
  use warnings;
  use HTTP::Session;
  use HTTP::Session::State::Cookie;
  use <+ dist +>::Cache::Session::OP;
  use <+ dist +>X::Config;
  
  
  
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
      my $cookie_config =  <+ dist +>X::Config->instance()->get('op_cookie_session');
  
      my $session = HTTP::Session->new(
          store => HTTP::Session::Store::Memcached->new( memd =>  <+ dist +>::Cache::Session::OP->instance ),
          state => HTTP::Session::State::Cookie->new( name => $cookie_config->{namespace} ),
          request => $req,
      );
  
  
      # http headerをセットしてる程度なのでとりあえずここでもおk
      $session->response_filter($res);
      return $session;
  }
  
  1;
---
file: lib/____var-dist-var____/Validator/Error.pm
template: |
  package <+ dist +>::Validator::Error;
  use strict;
  use warnings;
  use Ze::Class;
  extends 'Aplon::Error';
  with 'Aplon::Error::Role::LazyWay';
  
  use overload ( q{""} => \&as_string);
  
  sub as_string {
      my $self = shift;
      return join "\n", '<+ dist +>::Validator::Error', @{$self->error_keys};
  }
  
  
  sub errors {
    my $self = shift;
    my @errors = ();
    for my $field ( keys %{$self->error_message} ) {
        my $item = $self->error_message->{$field};
        if (ref $item eq 'ARRAY' ){
          push @errors, @$item; 
        }
        else{
          push @errors, $item; 
        }
    }
    return \@errors;
  }
  
  EOC;
---
file: lib/____var-dist-var____/Validator/Filter.pm
template: |
  package <+ dist +>::Validator::Filter;
  use strict;
  use warnings;
  
  sub trim_space {
    my $text = shift;  
    $text =~ s/^\s+//; 
    $text =~ s/\s+$//;
    return $text;
  }
  
  
  
  1;
---
file: lib/____var-dist-var____/Validator/Result.pm
template: |
  package <+ dist +>::Validator::Result;
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
file: lib/____var-dist-var____/Validator/Rule.pm
template: |
  package <+ dist +>::Validator::Rule;
  use strict;
  use warnings;
  use DateTime::TimeZone;
  use <+ dist +>X::Util;
  use <+ dist +>::OP::ACL();
  
  sub op_timezone {
      my $timezone          = shift;
      my $support_timezones = <+ dist +>X::Util::support_op_timezones;
      for my $lng (@$support_timezones) {
          if ( $lng eq $timezone ) {
              return 1;
          }
      }
      return 0;
  }
  sub op_language {
      my $language          = shift;
      my $support_languages = <+ dist +>X::Util::support_op_languages;
      for my $lng (@$support_languages) {
          if ( $lng eq $language ) {
              return 1;
          }
      }
      return 0;
  }
  sub op_access_key {
    my $key = shift;
    my $keys = <+ dist +>::OP::ACL->new->as_hashref();
  
    for my $k ( keys %$keys){
      return 1 if $key eq $keys->{$k} ;
    }
    return 0;
  }
  
  
  
  sub timezone {
      DateTime::TimeZone->is_valid_name(shift) ? 1 : 0;
  }
  
  sub terminal_type {
    my $type = shift;
    return $type =~ /^[1-3]$/ ? 1 : 0;
  }
  
  sub language {
      my $language          = shift;
      my $support_languages = <+ dist +>X::Util::support_languages;
      for my $lng (@$support_languages) {
          if ( $lng eq $language ) {
              return 1;
          }
      }
      return 0;
  }
  
  sub range {
    my $num  = shift;
    my $args = shift;
    return 0 unless $num =~ /^[0-9]*$/;
    return 0 if $num > $args->{max};
    return 0 if $num < $args->{min};
  
    return 1;
  }
  
  sub order_direction {
    my $value = shift or return 0;
    return $value =~ /^(descend|ascend)$/ ? 1 : 0;
  }
  
  sub order_by {
    my $text = shift or return 0;
    return $text =~ /^[a-z0-9_]+$/ ? 1 : 0;
  }
  
  sub operation_type {
    my $type = shift;
    return $type =~ /^[1-2]$/ ? 1 : 0;
  }
  
  1;
---
file: lib/____var-dist-var____/Validator/Rule/JA.pm
template: |
  package <+ dist +>::Validator::Rule::JA;
  use warnings;
  use strict;
  use utf8;
  
  sub timezone { 'タイムゾーン' }
  sub language { '言語' }
  sub terminal_type { 'ターミナルタイプ' }
  sub op_access_key { 'アクセスキー' }
  sub op_timezone { 'タイムゾーン' }
  sub op_language { '言語' }
  sub range { '範囲' }
  sub order_direction { 'ソート順' }
  sub order_by { 'ソートキー' }
  sub operation_type { '操作タイプ' }
  
  1;
---
file: lib/____var-dist-var____/WAF/Context.pm
template: |
  package <+ dist +>::WAF::Context;
  use Ze::Class;
  use Module::Pluggable::Object;
  extends 'Ze::WAF::Context';
  
  my $MODELS ;
  BEGIN {
      $MODELS = {}; 
      my $finder = Module::Pluggable::Object->new(
          search_path => ['<+ dist +>::Model'],
          except => qr/^(<+ dist +>::Model::Base$|<+ dist +>::Model::Role::)/, 
          'require' => 1,
      );
      my @classes = $finder->plugins;
      for my $class (@classes) {
          (my $moniker = $class) =~ s/^<+ dist +>::Model:://;
          $MODELS->{$moniker} = $class;
      }
  }
  
  sub model {
      my $c =  shift;
      my $moniker= shift;
      my $args   = shift || {};
      return $MODELS->{$moniker}->new( $args );
  }
  
  
  
  EOC;
---
file: lib/____var-dist-var____/WAF/Controller.pm
template: |
  package <+ dist +>::WAF::Controller;
  use Ze::Class;
  use Try::Tiny;
  use Class::Trigger;
  extends "Ze::WAF::Controller";
  
  sub EXECUTE {
      my( $self, $c, $action ) = @_;
  
      try {
          $self->call_trigger('BEFORE_EXECUTE',$c,$action);
          $self->$action( $c );
      }
      catch {
          if( ref $_ && ref $_ eq '<+ dist +>::Validator::Error') {
  
              if($c->view_type && $c->view_type eq 'JSON') {
                  $c->set_json_error($_);
              }
              else {
                  $c->stash->{fdat} = $_->valid;
                  $c->stash->{error_obj} = $_;
              }
          }
          elsif ( ref $_ ) {
              die Dumper $_;
          }
          else {
              die $_;
          }
      };
  
      $self->call_trigger('AFTER_EXECUTE',$c,$action);
  
      return 1;
  }
  
  
  EOC;
---
file: lib/____var-dist-var____/WAF/Dispatcher.pm
template: |
  package <+ dist +>::WAF::Dispatcher;
  use Ze::Class;
  extends "Ze::WAF::Dispatcher::Router";
  EOC;
---
file: lib/____var-dist-var____X/Config.pm
template: |
  package <+ dist +>X::Config;
  use parent 'Ze::Config';
  
  sub appname {
    my $self = shift;
    my $class = ref $self;
    my $name = uc Ze::Util::app_class( $class );
    $name =~ s/X$//;
    return $name;
  }
  sub get_config_files {
      my $self = shift;
      my @files;
      my $home = $self->home;
      my $base = $home->file('config/config.pl');
      push @files, $base;
  
      if ( my $env = $ENV{ $self->appname . '_ENV' } ) {
          my $filename = sprintf 'config/config_%s.pl', $env;
          die "could not found local config file:" . $home->file($filename) unless -f $home->file($filename);
          push @files, $home->file($filename);
      }
  
      return \@files;
  }
  
  1;
---
file: lib/____var-dist-var____X/Constants.pm
template: |
  package <+ dist +>X::Constants;
  
  use strict;
  use warnings;
  use parent qw(Exporter);
  
  our @EXPORT_OK = ();
  our %EXPORT_TAGS = (
      terminal_type      => [qw(TERMINAL_TYPE_WEB TERMINAL_TYPE_IOS TERMINAL_TYPE_ANDROID)],
      version_status     => [qw(VERSION_STATUS_OK VERSION_STATUS_REQUIRE_TO_UPDATE VERSION_STATUS_RECOMMEND_TO_UPDATE)],
      day_of_week        => [qw(MONDAY TUESDAY WEDNESDAY THURSDAY FRIDAY SATURDAY SUNDAY)],
      api_error          => [qw(API_ERROR API_ERROR_CLIENT_VERSION API_ERROR_CLIENT_MASTER API_ERROR_CLIENT_MAINTENANCE)],
      operation_type     => [qw(OPERATION_TYPE_OPERATOR_CREATE OPERATION_TYPE_OPERATOR_UPDATE)],
  );
  
  our $DATA = {};
  
  __PACKAGE__->build_export_ok();
  __PACKAGE__->make_hash_ref();
  
  use constant MONDAY    => 1;
  use constant TUESDAY   => 2;
  use constant WEDNESDAY => 3;
  use constant THURSDAY  => 4;
  use constant FRIDAY    => 5;
  use constant SATURDAY  => 6;
  use constant SUNDAY    => 7;
  
  use constant TERMINAL_TYPE_WEB     => 1;
  use constant TERMINAL_TYPE_IOS     => 2;
  use constant TERMINAL_TYPE_ANDROID => 3;
  
  use constant VERSION_STATUS_OK                  => 1;
  use constant VERSION_STATUS_REQUIRE_TO_UPDATE   => 2;
  use constant VERSION_STATUS_RECOMMEND_TO_UPDATE => 3;
  
  use constant API_ERROR => 1;
  use constant API_ERROR_CLIENT_VERSION => 2;
  use constant API_ERROR_CLIENT_MASTER  => 3;
  use constant API_ERROR_CLIENT_MAINTENANCE  => 4;
  
  use constant OPERATION_TYPE_OPERATOR_CREATE => 1;
  use constant OPERATION_TYPE_OPERATOR_UPDATE => 2;
  
  
  
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
  
  sub lookup {
    my $tag   = shift;
    my $list  = $EXPORT_TAGS{$tag};
    my $items = {};
    for (@$list) {
      $items->{ $DATA->{$_} } = $_;
    }
    return $items;
  }
  
  1;
---
file: lib/____var-dist-var____X/DateTime.pm
template: |
  package <+ dist +>X::DateTime;
  use strict;
  use warnings;
  use base qw( DateTime );
  use DateTime::TimeZone;
  use DateTime::Format::Strptime;
  use DateTime::Format::MySQL;
  use <+ dist +>X::Constants qw(:day_of_week);
  
  
  *DateTime::fmt_datetime = sub {
    my $self = shift;
    $self->strftime('%Y-%m-%d %H:%M:%S');
  };
  
  
  our $DEFAULT_TIMEZONE = DateTime::TimeZone->new( name => 'UTC' );
  
  sub new {
      my ( $class, %opts ) = @_;
      $opts{time_zone} ||= $DEFAULT_TIMEZONE;
      return $class->SUPER::new(%opts);
  }
  
  sub now {
      my ( $class, %opts ) = @_;
      $opts{time_zone} ||= $DEFAULT_TIMEZONE;
      return $class->SUPER::now(%opts);
  }
  
  sub from_epoch {
      my $class = shift;
      my %p = @_ == 1 ? ( epoch => $_[0] ) : @_;
      $p{time_zone} ||= $DEFAULT_TIMEZONE;
      return $class->SUPER::from_epoch(%p);
  }
  
  sub parse_mysql_datetime {
      my $class    = shift;
      my $datetime = shift;
      return DateTime::Format::MySQL->parse_datetime($datetime);
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
  
      my $dt = $module->parse_datetime($date) or return;
  
      $dt->set_time_zone( $DEFAULT_TIMEZONE || 'local' )
      unless $dt->time_zone->is_floating;
  
      return bless $dt, $class;
  }
  
  sub strptime {
      my ( $class, $pattern, $date ) = @_;
      my $format = DateTime::Format::Strptime->new(
          pattern   => $pattern,
          time_zone => $DEFAULT_TIMEZONE || 'local',
      );
      $class->parse( $format, $date );
  }
  
  sub set_time_zone {
      my $self = shift;
      eval { $self->SUPER::set_time_zone(@_) };
      if ($@) {
          $self->SUPER::set_time_zone('UTC');
      }
      return $self;
  }
  
  sub sql_now {
      my ( $class, %options ) = @_;
      my $self = $class->now(%options);
      $self->strftime('%Y-%m-%d %H:%M:%S');
  }
  
  sub yesterday {
      my $class = shift;
      my $now   = $class->now();
      return $now->subtract( days => 1 );
  }
  
  sub first_day_of_week {
      my ( $class, $year, $week ) = @_;
      return $class->new( year => $year, month => 1, day => 4 )->add( weeks => ( $week - 1 ) )->truncate( to => 'week' );
  }
  
  sub day_of_week {
      my $self        = shift;
      my $day_of_week = $self->SUPER::day_of_week;
      if ( $_[0] && $_[0] =~ /^\d$/ ) {
          my $start_day = $_[0];
          $day_of_week = ( $day_of_week >= $start_day ) ? $day_of_week - ( $start_day - 1 ) : $day_of_week + ( 8 - $start_day );
      }
      return $day_of_week;
  }
  
  sub offset_to_nextweek {
      my ( $self, $start_day ) = @_;
      my $day = $self->day_of_week($start_day);
      return 4 - ( ( $day + 8 ) % 8 );
  }
  
  sub last_day_of_month {
      my $self = shift;
      my $dt = $self->clone;
      return $dt->set_day(1)->add(months => 1)->subtract(days => 1)->day;
  }
  
  1;
---
file: lib/____var-dist-var____X/Home.pm
template: |
  package <+ dist +>X::Home;
  use parent 'Ze::Home';
  1;
---
file: lib/____var-dist-var____X/Setting.pm
template: |
  package <+ dist +>X::Setting;
  use strict;
  use warnings;
  use parent '<+ dist +>X::Overwrite::Setting';
  
  
  
  1;
---
file: lib/____var-dist-var____X/Util.pm
template: |
  package <+ dist +>X::Util;
  use strict;
  use warnings;
  use Data::GUID;
  use Data::GUID::URLSafe;
  use Encode;
  use JSON::XS;
  use Digest::SHA;
  use <+ dist +>X::Setting;
  
  
  sub default_language {
    return <+ dist +>X::Setting->DEFAULT_LANGUAGE;
  }
  
  sub support_languages {
    return <+ dist +>X::Setting->SUPPORT_LANGUAGES;
  }
  
  sub default_op_timezone {
    return <+ dist +>X::Setting->DEFAULT_OP_TIMEZONE;
  }
  
  sub support_op_timezones {
    return <+ dist +>X::Setting->SUPPORT_OP_TIMEZONES;
  }
  
  sub default_op_language {
    return <+ dist +>X::Setting->DEFAULT_OP_LANGUAGE;
  }
  sub support_op_languages {
    return <+ dist +>X::Setting->SUPPORT_OP_LANGUAGES;
  }
  
  
  sub from_json {
    my $json = shift;
    $json = Encode::encode( 'utf8', $json );
    return JSON::XS::decode_json($json);
  }
  
  sub to_json {
    my $data = shift;
    Encode::decode( 'utf8', JSON::XS::encode_json($data) );
  }
  
  sub available_language {
      my $language = shift;
      return default_language() unless $language;
  
      for ( @{ support_languages() } ) {
          if ( $language eq $_ ) {
              return $language;
          }
      }
      return default_language();
  }
  
  sub generate_access_token {
      Data::GUID->new->as_base64_urlsafe;
  }
  
  sub generate_terminal_code {
      Data::GUID->new->as_base64_urlsafe;
  }
  
  sub hashed_password {
    my $password = shift;
    Digest::SHA::sha256_base64($password);
  }
  
  1;
---
file: lib/____var-dist-var____X/Doc/API.pm
template: |
  package <+ dist +>X::Doc::API;
  use strict;
  use warnings;
  use Ze::Class;
  use <+ dist +>X::Home;
  
  has 'data' => ( is => 'rw');
  
  sub BUILD {
    my $self = shift;
    my $home = <+ dist +>X::Home->instance();
    my $doc = do $home->file('doc/api.pl');
    $self->data($doc);
  }
  
  sub get {
    my $self = shift;
    my $path = shift;
  
    for my $g (@{$self->data}){
        for my $i ( @{$g->{list}} ){
          return $i if $i->{path} eq $path;
        }
    }
    return ;
  }
  
  sub get_list {
    my $self = shift;
    my @groups = ();
  
    for my $g (@{$self->data}){
  
      my $group  = {
        name => $g->{name},
      };
  
      my @items = ();
      for my $i ( @{$g->{list}} ){
          my $item = {
            path => $i->{path},
            description => $i->{description},
          };
          push @items,$item;
      }
      $group->{items} = \@items;
      push @groups,$group;
    }
  
    return \@groups;
  }
  
  EOC;
---
file: lib/____var-dist-var____X/Setting/Default.pm
template: |
  package <+ dist +>X::Setting::Default;
  use strict;
  use warnings;
  
  use constant DEFAULT_LANGUAGE => 'ja_JP';
  use constant SUPPORT_LANGUAGES => ['ja_JP'];
  
  use constant DEFAULT_OP_LANGUAGE => 'en_US';
  use constant DEFAULT_OP_TIMEZONE => 'Asia/Tokyo';
  use constant SUPPORT_OP_LANGUAGES => ['en_US','ja_JP'];
  use constant SUPPORT_OP_TIMEZONES => ['Asia/Tokyo','Asia/Taipei'];
  
  1;
---
file: misc/____var-appname-var____.sql
template: |
  create table member (
         member_id int unsigned not null auto_increment,
         member_name varchar(255) NOT NULL,
         language varchar(5) NOT NULL,
         timezone varchar(100) NOT NULL,
         last_active_at DATETIME NOT NULL,
         on_active tinyint unsigned not null,
         updated_at TIMESTAMP NOT NULL,
         created_at DATETIME NOT NULL,
         PRIMARY KEY (member_id),
         KEY(last_active_at)
  ) ENGINE=InnoDB DEFAULT CHARACTER SET = 'utf8';
  
  create table auth_terminal (
        member_id int unsigned not null,
        terminal_code varchar(255) not null,
        terminal_type tinyint not null,
        terminal_info varchar(255) not null,
        updated_at TIMESTAMP NOT NULL,
        created_at DATETIME NOT NULL,
        PRIMARY KEY (terminal_code),
        INDEX(member_id)
  ) ENGINE=InnoDB DEFAULT CHARACTER SET = 'utf8';
  
  create table auth_access_token (
        member_id int unsigned not null,
        access_token varchar(255) not null,
        updated_at TIMESTAMP NOT NULL,
        created_at DATETIME NOT NULL,
        PRIMARY KEY (access_token),
        KEY (member_id)
  ) ENGINE=InnoDB DEFAULT CHARACTER SET = 'utf8';
  
  create table operator (
    operator_id int unsigned not null auto_increment,
    op_name          varchar(255) not null,
    email            varchar(255) not null,
    password         varchar(255) NOT NULL,
    op_timezone      varchar(255) NOT NULL,
    op_language varchar(5) NOT NULL,
    acl_token        varchar(255) NOT NULL,
    on_active tinyint unsigned not null,
    updated_at       TIMESTAMP    NOT NULL,
    created_at       DATETIME     NOT NULL,
    PRIMARY KEY(operator_id),
    UNIQUE(email)
  ) ENGINE=InnoDB DEFAULT CHARACTER SET = 'utf8';
  
  create table operation_log (
    operation_log_id int unsigned not null auto_increment,
    operator_id int unsigned not null,
    operation_type int unsigned not null,
    criteria_code varchar(100) not null,
    attributes_dump TEXT not null,
    operation_memo TEXT,
    updated_at       TIMESTAMP    NOT NULL,
    created_at       DATETIME     NOT NULL,
    PRIMARY KEY (operation_log_id),
    INDEX(operator_id),
    INDEX(operation_type,criteria_code)
  ) ENGINE=InnoDB DEFAULT CHARACTER SET = 'utf8';
---
file: misc/dbuser.sql
template: |
  CREATE USER 'dev_master'@'localhost' IDENTIFIED BY '';
  GRANT ALL PRIVILEGES ON * . * TO 'dev_master'@'localhost';
  CREATE USER 'dev_slave'@'localhost' IDENTIFIED BY '';
  GRANT SELECT ON * . * TO 'dev_slave'@'localhost';
---
file: misc/asset-sample/config/config.pl
template: |
  {
    debug => 0,
    cache => {
      servers => ['127.0.0.1:11211'],
    },
    cache_session => {
      servers => ['127.0.0.1:11211'],
    },
    cache_session_op => {
      servers => ['127.0.0.1:11211'],
    },
    application_version => {
        'iOS' => {
            min => 2,
            current => 4,
      },
    },
    database => {
        master => {
            dsn => "dbi:mysql:<+ dist | lower +>_test",
            username => "dev_master",
            password => "",
        },
        slaves => [
            {
                dsn => "dbi:mysql:<+ dist | lower +>_test",
                username => "dev_slave",
                password => "",
            }
        ],
    },
    op_cookie_session => {
      namespace => 'session_op',
    }
  }
---
file: misc/asset-sample/config/config_local.pl
template: |
  {
    debug => 1,
    url => {
      api => 'http://localhost:5000/api',
      explorer => 'http://localhost:5000/explorer',
      op => 'http://localhost:5000/op',
    },
    database => {
        master => {
            dsn => "dbi:mysql:<+ dist | lower +>_local",
            username => "dev_master",
            password => "",
        },
        slaves => [
            {
                dsn => "dbi:mysql:<+ dist | lower +>_local",
                username => "dev_slave",
                password => "",
            }
        ],
    },
  }
---
file: misc/asset-sample/data/i18n/card/ja_JP.json
template: |
  {
    "1.name" : "武士にゃん"
  }
---
file: misc/asset-sample/data/master/card/1.json
template: |
  {
    "master_card_id":1
    "master_card_type":1
    "cost":1,
    "hp":2,
    "attack":1
  }
---
file: misc/asset-sample/lib/____var-dist-var____X/Overwrite/Setting.pm
template: |
  package <+ dist +>X::Overwrite::Setting;
  use strict;
  use warnings;
  use parent '<+ dist +>X::Setting::Default';
  
  
  
  1;
---
file: po/op/ja_JP.po
template: |
  msgid ""
  msgstr ""
  
  #: view-include/op/header.inc:15
  msgid "Operation System"
  msgstr "運用システム"
---
file: psgi/api.psgi
template: |
  use strict;
  use FindBin::libs;
  use Plack::Builder;
  use File::RotateLogs;
  
  use <+ dist +>::API;
  use <+ dist +>X::Home;
  use <+ dist +>::Validator;
  use <+ dist +>X::Config;
  use Plack::Middleware::ServerStatus::Lite;
  
  
  # TODO LOAD INTO MEMORY
  
  
  # singletonize Validator
  <+ dist +>::Validator->instance();    # compile
  
  my $home = <+ dist +>X::Home->get;
  
  my $webapp = <+ dist +>::API->new;
  
  my $app = $webapp->to_app;
  
  my $config = <+ dist +>X::Config->instance();
  my $middlewares = $config->get('middleware') || {};
  
  if ($middlewares) {
    $middlewares = $middlewares->{api} || [];
  }
  
  builder {
    enable 'Plack::Middleware::Static',
        path => qr{^/static/},
        root => $home->file('htdocs');
  
    enable_if { $_[0]->{REMOTE_ADDR} eq '127.0.0.1' } "Plack::Middleware::ReverseProxy";
  
    if ( $ENV{<+ dist | upper +>_ENV} eq 'production' ) {
      my $rotatelogs = File::RotateLogs->new(
        logfile      => '/var/log/<+ dist | lower +>-server/access_log.%Y%m%d%H%M',
        linkname     => '/var/log/<+ dist | lower +>-server/access_log',
        rotationtime => 3600,
        maxage       => 86400 * 7,
      );
      
      enable 'Plack::Middleware::AxsLog',
          combined      => 1,
          response_time => 1,
          logger        => sub { $rotatelogs->print(@_) };
    }
  
    for (@$middlewares) {
      if ( $_->{opts} ) {
        enable $_->{name}, %{ $_->{opts} };
      }
      else {
        enable $_->{name};
      }
    }
  
    $app;
  };
---
file: psgi/explorer.psgi
template: |+
  use strict;
  use FindBin::libs;
  use Plack::Builder;
  use File::RotateLogs;
  use <+ dist +>::Explorer;
  use <+ dist +>X::Home;
  use <+ dist +>::Validator;
  use <+ dist +>X::Config;
  #use Devel::KYTProf;
  
  # singletonize Validator 
  <+ dist +>::Validator->instance();
  
  my $home = <+ dist +>X::Home->get;
  
  my $webapp = <+ dist +>::Explorer->new;
  
  my $app = $webapp->to_app;
  
  my $config = <+ dist +>X::Config->instance();
  my $middlewares = $config->get('middleware') || {};
  
  if ($middlewares) {
      $middlewares = $middlewares->{explorer} || [];
  }
  
  builder {
    enable 'Plack::Middleware::Static',
        path => qr{^/static/},
        root => $home->file('htdocs-internal');
  
    enable_if { $_[0]->{REMOTE_ADDR} eq '127.0.0.1' } "Plack::Middleware::ReverseProxy";
  
    if ( $ENV{<+ dist | upper +>_ENV} eq 'production' ) {
      my $rotatelogs = File::RotateLogs->new(
        logfile      => '/var/log/<+ dist | lower +>-explorer/access_log.%Y%m%d%H%M',
        linkname     => '/var/log/<+ dist | lower +>-explorer/access_log',
        rotationtime => 3600,
        maxage       => 86400 * 7,
      );
  
      enable 'Plack::Middleware::AxsLog',
          combined      => 1,
          response_time => 1,
          logger        => sub { $rotatelogs->print(@_) };
    }
  
    for (@$middlewares) {
      if ( $_->{opts} ) {
        enable $_->{name}, %{ $_->{opts} };
      }
      else {
        enable $_->{name};
      }
    }
  
    $app;
  };

---
file: psgi/mix.psgi
template: |
  use strict;
  use warnings;
  use FindBin::libs;
  use Plack::App::URLMap;
  use Plack::Util;
  
  use <+ dist +>X::Home;
  
  my $home = <+ dist +>X::Home->get;
  
  my $api = Plack::Util::load_psgi( $home->file('psgi/api.psgi'));
  my $explorer = Plack::Util::load_psgi( $home->file('psgi/explorer.psgi'));
  my $op = Plack::Util::load_psgi( $home->file('psgi/op.psgi'));
  
  my $urlmap = Plack::App::URLMap->new;
  $urlmap->map("/" => $explorer); # XXX
  $urlmap->map("/api" => $api);
  $urlmap->map("/explorer" => $explorer);
  $urlmap->map("/op" => $op);
  
  $urlmap->to_app;
---
file: psgi/op.psgi
template: |+
  use strict;
  use FindBin::libs;
  use Plack::Builder;
  use File::RotateLogs;
  use <+ dist +>::OP;
  use <+ dist +>X::Home;
  use <+ dist +>::Validator;
  use <+ dist +>X::Config;
  #use Devel::KYTProf;
  
  # singletonize Validator 
  <+ dist +>::Validator->instance();
  
  my $home = <+ dist +>X::Home->get;
  
  my $webapp = <+ dist +>::OP->new;
  
  my $app = $webapp->to_app;
  
  my $config = <+ dist +>X::Config->instance();
  my $middlewares = $config->get('middleware') || {};
  
  if ($middlewares) {
      $middlewares = $middlewares->{op} || [];
  }
  
  builder {
    enable 'Plack::Middleware::Static',
        path => qr{^/static/},
        root => $home->file('htdocs-internal');
  
    enable_if { $_[0]->{REMOTE_ADDR} eq '127.0.0.1' } "Plack::Middleware::ReverseProxy";
  
    if ( $ENV{<+ dist | upper +>_ENV} eq 'production' ) {
      my $rotatelogs = File::RotateLogs->new(
        logfile      => '/var/log/<+ dist | lower +>-op/access_log.%Y%m%d%H%M',
        linkname     => '/var/log/<+ dist | lower +>-op/access_log',
        rotationtime => 3600,
        maxage       => 86400 * 7,
      );
  
      enable 'Plack::Middleware::AxsLog',
          combined      => 1,
          response_time => 1,
          logger        => sub { $rotatelogs->print(@_) };
    }
  
    for (@$middlewares) {
      if ( $_->{opts} ) {
        enable $_->{name}, %{ $_->{opts} };
      }
      else {
        enable $_->{name};
      }
    }
  
    $app;
  };

---
file: router/api.pl
template: |
  my $terminal_type = '/{frontend:(?:app|web)}';
  
  my $router = router {
      submapper($terminal_type . '/', {controller => 'Root'})
              ->connect('info', {action => 'info' })
      ;
  
      submapper('/app/auth_terminal/', {controller => 'AuthTerminal'})
        ->connect('register', {action => 'register' })
        ->connect('login', {action => 'login' })
      ;
  
      submapper($terminal_type . '/member/', {controller => 'Member'})
        ->connect('me', {action => 'me' })
      ;
  
  }
---
file: router/explorer.pl
template: |
  my $router = router {
    submapper( '/', { controller => 'Root' } )
      ->connect( '', { action => 'index' } )
      ->connect( 'proxy', { action => 'proxy' } )
      ->connect( 'doc', { action => 'doc' } )
    ;
  };
  
  return $router;
---
file: router/op.pl
template: |
  my $route = router {
    submapper( '/', { controller => 'Root' } )
      ->connect( '', { action => 'index' } )
    ;
  
    submapper( '/auth/', { controller => 'Auth' } )
      ->connect( 'login', { action => 'login' } )
      ->connect( 'logout', { action => 'logout' } )
    ;
  
    submapper( '/member/', { controller => 'Member' } )
      ->connect( '', { action => 'index' } )
    ;
  
    submapper( '/my/operator/', { controller => 'My::Operator' } )
      ->connect( '', { action => 'index' } )
      ->connect( 'edit', { action => 'edit' } )
      ->connect( 'edit_password', { action => 'edit_password' } )
    ;
  
    submapper( '/admin/operator/', { controller => 'Admin::Operator' } )
      ->connect( '', { action => 'index' } )
      ->connect( 'add', { action => 'add' } )
      ->connect( '{operator_id:[0-9]+}/edit', { action => 'edit' } )
      ->connect( '{operator_id:[0-9]+}/', { action => 'detail' } )
    ;
  
    submapper( '/admin/operation_log/', { controller => 'Admin::OperationLog' } )
      ->connect( '', { action => 'index' } )
      ->connect( '{operation_log_id:[0-9]+}/', { action => 'detail' } )
    ;
  
  };
  
  return $route;
---
file: t/00_compile.t
template: |+
  use strict;
  use warnings;
  use Test::LoadAllModules;
  
  BEGIN {
      all_uses_ok( search_path => '<+ dist +>'); 
  }

---
file: t/02_all_data_class_ready.t
template: |
  use Test::More;
  use t::Util;
  use lib 't/lib';
  use Module::Pluggable::Object;
  use <+ dist +>::ObjectDriver::DBI;
  
  $finder = Module::Pluggable::Object->new( search_path => '<+ dist +>::Data',except => qr/^<+ dist +>::Data::Plugin::|^<+ dist +>::Data::Base/);
  
  for($finder->plugins){
    use_ok($_);
    columns_ok($_);
  }
  
  $tables = <+ dist +>::ObjectDriver::DBI->driver->r_handle->selectcol_arrayref("show tables");
  my $hashs = {};
  
  for(@{$tables} ){
    $_ =~ s/_//g;
    $_ = lc($_);
    $hashs->{$_} = 1;
  }
  
  for($finder->plugins){
    my($name) = $_ =~ m/::([^:]+)$/;
    $name =~ s/_//g;
    $name = lc($name);
    if( $hashs->{$name} ){
      ok(1,'check ok ' . $_);
    }
    else {
      ok(0,'check ng ' . $_);
    }
  }
  
  
  done_testing();
---
file: t/API-Context.t
template: |
  use Test::More;
  
  use_ok("<+ dist +>::API::Context");
  
  
  done_testing();
---
file: t/API-View.t
template: |
  use Test::More;
  
  use_ok('<+ dist +>::API::View');
  
  done_testing();
---
file: t/API.t
template: |
  use Test::More;
  
  use_ok( '<+ dist +>::API');
  
  done_testing();
---
file: t/Cache-Session.t
template: |
  use Test::More;
  
  use_ok(<+ dist +>::Cache::Session);
  
  my $session = <+ dist +>::Cache::Session->instance();
  
  $session->set('a','b');
  is($session->get('a'),'b');;
  
  done_testing();
---
file: t/ClientDetector.t
template: |
  use Test::More;
  use strict;
  use <+ dist +>::ClientDetector;
  use <+ dist +>X::Constants qw(:terminal_type);
  
  subtest 'ios ok' => sub { 
      my $obj = <+ dist +>::ClientDetector->new({ application_version => 'iOS_1' });
      is($obj->version,1);
      is($obj->client_name,'iOS');
  };
  
  subtest 'get_version_status' => sub {
      my $obj = <+ dist +>::ClientDetector->new({ application_version => 'iOS_1' });
      ok($obj->get_version_status());
  };
  
  subtest 'terminal_type' => sub {
      {
          my $obj = <+ dist +>::ClientDetector->new({ application_version => 'iOS_1' });
          is($obj->terminal_type(), TERMINAL_TYPE_IOS);
      }
      {
          my $obj = <+ dist +>::ClientDetector->new({ application_version => 'Android_1' });
          is($obj->terminal_type(), TERMINAL_TYPE_ANDROID);
      }
  };
  
  done_testing();
---
file: t/Data-AuthAccessToken.t
template: |
  use Test::More;
  use t::Util;
  
  cleanup_database();
  
  use_ok('<+ dist +>::Data::AuthAccessToken');
  
  subtest 'defaults' => sub {
    my $member_obj = create_member_obj();
    my $obj = <+ dist +>::Data::AuthAccessToken->new(
      member_id => $member_obj->id,
    );
    $obj->save();
    ok( $obj->access_token);
  };
  
  done_testing();
---
file: t/Data-AuthTerminal.t
template: |
  use Test::More;
  use t::Util;
  use <+ dist +>X::Constants qw(:terminal_type);
  
  cleanup_database();
  
  use_ok('<+ dist +>::Data::AuthTerminal');
  
  subtest 'defaults' => sub {
    my $member_obj = create_member_obj();
    my $obj = <+ dist +>::Data::AuthTerminal->new(
      member_id => $member_obj->id,
      terminal_type => TERMINAL_TYPE_IOS,
      terminal_info => 'Android/XXX',
    );
    $obj->save();
    ok( $obj->terminal_code);
  };
  
  subtest 'reset_access_token' => sub {
    my $member_obj = create_member_obj();
    my $obj = <+ dist +>::Data::AuthTerminal->new(
      member_id => $member_obj->id,
      terminal_type => TERMINAL_TYPE_IOS,
      terminal_info => 'Android/XXX',
    );
    $obj->save();
    my $access_token = $obj->reset_access_token();
    ok( $access_token );
    my $access_token2 = $obj->reset_access_token();
    $access_token2 = $obj->reset_access_token();
    ok( $access_token2 );
    ok( $access_token ne $access_token2 );
  };
  
  
  done_testing();
---
file: t/Data-Member.t
template: |
  use Test::More;
  use t::Util;
  use_ok('<+ dist +>::Data::Member');
  
  cleanup_database();
  
  
  subtest 'alias' => sub {
    my $obj = <+ dist +>::Data::Member->new(
      member_name => "Mr.Foo",
      language  => 'ja_JP',
      timezone => 'Asia/Tokyo' 
    );
    $obj->save();
    is($obj->member_id,$obj->id);
  };
  
  
  
  done_testing();
---
file: t/Data-OperationLog.t
template: |
  use Test::More;
  use t::Util;
  
  cleanup_database();
  
  use_ok('<+ dist +>::Data::OperationLog');
  
  
  done_testing();
---
file: t/Data-Operator.t
template: |
  use Test::More;
  use t::Util;
  
  cleanup_database();
  
  use_ok('<+ dist +>::Data::Operator');
  
  subtest 'defaults' => sub {
    my $obj = <+ dist +>::Data::Operator->new(
      op_name => 'Mr.Hoge',
      email => 'example@example.com',
      password => 'secret',
    );
    $obj->save();
    isa_ok($obj,'<+ dist +>::Data::Operator');
  };
  
  done_testing();
---
file: t/OP-ACL.t
template: |
  use Test::More;
  use strict;
  use warnings;
  use <+ dist +>::OP::ACL;
  
  {
    my $acl = <+ dist +>::OP::ACL->new();
    my $acl_token = $acl->get_token_for_operator();
    my $acl_obj = $acl->set_token($acl_token);
  
    ok( $acl_obj->has_privilege(OP_ACL_REPORT) );
    ok( $acl_obj->has_privilege(OP_ACL_OPERATION) );
    ok( !$acl_obj->has_privilege(OP_ACL_ADMIN) );
  }
  
  {
    my $acl = <+ dist +>::OP::ACL->new();
    my $acl_token = $acl->get_token_for_admin;
    my $acl_obj = $acl->set_token($acl_token);
  
    ok( $acl_obj->has_privilege(OP_ACL_REPORT) );
    ok( $acl_obj->has_privilege(OP_ACL_OPERATION) );
    ok( $acl_obj->has_privilege(OP_ACL_ADMIN) );
  
  
  }
  
  done_testing();
---
file: t/OP-I18N.t
template: |
  use Test::More;
  
  use_ok('<+ dist +>::OP::I18N');
  
  my $i18n = <+ dist +>::OP::I18N->get_handle('en_US');
  
  
  done_testing();
---
file: t/Pager.t
template: |
  use Test::More;
  
  use_ok('<+ dist +>::Pager');
  
  done_testing();
---
file: t/Util.pm
template: |
  use strict;
  use warnings;
  use utf8;
  use lib 't/lib';
  
  package t::Util;
  use strict;
  use parent qw/Exporter/;
  use Ze::WAF::Request;
  use <+ dist +>::Session::OP;
  use Plack::Test;
  use Plack::Util;
  use <+ dist +>X::Home;
  use Test::More();
  use <+ dist +>::ObjectDriver::DBI;
  use HTTP::Request::Common;
  use Test::TCP qw(empty_port);
  use Test::More;
  use Proc::Guard;
  use <+ dist +>X::Config;
  use <+ dist +>X::Home;
  use HTTP::Request;
  use HTTP::Response;
  use HTTP::Message::PSGI;
  use Try::Tiny;
  
  our @EXPORT = qw(
  test_api
  test_op
  login_terminal
  login_op
  create_operator_obj
  cleanup_database
  create_member_obj
  model_throws_ok
  api_res_ok
  columns_ok
  aliases_ok
  GET HEAD PUT POST
  );
  
  {
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
      die 'Do not use this script on production' if $ENV{<+ dist | upper +>_ENV} && $ENV{<+ dist | upper +>_ENV} eq 'production';  
  
      # Home hack
      *<+ dist +>X::Home::_new_instance = sub {
          my $class = shift;
          die 'You can not use this module directory' if $class eq 'App::Home';
          my $self  = bless { }, $class;
          $self->_home()->subdir('/t/root')
      };
  
  
      my $config;
      {
        local $ENV{<+ dist | upper +>_ENV} = '';
        $config = <+ dist +>X::Config->instance();
      }
  
      # up memcached for caches
      my $memcached_port = empty_port();
      $config->{cache} = {
          servers => ['127.0.0.1:' . $memcached_port  ],
      };
      $config->{cache_session} = {
          servers => ['127.0.0.1:' . $memcached_port  ],
      };
      $config->{cache_session_op} = {
          servers => ['127.0.0.1:' . $memcached_port  ],
      };
  
  
      $CACHE_MEMCACHED = t::Proc::Guard->new(
          command => ['/usr/bin/env','memcached', '-p', $memcached_port]
      );
  
  
      # database接続先の上書き
      my $database_config = $config->get('database');
      $database_config->{master}{dsn} =  "dbi:mysql:<+ dist | lower +>_test_" . $ENV{<+ dist | upper +>_ENV};
      for(@{$database_config->{slaves}}){
          $_->{dsn} =  "dbi:mysql:<+ dist | lower +>_test_" . $ENV{<+ dist | upper +>_ENV};
      } 
  
  
  
  }
  
  sub test_api {
      my $cb = shift;
      test_psgi(
          app => Plack::Util::load_psgi( <+ dist +>X::Home->get->file('psgi/api.psgi') ),
          client => $cb,
      );
  }
  sub test_op {
      my $cb = shift;
      test_psgi(
          app => Plack::Util::load_psgi( <+ dist +>X::Home->get->file('psgi/op.psgi') ),
          client => $cb,
      );
  }
  
  sub create_operator_obj {
      return <+ dist +>::Model::Operator->new->create_admin_operator({
              email => 'example@example.com',
              op_name => 'Mr.Foo',
              password => 'secret',
          });
    }
  
  sub login_op {
      my $operator_obj = shift || create_operator_obj();
  
      my $env = HTTP::Request->new(GET => "http://localhost/")->to_psgi;
      my $req  = Ze::WAF::Request->new($env);
      my $res  = $req->new_response;
      my $session = <+ dist +>::Session::OP->create($req,$res );
      
      $session->set('operator_id',$operator_obj->id); 
      $session->finalize();
      $ENV{HTTP_COOKIE} = $res->headers->header('SET-COOKIE');
      return $operator_obj;
  }
  
  sub cleanup_database {
      Test::More::note("TRUNCATING DATABASE");
      my $conf = <+ dist +>X::Config->instance->get('database')->{'master'};
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
          next if $_->[0] =~ /_view$/;
          push @tables,$_->[0];
      }
  
      return \@tables;
  }
  
  sub create_member_obj {
      my %args = @_;
      require <+ dist +>::Model::Member;
      $args{member_name} ||= '"<xmp>テスト';
      $args{language} ||= 'ja_JP';
      $args{timezone} ||= 'Asia/Tokyo';
      my $member_obj = <+ dist +>::Model::Member->new()->create( \%args );
      return $member_obj;
  }
  
  sub model_throws_ok  {
      my ( $coderef, $error_keys, $description ) = @_;
  
      try {
        $coderef->();
        Test::More::fail('no error');
      }
      catch {
        my $error = $_;
        Test::More::isa_ok($error,'<+ dist +>::Validator::Error');
        Test::More::is_deeply([sort(@{$error->error_keys})],$error_keys,$description);
      };
  }
  
  sub login_terminal {
    require <+ dist +>::Model::AuthTerminal;
    my $model = <+ dist +>::Model::AuthTerminal->new();
    my $obj = $model->register({member_name => "hello",language=>'ja_JP',timezone=>'Asia/Tokyo',terminal_type =>1 , terminal_info => "hoge" });
    my $access_token = $model->login($obj->terminal_code);
    return $access_token;
  }
  
  sub api_res_ok {
    my $res = shift;    
    Test::More::is($res->code,200,"HTTP Response OK");
    eval { 
      my $content = <+ dist +>X::Util::from_json($res->content);
      is($content->{error},0,"JSON Response OK");
    };
    if($@){
      Test::More::fail($res->content);
    }
  }
  sub columns_ok {
      my $pkg =  shift or die 'please set data class name';
  
      my $dbh = <+ dist +>::ObjectDriver::DBI->driver->rw_handle;
  
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
  
  sub aliases_ok {
    my $obj = shift;
    my $aliases = shift;
    for(@$aliases){
      if( $obj->can($_) ){
      }
      else {
        Test::More::ok(0,$_ . ' is not alliace');
        return ;
      }
    }
  
    Test::More::ok(1,'aliases_ok');
  }
  
  
  1;
---
file: t/Validator-Error.t
template: |
  use Test::More;
  
  use_ok('<+ dist +>::Validator::Error');
  
  
  my $error = <+ dist +>::Validator::Error->new();
  is("<+ dist +>::Validator::Error","$error","overload ok");
  
  
  done_testing();
---
file: t/Validator-Result.t
template: |
  use Test::More;
  
  
  use_ok("<+ dist +>::Validator::Result");
  
  
  done_testing();
---
file: t/Validator-Rule.t
template: |
  use Test::More;
  
  use_ok('<+ dist +>::Validator::Rule');
  
  done_testing();
---
file: t/WAF-Context.t
template: |
  use Test::More;
  
  use_ok('<+ dist +>::WAF::Context');
  
  done_testing();
---
file: t/WAF-Controller.t
template: |
  use Test::More;
  
  use_ok('<+ dist +>::WAF::Controller');
  
  done_testing();
---
file: t/WAF-Dispatcher.t
template: |
  use Test::More;
  
  use_ok('<+ dist +>::WAF::Dispatcher');
  
  done_testing();
---
file: t/API-Controller-AuthTerminal/login.t
template: |
  use Test::More;
  use t::Util;
  use <+ dist +>X::Util;
  use <+ dist +>::Model::AuthTerminal;
  
  cleanup_database;
  
  sub create_termianl_code {
    my $model = <+ dist +>::Model::AuthTerminal->new;
    my $obj = $model->register({
      terminal_type=>1,
      terminal_info=>'hoge',
      member_name=>'test',
      language=>'ja_JP',
      timezone=>'Asia/Tokyo',
    });
    return $obj->terminal_code;
  }
  
  test_api(sub {
          my $cb  = shift;
  
          {
            my $res = $cb->(POST "/app/auth_terminal/login",{ terminal_code => create_termianl_code() });
            api_res_ok($res);
          }
  
  });
  
  
  done_testing();
---
file: t/API-Controller-AuthTerminal/register.t
template: |
  use Test::More;
  
  use t::Util;
  
  test_api(sub {
          my $cb  = shift;
          my $res = $cb->(POST "/app/auth_terminal/register",{terminal_type=>1,terminal_info=>"hoge",member_name=>'Mr.Hoge',language => 'ja_JP',timezone=>"Asia/Tokyo" });
          api_res_ok($res);
  });
  
  
  
  done_testing();
---
file: t/API-Controller-Member/me.t
template: |
  use Test::More;
  use t::Util;
  
  cleanup_database;
  
  
  test_api(sub {
          my $cb  = shift;
  
          {
            my $res = $cb->(POST "/app/member/me",x_access_token => login_terminal() );
            api_res_ok($res);
          }
  
          {
            my $res = $cb->(POST "/app/member/me" );
            is($res->code,401);
          }
  
  });
  
  
  done_testing();
---
file: t/API-Controller-Root/info.t
template: |
  use Test::More;
  use t::Util;
  
  test_api(sub {
          my $cb  = shift;
          my $res = $cb->(GET "/web/info");
          api_res_ok($res);
          });
  
  
  done_testing();
---
file: t/lib/App/Prove/Plugin/SchemaUpdater.pm
template: |
  # DB スキーマに変更があったら、テスト用のデータベースをまるっと作り替える
  # mysqldump --opt -d -uroot <+ dist | lower +>_$ENV} | mysql -uroot <+ dist | lower +>_test_${ENV}
  # として、データベースを作成。スキーマ定義がちがくてうごかないときも同様。
  #
  #
  
  package t::lib::App::Prove::Plugin::SchemaUpdater;
  use strict;
  use warnings;
  use Test::More;
  
  sub run { system(@_)==0 or die "Cannot run: @_\n-- $!\n"; }
  
  sub get_<+ dist | lower +>_env {
      return $ENV{<+ dist | upper +>_ENV}; 
  }
  
  sub create_database {
      my ($target, $<+ dist | lower +>_env) = @_;
      diag("CREATE DATABASE ${target}_test_${<+ dist | lower +>_env}");
      run("mysqladmin -uroot create ${target}_test_${<+ dist | lower +>_env}");
  }
  sub drop_database {
      my ($target, $<+ dist | lower +>_env) = @_;
      diag("DROP DATABASE ${target}_test_${<+ dist | lower +>_env}");
      run("mysqladmin --force -uroot drop ${target}_test_${<+ dist | lower +>_env}");
  }
  sub copy_database {
      my ($target, $<+ dist | lower +>_env) = @_;
      diag("COPY DATABASE ${target}_${<+ dist | lower +>_env} to ${target}_test_${<+ dist | lower +>_env}");
      run("mysqldump --opt -d -uroot ${target}_${<+ dist | lower +>_env} | mysql -uroot ${target}_test_${<+ dist | lower +>_env}");
  }
  sub has_database {
      my ($target, $<+ dist | lower +>_env) = @_;
      my $command = sprintf "echo 'show databases' | mysql -u root|egrep '%s_test_%s\$' | wc -l", $target, $<+ dist | lower +>_env;
      return (`$command`=~ /1/);
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
      my ($target, $<+ dist | lower +>_env) = @_;
      my $orig = filter_dumpdata(`mysqldump --opt -d -uroot ${target}_${<+ dist | lower +>_env}`);
      my $test = filter_dumpdata(`mysqldump --opt -d -uroot ${target}_test_${<+ dist | lower +>_env}`);
      return ($orig ne $test);
  }
  
  
  sub load {
      my $<+ dist | lower +>_env = get_<+ dist | lower +>_env or die '<+ dist | upper +>_ENV is not set';
      for my $target (qw/ <+ dist | lower +> /) {
          if (has_database($target, $<+ dist | lower +>_env)) {
              if (changed_database($target, $<+ dist | lower +>_env)) {
                  drop_database($target, $<+ dist | lower +>_env);
                  create_database($target, $<+ dist | lower +>_env);
                  copy_database($target, $<+ dist | lower +>_env);
              } else {
                  diag("NO CHANGE DATABASE ${target}_test_${<+ dist | lower +>_env}");
              }
          } else {
              create_database($target, $<+ dist | lower +>_env);
              copy_database($target, $<+ dist | lower +>_env);
          }
      }
  }
  
  1;
---
file: t/Model-AuthAccessToken/auth.t
template: |
  use Test::More;
  use t::Util;
  use <+ dist +>::Model::AuthAccessToken;
  
  cleanup_database();
  
  my $access_token = login_terminal();
  my $model = <+ dist +>::Model::AuthAccessToken->new();
  
  subtest 'ok' => sub {
    my $member_obj = $model->auth({access_token => $access_token});
    isa_ok($member_obj,'<+ dist +>::Data::Member');
  };
  
  subtest 'missing' => sub {
    model_throws_ok(sub { $model->auth({}); },['model.access_token.missing'], 'missing throw ok');
  };
  
  done_testing();
---
file: t/Model-AuthTerminal/login.t
template: |
  use Test::More;
  use <+ dist +>::Model::AuthTerminal;
  use t::Util;
  
  cleanup_database();
  
  my $model = <+ dist +>::Model::AuthTerminal->new();
  my $obj = $model->register({ terminal_type => 1, terminal_info => "HOGE", member_name => "hello",language=>'ja_JP',timezone=>'Asia/Tokyo' });
  
  my $last_active_at;
  {
    my $member_obj = $obj->member_obj();
    $last_active_at = $member_obj->last_active_at('2000-12-12 12:12:12');
    $member_obj->save();
  }
  
  my $access_token = $model->login($obj->terminal_code);
  
  ok($obj->member_obj()->last_active_at ne $last_active_at);
  
  ok($access_token);
  ok($model->login($obj->terminal_code) ne $access_token );
  
  done_testing();
---
file: t/Model-AuthTerminal/register.t
template: |
  use Test::More;
  use <+ dist +>::Model::AuthTerminal;
  use <+ dist +>X::Constants qw(:terminal_type);
  
  cleanup_database();
  my $model = <+ dist +>::Model::AuthTerminal->new();
  
  subtest 'ok' => sub {
    my $obj = $model->register({
      member_name => "hello",
      language => "ja_JP",
      timezone => "Asia/Tokyo",
      terminal_type => TERMINAL_TYPE_WEB,
      terminal_info => "hoge",
    });
    ok($obj->terminal_code);
    my $member_obj = $obj->member_obj;
    isa_ok($member_obj,'<+ dist +>::Data::Member');
  };
  
  done_testing();
---
file: t/Model-Member/create.t
template: |
  use Test::More;
  use strict;
  use warnings;
  use <+ dist +>::Model::Member;
  
  my $model = <+ dist +>::Model::Member->new();
  
  subtest 'ok' => sub {
    my $obj = $model->create({
      member_name => "Mr.Boo",
      language => "ja_JP",
      timezone => "Asia/Tokyo",
    });
    isa_ok($obj,"<+ dist +>::Data::Member");
  };
  
  subtest 'missing' => sub {
    model_throws_ok ( sub { $model->create({}) },['model.language.missing','model.member_name.missing','model.timezone.missing']);
  };
  
  
  done_testing();
---
file: t/Model-Operator/create_admin_operator.t
template: |
  use Test::More;
  use t::Util;
  use <+ dist +>::Model::Operator;
  use <+ dist +>::OP::ACL;
  
  cleanup_database();
  
  my $model = <+ dist +>::Model::Operator->new();
  
  
  subtest 'ok' => sub {
    my $obj = $model->create_admin_operator({
      email => 'example@example.com',
      op_name => 'Mr.Foo',
      password => 'secret',
    });
    $obj->save();
    isa_ok($obj,'<+ dist +>::Data::Operator');
    my $acl = <+ dist +>::OP::ACL->new();
    is( $obj->acl_token ,$acl->get_token_for_admin);
  };
  
  
  done_testing();
---
file: t/OP-Controller-Auth/login.t
template: |
  use Test::More;
  use t::Util;
  use <+ dist +>X::Util;
  use <+ dist +>::Model::Operator;
  
  cleanup_database;
  
  test_op(sub {
          my $cb  = shift;
          {
            my $res = $cb->(GET "/auth/login",{});
            is(200,$res->code)
          }
  
          {
  
            my $operator_obj = create_operator_obj();
            my $res = $cb->(POST "/auth/login",{ email => $operator_obj->email ,password => 'secret' });
            ok( $res->headers->header('Set-Cookie') );
            is(302,$res->code)
          }
  
  });
  
  
  done_testing();
---
file: t/OP-Controller-Root/index.t
template: |
  use Test::More;
  use t::Util;
  use <+ dist +>X::Util;
  
  cleanup_database;
  
  test_op(sub {
          my $cb  = shift;
          login_op();
          {
            my $res = $cb->(GET "/",{});
            is(200,$res->code)
          }
  });
  
  
  done_testing();
---
file: t/root/config/config.pl
template: |
  {
    debug => 1,
    url => {
      api => 'http://localhost:5000/api',
      explorer => 'http://localhost:5000/explorer',
      op => 'http://localhost:5000/op',
    },
    cache => {
      servers => ['127.0.0.1:11211'],
    },
    cache_session => {
      servers => ['127.0.0.1:11211'],
    },
    application_version => {
        'iOS' => {
            min => 2,
            current => 4,
      },
    },
    database => {
        master => {
            dsn => "dbi:mysql:<+ dist | lower +>_test",
            username => "dev_master",
            password => "",
        },
        slaves => [
            {
                dsn => "dbi:mysql:<+ dist | lower +>_test",
                username => "dev_slave",
                password => "",
            }
        ],
    },
    op_cookie_session => {
      namespace => 'session_op',
    }
  
  
  }
---
file: t/root/config/config_test.pl
template: "{}\n"
---
file: t/X/Config.t
template: |
  use Test::More;
  
  use_ok(<+ dist +>X::Config);
  
  my $servers = <+ dist +>X::Config->instance->get('cache')->{servers};
  
  is(1,scalar @$servers);
  
  done_testing();
---
file: t/X/Home.t
template: |
  use Test::More;
  
  use_ok(<+ dist +>X::Home);
  
  my $home = <+ dist +>X::Home->get();
  ok(-d $home->subdir('config')->cleanup(),'home dir should have config directory');
  
  done_testing();
---
file: t/X/Setting.t
template: |
  use Test::More;
  
  use_ok('<+ dist +>X::Setting');
  
  ok(<+ dist +>X::Setting->DEFAULT_LANGUAGE());
  
  done_testing();
---
file: view-explorer/index.tx
template: |
  [% INCLUDE 'header.inc' %]
  
  
  <table>
  <tr>
  <td valign="top">
  <form method="post" id="form" onsubmit="return do_exproler();">
    <table class="form">
      <tr>
        <th>Access Token:</th>
        <td><input type="text" name="access_token" id="access_token" value="" /></td>
      </tr>
      <tr>
        <th>Internal Token:</th>
        <td><input type="text" name="internal_token" id="internal_token" value="" /></td>
      </tr>
      <tr>
        <th>Path</th>
        <td>
          [% c.config.get('url').api %]<input type="text" name="path" value="/app/info" id="path" style="width:200px" />
        </td>
      </tr>
      <tr>
        <th>Args in JSON</th>
        <td>
          <textarea name="args" id="args"></textarea>
        </td>
      </tr>
      <tr>
        <td colspan="2" style="text-align:right">
          <input type="submit" value="実行" />
        </td>
      </tr>
  
  </table>
  </form>
  
  <table class="form">
    <tr><td><textarea id="response" name="response" style="width:500px;height:400px"></textarea></td></tr>
  </table>
  
  </td>
  <td valign="top">
  
  <div class="m_info-container" style="width:400px;">
  <div id="doc_detail"></div>
  
  
  <ul>
  [% FOREACH group IN doc %]
  <li>[% group.name %]</li>
  <ul>
    [% FOREACH item IN group.items %]
      <li>
      <a class="api_path" data-api_path="[% item.path %]" href="#">[% item.path %]</a>
  </li>
    [% END %]
  </ul>
  [% END %]
  </ul>
  
  </div>
  
  </td>
  </tr>
  </table>
  
  
  
  
  [% MACRO footer_content_block  BLOCK -%]
  <script>
  
  set_api('/app/info');
  function set_api(path){
      $('#path').val( path );
  
      $.ajax({ 
        url: '/explorer/doc',
        data: { path :path},
        success: function(json){
          $('#doc_detail').html(  $('#tmpl_doc_detail').template(json.item) );
          var args = {};
          for (var field in json.item.requests){
            args[field] = '';
          }
          $('#args').val(JSON.stringify(args, undefined, 2));
        }
      });
  
  }
  $(document).ready(function() {
    $('.api_path').click(function(){
      var path = $(this).attr('data-api_path');
      set_api(path);
    });
  
    return false;
  
  });
  
  function do_exproler(){
    $('#response').val('Loading...');
  
  
  
    $.ajax({ 
      url: '/explorer/proxy',
      dataType: "JSON",
      data: $('#form').serialize(),
      success: function(json){
        $('#response').val(JSON.stringify(json, undefined, 2) );
      }
    });
    return false;
  }
  
  </script>
  [% END %]
  
  <script id="tmpl_doc_detail" type="text/html">
    <table>
      <tr>
        <th>path</th>
        <td><%= path %></td>
      </tr>
      <tr>
        <th>description</th>
        <td><%= description %></td>
      </tr>
      <tr><th colspan="2">Requests</td></tr>
      <%  for (var field in requests) { %>
      <tr>
        <th><%= field %></th>
        <td><%= requests[field] %></td>
      </tr>
      <% } %>
      <tr><th colspan="2">Response</td></tr>
      <%  for (var field in response) { %>
      <tr>
        <th><%= field %></th>
        <td><%= response[field] %></td>
      </tr>
      <% } %>
      <tr><th colspan="2">Custom Errors</td></tr>
      <%  for (var field in custom_errors ) { %>
      <tr>
        <th><%= field %></th>
        <td><%= custom_errors[field] %></td>
      </tr>
      <% } %>
    </table>
  </script>
  
  [% INCLUDE 'footer.inc' WITH
      footer_content = footer_content_block()
  %]
---
file: view-include/explorer/footer.inc
template: |2
  
  <p class="copyright">©G-MODE Corporation</p>
  
  <script src="//ajax.googleapis.com/ajax/libs/jquery/1.7.0/jquery.min.js"></script>
  <script src="[% '/static/common/js/jquery.cookie.js' %]"></script>
  <script src="[% '/static/common/js/jquery.ze.js' %]"></script>
  
  [% footer_content %]
  
  </body>
  </html>
  </body>
  </html>
---
file: view-include/explorer/header.inc
template: |
  <!DOCTYPE html>
  <html>
  <head>
  <meta charset="utf-8">
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <meta http-equiv="X-UA-Compatible" content="IE=Edge">
  <meta name="google" content="notranslate">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  
  <meta name="robots" content="noindex,nofollow" />
  <meta http-equiv="pragma" content="no-cache" />
  <meta http-equiv="cache-control" content="no-cache" />
  <meta http-equiv="expires" content="Thu, 1 Jan 1970 00:00:00 GMT" />
  
  <title>Explorer</title>
  <link rel="stylesheet" href="/static/css/normalize.css">
  <link rel="stylesheet" href="/static/css/base.css">
  </head>
---
file: view-include/op/error.inc
template: |
  [% IF error_obj %]
  <ul>
  [% FOREACH message IN error_obj.errors() %]
  <li>[% message %]</li>
  [% END %]
  [% FOREACH key IN error_obj.custom_invalid %]
  <li>Custom Error: [% key %]</li>
  [% END %]
  </ul>
  [% END %]
---
file: view-include/op/footer.inc
template: "\n</body>\n</html>\n"
---
file: view-include/op/header.inc
template: |
  <!DOCTYPE html>
  <html>
  <head>
  <meta charset="utf-8">
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <meta http-equiv="X-UA-Compatible" content="IE=Edge">
  <meta name="google" content="notranslate">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  
  <meta name="robots" content="noindex,nofollow" />
  <meta http-equiv="pragma" content="no-cache" />
  <meta http-equiv="cache-control" content="no-cache" />
  <meta http-equiv="expires" content="Thu, 1 Jan 1970 00:00:00 GMT" />
  
  <title>[% loc('Operation System') %]</title>
  <link rel="stylesheet" href="/static/css/normalize.css">
  <link rel="stylesheet" href="/static/css/base.css">
  </head>
  [% IF operator_obj %]
  <div class="login-bar">
  <b>[% operator_obj.op_name %]</b> : <small>[% operator_obj.op_timezone %] - [% requested_at.set_time_zone(operator_obj.op_timezone).fmt_datetime() %]</small>
  <a href="[% c.uri_for('/auth/logout') %]">logout</a>
  </div>
  [% INCLUDE 'menu.inc' %]
  [% END %]
  
  [% INCLUDE 'error.inc' %]
---
file: view-include/op/macro.inc
template: |
  [% MACRO paginate(pager,my_uri) BLOCK -%]
  [%- IF pager -%]
  
      [%- CALL pager.uri(my_uri) -%]
      [%- IF pager.last_page != pager.first_page -%]
  				<div class="pager">
  					<ul>
  					[%- IF pager.previous_page %]<li><a href="[% pager.build_uri(pager.previous_page) %]" class="prev">&laquo;&nbsp;Prev</a></li>[% END -%]
  					[%- FOR p IN pager.pages_in_navigation(5) -%]
  					[%- IF p == pager.current_page %]<li><span>[% p %]</span></li>[% ELSE %]<li><a href="[% pager.build_uri(p) %]" class="number">[% p %]</a></li>[% END -%]
  					[%- END -%]
  					[%- IF pager.next_page %]<li><a href="[% pager.build_uri(pager.next_page) %]" class="next">Next&nbsp;&raquo;</a></li>[% END -%]
  					</ul>
  					<form class="navbar-form pull-left" action="[% pager.uri(my_uri) %]" method="get">
  					<input type="text" class="input-mysize" name="p"/> / [% pager.last_page %]
  					<button type="submit" class="btn">Go</button>
  					</form>
          </div><!-- /pager -->
  
      [%- END # over 1 page -%]
  [% END -%]
  [% END -%]
---
file: view-include/op/menu.inc
template: |+
  [%-
    SET MENU = [
      ['top','Top', '/',0],
      ['member','Member', '/member/',constants.OP_ACL_OPERATION],
      ['my','My', '/my/operator/',0],
      ['admin','Admin', '/admin/operator/',constants.OP_ACL_ADMIN],
    ];
  -%]
  [%-
    SET SUB_MENU = {
      top => [['top','top page','/']],
      my => [
          ['operator','account','/my/operator/'],
          ['operator_edit','edit','/my/operator/edit'],
          ['operator_edit_password','edit password','/my/operator/edit_password'],
      ],
      member => [
        ['list','Member List','/member/'],
      ],
      admin => [
        ['operator_list','Operator List','/admin/operator/'],
        ['operator_add','Add New Operator','/admin/operator/add'],
        ['operation_log_list','Operation Log','/admin/operation_log/'],
      ],
    };
  -%]
  <div id="menu_container">
  <ul id="menu">
  [% FOREACH i IN MENU %]
    [% UNLESS i.3 == 0 or operator_obj.has_privilege(i.3) %]
      [% NEXT %]
    [% END %]
    <li>[% IF i.0 == header.menu %]<b>[% i.1 %]</b>[% ELSE %]<a class="menu-[% i.0 %]" href="[% c.uri_for(i.2) %]">[% i.1 %]</a>[% END %]</li>
  [% END %]
  </ul>
  
  [% SET sub_menus = SUB_MENU.${header.menu} %]
  <ul id="sub_menu">
  [% FOREACH i IN sub_menus %]
   <li>[% IF i.0 == header.sub_menu %]<b>[% i.1 %]</b>[% ELSE %]<a class="menu-[% i.0 %]" href="[% c.uri_for(i.2) %]">[% i.1 %]</a>[% END %]</li>
  [% END %]
  </ul>
  </div>

---
file: view-include/op/lookup/on_active.inc
template: |
  <select name="on_active">
    [% IF on_empty %]<option value="">-</option>[% END %]
    <option value="0">disable</option>
    <option value="1">active</option>
  </select>
---
file: view-include/op/lookup/op_language.inc
template: |
  <select name="op_language">
  [% IF on_empty %]<option value="">-</option>[% END %]
  [% FOREACH op_language IN support_op_languages %]
  <option value="[% op_language %]">[% op_language %]</option>
  [% END %]
  </select>
---
file: view-include/op/lookup/op_timezone.inc
template: |
  <select name="op_timezone">
  [% IF on_empty %]<option value="">-</option>[% END %]
  [% FOREACH op_timezone IN support_op_timezones %]
  <option value="[% op_timezone %]">[% op_timezone %]</option>
  [% END %]
  </select>
---
file: view-include/op/lookup/operation_log.inc
template: |
  <select name="operation_type">
  [% IF on_empty %]<option value="">-</option>[% END %]
  [% SET lookup_operation_type = lookup_const('operation_type') %]
  [% FOREACH k IN lookup_operation_type.keys() %]
   <option value="[% k %]">[% lookup_operation_type.${k} %]</option> 
  [% END %]
  </select>
---
file: view-op/index.tx
template: |
  [% INCLUDE 'header.inc' WITH header = { menu => 'top', sub_menu => 'top' } %]
  top
  [% INCLUDE 'footer.inc' %]
---
file: view-op/admin/operation_log/detail.tx
template: |
  [% INCLUDE 'header.inc' WITH header = { menu => 'admin', sub_menu => 'operation_log_list' } %]
  
  <table class="detail">
      <tr>
        <th>operation log id</th>
         <td>[% obj.id %]</td>
      </tr>
      <tr>
        <th>operator</th>
         <td><a href="[% c.uri_for('/admin/operator/' _ obj.operator_id _ '/') %]">[% obj.operator_id %]</a> : [% obj.operator_obj.op_name %]</td>
      </tr>
      <tr>
        [% SET lookup_operation_type = lookup_const('operation_type') %]
        <th>operation type</th>
         <td>[% obj.operation_type %] : [% lookup_operation_type.${ obj.operation_type } %]</td>
      </tr>
      <tr>
        <th>criteria code</th>
        <td>[% obj.criteria_code %]</td>
      </tr>
      <tr>
        <th>attricute dump</th>
        <td>[% obj.attributes_dump %]</td>
      </tr>
      <tr>
        <th>operation memo</th>
        <td>[% obj.operation_memo %]</td>
      </tr>
      <tr>
        <th>created_at</th>
         <td>[% obj.to_localized_datetime('created_at',operator_obj.op_timezone).fmt_datetime %]</td>
      </tr>
  </table>
  
  [% INCLUDE 'footer.inc' %]
---
file: view-op/admin/operation_log/index.tx
template: |
  [% INCLUDE 'header.inc' WITH header = { menu => 'admin', sub_menu => 'operation_log_list' } %]
  
  <form method="get" action="[% c.uri_for('/admin/operation_log/') %]">
  <table class="search">
  
  
  <tr>
  <th>operation log id</th>
  <td><input type="text" name="operation_log_id" /></td>
  </tr>
  
  <tr>
  <th>operator id</th>
  <td><input type="text" name="operator_id" /></td>
  </tr>
  
  <tr>
  <th>opeartion type</th>
  <td>
  [% INCLUDE 'lookup/operation_log.inc' WITH on_empty = 1 %]
  </td>
  </tr>
  
        <tr>
          <th>sort</th>
          <td>
            <select name="sort">
              <option value="operation_log_id">operation_log_id</option>
            </select>
              <select name="direction">
                  <option value="descend">descend</option>
                  <option value="ascend">ascend</option>
              </select>
          </td>
        </tr>
  
  
  
  <tr>
  <td colspan="2"><input type="submit" value="Search" /></td>
  </tr>
  </table>
  </form>
  
  <table class="listing">
  <tr>
    <th>operation log id</th>
    <th>operator</th>
    <th>operator_type</th>
    <th>attributes</th>
    <th>&nbsp;</th>
  </tr>
  [% SET lookup_operation_type = lookup_const('operation_type') %]
  [% FOREACH obj IN objs %]
  <tr>
    <td>[% obj.id %]</td>
    <td> <a href="[% c.uri_for('/admin/operator/' _ obj.operator_id _ '/') %]">[% obj.operator_id %]</a> : [% obj.operator_obj.op_name %]</td>
    <td>[% obj.operation_type %] : [% lookup_operation_type.${obj.operation_type} %]</td>
    <td>[% obj.attributes_dump %]</td>
    <td><a href="[% c.uri_for('/admin/operation_log/' _  obj.id _ '/') %]">detail</a></td>
  </tr>
  [% END %]
  </table>
  
  [% paginate(pager,c.req.uri ) %]
  
  [% INCLUDE 'footer.inc'  %]
---
file: view-op/admin/operator/add.tx
template: |
  [% INCLUDE 'header.inc' WITH header = { menu => 'admin', sub_menu => 'operator_add' } %]
  
  <form method="post" action="[% c.uri_for('/admin/operator/add') %]">
  [% INCLUDE 'admin/operator/form.inc' WITH mode = 'add' %]
  </form>
  
  
  [% INCLUDE 'footer.inc' %]
---
file: view-op/admin/operator/detail.tx
template: |
  [% INCLUDE 'header.inc' WITH header = { menu => 'admin', sub_menu => 'operator_list' } %]
  
  <div>
  operator > detail
  </div>
  
  <table class="detail">
      <tr>
        <th>operator id</th>
         <td>[% obj.id %]</td>
      </tr>
      <tr>
        <th>Email</th>
         <td>[% obj.email %]</td>
      </tr>
      <tr>
        <th>Name</th>
         <td>[% obj.op_name %]</td>
      </tr>
      <tr>
        <th>timezone</th>
         <td>[% obj.op_timezone %]</td>
      </tr>
      <tr>
        <th>language</th>
         <td>[% obj.op_language %]</td>
      </tr>
      <tr>
        <th>active</th>
         <td>[% obj.on_active %]</td>
      </tr>
      <tr>
        <th>access control</th>
        <td>[% FOREACH access_key IN obj.access_keys() ; access_key ; END %]</td>
      </tr>
      <tr>
        <th>created_at</th>
         <td>[% obj.to_localized_datetime('created_at',operator_obj.op_timezone).fmt_datetime %]</td>
      </tr>
  </table>
  
  [% INCLUDE 'footer.inc' %]
---
file: view-op/admin/operator/edit.tx
template: |
  [% INCLUDE 'header.inc' WITH header = { menu => 'admin', sub_menu => 'operator_list' } %]
  
  <div>
  operator > edit
  </div>
  
  <form method="post" action="[% c.uri_for('/admin/operator/' _  obj.id + '/edit') %]">
  [% INCLUDE 'admin/operator/form.inc' WITH mode = 'edit' %]
  </form>
  
  
  [% INCLUDE 'footer.inc' %]
---
file: view-op/admin/operator/form.inc
template: |2
  
    <table class="form">
    [% IF mode  == 'add' %]
      <tr>
        <th>Email</th>
         <td><input type="text" name="email" value=""></td>
      </tr>
      <tr>
        <th>Name</th>
         <td><input type="text" name="op_name" value=""></td>
      </tr>
      <tr>
        <th>Password</th>
         <td><input type="text" name="password" value=""></td>
      </tr>
      <tr>
        <th>timezone</th>
         <td>
         [% INCLUDE 'lookup/op_timezone.inc' %]
         </td>
      </tr>
      <tr>
        <th>language</th>
         <td>
         [% INCLUDE 'lookup/op_language.inc' %]
          </td>
      </tr>
      [% ELSE %]
      <tr>
        <th>Email</th>
         <td>[% obj.email %]</td>
      </tr>
      <tr>
        <th>Name</th>
         <td>[% obj.op_name %]</td>
      </tr>
      <tr>
        <th>timezone</th>
         <td>[% obj.op_timezone %]</td>
      </tr>
      <tr>
        <th>language</th>
         <td>[% obj.op_language %]</td>
      </tr>
      <tr>
        <th>active</th>
         <td>
          [% INCLUDE 'lookup/on_active.inc' %]
         </td>
      </tr>
      [% END %]
      <tr>
        <th>Access Control</th>
         <td>
            [% FOREACH k IN access_keys.keys() %]
              <input type="checkbox" name="op_access_key" value="[% access_keys.${k} %]" />[% access_keys.${k} %]
            [% END %]
         </td>
      </tr>
      <tr>
        <th>Operation Memo</th>
        <td>
          <textarea name="operation_memo"></textarea>
        </td>
      </tr>
      <tr>
        <th align="right" colspan="2"><input type="submit" value="[% IF mode == 'add' %]Add[% ELSE %]Edit[% END %]" /></th>
      </tr>
    </table>
---
file: view-op/admin/operator/index.tx
template: |
  [% INCLUDE 'header.inc' WITH header = { menu => 'admin', sub_menu => 'operator_list' } %]
  
  <form method="get" action="[% c.uri_for('/admin/operator/') %]">
  <table class="search">
  <tr>
  <th>operator id</th>
  <td><input type="text" name="operator_id" /></td>
  </tr>
  <tr>
  <th>active</th>
  <td>
  [% INCLUDE 'lookup/on_active.inc' WITH on_empty = 1 %]
  </td>
  </tr>
  
  </tr>
        <tr>
          <th>sort</th>
          <td>
            <select name="sort">
              <option value="operator_id">operator id</option>
            </select>
              <select name="direction">
                  <option value="descend">descend</option>
                  <option value="ascend">ascend</option>
              </select>
          </td>
        </tr>
  
  
  <tr>
  <td colspan="2"><input type="submit" value="Search" /></td>
  </tr>
  </table>
  </form>
  
  <table class="listing">
  <tr>
    <th>id</th>
    <th>name</th>
    <th>email</th>
    <th>language</th>
    <th>timezone</th>
    <th>access_keys</th>
    <th>on_active</th>
    <th>&nbsp;</th>
  </tr>
  [% FOREACH obj IN objs %]
  <tr>
    <td>[% obj.id %]</td>
    <td>[% obj.op_name %]</td>
    <td>[% obj.email %]</td>
    <td>[% obj.op_language %]</td>
    <td>[% obj.op_timezone %]</td>
    <td>
    [% FOREACH access_key IN obj.access_keys() %]
      [% access_key %]
    [% END %]
    </td>
    <td>[% obj.on_active %]
    <td>
    <a href="[% c.uri_for('/admin/operator/' _  obj.id _ '/') %]">detail</a>/
    <a href="[% c.uri_for('/admin/operator/' _  obj.id _ '/edit') %]">edit</a>/
    <a href="[% c.uri_for('/admin/operation_log/?operator_id=' _ obj.id ) %]">oprator log</a>
  </td>
  </tr>
  [% END %]
  </table>
  
  [% paginate(pager,c.req.uri ) %]
  
  [% INCLUDE 'footer.inc'  %]
---
file: view-op/auth/login.tx
template: |
  [% INCLUDE 'header.inc' %]
  
  
  <h3>LOGIN</h3>
  
  <form method="post" action="[% c.uri_for('/auth/login') %]">
  <table class="form">
  <tr>
    <th>Email</th>
    <td><input type="text" name="email"></td>
  </tr>
  <tr>
    <th>Password</th>
    <td><input type="password" name="password"></td>
  </tr>
  <tr>
    <td colspan="2" align="right"><input type="submit" value="Login"></td>
  </tr>
  </table>
  </form>
  [% INCLUDE 'footer.inc' %]
---
file: view-op/member/index.tx
template: |
  [% INCLUDE 'header.inc' WITH header = { menu => 'member', sub_menu => 'list' } %]
  
  member list
  
  [% INCLUDE 'footer.inc'  %]
---
file: view-op/my/operator/edit.tx
template: |
  [% INCLUDE 'header.inc' WITH header = { menu => 'my', sub_menu => 'operator_edit' } %]
  
  
  <form method="post" action="[% c.uri_for('/my/operator/edit') %]">
  <table class="form">
      <tr>
        <th>Email</th>
         <td>[% operator_obj.email %]</td>
      </tr>
      <tr>
        <th>Name</th>
         <td><input type="text" name="op_name" value=""></td>
      </tr>
      <tr>
        <th>timezone</th>
         <td>
         [% INCLUDE 'lookup/op_timezone.inc' %]
         </td>
      </tr>
      <tr>
        <th>language</th>
         <td>
         [% INCLUDE 'lookup/op_language.inc' %]
          </td>
      </tr>
      <tr>
        <td align="right" colspan="2"><input type="submit" value="Edit" /></td>
      </tr>
  </table>
  </form>
  
  
  [% INCLUDE 'footer.inc' %]
---
file: view-op/my/operator/edit_password.tx
template: |
  [% INCLUDE 'header.inc' WITH header = { menu => 'my', sub_menu => 'operator_edit_password' } %]
  
  <form method="post" action="[% c.uri_for('/my/operator/edit_password') %]">
  <table class="form">
      <tr>
        <th>password</th>
         <td><input type="password" name="password" /></td>
      </tr>
      <tr>
        <th>confirm password</th>
         <td><input type="password" name="confirm_password" /></td>
      </tr>
      <tr>
        <td colspan="2" align="right"><input type="submit" value="Edit" /></td>
      </tr>
  </table>
  </form>
  
  
  [% INCLUDE 'footer.inc' %]
---
file: view-op/my/operator/index.tx
template: |
  [% INCLUDE 'header.inc' WITH header = { menu => 'my', sub_menu => 'operator' } %]
  
  
  <table class="detail">
      <tr>
        <th>Email</th>
         <td>[% operator_obj.email %]</td>
      </tr>
      <tr>
        <th>Name</th>
         <td>[% operator_obj.op_name %]</td>
      </tr>
      <tr>
        <th>timezone</th>
         <td>[% operator_obj.op_timezone %]</td>
      </tr>
      <tr>
        <th>language</th>
         <td>[% operator_obj.op_language %]</td>
      </tr>
      <tr>
        <th>Access Control</th>
         <td>
            [% FOREACH k IN operator_obj.access_keys() ; k ; END %]
         </td>
      </tr>
  </table>
  
  
  [% INCLUDE 'footer.inc' %]
---
plugin: API.pm
template: |+
  package Ze::_::Helper::API;
  use strict;
  use warnings;
  use base 'Module::Setup::Plugin';
  
  use Template;
  my $TEMPLATE;
  
  
  sub register {
      my ( $self, ) = @_;
  
      $TEMPLATE = Template->new({
             START_TAG => quotemeta('<+'),
            END_TAG   => quotemeta('+>'),
        });
      $self->add_trigger( template_process => \&template_process );
  
      $self->add_trigger( 'after_setup_template_vars' => \&after_setup_template_vars );
  
  
  }
  
  sub template_process {
      my($self, $opts) = @_;
      return unless $opts->{template};
      my $template = delete $opts->{template};;
      $TEMPLATE->process(\$template, $opts->{vars}, \my $content);
      $opts->{content} = $content;
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
  class: Ze::Helper::API
  module_setup_flavor_devel: 1
  plugins:
    - Config::Basic
    - Additional
    - VC::Git
    - +Ze::_::Helper::API


