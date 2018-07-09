From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 9 Jul 2018 09:34:59 -0400
Subject: master - lv_manip: layout and role support for vdo segment
Message-ID: <201807091334.w69DYx4D030725@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=493ffe7a0f4646d151bd4a48e2ec9756892c4944
Commit:        493ffe7a0f4646d151bd4a48e2ec9756892c4944
Parent:        00990ed53e4d00fe7b030d366193a51bd646c85b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jun 29 11:18:44 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 9 15:28:35 2018 +0200

lv_manip: layout and role support for vdo segment

---
 lib/metadata/lv_manip.c |   45 +++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 45 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 2dfe994..d3c4e76 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -113,6 +113,7 @@ enum {
 	LV_TYPE_POOL,
 	LV_TYPE_DATA,
 	LV_TYPE_SPARE,
+	LV_TYPE_VDO,
 	LV_TYPE_VIRTUAL,
 	LV_TYPE_RAID0,
 	LV_TYPE_RAID0_META,
@@ -164,6 +165,7 @@ static const char *_lv_type_names[] = {
 	[LV_TYPE_POOL] =				"pool",
 	[LV_TYPE_DATA] =				"data",
 	[LV_TYPE_SPARE] =				"spare",
+	[LV_TYPE_VDO] =					"vdo",
 	[LV_TYPE_VIRTUAL] =				"virtual",
 	[LV_TYPE_RAID0] =				SEG_TYPE_NAME_RAID0,
 	[LV_TYPE_RAID0_META] =				SEG_TYPE_NAME_RAID0_META,
@@ -466,6 +468,44 @@ bad:
 	return 0;
 }
 
+static int _lv_layout_and_role_vdo(struct dm_pool *mem,
+				    const struct logical_volume *lv,
+				    struct dm_list *layout,
+				    struct dm_list *role,
+				    int *public_lv)
+{
+	int top_level = 0;
+
+	/* non-top-level LVs */
+	if (lv_is_vdo_pool(lv)) {
+		if (!str_list_add_no_dup_check(mem, layout, _lv_type_names[LV_TYPE_VDO]) ||
+		    !str_list_add_no_dup_check(mem, layout, _lv_type_names[LV_TYPE_POOL]))
+			goto_bad;
+	} else if (lv_is_vdo_pool_data(lv)) {
+		if (!str_list_add_no_dup_check(mem, role, _lv_type_names[LV_TYPE_VDO]) ||
+		    !str_list_add_no_dup_check(mem, role, _lv_type_names[LV_TYPE_POOL]) ||
+		    !str_list_add_no_dup_check(mem, role, _lv_type_names[LV_TYPE_DATA]))
+			goto_bad;
+	} else
+		top_level = 1;
+
+	if (!top_level) {
+		*public_lv = 0;
+		return 1;
+	}
+
+	/* top-level LVs */
+	if (lv_is_vdo(lv)) {
+		if (!str_list_add_no_dup_check(mem, layout, _lv_type_names[LV_TYPE_VDO]) ||
+		    !str_list_add_no_dup_check(mem, layout, _lv_type_names[LV_TYPE_SPARSE]))
+			goto_bad;
+	}
+
+	return 1;
+bad:
+	return 0;
+}
+
 int lv_layout_and_role(struct dm_pool *mem, const struct logical_volume *lv,
 		       struct dm_list **layout, struct dm_list **role) {
 	int linear, striped;
@@ -510,6 +550,11 @@ int lv_layout_and_role(struct dm_pool *mem, const struct logical_volume *lv,
 	    !_lv_layout_and_role_cache(mem, lv, *layout, *role, &public_lv))
 		goto_bad;
 
+	/* VDO and related */
+	if (lv_is_vdo_type(lv) &&
+	    !_lv_layout_and_role_vdo(mem, lv, *layout, *role, &public_lv))
+		goto_bad;
+
 	/* Pool-specific */
 	if (lv_is_pool_metadata_spare(lv)) {
 		if (!str_list_add_no_dup_check(mem, *role, _lv_type_names[LV_TYPE_POOL]) ||


