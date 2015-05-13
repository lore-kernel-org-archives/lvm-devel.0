From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 13 May 2015 22:20:06 +0000 (UTC)
Subject: master - makefiles: protect CFLAGS
Message-ID: <20150513222006.8B9DF60CFB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6fb2552ef47200af1e9b1a987cb3edfdc8f3ee66
Commit:        6fb2552ef47200af1e9b1a987cb3edfdc8f3ee66
Parent:        a2c9ede6b38f2a454e1a18fc4cac9dd06af04972
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed May 13 23:43:50 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu May 14 00:19:33 2015 +0200

makefiles: protect CFLAGS

When CFLAGS and LDFLAGS are passed into - protect them,
and avoid even recursive subdir 'extension' of them.
---
 make.tmpl.in |   17 +++++++++++++----
 1 files changed, 13 insertions(+), 4 deletions(-)

diff --git a/make.tmpl.in b/make.tmpl.in
index 1aae6a2..7ff61fd 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -46,11 +46,11 @@ LIBS = @LIBS@
 STATIC_LIBS = $(SELINUX_LIBS) $(UDEV_LIBS) $(BLKID_LIBS)
 DEFS += @DEFS@
 # FIXME set this only where it's needed, not globally?
-CFLAGS += @CFLAGS@
+CFLAGS ?= @COPTIMISE_FLAG@ @CFLAGS@
+LDFLAGS ?= @COPTIMISE_FLAG@ @LDFLAGS@
 CLDFLAGS += @CLDFLAGS@
 ELDFLAGS += @ELDFLAGS@
 LDDEPS += @LDDEPS@
-LDFLAGS += @LDFLAGS@
 LIB_SUFFIX = @LIB_SUFFIX@
 LVMINTERNAL_LIBS = -llvm-internal $(DAEMON_LIBS) $(UDEV_LIBS) $(DL_LIBS) $(BLKID_LIBS)
 DL_LIBS = @DL_LIBS@
@@ -204,8 +204,13 @@ endif
 #WFLAGS += -pedantic -std=gnu99
 #DEFS += -DDEBUG_CRC32
 
-CFLAGS += -fPIC  @COPTIMISE_FLAG@
-LDFLAGS += @COPTIMISE_FLAG@
+#
+# Avoid recursive extension of CFLAGS
+# by checking whether CFLAGS already has fPIC string
+#
+ifeq (,$(findstring fPIC,$(CFLAGS)))
+
+CFLAGS += -fPIC
 
 ifeq ("@DEBUG@", "yes")
   CFLAGS += -g -fno-omit-frame-pointer
@@ -216,6 +221,10 @@ ifeq ("@DEBUG@", "yes")
   endif
 endif
 
+# end of fPIC protection
+endif
+
+
 ifeq ("@INTL@", "yes")
   DEFS += -DINTL_PACKAGE=\"@INTL_PACKAGE@\" -DLOCALEDIR=\"@LOCALEDIR@\"
 endif


