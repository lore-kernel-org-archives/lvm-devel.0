From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri,  4 Nov 2016 00:23:41 +0000 (UTC)
Subject: master - tests: Disable 3-leg raid1 pre-sync repair attempt
Message-ID: <20161104002341.1C2D460E08@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6dce0e948935678e647dddeeea816cb4937f078a
Commit:        6dce0e948935678e647dddeeea816cb4937f078a
Parent:        461d340bd75556ef1f9fcda7ec29ebd5f044d861
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri Nov 4 00:23:08 2016 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Nov 4 00:23:08 2016 +0000

tests: Disable 3-leg raid1 pre-sync repair attempt

Test fails as it doesn't ensure device isn't already in sync.
---
 test/shell/lvconvert-repair-raid.sh |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/test/shell/lvconvert-repair-raid.sh b/test/shell/lvconvert-repair-raid.sh
index b51d8fe..d3ac1da 100644
--- a/test/shell/lvconvert-repair-raid.sh
+++ b/test/shell/lvconvert-repair-raid.sh
@@ -53,7 +53,8 @@ delay 50
 # RAID1 triple-leg single replace during initial sync
 lvcreate --type raid1 -m 2 -L $RAID_SIZE -n $lv1 $vg "$dev1" "$dev2" "$dev3"
 aux disable_dev "$dev2" "$dev3"
-not lvconvert -y --repair $vg/$lv1
+# FIXME 2016/11/04 AGK: Disabled next line as it fails to guarantee it is not already in sync.
+#not lvconvert -y --repair $vg/$lv1
 aux wait_for_sync $vg $lv1
 lvconvert -y --repair $vg/$lv1
 vgreduce --removemissing $vg


