From: Thomas Bächler <thomas@archlinux.org>
Date: Tue, 11 Aug 2015 09:44:02 +0200
Subject: [PATCH] udev: Do not override SYSTEMD_WANTS environment variable
Message-ID: <1439279042-2040-1-git-send-email-thomas@archlinux.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Instead of using = to override SYSTEMD_WANTS, use += to add the pvscan service.
---
 udev/Makefile.in | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

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
-- 
2.4.6


