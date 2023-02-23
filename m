From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 23 Feb 2023 15:48:53 +0000 (GMT)
Subject: main - makefiles: avoid grep
Message-ID: <20230223154853.76FA73858C00@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e0c95f15a7a859ee41a6561cae1e53c17a23a0c3
Commit:        e0c95f15a7a859ee41a6561cae1e53c17a23a0c3
Parent:        c1cecc3dc5164856f27e08e5d031315785be2c9f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Feb 22 21:53:41 2023 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Feb 23 16:46:35 2023 +0100

makefiles: avoid grep

Avoid getting annoyting grep warning and use just awk to get the
value.
---
 udev/Makefile.in | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/udev/Makefile.in b/udev/Makefile.in
index 5ee30d09c..e592c534d 100644
--- a/udev/Makefile.in
+++ b/udev/Makefile.in
@@ -20,7 +20,7 @@ include $(top_builddir)/make.tmpl
 DM_RULES=10-dm.rules 13-dm-disk.rules 95-dm-notify.rules
 LVM_RULES=11-dm-lvm.rules 69-dm-lvm.rules
 
-DM_DIR=$(shell $(GREP) "\#define DM_DIR" $(top_srcdir)/libdm/misc/dm-ioctl.h | $(AWK) '{print $$3}')
+DM_DIR=$(shell $(AWK) '/\#define DM_DIR/ {print $$3}' $(top_srcdir)/libdm/misc/dm-ioctl.h)
 
 SYSTEMDRUN=@SYSTEMD_RUN_CMD@
 ifeq ("@UDEV_RULE_EXEC_DETECTION@", "yes")

