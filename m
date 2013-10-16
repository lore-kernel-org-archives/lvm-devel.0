From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 16 Oct 2013 13:10:11 +0000 (UTC)
Subject: master - tests: correct LVM_TEST_THIN_CHECK_CMD
Message-ID: <20131016131011.C525760E48@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9b13cb86878677e2b35e29fef054d9de7e24f320
Commit:        9b13cb86878677e2b35e29fef054d9de7e24f320
Parent:        ee878bc52c18dca928682d5f282e8e4ed54bcc2e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Oct 16 15:05:12 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Oct 16 15:10:03 2013 +0200

tests: correct LVM_TEST_THIN_CHECK_CMD

missed to use proper shell variable
---
 test/shell/lvconvert-repair-thin.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/shell/lvconvert-repair-thin.sh b/test/shell/lvconvert-repair-thin.sh
index f7687d4..225dcc8 100644
--- a/test/shell/lvconvert-repair-thin.sh
+++ b/test/shell/lvconvert-repair-thin.sh
@@ -76,7 +76,7 @@ should not $LVM_TEST_THIN_DUMP_CMD $DM_DEV_DIR/$vg/repair | tee dump
 
 should $LVM_TEST_THIN_REPAIR_CMD -i $DM_DEV_DIR/$vg/repair -o $DM_DEV_DIR/$vg/fixed
 
-should $THIN_CHECK $DM_DEV_DIR/$vg/fixed
+should $LVM_TEST_THIN_CHECK_CMD $DM_DEV_DIR/$vg/fixed
 
 # Swap repaired metadata back
 lvconvert -y -f --poolmetadata $vg/fixed --thinpool $vg/pool


