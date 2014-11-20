From: Petr Rockai <mornfall@fedoraproject.org>
Date: Thu, 20 Nov 2014 15:53:19 +0000 (UTC)
Subject: master - cache: Implement 'default' as a policy settings value to clear the record.
Message-ID: <20141120155319.BB8BE60DB5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c75ae0846e4c1a74fbd44d85837e2b6dc50e9783
Commit:        c75ae0846e4c1a74fbd44d85837e2b6dc50e9783
Parent:        4b9b8e12825d5611d3b8d73aa8e381a4caffff5a
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Thu Nov 20 12:05:40 2014 +0100
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Thu Nov 20 16:51:07 2014 +0100

cache: Implement 'default' as a policy settings value to clear the record.

---
 lib/metadata/cache_manip.c   |   40 +++++++++++++++++++++++++++++++++++++---
 test/shell/lvchange-cache.sh |   14 ++++++++++++++
 2 files changed, 51 insertions(+), 3 deletions(-)

diff --git a/lib/metadata/cache_manip.c b/lib/metadata/cache_manip.c
index f7b1b99..6a13ec1 100644
--- a/lib/metadata/cache_manip.c
+++ b/lib/metadata/cache_manip.c
@@ -399,18 +399,52 @@ int lv_cache_setpolicy(struct logical_volume *lv, struct dm_config_tree *policy)
 {
 	struct lv_segment *seg = first_seg(lv);
 	const char *name;
+	struct dm_config_node *cn;
+	struct dm_config_tree *old = NULL, *new = NULL, *tmp = NULL;
+	int r = 0;
 
 	if (lv_is_cache(lv))
 		seg = first_seg(seg->pool_lv);
 
+	if (seg->policy_settings) {
+		if (!(old = dm_config_create()))
+			goto_out;
+		if (!(new = dm_config_create()))
+			goto_out;
+		new->root = policy->root;
+		old->root = seg->policy_settings;
+		new->cascade = old;
+		if (!(tmp = policy = dm_config_flatten(new)))
+			goto_out;
+	}
+
 	if (!(seg->policy_settings = dm_config_clone_node_with_mem(lv->vg->vgmem, policy->root, 0)))
-		return_0;
+		goto_out;
 
 	if ((name = dm_config_find_str(policy->root, "policy", NULL)) &&
 	    !(seg->policy_name = dm_pool_strdup(lv->vg->vgmem, name)))
-		return_0;
+		goto_out;
+
+restart: /* remove any 'default" nodes */
+	cn = seg->policy_settings->child;
+	while (cn) {
+		if (cn->v->type == DM_CFG_STRING && !strcmp(cn->v->v.str, "default")) {
+			dm_config_remove_node(seg->policy_settings, cn);
+			goto restart;
+		}
+		cn = cn->sib;
+	}
 
-	return 1;
+	r = 1;
+
+out:
+	if (old)
+		dm_config_destroy(old);
+	if (new)
+		dm_config_destroy(new);
+	if (tmp)
+		dm_config_destroy(tmp);
+	return r;
 }
 
 /*
diff --git a/test/shell/lvchange-cache.sh b/test/shell/lvchange-cache.sh
index 997b770..4845bba 100644
--- a/test/shell/lvchange-cache.sh
+++ b/test/shell/lvchange-cache.sh
@@ -33,4 +33,18 @@ lvchange --cachesettings 'migration_threshold = 233 sequential_threshold = 13' $
 dmsetup status | grep $vg-corigin | grep 'migration_threshold 233'
 dmsetup status | grep $vg-corigin | grep 'sequential_threshold 13'
 
+lvchange --cachesettings 'migration_threshold = 17' $vg/corigin
+dmsetup status | grep $vg-corigin | grep 'migration_threshold 17'
+dmsetup status | grep $vg-corigin | grep 'sequential_threshold 13'
+
+lvchange --cachesettings 'migration_threshold = default' $vg/corigin
+dmsetup status | grep $vg-corigin | grep 'migration_threshold 2048'
+dmsetup status | grep $vg-corigin | grep 'sequential_threshold 13'
+
+lvchange --cachesettings 'migration_threshold = 233 sequential_threshold = 13 random_threshold = 1' $vg/corigin
+lvchange --cachesettings 'random_threshold = default migration_threshold = default' $vg/corigin
+dmsetup status | grep $vg-corigin | grep 'migration_threshold 2048'
+dmsetup status | grep $vg-corigin | grep 'sequential_threshold 13'
+dmsetup status | grep $vg-corigin | grep 'random_threshold 4'
+
 vgremove -f $vg


