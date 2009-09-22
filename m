From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 22 Sep 2009 13:32:40 -0000
Subject: LVM2 Makefile.in
Message-ID: <20090922133240.11672.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2009-09-22 13:32:39

Modified files:
	.              : Makefile.in 

Log message:
	Minor replace of of ${top_srcdir} with $(top_srcdir) for lcov target

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/Makefile.in.diff?cvsroot=lvm2&r1=1.38&r2=1.39

--- LVM2/Makefile.in	2009/09/15 15:37:12	1.38
+++ LVM2/Makefile.in	2009/09/22 13:32:39	1.39
@@ -105,7 +105,7 @@
 lcov: all
 	$(RM) -rf $(LCOV_REPORTS_DIR)
 	$(MKDIR_P) $(LCOV_REPORTS_DIR)
-	$(LCOV) -b ${top_srcdir}/libdm -d $(top_srcdir)/libdm -c -o $(LCOV_REPORTS_DIR)/libdm.info
+	$(LCOV) -b $(top_srcdir)/libdm -d $(top_srcdir)/libdm -c -o $(LCOV_REPORTS_DIR)/libdm.info
 	$(LCOV) -b $(top_srcdir)/lib -d $(top_srcdir)/lib -c -o $(LCOV_REPORTS_DIR)/lib.info
 	$(LCOV) -b $(top_srcdir)/tools -d $(top_srcdir)/tools -c -o $(LCOV_REPORTS_DIR)/tools.info
 	DMEVENTD_INFO="$(LCOV_REPORTS_DIR)/dmeventd.info" ;\


