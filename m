From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 14 Nov 2019 12:08:27 -0500
Subject: master - tests: enusure lib is initilized
Message-ID: <82977.119111412082300129@us-mta-152.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=91df257b53849ca4206f4c3d45c71bff83c4a5ee
Commit:        91df257b53849ca4206f4c3d45c71bff83c4a5ee
Parent:        e92d3bd1f75d335fba5303c433516ea4ebe5cab1
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Nov 14 13:04:29 2019 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Nov 14 18:06:42 2019 +0100

tests: enusure lib is initilized

---
 test/Makefile.in |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/Makefile.in b/test/Makefile.in
index fcb612d..9fa908e 100644
--- a/test/Makefile.in
+++ b/test/Makefile.in
@@ -315,7 +315,7 @@ lib/dm-version-expected: $(top_srcdir)/VERSION_DM .lib-dir-stamp
 CMDS = lvm $(shell cat $(top_builddir)/tools/.commands 2>/dev/null)
 LIB = $(addprefix lib/, $(LIB_SECURETEST) $(LIB_DMSECURETEST) $(LIB_SHARED) $(LIB_LOCAL) $(LIB_NOT) $(LIB_LINK_NOT) $(LIB_FLAVOURS))
 
-.tests-stamp: $(ALL) $(LIB) $(SUBDIRS) lib/version-expected lib/dm-version-expected unit-test
+.tests-stamp: .lib-dir-stamp $(ALL) $(LIB) $(SUBDIRS) lib/version-expected lib/dm-version-expected unit-test
 	@echo "    [TEST-STAMP]"
 	@if test "$(srcdir)" != . ; then \
 		echo "Linking tests to builddir."; \



