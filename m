From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 22 Oct 2013 13:14:33 +0000 (UTC)
Subject: master - make: correct sed line in udev's Makefile
Message-ID: <20131022131433.07DF16019A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c3f44a0c66abf8916bebafe2de9da30132cea9e2
Commit:        c3f44a0c66abf8916bebafe2de9da30132cea9e2
Parent:        3fee6610286f83737d193c9047e24e8d7c85d1ce
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Oct 22 15:13:58 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Oct 22 15:13:58 2013 +0200

make: correct sed line in udev's Makefile

---
 udev/Makefile.in |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/udev/Makefile.in b/udev/Makefile.in
index 8f0dc8a..40a4671 100644
--- a/udev/Makefile.in
+++ b/udev/Makefile.in
@@ -47,9 +47,7 @@ BLKID_RULE=IMPORT{program}=\"${SBIN}\/blkid -o udev -p \$$tempnode\"
 endif
 
 ifeq ("@UDEV_SYSTEMD_BACKGROUND_JOBS@", "yes")
-PVSCAN_RULE="ENV{SYSTEMD_ALIAS}=\"/dev/block/$$major:$$minor\" \
-	     ENV{ID_MODEL}=\"LVM PV $$env{ID_FS_UUID_ENC} on /dev/$$name\" \
-	     ENV{SYSTEMD_WANTS}=\"lvm2-pvscan@\$$devnode.service\""
+PVSCAN_RULE=ENV{SYSTEMD_ALIAS}=\"\/dev\/block\/\$$major:\$$minor\"\nENV{ID_MODEL}=\"LVM PV \$$env{ID_FS_UUID_ENC} on \/dev\/\$$name\"\nENV{SYSTEMD_WANTS}=\"lvm2-pvscan@\$$major:\$$minor.service\"
 else
 PVSCAN_RULE=RUN\+\=\"$(LVM_EXEC)/lvm pvscan --background --cache --activate ay --major \$$major --minor \$$minor\", ENV{LVM_SCANNED}=\"1\"
 endif


