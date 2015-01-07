From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed,  7 Jan 2015 12:30:37 +0000 (UTC)
Subject: master - raid: fix mirror image naming when converting from mirror to raid1
Message-ID: <20150107123037.7F7CC60A67@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=aaecbb181838102e1ce58ea19df14eb69db79dd9
Commit:        aaecbb181838102e1ce58ea19df14eb69db79dd9
Parent:        ff1eca3b6f1b40158fa5a5877b1ad6de72e4ed1e
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Wed Jan 7 13:25:08 2015 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Jan 7 13:25:08 2015 +0100

raid: fix mirror image naming when converting from mirror to raid1

$ lvcreate -l1 -m1 --type mirror vg
  Logical volume "lvol0" created.
$ lvconvert --type raid1 vg/lvol0

Before:
$ lvs -a vg
  LV                        VG     Active Attr       LSize   Cpy%Sync Layout     Role
  lvol0                     vg     active rwi-a-r---   4.00m 100.00   raid,raid1 public
  [lvol0_mimage_0_rimage_0] vg     active iwi-aor---   4.00m          linear     private,raid,image
  [lvol0_mimage_1_rimage_1] vg     active iwi-aor---   4.00m          linear     private,raid,image
  [lvol0_rmeta_0]           vg     active ewi-aor---   4.00m          linear     private,raid,metadata
  [lvol0_rmeta_1]           vg     active ewi-aor---   4.00m          linear     private,raid,metadata

Incorrect name: lvol0_mimage_0_rimage_0

With this patch applied:
$ lvs -a vg
  LV               VG   Active Attr       LSize Cpy%Sync Layout     Role
  lvol0            vg   active rwi-a-r--- 4.00m 100.00   raid,raid1 public
  [lvol0_rimage_0] vg   active iwi-aor--- 4.00m          linear     private,raid,image
  [lvol0_rimage_1] vg   active iwi-aor--- 4.00m          linear     private,raid,image
  [lvol0_rmeta_0]  vg   active ewi-aor--- 4.00m          linear     private,raid,metadata
  [lvol0_rmeta_1]  vg   active ewi-aor--- 4.00m          linear     private,raid,metadata

Proper name: lvol0_rimage_0
---
 lib/metadata/raid_manip.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 59d3adb..6f951f4 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -1409,7 +1409,7 @@ static int _convert_mirror_to_raid1(struct logical_volume *lv,
 	}
 
 	for (s = 0; s < seg->area_count; ++s) {
-		if (!(new_name = _generate_raid_name(seg_lv(seg, s), "rimage", s)))
+		if (!(new_name = _generate_raid_name(lv, "rimage", s)))
 			return_0;
 		log_debug_metadata("Renaming %s to %s", seg_lv(seg, s)->name, new_name);
 		seg_lv(seg, s)->name = new_name;


