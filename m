From: agk@sourceware.org <agk@sourceware.org>
Date: 28 Jul 2010 12:20:47 -0000
Subject: LVM2 report-generators/memcheck.rb report-gene ...
Message-ID: <20100728122047.13367.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-07-28 12:20:41

Modified files:
	report-generators: memcheck.rb title_page.rb unit_test.rb 
	report-generators/lib: log.rb report_templates.rb reports.rb 
	                       schedule_file.rb string-store.rb 
	report-generators/test: tc_log.rb tc_schedule_file.rb 
	                        tc_string_store.rb ts.rb 
	test           : check.sh harness.c harness.sh not.c 
	                 t-activate-missing.sh t-activate-partial.sh 
	                 t-lvconvert-mirror-basic-0.sh 
	                 t-lvconvert-mirror-basic-1.sh 
	                 t-lvconvert-mirror-basic-2.sh 
	                 t-lvconvert-mirror-basic-3.sh 
	                 t-lvconvert-mirror-basic.sh t-nomda-missing.sh 
	                 t-snapshots-of-mirrors.sh t-vgsplit-stacked.sh 
	unit-tests/datastruct: bitset_t.c 

Log message:
	add copyright notices to new files

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/report-generators/memcheck.rb.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/report-generators/title_page.rb.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/report-generators/unit_test.rb.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/report-generators/lib/log.rb.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/report-generators/lib/report_templates.rb.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/report-generators/lib/reports.rb.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/report-generators/lib/schedule_file.rb.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/report-generators/lib/string-store.rb.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/report-generators/test/tc_log.rb.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/report-generators/test/tc_schedule_file.rb.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/report-generators/test/tc_string_store.rb.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/report-generators/test/ts.rb.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/check.sh.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/harness.c.diff?cvsroot=lvm2&r1=1.12&r2=1.13
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/harness.sh.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/not.c.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-activate-missing.sh.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-activate-partial.sh.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvconvert-mirror-basic-0.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvconvert-mirror-basic-1.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvconvert-mirror-basic-2.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvconvert-mirror-basic-3.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvconvert-mirror-basic.sh.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-nomda-missing.sh.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-snapshots-of-mirrors.sh.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgsplit-stacked.sh.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/unit-tests/datastruct/bitset_t.c.diff?cvsroot=lvm2&r1=1.3&r2=1.4

--- LVM2/report-generators/memcheck.rb	2010/07/20 14:38:44	1.1
+++ LVM2/report-generators/memcheck.rb	2010/07/28 12:20:38	1.2
@@ -1,3 +1,13 @@
+# Copyright (C) 2010 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
 # Reads the schedule files given on the command line.  Runs them and
 # generates the reports.
 
--- LVM2/report-generators/title_page.rb	2010/07/20 14:38:44	1.1
+++ LVM2/report-generators/title_page.rb	2010/07/28 12:20:38	1.2
@@ -1,3 +1,13 @@
+# Copyright (C) 2010 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
 # This generates the index for the reports, including generation
 # times.
 
--- LVM2/report-generators/unit_test.rb	2010/07/20 14:38:44	1.1
+++ LVM2/report-generators/unit_test.rb	2010/07/28 12:20:38	1.2
@@ -1,3 +1,13 @@
+# Copyright (C) 2010 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
 # Reads the schedule files given on the command line.  Runs them and
 # generates the reports.
 
--- LVM2/report-generators/lib/log.rb	2010/07/20 14:38:45	1.1
+++ LVM2/report-generators/lib/log.rb	2010/07/28 12:20:40	1.2
@@ -1,3 +1,13 @@
+# Copyright (C) 2010 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
 # Merely wraps the logger library with a bit of standard policy.
 require 'logger'
 
--- LVM2/report-generators/lib/report_templates.rb	2010/07/20 14:38:45	1.1
+++ LVM2/report-generators/lib/report_templates.rb	2010/07/28 12:20:40	1.2
@@ -1,3 +1,13 @@
+# Copyright (C) 2010 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
 # Policy for the location of report templates
 require 'string-store'
 
