From: Petr Rockai <mornfall@fedoraproject.org>
Date: Thu, 11 Oct 2012 09:52:15 +0000 (UTC)
Subject: master - test: Skip the topology test if setting up scsi_debug fails.
Message-ID: <20121011095215.10F0EA0D93@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=57460fe5a853c0824d35c02b2a77ef0afc8a5f2d
Commit:        57460fe5a853c0824d35c02b2a77ef0afc8a5f2d
Parent:        deea86c7f49ea825608826e29b56a005e2c9e747
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Thu Oct 11 11:51:04 2012 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Thu Oct 11 11:51:04 2012 +0200

test: Skip the topology test if setting up scsi_debug fails.

---
 test/shell/topology-support.sh |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/test/shell/topology-support.sh b/test/shell/topology-support.sh
index cf2461c..e952dc0 100644
--- a/test/shell/topology-support.sh
+++ b/test/shell/topology-support.sh
@@ -53,7 +53,8 @@ PER_DEV_SIZE=34
 DEV_SIZE=$(($NUM_DEVS*$PER_DEV_SIZE))
 
 # Test that kernel supports topology
-aux prepare_scsi_debug_dev $DEV_SIZE
+aux prepare_scsi_debug_dev $DEV_SIZE || skip
+
 if [ ! -e /sys/block/$(basename $(cat SCSI_DEBUG_DEV))/alignment_offset ] ; then
 	aux cleanup_scsi_debug_dev
 	skip


