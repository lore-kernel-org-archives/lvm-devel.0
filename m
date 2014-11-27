From: Petr Rockai <mornfall@fedoraproject.org>
Date: Thu, 27 Nov 2014 19:32:14 +0000 (UTC)
Subject: master - metadata: Add cache_policy to lvcreate_params and honour it.
Message-ID: <20141127193214.7DC3C60BBB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2c3db52356eebd7ad7e950a01f465359c040b379
Commit:        2c3db52356eebd7ad7e950a01f465359c040b379
Parent:        92908541638b41215d48e51d6fa4aa63b82d8c1a
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Thu Nov 27 20:20:48 2014 +0100
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Thu Nov 27 20:20:48 2014 +0100

metadata: Add cache_policy to lvcreate_params and honour it.

---
 lib/metadata/lv_manip.c          |   11 +++++++++++
 lib/metadata/metadata-exported.h |    1 +
 2 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 879cd51..b00e11b 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -7143,6 +7143,13 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 		}
 	}
 
+	if (lv_is_cache_pool(lv) && !origin_lv) {
+		if (lp->cache_policy && !lv_cache_setpolicy(lv, lp->cache_policy))
+			return NULL; /* revert? */
+		if (!lv_update_and_reload(lv))
+			return NULL; /* FIXME: revert */
+	}
+
 	if (seg_is_cache(lp) || (origin_lv && lv_is_cache_pool(lv))) {
 		/* Finish cache conversion magic */
 		if (origin_lv) {
@@ -7161,6 +7168,10 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 			}
 		}
 		lv = tmp_lv;
+
+		if (lp->cache_policy && !lv_cache_setpolicy(lv, lp->cache_policy))
+			return NULL; /* revert? */
+
 		if (!lv_update_and_reload(lv)) {
 			/* FIXME Do a better revert */
 			log_error("Aborting. Manual intervention required.");
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index d960e1f..d70602d 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -854,6 +854,7 @@ struct lvcreate_params {
 	uint32_t max_recovery_rate; /* RAID */
 
 	uint64_t feature_flags; /* cache */
+	struct dm_config_tree *cache_policy; /* cache */
 
 	const struct segment_type *segtype; /* all */
 	unsigned target_attr; /* all */


