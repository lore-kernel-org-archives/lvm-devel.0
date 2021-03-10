From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 10 Mar 2021 00:36:37 +0000 (GMT)
Subject: main - activation: use existing LV as best effort
Message-ID: <20210310003637.ACA783857C5F@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=131ca0eb9582dd183ed40400caf4fc832f43cb16
Commit:        131ca0eb9582dd183ed40400caf4fc832f43cb16
Parent:        15c588f931d3b30344352a49d7f8df6dc5ea873c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Mar 9 18:23:42 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Mar 10 01:29:06 2021 +0100

activation: use existing LV as best effort

Returning NULL for lv_committed is basically instant crash,
so instead try with passed LV instead.
It shouldn't matter as this is internall error path anyway,
but coverity should be happier.
---
 lib/metadata/metadata.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index f82ada8be..71e59207d 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -4335,7 +4335,7 @@ char *tags_format_and_copy(struct dm_pool *mem, const struct dm_list *tagsl)
 const struct logical_volume *lv_committed(const struct logical_volume *lv)
 {
 	struct volume_group *vg;
-	struct logical_volume *found_lv;
+	const struct logical_volume *found_lv;
 
 	if (!lv)
 		return NULL;
@@ -4348,7 +4348,7 @@ const struct logical_volume *lv_committed(const struct logical_volume *lv)
 	if (!(found_lv = find_lv_in_vg_by_lvid(vg, &lv->lvid))) {
 		log_error(INTERNAL_ERROR "LV %s (UUID %s) not found in committed metadata.",
 			  display_lvname(lv), lv->lvid.s);
-		return NULL;
+		found_lv = lv; /* Use uncommitted LV as best effort */
 	}
 
 	return found_lv;


