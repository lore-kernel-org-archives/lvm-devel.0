From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 17 Feb 2021 12:01:27 +0000 (GMT)
Subject: stable-2.02 - makefiles: ignore missing files
Message-ID: <20210217120127.A6F5F389C420@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=37a97c8995a4f5ffb65ce6f735816835f9533a29
Commit:        37a97c8995a4f5ffb65ce6f735816835f9533a29
Parent:        dee104668ea5b39518a3a220d360d4624c3f3575
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 30 12:54:34 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Feb 17 12:59:36 2021 +0100

makefiles: ignore missing files

---
 Makefile.in | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/Makefile.in b/Makefile.in
index 3c8f8c8cf..aa1405d1b 100644
--- a/Makefile.in
+++ b/Makefile.in
@@ -205,13 +205,13 @@ $(LCOV_TRACES):
 
 ifneq ("$(GENHTML)", "")
 lcov: $(LCOV_TRACES)
-	$(RM) -r $(LCOV_REPORTS_DIR)
+	$(RM) -rf $(LCOV_REPORTS_DIR)
 	$(MKDIR_P) $(LCOV_REPORTS_DIR)
-	for i in $(LCOV_TRACES); do \
-		test -s $$i -a $$(wc -w <$$i) -ge 100 && lc="$$lc $$i"; \
-	done; \
-	test -z "$$lc" || $(GENHTML) -p @abs_top_builddir@ \
-		-o $(LCOV_REPORTS_DIR) $$lc
+	$(LCOV) --capture --directory $(top_builddir) --ignore-errors source \
+		--output-file $(LCOV_REPORTS_DIR)/out.info
+	-test ! -s $(LCOV_REPORTS_DIR)/out.info || \
+		$(GENHTML) -o $(LCOV_REPORTS_DIR) --ignore-errors source \
+		$(LCOV_REPORTS_DIR)/out.info
 endif
 
 endif


