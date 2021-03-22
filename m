From: David Teigland <teigland@sourceware.org>
Date: Mon, 22 Mar 2021 15:39:42 +0000 (GMT)
Subject: dev-next - tests: drop status workaround
Message-ID: <20210322153942.B4BC6385482A@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e27baa791f0e28e9df539c97e25a0a8b1b1c20f7
Commit:        e27baa791f0e28e9df539c97e25a0a8b1b1c20f7
Parent:        ed90a3d9b4247130794ed515b9547e9b4dbbf2dc
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Mar 19 02:06:46 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Mar 20 00:05:01 2021 +0100

tests: drop status workaround

lvconvert should now recognize resync from older kernels.
---
 test/shell/lvconvert-raid.sh | 6 ------
 1 file changed, 6 deletions(-)

diff --git a/test/shell/lvconvert-raid.sh b/test/shell/lvconvert-raid.sh
index 1ab2d4fd3..6aaaf3669 100644
--- a/test/shell/lvconvert-raid.sh
+++ b/test/shell/lvconvert-raid.sh
@@ -232,12 +232,6 @@ lvcreate -aey -l 2 -n $lv1 $vg "$dev1"
 lvconvert -y -m 1 $vg/$lv1 \
 	--config 'global { mirror_segtype_default = "raid1" }' "$dev2"
 lvs --noheadings -o attr $vg/$lv1 | grep '^[[:space:]]*r'
-# FIXME: lvconvert/lvcreate should trace state of target
-for i in {1..10}; do
-	dmsetup status | grep $vg-$lv1: | tee out
-	grep -E "recover|rebuild" out && break
-	sleep .05
-done
 not lvconvert --yes -m 0 $vg/$lv1 "$dev1"
 lvconvert --yes -m 0 $vg/$lv1 "$dev2"
 aux enable_dev "$dev2"


