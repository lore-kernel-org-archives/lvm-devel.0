From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun, 17 May 2015 18:29:17 +0000 (UTC)
Subject: master - tests: no warn if test does not need thin_repair
Message-ID: <20150517182917.5F4A2605CD@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=76cc477fbabf2ee7ceea48950cd1db32eb2e5fca
Commit:        76cc477fbabf2ee7ceea48950cd1db32eb2e5fca
Parent:        2fca6cdeb3df2793cb88c4e99af65703615e4e14
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun May 17 17:22:18 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun May 17 20:24:36 2015 +0200

tests: no warn if test does not need thin_repair

Set LVM_TEST_THIN_REPAIR_CMD to /bin/false for test which
doesn't need it.

This way - even if on the system there is no such tool present,
test will not result with warning about missing tool.

Also remove from Makefile settings of TEST vars which are set in
through /lib/paths  - this also allows to override them in test.
---
 test/Makefile.in                              |    9 ---------
 test/shell/discards-thin.sh                   |    2 ++
 test/shell/lvchange-thin.sh                   |    2 ++
 test/shell/lvcreate-thin-big.sh               |    2 ++
 test/shell/lvcreate-thin-external.sh          |    2 ++
 test/shell/lvcreate-thin-power2.sh            |    2 ++
 test/shell/lvcreate-thin-snap.sh              |    2 ++
 test/shell/lvcreate-thin.sh                   |    2 ++
 test/shell/lvextend-thin-metadata-dmeventd.sh |    3 +++
 test/shell/lvextend-thin.sh                   |    2 ++
 test/shell/lvresize-thin-external-origin.sh   |    3 +++
 test/shell/lvresize-thin-metadata.sh          |    2 ++
 test/shell/profiles-thin.sh                   |    2 ++
 test/shell/select-tools-thin.sh               |    4 ++++
 test/shell/thin-autoumount-dmeventd.sh        |    2 ++
 test/shell/thin-defaults.sh                   |    2 ++
 test/shell/thin-merge.sh                      |    2 ++
 test/shell/thin-restore.sh                    |    2 ++
 test/shell/thin-vglock.sh                     |    2 ++
 test/shell/thin-volume-list.sh                |    2 ++
 test/shell/vgsplit-thin.sh                    |    2 ++
 21 files changed, 44 insertions(+), 9 deletions(-)

diff --git a/test/Makefile.in b/test/Makefile.in
index 2a193ab..ecd510a 100644
--- a/test/Makefile.in
+++ b/test/Makefile.in
@@ -26,15 +26,6 @@ abs_top_srcdir = @abs_top_srcdir@
 datarootdir = @datarootdir@
 
 LVM_TEST_RESULTS ?= results
-export LVM_TEST_THIN_CHECK_CMD?=@THIN_CHECK_CMD@
-export LVM_TEST_THIN_DUMP_CMD?=@THIN_DUMP_CMD@
-export LVM_TEST_THIN_REPAIR_CMD?=@THIN_REPAIR_CMD@
-export LVM_TEST_THIN_RESTORE_CMD?=@THIN_RESTORE_CMD@
-
-export LVM_TEST_CACHE_CHECK_CMD?=@CACHE_CHECK_CMD@
-export LVM_TEST_CACHE_DUMP_CMD?=@CACHE_DUMP_CMD@
-export LVM_TEST_CACHE_REPAIR_CMD?=@CACHE_REPAIR_CMD@
-export LVM_TEST_CACHE_RESTORE_CMD?=@CACHE_RESTORE_CMD@
 
 SUBDIRS = api unit
 SOURCES = lib/not.c lib/harness.c
diff --git a/test/shell/discards-thin.sh b/test/shell/discards-thin.sh
index 8acb20d..fbd0d87 100644
--- a/test/shell/discards-thin.sh
+++ b/test/shell/discards-thin.sh
@@ -13,6 +13,8 @@
 # test support of thin discards
 #
 
+export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
+
 . lib/inittest
 
 test -e LOCAL_LVMPOLLD && skip
diff --git a/test/shell/lvchange-thin.sh b/test/shell/lvchange-thin.sh
index 763bc34..b66c5ee 100644
--- a/test/shell/lvchange-thin.sh
+++ b/test/shell/lvchange-thin.sh
@@ -9,6 +9,8 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
+export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
+
 . lib/inittest
 
 test -e LOCAL_LVMPOLLD && skip
