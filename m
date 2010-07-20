From: thornber@sourceware.org <thornber@sourceware.org>
Date: 20 Jul 2010 14:38:49 -0000
Subject: LVM2 ./Makefile.in ./configure.in ./make.tmpl. ...
Message-ID: <20100720143849.13269.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	thornber at sourceware.org	2010-07-20 14:38:45

Modified files:
	.              : Makefile.in configure.in make.tmpl.in 
Added files:
	report-generators: memcheck.rb title_page.rb unit_test.rb 
	report-generators/lib: log.rb report_templates.rb reports.rb 
	                       schedule_file.rb string-store.rb 
	report-generators/templates: boiler_plate.rhtml index.rhtml 
	                             memcheck.rhtml unit_detail.rhtml 
	                             unit_test.rhtml 
	report-generators/test: example.schedule tc_log.rb 
	                        tc_schedule_file.rb tc_string_store.rb 
	                        ts.rb 
	report-generators/test/strings: test1.txt test2 
	report-generators/test/strings/more_strings: test3.txt 
	reports        : stylesheet.css 

Log message:
	Report generators for unit tests and memory checks.  Configure with
	--enable-testing.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/Makefile.in.diff?cvsroot=lvm2&r1=1.55&r2=1.56
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.in.diff?cvsroot=lvm2&r1=1.146&r2=1.147
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/make.tmpl.in.diff?cvsroot=lvm2&r1=1.105&r2=1.106
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/report-generators/memcheck.rb.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/report-generators/title_page.rb.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/report-generators/unit_test.rb.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/report-generators/lib/log.rb.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/report-generators/lib/report_templates.rb.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/report-generators/lib/reports.rb.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/report-generators/lib/schedule_file.rb.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/report-generators/lib/string-store.rb.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/report-generators/templates/boiler_plate.rhtml.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/report-generators/templates/index.rhtml.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/report-generators/templates/memcheck.rhtml.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/report-generators/templates/unit_detail.rhtml.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/report-generators/templates/unit_test.rhtml.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/report-generators/test/example.schedule.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/report-generators/test/tc_log.rb.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/report-generators/test/tc_schedule_file.rb.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/report-generators/test/tc_string_store.rb.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/report-generators/test/ts.rb.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/report-generators/test/strings/test1.txt.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/report-generators/test/strings/test2.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/report-generators/test/strings/more_strings/test3.txt.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/reports/stylesheet.css.diff?cvsroot=lvm2&r1=NONE&r2=1.1

--- LVM2/Makefile.in	2010/05/24 09:04:27	1.55
+++ LVM2/Makefile.in	2010/07/20 14:38:44	1.56
@@ -127,3 +127,23 @@
 endif
 
 endif
+
+ifeq ("$(TESTING)", "yes")
+# testing and report generation
+RUBY=ruby1.9 -Ireport-generators/lib -Ireport-generators/test
+
+.PHONEY: unit-test ruby-test test-programs
+
+test-programs:
+
+unit-test: test-programs
+	$(RUBY) report-generators/unit_test.rb $(shell find . -name TESTS)
+	$(RUBY) report-generators/title_page.rb
+
+memcheck: test-programs
+	$(RUBY) report-generators/memcheck.rb $(shell find . -name TESTS)
+	$(RUBY) report-generators/title_page.rb
+
+ruby-test:
+	$(RUBY) report-generators/test/ts.rb
+endif
\ No newline at end of file
--- LVM2/configure.in	2010/07/13 13:51:01	1.146
+++ LVM2/configure.in	2010/07/20 14:38:44	1.147
@@ -701,6 +701,22 @@
 fi
 
 ################################################################################
