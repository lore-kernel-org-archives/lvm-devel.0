From: Peter Rajnoha <prajnoha@sourceware.org>
Date: Fri, 22 Sep 2017 05:11:41 -0400
Subject: master - blkdeactivate: cleanup
Message-ID: <201709220911.v8M9BfJ3016707@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b0f4e0fcec1a50b73fbc4f05bfd2d385895bc3bc
Commit:        b0f4e0fcec1a50b73fbc4f05bfd2d385895bc3bc
Parent:        bdccab07f94f6b2e464e2d43d1f91dbb0a9fb2e0
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Sep 22 11:10:57 2017 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Sep 22 11:10:57 2017 +0200

blkdeactivate: cleanup

Use a different variable for translated name in dm/md_deactivate fn
Fix dmraidoption/dmraidoptions in man page.
---
 man/blkdeactivate.8_main    |    2 +-
 scripts/blkdeactivate.sh.in |   20 +++++++++++---------
 2 files changed, 12 insertions(+), 10 deletions(-)

diff --git a/man/blkdeactivate.8_main b/man/blkdeactivate.8_main
index 0aa9c2a..f3c19a8 100644
--- a/man/blkdeactivate.8_main
+++ b/man/blkdeactivate.8_main
@@ -63,7 +63,7 @@ all the paths are unavailable for any underlying device-mapper multipath
 device.
 .RE
 .TP
-.BR -r ", " --mdraidoption \ \fImdraid_options\fP
+.BR -r ", " --mdraidoptions \ \fImdraid_options\fP
 Comma-separated list of MD RAID specific options:
 .RS
 .IP \fIwait\fP
diff --git a/scripts/blkdeactivate.sh.in b/scripts/blkdeactivate.sh.in
index 11b5983..daa53df 100644
--- a/scripts/blkdeactivate.sh.in
+++ b/scripts/blkdeactivate.sh.in
@@ -211,14 +211,15 @@ deactivate_holders () {
 }
 
 deactivate_dm () {
-	local name=$(printf "%s" "$name")
-	test -b "$DEV_DIR/mapper/$name" || return 0
+	local xname
+	xname=$(printf "%s" "$name")
+	test -b "$DEV_DIR/mapper/$xname" || return 0
 	test -z "${SKIP_DEVICE_LIST["$kname"]}" || return 1
 
-	deactivate_holders "$DEV_DIR/mapper/$name" || return 1
+	deactivate_holders "$DEV_DIR/mapper/$xname" || return 1
 
-	echo -n "  [DM]: deactivating $devtype device $name ($kname)... "
-	if eval "$DMSETUP" $DMSETUP_OPTS remove "$name" "$OUT" "$ERR"; then
+	echo -n "  [DM]: deactivating $devtype device $xname ($kname)... "
+	if eval "$DMSETUP" $DMSETUP_OPTS remove "$xname" "$OUT" "$ERR"; then
 		echo "done"
 	else
 		echo "skipping"
@@ -280,9 +281,10 @@ deactivate_lvm () {
 }
 
 deactivate_md () {
-	local name=$(printf "%s" "$name")
+	local xname
+	xname=$(printf "%s" "$name")
 	local sync_action
-	test -b "$DEV_DIR/$name" || return 0
+	test -b "$DEV_DIR/$xname" || return 0
 	test -z "${SKIP_DEVICE_LIST["$kname"]}" || return 1
 
 	# Skip MD device deactivation if MD tools missing.
@@ -291,7 +293,7 @@ deactivate_md () {
 		return 1
 	}
 
-	deactivate_holders "$DEV_DIR/$name" || return 1
+	deactivate_holders "$DEV_DIR/$xname" || return 1
 
 	echo -n "  [MD]: deactivating $devtype device $kname... "
 
@@ -307,7 +309,7 @@ deactivate_md () {
 		}
 	}
 
-	if eval "$MDADM" $MDADM_OPTS -S "$name" "$OUT" "$ERR"; then
+	if eval "$MDADM" $MDADM_OPTS -S "$xname" "$OUT" "$ERR"; then
 		echo "done"
 	else
 		echo "skipping"


