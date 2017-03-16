From: Alasdair Kergon <agk@sourceware.org>
Date: Thu, 16 Mar 2017 19:14:53 -0400
Subject: master - make.tmpl: Support per-object DEFS.
Message-ID: <201703162314.v2GNErQm030373@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0c74afa1c613537e5aed33ed230755cfe8b0ab03
Commit:        0c74afa1c613537e5aed33ed230755cfe8b0ab03
Parent:        2d007673947b26bd0807cb637abb2fb9563c5e41
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Thu Mar 16 23:03:03 2017 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Thu Mar 16 23:03:03 2017 +0000

make.tmpl: Support per-object DEFS.

Same as CFLAGS.
---
 make.tmpl.in |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/make.tmpl.in b/make.tmpl.in
index 2af1b1c..41f23e6 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -416,7 +416,7 @@ endif
 .LIBPATTERNS = lib%.so lib%.a
 
 %.o: %.c
-	$(CC) -c $(INCLUDES) $(DEFS) $(WFLAGS) $(WCFLAGS) $(CFLAGS) $(CFLAGS_$@) $< -o $@
+	$(CC) -c $(INCLUDES) $(DEFS) $(DEFS_$@) $(WFLAGS) $(WCFLAGS) $(CFLAGS) $(CFLAGS_$@) $< -o $@
 
 %.o: %.cpp
 	$(CXX) -c $(INCLUDES) $(DEFS) $(WFLAGS) $(CXXFLAGS) $(CXXFLAGS_$@) $< -o $@


