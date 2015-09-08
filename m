From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue,  8 Sep 2015 13:41:39 +0000 (UTC)
Subject: master - makefiles: ensure no old .h are left
Message-ID: <20150908134139.37F0A605B2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8ff43c3705573043e2fa8ce68c2f052273cce205
Commit:        8ff43c3705573043e2fa8ce68c2f052273cce205
Parent:        026db9062129d8b5f0e0a8a6539014e8c04a35e0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Sep 8 14:33:29 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Sep 8 15:41:33 2015 +0200

makefiles: ensure no old .h are left

Ensure make clean  cleans any left-over file from their previous
location so they are not in conflict with new ones.

Also hide error message when .commands file is not present.
---
 lib/Makefile.in  |    2 ++
 test/Makefile.in |    2 +-
 2 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/lib/Makefile.in b/lib/Makefile.in
index ec80c7c..3e0e6f8 100644
--- a/lib/Makefile.in
+++ b/lib/Makefile.in
@@ -229,3 +229,5 @@ include $(top_builddir)/make.tmpl
 CFLAGS += $(BLKID_CFLAGS) $(UDEV_CFLAGS) $(VALGRIND_CFLAGS)
 
 $(SUBDIRS): $(LIB_STATIC)
+
+CLEAN_TARGETS += misc/configure.h misc/lvm-version.h
diff --git a/test/Makefile.in b/test/Makefile.in
index e6860e1..769f931 100644
--- a/test/Makefile.in
+++ b/test/Makefile.in
@@ -281,7 +281,7 @@ lib/paths: lib/paths-common
 	echo 'abs_builddir="$(abs_builddir)"' >> $@-t
 	mv $@-t $@
 
-CMDS = lvm $(shell cat $(top_builddir)/tools/.commands)
+CMDS = lvm $(shell cat $(top_builddir)/tools/.commands 2>/dev/null)
 LIB = $(addprefix lib/, $(LIB_SHARED) $(LIB_LOCAL) $(LIB_NOT) $(LIB_LINK_NOT) $(LIB_FLAVOURS))
 
 .tests-stamp: $(ALL) $(LIB) $(SUBDIRS)


