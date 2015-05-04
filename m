From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  4 May 2015 08:21:31 +0000 (UTC)
Subject: master - tests: drop extra scsi init
Message-ID: <20150504082131.1E16760F2F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7a588bce7bd032175d56a1a10af528d61e1c554b
Commit:        7a588bce7bd032175d56a1a10af528d61e1c554b
Parent:        c90ee0414d74ddbaabf270c306acd4fef76718b5
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon May 4 10:17:48 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon May 4 10:17:48 2015 +0200

tests: drop extra scsi init

Use first test also for checking the support is there -
avoid one extra unnecessary scsi_debug reload.
---
 test/shell/topology-support.sh |   14 +++++---------
 1 files changed, 5 insertions(+), 9 deletions(-)

diff --git a/test/shell/topology-support.sh b/test/shell/topology-support.sh
index f465ab7..f1e42a8 100644
--- a/test/shell/topology-support.sh
+++ b/test/shell/topology-support.sh
@@ -43,21 +43,17 @@ NUM_DEVS=1
 PER_DEV_SIZE=34
 DEV_SIZE=$(($NUM_DEVS*$PER_DEV_SIZE))
 
-# Test that kernel supports topology
-aux prepare_scsi_debug_dev $DEV_SIZE || skip
-
-if [ ! -e /sys/block/$(basename $(< SCSI_DEBUG_DEV))/alignment_offset ] ; then
-	aux cleanup_scsi_debug_dev
-	skip
-fi
-aux cleanup_scsi_debug_dev
-
 # ---------------------------------------------
 # Create "desktop-class" 4K drive
 # (logical_block_size=512, physical_block_size=4096, alignment_offset=0):
 LOGICAL_BLOCK_SIZE=512
 aux prepare_scsi_debug_dev $DEV_SIZE \
     sector_size=$LOGICAL_BLOCK_SIZE physblk_exp=3
+# Test that kernel supports topology
+if [ ! -e /sys/block/$(basename $(< SCSI_DEBUG_DEV))/alignment_offset ] ; then
+	aux cleanup_scsi_debug_dev
+	skip
+fi
 check sysfs "$(< SCSI_DEBUG_DEV)" queue/logical_block_size $LOGICAL_BLOCK_SIZE
 aux prepare_pvs $NUM_DEVS $PER_DEV_SIZE
 get_devs


