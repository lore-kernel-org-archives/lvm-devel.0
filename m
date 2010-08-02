From: agk@sourceware.org <agk@sourceware.org>
Date: 2 Aug 2010 12:10:37 -0000
Subject: LVM2 WHATS_NEW Makefile.in
Message-ID: <20100802121037.31606.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-08-02 12:10:36

Modified files:
	.              : WHATS_NEW Makefile.in 

Log message:
	Make liblvm.device-mapper wait for include file generation.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1680&r2=1.1681
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/Makefile.in.diff?cvsroot=lvm2&r1=1.59&r2=1.60

--- LVM2/WHATS_NEW	2010/07/31 14:13:59	1.1680
+++ LVM2/WHATS_NEW	2010/08/02 12:10:35	1.1681
@@ -1,5 +1,6 @@
 Version 2.02.73 - 
 ================================
+  Make liblvm.device-mapper wait for include file generation.
   Drop explicit 'Base' version from exported symbols.
   Fix configure to supply DEFAULT_RUN_DIR to Makefiles.
   Fix wrong number of mirror log at allocate policy
--- LVM2/Makefile.in	2010/07/28 13:55:42	1.59
+++ LVM2/Makefile.in	2010/08/02 12:10:36	1.60
@@ -50,6 +50,7 @@
 po: tools daemons
 
 libdm.device-mapper: include.device-mapper
+liblvm.device-mapper: include.device-mapper
 daemons.device-mapper: libdm.device-mapper
 tools.device-mapper: libdm.device-mapper
 device-mapper: tools.device-mapper daemons.device-mapper man.device-mapper
@@ -149,4 +150,4 @@
 
 ruby-test:
 	$(RUBY) report-generators/test/ts.rb
-endif
\ No newline at end of file
+endif


