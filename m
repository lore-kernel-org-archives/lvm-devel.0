From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 12 Aug 2015 07:33:24 +0000 (UTC)
Subject: master - udev: use += for SYSTEMD_WANTS instead of =
Message-ID: <20150812073324.00CFD60641@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3ea396e9d220cec55fd4e139be7ae486cb4ddb91
Commit:        3ea396e9d220cec55fd4e139be7ae486cb4ddb91
Parent:        819dc1845edcf48e0f3eb282a6d8b9ace8cb1a1b
Author:        Thomas B??chler <thomas@archlinux.org>
AuthorDate:    Wed Aug 12 09:29:04 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Aug 12 09:33:06 2015 +0200

udev: use += for SYSTEMD_WANTS instead of =

Instead of using = to override SYSTEMD_WANTS, use += to add
the pvscan service.
---
 WHATS_NEW        |    1 +
 udev/Makefile.in |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 71c41d2..8241dc1 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.128 - 
 ===================================
+  Fix lvmetad udev rules to not override SYSTEMD_WANTS, add the service instead.
 
 Version 2.02.127 - 10th August 2015
 ===================================
diff --git a/udev/Makefile.in b/udev/Makefile.in
index 390069b..c4cc2bd 100644
--- a/udev/Makefile.in
+++ b/udev/Makefile.in
@@ -47,7 +47,7 @@ BLKID_RULE=IMPORT{program}=\"${SBIN}\/blkid -o udev -p \$$tempnode\"
 endif
 
 ifeq ("@UDEV_SYSTEMD_BACKGROUND_JOBS@", "yes")
-PVSCAN_RULE=ACTION\!=\"remove\", ENV{LVM_PV_GONE}==\"1\", RUN\+=\"@bindir@/systemd-run $(LVM_EXEC)\/lvm pvscan --cache \$$major\:\$$minor\", GOTO=\"lvm_end\"\nENV{SYSTEMD_ALIAS}=\"\/dev\/block\/\$$major:\$$minor\"\nENV{ID_MODEL}=\"LVM PV \$$env{ID_FS_UUID_ENC} on \/dev\/\$$name\"\nENV{SYSTEMD_WANTS}=\"lvm2-pvscan@\$$major:\$$minor.service\"
+PVSCAN_RULE=ACTION\!=\"remove\", ENV{LVM_PV_GONE}==\"1\", RUN\+=\"@bindir@/systemd-run $(LVM_EXEC)\/lvm pvscan --cache \$$major\:\$$minor\", GOTO=\"lvm_end\"\nENV{SYSTEMD_ALIAS}=\"\/dev\/block\/\$$major:\$$minor\"\nENV{ID_MODEL}=\"LVM PV \$$env{ID_FS_UUID_ENC} on \/dev\/\$$name\"\nENV{SYSTEMD_WANTS}+=\"lvm2-pvscan@\$$major:\$$minor.service\"
 else
 PVSCAN_RULE=RUN\+\=\"$(LVM_EXEC)/lvm pvscan --background --cache --activate ay --major \$$major --minor \$$minor\", ENV{LVM_SCANNED}=\"1\"
 endif


