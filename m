From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Wed, 25 Jul 2012 14:44:31 +0000 (UTC)
Subject: master - TEST: Conditionalize RAID tests on whether the dm-raid module exists
Message-ID: <20120725144431.165CD22FD@lists.fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=599f18db8aadcc0f4818471ec5b47298a5a8ef54
Commit:        599f18db8aadcc0f4818471ec5b47298a5a8ef54
Parent:        81e89c0647d856d328ac6ccc8db55472b5746181
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Wed Jul 25 09:43:28 2012 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Wed Jul 25 09:43:28 2012 -0500

TEST:  Conditionalize RAID tests on whether the dm-raid module exists

---
 test/shell/lvconvert-repair.sh |   44 ++++++++++++++++++++-------------------
 1 files changed, 23 insertions(+), 21 deletions(-)

diff --git a/test/shell/lvconvert-repair.sh b/test/shell/lvconvert-repair.sh
index 0aeeffa..51bc9de 100644
--- a/test/shell/lvconvert-repair.sh
+++ b/test/shell/lvconvert-repair.sh
@@ -113,26 +113,28 @@ aux enable_dev "$dev3"
 vgextend $vg "$dev3"
 lvremove -ff $vg
 
-# RAID5 single replace
-lvcreate --type raid5 -i 2 -l 2 -n $lv1 $vg "$dev1" "$dev2" "$dev3"
-aux wait_for_sync $vg $lv1
-aux disable_dev "$dev3"
-lvconvert -y --repair $vg/$lv1
-vgreduce --removemissing $vg
-aux enable_dev "$dev3"
-vgextend $vg "$dev3"
-lvremove -ff $vg
-
-# RAID6 double replace
-lvcreate --type raid5 -i 3 -l 2 -n $lv1 $vg \
-    "$dev1" "$dev2" "$dev3" "$dev4" "$dev5"
-aux wait_for_sync $vg $lv1
-aux disable_dev "$dev4" "$dev5"
-lvconvert -y --repair $vg/$lv1
-vgreduce --removemissing $vg
-aux enable_dev "$dev4"
-aux enable_dev "$dev5"
-vgextend $vg "$dev4" "$dev5"
-lvremove -ff $vg
+if aux target_at_least dm-raid 1 1 0; then
+	# RAID5 single replace
+	lvcreate --type raid5 -i 2 -l 2 -n $lv1 $vg "$dev1" "$dev2" "$dev3"
+	aux wait_for_sync $vg $lv1
+	aux disable_dev "$dev3"
+	lvconvert -y --repair $vg/$lv1
+	vgreduce --removemissing $vg
+	aux enable_dev "$dev3"
+	vgextend $vg "$dev3"
+	lvremove -ff $vg
+
+	# RAID6 double replace
+	lvcreate --type raid5 -i 3 -l 2 -n $lv1 $vg \
+	    "$dev1" "$dev2" "$dev3" "$dev4" "$dev5"
+	aux wait_for_sync $vg $lv1
+	aux disable_dev "$dev4" "$dev5"
+	lvconvert -y --repair $vg/$lv1
+	vgreduce --removemissing $vg
+	aux enable_dev "$dev4"
+	aux enable_dev "$dev5"
+	vgextend $vg "$dev4" "$dev5"
+	lvremove -ff $vg
+fi
 
 vgremove -ff $vg


