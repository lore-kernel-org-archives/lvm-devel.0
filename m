From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 1 Nov 2019 11:26:20 -0400
Subject: stable-2.02 - tests: needs some raid
Message-ID: <201911011526.xA1FQKjG016366@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2cd30c0d44996cfafcf450201948139f76570ab7
Commit:        2cd30c0d44996cfafcf450201948139f76570ab7
Parent:        010062cf03327340053bd1e96613bda9240e3464
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 1 16:04:09 2019 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Nov 1 16:12:39 2019 +0100

tests: needs some raid

Add explicit check for at least 'some' raid being present.
Slowdown 'delay' more.
---
 test/shell/lvextend-raid.sh |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/test/shell/lvextend-raid.sh b/test/shell/lvextend-raid.sh
index 8988411..471097e 100644
--- a/test/shell/lvextend-raid.sh
+++ b/test/shell/lvextend-raid.sh
@@ -15,6 +15,8 @@ SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
 
+aux have_raid 1 7 0 || skip
+
 v1_15_0=0
 aux have_raid 1 15 0 && v1_15_0=1
 
@@ -33,7 +35,7 @@ aux prepare_pvs 2 $(($lvsz + 3 * $lvext))
 get_devs
 vgcreate -s 4k $vg ${DEVICES[@]}
 
-aux delay_dev "$dev1"  0 50
+aux delay_dev "$dev1"  0 150
 
 # Create raid1 LV consuming 1 MD bitmap page
 lvcreate --yes --type raid1 --regionsize ${regionsize}K -L$(($lvsz-$lvext))M -n $lv1 $vg


