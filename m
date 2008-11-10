From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 10 Nov 2008 14:04:13 -0000
Subject: LVM2 Makefile.in
Message-ID: <20081110140413.11889.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2008-11-10 14:04:12

Modified files:
	.              : Makefile.in 

Log message:
	Include libdm in lcov reports.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/Makefile.in.diff?cvsroot=lvm2&r1=1.28&r2=1.29

--- LVM2/Makefile.in	2008/11/04 15:55:26	1.28
+++ LVM2/Makefile.in	2008/11/10 14:04:12	1.29
@@ -84,18 +84,21 @@
 
 lcov-reset:
 	$(LCOV) -d $(top_srcdir)/dmeventd --zerocounters
+	$(LCOV) -d $(top_srcdir)/libdm --zerocounters
 	$(LCOV) -d $(top_srcdir)/lib --zerocounters
 	$(LCOV) -d $(top_srcdir)/tools --zerocounters
 
 lcov: all
 	$(RM) -rf $(LCOV_REPORTS_DIR)
 	$(MKDIR_P) $(LCOV_REPORTS_DIR)
+	$(LCOV) -b ${top_srcdir}/libdm -d $(top_srcdir)/libdm -c -o $(LCOV_REPORTS_DIR)/libdm.info
 	$(LCOV) -b $(top_srcdir)/lib -d $(top_srcdir)/lib -c -o $(LCOV_REPORTS_DIR)/lib.info
 	$(LCOV) -b $(top_srcdir)/tools -d $(top_srcdir)/tools -c -o $(LCOV_REPORTS_DIR)/tools.info
 	DMEVENTD_INFO="$(LCOV_REPORTS_DIR)/dmeventd.info" ;\
 	DMEVENTD_INFO_A="-a $$DMEVENTDINFO" ;\
 	$(LCOV) -b $(top_srcdir)/dmeventd -d $(top_srcdir)/dmeventd -c -o $$DMEVENTD_INFO || DMEVENTD_INFO_A="" ;\
 	$(LCOV) $$DMEVENTD_INFO_A -a $(LCOV_REPORTS_DIR)/lib.info \
+		-a $(LCOV_REPORTS_DIR)/libdm.info \
 		-a $(LCOV_REPORTS_DIR)/tools.info \
 		-o $(LCOV_REPORTS_DIR)/lvm.info
 ifneq ("@GENHTML@", "")


