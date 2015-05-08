From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri,  8 May 2015 19:02:40 +0000 (UTC)
Subject: master - tests: better filter
Message-ID: <20150508190240.9E8D360393@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=53aff9322e6be8f805688445fb7d7d8825d53692
Commit:        53aff9322e6be8f805688445fb7d7d8825d53692
Parent:        1d832aef09c8a96308441750b475ca96b7c91cc3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri May 8 20:44:43 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri May 8 21:00:10 2015 +0200

tests: better filter

Filter $PREFIX rather then just LVMTEST.
---
 test/lib/aux.sh   |    4 ++--
 test/lib/utils.sh |    2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 80792f5..d1d38f8 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -95,7 +95,7 @@ prepare_lvmetad() {
 	kill_sleep_kill_ LOCAL_LVMETAD ${LVM_VALGRIND_LVMETAD:-0}
 
 	# Avoid reconfiguring, if already set to use_lvmetad
-	(grep use_lvmetad CONFIG_VALUES 2>/dev/null | tail -1 | grep -q 1) || \
+	(grep use_lvmetad CONFIG_VALUES 2>/dev/null | tail -n 1 | grep -q 1) || \
 		aux lvmconf "global/use_lvmetad = 1" "devices/md_component_detection = 0"
 	# Default debug is "-l all" and could be override
 	# by setting LVM_TEST_LVMETAD_DEBUG_OPTS before calling inittest.
@@ -735,7 +735,7 @@ extend_filter() {
 }
 
 extend_filter_LVMTEST() {
-	extend_filter "a|$DM_DEV_DIR/LVMTEST|"
+	extend_filter "a|$DM_DEV_DIR/$PREFIX|"
 }
 
 hide_dev() {
diff --git a/test/lib/utils.sh b/test/lib/utils.sh
index ba3ba34..fe7ccd3 100644
--- a/test/lib/utils.sh
+++ b/test/lib/utils.sh
@@ -166,7 +166,7 @@ STACKTRACE() {
 			       "$DM_DEV_DIR" | sed -e "s,^,## LSLR:	,"
 			echo "<======== Udev DB content ========>"
 			for i in /sys/block/dm-* /sys/block/loop* ; do
-				udevadm info --query=all --path "$i" || true
+				udevadm info --query=all --path "$i" 2>/dev/null || true
 			done | sed -e "s,^,## UDEV:	,"
 		fi
 		echo "<======== Script file \"$(< TESTNAME)\" ========>"


