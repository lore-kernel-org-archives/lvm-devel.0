From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 25 Mar 2014 23:06:39 +0000 (UTC)
Subject: master - tests: check forced backup
Message-ID: <20140325230639.C64A961055@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4b30863e857aa5a671485227c9b7a7e3a6d1e277
Commit:        4b30863e857aa5a671485227c9b7a7e3a6d1e277
Parent:        4adbb85c372b1030b67749f7f208132a2cc06a7f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Mar 25 23:55:04 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Mar 26 00:05:46 2014 +0100

tests: check forced backup

---
 test/shell/vgcfgbackup-usage.sh |   11 +++++++++++
 1 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/test/shell/vgcfgbackup-usage.sh b/test/shell/vgcfgbackup-usage.sh
index 314ecdd..3d955b5 100644
--- a/test/shell/vgcfgbackup-usage.sh
+++ b/test/shell/vgcfgbackup-usage.sh
@@ -13,11 +13,22 @@
 
 aux prepare_pvs 4
 
+# No automatic backup
+aux lvmconf "backup/backup = 0"
+
 # vgcfgbackup handles similar VG names (bz458941)
 vg1=${PREFIX}vg00
 vg2=${PREFIX}vg01
 vgcreate $vg1 "$dev1"
 vgcreate $vg2 "$dev2"
+
+# Enforces system backup
+test ! -e etc/backup/$vg1
+test ! -e etc/backup/$vg2
+vgcfgbackup
+test -e etc/backup/$vg1
+test -e etc/backup/$vg2
+
 vgcfgbackup -f bak-%s >out
 grep "Volume group \"$vg1\" successfully backed up." out
 grep "Volume group \"$vg2\" successfully backed up." out


