From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 1 Feb 2012 10:46:48 -0000
Subject: LVM2 Makefile.in WHATS_NEW
Message-ID: <20120201104648.29780.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-02-01 10:46:46

Modified files:
	.              : Makefile.in WHATS_NEW 

Log message:
	User correct base dir for lcov reports
	
	Fix problem when srcdir != builddir.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/Makefile.in.diff?cvsroot=lvm2&r1=1.67&r2=1.68
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2249&r2=1.2250

--- LVM2/Makefile.in	2011/11/23 12:21:41	1.67
+++ LVM2/Makefile.in	2012/02/01 10:46:45	1.68
@@ -116,7 +116,7 @@
 
 # maybe use subdirs processing to create tracefiles...
 $(LCOV_TRACES):
-	$(LCOV) -b $(top_srcdir)/$(basename $@) \
+	$(LCOV) -b $(basename $@) \
 		-d $(basename $@) -c -o - | $(SED) \
 		-e "s/\(dmeventd_lvm.[ch]\)/plugins\/lvm2\/\1/" \
 		-e "s/\(dmeventd_mirror.c\)/plugins\/mirror\/\1/" \
--- LVM2/WHATS_NEW	2012/02/01 02:10:45	1.2249
+++ LVM2/WHATS_NEW	2012/02/01 10:46:45	1.2250
@@ -1,5 +1,6 @@
 Version 2.02.90 - 
 ===================================
+  Fix lcov reports when srcdir != builddir.
   Allow ALLOC_NORMAL to track reserved extents for log and data on same PV.
   Automatically detect whether corosync clvmd needs to use confdb or cmap.
   Fix data% report for thin volume used as origin for non-thin snapshot.


