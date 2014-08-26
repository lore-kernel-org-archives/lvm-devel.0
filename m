From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 26 Aug 2014 15:08:11 +0000 (UTC)
Subject: master - revert: commit 8d00499167f010b82ea6ddebcc6b22ec170002f9
Message-ID: <20140826150811.9AE3D602E2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=50babdf123349f9efdcf91f63d11bfece98ee6ab
Commit:        50babdf123349f9efdcf91f63d11bfece98ee6ab
Parent:        70e998754e852fd3052daa5d79213af2f632ac44
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Aug 26 17:07:37 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Aug 26 17:07:37 2014 +0200

revert: commit 8d00499167f010b82ea6ddebcc6b22ec170002f9

Let's test this more...
---
 WHATS_NEW         |    1 -
 tools/lvconvert.c |    6 ++----
 2 files changed, 2 insertions(+), 5 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 9ddb232..2e27043 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -4,7 +4,6 @@ Version 2.02.110 -
   Support lv/vgremove -ff to remove thin vols from broken/inactive thin pools.
   Fix typo breaking configure --with-lvm1=shared.
   Modify lvresize code to handle raid/mirrors and physical extents.
-  Allow conversion of raid1 LV into a snapshot LV or snapshot origin LV.
   Cleanly error when creating RAID with stripe size < PAGE_SIZE.
   Print name of LV which on activation triggers delayed snapshot merge.
   Add lv_layout and lv_role LV reporting fields.
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 00bfe80..cf8d2c0 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -2041,7 +2041,7 @@ static int _lvconvert_snapshot(struct cmd_context *cmd,
 {
 	struct logical_volume *org;
 
-	if ((lv->status & MIRRORED) && !lv_is_raid(lv)) {
+	if (lv->status & MIRRORED) {
 		log_error("Unable to convert mirrored LV \"%s\" into a snapshot.", lv->name);
 		return 0;
 	}
@@ -2066,9 +2066,7 @@ static int _lvconvert_snapshot(struct cmd_context *cmd,
 	if (!cow_has_min_chunks(lv->vg, lv->le_count, lp->chunk_size))
 		return_0;
 
-	if ((org->status & (LOCKED|PVMOVE)) ||
-	    ((org->status & MIRRORED) && !lv_is_raid(org)) ||
-	    lv_is_cow(org)) {
+	if (org->status & (LOCKED|PVMOVE|MIRRORED) || lv_is_cow(org)) {
 		log_error("Unable to convert an LV into a snapshot of a %s LV.",
 			  org->status & LOCKED ? "locked" :
 			  org->status & PVMOVE ? "pvmove" :


