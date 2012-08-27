From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 27 Aug 2012 13:40:26 +0000 (UTC)
Subject: master - make: fix subdir order for distclean
Message-ID: <20120827134026.14FB9A1043@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=967b5eb1f3a25572448974f882e3bc8ba5d3fb9a
Commit:        967b5eb1f3a25572448974f882e3bc8ba5d3fb9a
Parent:        847e2856a29c41756cc5bbaf70eb87ea030826f4
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Aug 27 15:39:08 2012 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Aug 27 15:39:08 2012 +0200

make: fix subdir order for distclean

The 'test' subdir needs to be processed before 'tools' subdir
for distclean as all the cmd names are read from 'tools/.commands'
file. Otherwise we'd end up with dangling symlinks in 'tools' subdir.
---
 Makefile.in |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/Makefile.in b/Makefile.in
index d957e26..4316190 100644
--- a/Makefile.in
+++ b/Makefile.in
@@ -40,9 +40,9 @@ SUBDIRS += scripts
 
 # FIXME Should use intermediate Makefiles here!
 ifeq ($(MAKECMDGOALS),distclean)
-  SUBDIRS = doc include man scripts \
+  SUBDIRS = doc include man test scripts \
     libdaemon lib tools daemons libdm \
-    udev po liblvm test \
+    udev po liblvm \
     unit-tests/datastruct unit-tests/mm unit-tests/regex
 endif
 DISTCLEAN_DIRS += lcov_reports*


