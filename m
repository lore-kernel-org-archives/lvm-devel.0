From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 29 Nov 2018 17:12:30 -0500
Subject: master - makefiles: improve lcov generator
Message-ID: <201811292212.wATMCUUg016561@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=483ed8f76700ad6d7c479c0e41c58970cc266ee7
Commit:        483ed8f76700ad6d7c479c0e41c58970cc266ee7
Parent:        8bb5dd54303df384233a06057d9258385d0363ec
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 23 13:07:50 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Nov 29 23:05:43 2018 +0100

makefiles: improve lcov generator

Simplify generation of lcov report.
---
 Makefile.in |   34 +++++++---------------------------
 1 files changed, 7 insertions(+), 27 deletions(-)

diff --git a/Makefile.in b/Makefile.in
index 6a1a990..2561e4b 100644
--- a/Makefile.in
+++ b/Makefile.in
@@ -148,18 +148,8 @@ install_all_man:
 install_tmpfiles_configuration:
 	$(MAKE) -C scripts install_tmpfiles_configuration
 
-LCOV_TRACES = libdm.info lib.info tools.info \
-	libdaemon/client.info libdaemon/server.info \
-	test/unit.info \
-	daemons/clvmd.info \
-	daemons/dmeventd.info \
-	daemons/lvmlockd.info \
-	daemons/lvmpolld.info
-
-CLEAN_TARGETS += $(LCOV_TRACES)
-
 ifneq ("$(LCOV)", "")
-.PHONY: lcov-reset lcov lcov-dated $(LCOV_TRACES)
+.PHONY: lcov-reset lcov lcov-dated
 
 ifeq ($(MAKECMDGOALS),lcov-dated)
 LCOV_REPORTS_DIR := lcov_reports-$(shell date +%Y%m%d%k%M%S)
@@ -169,25 +159,15 @@ LCOV_REPORTS_DIR := lcov_reports
 endif
 
 lcov-reset:
-	$(LCOV) --zerocounters $(addprefix -d , $(basename $(LCOV_TRACES)))
-
-# maybe use subdirs processing to create tracefiles...
-$(LCOV_TRACES):
-	$(LCOV) -b $(basename $@) -d $(basename $@) \
-		--ignore-errors source -c -o - | $(SED) \
-		-e "s/\(dmeventd_lvm.[ch]\)/plugins\/lvm2\/\1/" \
-		-e "s/dmeventd_\(mirror\|snapshot\|thin\|raid\)\.c/plugins\/\1\/dmeventd_\1\.c/" \
-		>$@
+	$(LCOV) --zerocounters --directory $(top_builddir)
 
 ifneq ("$(GENHTML)", "")
-lcov: $(LCOV_TRACES)
-	$(RM) -r $(LCOV_REPORTS_DIR)
+lcov:
+	$(RM) -rf $(LCOV_REPORTS_DIR)
 	$(MKDIR_P) $(LCOV_REPORTS_DIR)
-	for i in $(LCOV_TRACES); do \
-		test -s $$i -a $$(wc -w <$$i) -ge 100 && lc="$$lc $$i"; \
-	done; \
-	test -z "$$lc" || $(GENHTML) -p @abs_top_builddir@ \
-		-o $(LCOV_REPORTS_DIR) $$lc
+	$(LCOV) --capture --directory $(top_builddir) --output-file $(LCOV_REPORTS_DIR)/out.info
+	-test !-s $(LCOV_REPORTS_DIR)/out.info || \
+		$(GENHTML) -o $(LCOV_REPORTS_DIR) --ignore-errors source $(LCOV_REPORTS_DIR)/out.info
 endif
 
 endif


