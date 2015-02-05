From: Petr Rockai <mornfall@fedoraproject.org>
Date: Thu,  5 Feb 2015 13:43:08 +0000 (UTC)
Subject: master - test: Fix prepare_scsi_debug_dev.
Message-ID: <20150205134308.B1B0A60E22@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c2b7642d4d8df4a9d6798f339415466c9b69a805
Commit:        c2b7642d4d8df4a9d6798f339415466c9b69a805
Parent:        580370bea3a149afaffd9cfeeefb93b20c69c71f
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Tue Sep 30 16:50:31 2014 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Thu Feb 5 13:47:21 2015 +0100

test: Fix prepare_scsi_debug_dev.

---
 test/lib/aux.sh |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 32268a6..fd537bd 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -334,9 +334,9 @@ prepare_scsi_debug_dev() {
 	# Create symlink to scsi_debug device in $DM_DEV_DIR
 	SCSI_DEBUG_DEV="$DM_DEV_DIR/$(basename $DEBUG_DEV)"
 	echo "$SCSI_DEBUG_DEV" > SCSI_DEBUG_DEV
-	echo "$SCSI_DEBUG_DEV" > LOOP
+	echo "$SCSI_DEBUG_DEV" > BACKING_DEV
 	# Setting $LOOP provides means for prepare_devs() override
-	test "$LVM_TEST_DEVDIR" = "/dev" || ln -snf "$DEBUG_DEV" "$SCSI_DEBUG_DEV"
+	test "$DEBUG_DEV" = "$SCSI_DEBUG_DEV" || ln -snf "$DEBUG_DEV" "$SCSI_DEBUG_DEV"
 }
 
 cleanup_scsi_debug_dev() {
@@ -345,7 +345,9 @@ cleanup_scsi_debug_dev() {
 }
 
 prepare_backing_dev() {
-	if test -b "$LVM_TEST_BACKING_DEVICE"; then
+	if test -f BACKING_DEV; then 
+		BACKING_DEV=$(< BACKING_DEV)
+	elif test -b "$LVM_TEST_BACKING_DEVICE"; then
 		BACKING_DEV="$LVM_TEST_BACKING_DEVICE"
 		echo "$BACKING_DEV" > BACKING_DEV
 	else
@@ -374,6 +376,7 @@ prepare_devs() {
 		   test -n "$LVM_TEST_BACKING_DEVICE";
 		then # maybe the backing device is too small for this test
 		    LVM_TEST_BACKING_DEVICE=
+		    rm -f BACKING_DEV
 		    prepare_devs "$@"
 		    return $?
 		fi


