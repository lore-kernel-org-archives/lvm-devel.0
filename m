From: Marian Csontos <mcsontos@sourceware.org>
Date: Wed, 25 Jan 2023 09:00:36 +0000 (GMT)
Subject: main - Revert "makefiles: fix grep warning from make"
Message-ID: <20230125090036.966573858D28@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=49c650423a17197c66b1c839a0274db8fba9a7d9
Commit:        49c650423a17197c66b1c839a0274db8fba9a7d9
Parent:        ed808a9b548ca59221d512bfb7ae581e8367fe50
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Wed Jan 25 09:46:18 2023 +0100
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Wed Jan 25 09:46:18 2023 +0100

Revert "makefiles: fix grep warning from make"

This reverts commit 92199ad0b98586182a52e2f8cd82c06336e306f1.

This breaks make rpm.
---
 udev/Makefile.in | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/udev/Makefile.in b/udev/Makefile.in
index ac4de0a6a..e777dda16 100644
--- a/udev/Makefile.in
+++ b/udev/Makefile.in
@@ -20,7 +20,7 @@ include $(top_builddir)/make.tmpl
 DM_RULES=10-dm.rules 13-dm-disk.rules 95-dm-notify.rules
 LVM_RULES=11-dm-lvm.rules 69-dm-lvm.rules
 
-DM_DIR=$(shell $(GREP) "#define DM_DIR" $(top_srcdir)/libdm/misc/dm-ioctl.h | $(AWK) '{print $$3}')
+DM_DIR=$(shell $(GREP) "\#define DM_DIR" $(top_srcdir)/libdm/misc/dm-ioctl.h | $(AWK) '{print $$3}')
 
 BINDIR=@bindir@
 ifeq ("@UDEV_RULE_EXEC_DETECTION@", "yes")

