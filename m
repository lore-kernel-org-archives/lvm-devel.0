From: David Teigland <teigland@fedoraproject.org>
Date: Tue, 17 Nov 2015 18:12:41 +0000 (UTC)
Subject: master - tests: update lvmcache-exercise
Message-ID: <20151117181241.8C7F960FBE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7b11ef6de057e4a26e88792cf4dc966a79ac4ba0
Commit:        7b11ef6de057e4a26e88792cf4dc966a79ac4ba0
Parent:        6167f5da103fe3d3619cfee1166a66b058e5b3ba
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Nov 17 12:05:22 2015 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Nov 17 12:12:17 2015 -0600

tests: update lvmcache-exercise

To handle multiple VGs with the same name.
Simply using the VG name is ambiguous, and
lvmetad requires the VG uuid be used to
specify which one is meant.
---
 test/shell/lvmcache-exercise.sh |   16 +++++++++++++++-
 1 files changed, 15 insertions(+), 1 deletions(-)

diff --git a/test/shell/lvmcache-exercise.sh b/test/shell/lvmcache-exercise.sh
index 2c2be52..f3bddb7 100644
--- a/test/shell/lvmcache-exercise.sh
+++ b/test/shell/lvmcache-exercise.sh
@@ -18,12 +18,20 @@ aux prepare_pvs 5
 vgcreate $vg1 "$dev1"
 vgcreate $vg2 "$dev3" "$dev4" "$dev5"
 
+UUID1=$(get vg_field $vg1 uuid)
+
 aux disable_dev "$dev1"
 pvscan
 # dev1 is missing
 fail pvs $(cat DEVICES)
 
+# create a new vg1 on dev2,
+# so dev1 and dev2 have different VGs with the same name
 vgcreate $vg1 "$dev2"
+
+UUID2=$(get vg_field $vg1 uuid)
+
+# Once dev1 is visible again, both VGs named "vg1" are visible.
 aux enable_dev "$dev1"
 
 pvs "$dev1"
@@ -36,9 +44,15 @@ lvconvert --yes --repair $vg2/$lv1
 aux enable_dev "$dev3"
 
 # here it should fix any reappeared devices
-lvs $vg1 $vg2
+lvs
 
 lvs -a $vg2 -o+devices 2>&1 | tee out
 not grep reappeared out
 
+# This removes the first "vg1" using its uuid
+vgremove -ff -S vg_uuid=$UUID1
+
+# This removes the second "vg1" using its name,
+# now that there is only one VG with that name.
 vgremove -ff $vg1 $vg2
+


