From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 20 Jul 2017 06:19:21 -0400
Subject: master - tests: aus.sh fix md teardown
Message-ID: <201707201019.v6KAJLY3016567@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7b048f6b43a7cb752bae44fbed0da8508b24b959
Commit:        7b048f6b43a7cb752bae44fbed0da8508b24b959
Parent:        48ce8c7a49a963a3d1357ad2b964f46902a2c163
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jul 20 12:15:06 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jul 20 12:16:27 2017 +0200

tests: aus.sh fix md teardown

Commit 8a912d6dbcc34ce2b76a0104c39de7aa0480c512 missed the wrong logic,
we use 2 vars 'dev' & 'mddev' and their usage can't be mixed.

So correctly separate them so mddev keeps name of MD device.
---
 test/lib/aux.sh |   11 ++++++-----
 1 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index e620e81..b8a0cc0 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -778,10 +778,11 @@ cleanup_md_dev() {
 
 	local IFS=$IFS_NL
 	local dev
-	dev=$(< MD_DEV)
+	local mddev
+	mddev=$(< MD_DEV)
 	udev_wait
-	mdadm --stop "$dev" || true
-	test "$DM_DEV_DIR" != "/dev" && rm -f "$DM_DEV_DIR/$(basename "$dev")"
+	mdadm --stop "$mddev" || true
+	test "$DM_DEV_DIR" != "/dev" && rm -f "$DM_DEV_DIR/$(basename "$mddev")"
 	notify_lvmetad "$(< MD_DEV_PV)"
 	udev_wait  # wait till events are process, not zeroing to early
 	for dev in $(< MD_DEVICES); do
@@ -789,12 +790,12 @@ cleanup_md_dev() {
 		notify_lvmetad "$dev"
 	done
 	udev_wait
-	if [ -b "$dev" ]; then
+	if [ -b "$mddev" ]; then
 		# mdadm doesn't always cleanup the device node
 		# sleeps offer hack to defeat: 'md: md127 still in use'
 		# see: https://bugzilla.redhat.com/show_bug.cgi?id=509908#c25
 		sleep 2
-		rm -f "$dev"
+		rm -f "$mddev"
 	fi
 	rm -f MD_DEV MD_DEVICES MD_DEV_PV
 }


