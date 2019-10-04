From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 4 Oct 2019 11:33:35 -0400
Subject: master - vdo: remember configure VDO write policy in metadata
Message-ID: <201910041533.x94FXZHv031072@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=862aa06e5eb28c0a9a163f109bdaeba9729243bc
Commit:        862aa06e5eb28c0a9a163f109bdaeba9729243bc
Parent:        7ca9be034f451bc9a87b36dce4f9979db5a67efd
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 4 15:09:11 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 4 17:31:55 2019 +0200

vdo: remember configure VDO write policy in metadata

Store write_policy in vdopool metadata.
In case it's not present 'auto' is selected.
---
 lib/vdo/vdo.c |   12 +++++++++++-
 1 files changed, 11 insertions(+), 1 deletions(-)

diff --git a/lib/vdo/vdo.c b/lib/vdo/vdo.c
index b4cb578..01d95f7 100644
--- a/lib/vdo/vdo.c
+++ b/lib/vdo/vdo.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2018 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2018-2019 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -189,6 +189,7 @@ static void _vdo_pool_display(const struct lv_segment *seg)
 	log_print("  # Logical threads\t%u", (unsigned) vtp->logical_threads);
 	log_print("  # Physical threads\t%u", (unsigned) vtp->physical_threads);
 	log_print("  Max discard\t%u", (unsigned) vtp->max_discard);
+	log_print("  Write policy\t%s", get_vdo_write_policy_name(vtp->write_policy));
 }
 
 /* reused as _vdo_text_import_area_count */
@@ -280,6 +281,12 @@ static int _vdo_pool_text_import(struct lv_segment *seg,
 	if (!dm_config_get_uint32(n, "physical_threads", &vtp->physical_threads))
 		return _bad_field("physical_threads");
 
+	if (dm_config_has_node(n, "write_policy")) {
+		if (!(str = dm_config_find_str(n, "write_policy", NULL)) ||
+		    !set_vdo_write_policy(&vtp->write_policy, str))
+			return _bad_field("write_policy");
+	} else
+		vtp->write_policy = DM_VDO_WRITE_POLICY_AUTO;
 
 	if (!set_lv_segment_area_lv(seg, 0, data_lv, 0, LV_VDO_POOL_DATA))
 		return_0;
@@ -334,6 +341,9 @@ static int _vdo_pool_text_export(const struct lv_segment *seg, struct formatter
 	outf(f, "logical_threads = %u", (unsigned) vtp->logical_threads);
 	outf(f, "physical_threads = %u", (unsigned) vtp->physical_threads);
 
+	if (vtp->write_policy != DM_VDO_WRITE_POLICY_AUTO)
+		outf(f, "write_policy = %s", get_vdo_write_policy_name(vtp->write_policy));
+
 	return 1;
 }
 


