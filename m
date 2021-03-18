From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 18 Mar 2021 18:15:11 +0000 (GMT)
Subject: main - tests: check for raid sync in progress
Message-ID: <20210318181511.C4B3F386EC52@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=26fb6b5e8d61e3d3097fccf4fca5bd9582fbbb4f
Commit:        26fb6b5e8d61e3d3097fccf4fca5bd9582fbbb4f
Parent:        accf324ccba681ad06cd8bcb27ead17ec191a471
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Mar 17 11:22:16 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Mar 18 19:12:00 2021 +0100

tests: check for raid sync in progress

TODO: this needs to be built-in in lvm command itself.
---
 test/shell/lvconvert-raid.sh | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/test/shell/lvconvert-raid.sh b/test/shell/lvconvert-raid.sh
index 87eb7b53c..1ab2d4fd3 100644
--- a/test/shell/lvconvert-raid.sh
+++ b/test/shell/lvconvert-raid.sh
@@ -232,10 +232,11 @@ lvcreate -aey -l 2 -n $lv1 $vg "$dev1"
 lvconvert -y -m 1 $vg/$lv1 \
 	--config 'global { mirror_segtype_default = "raid1" }' "$dev2"
 lvs --noheadings -o attr $vg/$lv1 | grep '^[[:space:]]*r'
+# FIXME: lvconvert/lvcreate should trace state of target
 for i in {1..10}; do
-	check raid_leg_status $vg $lv1 "Aa" && break
-	check raid_leg_status $vg $lv1 "aa" || die "Cannot wait for Aa on $vg/$lv1"
-	sleep .1
+	dmsetup status | grep $vg-$lv1: | tee out
+	grep -E "recover|rebuild" out && break
+	sleep .05
 done
 not lvconvert --yes -m 0 $vg/$lv1 "$dev1"
 lvconvert --yes -m 0 $vg/$lv1 "$dev2"


