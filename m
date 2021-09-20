From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 20 Sep 2021 13:30:08 +0000 (GMT)
Subject: main - cov: check for possible NULL segtype
Message-ID: <20210920133008.B82053858C3B@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6c87e98ee367e1ff410470c09e6131697f0a7660
Commit:        6c87e98ee367e1ff410470c09e6131697f0a7660
Parent:        bfc6fe2bac8ac262075271c2f6649b28cd04f883
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Sep 20 01:51:29 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 20 14:26:09 2021 +0200

cov: check for possible NULL segtype

Although likely impossible to ever miss ERROR segtype,
make analyzer hapier.
---
 lib/metadata/lv_manip.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index e2efbf03a..1a4e613a7 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -1699,6 +1699,10 @@ int lv_empty(struct logical_volume *lv)
 int replace_lv_with_error_segment(struct logical_volume *lv)
 {
 	uint32_t len = lv->le_count;
+	struct segment_type *segtype;
+
+	if (!(segtype = get_segtype_from_string(lv->vg->cmd, SEG_TYPE_NAME_ERROR)))
+		return_0;
 
 	if (len && !lv_empty(lv))
 		return_0;
@@ -1717,7 +1721,7 @@ int replace_lv_with_error_segment(struct logical_volume *lv)
 
 	/* FIXME Check for any attached LVs that will become orphans e.g. mirror logs */
 
-	if (!lv_add_virtual_segment(lv, 0, len, get_segtype_from_string(lv->vg->cmd, SEG_TYPE_NAME_ERROR)))
+	if (!lv_add_virtual_segment(lv, 0, len, segtype))
 		return_0;
 
 	return 1;


