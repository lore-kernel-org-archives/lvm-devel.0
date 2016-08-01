From: Heinz Mauelshagen <mauelsha@fedoraproject.org>
Date: Mon,  1 Aug 2016 20:42:44 +0000 (UTC)
Subject: master - vg_validate: new RAID segment checks in check_lv_segments() introduced with commit 8f62b7bfe56c rely on complete defintions of the relations between the LVs of a VG. Hence only run these checks when the complete_vg flag is set on calls to check_lv_segments().
Message-ID: <20160801204244.0AAFB60FE3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5765a2845600b827eab782e02250060eb4520c81
Commit:        5765a2845600b827eab782e02250060eb4520c81
Parent:        c490be9134a3c571636ab67d99ffeeac27d9b56f
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Mon Aug 1 22:42:05 2016 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Mon Aug 1 22:42:05 2016 +0200

vg_validate: new RAID segment checks in check_lv_segments()              introduced with commit 8f62b7bfe56c rely on complete              defintions of the relations between the LVs of a VG.              Hence only run these checks when the complete_vg flag              is set on calls to check_lv_segments().

             lvconvert failed in test lvconvert-thin-raid.sh when
             calling check_lv_segments() from _read_segments() without
             providing a complete definition.
---
 lib/metadata/merge.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/merge.c b/lib/metadata/merge.c
index 12c3829..be491e3 100644
--- a/lib/metadata/merge.c
+++ b/lib/metadata/merge.c
@@ -391,7 +391,7 @@ int check_lv_segments(struct logical_volume *lv, int complete_vg)
 	dm_list_iterate_items(seg, &lv->segments) {
 		seg_count++;
 
-		if (seg_is_raid(seg))
+		if (complete_vg && seg_is_raid(seg))
 			 _check_raid_seg(seg, &error_count);
 		
 		if (seg->le != le) {