--- LVM2/report-generators/lib/reports.rb	2010/07/20 14:38:45	1.1
+++ LVM2/report-generators/lib/reports.rb	2010/07/28 12:20:40	1.2
@@ -1,3 +1,13 @@
+# Copyright (C) 2010 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
 # Data about the various reports we support
 require 'log'
 require 'pathname'
--- LVM2/report-generators/lib/schedule_file.rb	2010/07/20 14:38:45	1.1
+++ LVM2/report-generators/lib/schedule_file.rb	2010/07/28 12:20:40	1.2
@@ -1,3 +1,13 @@
+# Copyright (C) 2010 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
 # Parses the simple colon delimited test schedule files.
 
 ScheduledTest = Struct.new(:desc, :command_line, :status, :output)
--- LVM2/report-generators/lib/string-store.rb	2010/07/20 14:38:45	1.1
+++ LVM2/report-generators/lib/string-store.rb	2010/07/28 12:20:40	1.2
@@ -1,3 +1,13 @@
+# Copyright (C) 2010 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
 # Provides a simple way of accessing the contents of files by a symbol
 # name.  Useful for erb templates.
 
--- LVM2/report-generators/test/tc_log.rb	2010/07/20 14:38:45	1.1
+++ LVM2/report-generators/test/tc_log.rb	2010/07/28 12:20:40	1.2
@@ -1,3 +1,13 @@
+# Copyright (C) 2010 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
 require 'test/unit'
 require 'stringio'
 require 'log'
--- LVM2/report-generators/test/tc_schedule_file.rb	2010/07/20 14:38:45	1.1
+++ LVM2/report-generators/test/tc_schedule_file.rb	2010/07/28 12:20:40	1.2
@@ -1,3 +1,13 @@
+# Copyright (C) 2010 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
 require 'test/unit'
 require 'pathname'
 require 'schedule_file'
--- LVM2/report-generators/test/tc_string_store.rb	2010/07/20 14:38:45	1.1
+++ LVM2/report-generators/test/tc_string_store.rb	2010/07/28 12:20:40	1.2
@@ -1,3 +1,13 @@
+# Copyright (C) 2010 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
 require 'string-store'
 require 'test/unit'
 
--- LVM2/report-generators/test/ts.rb	2010/07/20 14:38:45	1.1
+++ LVM2/report-generators/test/ts.rb	2010/07/28 12:20:40	1.2
@@ -1,3 +1,13 @@
+# Copyright (C) 2010 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
 require 'tc_log'
 require 'tc_string_store'
 require 'tc_schedule_file'
--- LVM2/test/check.sh	2010/05/12 10:08:35	1.5
+++ LVM2/test/check.sh	2010/07/28 12:20:41	1.6
@@ -1,5 +1,15 @@
 #!/bin/bash
 
+# Copyright (C) 2010 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
 # check.sh: assert various things about volumes
 
 # USAGE
