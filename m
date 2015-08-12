From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 12 Aug 2015 17:47:09 +0000 (UTC)
Subject: master - udev: fix missing escape for +
Message-ID: <20150812174709.9057560DF2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0f45aa7f313e60e10aec6779e86f2179b8ac8865
Commit:        0f45aa7f313e60e10aec6779e86f2179b8ac8865
Parent:        2cf3336130b01dc40e89bdd83fceabf057b4a03c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Aug 12 19:45:32 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Aug 12 19:46:44 2015 +0200

udev: fix missing escape for +

Commit 3ea396e9d220cec55fd4e139be7ae486cb4ddb91 missed to escape +
which is used by 'sed' as separator for 's'.
---
 udev/Makefile.in |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/udev/Makefile.in b/udev/Makefile.in
index c4cc2bd..cd031ae 100644
--- a/udev/Makefile.in
+++ b/udev/Makefile.in
@@ -47,7 +47,7 @@ BLKID_RULE=IMPORT{program}=\"${SBIN}\/blkid -o udev -p \$$tempnode\"
 endif
 
 ifeq ("@UDEV_SYSTEMD_BACKGROUND_JOBS@", "yes")
-PVSCAN_RULE=ACTION\!=\"remove\", ENV{LVM_PV_GONE}==\"1\", RUN\+=\"@bindir@/systemd-run $(LVM_EXEC)\/lvm pvscan --cache \$$major\:\$$minor\", GOTO=\"lvm_end\"\nENV{SYSTEMD_ALIAS}=\"\/dev\/block\/\$$major:\$$minor\"\nENV{ID_MODEL}=\"LVM PV \$$env{ID_FS_UUID_ENC} on \/dev\/\$$name\"\nENV{SYSTEMD_WANTS}+=\"lvm2-pvscan@\$$major:\$$minor.service\"
+PVSCAN_RULE=ACTION\!=\"remove\", ENV{LVM_PV_GONE}==\"1\", RUN\+=\"@bindir@/systemd-run $(LVM_EXEC)\/lvm pvscan --cache \$$major\:\$$minor\", GOTO=\"lvm_end\"\nENV{SYSTEMD_ALIAS}=\"\/dev\/block\/\$$major:\$$minor\"\nENV{ID_MODEL}=\"LVM PV \$$env{ID_FS_UUID_ENC} on \/dev\/\$$name\"\nENV{SYSTEMD_WANTS}\+=\"lvm2-pvscan@\$$major:\$$minor.service\"
 else
 PVSCAN_RULE=RUN\+\=\"$(LVM_EXEC)/lvm pvscan --background --cache --activate ay --major \$$major --minor \$$minor\", ENV{LVM_SCANNED}=\"1\"
 endif