+dnl -- Enable testing
+AC_MSG_CHECKING(whether to enable unit testing)
+AC_ARG_ENABLE(testing,
+              AC_HELP_STRING(--enable-testing, [enable testing targets in the makefile]),
+              TESTING=$enableval, TESTING=no)
+AC_MSG_RESULT($TESTING)
+
+if test "$TESTING" = yes; then
+   AC_PATH_PROG(RUBY19, ruby1.9)
+   AC_PATH_PROG(VALGRIND, valgrind)
+   if test -z "$RUBY19" -o -z "$VALGRIND"; then
+       AC_MSG_ERROR([ruby1.9 and valgrind are required for testing])
+   fi
+fi
+
+################################################################################
 dnl -- Disable devmapper
 AC_MSG_CHECKING(whether to use device-mapper)
 AC_ARG_ENABLE(devmapper,
@@ -1260,6 +1276,7 @@
 AC_SUBST(SNAPSHOTS)
 AC_SUBST(STATICDIR)
 AC_SUBST(STATIC_LINK)
+AC_SUBST(TESTING)
 AC_SUBST(UDEV_LIBS)
 AC_SUBST(UDEV_PC)
 AC_SUBST(UDEV_RULES)
--- LVM2/make.tmpl.in	2010/07/09 15:26:41	1.105
+++ LVM2/make.tmpl.in	2010/07/20 14:38:44	1.106
@@ -45,6 +45,7 @@
 READLINE_LIBS = @READLINE_LIBS@
 SELINUX_LIBS = @SELINUX_LIBS@
 UDEV_LIBS = @UDEV_LIBS@
+TESTING = @TESTING@
 
 # Setup directory variables
 prefix = @prefix@
/cvs/lvm2/LVM2/report-generators/memcheck.rb,v  -->  standard output
revision 1.1
--- LVM2/report-generators/memcheck.rb
+++ -	2010-07-20 14:38:47.194654000 +0000
@@ -0,0 +1,76 @@
+# Reads the schedule files given on the command line.  Runs them and
+# generates the reports.
+
+# FIXME: a lot of duplication with unit_test.rb
+
+require 'schedule_file'
+require 'pathname'
+require 'reports'
+require 'erb'
+require 'report_templates'
+
+include ReportTemplates
+
+schedules = ARGV.map do |f|
+  p = Pathname.new(f)
+  Schedule.read(p.dirname, p)
+end
+
+total_passed = 0
+total_failed = 0
+
+# We need to make sure the lvm shared libs are in the LD_LIBRARY_PATH
+ENV['LD_LIBRARY_PATH'] = `pwd`.strip + "/libdm:" + (ENV['LD_LIBRARY_PATH'] || '')
+
+ENV['TEST_TOOL'] = "valgrind --leak-check=full --show-reachable=yes"
+
+schedules.each do |s|
+  s.run
+
+  s.schedules.each do |t|
+    if t.status.success?
+      total_passed += 1
+    else
+      total_failed += 1
+    end
+  end
+end
+
+def mangle(txt)
+  txt.gsub(/\s+/, '_')
+end
+
+MemcheckStats = Struct.new(:definitely_lost, :indirectly_lost, :possibly_lost, :reachable)
+
+def format(bytes, blocks)
+  "#{bytes} bytes, #{blocks} blocks"
+end
+
+# Examines the output for details of leaks
+def extract_stats(t)
+  d = i = p = r = '-'
+
+  t.output.split("\n").each do |l|
+    case l
+    when /==\d+==    definitely lost: ([0-9,]+) bytes in ([0-9,]+) blocks/
+        d = format($1, $2)
+    when /==\d+==    indirectly lost: ([0-9,]+) bytes in ([0-9,]+) blocks/
+        i = format($1, $2)
+    when /==\d+==    possibly lost: ([0-9,]+) bytes in ([0-9,]+) blocks/
+        p = format($1, $2)
+    when /==\d+==    still reachable: ([0-9,]+) bytes in ([0-9,]+) blocks/
+        r = format($1, $2)
+    end
+  end
+
+  MemcheckStats.new(d, i, p, r)
+end
+
+generate_report(:memcheck, binding)
+
+# now we generate a detail report for each schedule
+schedules.each do |s|
+  s.schedules.each do |t|
+    generate_report(:unit_detail, binding, Pathname.new("reports/memcheck_#{mangle(t.desc)}.html"))
+  end
+end
/cvs/lvm2/LVM2/report-generators/title_page.rb,v  -->  standard output
revision 1.1
--- LVM2/report-generators/title_page.rb
+++ -	2010-07-20 14:38:47.282849000 +0000
@@ -0,0 +1,32 @@
+# This generates the index for the reports, including generation
+# times.
+
+require 'log'
+require 'string-store'
+require 'reports'
+require 'erb'
+require 'report_templates'
+
+include Reports
+
+reports = ReportRegister.new
+
+def safe_mtime(r)
+  r.path.file? ? r.path.mtime.to_s : "not generated"
+end
+
+template_store = TemplateStringStore.new
+
+# FIXME: use generate_report() method
+erb = ERB.new(template_store.lookup("index.rhtml"))
+body = erb.result(binding)
+title = "Generation times"
+
+erb = ERB.new(template_store.lookup("boiler_plate.rhtml"))
+txt = erb.result(binding)
+
+Pathname.new("reports/index.html").open("w") do |f|
+  f.puts txt
+end
+
+
/cvs/lvm2/LVM2/report-generators/unit_test.rb,v  -->  standard output
revision 1.1
--- LVM2/report-generators/unit_test.rb
+++ -	2010-07-20 14:38:47.375377000 +0000
@@ -0,0 +1,46 @@
+# Reads the schedule files given on the command line.  Runs them and
+# generates the reports.
+
+require 'schedule_file'
+require 'pathname'
+require 'reports'
+require 'erb'
+require 'report_templates'
+
+include ReportTemplates
+
+schedules = ARGV.map do |f|
+  p = Pathname.new(f)
+  Schedule.read(p.dirname, p)
+end
+
+total_passed = 0
+total_failed = 0
+
+# We need to make sure the lvm shared libs are in the LD_LIBRARY_PATH
+ENV['LD_LIBRARY_PATH'] = `pwd`.strip + "/libdm:" + (ENV['LD_LIBRARY_PATH'] || '')
+
+schedules.each do |s|
+  s.run
+
+  s.schedules.each do |t|
+    if t.status.success?
+      total_passed += 1
+    else
+      total_failed += 1
+    end
+  end
+end
+
+def mangle(txt)
+  txt.gsub(/\s+/, '_')
+end
+
+generate_report(:unit_test, binding)
+
+# now we generate a detail report for each schedule
+schedules.each do |s|
+  s.schedules.each do |t|
+    generate_report(:unit_detail, binding, Pathname.new("reports/detail_#{mangle(t.desc)}.html"))
+  end
+end
/cvs/lvm2/LVM2/report-generators/lib/log.rb,v  -->  standard output
revision 1.1
--- LVM2/report-generators/lib/log.rb
+++ -	2010-07-20 14:38:47.484273000 +0000
@@ -0,0 +1,30 @@
+# Merely wraps the logger library with a bit of standard policy.
+require 'logger'
+
+module Log
+  $log = Logger.new(STDERR)
+
+  def init(io_)
+    $log = Logger.new(io_)
+  end
+end
+
+def fatal(*args)
+  $log.fatal(*args)
+end
+
+def error(*args)
+  $log.error(*args)
+end
+
+def info(*args)
+  $log.info(*args)
+end
+
+def warning(*args)
+  $log.warn(*args)
+end
+
+def debug(*args)
+  $log.debug(*args)
+end
/cvs/lvm2/LVM2/report-generators/lib/report_templates.rb,v  -->  standard output
revision 1.1
--- LVM2/report-generators/lib/report_templates.rb
+++ -	2010-07-20 14:38:47.575408000 +0000
@@ -0,0 +1,28 @@
+# Policy for the location of report templates
+require 'string-store'
+
+class TemplateStringStore < StringStore
+  def initialize()
+    super(['report-generators/templates'])
+  end
+end
+
+module ReportTemplates
+  def generate_report(report, bs, dest_path = nil)
+    include Reports
+    reports = ReportRegister.new
+    template_store = TemplateStringStore.new
+    report = reports.get_report(report)
+    erb = ERB.new(template_store.lookup(report.template))
+    body = erb.result(bs)
+    title = report.short_desc
+
+    erb = ERB.new(template_store.lookup("boiler_plate.rhtml"))
+    txt = erb.result(binding)
+
+    dest_path = dest_path.nil? ? report.path : dest_path
+    dest_path.open("w") do |out|
+      out.puts txt
+    end
+  end
+end
/cvs/lvm2/LVM2/report-generators/lib/reports.rb,v  -->  standard output
revision 1.1
--- LVM2/report-generators/lib/reports.rb
+++ -	2010-07-20 14:38:47.677539000 +0000
@@ -0,0 +1,48 @@
+# Data about the various reports we support
+require 'log'
+require 'pathname'
+
+module Reports
+  Report = Struct.new(:short_desc, :desc, :path, :template)
+
+  class ReportRegister
+    attr_reader :reports
+
+    private
+    def add_report(sym, *args)
+      @reports[sym] = Report.new(*args)
+    end
+
+    public
+    def initialize()
+      @reports = Hash.new
+
+      add_report(:unit_test,
+                 "Unit Tests",
+                 "unit tests",
+                 Pathname.new("reports/unit.html"),
+                 Pathname.new("unit_test.rhtml"))
+
+      add_report(:memcheck,
+                 "Memory Tests",
+                 "unit tests with valgrind memory checking",
+                 Pathname.new("reports/memcheck.html"),
+                 Pathname.new("memcheck.rhtml"))
+
+      add_report(:unit_detail,
+                 "Unit Test Detail",
+                 "unit test detail",
+                 Pathname.new("reports/unit_detail.html"), # FIXME replace this with a lambda
+                 Pathname.new("unit_detail.rhtml"))
+    end
+
+    def get_report(sym)
+      raise RuntimeError, "unknown report '#{sym}'" unless @reports.member?(sym)
+      @reports[sym]
+    end
+
+    def each(&block)
+      @reports.each(&block)
+    end
+  end
+end
/cvs/lvm2/LVM2/report-generators/lib/schedule_file.rb,v  -->  standard output
revision 1.1
--- LVM2/report-generators/lib/schedule_file.rb
+++ -	2010-07-20 14:38:47.777302000 +0000
@@ -0,0 +1,46 @@
+# Parses the simple colon delimited test schedule files.
+
+ScheduledTest = Struct.new(:desc, :command_line, :status, :output)
+
+class Schedule
+  attr_reader :dir, :schedules
+
+  def initialize(dir, ss)
+    @dir = dir
+    @schedules = ss
+  end
+
+  def run
+    Dir::chdir(@dir.to_s) do
+      @schedules.each do |s|
+        reader, writer = IO.pipe
+        print "#{s.desc} ... "
+        pid = spawn(s.command_line, [ STDERR, STDOUT ] => writer)
+        writer.close
+        _, s.status = Process::waitpid2(pid)
+        puts (s.status.success? ? "pass" : "fail")
+        s.output = reader.read
+      end
+    end
+  end
+
+  def self.read(dir, io)
+    ss = Array.new
+
+    io.readlines.each do |line|
+      case line.strip
+      when /^\#.*/
+        next
+
+      when /([^:]+):(.*)/
+        ss << ScheduledTest.new($1.strip, $2.strip)
+
+      else
+        raise RuntimeError, "badly formatted schedule line"
+      end  
+    end
+
+    Schedule.new(dir, ss)
+  end
+end
+
/cvs/lvm2/LVM2/report-generators/lib/string-store.rb,v  -->  standard output
revision 1.1
--- LVM2/report-generators/lib/string-store.rb
+++ -	2010-07-20 14:38:47.872851000 +0000
@@ -0,0 +1,32 @@
+# Provides a simple way of accessing the contents of files by a symbol
+# name.  Useful for erb templates.
+
+require 'pathname'
+
+class StringStore
+  attr_accessor :path
+
+  def initialize(p)
+    @paths = p.nil? ? Array.new : p # FIXME: do we need to copy p ?
+  end
+
+  def lookup(sym)
+    files = expansions(sym)
+
+    @paths.each do |p|
+      files.each do |f|
+        pn = Pathname.new("#{p}/#{f}")
+        if pn.file?
+          return pn.read
+        end
+      end
+    end
+
+    raise RuntimeError, "unknown string entry: #{sym}"
+  end
+
+  private
+  def expansions(sym)
+    ["#{sym}", "#{sym}.txt"]
+  end
+end
/cvs/lvm2/LVM2/report-generators/templates/boiler_plate.rhtml,v  -->  standard output
revision 1.1
--- LVM2/report-generators/templates/boiler_plate.rhtml
+++ -	2010-07-20 14:38:48.000343000 +0000
@@ -0,0 +1,25 @@
+<html>
+<head>
+<META http-equiv="Content-Type" content="text/html; charset=US-ASCII">
+<title><%= title %></title>
+<link title="Style" type="text/css" rel="stylesheet" href="stylesheet.css">
+</head>
+
+<body>
+<div id="banner">
+<h2><%= title %></h2>
+</div>
+<div id="main">
+  <div id="controls">
+    <table>
+      <tr><td><a href="index.html">Generation times</a></td></tr>
+      <tr><td><a href="unit.html">Unit tests</a></td></tr>
+      <tr><td><a href="memcheck.html">Memory tests</a></td></tr>
+    </table>
+  </div>
+
+  <div id="body">
+    <%= body %>
+  </div>
+</div>
+</body>
/cvs/lvm2/LVM2/report-generators/templates/index.rhtml,v  -->  standard output
revision 1.1
--- LVM2/report-generators/templates/index.rhtml
+++ -	2010-07-20 14:38:48.082931000 +0000
@@ -0,0 +1,17 @@
+<table width="95%" cellspacing="2" cellpadding="5" border="0" class="stripes">
+<tr><th>Report</th><th>Generation time</th></tr>
+<% [:unit_test, :memcheck].each do |sym| %>
+<% r = reports.get_report(sym) %>
+<tr>
+  <td>
+    <% if r.path.file? %>
+    <a href="<%= r.path.to_s.gsub(/^reports\//, '') %>"><%= r.short_desc %></a>
+    <% else %>
+    <%= r.short_desc %>
+    <% end %>
+  </td>
+  <td><%= safe_mtime(r) %></td>
+</tr>
+<% end %>
+</table>
+
/cvs/lvm2/LVM2/report-generators/templates/memcheck.rhtml,v  -->  standard output
revision 1.1
--- LVM2/report-generators/templates/memcheck.rhtml
+++ -	2010-07-20 14:38:48.164010000 +0000
@@ -0,0 +1,30 @@
+<table width="95%" cellspacing="2" cellpadding="5" border="0" class="stripes">
+  <tr><th>Tests passed</th><th>Tests failed</th></tr>
+  <tr><td class="pass"><%= total_passed %></td><td <%= total_failed == 0 ? "" : "class=\"fail\""%>><%= total_failed %></td></tr>
+</table>
+
+<% schedules.each do |s| %>
+<h3><%= s.dir.sub('./unit-tests/', '') %></h3>
+<table width="95%" cellspacing="2" cellpadding="5" border="0" class="stripes">
+<tr><th>Test</th><th>Result</th><th>Definitely lost</th><th>indirectly lost</th><th>possibly lost</th><th>still reachable</th><tr>
+
+<% s.schedules.each do |t| %>
+<tr>
+  <td>
+  <a href="memcheck_<%= mangle(t.desc) %>.html"><%= t.desc %></a>
+  </td>
+  <% if t.status.success? %>
+  <td class="pass">pass</td>
+  <% else %>
+  <td class="fail">fail</td>
+  <% end %>
+ 
+  <% stats = extract_stats(t) %>
+  <td><%= stats.definitely_lost %></td>
+  <td><%= stats.indirectly_lost %></td>
+  <td><%= stats.possibly_lost %></td>
+  <td><%= stats.reachable %></td>
+</tr>
+<% end %>
+</table>
+<% end %>
/cvs/lvm2/LVM2/report-generators/templates/unit_detail.rhtml,v  -->  standard output
revision 1.1
--- LVM2/report-generators/templates/unit_detail.rhtml
+++ -	2010-07-20 14:38:48.264240000 +0000
@@ -0,0 +1,37 @@
+<table width="95%" cellspacing="2" cellpadding="5" border="0" class="stripes">
+<tr><th>Test</th><th>Result</th></tr>
+<tr>
+  <td>
+  <%= t.desc %>
+  </td>
+  <% if t.status.success? %>
+  <td class="pass">pass</td>
+  <% else %>
+  <td class="fail">fail</td>
+  <% end %>
+</tr>
+</table>
+
+<table width="95%" cellspacing="2" cellpadding="5" border="0" class="stripes">
+<tr><th>Command line</th></tr>
+<tr>
+  <td>
+  <pre>
+<%= t.command_line %>
+  </pre>
+  </td>
+</tr>
+</table>
+
+
+<table width="95%" cellspacing="2" cellpadding="5" border="0" class="stripes">
+<tr><th>Output</th></tr>
+<tr>
+  <td>
+  <pre>
+<%= t.output %>
+  </pre>
+  </td>
+</tr>
+</table>
+
/cvs/lvm2/LVM2/report-generators/templates/unit_test.rhtml,v  -->  standard output
revision 1.1
--- LVM2/report-generators/templates/unit_test.rhtml
+++ -	2010-07-20 14:38:48.350577000 +0000
@@ -0,0 +1,23 @@
+<table width="95%" cellspacing="2" cellpadding="5" border="0" class="stripes">
+  <tr><th>Tests passed</th><th>Tests failed</th></tr>
+  <tr><td class="pass"><%= total_passed %></td><td <%= total_failed == 0 ? "" : "class=\"fail\""%>><%= total_failed %></td></tr>
+</table>
+
+<% schedules.each do |s| %>
+<h3><%= s.dir.sub('./unit-tests/', '') %></h3>
+<table width="95%" cellspacing="2" cellpadding="5" border="0" class="stripes">
+<tr><th>Test</th><th>Result</th></tr>
+<% s.schedules.each do |t| %>
+<tr>
+  <td>
+  <a href="detail_<%= mangle(t.desc) %>.html"><%= t.desc %></a>
+  </td>
+  <% if t.status.success? %>
+  <td class="pass">pass</td>
+  <% else %>
+  <td class="fail">fail</td>
+  <% end %>
+</tr>
+<% end %>
+</table>
+<% end %>
/cvs/lvm2/LVM2/report-generators/test/example.schedule,v  -->  standard output
revision 1.1
--- LVM2/report-generators/test/example.schedule
+++ -	2010-07-20 14:38:48.459280000 +0000
@@ -0,0 +1,4 @@
+# This is a comment
+description number 1:$TEST_TOOL ls
+foo bar:   $TEST_TOOL du -hs .
+   	this comment is prefixed with whitespace: $TEST_TOOL date
\ No newline at end of file
/cvs/lvm2/LVM2/report-generators/test/tc_log.rb,v  -->  standard output
revision 1.1
--- LVM2/report-generators/test/tc_log.rb
+++ -	2010-07-20 14:38:48.726055000 +0000
@@ -0,0 +1,26 @@
+require 'test/unit'
+require 'stringio'
+require 'log'
+
+class TestLog < Test::Unit::TestCase
+  include Log
+
+  private
+  def remove_timestamps(l)
+    l.gsub(/\[[^\]]*\]/, '')
+  end
+
+  public
+  def test_log
+    StringIO.open do |out|
+      init(out)
+
+      info("msg1")
+      warning("msg2")
+      debug("msg3")
+
+      assert_equal("I,   INFO -- : msg1\nW,   WARN -- : msg2\nD,  DEBUG -- : msg3\n",
+                   remove_timestamps(out.string))
+    end
+  end
+end
/cvs/lvm2/LVM2/report-generators/test/tc_schedule_file.rb,v  -->  standard output
revision 1.1
--- LVM2/report-generators/test/tc_schedule_file.rb
+++ -	2010-07-20 14:38:48.840419000 +0000
@@ -0,0 +1,28 @@
+require 'test/unit'
+require 'pathname'
+require 'schedule_file'
+
+class TestScheduleFile < Test::Unit::TestCase
+  def test_reading
+    p = Pathname.new("report-generators/test/example.schedule")
+    p.open do |f|
+      s = Schedule.read(p.dirname, f)
+
+      assert_equal(3, s.schedules.size)
+      assert_equal(s.schedules[2].desc, "this comment is prefixed with whitespace")
+      assert_equal(s.schedules[0].command_line, "$TEST_TOOL ls")
+    end
+  end
+
+  def test_running
+    p = Pathname.new("report-generators/test/example.schedule")
+    p.open do |f|
+      s = Schedule.read(p.dirname, f)
+      s.run
+
+      s.schedules.each do |t|
+        assert(t.status.success?)
+      end
+    end
+  end
+end
/cvs/lvm2/LVM2/report-generators/test/tc_string_store.rb,v  -->  standard output
revision 1.1
--- LVM2/report-generators/test/tc_string_store.rb
+++ -	2010-07-20 14:38:48.924590000 +0000
@@ -0,0 +1,19 @@
+require 'string-store'
+require 'test/unit'
+
+class TestStringStore < Test::Unit::TestCase
+  def setup
+    @ss = StringStore.new(['report-generators/test/strings',
+                           'report-generators/test/strings/more_strings'])
+  end
+
+  def test_lookup
+    assert_equal("Hello, world!\n", @ss.lookup(:test1))
+    assert_equal("one\ntwo\nthree", @ss.lookup(:test2))
+    assert_equal("lorem\n", @ss.lookup(:test3))
+
+    assert_raises(RuntimeError) do
+      @ss.lookup(:unlikely_name)
+    end
+  end
+end
/cvs/lvm2/LVM2/report-generators/test/ts.rb,v  -->  standard output
revision 1.1
--- LVM2/report-generators/test/ts.rb
+++ -	2010-07-20 14:38:49.072218000 +0000
@@ -0,0 +1,3 @@
+require 'tc_log'
+require 'tc_string_store'
+require 'tc_schedule_file'
/cvs/lvm2/LVM2/report-generators/test/strings/test1.txt,v  -->  standard output
revision 1.1
--- LVM2/report-generators/test/strings/test1.txt
+++ -	2010-07-20 14:38:49.255652000 +0000
@@ -0,0 +1 @@
+Hello, world!
/cvs/lvm2/LVM2/report-generators/test/strings/test2,v  -->  standard output
revision 1.1
--- LVM2/report-generators/test/strings/test2
+++ -	2010-07-20 14:38:49.359850000 +0000
@@ -0,0 +1,3 @@
+one
+two
+three
\ No newline at end of file
/cvs/lvm2/LVM2/report-generators/test/strings/more_strings/test3.txt,v  -->  standard output
revision 1.1
--- LVM2/report-generators/test/strings/more_strings/test3.txt
+++ -	2010-07-20 14:38:49.446703000 +0000
@@ -0,0 +1 @@
+lorem
/cvs/lvm2/LVM2/reports/stylesheet.css,v  -->  standard output
revision 1.1
--- LVM2/reports/stylesheet.css
+++ -	2010-07-20 14:38:49.588725000 +0000
@@ -0,0 +1,264 @@
+/* I know nothing about css, and am not likely too either since it's
+ * about bottom on my list of things to learn.  So this file has been
+ * pinched from the Pragmatic Programmers ruby on rails book.  - ejt
+ */
+
+/* Global styles */
+
+/* START:notice */
+#notice {
+  border: 2px solid red;
+  padding: 1em;
+  margin-bottom: 2em;
+  background-color: #f0f0f0;
+  font: bold smaller sans-serif;
+}
+/* END:notice */
+
+/* Styles for admin/list */
+
+#product-list .list-title {
+	color:        #244;
+	font-weight:  bold;
+	font-size:    larger;
+}
+
+#product-list .list-image {
+  width:        60px;
+  height:       70px;
+}
+
+
+#product-list .list-actions {
+  font-size:    x-small;
+  text-align:   right;
+  padding-left: 1em;
+}
+
+#product-list .list-line-even {
+  background:   #e0f8f8;
+}
+
+#product-list .list-line-odd {
+  background:   #f8b0f8;
+}
+
+
+/* Styles for main page */
+
+#banner {
+  background: #9c9;
+  padding-top: 5px;
+  padding-bottom: 5px;
+  border-bottom: 2px solid;
+  font: small-caps 20px/20px "Times New Roman", serif;
+  color: #282;
+  text-align: center;
+}
+
+#banner img {
+  float: left;
+}
+
+#main {
+  margin-left: 0em;
+  padding-top: 4ex;
+  padding-left: 2em;
+  background: white;
+}
+
+h1 {
+  font:  150% sans-serif;
+  color: #226;
+  border-bottom: 3px dotted #77d;
+}
+
+/* An entry in the store catalog */
+
+#store  .entry {
+  border-bottom: 1px dotted #77d;
+}
+
+#store  .title {
+  font-size: 120%;
+  font-family: sans-serif;
+}
+
+#store .entry img {
+  width: 75px;
+  float: left;
+}
+
+
+#store .entry h3 {
+ margin-bottom: 2px;
+ color: #227;
+}
+
+#store .entry p {
+ margin-top: 0px;
+ margin-bottom: 0.8em;
+}
+
+#store .entry .price-line {
+}
+
+#store .entry .add-to-cart {
+  position: relative;
+}
+
+#store .entry  .price {
+  color: #44a;
+  font-weight: bold;
+  margin-right: 2em;
+}
+
+/* START:inline */
+#store .entry form, #store .entry form div {
+  display: inline;
+}
+/* END:inline */
+
+/* START:cart */
+/* Styles for the cart in the main page and the sidebar */
+
+.cart-title {
+  font: 120% bold;
+}
+
+.item-price, .total-line {
+  text-align: right;
+}
+
+.total-line .total-cell {
+  font-weight: bold;
+  border-top: 1px solid #595;
+}
+
+
+/* Styles for the cart in the sidebar */
+
+#cart, #cart table {
+  font-size: smaller;
+  color:     white;
+}
+
+#cart table {
+  border-top:    1px dotted #595;
+  border-bottom: 1px dotted #595;
+  margin-bottom: 10px;
+}
+/* END:cart */
+
+/* Styles for order form */
+
+.depot-form fieldset {
+  background: #efe;
+}
+
+.depot-form legend {
+  color: #dfd;
+  background: #141;
+  font-family: sans-serif;
+  padding: 0.2em 1em;
+}
+
+.depot-form label {
+  width: 5em;
+  float: left;
+  text-align: right;
+  margin-right: 0.5em;
+  display: block;
+}
+
+.depot-form .submit {
+  margin-left: 5.5em;
+}
+
+/* The error box */
+
+.fieldWithErrors {
+  padding: 2px;
+  background-color: red;
+  display: table;
+}
+
+#errorExplanation {
+  width: 400px;
+  border: 2px solid red;
+  padding: 7px;
+  padding-bottom: 12px;
+  margin-bottom: 20px;
+  background-color: #f0f0f0;
+}
+
+#errorExplanation h2 {
+  text-align: left;
+  font-weight: bold;
+  padding: 5px 5px 5px 15px;
+  font-size: 12px;
+  margin: -7px;
+  background-color: #c00;
+  color: #fff;
+}
+
+#errorExplanation p {
+  color: #333;
+  margin-bottom: 0;
+  padding: 5px;
+}
+
+#errorExplanation ul li {
+  font-size: 12px;
+  list-style: square;
+}
+
+body {
+    font: normal 75% verdana,arial,helvetica;
+    color:#000000;
+}
+
+table tr td, table tr th {
+  font-size: 75%;
+}
+
+table.stripes tr th {
+    font-weight: bold;
+    text-align: left;
+    background: #a0a0a0;
+}
+
+table.stripes tr td {
+    background: #ccccc0;
+}
+
+td.pass {
+  color: green;
+}
+
+td.fail {
+  color: red;
+  font-weight: bold;
+}
+
+#main {
+    padding-left: 0em;
+}
+
+#controls {
+  float: left;
+  padding-top: 1em;
+  padding-left: 1em;
+  padding-right: 1em;
+  padding-bottom: 1em;
+  width: 14em;
+  border-right: 2px solid;
+}
+
+#body {
+  margin-left: 16em;
+  padding-top: 4ex;
+  padding-left: 2em;
+  background: white;
+  border-left: 2px solid;
+}


