From: Milan Broz <mbroz@redhat.com>
Date: Sun, 10 May 2009 20:06:11 +0200
Subject: [PATCH] Fix device-mapper static build targets.
In-Reply-To: <1241978772-6394-1-git-send-email-mbroz@redhat.com>
References: <1241978772-6394-1-git-send-email-mbroz@redhat.com>
Message-ID: <1241978772-6394-4-git-send-email-mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

dmsetup.static is not built and cleaned properly
if running only device-mapper install/build.

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 tools/Makefile.in |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/tools/Makefile.in b/tools/Makefile.in
index 05df82f..874d391 100644
--- a/tools/Makefile.in
+++ b/tools/Makefile.in
@@ -66,12 +66,15 @@ TARGETS =\
 	.commands \
 	lvm
 
+TARGETS_DM = dmsetup
+
 INSTALL_LVM_TARGETS = install_tools_dynamic
 INSTALL_DMSETUP_TARGETS = install_dmsetup_dynamic
 INSTALL_CMDLIB_TARGETS = install_cmdlib_dynamic
 
 ifeq ("@STATIC_LINK@", "yes")
-  TARGETS += lvm.static dmsetup.static
+  TARGETS += lvm.static
+  TARGETS_DM += dmsetup.static
   INSTALL_LVM_TARGETS += install_tools_static
   INSTALL_DMSETUP_TARGETS += install_dmsetup_static
   INSTALL_CMDLIB_TARGETS += install_cmdlib_static
@@ -82,7 +85,7 @@ LVMLIBS = -llvm-internal
 CLEAN_TARGETS = liblvm2cmd.$(LIB_SUFFIX) liblvm2cmd.a liblvm2cmd-static.a lvm lvm.o \
 		lvm2cmd.o lvm2cmd-static.o lvm2cmdlib.o lvm.static \
 		lvm.cflow lvm.xref lvm.tree lvm.rxref lvm.rtree \
-		lvmcmdlib.o lvm-static.o dmsetup.o dmsetup
+		lvmcmdlib.o lvm-static.o dmsetup.o $(TARGETS_DM)
 
 ifeq ("@CMDLIB@", "yes")
 	TARGETS += liblvm2cmd.$(LIB_SUFFIX)
@@ -99,7 +102,7 @@ DEFS += -DLVM_SHARED_PATH=\"$(exec_prefix)/sbin/lvm\"
 
 include $(top_srcdir)/make.tmpl
 
-device-mapper: dmsetup
+device-mapper: $(TARGETS_DM)
 
 dmsetup: dmsetup.o $(top_srcdir)/libdm/libdevmapper.$(LIB_SUFFIX)
 	$(CC) -o $@ dmsetup.o $(CFLAGS) $(LDFLAGS) \
-- 
1.6.2.4


