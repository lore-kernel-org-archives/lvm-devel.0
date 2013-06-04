From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue,  4 Jun 2013 19:26:20 +0000 (UTC)
Subject: dev-mornfall-activate - make: fix exported symbols regex for non-GNU sed
Message-ID: <20130604192620.D570261084@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2e4a66a7617de57cbf8462bdd1e555aef0b13c47
Commit:        2e4a66a7617de57cbf8462bdd1e555aef0b13c47
Parent:        c6cf2ed7fd29d1860df511ac897367af646a6fb3
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue May 14 19:29:26 2013 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue May 14 19:29:26 2013 +0100

make: fix exported symbols regex for non-GNU sed

Remove a couple of incorrect backslashes from expressions used to
generate lists of exported symbols so it works with busybox sed.
[John Spencer]
---
 WHATS_NEW    |    1 +
 make.tmpl.in |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 626a354..8f19310 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Fix exported symbols regex for non-GNU busybox sed.
   Accept --yes in all commands so test scripts can be simpler.
   Fix alignment of PV data area if detected alignment less than 1 MB (2.02.74).
   Fix memory resource leak in memlocking error path.
diff --git a/make.tmpl.in b/make.tmpl.in
index b33ddb3..df7453d 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -392,7 +392,7 @@ distclean: cleandir $(SUBDIRS.distclean)
 	( cat $(srcdir)/.exported_symbols; \
 	  if test x$(EXPORTED_HEADER) != x; then \
 		$(CC) -E -P $(INCLUDES) $(DEFS) $(EXPORTED_HEADER) | \
-		$(SED) -ne "/^typedef|}/!s/.*[ \*]\(\$(EXPORTED_FN_PREFIX)_[a-z0-9_]*\)(.*/\1/p"; \
+		$(SED) -ne "/^typedef|}/!s/.*[ *]\($(EXPORTED_FN_PREFIX)_[a-z0-9_]*\)(.*/\1/p"; \
 	  fi \
 	) > $@
 


