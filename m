From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 17 Jul 2017 07:41:25 -0400
Subject: master - tests: aux.sh correcting bounder values
Message-ID: <201707171141.v6HBfPFb022685@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f293d469463ad26cbd5e1aefce6e939afceb36ff
Commit:        f293d469463ad26cbd5e1aefce6e939afceb36ff
Parent:        84b56872fbf82f6c0509cab6cc8a5054489cb2d8
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Jul 16 20:41:13 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 17 12:33:42 2017 +0200

tests: aux.sh correcting bounder values

grep for defined PREFIX.
use 'dev' instead of undefined mddev.
---
 test/lib/aux.sh |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 30623b3..da367aa 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -566,7 +566,7 @@ teardown() {
 	dm_table | not grep -E -q "$vg|$vg1|$vg2|$vg3|$vg4" || {
 		# Avoid activation of dmeventd if there is no pid
 		cfg=$(test -s LOCAL_DMEVENTD || echo "--config activation{monitoring=0}")
-		if dm_info suspended,name | grep -q "^Suspended:.*$prefix" ; then
+		if dm_info suspended,name | grep -q "^Suspended:.*$PREFIX" ; then
 			echo "## skipping vgremove, suspended devices detected."
 		else
 			vgremove -ff "$cfg"  \
@@ -681,7 +681,7 @@ prepare_scsi_debug_dev() {
 
 	rm -f debug.log strace.log
 	test ! -f "SCSI_DEBUG_DEV" || return 0
-	test -z "$LOOP"
+	test ! -f LOOP
 	test -n "$DM_DEV_DIR"
 
 	# Skip test if scsi_debug module is unavailable or is already in use
@@ -786,12 +786,12 @@ cleanup_md_dev() {
 		notify_lvmetad "$dev"
 	done
 	udev_wait
-	if [ -b "$mddev" ]; then
+	if [ -b "$dev" ]; then
 		# mdadm doesn't always cleanup the device node
 		# sleeps offer hack to defeat: 'md: md127 still in use'
 		# see: https://bugzilla.redhat.com/show_bug.cgi?id=509908#c25
 		sleep 2
-		rm -f "$mddev"
+		rm -f "$dev"
 	fi
 	rm -f MD_DEV MD_DEVICES MD_DEV_PV
 }


