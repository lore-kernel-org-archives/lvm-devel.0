From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri,  4 Dec 2015 21:11:45 +0000 (UTC)
Subject: master - tests: extend test
Message-ID: <20151204211145.7A23660E57@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fedf15ffb0237d0bc44c13b0ce62122a2aed64ec
Commit:        fedf15ffb0237d0bc44c13b0ce62122a2aed64ec
Parent:        748b8158b5bb7d986fb26f2462c4909f723214fc
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Dec 4 22:09:05 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Dec 4 22:10:30 2015 +0100

tests: extend test

---
 test/shell/backup-read-only.sh |   20 ++++++++++++++++----
 1 files changed, 16 insertions(+), 4 deletions(-)

diff --git a/test/shell/backup-read-only.sh b/test/shell/backup-read-only.sh
index 810db0d..01ac741 100644
--- a/test/shell/backup-read-only.sh
+++ b/test/shell/backup-read-only.sh
@@ -42,7 +42,7 @@ mount -n -r "$etc_lv" "$mount_dir"
 
 aux lvmconf "backup/archive = 1" "backup/backup = 1"
 
-# cannot archive to read-only
+# cannot archive to read-only - requires user to specify -An
 not lvcreate -n $lv2 -l 10%FREE $vg
 lvcreate -An -n $lv2 -l 10%FREE $vg
 
@@ -59,12 +59,24 @@ vgreduce $vg "$dev2"
 mount_dir="etc/backup"
 mount -n -r "$etc_lv" "$mount_dir"
 
-lvcreate -n $lv3 -l 10%FREE $vg
+# Must not fail on making backup
+vgscan
+
+lvcreate -An -n $lv3 -l 10%FREE $vg
+
 vgextend $vg "$dev2"
 
+#
+# Now check both archive & backup read-only
+#
+rm -rf etc/archive
+ln -s backup etc/archive
+
+# Must not fail on making backup
+vgscan
+lvcreate -An -n $lv4 -l 10%FREE $vg
+
 umount "$mount_dir" || true
-#ls -laR
-#grep "" etc/archive/*
 
 # TODO maybe also support --ignorelockingfailure ??
 vgremove -ff $vg


