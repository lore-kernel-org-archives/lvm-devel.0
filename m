From: Alasdair Kergon <agk@sourceware.org>
Date: Mon, 22 May 2017 18:34:04 -0400
Subject: master - format_text: More internal errors if given invalid internal metadata
Message-ID: <201705222234.v4MMY4XX004628@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d1ddfc408535b9c4df432273657f952c59f16232
Commit:        d1ddfc408535b9c4df432273657f952c59f16232
Parent:        ca241964914fc151a9a2f370b1567b4a1ef5cb48
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon May 22 23:30:34 2017 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Mon May 22 23:30:34 2017 +0100

format_text: More internal errors if given invalid internal metadata

Three more messages to ensure each failure in out_areas() results in a
low-level message instead of sometimes just <backtrace>.
---
 lib/format_text/export.c |   19 +++++++++++++++++--
 1 files changed, 17 insertions(+), 2 deletions(-)

diff --git a/lib/format_text/export.c b/lib/format_text/export.c
index 473275d..f530ec9 100644
--- a/lib/format_text/export.c
+++ b/lib/format_text/export.c
@@ -501,7 +501,13 @@ static int _print_vg(struct formatter *f, struct volume_group *vg)
  */
 static const char *_get_pv_name_from_uuid(struct formatter *f, char *uuid)
 {
-	return dm_hash_lookup(f->pv_names, uuid);
+	const char *pv_name = dm_hash_lookup(f->pv_names, uuid);
+
+	if (!pv_name)
+		log_error(INTERNAL_ERROR "PV name for uuid %s missing from text metadata export hash table.",
+			  uuid);
+
+	return pv_name;
 }
 
 static const char *_get_pv_name(struct formatter *f, struct physical_volume *pv)
@@ -607,6 +613,7 @@ int out_areas(struct formatter *f, const struct lv_segment *seg,
 {
 	const char *name;
 	unsigned int s;
+	struct physical_volume *pv;
 
 	outnl(f);
 
@@ -616,7 +623,13 @@ int out_areas(struct formatter *f, const struct lv_segment *seg,
 	for (s = 0; s < seg->area_count; s++) {
 		switch (seg_type(seg, s)) {
 		case AREA_PV:
-			if (!(name = _get_pv_name(f, seg_pv(seg, s))))
+			if (!(pv = seg_pv(seg, s))) {
+				log_error(INTERNAL_ERROR "Missing PV for area %" PRIu32 " of %s segment of LV %s.",
+					  s, type, display_lvname(seg->lv));
+				return 0;
+			}
+				
+			if (!(name = _get_pv_name(f, pv)))
 				return_0;
 
 			outf(f, "\"%s\", %u%s", name,
@@ -650,6 +663,8 @@ int out_areas(struct formatter *f, const struct lv_segment *seg,
 
 			break;
 		case AREA_UNASSIGNED:
+			log_error(INTERNAL_ERROR "Invalid type for area %" PRIu32 " of %s segment of LV %s.",
+				  s, type, display_lvname(seg->lv));
 			return 0;
 		}
 	}


