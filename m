From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 6 Apr 2010 09:50:08 -0000
Subject: LVM2 Makefile.in
Message-ID: <20100406095008.6183.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-04-06 09:50:07

Modified files:
	.              : Makefile.in 

Log message:
	Fix lcov target
	
	Patch fixes generation of coverage files for dmeventd and adds support for clvmd.
	Path names are stripped, so the the html looks better.
	Frames 'previews' is enabled for generated pages.
	Using top_srcdir was wrong here - though we still can't easily use builddir.
	Requiers using shell variables before execution of binaries build outside
	of srcdir.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/Makefile.in.diff?cvsroot=lvm2&r1=1.47&r2=1.48

--- LVM2/Makefile.in	2010/03/29 14:17:59	1.47
+++ LVM2/Makefile.in	2010/04/06 09:50:07	1.48
@@ -78,38 +78,41 @@
 check: all
 	$(MAKE) -C test all
 
+LCOV_TRACES = libdm.info lib.info tools.info \
+	daemons/dmeventd.info daemons/clvmd.info
+CLEAN_TARGETS += $(LCOV_TRACES)
+
 ifneq ("$(LCOV)", "")
-.PHONY: lcov-reset lcov lcov-dated
+.PHONY: lcov-reset lcov lcov-dated $(LCOV_TRACES)
 
 ifeq ($(MAKECMDGOALS),lcov-dated)
-LCOV_REPORTS_DIR=$(top_srcdir)/lcov_reports-$(shell date +%Y%m%d%k%M%S)
+LCOV_REPORTS_DIR := lcov_reports-$(shell date +%Y%m%d%k%M%S)
+lcov-dated: lcov
 else
-LCOV_REPORTS_DIR=$(top_srcdir)/lcov_reports
+LCOV_REPORTS_DIR := lcov_reports
 endif
 
 lcov-reset:
-	$(LCOV) -d $(top_srcdir)/dmeventd --zerocounters
-	$(LCOV) -d $(top_srcdir)/libdm --zerocounters
-	$(LCOV) -d $(top_srcdir)/lib --zerocounters
-	$(LCOV) -d $(top_srcdir)/tools --zerocounters
+	$(LCOV) --zerocounters $(addprefix -d , $(basename $(LCOV_TRACES)))
+
+# maybe use subdirs processing to create tracefiles...
+$(LCOV_TRACES):
+	$(LCOV) -b $(top_srcdir)/$(basename $@) \
+		-d $(basename $@) -c -o - | $(SED) \
+		-e "s/\(dmeventd_lvm.[ch]\)/plugins\/lvm2\/\1/" \
+		-e "s/\(dmeventd_mirror.c\)/plugins\/mirror\/\1/" \
+		-e "s/\(dmeventd_snapshot.c\)/plugins\/snapshot\/\1/" \
+		>$@
 
-lcov: all
-	$(RM) -rf $(LCOV_REPORTS_DIR)
-	$(MKDIR_P) $(LCOV_REPORTS_DIR)
-	$(LCOV) -b $(top_srcdir)/libdm -d $(top_srcdir)/libdm -c -o $(LCOV_REPORTS_DIR)/libdm.info
-	$(LCOV) -b $(top_srcdir)/lib -d $(top_srcdir)/lib -c -o $(LCOV_REPORTS_DIR)/lib.info
-	$(LCOV) -b $(top_srcdir)/tools -d $(top_srcdir)/tools -c -o $(LCOV_REPORTS_DIR)/tools.info
-	DMEVENTD_INFO="$(LCOV_REPORTS_DIR)/dmeventd.info" ;\
-	DMEVENTD_INFO_A="-a $$DMEVENTDINFO" ;\
-	$(LCOV) -b $(top_srcdir)/dmeventd -d $(top_srcdir)/dmeventd -c -o $$DMEVENTD_INFO || DMEVENTD_INFO_A="" ;\
-	$(LCOV) $$DMEVENTD_INFO_A -a $(LCOV_REPORTS_DIR)/lib.info \
-		-a $(LCOV_REPORTS_DIR)/libdm.info \
-		-a $(LCOV_REPORTS_DIR)/tools.info \
-		-o $(LCOV_REPORTS_DIR)/lvm.info
 ifneq ("$(GENHTML)", "")
-	$(GENHTML) -o $(LCOV_REPORTS_DIR) -p $(top_srcdir) $(LCOV_REPORTS_DIR)/lvm.info
+lcov: $(LCOV_TRACES)
+	$(RM) -r $(LCOV_REPORTS_DIR)
+	$(MKDIR_P) $(LCOV_REPORTS_DIR)
+	for i in $(LCOV_TRACES); do \
+		test -s $$i && lc="$$lc $$i"; \
+	done; \
+	test -z "$$lc" || $(GENHTML) --frames -p @abs_top_builddir@ \
+		-o $(LCOV_REPORTS_DIR) $$lc
 endif
 
-lcov-dated: lcov
-
 endif


