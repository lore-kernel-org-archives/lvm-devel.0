From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 20 Aug 2014 08:12:18 +0000 (UTC)
Subject: master - lvconvert: snapshot: allow using raid1 for snapshot and snapshot origin
Message-ID: <20140820081218.5B8AF60F42@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8d00499167f010b82ea6ddebcc6b22ec170002f9
Commit:        8d00499167f010b82ea6ddebcc6b22ec170002f9
Parent:        4f05e55f84fc1d1c4f839b7f523392e369f681b0
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Aug 20 10:05:51 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Aug 20 10:12:09 2014 +0200

lvconvert: snapshot: allow using raid1 for snapshot and snapshot origin

When testing conversion sanity, we checked lv->status & MIRRORED
which encompasses both old mirrors and raid1 mirrors. But we need to
ban only the old mirrors here hence allow raid1 mirrors.
---
 WHATS_NEW         |    1 +
 tools/lvconvert.c |    6 ++++--
 2 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 2e2a064..f5a1dcf 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.110 -
 ==================================
+  Allow conversion of raid1 LV into a snapshot LV or snapshot origin LV.
   Cleanly error when creating RAID with stripe size < PAGE_SIZE.
   Print name of LV which on activation triggers delayed snapshot merge.
   Add lv_layout and lv_type LV reporting fields.
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index cf8d2c0..00bfe80 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -2041,7 +2041,7 @@ static int _lvconvert_snapshot(struct cmd_context *cmd,
 {
 	struct logical_volume *org;
 
-	if (lv->status & MIRRORED) {
+	if ((lv->status & MIRRORED) && !lv_is_raid(lv)) {
 		log_error("Unable to convert mirrored LV \"%s\" into a snapshot.", lv->name);
 		return 0;
 	}
@@ -2066,7 +2066,9 @@ static int _lvconvert_snapshot(struct cmd_context *cmd,
 	if (!cow_has_min_chunks(lv->vg, lv->le_count, lp->chunk_size))
 		return_0;
 
-	if (org->status & (LOCKED|PVMOVE|MIRRORED) || lv_is_cow(org)) {
+	if ((org->status & (LOCKED|PVMOVE)) ||
+	    ((org->status & MIRRORED) && !lv_is_raid(org)) ||
+	    lv_is_cow(org)) {
 		log_error("Unable to convert an LV into a snapshot of a %s LV.",
 			  org->status & LOCKED ? "locked" :
 			  org->status & PVMOVE ? "pvmove" :


