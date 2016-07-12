From: Heinz Mauelshagen <mauelsha@fedoraproject.org>
Date: Tue, 12 Jul 2016 15:55:28 +0000 (UTC)
Subject: master - raid_manip: 'vgreduce --removemissing --force ...' segfaults on raid0 LV
Message-ID: <20160712155528.36B5761142@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9c2757349370cb0b098fb3a3d137107543818fd7
Commit:        9c2757349370cb0b098fb3a3d137107543818fd7
Parent:        c77c59f3d9a97b43cd2bd9be1c5892aea384f857
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Tue Jul 12 17:55:01 2016 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Tue Jul 12 17:55:01 2016 +0200

raid_manip: 'vgreduce --removemissing --force ...' segfaults on raid0 LV

An unconditional access to the non-existing MetaLV of a raid0 LV in
lv_raid_remove_missing() was causing the segfault.

Only call log_debug() on replacements of existing MetaLVs.

- resolves rhbz1354646
---
 lib/metadata/raid_manip.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 9ac061f..2ef47b2 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -3090,8 +3090,11 @@ int lv_raid_remove_missing(struct logical_volume *lv)
 		    (!seg->meta_areas || !seg_metalv(seg, s) || !lv_is_partial(seg_metalv(seg, s))))
 			continue;
 
-		log_debug("Replacing %s and %s segments with error target",
-			  seg_lv(seg, s)->name, seg_metalv(seg, s)->name);
+		log_debug("Replacing %s segments with error target",
+			  display_lvname(seg_lv(seg, s)));
+		if (seg->meta_areas && seg_metalv(seg, s))
+			log_debug("Replacing %s segments with error target",
+				  display_lvname(seg_metalv(seg, s)));
 		if (!replace_lv_with_error_segment(seg_lv(seg, s))) {
 			log_error("Failed to replace %s's extents with error target.",
 				  display_lvname(seg_lv(seg, s)));


