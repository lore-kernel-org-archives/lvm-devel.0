From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 1 Nov 2019 11:32:00 -0400
Subject: master - tests: slowdown delay of raid
Message-ID: <201911011532.xA1FW09x016953@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5f064e22211959149798ebbd92497c3fc953c489
Commit:        5f064e22211959149798ebbd92497c3fc953c489
Parent:        c935f8a327716292bb5454ae470143bfe7b1b3a9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 1 16:04:09 2019 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Nov 1 16:31:12 2019 +0100

tests: slowdown delay of raid

Slowdown 'delay' more.
---
 test/shell/lvextend-raid.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/shell/lvextend-raid.sh b/test/shell/lvextend-raid.sh
index 1c0e9c6..e38634b 100644
--- a/test/shell/lvextend-raid.sh
+++ b/test/shell/lvextend-raid.sh
@@ -34,7 +34,7 @@ aux prepare_pvs 2 $(($lvsz + 3 * $lvext))
 get_devs
 vgcreate -s 4k $vg ${DEVICES[@]}
 
-aux delay_dev "$dev1"  0 50
+aux delay_dev "$dev1"  0 150
 
 # Create raid1 LV consuming 1 MD bitmap page
 lvcreate --yes --type raid1 --regionsize ${regionsize}K -L$(($lvsz-$lvext))M -n $lv1 $vg


