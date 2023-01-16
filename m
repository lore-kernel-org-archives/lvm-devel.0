From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 16 Jan 2023 11:39:20 +0000 (GMT)
Subject: main - makefiles: fix grep warning from make
Message-ID: <20230116113920.D9D883858D32@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=92199ad0b98586182a52e2f8cd82c06336e306f1
Commit:        92199ad0b98586182a52e2f8cd82c06336e306f1
Parent:        3a58e08b8c1ef8b988a588301e097f50c843f0aa
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Jan 15 21:42:41 2023 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jan 16 12:37:40 2023 +0100

makefiles: fix grep warning from make

Remove unnecessary '\'.
---
 udev/Makefile.in | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/udev/Makefile.in b/udev/Makefile.in
index e777dda16..ac4de0a6a 100644
--- a/udev/Makefile.in
+++ b/udev/Makefile.in
@@ -20,7 +20,7 @@ include $(top_builddir)/make.tmpl
 DM_RULES=10-dm.rules 13-dm-disk.rules 95-dm-notify.rules
 LVM_RULES=11-dm-lvm.rules 69-dm-lvm.rules
 
-DM_DIR=$(shell $(GREP) "\#define DM_DIR" $(top_srcdir)/libdm/misc/dm-ioctl.h | $(AWK) '{print $$3}')
+DM_DIR=$(shell $(GREP) "#define DM_DIR" $(top_srcdir)/libdm/misc/dm-ioctl.h | $(AWK) '{print $$3}')
 
 BINDIR=@bindir@
 ifeq ("@UDEV_RULE_EXEC_DETECTION@", "yes")

