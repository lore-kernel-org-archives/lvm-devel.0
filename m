From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 24 Apr 2014 12:43:11 +0000 (UTC)
Subject: master - tests: fix creation of scsi debug
Message-ID: <20140424124311.D856360E7F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=22037ee3289d3929b534812905b5c6d30f9ee4f8
Commit:        22037ee3289d3929b534812905b5c6d30f9ee4f8
Parent:        8e8a47143fa920b49f279ec4d096022a1afb36ec
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Apr 24 14:40:15 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Apr 24 14:42:27 2014 +0200

tests: fix creation of scsi debug

Use proper '||' test form to avoid unwanted test abort
on failure.
(i.e. running failing test profiles-thin.sh on a real /dev)
---
 test/lib/aux.sh |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 76cfd82..8b765e9 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -302,7 +302,7 @@ prepare_scsi_debug_dev() {
 	local DEV_SIZE=$1
 	local SCSI_DEBUG_PARAMS=${@:2}
 
-	test -f "SCSI_DEBUG_DEV" && return 0
+	test ! -f "SCSI_DEBUG_DEV" || return 0
 	test -z "$LOOP"
 	test -n "$DM_DEV_DIR"
 
@@ -311,7 +311,7 @@ prepare_scsi_debug_dev() {
 
 	# Skip test if scsi_debug module is unavailable or is already in use
 	modprobe --dry-run scsi_debug || skip
-	lsmod | grep -q scsi_debug && skip
+	lsmod | not grep -q scsi_debug || skip
 
 	# Create the scsi_debug device and determine the new scsi device's name
 	# NOTE: it will _never_ make sense to pass num_tgts param;
@@ -327,7 +327,7 @@ prepare_scsi_debug_dev() {
 	echo "$SCSI_DEBUG_DEV" > SCSI_DEBUG_DEV
 	echo "$SCSI_DEBUG_DEV" > LOOP
 	# Setting $LOOP provides means for prepare_devs() override
-	test "$LVM_TEST_DEVDIR" != "/dev" && ln -snf "$DEBUG_DEV" "$SCSI_DEBUG_DEV"
+	test "$LVM_TEST_DEVDIR" = "/dev" || ln -snf "$DEBUG_DEV" "$SCSI_DEBUG_DEV"
 }
 
 cleanup_scsi_debug_dev() {


