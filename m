From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Tue, 14 Nov 2017 08:18:19 -0500
Subject: master - test: additional avoid have_raid overhead
Message-ID: <201711141318.vAEDIJsq030808@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b147ce00686beea3a55b74e1a5eeb2d194259a49
Commit:        b147ce00686beea3a55b74e1a5eeb2d194259a49
Parent:        80f5fb7ebb677f875df172451def5544c17c3c8d
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Tue Nov 14 14:17:54 2017 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Tue Nov 14 14:17:54 2017 +0100

test: additional avoid have_raid overhead

---
 test/shell/lvcreate-large-raid.sh |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/test/shell/lvcreate-large-raid.sh b/test/shell/lvcreate-large-raid.sh
index 1082731..3488db4 100644
--- a/test/shell/lvcreate-large-raid.sh
+++ b/test/shell/lvcreate-large-raid.sh
@@ -21,6 +21,8 @@ SKIP_WITH_LVMPOLLD=1
 aux can_use_16T || skip
 
 aux have_raid 1 3 0 || skip
+v1_9_0=0
+aux have_raid 1 9 0 && v1_9_0=1
 
 segtypes="raid5"
 aux have_raid4 && segtypes="raid4 raid5"
@@ -78,7 +80,7 @@ lvremove -ff $vg1
 
 
 # Check --nosync is rejected for raid6
-if aux have_raid 1 9 0 ; then
+if [ $v1_9_0 -eq 1 ] ; then
 	not lvcreate --type raid6 -i 3 -L 750T -n $lv1 $vg1 --nosync
 fi
 
@@ -103,7 +105,7 @@ lvremove -ff $vg1
 lvcreate -aey -L 200T -n $lv1 $vg1
 lvconvert -y --type raid1 -m 1 $vg1/$lv1
 check lv_field $vg1/$lv1 size "200.00t"
-if aux have_raid 1 9 0; then
+if [ $v1_9_0 -eq 1 ] ; then
 	# The 1.9.0 version of dm-raid is capable of performing
 	# linear -> RAID1 upconverts as "recover" not "resync"
 	# The LVM code now checks the dm-raid version when


