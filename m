From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 30 Nov 2018 07:10:57 -0500
Subject: master - makefiles: ignore missing files
Message-ID: <201811301210.wAUCAv79014588@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7fb280ceacbacf6d0fb02ba1378e2caef2c8c582
Commit:        7fb280ceacbacf6d0fb02ba1378e2caef2c8c582
Parent:        46f946145c7cf7b56b6414055fd6f50c0bbef702
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 30 12:54:34 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Nov 30 13:03:09 2018 +0100

makefiles: ignore missing files

---
 Makefile.in |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/Makefile.in b/Makefile.in
index 85dfeac..dd8a526 100644
--- a/Makefile.in
+++ b/Makefile.in
@@ -165,9 +165,11 @@ ifneq ("$(GENHTML)", "")
 lcov:
 	$(RM) -rf $(LCOV_REPORTS_DIR)
 	$(MKDIR_P) $(LCOV_REPORTS_DIR)
-	$(LCOV) --capture --directory $(top_builddir) --output-file $(LCOV_REPORTS_DIR)/out.info
-	-test !-s $(LCOV_REPORTS_DIR)/out.info || \
-		$(GENHTML) -o $(LCOV_REPORTS_DIR) --ignore-errors source $(LCOV_REPORTS_DIR)/out.info
+	$(LCOV) --capture --directory $(top_builddir) --ignore-errors source \
+		--output-file $(LCOV_REPORTS_DIR)/out.info
+	-test ! -s $(LCOV_REPORTS_DIR)/out.info || \
+		$(GENHTML) -o $(LCOV_REPORTS_DIR) --ignore-errors source \
+		$(LCOV_REPORTS_DIR)/out.info
 endif
 
 endif