diff --git a/test/shell/lvcreate-thin-big.sh b/test/shell/lvcreate-thin-big.sh
index 0ef5cbc..dbd0986 100644
--- a/test/shell/lvcreate-thin-big.sh
+++ b/test/shell/lvcreate-thin-big.sh
@@ -13,6 +13,8 @@
 # test currently needs to drop
 # 'return NULL' in _lv_create_an_lv after log_error("Can't create %s without using "
 
+export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
+
 . lib/inittest
 
 test -e LOCAL_LVMPOLLD && skip
diff --git a/test/shell/lvcreate-thin-external.sh b/test/shell/lvcreate-thin-external.sh
index bb5cef2..9e907a6 100644
--- a/test/shell/lvcreate-thin-external.sh
+++ b/test/shell/lvcreate-thin-external.sh
@@ -12,6 +12,8 @@
 
 # Test creation of thin snapshots using external origin
 
+export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
+
 . lib/inittest
 
 test -e LOCAL_LVMPOLLD && skip
diff --git a/test/shell/lvcreate-thin-power2.sh b/test/shell/lvcreate-thin-power2.sh
index fcae643..4d3d175 100644
--- a/test/shell/lvcreate-thin-power2.sh
+++ b/test/shell/lvcreate-thin-power2.sh
@@ -13,6 +13,8 @@
 # test support for non-power-of-2 thin chunk size
 #
 
+export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
+
 . lib/inittest
 
 test -e LOCAL_LVMPOLLD && skip
diff --git a/test/shell/lvcreate-thin-snap.sh b/test/shell/lvcreate-thin-snap.sh
index d801d4a..76929cc 100644
--- a/test/shell/lvcreate-thin-snap.sh
+++ b/test/shell/lvcreate-thin-snap.sh
@@ -10,6 +10,8 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
+export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
+
 . lib/inittest
 
 test -e LOCAL_LVMPOLLD && skip
diff --git a/test/shell/lvcreate-thin.sh b/test/shell/lvcreate-thin.sh
index 18e4644..56d7e35 100644
--- a/test/shell/lvcreate-thin.sh
+++ b/test/shell/lvcreate-thin.sh
@@ -13,6 +13,8 @@
 # test currently needs to drop
 # 'return NULL' in _lv_create_an_lv after log_error("Can't create %s without using "
 
+export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
+
 . lib/inittest
 
 test -e LOCAL_LVMPOLLD && skip
diff --git a/test/shell/lvextend-thin-metadata-dmeventd.sh b/test/shell/lvextend-thin-metadata-dmeventd.sh
index 78dce6d..473f1ca 100644
--- a/test/shell/lvextend-thin-metadata-dmeventd.sh
+++ b/test/shell/lvextend-thin-metadata-dmeventd.sh
@@ -10,6 +10,9 @@
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
 # Test autoextension of thin metadata volume
+
+export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
+
 . lib/inittest
 
 test -e LOCAL_LVMPOLLD && skip
diff --git a/test/shell/lvextend-thin.sh b/test/shell/lvextend-thin.sh
index ab538a7..1e64e42 100644
--- a/test/shell/lvextend-thin.sh
+++ b/test/shell/lvextend-thin.sh
@@ -9,6 +9,8 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
+export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
+
 . lib/inittest
 
 test -e LOCAL_LVMPOLLD && skip
diff --git a/test/shell/lvresize-thin-external-origin.sh b/test/shell/lvresize-thin-external-origin.sh
index 82b7f8b..66de5f8 100644
--- a/test/shell/lvresize-thin-external-origin.sh
+++ b/test/shell/lvresize-thin-external-origin.sh
@@ -10,6 +10,9 @@
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
 # Test resize of thin volume with external origin
+
+export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
+
 . lib/inittest
 
 test -e LOCAL_LVMPOLLD && skip
diff --git a/test/shell/lvresize-thin-metadata.sh b/test/shell/lvresize-thin-metadata.sh
index 4416b67..82ac898 100644
--- a/test/shell/lvresize-thin-metadata.sh
+++ b/test/shell/lvresize-thin-metadata.sh
@@ -9,6 +9,8 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
+export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
+
 . lib/inittest
 
 test -e LOCAL_LVMPOLLD && skip
