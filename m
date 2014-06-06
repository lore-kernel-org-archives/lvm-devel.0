From: Jonathan Brassow <jbrassow@redhat.com>
Date: Thu, 05 Jun 2014 23:26:00 -0500
Subject: [PATCH] cache: Properly rename origin LV tree when adding "_corig" suffix
Message-ID: <1402028760.4356.4.camel@f16>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Currently, when creating a cache LV that has a RAID origin LV, the
sub-LVs are not properly renamed.  The reason is that
insert_layer_for_lv does not take sub-LVs into account when adding the
layer suffix.  I've worked around this in lv_cache_create, but I wonder
if the solution should be added to insert_layer_for_lv instead...

 brassow

cache: Properly rename origin LV tree when adding "_corig"

When creating a cache LV with a RAID origin, we need to ensure that
the sub-LVs of that origin properly change their names to include
the "_corig" extention of the top-level LV.  We do this by first
performing a 'lv_rename_update' before making the call to
'insert_layer_for_lv'.

Index: lvm2/lib/metadata/cache_manip.c
===================================================================
--- lvm2.orig/lib/metadata/cache_manip.c
+++ lvm2/lib/metadata/cache_manip.c
@@ -91,6 +91,8 @@ struct logical_volume *lv_cache_create(s
 	struct cmd_context *cmd = pool->vg->cmd;
 	struct logical_volume *cache_lv;
 	struct lv_segment *seg;
+	int origin_name_len = strlen(origin->name);
+	char origin_name[origin_name_len + 7]; /* + "_corig" and NULL */
 
 	if (!lv_is_cache_pool(pool)) {
 		log_error(INTERNAL_ERROR
@@ -122,8 +124,23 @@ struct logical_volume *lv_cache_create(s
 	if (!(segtype = get_segtype_from_string(cmd, "cache")))
 		return_NULL;
 
+	/*
+	 * insert_layer_for_lv does not rename the sub-LVs when adding
+	 * the suffix.  So, we rename everything here and then change
+	 * only the top-level LV back before adding the layer.
+	 */
+	sprintf(origin_name, "%s_corig", origin->name);
+	if (!lv_rename_update(cmd, origin, origin_name, 0)) {
+		log_error("Failed to rename origin LV, %s", origin->name);
+		return NULL;
+	}
+	
+	origin_name[origin_name_len] = '\0';	
+	if (!(origin->name = dm_pool_strdup(origin->vg->vgmem, origin_name)))
+		return_0;
+
 	cache_lv = origin;
-	if (!insert_layer_for_lv(cmd, cache_lv, CACHE, "_corig"))
+	if (!(origin = insert_layer_for_lv(cmd, cache_lv, CACHE, "_corig")))
 		return_NULL;
 
 	seg = first_seg(cache_lv);



