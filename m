From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 24 Sep 2013 07:36:23 +0000 (UTC)
Subject: master - tools: don't install separate command symlink for lvm devtypes
Message-ID: <20130924073623.5F29960BCC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f050278a35ec0049fa333ce82abfc2bf6a231c62
Commit:        f050278a35ec0049fa333ce82abfc2bf6a231c62
Parent:        11dc6a03c4cdd10bc4065c7d7a8585373455f947
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Sep 24 09:35:20 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Sep 24 09:35:20 2013 +0200

tools: don't install separate command symlink for lvm devtypes

---
 WHATS_NEW         |    1 +
 tools/Makefile.in |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index efd83e6..ac2a84e 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.103 - 
 ======================================
+  Don't install separate command symlink in binary directory for 'lvm devtypes'.
   Add seg_size_pe field to reports.
   Support start+length notation with command line PE ranges.
   Exit cleanly with message when pvmove cannot restart because LV is inactive.
diff --git a/tools/Makefile.in b/tools/Makefile.in
index 96dd8cf..f90cfae 100644
--- a/tools/Makefile.in
+++ b/tools/Makefile.in
@@ -162,7 +162,7 @@ liblvm2cmd.$(LIB_SUFFIX).$(LIB_VERSION): liblvm2cmd.$(LIB_SUFFIX)
 
 .commands: $(srcdir)/commands.h $(srcdir)/cmdnames.h Makefile
 	$(CC) -E -P $(srcdir)/cmdnames.h 2> /dev/null | \
-		egrep -v '^ *(|#.*|dumpconfig|formats|help|pvdata|segtypes|version) *$$' > .commands
+		egrep -v '^ *(|#.*|devtypes|dumpconfig|formats|help|pvdata|segtypes|version) *$$' > .commands
 
 ifneq ("$(CFLOW_CMD)", "")
 CFLOW_SOURCES = $(addprefix $(srcdir)/, $(SOURCES))


