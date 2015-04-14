From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 14 Apr 2015 11:31:30 +0000 (UTC)
Subject: master - makefiles: check lcov file has content
Message-ID: <20150414113130.CE53660B47@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4cdf155a87211d269ae31c70856f580111fca186
Commit:        4cdf155a87211d269ae31c70856f580111fca186
Parent:        a084b3122f5df4d9dcd244762132abcb5f46ea6a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Apr 14 13:28:26 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Apr 14 13:29:43 2015 +0200

makefiles: check lcov file has content

genhtml may get confused without content.
---
 Makefile.in |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/Makefile.in b/Makefile.in
index 41eb2e9..a7bed8e 100644
--- a/Makefile.in
+++ b/Makefile.in
@@ -155,7 +155,7 @@ lcov: $(LCOV_TRACES)
 	$(RM) -r $(LCOV_REPORTS_DIR)
 	$(MKDIR_P) $(LCOV_REPORTS_DIR)
 	for i in $(LCOV_TRACES); do \
-		test -s $$i && lc="$$lc $$i"; \
+		test -s $$i -a $$(wc -w <$$i) -ge 100 && lc="$$lc $$i"; \
 	done; \
 	test -z "$$lc" || $(GENHTML) -p @abs_top_builddir@ \
 		-o $(LCOV_REPORTS_DIR) $$lc