--- LVM2/test/harness.c	2010/05/12 11:23:16	1.12
+++ LVM2/test/harness.c	2010/07/28 12:20:41	1.13
@@ -1,3 +1,17 @@
+/*
+ * Copyright (C) 2010 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU General Public License v.2.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+
 #include <fcntl.h>
 #include <string.h>
 #include <stdio.h>
--- LVM2/test/harness.sh	2008/11/04 14:37:51	1.5
+++ LVM2/test/harness.sh	2010/07/28 12:20:41	1.6
@@ -1,5 +1,15 @@
 #!/bin/sh
 
+# Copyright (C) 2010 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
 tests="$@"
 test -z "$tests" && tests=`echo t-*.sh`
 
--- LVM2/test/not.c	2010/05/12 05:55:42	1.4
+++ LVM2/test/not.c	2010/07/28 12:20:41	1.5
@@ -1,3 +1,17 @@
+/*
+ * Copyright (C) 2010 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU General Public License v.2.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+
 #include <unistd.h>
 #include <stdio.h>
 #include <stdarg.h>
--- LVM2/test/t-activate-missing.sh	2010/07/27 20:05:29	1.2
+++ LVM2/test/t-activate-missing.sh	2010/07/28 12:20:41	1.3
@@ -1,5 +1,15 @@
 #!/bin/bash
 
+# Copyright (C) 2010 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
 # Test activation behaviour with devices missing.
 # - snapshots and their origins are only activated together; if one fails, both
 #   fail
--- LVM2/test/t-activate-partial.sh	2010/06/30 14:01:39	1.3
+++ LVM2/test/t-activate-partial.sh	2010/07/28 12:20:41	1.4
@@ -1,3 +1,13 @@
+# Copyright (C) 2010 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
 . ./test-utils.sh
 
 aux prepare_vg 3
@@ -17,4 +27,4 @@
 vgchange -a y --partial $vg
 
 # check vgremove
-vgremove -f $vg
\ No newline at end of file
+vgremove -f $vg
--- LVM2/test/t-lvconvert-mirror-basic-0.sh	2010/05/12 13:15:38	1.1
+++ LVM2/test/t-lvconvert-mirror-basic-0.sh	2010/07/28 12:20:41	1.2
@@ -1,2 +1,12 @@
+# Copyright (C) 2010 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
 . ./t-lvconvert-mirror-basic.sh
 test_many 0
--- LVM2/test/t-lvconvert-mirror-basic-1.sh	2010/05/12 13:15:38	1.1
+++ LVM2/test/t-lvconvert-mirror-basic-1.sh	2010/07/28 12:20:41	1.2
@@ -1,2 +1,12 @@
+# Copyright (C) 2010 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
 . ./t-lvconvert-mirror-basic.sh
 test_many 1
--- LVM2/test/t-lvconvert-mirror-basic-2.sh	2010/05/12 13:15:38	1.1
+++ LVM2/test/t-lvconvert-mirror-basic-2.sh	2010/07/28 12:20:41	1.2
@@ -1,2 +1,12 @@
+# Copyright (C) 2010 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
 . ./t-lvconvert-mirror-basic.sh
 test_many 2
--- LVM2/test/t-lvconvert-mirror-basic-3.sh	2010/05/12 13:15:38	1.1
+++ LVM2/test/t-lvconvert-mirror-basic-3.sh	2010/07/28 12:20:41	1.2
@@ -1,2 +1,12 @@
+# Copyright (C) 2010 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
 . ./t-lvconvert-mirror-basic.sh
 test_many 3
--- LVM2/test/t-lvconvert-mirror-basic.sh	2010/06/28 19:13:33	1.3
+++ LVM2/test/t-lvconvert-mirror-basic.sh	2010/07/28 12:20:41	1.4
@@ -1,3 +1,13 @@
+# Copyright (C) 2010 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
 . ./test-utils.sh
 
 log_name_to_count()
--- LVM2/test/t-nomda-missing.sh	2010/07/27 21:08:32	1.2
+++ LVM2/test/t-nomda-missing.sh	2010/07/28 12:20:41	1.3
@@ -1,5 +1,15 @@
 #!/bin/bash
 
+# Copyright (C) 2010 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
 . ./test-utils.sh
 
 prepare_devs 4
--- LVM2/test/t-snapshots-of-mirrors.sh	2010/03/26 22:15:44	1.4
+++ LVM2/test/t-snapshots-of-mirrors.sh	2010/07/28 12:20:41	1.5
@@ -1,3 +1,13 @@
+# Copyright (C) 2010 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
 . ./test-utils.sh
 
 prepare_vg 4
--- LVM2/test/t-vgsplit-stacked.sh	2010/04/07 14:46:27	1.3
+++ LVM2/test/t-vgsplit-stacked.sh	2010/07/28 12:20:41	1.4
@@ -1,3 +1,13 @@
+# Copyright (C) 2010 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
 . ./test-utils.sh
 
 prepare_lvmconf '[ "a/dev\/mirror/", "a/dev\/mapper\/.*$/", "a/dev\/LVMTEST/", "r/.*/" ]'
--- LVM2/unit-tests/datastruct/bitset_t.c	2010/07/20 15:28:22	1.3
+++ LVM2/unit-tests/datastruct/bitset_t.c	2010/07/28 12:20:41	1.4
@@ -1,3 +1,17 @@
+/*
+ * Copyright (C) 2010 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU General Public License v.2.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+
 #include "libdevmapper.h"
 
 #include <assert.h>