diff --git a/test/shell/profiles-thin.sh b/test/shell/profiles-thin.sh
index 9578ed1..0c7fb61 100644
--- a/test/shell/profiles-thin.sh
+++ b/test/shell/profiles-thin.sh
@@ -13,6 +13,8 @@
 # test thin profile functionality
 #
 
+export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
+
 . lib/inittest
 
 test -e LOCAL_LVMPOLLD && skip
diff --git a/test/shell/select-tools-thin.sh b/test/shell/select-tools-thin.sh
index 37c4856..4cabde1 100644
--- a/test/shell/select-tools-thin.sh
+++ b/test/shell/select-tools-thin.sh
@@ -9,6 +9,8 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
+export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
+
 . lib/inittest
 
 test -e LOCAL_LVMPOLLD && skip
@@ -35,3 +37,5 @@ grep "Logical volume \"thin_orig\" successfully removed" out
 grep "Logical volume \"thin_snap\" successfully removed" out
 not lvs $vg1/thin_orig
 not lvs $vg1/thin_snap
+
+vgremove -ff $vg1
diff --git a/test/shell/thin-autoumount-dmeventd.sh b/test/shell/thin-autoumount-dmeventd.sh
index 00ea859..5f1fc6b 100644
--- a/test/shell/thin-autoumount-dmeventd.sh
+++ b/test/shell/thin-autoumount-dmeventd.sh
@@ -11,6 +11,8 @@
 
 # no automatic extensions, just umount
 
+export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
+
 is_dir_mounted_()
 {
 	cat /proc/mounts | sed 's:\\040: :g' | grep "$1"
diff --git a/test/shell/thin-defaults.sh b/test/shell/thin-defaults.sh
index 4341899..3e49390 100644
--- a/test/shell/thin-defaults.sh
+++ b/test/shell/thin-defaults.sh
@@ -11,6 +11,8 @@
 
 # test defaults entered through lvm.conf
 
+export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
+
 . lib/inittest
 
 test -e LOCAL_LVMPOLLD && skip
diff --git a/test/shell/thin-merge.sh b/test/shell/thin-merge.sh
index d3275dd..ef53496 100644
--- a/test/shell/thin-merge.sh
+++ b/test/shell/thin-merge.sh
@@ -11,6 +11,8 @@
 
 # test merge of thin snapshot
 
+export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
+
 . lib/inittest
 
 MKFS=mkfs.ext2
diff --git a/test/shell/thin-restore.sh b/test/shell/thin-restore.sh
index 1ac4f66..3516e2d 100644
--- a/test/shell/thin-restore.sh
+++ b/test/shell/thin-restore.sh
@@ -11,6 +11,8 @@
 
 # test restore operation of thin pool metadata
 
+export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
+
 . lib/inittest
 
 test -e LOCAL_LVMPOLLD && skip
diff --git a/test/shell/thin-vglock.sh b/test/shell/thin-vglock.sh
index fe1ee11..d06c62c 100644
--- a/test/shell/thin-vglock.sh
+++ b/test/shell/thin-vglock.sh
@@ -12,6 +12,8 @@
 # Test locking works and doesn't update metadata
 # RHBZ: https://bugzilla.redhat.com/show_bug.cgi?id=1063542
 
+export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
+
 . lib/inittest
 
 MKFS=mkfs.ext2
diff --git a/test/shell/thin-volume-list.sh b/test/shell/thin-volume-list.sh
index e173d87..c3dab25 100644
--- a/test/shell/thin-volume-list.sh
+++ b/test/shell/thin-volume-list.sh
@@ -11,6 +11,8 @@
 
 # test pool behaviour when volume_list masks activation
 
+export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
+
 . lib/inittest
 
 test -e LOCAL_LVMPOLLD && skip
diff --git a/test/shell/vgsplit-thin.sh b/test/shell/vgsplit-thin.sh
index 0f6b427..754f8ba 100644
--- a/test/shell/vgsplit-thin.sh
+++ b/test/shell/vgsplit-thin.sh
@@ -11,6 +11,8 @@
 
 # Test vgsplit command options for validity
 
+export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
+
 . lib/inittest
 
 test -e LOCAL_LVMPOLLD && skip


