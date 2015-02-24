
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
file: .proverc
template: |
  "--exec=perl -Ilib -It/lib -I. -Mt::Util"
  --color
  -Pt::lib::App::Prove::Plugin::SchemaUpdater
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
file: Makefile.PL
template: |
  use inc::Module::Install;
  name '<+ dist +>';
  all_from 'lib/<+ dist +>.pm';
  
  requires (
    "Ze" => 0.04,
    "Aplon" => 0,
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
file: Changes
is_binary: 1
template: ''
---
file: po/op/ja_JP.po
template: |
  msgid ""
  msgstr ""
  
  #: view-include/op/header.inc:15
  msgid "Operation System"
  msgstr "運用システム"
---
file: view-component/sp/sample/echo.tx
template: "sp name [% name %]\n"
---
file: view-component/pc/sample/echo.tx
template: "pc name [% name %]\n"
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
          <input type="text" name="path" value="/app/info" id="path" />
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
file: htdocs-explorer/static/css/base.css
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
file: htdocs-explorer/static/css/normalize.css
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
file: htdocs-explorer/static/common/js/jquery.ze.js
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
file: htdocs-explorer/static/common/js/jquery.cookie.js
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
file: view-op/index.tx
template: |
  [% INCLUDE 'header.inc' WITH header = { menu => 'top', sub_menu => 'top' } %]
  top
  [% INCLUDE 'footer.inc' %]
---
file: view-op/auth/login.tx
template: |
  [% INCLUDE 'header.inc' %]
  
  
  <h3>LOGIN</h3>
  
  <form method="post" action="/auth/login">
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
  
  
  <form method="post" action="/my/operator/edit">
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
file: view-op/my/operator/edit_password.tx
template: |
  [% INCLUDE 'header.inc' WITH header = { menu => 'my', sub_menu => 'operator_edit_password' } %]
  
  <form method="post" action="/my/operator/edit_password">
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
         <td><a href="/admin/operator/[% obj.operator_id %]/">[% obj.operator_id %]</a> : [% obj.operator_obj.op_name %]</td>
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
  
  <form method="get" action="/admin/operation_log/">
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
    <td> <a href="/admin/operator/[% obj.operator_id %]/">[% obj.operator_id %]</a> : [% obj.operator_obj.op_name %]</td>
    <td>[% obj.operation_type %] : [% lookup_operation_type.${obj.operation_type} %]</td>
    <td>[% obj.attributes_dump %]</td>
    <td><a href="/admin/operation_log/[% obj.id %]/">detail</a></td>
  </tr>
  [% END %]
  </table>
  
  [% paginate(pager,c.req.uri ) %]
  
  [% INCLUDE 'footer.inc'  %]
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
file: view-op/admin/operator/add.tx
template: |
  [% INCLUDE 'header.inc' WITH header = { menu => 'admin', sub_menu => 'operator_add' } %]
  
  <form method="post" action="/admin/operator/add">
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
  
  <form method="post" action="/admin/operator/[% obj.id %]/edit">
  [% INCLUDE 'admin/operator/form.inc' WITH mode = 'edit' %]
  </form>
  
  
  [% INCLUDE 'footer.inc' %]
---
file: view-op/admin/operator/index.tx
template: |
  [% INCLUDE 'header.inc' WITH header = { menu => 'admin', sub_menu => 'operator_list' } %]
  
  <form method="get" action="/admin/operator/">
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
    <a href="/admin/operator/[% obj.id %]/">detail</a>/
    <a href="/admin/operator/[% obj.id %]/edit">edit</a>/
    <a href="/admin/operation_log/?operator_id=[% obj.id %]">oprator log</a>
  </td>
  </tr>
  [% END %]
  </table>
  
  [% paginate(pager,c.req.uri ) %]
  
  [% INCLUDE 'footer.inc'  %]
---
file: lib/____var-dist-var____.pm
template: |
  package <+ dist +>;
  use strict;
  use warnings;
  
  our $VERSION = "0.0.1";
  
  
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
file: lib/____var-dist-var____/Explorer/Context.pm
template: |
  package <+ dist +>::Explorer::Context;
  use Ze::Class;
  extends '<+ dist +>::WAF::Context';
  
  
  __PACKAGE__->load_plugins(qw(
      Ze::WAF::Plugin::Encode
      Ze::WAF::Plugin::FillInForm
      Ze::WAF::Plugin::JSON
      ));
  
  
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
file: lib/____var-dist-var____X/Home.pm
template: |
  package <+ dist +>X::Home;
  use parent 'Ze::Home';
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
file: lib/____var-dist-var____X/Setting.pm
template: |
  package <+ dist +>X::Setting;
  use strict;
  use warnings;
  use parent '<+ dist +>X::Overwrite::Setting';
  
  
  
  1;
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
dir: etc
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
file: t/WAF-Controller.t
template: |
  use Test::More;
  
  use_ok('<+ dist +>::WAF::Controller');
  
  done_testing();
---
file: t/Pager.t
template: |
  use Test::More;
  
  use_ok('<+ dist +>::Pager');
  
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
file: t/Validator-Error.t
template: |
  use Test::More;
  
  use_ok('<+ dist +>::Validator::Error');
  
  
  my $error = <+ dist +>::Validator::Error->new();
  is("<+ dist +>::Validator::Error","$error","overload ok");
  
  
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
file: t/WAF-Dispatcher.t
template: |
  use Test::More;
  
  use_ok('<+ dist +>::WAF::Dispatcher');
  
  done_testing();
---
file: t/API-View.t
template: |
  use Test::More;
  
  use_ok('<+ dist +>::API::View');
  
  done_testing();
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
file: t/Data-OperationLog.t
template: |
  use Test::More;
  use t::Util;
  
  cleanup_database();
  
  use_ok('<+ dist +>::Data::OperationLog');
  
  
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
file: t/API.t
template: |
  use Test::More;
  
  use_ok( '<+ dist +>::API');
  
  done_testing();
---
file: t/WAF-Context.t
template: |
  use Test::More;
  
  use_ok('<+ dist +>::WAF::Context');
  
  done_testing();
---
file: t/Validator-Result.t
template: |
  use Test::More;
  
  
  use_ok("<+ dist +>::Validator::Result");
  
  
  done_testing();
---
file: t/OP-I18N.t
template: |
  use Test::More;
  
  use_ok('<+ dist +>::OP::I18N');
  
  my $i18n = <+ dist +>::OP::I18N->get_handle('en_US');
  
  
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
file: t/Validator-Rule.t
template: |
  use Test::More;
  
  use_ok('<+ dist +>::Validator::Rule');
  
  done_testing();
---
file: t/API-Context.t
template: |
  use Test::More;
  
  use_ok("<+ dist +>::API::Context");
  
  
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
file: t/root/config/config.pl
template: |
  {
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
file: t/X/Setting.t
template: |
  use Test::More;
  
  use_ok('<+ dist +>X::Setting');
  
  ok(<+ dist +>X::Setting->DEFAULT_LANGUAGE());
  
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
file: htdocs-op/static/css/base.css
template: |
  /*! HTML5 Boilerplate v4.3.0 | MIT License | http://h5bp.com/ */
  
  /*
   * What follows is the result of much research on cross-browser styling.
   * Credit left inline and big thanks to Nicolas Gallagher, Jonathan Neal,
   * Kroc Camen, and the H5BP dev community and team.
   */
  
  /* ==========================================================================
     Base styles: opinionated defaults
     ========================================================================== */
  
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
   * Remove text-shadow in selection highlight: h5bp.com/i
   * These selection rule sets have to be separate.
   * Customize the background color to match your design.
   */
  
  ::-moz-selection {
  	background: #b3d4fc;
  	text-shadow: none;
  }
  
  ::selection {
  	background: #b3d4fc;
  	text-shadow: none;
  }
  
  /*
   * A better looking default horizontal rule
   */
  
  hr {
  	display: block;
  	height: 1px;
  	border: 0;
  	border-top: 1px solid #ccc;
  	margin: 1em 0;
  	padding: 0;
  }
  
  /*
   * Remove the gap between images, videos, audio and canvas and the bottom of
   * their containers: h5bp.com/i/440
   */
  
  audio,
  canvas,
  img,
  video {
  	vertical-align: middle;
  }
  
  /*
   * Remove default fieldset styles.
   */
  
  fieldset {
  	border: 0;
  	margin: 0;
  	padding: 0;
  }
  
  /*
   * Allow only vertical resizing of textareas.
   */
  
  textarea {
  	resize: vertical;
  }
  
  /* ==========================================================================
     Browse Happy prompt
     ========================================================================== */
  
  .browsehappy {
  	margin: 0.2em 0;
  	background: #ccc;
  	color: #000;
  	padding: 0.2em 0;
  }
  
  /* ==========================================================================
     Author's custom styles
     ========================================================================== */
  
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
  
  
  
  
  
  
  
  
  /* ==========================================================================
     Helper classes
     ========================================================================== */
  
  /*
   * Image replacement
   */
  
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
   * Hide from both screenreaders and browsers: h5bp.com/u
   */
  
  .hidden {
  	display: none !important;
  	visibility: hidden;
  }
  
  /*
   * Hide only visually, but have it available for screenreaders: h5bp.com/v
   */
  
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
   * Extends the .visuallyhidden class to allow the element to be focusable
   * when navigated to via the keyboard: h5bp.com/p
   */
  
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
   * Hide visually and from screenreaders, but maintain layout
   */
  
  .invisible {
  	visibility: hidden;
  }
  
  /*
   * Clearfix: contain floats
   *
   * For modern browsers
   * 1. The space content is one way to avoid an Opera bug when the
   *    `contenteditable` attribute is included anywhere else in the document.
   *    Otherwise it causes space to appear at the top and bottom of elements
   *    that receive the `clearfix` class.
   * 2. The use of `table` rather than `block` is only necessary if using
   *    `:before` to contain the top-margins of child elements.
   */
  
  .clearfix:before,
  .clearfix:after {
  	content: " "; /* 1 */
  	display: table; /* 2 */
  }
  
  .clearfix:after {
  	clear: both;
  }
  
  /*
   * For IE 6/7 only
   * Include this rule to trigger hasLayout and contain floats.
   */
  
  .clearfix {
  	*zoom: 1;
  }
  
  /* ==========================================================================
     EXAMPLE Media Queries for Responsive Design.
     These examples override the primary ('mobile first') styles.
     Modify as content requires.
     ========================================================================== */
  
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
     Print styles.
     Inlined to avoid required HTTP connection: h5bp.com/r
     ========================================================================== */
  
  @media print {
  	* {
  		background: transparent !important;
  		color: #000 !important; /* Black prints faster: h5bp.com/s */
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
  	 * Don't show links for images, or javascript/internal links
  	 */
  
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
file: htdocs-op/static/css/normalize.css
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
file: misc/asset-sample/data/i18n/card/ja_JP.json
template: |
  {
    "1.name" : "武士にゃん"
  }
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
file: misc/asset-sample/config/config_tteranishi.pl
template: |
  {
    database => {
        master => {
            dsn => "dbi:mysql:<+ dist | lower +>_tteranishi",
            username => "dev_master",
            password => "",
        },
        slaves => [
            {
                dsn => "dbi:mysql:<+ dist | lower +>_tteranishi",
                username => "dev_slave",
                password => "",
            }
        ],
    },
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
    <li>[% IF i.0 == header.menu %]<b>[% i.1 %]</b>[% ELSE %]<a class="menu-[% i.0 %]" href="[% i.2 %]">[% i.1 %]</a>[% END %]</li>
  [% END %]
  </ul>
  
  [% SET sub_menus = SUB_MENU.${header.menu} %]
  <ul id="sub_menu">
  [% FOREACH i IN sub_menus %]
   <li>[% IF i.0 == header.sub_menu %]<b>[% i.1 %]</b>[% ELSE %]<a class="menu-[% i.0 %]" href="[% i.2 %]">[% i.1 %]</a>[% END %]</li>
  [% END %]
  </ul>
  </div>

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
  <a href="/auth/logout">logout</a>
  </div>
  [% INCLUDE 'menu.inc' %]
  [% END %]
  
  [% INCLUDE 'error.inc' %]
---
file: view-include/op/footer.inc
template: "\n</body>\n</html>\n"
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
file: view-include/op/lookup/on_active.inc
template: |
  <select name="on_active">
    [% IF on_empty %]<option value="">-</option>[% END %]
    <option value="0">disable</option>
    <option value="1">active</option>
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
file: view-include/op/lookup/op_timezone.inc
template: |
  <select name="op_timezone">
  [% IF on_empty %]<option value="">-</option>[% END %]
  [% FOREACH op_timezone IN support_op_timezones %]
  <option value="[% op_timezone %]">[% op_timezone %]</option>
  [% END %]
  </select>
---
file: view-include/component/sp/sample/echo.inc
template: "sp name sample\n"
---
file: view-include/component/pc/sample/echo.inc
template: "pc name sample\n"
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
dir: inc/.author
---
file: inc/Test/More.pm
template: |
  #line 1
  package Test::More;
  
  use 5.006;
  use strict;
  use warnings;
  
  #---- perlcritic exemptions. ----#
  
  # We use a lot of subroutine prototypes
  ## no critic (Subroutines::ProhibitSubroutinePrototypes)
  
  # Can't use Carp because it might cause use_ok() to accidentally succeed
  # even though the module being used forgot to use Carp.  Yes, this
  # actually happened.
  sub _carp {
      my( $file, $line ) = ( caller(1) )[ 1, 2 ];
      return warn @_, " at $file line $line\n";
  }
  
  our $VERSION = '1.001002';
  $VERSION = eval $VERSION;    ## no critic (BuiltinFunctions::ProhibitStringyEval)
  
  use Test::Builder::Module 0.99;
  our @ISA    = qw(Test::Builder::Module);
  our @EXPORT = qw(ok use_ok require_ok
    is isnt like unlike is_deeply
    cmp_ok
    skip todo todo_skip
    pass fail
    eq_array eq_hash eq_set
    $TODO
    plan
    done_testing
    can_ok isa_ok new_ok
    diag note explain
    subtest
    BAIL_OUT
  );
  
  #line 163
  
  sub plan {
      my $tb = Test::More->builder;
  
      return $tb->plan(@_);
  }
  
  # This implements "use Test::More 'no_diag'" but the behavior is
  # deprecated.
  sub import_extra {
      my $class = shift;
      my $list  = shift;
  
      my @other = ();
      my $idx   = 0;
      while( $idx <= $#{$list} ) {
          my $item = $list->[$idx];
  
          if( defined $item and $item eq 'no_diag' ) {
              $class->builder->no_diag(1);
          }
          else {
              push @other, $item;
          }
  
          $idx++;
      }
  
      @$list = @other;
  
      return;
  }
  
  #line 216
  
  sub done_testing {
      my $tb = Test::More->builder;
      $tb->done_testing(@_);
  }
  
  #line 288
  
  sub ok ($;$) {
      my( $test, $name ) = @_;
      my $tb = Test::More->builder;
  
      return $tb->ok( $test, $name );
  }
  
  #line 371
  
  sub is ($$;$) {
      my $tb = Test::More->builder;
  
      return $tb->is_eq(@_);
  }
  
  sub isnt ($$;$) {
      my $tb = Test::More->builder;
  
      return $tb->isnt_eq(@_);
  }
  
  *isn't = \&isnt;
  
  #line 415
  
  sub like ($$;$) {
      my $tb = Test::More->builder;
  
      return $tb->like(@_);
  }
  
  #line 430
  
  sub unlike ($$;$) {
      my $tb = Test::More->builder;
  
      return $tb->unlike(@_);
  }
  
  #line 476
  
  sub cmp_ok($$$;$) {
      my $tb = Test::More->builder;
  
      return $tb->cmp_ok(@_);
  }
  
  #line 511
  
  sub can_ok ($@) {
      my( $proto, @methods ) = @_;
      my $class = ref $proto || $proto;
      my $tb = Test::More->builder;
  
      unless($class) {
          my $ok = $tb->ok( 0, "->can(...)" );
          $tb->diag('    can_ok() called with empty class or reference');
          return $ok;
      }
  
      unless(@methods) {
          my $ok = $tb->ok( 0, "$class->can(...)" );
          $tb->diag('    can_ok() called with no methods');
          return $ok;
      }
  
      my @nok = ();
      foreach my $method (@methods) {
          $tb->_try( sub { $proto->can($method) } ) or push @nok, $method;
      }
  
      my $name = (@methods == 1) ? "$class->can('$methods[0]')" :
                                   "$class->can(...)"           ;
  
      my $ok = $tb->ok( !@nok, $name );
  
      $tb->diag( map "    $class->can('$_') failed\n", @nok );
  
      return $ok;
  }
  
  #line 577
  
  sub isa_ok ($$;$) {
      my( $thing, $class, $thing_name ) = @_;
      my $tb = Test::More->builder;
  
      my $whatami;
      if( !defined $thing ) {
          $whatami = 'undef';
      }
      elsif( ref $thing ) {
          $whatami = 'reference';
  
          local($@,$!);
          require Scalar::Util;
          if( Scalar::Util::blessed($thing) ) {
              $whatami = 'object';
          }
      }
      else {
          $whatami = 'class';
      }
  
      # We can't use UNIVERSAL::isa because we want to honor isa() overrides
      my( $rslt, $error ) = $tb->_try( sub { $thing->isa($class) } );
  
      if($error) {
          die <<WHOA unless $error =~ /^Can't (locate|call) method "isa"/;
  WHOA! I tried to call ->isa on your $whatami and got some weird error.
  Here's the error.
  $error
  WHOA
      }
  
      # Special case for isa_ok( [], "ARRAY" ) and like
      if( $whatami eq 'reference' ) {
          $rslt = UNIVERSAL::isa($thing, $class);
      }
  
      my($diag, $name);
      if( defined $thing_name ) {
          $name = "'$thing_name' isa '$class'";
          $diag = defined $thing ? "'$thing_name' isn't a '$class'" : "'$thing_name' isn't defined";
      }
      elsif( $whatami eq 'object' ) {
          my $my_class = ref $thing;
          $thing_name = qq[An object of class '$my_class'];
          $name = "$thing_name isa '$class'";
          $diag = "The object of class '$my_class' isn't a '$class'";
      }
      elsif( $whatami eq 'reference' ) {
          my $type = ref $thing;
          $thing_name = qq[A reference of type '$type'];
          $name = "$thing_name isa '$class'";
          $diag = "The reference of type '$type' isn't a '$class'";
      }
      elsif( $whatami eq 'undef' ) {
          $thing_name = 'undef';
          $name = "$thing_name isa '$class'";
          $diag = "$thing_name isn't defined";
      }
      elsif( $whatami eq 'class' ) {
          $thing_name = qq[The class (or class-like) '$thing'];
          $name = "$thing_name isa '$class'";
          $diag = "$thing_name isn't a '$class'";
      }
      else {
          die;
      }
  
      my $ok;
      if($rslt) {
          $ok = $tb->ok( 1, $name );
      }
      else {
          $ok = $tb->ok( 0, $name );
          $tb->diag("    $diag\n");
      }
  
      return $ok;
  }
  
  #line 678
  
  sub new_ok {
      my $tb = Test::More->builder;
      $tb->croak("new_ok() must be given at least a class") unless @_;
  
      my( $class, $args, $object_name ) = @_;
  
      $args ||= [];
  
      my $obj;
      my( $success, $error ) = $tb->_try( sub { $obj = $class->new(@$args); 1 } );
      if($success) {
          local $Test::Builder::Level = $Test::Builder::Level + 1;
          isa_ok $obj, $class, $object_name;
      }
      else {
          $class = 'undef' if !defined $class;
          $tb->ok( 0, "$class->new() died" );
          $tb->diag("    Error was:  $error");
      }
  
      return $obj;
  }
  
  #line 764
  
  sub subtest {
      my ($name, $subtests) = @_;
  
      my $tb = Test::More->builder;
      return $tb->subtest(@_);
  }
  
  #line 788
  
  sub pass (;$) {
      my $tb = Test::More->builder;
  
      return $tb->ok( 1, @_ );
  }
  
  sub fail (;$) {
      my $tb = Test::More->builder;
  
      return $tb->ok( 0, @_ );
  }
  
  #line 841
  
  sub require_ok ($) {
      my($module) = shift;
      my $tb = Test::More->builder;
  
      my $pack = caller;
  
      # Try to determine if we've been given a module name or file.
      # Module names must be barewords, files not.
      $module = qq['$module'] unless _is_module_name($module);
  
      my $code = <<REQUIRE;
  package $pack;
  require $module;
  1;
  REQUIRE
  
      my( $eval_result, $eval_error ) = _eval($code);
      my $ok = $tb->ok( $eval_result, "require $module;" );
  
      unless($ok) {
          chomp $eval_error;
          $tb->diag(<<DIAGNOSTIC);
      Tried to require '$module'.
      Error:  $eval_error
  DIAGNOSTIC
  
      }
  
      return $ok;
  }
  
  sub _is_module_name {
      my $module = shift;
  
      # Module names start with a letter.
      # End with an alphanumeric.
      # The rest is an alphanumeric or ::
      $module =~ s/\b::\b//g;
  
      return $module =~ /^[a-zA-Z]\w*$/ ? 1 : 0;
  }
  
  
  #line 935
  
  sub use_ok ($;@) {
      my( $module, @imports ) = @_;
      @imports = () unless @imports;
      my $tb = Test::More->builder;
  
      my( $pack, $filename, $line ) = caller;
      $filename =~ y/\n\r/_/; # so it doesn't run off the "#line $line $f" line
  
      my $code;
      if( @imports == 1 and $imports[0] =~ /^\d+(?:\.\d+)?$/ ) {
          # probably a version check.  Perl needs to see the bare number
          # for it to work with non-Exporter based modules.
          $code = <<USE;
  package $pack;
  
  #line $line $filename
  use $module $imports[0];
  1;
  USE
      }
      else {
          $code = <<USE;
  package $pack;
  
  #line $line $filename
  use $module \@{\$args[0]};
  1;
  USE
      }
  
      my( $eval_result, $eval_error ) = _eval( $code, \@imports );
      my $ok = $tb->ok( $eval_result, "use $module;" );
  
      unless($ok) {
          chomp $eval_error;
          $@ =~ s{^BEGIN failed--compilation aborted at .*$}
                  {BEGIN failed--compilation aborted at $filename line $line.}m;
          $tb->diag(<<DIAGNOSTIC);
      Tried to use '$module'.
      Error:  $eval_error
  DIAGNOSTIC
  
      }
  
      return $ok;
  }
  
  sub _eval {
      my( $code, @args ) = @_;
  
      # Work around oddities surrounding resetting of $@ by immediately
      # storing it.
      my( $sigdie, $eval_result, $eval_error );
      {
          local( $@, $!, $SIG{__DIE__} );    # isolate eval
          $eval_result = eval $code;              ## no critic (BuiltinFunctions::ProhibitStringyEval)
          $eval_error  = $@;
          $sigdie      = $SIG{__DIE__} || undef;
      }
      # make sure that $code got a chance to set $SIG{__DIE__}
      $SIG{__DIE__} = $sigdie if defined $sigdie;
  
      return( $eval_result, $eval_error );
  }
  
  
  #line 1036
  
  our( @Data_Stack, %Refs_Seen );
  my $DNE = bless [], 'Does::Not::Exist';
  
  sub _dne {
      return ref $_[0] eq ref $DNE;
  }
  
  ## no critic (Subroutines::RequireArgUnpacking)
  sub is_deeply {
      my $tb = Test::More->builder;
  
      unless( @_ == 2 or @_ == 3 ) {
          my $msg = <<'WARNING';
  is_deeply() takes two or three args, you gave %d.
  This usually means you passed an array or hash instead 
  of a reference to it
  WARNING
          chop $msg;    # clip off newline so carp() will put in line/file
  
          _carp sprintf $msg, scalar @_;
  
          return $tb->ok(0);
      }
  
      my( $got, $expected, $name ) = @_;
  
      $tb->_unoverload_str( \$expected, \$got );
  
      my $ok;
      if( !ref $got and !ref $expected ) {    # neither is a reference
          $ok = $tb->is_eq( $got, $expected, $name );
      }
      elsif( !ref $got xor !ref $expected ) {    # one's a reference, one isn't
          $ok = $tb->ok( 0, $name );
          $tb->diag( _format_stack({ vals => [ $got, $expected ] }) );
      }
      else {                                     # both references
          local @Data_Stack = ();
          if( _deep_check( $got, $expected ) ) {
              $ok = $tb->ok( 1, $name );
          }
          else {
              $ok = $tb->ok( 0, $name );
              $tb->diag( _format_stack(@Data_Stack) );
          }
      }
  
      return $ok;
  }
  
  sub _format_stack {
      my(@Stack) = @_;
  
      my $var       = '$FOO';
      my $did_arrow = 0;
      foreach my $entry (@Stack) {
          my $type = $entry->{type} || '';
          my $idx = $entry->{'idx'};
          if( $type eq 'HASH' ) {
              $var .= "->" unless $did_arrow++;
              $var .= "{$idx}";
          }
          elsif( $type eq 'ARRAY' ) {
              $var .= "->" unless $did_arrow++;
              $var .= "[$idx]";
          }
          elsif( $type eq 'REF' ) {
              $var = "\${$var}";
          }
      }
  
      my @vals = @{ $Stack[-1]{vals} }[ 0, 1 ];
      my @vars = ();
      ( $vars[0] = $var ) =~ s/\$FOO/     \$got/;
      ( $vars[1] = $var ) =~ s/\$FOO/\$expected/;
  
      my $out = "Structures begin differing at:\n";
      foreach my $idx ( 0 .. $#vals ) {
          my $val = $vals[$idx];
          $vals[$idx]
            = !defined $val ? 'undef'
            : _dne($val)    ? "Does not exist"
            : ref $val      ? "$val"
            :                 "'$val'";
      }
  
      $out .= "$vars[0] = $vals[0]\n";
      $out .= "$vars[1] = $vals[1]\n";
  
      $out =~ s/^/    /msg;
      return $out;
  }
  
  sub _type {
      my $thing = shift;
  
      return '' if !ref $thing;
  
      for my $type (qw(Regexp ARRAY HASH REF SCALAR GLOB CODE)) {
          return $type if UNIVERSAL::isa( $thing, $type );
      }
  
      return '';
  }
  
  #line 1196
  
  sub diag {
      return Test::More->builder->diag(@_);
  }
  
  sub note {
      return Test::More->builder->note(@_);
  }
  
  #line 1222
  
  sub explain {
      return Test::More->builder->explain(@_);
  }
  
  #line 1288
  
  ## no critic (Subroutines::RequireFinalReturn)
  sub skip {
      my( $why, $how_many ) = @_;
      my $tb = Test::More->builder;
  
      unless( defined $how_many ) {
          # $how_many can only be avoided when no_plan is in use.
          _carp "skip() needs to know \$how_many tests are in the block"
            unless $tb->has_plan eq 'no_plan';
          $how_many = 1;
      }
  
      if( defined $how_many and $how_many =~ /\D/ ) {
          _carp
            "skip() was passed a non-numeric number of tests.  Did you get the arguments backwards?";
          $how_many = 1;
      }
  
      for( 1 .. $how_many ) {
          $tb->skip($why);
      }
  
      no warnings 'exiting';
      last SKIP;
  }
  
  #line 1372
  
  sub todo_skip {
      my( $why, $how_many ) = @_;
      my $tb = Test::More->builder;
  
      unless( defined $how_many ) {
          # $how_many can only be avoided when no_plan is in use.
          _carp "todo_skip() needs to know \$how_many tests are in the block"
            unless $tb->has_plan eq 'no_plan';
          $how_many = 1;
      }
  
      for( 1 .. $how_many ) {
          $tb->todo_skip($why);
      }
  
      no warnings 'exiting';
      last TODO;
  }
  
  #line 1427
  
  sub BAIL_OUT {
      my $reason = shift;
      my $tb     = Test::More->builder;
  
      $tb->BAIL_OUT($reason);
  }
  
  #line 1466
  
  #'#
  sub eq_array {
      local @Data_Stack = ();
      _deep_check(@_);
  }
  
  sub _eq_array {
      my( $a1, $a2 ) = @_;
  
      if( grep _type($_) ne 'ARRAY', $a1, $a2 ) {
          warn "eq_array passed a non-array ref";
          return 0;
      }
  
      return 1 if $a1 eq $a2;
  
      my $ok = 1;
      my $max = $#$a1 > $#$a2 ? $#$a1 : $#$a2;
      for( 0 .. $max ) {
          my $e1 = $_ > $#$a1 ? $DNE : $a1->[$_];
          my $e2 = $_ > $#$a2 ? $DNE : $a2->[$_];
  
          next if _equal_nonrefs($e1, $e2);
  
          push @Data_Stack, { type => 'ARRAY', idx => $_, vals => [ $e1, $e2 ] };
          $ok = _deep_check( $e1, $e2 );
          pop @Data_Stack if $ok;
  
          last unless $ok;
      }
  
      return $ok;
  }
  
  sub _equal_nonrefs {
      my( $e1, $e2 ) = @_;
  
      return if ref $e1 or ref $e2;
  
      if ( defined $e1 ) {
          return 1 if defined $e2 and $e1 eq $e2;
      }
      else {
          return 1 if !defined $e2;
      }
  
      return;
  }
  
  sub _deep_check {
      my( $e1, $e2 ) = @_;
      my $tb = Test::More->builder;
  
      my $ok = 0;
  
      # Effectively turn %Refs_Seen into a stack.  This avoids picking up
      # the same referenced used twice (such as [\$a, \$a]) to be considered
      # circular.
      local %Refs_Seen = %Refs_Seen;
  
      {
          $tb->_unoverload_str( \$e1, \$e2 );
  
          # Either they're both references or both not.
          my $same_ref = !( !ref $e1 xor !ref $e2 );
          my $not_ref = ( !ref $e1 and !ref $e2 );
  
          if( defined $e1 xor defined $e2 ) {
              $ok = 0;
          }
          elsif( !defined $e1 and !defined $e2 ) {
              # Shortcut if they're both undefined.
              $ok = 1;
          }
          elsif( _dne($e1) xor _dne($e2) ) {
              $ok = 0;
          }
          elsif( $same_ref and( $e1 eq $e2 ) ) {
              $ok = 1;
          }
          elsif($not_ref) {
              push @Data_Stack, { type => '', vals => [ $e1, $e2 ] };
              $ok = 0;
          }
          else {
              if( $Refs_Seen{$e1} ) {
                  return $Refs_Seen{$e1} eq $e2;
              }
              else {
                  $Refs_Seen{$e1} = "$e2";
              }
  
              my $type = _type($e1);
              $type = 'DIFFERENT' unless _type($e2) eq $type;
  
              if( $type eq 'DIFFERENT' ) {
                  push @Data_Stack, { type => $type, vals => [ $e1, $e2 ] };
                  $ok = 0;
              }
              elsif( $type eq 'ARRAY' ) {
                  $ok = _eq_array( $e1, $e2 );
              }
              elsif( $type eq 'HASH' ) {
                  $ok = _eq_hash( $e1, $e2 );
              }
              elsif( $type eq 'REF' ) {
                  push @Data_Stack, { type => $type, vals => [ $e1, $e2 ] };
                  $ok = _deep_check( $$e1, $$e2 );
                  pop @Data_Stack if $ok;
              }
              elsif( $type eq 'SCALAR' ) {
                  push @Data_Stack, { type => 'REF', vals => [ $e1, $e2 ] };
                  $ok = _deep_check( $$e1, $$e2 );
                  pop @Data_Stack if $ok;
              }
              elsif($type) {
                  push @Data_Stack, { type => $type, vals => [ $e1, $e2 ] };
                  $ok = 0;
              }
              else {
                  _whoa( 1, "No type in _deep_check" );
              }
          }
      }
  
      return $ok;
  }
  
  sub _whoa {
      my( $check, $desc ) = @_;
      if($check) {
          die <<"WHOA";
  WHOA!  $desc
  This should never happen!  Please contact the author immediately!
  WHOA
      }
  }
  
  #line 1613
  
  sub eq_hash {
      local @Data_Stack = ();
      return _deep_check(@_);
  }
  
  sub _eq_hash {
      my( $a1, $a2 ) = @_;
  
      if( grep _type($_) ne 'HASH', $a1, $a2 ) {
          warn "eq_hash passed a non-hash ref";
          return 0;
      }
  
      return 1 if $a1 eq $a2;
  
      my $ok = 1;
      my $bigger = keys %$a1 > keys %$a2 ? $a1 : $a2;
      foreach my $k ( keys %$bigger ) {
          my $e1 = exists $a1->{$k} ? $a1->{$k} : $DNE;
          my $e2 = exists $a2->{$k} ? $a2->{$k} : $DNE;
  
          next if _equal_nonrefs($e1, $e2);
  
          push @Data_Stack, { type => 'HASH', idx => $k, vals => [ $e1, $e2 ] };
          $ok = _deep_check( $e1, $e2 );
          pop @Data_Stack if $ok;
  
          last unless $ok;
      }
  
      return $ok;
  }
  
  #line 1672
  
  sub eq_set {
      my( $a1, $a2 ) = @_;
      return 0 unless @$a1 == @$a2;
  
      no warnings 'uninitialized';
  
      # It really doesn't matter how we sort them, as long as both arrays are
      # sorted with the same algorithm.
      #
      # Ensure that references are not accidentally treated the same as a
      # string containing the reference.
      #
      # Have to inline the sort routine due to a threading/sort bug.
      # See [rt.cpan.org 6782]
      #
      # I don't know how references would be sorted so we just don't sort
      # them.  This means eq_set doesn't really work with refs.
      return eq_array(
          [ grep( ref, @$a1 ), sort( grep( !ref, @$a1 ) ) ],
          [ grep( ref, @$a2 ), sort( grep( !ref, @$a2 ) ) ],
      );
  }
  
  #line 1911
  
  1;
---
file: inc/Test/LoadAllModules.pm
template: |
  #line 1
  package Test::LoadAllModules;
  use strict;
  use warnings;
  use Module::Pluggable::Object;
  use List::MoreUtils qw(any);
  use Test::More ();
  
  our $VERSION = '0.022';
  
  use Exporter;
  our @ISA    = qw/Exporter/;
  our @EXPORT = qw/all_uses_ok/;
  
  sub all_uses_ok {
      my %param       = @_;
      my $search_path = $param{search_path};
      unless ($search_path) {
          Test::More::plan skip_all => 'no search path';
          exit;
      }
      Test::More::plan('no_plan');
      my @exceptions = @{ $param{except} || [] };
      my @lib
          = @{ $param{lib} || [ 'lib' ] };
      foreach my $class (
          grep { !is_excluded( $_, @exceptions ) }
          sort do {
              local @INC = @lib;
              my $finder = Module::Pluggable::Object->new(
                  search_path => $search_path );
              ( $search_path, $finder->plugins );
          }
          )
      {
          Test::More::use_ok($class);
      }
  }
  
  sub is_excluded {
      my ( $module, @exceptions ) = @_;
      any { $module eq $_ || $module =~ /$_/ } @exceptions;
  }
  
  1;
  
  __END__
  
  #line 110
---
file: inc/Module/Install.pm
template: |
  #line 1
  package Module::Install;
  
  # For any maintainers:
  # The load order for Module::Install is a bit magic.
  # It goes something like this...
  #
  # IF ( host has Module::Install installed, creating author mode ) {
  #     1. Makefile.PL calls "use inc::Module::Install"
  #     2. $INC{inc/Module/Install.pm} set to installed version of inc::Module::Install
  #     3. The installed version of inc::Module::Install loads
  #     4. inc::Module::Install calls "require Module::Install"
  #     5. The ./inc/ version of Module::Install loads
  # } ELSE {
  #     1. Makefile.PL calls "use inc::Module::Install"
  #     2. $INC{inc/Module/Install.pm} set to ./inc/ version of Module::Install
  #     3. The ./inc/ version of Module::Install loads
  # }
  
  use 5.006;
  use strict 'vars';
  use Cwd        ();
  use File::Find ();
  use File::Path ();
  
  use vars qw{$VERSION $MAIN};
  BEGIN {
  	# All Module::Install core packages now require synchronised versions.
  	# This will be used to ensure we don't accidentally load old or
  	# different versions of modules.
  	# This is not enforced yet, but will be some time in the next few
  	# releases once we can make sure it won't clash with custom
  	# Module::Install extensions.
  	$VERSION = '1.14';
  
  	# Storage for the pseudo-singleton
  	$MAIN    = undef;
  
  	*inc::Module::Install::VERSION = *VERSION;
  	@inc::Module::Install::ISA     = __PACKAGE__;
  
  }
  
  sub import {
  	my $class = shift;
  	my $self  = $class->new(@_);
  	my $who   = $self->_caller;
  
  	#-------------------------------------------------------------
  	# all of the following checks should be included in import(),
  	# to allow "eval 'require Module::Install; 1' to test
  	# installation of Module::Install. (RT #51267)
  	#-------------------------------------------------------------
  
  	# Whether or not inc::Module::Install is actually loaded, the
  	# $INC{inc/Module/Install.pm} is what will still get set as long as
  	# the caller loaded module this in the documented manner.
  	# If not set, the caller may NOT have loaded the bundled version, and thus
  	# they may not have a MI version that works with the Makefile.PL. This would
  	# result in false errors or unexpected behaviour. And we don't want that.
  	my $file = join( '/', 'inc', split /::/, __PACKAGE__ ) . '.pm';
  	unless ( $INC{$file} ) { die <<"END_DIE" }
  
  Please invoke ${\__PACKAGE__} with:
  
  	use inc::${\__PACKAGE__};
  
  not:
  
  	use ${\__PACKAGE__};
  
  END_DIE
  
  	# This reportedly fixes a rare Win32 UTC file time issue, but
  	# as this is a non-cross-platform XS module not in the core,
  	# we shouldn't really depend on it. See RT #24194 for detail.
  	# (Also, this module only supports Perl 5.6 and above).
  	eval "use Win32::UTCFileTime" if $^O eq 'MSWin32' && $] >= 5.006;
  
  	# If the script that is loading Module::Install is from the future,
  	# then make will detect this and cause it to re-run over and over
  	# again. This is bad. Rather than taking action to touch it (which
  	# is unreliable on some platforms and requires write permissions)
  	# for now we should catch this and refuse to run.
  	if ( -f $0 ) {
  		my $s = (stat($0))[9];
  
  		# If the modification time is only slightly in the future,
  		# sleep briefly to remove the problem.
  		my $a = $s - time;
  		if ( $a > 0 and $a < 5 ) { sleep 5 }
  
  		# Too far in the future, throw an error.
  		my $t = time;
  		if ( $s > $t ) { die <<"END_DIE" }
  
  Your installer $0 has a modification time in the future ($s > $t).
  
  This is known to create infinite loops in make.
  
  Please correct this, then run $0 again.
  
  END_DIE
  	}
  
  
  	# Build.PL was formerly supported, but no longer is due to excessive
  	# difficulty in implementing every single feature twice.
  	if ( $0 =~ /Build.PL$/i ) { die <<"END_DIE" }
  
  Module::Install no longer supports Build.PL.
  
  It was impossible to maintain duel backends, and has been deprecated.
  
  Please remove all Build.PL files and only use the Makefile.PL installer.
  
  END_DIE
  
  	#-------------------------------------------------------------
  
  	# To save some more typing in Module::Install installers, every...
  	# use inc::Module::Install
  	# ...also acts as an implicit use strict.
  	$^H |= strict::bits(qw(refs subs vars));
  
  	#-------------------------------------------------------------
  
  	unless ( -f $self->{file} ) {
  		foreach my $key (keys %INC) {
  			delete $INC{$key} if $key =~ /Module\/Install/;
  		}
  
  		local $^W;
  		require "$self->{path}/$self->{dispatch}.pm";
  		File::Path::mkpath("$self->{prefix}/$self->{author}");
  		$self->{admin} = "$self->{name}::$self->{dispatch}"->new( _top => $self );
  		$self->{admin}->init;
  		@_ = ($class, _self => $self);
  		goto &{"$self->{name}::import"};
  	}
  
  	local $^W;
  	*{"${who}::AUTOLOAD"} = $self->autoload;
  	$self->preload;
  
  	# Unregister loader and worker packages so subdirs can use them again
  	delete $INC{'inc/Module/Install.pm'};
  	delete $INC{'Module/Install.pm'};
  
  	# Save to the singleton
  	$MAIN = $self;
  
  	return 1;
  }
  
  sub autoload {
  	my $self = shift;
  	my $who  = $self->_caller;
  	my $cwd  = Cwd::getcwd();
  	my $sym  = "${who}::AUTOLOAD";
  	$sym->{$cwd} = sub {
  		my $pwd = Cwd::getcwd();
  		if ( my $code = $sym->{$pwd} ) {
  			# Delegate back to parent dirs
  			goto &$code unless $cwd eq $pwd;
  		}
  		unless ($$sym =~ s/([^:]+)$//) {
  			# XXX: it looks like we can't retrieve the missing function
  			# via $$sym (usually $main::AUTOLOAD) in this case.
  			# I'm still wondering if we should slurp Makefile.PL to
  			# get some context or not ...
  			my ($package, $file, $line) = caller;
  			die <<"EOT";
  Unknown function is found at $file line $line.
  Execution of $file aborted due to runtime errors.
  
  If you're a contributor to a project, you may need to install
  some Module::Install extensions from CPAN (or other repository).
  If you're a user of a module, please contact the author.
  EOT
  		}
  		my $method = $1;
  		if ( uc($method) eq $method ) {
  			# Do nothing
  			return;
  		} elsif ( $method =~ /^_/ and $self->can($method) ) {
  			# Dispatch to the root M:I class
  			return $self->$method(@_);
  		}
  
  		# Dispatch to the appropriate plugin
  		unshift @_, ( $self, $1 );
  		goto &{$self->can('call')};
  	};
  }
  
  sub preload {
  	my $self = shift;
  	unless ( $self->{extensions} ) {
  		$self->load_extensions(
  			"$self->{prefix}/$self->{path}", $self
  		);
  	}
  
  	my @exts = @{$self->{extensions}};
  	unless ( @exts ) {
  		@exts = $self->{admin}->load_all_extensions;
  	}
  
  	my %seen;
  	foreach my $obj ( @exts ) {
  		while (my ($method, $glob) = each %{ref($obj) . '::'}) {
  			next unless $obj->can($method);
  			next if $method =~ /^_/;
  			next if $method eq uc($method);
  			$seen{$method}++;
  		}
  	}
  
  	my $who = $self->_caller;
  	foreach my $name ( sort keys %seen ) {
  		local $^W;
  		*{"${who}::$name"} = sub {
  			${"${who}::AUTOLOAD"} = "${who}::$name";
  			goto &{"${who}::AUTOLOAD"};
  		};
  	}
  }
  
  sub new {
  	my ($class, %args) = @_;
  
  	delete $INC{'FindBin.pm'};
  	{
  		# to suppress the redefine warning
  		local $SIG{__WARN__} = sub {};
  		require FindBin;
  	}
  
  	# ignore the prefix on extension modules built from top level.
  	my $base_path = Cwd::abs_path($FindBin::Bin);
  	unless ( Cwd::abs_path(Cwd::getcwd()) eq $base_path ) {
  		delete $args{prefix};
  	}
  	return $args{_self} if $args{_self};
  
  	$args{dispatch} ||= 'Admin';
  	$args{prefix}   ||= 'inc';
  	$args{author}   ||= ($^O eq 'VMS' ? '_author' : '.author');
  	$args{bundle}   ||= 'inc/BUNDLES';
  	$args{base}     ||= $base_path;
  	$class =~ s/^\Q$args{prefix}\E:://;
  	$args{name}     ||= $class;
  	$args{version}  ||= $class->VERSION;
  	unless ( $args{path} ) {
  		$args{path}  = $args{name};
  		$args{path}  =~ s!::!/!g;
  	}
  	$args{file}     ||= "$args{base}/$args{prefix}/$args{path}.pm";
  	$args{wrote}      = 0;
  
  	bless( \%args, $class );
  }
  
  sub call {
  	my ($self, $method) = @_;
  	my $obj = $self->load($method) or return;
          splice(@_, 0, 2, $obj);
  	goto &{$obj->can($method)};
  }
  
  sub load {
  	my ($self, $method) = @_;
  
  	$self->load_extensions(
  		"$self->{prefix}/$self->{path}", $self
  	) unless $self->{extensions};
  
  	foreach my $obj (@{$self->{extensions}}) {
  		return $obj if $obj->can($method);
  	}
  
  	my $admin = $self->{admin} or die <<"END_DIE";
  The '$method' method does not exist in the '$self->{prefix}' path!
  Please remove the '$self->{prefix}' directory and run $0 again to load it.
  END_DIE
  
  	my $obj = $admin->load($method, 1);
  	push @{$self->{extensions}}, $obj;
  
  	$obj;
  }
  
  sub load_extensions {
  	my ($self, $path, $top) = @_;
  
  	my $should_reload = 0;
  	unless ( grep { ! ref $_ and lc $_ eq lc $self->{prefix} } @INC ) {
  		unshift @INC, $self->{prefix};
  		$should_reload = 1;
  	}
  
  	foreach my $rv ( $self->find_extensions($path) ) {
  		my ($file, $pkg) = @{$rv};
  		next if $self->{pathnames}{$pkg};
  
  		local $@;
  		my $new = eval { local $^W; require $file; $pkg->can('new') };
  		unless ( $new ) {
  			warn $@ if $@;
  			next;
  		}
  		$self->{pathnames}{$pkg} =
  			$should_reload ? delete $INC{$file} : $INC{$file};
  		push @{$self->{extensions}}, &{$new}($pkg, _top => $top );
  	}
  
  	$self->{extensions} ||= [];
  }
  
  sub find_extensions {
  	my ($self, $path) = @_;
  
  	my @found;
  	File::Find::find( sub {
  		my $file = $File::Find::name;
  		return unless $file =~ m!^\Q$path\E/(.+)\.pm\Z!is;
  		my $subpath = $1;
  		return if lc($subpath) eq lc($self->{dispatch});
  
  		$file = "$self->{path}/$subpath.pm";
  		my $pkg = "$self->{name}::$subpath";
  		$pkg =~ s!/!::!g;
  
  		# If we have a mixed-case package name, assume case has been preserved
  		# correctly.  Otherwise, root through the file to locate the case-preserved
  		# version of the package name.
  		if ( $subpath eq lc($subpath) || $subpath eq uc($subpath) ) {
  			my $content = Module::Install::_read($subpath . '.pm');
  			my $in_pod  = 0;
  			foreach ( split /\n/, $content ) {
  				$in_pod = 1 if /^=\w/;
  				$in_pod = 0 if /^=cut/;
  				next if ($in_pod || /^=cut/);  # skip pod text
  				next if /^\s*#/;               # and comments
  				if ( m/^\s*package\s+($pkg)\s*;/i ) {
  					$pkg = $1;
  					last;
  				}
  			}
  		}
  
  		push @found, [ $file, $pkg ];
  	}, $path ) if -d $path;
  
  	@found;
  }
  
  
  
  
  
  #####################################################################
  # Common Utility Functions
  
  sub _caller {
  	my $depth = 0;
  	my $call  = caller($depth);
  	while ( $call eq __PACKAGE__ ) {
  		$depth++;
  		$call = caller($depth);
  	}
  	return $call;
  }
  
  # Done in evals to avoid confusing Perl::MinimumVersion
  eval( $] >= 5.006 ? <<'END_NEW' : <<'END_OLD' ); die $@ if $@;
  sub _read {
  	local *FH;
  	open( FH, '<', $_[0] ) or die "open($_[0]): $!";
  	binmode FH;
  	my $string = do { local $/; <FH> };
  	close FH or die "close($_[0]): $!";
  	return $string;
  }
  END_NEW
  sub _read {
  	local *FH;
  	open( FH, "< $_[0]"  ) or die "open($_[0]): $!";
  	binmode FH;
  	my $string = do { local $/; <FH> };
  	close FH or die "close($_[0]): $!";
  	return $string;
  }
  END_OLD
  
  sub _readperl {
  	my $string = Module::Install::_read($_[0]);
  	$string =~ s/(?:\015{1,2}\012|\015|\012)/\n/sg;
  	$string =~ s/(\n)\n*__(?:DATA|END)__\b.*\z/$1/s;
  	$string =~ s/\n\n=\w+.+?\n\n=cut\b.+?\n+/\n\n/sg;
  	return $string;
  }
  
  sub _readpod {
  	my $string = Module::Install::_read($_[0]);
  	$string =~ s/(?:\015{1,2}\012|\015|\012)/\n/sg;
  	return $string if $_[0] =~ /\.pod\z/;
  	$string =~ s/(^|\n=cut\b.+?\n+)[^=\s].+?\n(\n=\w+|\z)/$1$2/sg;
  	$string =~ s/\n*=pod\b[^\n]*\n+/\n\n/sg;
  	$string =~ s/\n*=cut\b[^\n]*\n+/\n\n/sg;
  	$string =~ s/^\n+//s;
  	return $string;
  }
  
  # Done in evals to avoid confusing Perl::MinimumVersion
  eval( $] >= 5.006 ? <<'END_NEW' : <<'END_OLD' ); die $@ if $@;
  sub _write {
  	local *FH;
  	open( FH, '>', $_[0] ) or die "open($_[0]): $!";
  	binmode FH;
  	foreach ( 1 .. $#_ ) {
  		print FH $_[$_] or die "print($_[0]): $!";
  	}
  	close FH or die "close($_[0]): $!";
  }
  END_NEW
  sub _write {
  	local *FH;
  	open( FH, "> $_[0]"  ) or die "open($_[0]): $!";
  	binmode FH;
  	foreach ( 1 .. $#_ ) {
  		print FH $_[$_] or die "print($_[0]): $!";
  	}
  	close FH or die "close($_[0]): $!";
  }
  END_OLD
  
  # _version is for processing module versions (eg, 1.03_05) not
  # Perl versions (eg, 5.8.1).
  sub _version {
  	my $s = shift || 0;
  	my $d =()= $s =~ /(\.)/g;
  	if ( $d >= 2 ) {
  		# Normalise multipart versions
  		$s =~ s/(\.)(\d{1,3})/sprintf("$1%03d",$2)/eg;
  	}
  	$s =~ s/^(\d+)\.?//;
  	my $l = $1 || 0;
  	my @v = map {
  		$_ . '0' x (3 - length $_)
  	} $s =~ /(\d{1,3})\D?/g;
  	$l = $l . '.' . join '', @v if @v;
  	return $l + 0;
  }
  
  sub _cmp {
  	_version($_[1]) <=> _version($_[2]);
  }
  
  # Cloned from Params::Util::_CLASS
  sub _CLASS {
  	(
  		defined $_[0]
  		and
  		! ref $_[0]
  		and
  		$_[0] =~ m/^[^\W\d]\w*(?:::\w+)*\z/s
  	) ? $_[0] : undef;
  }
  
  1;
  
  # Copyright 2008 - 2012 Adam Kennedy.
---
file: inc/Module/Install/Fetch.pm
template: |
  #line 1
  package Module::Install::Fetch;
  
  use strict;
  use Module::Install::Base ();
  
  use vars qw{$VERSION @ISA $ISCORE};
  BEGIN {
  	$VERSION = '1.14';
  	@ISA     = 'Module::Install::Base';
  	$ISCORE  = 1;
  }
  
  sub get_file {
      my ($self, %args) = @_;
      my ($scheme, $host, $path, $file) =
          $args{url} =~ m|^(\w+)://([^/]+)(.+)/(.+)| or return;
  
      if ( $scheme eq 'http' and ! eval { require LWP::Simple; 1 } ) {
          $args{url} = $args{ftp_url}
              or (warn("LWP support unavailable!\n"), return);
          ($scheme, $host, $path, $file) =
              $args{url} =~ m|^(\w+)://([^/]+)(.+)/(.+)| or return;
      }
  
      $|++;
      print "Fetching '$file' from $host... ";
  
      unless (eval { require Socket; Socket::inet_aton($host) }) {
          warn "'$host' resolve failed!\n";
          return;
      }
  
      return unless $scheme eq 'ftp' or $scheme eq 'http';
  
      require Cwd;
      my $dir = Cwd::getcwd();
      chdir $args{local_dir} or return if exists $args{local_dir};
  
      if (eval { require LWP::Simple; 1 }) {
          LWP::Simple::mirror($args{url}, $file);
      }
      elsif (eval { require Net::FTP; 1 }) { eval {
          # use Net::FTP to get past firewall
          my $ftp = Net::FTP->new($host, Passive => 1, Timeout => 600);
          $ftp->login("anonymous", 'anonymous@example.com');
          $ftp->cwd($path);
          $ftp->binary;
          $ftp->get($file) or (warn("$!\n"), return);
          $ftp->quit;
      } }
      elsif (my $ftp = $self->can_run('ftp')) { eval {
          # no Net::FTP, fallback to ftp.exe
          require FileHandle;
          my $fh = FileHandle->new;
  
          local $SIG{CHLD} = 'IGNORE';
          unless ($fh->open("|$ftp -n")) {
              warn "Couldn't open ftp: $!\n";
              chdir $dir; return;
          }
  
          my @dialog = split(/\n/, <<"END_FTP");
  open $host
  user anonymous anonymous\@example.com
  cd $path
  binary
  get $file $file
  quit
  END_FTP
          foreach (@dialog) { $fh->print("$_\n") }
          $fh->close;
      } }
      else {
          warn "No working 'ftp' program available!\n";
          chdir $dir; return;
      }
  
      unless (-f $file) {
          warn "Fetching failed: $@\n";
          chdir $dir; return;
      }
  
      return if exists $args{size} and -s $file != $args{size};
      system($args{run}) if exists $args{run};
      unlink($file) if $args{remove};
  
      print(((!exists $args{check_for} or -e $args{check_for})
          ? "done!" : "failed! ($!)"), "\n");
      chdir $dir; return !$?;
  }
  
  1;
---
file: inc/Module/Install/Include.pm
template: |
  #line 1
  package Module::Install::Include;
  
  use strict;
  use Module::Install::Base ();
  
  use vars qw{$VERSION @ISA $ISCORE};
  BEGIN {
  	$VERSION = '1.14';
  	@ISA     = 'Module::Install::Base';
  	$ISCORE  = 1;
  }
  
  sub include {
  	shift()->admin->include(@_);
  }
  
  sub include_deps {
  	shift()->admin->include_deps(@_);
  }
  
  sub auto_include {
  	shift()->admin->auto_include(@_);
  }
  
  sub auto_include_deps {
  	shift()->admin->auto_include_deps(@_);
  }
  
  sub auto_include_dependent_dists {
  	shift()->admin->auto_include_dependent_dists(@_);
  }
  
  1;
---
file: inc/Module/Install/Can.pm
template: |
  #line 1
  package Module::Install::Can;
  
  use strict;
  use Config                ();
  use ExtUtils::MakeMaker   ();
  use Module::Install::Base ();
  
  use vars qw{$VERSION @ISA $ISCORE};
  BEGIN {
  	$VERSION = '1.14';
  	@ISA     = 'Module::Install::Base';
  	$ISCORE  = 1;
  }
  
  # check if we can load some module
  ### Upgrade this to not have to load the module if possible
  sub can_use {
  	my ($self, $mod, $ver) = @_;
  	$mod =~ s{::|\\}{/}g;
  	$mod .= '.pm' unless $mod =~ /\.pm$/i;
  
  	my $pkg = $mod;
  	$pkg =~ s{/}{::}g;
  	$pkg =~ s{\.pm$}{}i;
  
  	local $@;
  	eval { require $mod; $pkg->VERSION($ver || 0); 1 };
  }
  
  # Check if we can run some command
  sub can_run {
  	my ($self, $cmd) = @_;
  
  	my $_cmd = $cmd;
  	return $_cmd if (-x $_cmd or $_cmd = MM->maybe_command($_cmd));
  
  	for my $dir ((split /$Config::Config{path_sep}/, $ENV{PATH}), '.') {
  		next if $dir eq '';
  		require File::Spec;
  		my $abs = File::Spec->catfile($dir, $cmd);
  		return $abs if (-x $abs or $abs = MM->maybe_command($abs));
  	}
  
  	return;
  }
  
  # Can our C compiler environment build XS files
  sub can_xs {
  	my $self = shift;
  
  	# Ensure we have the CBuilder module
  	$self->configure_requires( 'ExtUtils::CBuilder' => 0.27 );
  
  	# Do we have the configure_requires checker?
  	local $@;
  	eval "require ExtUtils::CBuilder;";
  	if ( $@ ) {
  		# They don't obey configure_requires, so it is
  		# someone old and delicate. Try to avoid hurting
  		# them by falling back to an older simpler test.
  		return $self->can_cc();
  	}
  
  	# Do we have a working C compiler
  	my $builder = ExtUtils::CBuilder->new(
  		quiet => 1,
  	);
  	unless ( $builder->have_compiler ) {
  		# No working C compiler
  		return 0;
  	}
  
  	# Write a C file representative of what XS becomes
  	require File::Temp;
  	my ( $FH, $tmpfile ) = File::Temp::tempfile(
  		"compilexs-XXXXX",
  		SUFFIX => '.c',
  	);
  	binmode $FH;
  	print $FH <<'END_C';
  #include "EXTERN.h"
  #include "perl.h"
  #include "XSUB.h"
  
  int main(int argc, char **argv) {
      return 0;
  }
  
  int boot_sanexs() {
      return 1;
  }
  
  END_C
  	close $FH;
  
  	# Can the C compiler access the same headers XS does
  	my @libs   = ();
  	my $object = undef;
  	eval {
  		local $^W = 0;
  		$object = $builder->compile(
  			source => $tmpfile,
  		);
  		@libs = $builder->link(
  			objects     => $object,
  			module_name => 'sanexs',
  		);
  	};
  	my $result = $@ ? 0 : 1;
  
  	# Clean up all the build files
  	foreach ( $tmpfile, $object, @libs ) {
  		next unless defined $_;
  		1 while unlink;
  	}
  
  	return $result;
  }
  
  # Can we locate a (the) C compiler
  sub can_cc {
  	my $self   = shift;
  	my @chunks = split(/ /, $Config::Config{cc}) or return;
  
  	# $Config{cc} may contain args; try to find out the program part
  	while (@chunks) {
  		return $self->can_run("@chunks") || (pop(@chunks), next);
  	}
  
  	return;
  }
  
  # Fix Cygwin bug on maybe_command();
  if ( $^O eq 'cygwin' ) {
  	require ExtUtils::MM_Cygwin;
  	require ExtUtils::MM_Win32;
  	if ( ! defined(&ExtUtils::MM_Cygwin::maybe_command) ) {
  		*ExtUtils::MM_Cygwin::maybe_command = sub {
  			my ($self, $file) = @_;
  			if ($file =~ m{^/cygdrive/}i and ExtUtils::MM_Win32->can('maybe_command')) {
  				ExtUtils::MM_Win32->maybe_command($file);
  			} else {
  				ExtUtils::MM_Unix->maybe_command($file);
  			}
  		}
  	}
  }
  
  1;
  
  __END__
  
  #line 236
---
file: inc/Module/Install/Base.pm
template: |
  #line 1
  package Module::Install::Base;
  
  use strict 'vars';
  use vars qw{$VERSION};
  BEGIN {
  	$VERSION = '1.14';
  }
  
  # Suspend handler for "redefined" warnings
  BEGIN {
  	my $w = $SIG{__WARN__};
  	$SIG{__WARN__} = sub { $w };
  }
  
  #line 42
  
  sub new {
  	my $class = shift;
  	unless ( defined &{"${class}::call"} ) {
  		*{"${class}::call"} = sub { shift->_top->call(@_) };
  	}
  	unless ( defined &{"${class}::load"} ) {
  		*{"${class}::load"} = sub { shift->_top->load(@_) };
  	}
  	bless { @_ }, $class;
  }
  
  #line 61
  
  sub AUTOLOAD {
  	local $@;
  	my $func = eval { shift->_top->autoload } or return;
  	goto &$func;
  }
  
  #line 75
  
  sub _top {
  	$_[0]->{_top};
  }
  
  #line 90
  
  sub admin {
  	$_[0]->_top->{admin}
  	or
  	Module::Install::Base::FakeAdmin->new;
  }
  
  #line 106
  
  sub is_admin {
  	! $_[0]->admin->isa('Module::Install::Base::FakeAdmin');
  }
  
  sub DESTROY {}
  
  package Module::Install::Base::FakeAdmin;
  
  use vars qw{$VERSION};
  BEGIN {
  	$VERSION = $Module::Install::Base::VERSION;
  }
  
  my $fake;
  
  sub new {
  	$fake ||= bless(\@_, $_[0]);
  }
  
  sub AUTOLOAD {}
  
  sub DESTROY {}
  
  # Restore warning handler
  BEGIN {
  	$SIG{__WARN__} = $SIG{__WARN__}->();
  }
  
  1;
  
  #line 159
---
file: inc/Module/Install/Metadata.pm
template: |
  #line 1
  package Module::Install::Metadata;
  
  use strict 'vars';
  use Module::Install::Base ();
  
  use vars qw{$VERSION @ISA $ISCORE};
  BEGIN {
  	$VERSION = '1.14';
  	@ISA     = 'Module::Install::Base';
  	$ISCORE  = 1;
  }
  
  my @boolean_keys = qw{
  	sign
  };
  
  my @scalar_keys = qw{
  	name
  	module_name
  	abstract
  	version
  	distribution_type
  	tests
  	installdirs
  };
  
  my @tuple_keys = qw{
  	configure_requires
  	build_requires
  	requires
  	recommends
  	bundles
  	resources
  };
  
  my @resource_keys = qw{
  	homepage
  	bugtracker
  	repository
  };
  
  my @array_keys = qw{
  	keywords
  	author
  };
  
  *authors = \&author;
  
  sub Meta              { shift          }
  sub Meta_BooleanKeys  { @boolean_keys  }
  sub Meta_ScalarKeys   { @scalar_keys   }
  sub Meta_TupleKeys    { @tuple_keys    }
  sub Meta_ResourceKeys { @resource_keys }
  sub Meta_ArrayKeys    { @array_keys    }
  
  foreach my $key ( @boolean_keys ) {
  	*$key = sub {
  		my $self = shift;
  		if ( defined wantarray and not @_ ) {
  			return $self->{values}->{$key};
  		}
  		$self->{values}->{$key} = ( @_ ? $_[0] : 1 );
  		return $self;
  	};
  }
  
  foreach my $key ( @scalar_keys ) {
  	*$key = sub {
  		my $self = shift;
  		return $self->{values}->{$key} if defined wantarray and !@_;
  		$self->{values}->{$key} = shift;
  		return $self;
  	};
  }
  
  foreach my $key ( @array_keys ) {
  	*$key = sub {
  		my $self = shift;
  		return $self->{values}->{$key} if defined wantarray and !@_;
  		$self->{values}->{$key} ||= [];
  		push @{$self->{values}->{$key}}, @_;
  		return $self;
  	};
  }
  
  foreach my $key ( @resource_keys ) {
  	*$key = sub {
  		my $self = shift;
  		unless ( @_ ) {
  			return () unless $self->{values}->{resources};
  			return map  { $_->[1] }
  			       grep { $_->[0] eq $key }
  			       @{ $self->{values}->{resources} };
  		}
  		return $self->{values}->{resources}->{$key} unless @_;
  		my $uri = shift or die(
  			"Did not provide a value to $key()"
  		);
  		$self->resources( $key => $uri );
  		return 1;
  	};
  }
  
  foreach my $key ( grep { $_ ne "resources" } @tuple_keys) {
  	*$key = sub {
  		my $self = shift;
  		return $self->{values}->{$key} unless @_;
  		my @added;
  		while ( @_ ) {
  			my $module  = shift or last;
  			my $version = shift || 0;
  			push @added, [ $module, $version ];
  		}
  		push @{ $self->{values}->{$key} }, @added;
  		return map {@$_} @added;
  	};
  }
  
  # Resource handling
  my %lc_resource = map { $_ => 1 } qw{
  	homepage
  	license
  	bugtracker
  	repository
  };
  
  sub resources {
  	my $self = shift;
  	while ( @_ ) {
  		my $name  = shift or last;
  		my $value = shift or next;
  		if ( $name eq lc $name and ! $lc_resource{$name} ) {
  			die("Unsupported reserved lowercase resource '$name'");
  		}
  		$self->{values}->{resources} ||= [];
  		push @{ $self->{values}->{resources} }, [ $name, $value ];
  	}
  	$self->{values}->{resources};
  }
  
  # Aliases for build_requires that will have alternative
  # meanings in some future version of META.yml.
  sub test_requires     { shift->build_requires(@_) }
  sub install_requires  { shift->build_requires(@_) }
  
  # Aliases for installdirs options
  sub install_as_core   { $_[0]->installdirs('perl')   }
  sub install_as_cpan   { $_[0]->installdirs('site')   }
  sub install_as_site   { $_[0]->installdirs('site')   }
  sub install_as_vendor { $_[0]->installdirs('vendor') }
  
  sub dynamic_config {
  	my $self  = shift;
  	my $value = @_ ? shift : 1;
  	if ( $self->{values}->{dynamic_config} ) {
  		# Once dynamic we never change to static, for safety
  		return 0;
  	}
  	$self->{values}->{dynamic_config} = $value ? 1 : 0;
  	return 1;
  }
  
  # Convenience command
  sub static_config {
  	shift->dynamic_config(0);
  }
  
  sub perl_version {
  	my $self = shift;
  	return $self->{values}->{perl_version} unless @_;
  	my $version = shift or die(
  		"Did not provide a value to perl_version()"
  	);
  
  	# Normalize the version
  	$version = $self->_perl_version($version);
  
  	# We don't support the really old versions
  	unless ( $version >= 5.005 ) {
  		die "Module::Install only supports 5.005 or newer (use ExtUtils::MakeMaker)\n";
  	}
  
  	$self->{values}->{perl_version} = $version;
  }
  
  sub all_from {
  	my ( $self, $file ) = @_;
  
  	unless ( defined($file) ) {
  		my $name = $self->name or die(
  			"all_from called with no args without setting name() first"
  		);
  		$file = join('/', 'lib', split(/-/, $name)) . '.pm';
  		$file =~ s{.*/}{} unless -e $file;
  		unless ( -e $file ) {
  			die("all_from cannot find $file from $name");
  		}
  	}
  	unless ( -f $file ) {
  		die("The path '$file' does not exist, or is not a file");
  	}
  
  	$self->{values}{all_from} = $file;
  
  	# Some methods pull from POD instead of code.
  	# If there is a matching .pod, use that instead
  	my $pod = $file;
  	$pod =~ s/\.pm$/.pod/i;
  	$pod = $file unless -e $pod;
  
  	# Pull the different values
  	$self->name_from($file)         unless $self->name;
  	$self->version_from($file)      unless $self->version;
  	$self->perl_version_from($file) unless $self->perl_version;
  	$self->author_from($pod)        unless @{$self->author || []};
  	$self->license_from($pod)       unless $self->license;
  	$self->abstract_from($pod)      unless $self->abstract;
  
  	return 1;
  }
  
  sub provides {
  	my $self     = shift;
  	my $provides = ( $self->{values}->{provides} ||= {} );
  	%$provides = (%$provides, @_) if @_;
  	return $provides;
  }
  
  sub auto_provides {
  	my $self = shift;
  	return $self unless $self->is_admin;
  	unless (-e 'MANIFEST') {
  		warn "Cannot deduce auto_provides without a MANIFEST, skipping\n";
  		return $self;
  	}
  	# Avoid spurious warnings as we are not checking manifest here.
  	local $SIG{__WARN__} = sub {1};
  	require ExtUtils::Manifest;
  	local *ExtUtils::Manifest::manicheck = sub { return };
  
  	require Module::Build;
  	my $build = Module::Build->new(
  		dist_name    => $self->name,
  		dist_version => $self->version,
  		license      => $self->license,
  	);
  	$self->provides( %{ $build->find_dist_packages || {} } );
  }
  
  sub feature {
  	my $self     = shift;
  	my $name     = shift;
  	my $features = ( $self->{values}->{features} ||= [] );
  	my $mods;
  
  	if ( @_ == 1 and ref( $_[0] ) ) {
  		# The user used ->feature like ->features by passing in the second
  		# argument as a reference.  Accomodate for that.
  		$mods = $_[0];
  	} else {
  		$mods = \@_;
  	}
  
  	my $count = 0;
  	push @$features, (
  		$name => [
  			map {
  				ref($_) ? ( ref($_) eq 'HASH' ) ? %$_ : @$_ : $_
  			} @$mods
  		]
  	);
  
  	return @$features;
  }
  
  sub features {
  	my $self = shift;
  	while ( my ( $name, $mods ) = splice( @_, 0, 2 ) ) {
  		$self->feature( $name, @$mods );
  	}
  	return $self->{values}->{features}
  		? @{ $self->{values}->{features} }
  		: ();
  }
  
  sub no_index {
  	my $self = shift;
  	my $type = shift;
  	push @{ $self->{values}->{no_index}->{$type} }, @_ if $type;
  	return $self->{values}->{no_index};
  }
  
  sub read {
  	my $self = shift;
  	$self->include_deps( 'YAML::Tiny', 0 );
  
  	require YAML::Tiny;
  	my $data = YAML::Tiny::LoadFile('META.yml');
  
  	# Call methods explicitly in case user has already set some values.
  	while ( my ( $key, $value ) = each %$data ) {
  		next unless $self->can($key);
  		if ( ref $value eq 'HASH' ) {
  			while ( my ( $module, $version ) = each %$value ) {
  				$self->can($key)->($self, $module => $version );
  			}
  		} else {
  			$self->can($key)->($self, $value);
  		}
  	}
  	return $self;
  }
  
  sub write {
  	my $self = shift;
  	return $self unless $self->is_admin;
  	$self->admin->write_meta;
  	return $self;
  }
  
  sub version_from {
  	require ExtUtils::MM_Unix;
  	my ( $self, $file ) = @_;
  	$self->version( ExtUtils::MM_Unix->parse_version($file) );
  
  	# for version integrity check
  	$self->makemaker_args( VERSION_FROM => $file );
  }
  
  sub abstract_from {
  	require ExtUtils::MM_Unix;
  	my ( $self, $file ) = @_;
  	$self->abstract(
  		bless(
  			{ DISTNAME => $self->name },
  			'ExtUtils::MM_Unix'
  		)->parse_abstract($file)
  	);
  }
  
  # Add both distribution and module name
  sub name_from {
  	my ($self, $file) = @_;
  	if (
  		Module::Install::_read($file) =~ m/
  		^ \s*
  		package \s*
  		([\w:]+)
  		[\s|;]*
  		/ixms
  	) {
  		my ($name, $module_name) = ($1, $1);
  		$name =~ s{::}{-}g;
  		$self->name($name);
  		unless ( $self->module_name ) {
  			$self->module_name($module_name);
  		}
  	} else {
  		die("Cannot determine name from $file\n");
  	}
  }
  
  sub _extract_perl_version {
  	if (
  		$_[0] =~ m/
  		^\s*
  		(?:use|require) \s*
  		v?
  		([\d_\.]+)
  		\s* ;
  		/ixms
  	) {
  		my $perl_version = $1;
  		$perl_version =~ s{_}{}g;
  		return $perl_version;
  	} else {
  		return;
  	}
  }
  
  sub perl_version_from {
  	my $self = shift;
  	my $perl_version=_extract_perl_version(Module::Install::_read($_[0]));
  	if ($perl_version) {
  		$self->perl_version($perl_version);
  	} else {
  		warn "Cannot determine perl version info from $_[0]\n";
  		return;
  	}
  }
  
  sub author_from {
  	my $self    = shift;
  	my $content = Module::Install::_read($_[0]);
  	if ($content =~ m/
  		=head \d \s+ (?:authors?)\b \s*
  		([^\n]*)
  		|
  		=head \d \s+ (?:licen[cs]e|licensing|copyright|legal)\b \s*
  		.*? copyright .*? \d\d\d[\d.]+ \s* (?:\bby\b)? \s*
  		([^\n]*)
  	/ixms) {
  		my $author = $1 || $2;
  
  		# XXX: ugly but should work anyway...
  		if (eval "require Pod::Escapes; 1") {
  			# Pod::Escapes has a mapping table.
  			# It's in core of perl >= 5.9.3, and should be installed
  			# as one of the Pod::Simple's prereqs, which is a prereq
  			# of Pod::Text 3.x (see also below).
  			$author =~ s{ E<( (\d+) | ([A-Za-z]+) )> }
  			{
  				defined $2
  				? chr($2)
  				: defined $Pod::Escapes::Name2character_number{$1}
  				? chr($Pod::Escapes::Name2character_number{$1})
  				: do {
  					warn "Unknown escape: E<$1>";
  					"E<$1>";
  				};
  			}gex;
  		}
  		elsif (eval "require Pod::Text; 1" && $Pod::Text::VERSION < 3) {
  			# Pod::Text < 3.0 has yet another mapping table,
  			# though the table name of 2.x and 1.x are different.
  			# (1.x is in core of Perl < 5.6, 2.x is in core of
  			# Perl < 5.9.3)
  			my $mapping = ($Pod::Text::VERSION < 2)
  				? \%Pod::Text::HTML_Escapes
  				: \%Pod::Text::ESCAPES;
  			$author =~ s{ E<( (\d+) | ([A-Za-z]+) )> }
  			{
  				defined $2
  				? chr($2)
  				: defined $mapping->{$1}
  				? $mapping->{$1}
  				: do {
  					warn "Unknown escape: E<$1>";
  					"E<$1>";
  				};
  			}gex;
  		}
  		else {
  			$author =~ s{E<lt>}{<}g;
  			$author =~ s{E<gt>}{>}g;
  		}
  		$self->author($author);
  	} else {
  		warn "Cannot determine author info from $_[0]\n";
  	}
  }
  
  #Stolen from M::B
  my %license_urls = (
      perl         => 'http://dev.perl.org/licenses/',
      apache       => 'http://apache.org/licenses/LICENSE-2.0',
      apache_1_1   => 'http://apache.org/licenses/LICENSE-1.1',
      artistic     => 'http://opensource.org/licenses/artistic-license.php',
      artistic_2   => 'http://opensource.org/licenses/artistic-license-2.0.php',
      lgpl         => 'http://opensource.org/licenses/lgpl-license.php',
      lgpl2        => 'http://opensource.org/licenses/lgpl-2.1.php',
      lgpl3        => 'http://opensource.org/licenses/lgpl-3.0.html',
      bsd          => 'http://opensource.org/licenses/bsd-license.php',
      gpl          => 'http://opensource.org/licenses/gpl-license.php',
      gpl2         => 'http://opensource.org/licenses/gpl-2.0.php',
      gpl3         => 'http://opensource.org/licenses/gpl-3.0.html',
      mit          => 'http://opensource.org/licenses/mit-license.php',
      mozilla      => 'http://opensource.org/licenses/mozilla1.1.php',
      open_source  => undef,
      unrestricted => undef,
      restrictive  => undef,
      unknown      => undef,
  );
  
  sub license {
  	my $self = shift;
  	return $self->{values}->{license} unless @_;
  	my $license = shift or die(
  		'Did not provide a value to license()'
  	);
  	$license = __extract_license($license) || lc $license;
  	$self->{values}->{license} = $license;
  
  	# Automatically fill in license URLs
  	if ( $license_urls{$license} ) {
  		$self->resources( license => $license_urls{$license} );
  	}
  
  	return 1;
  }
  
  sub _extract_license {
  	my $pod = shift;
  	my $matched;
  	return __extract_license(
  		($matched) = $pod =~ m/
  			(=head \d \s+ L(?i:ICEN[CS]E|ICENSING)\b.*?)
  			(=head \d.*|=cut.*|)\z
  		/xms
  	) || __extract_license(
  		($matched) = $pod =~ m/
  			(=head \d \s+ (?:C(?i:OPYRIGHTS?)|L(?i:EGAL))\b.*?)
  			(=head \d.*|=cut.*|)\z
  		/xms
  	);
  }
  
  sub __extract_license {
  	my $license_text = shift or return;
  	my @phrases      = (
  		'(?:under )?the same (?:terms|license) as (?:perl|the perl (?:\d )?programming language)' => 'perl', 1,
  		'(?:under )?the terms of (?:perl|the perl programming language) itself' => 'perl', 1,
  		'Artistic and GPL'                   => 'perl',         1,
  		'GNU general public license'         => 'gpl',          1,
  		'GNU public license'                 => 'gpl',          1,
  		'GNU lesser general public license'  => 'lgpl',         1,
  		'GNU lesser public license'          => 'lgpl',         1,
  		'GNU library general public license' => 'lgpl',         1,
  		'GNU library public license'         => 'lgpl',         1,
  		'GNU Free Documentation license'     => 'unrestricted', 1,
  		'GNU Affero General Public License'  => 'open_source',  1,
  		'(?:Free)?BSD license'               => 'bsd',          1,
  		'Artistic license 2\.0'              => 'artistic_2',   1,
  		'Artistic license'                   => 'artistic',     1,
  		'Apache (?:Software )?license'       => 'apache',       1,
  		'GPL'                                => 'gpl',          1,
  		'LGPL'                               => 'lgpl',         1,
  		'BSD'                                => 'bsd',          1,
  		'Artistic'                           => 'artistic',     1,
  		'MIT'                                => 'mit',          1,
  		'Mozilla Public License'             => 'mozilla',      1,
  		'Q Public License'                   => 'open_source',  1,
  		'OpenSSL License'                    => 'unrestricted', 1,
  		'SSLeay License'                     => 'unrestricted', 1,
  		'zlib License'                       => 'open_source',  1,
  		'proprietary'                        => 'proprietary',  0,
  	);
  	while ( my ($pattern, $license, $osi) = splice(@phrases, 0, 3) ) {
  		$pattern =~ s#\s+#\\s+#gs;
  		if ( $license_text =~ /\b$pattern\b/i ) {
  			return $license;
  		}
  	}
  	return '';
  }
  
  sub license_from {
  	my $self = shift;
  	if (my $license=_extract_license(Module::Install::_read($_[0]))) {
  		$self->license($license);
  	} else {
  		warn "Cannot determine license info from $_[0]\n";
  		return 'unknown';
  	}
  }
  
  sub _extract_bugtracker {
  	my @links   = $_[0] =~ m#L<(
  	 https?\Q://rt.cpan.org/\E[^>]+|
  	 https?\Q://github.com/\E[\w_]+/[\w_]+/issues|
  	 https?\Q://code.google.com/p/\E[\w_\-]+/issues/list
  	 )>#gx;
  	my %links;
  	@links{@links}=();
  	@links=keys %links;
  	return @links;
  }
  
  sub bugtracker_from {
  	my $self    = shift;
  	my $content = Module::Install::_read($_[0]);
  	my @links   = _extract_bugtracker($content);
  	unless ( @links ) {
  		warn "Cannot determine bugtracker info from $_[0]\n";
  		return 0;
  	}
  	if ( @links > 1 ) {
  		warn "Found more than one bugtracker link in $_[0]\n";
  		return 0;
  	}
  
  	# Set the bugtracker
  	bugtracker( $links[0] );
  	return 1;
  }
  
  sub requires_from {
  	my $self     = shift;
  	my $content  = Module::Install::_readperl($_[0]);
  	my @requires = $content =~ m/^use\s+([^\W\d]\w*(?:::\w+)*)\s+(v?[\d\.]+)/mg;
  	while ( @requires ) {
  		my $module  = shift @requires;
  		my $version = shift @requires;
  		$self->requires( $module => $version );
  	}
  }
  
  sub test_requires_from {
  	my $self     = shift;
  	my $content  = Module::Install::_readperl($_[0]);
  	my @requires = $content =~ m/^use\s+([^\W\d]\w*(?:::\w+)*)\s+([\d\.]+)/mg;
  	while ( @requires ) {
  		my $module  = shift @requires;
  		my $version = shift @requires;
  		$self->test_requires( $module => $version );
  	}
  }
  
  # Convert triple-part versions (eg, 5.6.1 or 5.8.9) to
  # numbers (eg, 5.006001 or 5.008009).
  # Also, convert double-part versions (eg, 5.8)
  sub _perl_version {
  	my $v = $_[-1];
  	$v =~ s/^([1-9])\.([1-9]\d?\d?)$/sprintf("%d.%03d",$1,$2)/e;
  	$v =~ s/^([1-9])\.([1-9]\d?\d?)\.(0|[1-9]\d?\d?)$/sprintf("%d.%03d%03d",$1,$2,$3 || 0)/e;
  	$v =~ s/(\.\d\d\d)000$/$1/;
  	$v =~ s/_.+$//;
  	if ( ref($v) ) {
  		# Numify
  		$v = $v + 0;
  	}
  	return $v;
  }
  
  sub add_metadata {
      my $self = shift;
      my %hash = @_;
      for my $key (keys %hash) {
          warn "add_metadata: $key is not prefixed with 'x_'.\n" .
               "Use appopriate function to add non-private metadata.\n" unless $key =~ /^x_/;
          $self->{values}->{$key} = $hash{$key};
      }
  }
  
  
  ######################################################################
  # MYMETA Support
  
  sub WriteMyMeta {
  	die "WriteMyMeta has been deprecated";
  }
  
  sub write_mymeta_yaml {
  	my $self = shift;
  
  	# We need YAML::Tiny to write the MYMETA.yml file
  	unless ( eval { require YAML::Tiny; 1; } ) {
  		return 1;
  	}
  
  	# Generate the data
  	my $meta = $self->_write_mymeta_data or return 1;
  
  	# Save as the MYMETA.yml file
  	print "Writing MYMETA.yml\n";
  	YAML::Tiny::DumpFile('MYMETA.yml', $meta);
  }
  
  sub write_mymeta_json {
  	my $self = shift;
  
  	# We need JSON to write the MYMETA.json file
  	unless ( eval { require JSON; 1; } ) {
  		return 1;
  	}
  
  	# Generate the data
  	my $meta = $self->_write_mymeta_data or return 1;
  
  	# Save as the MYMETA.yml file
  	print "Writing MYMETA.json\n";
  	Module::Install::_write(
  		'MYMETA.json',
  		JSON->new->pretty(1)->canonical->encode($meta),
  	);
  }
  
  sub _write_mymeta_data {
  	my $self = shift;
  
  	# If there's no existing META.yml there is nothing we can do
  	return undef unless -f 'META.yml';
  
  	# We need Parse::CPAN::Meta to load the file
  	unless ( eval { require Parse::CPAN::Meta; 1; } ) {
  		return undef;
  	}
  
  	# Merge the perl version into the dependencies
  	my $val  = $self->Meta->{values};
  	my $perl = delete $val->{perl_version};
  	if ( $perl ) {
  		$val->{requires} ||= [];
  		my $requires = $val->{requires};
  
  		# Canonize to three-dot version after Perl 5.6
  		if ( $perl >= 5.006 ) {
  			$perl =~ s{^(\d+)\.(\d\d\d)(\d*)}{join('.', $1, int($2||0), int($3||0))}e
  		}
  		unshift @$requires, [ perl => $perl ];
  	}
  
  	# Load the advisory META.yml file
  	my @yaml = Parse::CPAN::Meta::LoadFile('META.yml');
  	my $meta = $yaml[0];
  
  	# Overwrite the non-configure dependency hashes
  	delete $meta->{requires};
  	delete $meta->{build_requires};
  	delete $meta->{recommends};
  	if ( exists $val->{requires} ) {
  		$meta->{requires} = { map { @$_ } @{ $val->{requires} } };
  	}
  	if ( exists $val->{build_requires} ) {
  		$meta->{build_requires} = { map { @$_ } @{ $val->{build_requires} } };
  	}
  
  	return $meta;
  }
  
  1;
---
file: inc/Module/Install/Win32.pm
template: |
  #line 1
  package Module::Install::Win32;
  
  use strict;
  use Module::Install::Base ();
  
  use vars qw{$VERSION @ISA $ISCORE};
  BEGIN {
  	$VERSION = '1.14';
  	@ISA     = 'Module::Install::Base';
  	$ISCORE  = 1;
  }
  
  # determine if the user needs nmake, and download it if needed
  sub check_nmake {
  	my $self = shift;
  	$self->load('can_run');
  	$self->load('get_file');
  
  	require Config;
  	return unless (
  		$^O eq 'MSWin32'                     and
  		$Config::Config{make}                and
  		$Config::Config{make} =~ /^nmake\b/i and
  		! $self->can_run('nmake')
  	);
  
  	print "The required 'nmake' executable not found, fetching it...\n";
  
  	require File::Basename;
  	my $rv = $self->get_file(
  		url       => 'http://download.microsoft.com/download/vc15/Patch/1.52/W95/EN-US/Nmake15.exe',
  		ftp_url   => 'ftp://ftp.microsoft.com/Softlib/MSLFILES/Nmake15.exe',
  		local_dir => File::Basename::dirname($^X),
  		size      => 51928,
  		run       => 'Nmake15.exe /o > nul',
  		check_for => 'Nmake.exe',
  		remove    => 1,
  	);
  
  	die <<'END_MESSAGE' unless $rv;
  
  -------------------------------------------------------------------------------
  
  Since you are using Microsoft Windows, you will need the 'nmake' utility
  before installation. It's available at:
  
    http://download.microsoft.com/download/vc15/Patch/1.52/W95/EN-US/Nmake15.exe
        or
    ftp://ftp.microsoft.com/Softlib/MSLFILES/Nmake15.exe
  
  Please download the file manually, save it to a directory in %PATH% (e.g.
  C:\WINDOWS\COMMAND\), then launch the MS-DOS command line shell, "cd" to
  that directory, and run "Nmake15.exe" from there; that will create the
  'nmake.exe' file needed by this module.
  
  You may then resume the installation process described in README.
  
  -------------------------------------------------------------------------------
  END_MESSAGE
  
  }
  
  1;
---
file: inc/Module/Install/Makefile.pm
template: |
  #line 1
  package Module::Install::Makefile;
  
  use strict 'vars';
  use ExtUtils::MakeMaker   ();
  use Module::Install::Base ();
  use Fcntl qw/:flock :seek/;
  
  use vars qw{$VERSION @ISA $ISCORE};
  BEGIN {
  	$VERSION = '1.14';
  	@ISA     = 'Module::Install::Base';
  	$ISCORE  = 1;
  }
  
  sub Makefile { $_[0] }
  
  my %seen = ();
  
  sub prompt {
  	shift;
  
  	# Infinite loop protection
  	my @c = caller();
  	if ( ++$seen{"$c[1]|$c[2]|$_[0]"} > 3 ) {
  		die "Caught an potential prompt infinite loop ($c[1]|$c[2]|$_[0])";
  	}
  
  	# In automated testing or non-interactive session, always use defaults
  	if ( ($ENV{AUTOMATED_TESTING} or -! -t STDIN) and ! $ENV{PERL_MM_USE_DEFAULT} ) {
  		local $ENV{PERL_MM_USE_DEFAULT} = 1;
  		goto &ExtUtils::MakeMaker::prompt;
  	} else {
  		goto &ExtUtils::MakeMaker::prompt;
  	}
  }
  
  # Store a cleaned up version of the MakeMaker version,
  # since we need to behave differently in a variety of
  # ways based on the MM version.
  my $makemaker = eval $ExtUtils::MakeMaker::VERSION;
  
  # If we are passed a param, do a "newer than" comparison.
  # Otherwise, just return the MakeMaker version.
  sub makemaker {
  	( @_ < 2 or $makemaker >= eval($_[1]) ) ? $makemaker : 0
  }
  
  # Ripped from ExtUtils::MakeMaker 6.56, and slightly modified
  # as we only need to know here whether the attribute is an array
  # or a hash or something else (which may or may not be appendable).
  my %makemaker_argtype = (
   C                  => 'ARRAY',
   CONFIG             => 'ARRAY',
  # CONFIGURE          => 'CODE', # ignore
   DIR                => 'ARRAY',
   DL_FUNCS           => 'HASH',
   DL_VARS            => 'ARRAY',
   EXCLUDE_EXT        => 'ARRAY',
   EXE_FILES          => 'ARRAY',
   FUNCLIST           => 'ARRAY',
   H                  => 'ARRAY',
   IMPORTS            => 'HASH',
   INCLUDE_EXT        => 'ARRAY',
   LIBS               => 'ARRAY', # ignore ''
   MAN1PODS           => 'HASH',
   MAN3PODS           => 'HASH',
   META_ADD           => 'HASH',
   META_MERGE         => 'HASH',
   PL_FILES           => 'HASH',
   PM                 => 'HASH',
   PMLIBDIRS          => 'ARRAY',
   PMLIBPARENTDIRS    => 'ARRAY',
   PREREQ_PM          => 'HASH',
   CONFIGURE_REQUIRES => 'HASH',
   SKIP               => 'ARRAY',
   TYPEMAPS           => 'ARRAY',
   XS                 => 'HASH',
  # VERSION            => ['version',''],  # ignore
  # _KEEP_AFTER_FLUSH  => '',
  
   clean      => 'HASH',
   depend     => 'HASH',
   dist       => 'HASH',
   dynamic_lib=> 'HASH',
   linkext    => 'HASH',
   macro      => 'HASH',
   postamble  => 'HASH',
   realclean  => 'HASH',
   test       => 'HASH',
   tool_autosplit => 'HASH',
  
   # special cases where you can use makemaker_append
   CCFLAGS   => 'APPENDABLE',
   DEFINE    => 'APPENDABLE',
   INC       => 'APPENDABLE',
   LDDLFLAGS => 'APPENDABLE',
   LDFROM    => 'APPENDABLE',
  );
  
  sub makemaker_args {
  	my ($self, %new_args) = @_;
  	my $args = ( $self->{makemaker_args} ||= {} );
  	foreach my $key (keys %new_args) {
  		if ($makemaker_argtype{$key}) {
  			if ($makemaker_argtype{$key} eq 'ARRAY') {
  				$args->{$key} = [] unless defined $args->{$key};
  				unless (ref $args->{$key} eq 'ARRAY') {
  					$args->{$key} = [$args->{$key}]
  				}
  				push @{$args->{$key}},
  					ref $new_args{$key} eq 'ARRAY'
  						? @{$new_args{$key}}
  						: $new_args{$key};
  			}
  			elsif ($makemaker_argtype{$key} eq 'HASH') {
  				$args->{$key} = {} unless defined $args->{$key};
  				foreach my $skey (keys %{ $new_args{$key} }) {
  					$args->{$key}{$skey} = $new_args{$key}{$skey};
  				}
  			}
  			elsif ($makemaker_argtype{$key} eq 'APPENDABLE') {
  				$self->makemaker_append($key => $new_args{$key});
  			}
  		}
  		else {
  			if (defined $args->{$key}) {
  				warn qq{MakeMaker attribute "$key" is overriden; use "makemaker_append" to append values\n};
  			}
  			$args->{$key} = $new_args{$key};
  		}
  	}
  	return $args;
  }
  
  # For mm args that take multiple space-separated args,
  # append an argument to the current list.
  sub makemaker_append {
  	my $self = shift;
  	my $name = shift;
  	my $args = $self->makemaker_args;
  	$args->{$name} = defined $args->{$name}
  		? join( ' ', $args->{$name}, @_ )
  		: join( ' ', @_ );
  }
  
  sub build_subdirs {
  	my $self    = shift;
  	my $subdirs = $self->makemaker_args->{DIR} ||= [];
  	for my $subdir (@_) {
  		push @$subdirs, $subdir;
  	}
  }
  
  sub clean_files {
  	my $self  = shift;
  	my $clean = $self->makemaker_args->{clean} ||= {};
  	  %$clean = (
  		%$clean,
  		FILES => join ' ', grep { length $_ } ($clean->{FILES} || (), @_),
  	);
  }
  
  sub realclean_files {
  	my $self      = shift;
  	my $realclean = $self->makemaker_args->{realclean} ||= {};
  	  %$realclean = (
  		%$realclean,
  		FILES => join ' ', grep { length $_ } ($realclean->{FILES} || (), @_),
  	);
  }
  
  sub libs {
  	my $self = shift;
  	my $libs = ref $_[0] ? shift : [ shift ];
  	$self->makemaker_args( LIBS => $libs );
  }
  
  sub inc {
  	my $self = shift;
  	$self->makemaker_args( INC => shift );
  }
  
  sub _wanted_t {
  }
  
  sub tests_recursive {
  	my $self = shift;
  	my $dir = shift || 't';
  	unless ( -d $dir ) {
  		die "tests_recursive dir '$dir' does not exist";
  	}
  	my %tests = map { $_ => 1 } split / /, ($self->tests || '');
  	require File::Find;
  	File::Find::find(
          sub { /\.t$/ and -f $_ and $tests{"$File::Find::dir/*.t"} = 1 },
          $dir
      );
  	$self->tests( join ' ', sort keys %tests );
  }
  
  sub write {
  	my $self = shift;
  	die "&Makefile->write() takes no arguments\n" if @_;
  
  	# Check the current Perl version
  	my $perl_version = $self->perl_version;
  	if ( $perl_version ) {
  		eval "use $perl_version; 1"
  			or die "ERROR: perl: Version $] is installed, "
  			. "but we need version >= $perl_version";
  	}
  
  	# Make sure we have a new enough MakeMaker
  	require ExtUtils::MakeMaker;
  
  	if ( $perl_version and $self->_cmp($perl_version, '5.006') >= 0 ) {
  		# This previous attempted to inherit the version of
  		# ExtUtils::MakeMaker in use by the module author, but this
  		# was found to be untenable as some authors build releases
  		# using future dev versions of EU:MM that nobody else has.
  		# Instead, #toolchain suggests we use 6.59 which is the most
  		# stable version on CPAN at time of writing and is, to quote
  		# ribasushi, "not terminally fucked, > and tested enough".
  		# TODO: We will now need to maintain this over time to push
  		# the version up as new versions are released.
  		$self->build_requires(     'ExtUtils::MakeMaker' => 6.59 );
  		$self->configure_requires( 'ExtUtils::MakeMaker' => 6.59 );
  	} else {
  		# Allow legacy-compatibility with 5.005 by depending on the
  		# most recent EU:MM that supported 5.005.
  		$self->build_requires(     'ExtUtils::MakeMaker' => 6.36 );
  		$self->configure_requires( 'ExtUtils::MakeMaker' => 6.36 );
  	}
  
  	# Generate the MakeMaker params
  	my $args = $self->makemaker_args;
  	$args->{DISTNAME} = $self->name;
  	$args->{NAME}     = $self->module_name || $self->name;
  	$args->{NAME}     =~ s/-/::/g;
  	$args->{VERSION}  = $self->version or die <<'EOT';
  ERROR: Can't determine distribution version. Please specify it
  explicitly via 'version' in Makefile.PL, or set a valid $VERSION
  in a module, and provide its file path via 'version_from' (or
  'all_from' if you prefer) in Makefile.PL.
  EOT
  
  	if ( $self->tests ) {
  		my @tests = split ' ', $self->tests;
  		my %seen;
  		$args->{test} = {
  			TESTS => (join ' ', grep {!$seen{$_}++} @tests),
  		};
      } elsif ( $Module::Install::ExtraTests::use_extratests ) {
          # Module::Install::ExtraTests doesn't set $self->tests and does its own tests via harness.
          # So, just ignore our xt tests here.
  	} elsif ( -d 'xt' and ($Module::Install::AUTHOR or $ENV{RELEASE_TESTING}) ) {
  		$args->{test} = {
  			TESTS => join( ' ', map { "$_/*.t" } grep { -d $_ } qw{ t xt } ),
  		};
  	}
  	if ( $] >= 5.005 ) {
  		$args->{ABSTRACT} = $self->abstract;
  		$args->{AUTHOR}   = join ', ', @{$self->author || []};
  	}
  	if ( $self->makemaker(6.10) ) {
  		$args->{NO_META}   = 1;
  		#$args->{NO_MYMETA} = 1;
  	}
  	if ( $self->makemaker(6.17) and $self->sign ) {
  		$args->{SIGN} = 1;
  	}
  	unless ( $self->is_admin ) {
  		delete $args->{SIGN};
  	}
  	if ( $self->makemaker(6.31) and $self->license ) {
  		$args->{LICENSE} = $self->license;
  	}
  
  	my $prereq = ($args->{PREREQ_PM} ||= {});
  	%$prereq = ( %$prereq,
  		map { @$_ } # flatten [module => version]
  		map { @$_ }
  		grep $_,
  		($self->requires)
  	);
  
  	# Remove any reference to perl, PREREQ_PM doesn't support it
  	delete $args->{PREREQ_PM}->{perl};
  
  	# Merge both kinds of requires into BUILD_REQUIRES
  	my $build_prereq = ($args->{BUILD_REQUIRES} ||= {});
  	%$build_prereq = ( %$build_prereq,
  		map { @$_ } # flatten [module => version]
  		map { @$_ }
  		grep $_,
  		($self->configure_requires, $self->build_requires)
  	);
  
  	# Remove any reference to perl, BUILD_REQUIRES doesn't support it
  	delete $args->{BUILD_REQUIRES}->{perl};
  
  	# Delete bundled dists from prereq_pm, add it to Makefile DIR
  	my $subdirs = ($args->{DIR} || []);
  	if ($self->bundles) {
  		my %processed;
  		foreach my $bundle (@{ $self->bundles }) {
  			my ($mod_name, $dist_dir) = @$bundle;
  			delete $prereq->{$mod_name};
  			$dist_dir = File::Basename::basename($dist_dir); # dir for building this module
  			if (not exists $processed{$dist_dir}) {
  				if (-d $dist_dir) {
  					# List as sub-directory to be processed by make
  					push @$subdirs, $dist_dir;
  				}
  				# Else do nothing: the module is already present on the system
  				$processed{$dist_dir} = undef;
  			}
  		}
  	}
  
  	unless ( $self->makemaker('6.55_03') ) {
  		%$prereq = (%$prereq,%$build_prereq);
  		delete $args->{BUILD_REQUIRES};
  	}
  
  	if ( my $perl_version = $self->perl_version ) {
  		eval "use $perl_version; 1"
  			or die "ERROR: perl: Version $] is installed, "
  			. "but we need version >= $perl_version";
  
  		if ( $self->makemaker(6.48) ) {
  			$args->{MIN_PERL_VERSION} = $perl_version;
  		}
  	}
  
  	if ($self->installdirs) {
  		warn qq{old INSTALLDIRS (probably set by makemaker_args) is overriden by installdirs\n} if $args->{INSTALLDIRS};
  		$args->{INSTALLDIRS} = $self->installdirs;
  	}
  
  	my %args = map {
  		( $_ => $args->{$_} ) } grep {defined($args->{$_} )
  	} keys %$args;
  
  	my $user_preop = delete $args{dist}->{PREOP};
  	if ( my $preop = $self->admin->preop($user_preop) ) {
  		foreach my $key ( keys %$preop ) {
  			$args{dist}->{$key} = $preop->{$key};
  		}
  	}
  
  	my $mm = ExtUtils::MakeMaker::WriteMakefile(%args);
  	$self->fix_up_makefile($mm->{FIRST_MAKEFILE} || 'Makefile');
  }
  
  sub fix_up_makefile {
  	my $self          = shift;
  	my $makefile_name = shift;
  	my $top_class     = ref($self->_top) || '';
  	my $top_version   = $self->_top->VERSION || '';
  
  	my $preamble = $self->preamble
  		? "# Preamble by $top_class $top_version\n"
  			. $self->preamble
  		: '';
  	my $postamble = "# Postamble by $top_class $top_version\n"
  		. ($self->postamble || '');
  
  	local *MAKEFILE;
  	open MAKEFILE, "+< $makefile_name" or die "fix_up_makefile: Couldn't open $makefile_name: $!";
  	eval { flock MAKEFILE, LOCK_EX };
  	my $makefile = do { local $/; <MAKEFILE> };
  
  	$makefile =~ s/\b(test_harness\(\$\(TEST_VERBOSE\), )/$1'inc', /;
  	$makefile =~ s/( -I\$\(INST_ARCHLIB\))/ -Iinc$1/g;
  	$makefile =~ s/( "-I\$\(INST_LIB\)")/ "-Iinc"$1/g;
  	$makefile =~ s/^(FULLPERL = .*)/$1 "-Iinc"/m;
  	$makefile =~ s/^(PERL = .*)/$1 "-Iinc"/m;
  
  	# Module::Install will never be used to build the Core Perl
  	# Sometimes PERL_LIB and PERL_ARCHLIB get written anyway, which breaks
  	# PREFIX/PERL5LIB, and thus, install_share. Blank them if they exist
  	$makefile =~ s/^PERL_LIB = .+/PERL_LIB =/m;
  	#$makefile =~ s/^PERL_ARCHLIB = .+/PERL_ARCHLIB =/m;
  
  	# Perl 5.005 mentions PERL_LIB explicitly, so we have to remove that as well.
  	$makefile =~ s/(\"?)-I\$\(PERL_LIB\)\1//g;
  
  	# XXX - This is currently unused; not sure if it breaks other MM-users
  	# $makefile =~ s/^pm_to_blib\s+:\s+/pm_to_blib :: /mg;
  
  	seek MAKEFILE, 0, SEEK_SET;
  	truncate MAKEFILE, 0;
  	print MAKEFILE  "$preamble$makefile$postamble" or die $!;
  	close MAKEFILE  or die $!;
  
  	1;
  }
  
  sub preamble {
  	my ($self, $text) = @_;
  	$self->{preamble} = $text . $self->{preamble} if defined $text;
  	$self->{preamble};
  }
  
  sub postamble {
  	my ($self, $text) = @_;
  	$self->{postamble} ||= $self->admin->postamble;
  	$self->{postamble} .= $text if defined $text;
  	$self->{postamble}
  }
  
  1;
  
  __END__
  
  #line 544
---
file: inc/Module/Install/WriteAll.pm
template: |
  #line 1
  package Module::Install::WriteAll;
  
  use strict;
  use Module::Install::Base ();
  
  use vars qw{$VERSION @ISA $ISCORE};
  BEGIN {
  	$VERSION = '1.14';
  	@ISA     = qw{Module::Install::Base};
  	$ISCORE  = 1;
  }
  
  sub WriteAll {
  	my $self = shift;
  	my %args = (
  		meta        => 1,
  		sign        => 0,
  		inline      => 0,
  		check_nmake => 1,
  		@_,
  	);
  
  	$self->sign(1)                if $args{sign};
  	$self->admin->WriteAll(%args) if $self->is_admin;
  
  	$self->check_nmake if $args{check_nmake};
  	unless ( $self->makemaker_args->{PL_FILES} ) {
  		# XXX: This still may be a bit over-defensive...
  		unless ($self->makemaker(6.25)) {
  			$self->makemaker_args( PL_FILES => {} ) if -f 'Build.PL';
  		}
  	}
  
  	# Until ExtUtils::MakeMaker support MYMETA.yml, make sure
  	# we clean it up properly ourself.
  	$self->realclean_files('MYMETA.yml');
  
  	if ( $args{inline} ) {
  		$self->Inline->write;
  	} else {
  		$self->Makefile->write;
  	}
  
  	# The Makefile write process adds a couple of dependencies,
  	# so write the META.yml files after the Makefile.
  	if ( $args{meta} ) {
  		$self->Meta->write;
  	}
  
  	# Experimental support for MYMETA
  	if ( $ENV{X_MYMETA} ) {
  		if ( $ENV{X_MYMETA} eq 'JSON' ) {
  			$self->Meta->write_mymeta_json;
  		} else {
  			$self->Meta->write_mymeta_yaml;
  		}
  	}
  
  	return 1;
  }
  
  1;
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
        root => $home->file('htdocs-explorer');
  
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
  
  my $urlmap = Plack::App::URLMap->new;
  $urlmap->map("/" => $explorer); # XXX
  $urlmap->map("/api" => $api);
  $urlmap->map("/explorer" => $explorer);
  
  $urlmap->to_app;
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
        root => $home->file('htdocs-op');
  
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
file: bin/filegenerator.pl
template: |+
  #!/usr/bin/env perl
  
  use strict;
  use warnings;
  use FindBin::libs ;
  use <+ dist +>::FileGenerator;
  
  <+ dist +>::FileGenerator->run();
  

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
file: bin/tool/op_i18n.pl
template: |
  #!/usr/bin/env perl
  
  system( 'xgettext.pl -D view-include/op -D view-op-D -o po/op/ja_JP.po' );
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


