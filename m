From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 1 Aug 2017 12:34:38 -0400
Subject: master - makefiles: add DEFS_$@ for cxx
Message-ID: <201708011634.v71GYc5J018032@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3232b210ab750bb21b9032d41cf20aee2bb33288
Commit:        3232b210ab750bb21b9032d41cf20aee2bb33288
Parent:        ad44543e8166d7068c8db1222aa06c786dcf58b3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Aug 1 18:13:21 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Aug 1 18:33:50 2017 +0200

makefiles: add DEFS_$@ for cxx

Add DEFS_$@ for c++  (used only by test suite...)
Just to pair plain C build rules.
---
 make.tmpl.in |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/make.tmpl.in b/make.tmpl.in
index 91f38b8..65362d8 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -439,7 +439,7 @@ endif
 	$(CC) -c $(INCLUDES) $(VALGRIND_CFLAGS) $(PROGS_CFLAGS) $(DEFS) $(DEFS_$@) $(WFLAGS) $(WCFLAGS) $(CFLAGS) $(CFLAGS_$@) $< -o $@
 
 %.o: %.cpp
-	$(CXX) -c $(INCLUDES) $(VALGRIND_CFLAGS) $(DEFS) $(WFLAGS) $(CXXFLAGS) $(CXXFLAGS_$@) $< -o $@
+	$(CXX) -c $(INCLUDES) $(VALGRIND_CFLAGS) $(DEFS) $(DEFS_$@) $(WFLAGS) $(CXXFLAGS) $(CXXFLAGS_$@) $< -o $@
 
 %.pot: %.c Makefile
 	$(CC) -E $(INCLUDES) $(VALGRIND_CFLAGS) $(PROGS_CFLAGS) -include $(top_builddir)/include/pogen.h $(DEFS) $(WFLAGS) $(CFLAGS) $< >$@


