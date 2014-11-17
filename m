From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 17 Nov 2014 07:45:23 +0000 (UTC)
Subject: master - tests: deactivate repaired before swap
Message-ID: <20141117074523.144D2611A2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=542b03ee007d50cd8aa6dbd582b79369a38919b0
Commit:        542b03ee007d50cd8aa6dbd582b79369a38919b0
Parent:        740fcdae7d44ae2398ea427f91fc87195e449d42
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Nov 17 08:44:53 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 17 08:44:53 2014 +0100

tests: deactivate repaired before swap

---
 test/shell/lvconvert-repair-thin.sh |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/test/shell/lvconvert-repair-thin.sh b/test/shell/lvconvert-repair-thin.sh
index 4732efc..8e35ad1 100644
--- a/test/shell/lvconvert-repair-thin.sh
+++ b/test/shell/lvconvert-repair-thin.sh
@@ -70,6 +70,8 @@ not "$LVM_TEST_THIN_DUMP_CMD" "$DM_DEV_DIR/$vg/repair" | tee dump
 
 "$LVM_TEST_THIN_CHECK_CMD" "$DM_DEV_DIR/$vg/fixed"
 
+lvchange -an $vg
+
 # Swap repaired metadata back
 lvconvert -y -f --poolmetadata $vg/fixed --thinpool $vg/pool
 


