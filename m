From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu,  6 Mar 2014 16:31:12 +0000 (UTC)
Subject: master - makefiles: use BLKID/UDEV_CFLAGS properly
Message-ID: <20140306163112.0917660DF1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7a595d7388d2dfdb4253ef9425c812491c8e7af5
Commit:        7a595d7388d2dfdb4253ef9425c812491c8e7af5
Parent:        216c57eed72fee52e99bb5d014c9de535e631f58
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Mar 6 16:03:08 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Mar 6 17:30:06 2014 +0100

makefiles: use BLKID/UDEV_CFLAGS properly

blkid.h needs BLKID_CFLAGS
Do not add UDEV_CFLAGS everywhere and use it only when needed.
---
 WHATS_NEW             |    1 +
 lib/Makefile.in       |    2 ++
 lib/device/dev-type.c |    2 +-
 make.tmpl.in          |    6 ++++--
 4 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 6e04327..f72587a 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.106 - 
 ====================================
+  Use BLKID_CFLAGS when compiling with blkid support.
   Use correct rl_completion_func_t typedef for new readline.
   Make lvm 'dumpconfig --type default' complete for it to be consumed by lvm.
   Run pvscan --cache via systemd-run in udev if the PV label is detected lost.
diff --git a/lib/Makefile.in b/lib/Makefile.in
index 968ad00..c3d4598 100644
--- a/lib/Makefile.in
+++ b/lib/Makefile.in
@@ -217,6 +217,8 @@ CFLOW_LIST_TARGET = $(LIB_NAME).cflow
 
 include $(top_builddir)/make.tmpl
 
+CFLAGS += $(BLKID_CFLAGS) $(UDEV_CFLAGS)
+
 $(SUBDIRS): $(LIB_STATIC)
 
 DISTCLEAN_TARGETS += misc/configure.h misc/lvm-version.h
diff --git a/lib/device/dev-type.c b/lib/device/dev-type.c
index 81100ad..193e9bd 100644
--- a/lib/device/dev-type.c
+++ b/lib/device/dev-type.c
@@ -22,7 +22,7 @@
 #include <ctype.h>
 
 #ifdef BLKID_WIPING_SUPPORT
-#include <blkid/blkid.h>
+#include <blkid.h>
 #endif
 
 #include "device-types.h"
diff --git a/make.tmpl.in b/make.tmpl.in
index 7d7d701..b1a6b8f 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -46,7 +46,7 @@ LIBS = @LIBS@
 STATIC_LIBS = $(SELINUX_LIBS) $(UDEV_LIBS) $(BLKID_LIBS)
 DEFS += @DEFS@
 # FIXME set this only where it's needed, not globally?
-CFLAGS += @CFLAGS@ @UDEV_CFLAGS@
+CFLAGS += @CFLAGS@
 CLDFLAGS += @CLDFLAGS@
 ELDFLAGS += @ELDFLAGS@
 LDDEPS += @LDDEPS@
@@ -57,8 +57,10 @@ DL_LIBS = @DL_LIBS@
 PTHREAD_LIBS = @PTHREAD_LIBS@
 READLINE_LIBS = @READLINE_LIBS@
 SELINUX_LIBS = @SELINUX_LIBS@
+UDEV_CFLAGS = @UDEV_CFLAGS@
 UDEV_LIBS = @UDEV_LIBS@
-BLKID_LIBS=@BLKID_LIBS@
+BLKID_CFLAGS = @BLKID_CFLAGS@
+BLKID_LIBS = @BLKID_LIBS@
 TESTING = @TESTING@
 
 # Setup directory variables


