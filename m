From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed, 26 Sep 2012 17:55:49 +0000 (UTC)
Subject: master - lib/cache/lvmetad: s/pvscan_lvmetad/lvmetad_pvscan/ in the API
Message-ID: <20120926175549.D8961A33AB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ca0c8673b2064ceb840ee7f4cb5804b33e55f3c7
Commit:        ca0c8673b2064ceb840ee7f4cb5804b33e55f3c7
Parent:        c9f56d639b6c6ddfae7749c64eba64a776ecc7d9
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Sun Sep 9 22:05:59 2012 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Wed Sep 26 17:26:23 2012 +0200

lib/cache/lvmetad: s/pvscan_lvmetad/lvmetad_pvscan/ in the API

---
 lib/cache/lvmetad.c |   18 +++++++++---------
 lib/cache/lvmetad.h |    8 ++++----
 tools/pvscan.c      |    6 +++---
 3 files changed, 16 insertions(+), 16 deletions(-)

diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index 1e185da..237fec6 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -123,7 +123,7 @@ retry:
 		_lvmetad_token = (char *) "update in progress";
 		if (!_token_update()) goto out;
 
-		if (pvscan_lvmetad_all_devs(_lvmetad_cmd, NULL)) {
+		if (lvmetad_pvscan_all_devs(_lvmetad_cmd, NULL)) {
 			_lvmetad_token = future_token;
 			if (!_token_update()) goto out;
 		}
@@ -773,14 +773,14 @@ int lvmetad_pv_gone_by_dev(struct device *dev, activation_handler handler)
  * The following code implements pvscan --cache.
  */
 
-struct _pvscan_lvmetad_baton {
+struct _lvmetad_pvscan_baton {
 	struct volume_group *vg;
 	struct format_instance *fid;
 };
 
-static int _pvscan_lvmetad_single(struct metadata_area *mda, void *baton)
+static int _lvmetad_pvscan_single(struct metadata_area *mda, void *baton)
 {
-	struct _pvscan_lvmetad_baton *b = baton;
+	struct _lvmetad_pvscan_baton *b = baton;
 	struct volume_group *this = mda->ops->vg_read(b->fid, "", mda, 1);
 
 	/* FIXME Also ensure contents match etc. */
@@ -792,12 +792,12 @@ static int _pvscan_lvmetad_single(struct metadata_area *mda, void *baton)
 	return 1;
 }
 
-int pvscan_lvmetad_single(struct cmd_context *cmd, struct device *dev,
+int lvmetad_pvscan_single(struct cmd_context *cmd, struct device *dev,
 			  activation_handler handler)
 {
 	struct label *label;
 	struct lvmcache_info *info;
-	struct _pvscan_lvmetad_baton baton;
+	struct _lvmetad_pvscan_baton baton;
 	/* Create a dummy instance. */
 	struct format_instance_ctx fic = { .type = 0 };
 
@@ -822,7 +822,7 @@ int pvscan_lvmetad_single(struct cmd_context *cmd, struct device *dev,
 	if (!baton.fid)
 		goto_bad;
 
-	lvmcache_foreach_mda(info, _pvscan_lvmetad_single, &baton);
+	lvmcache_foreach_mda(info, _lvmetad_pvscan_single, &baton);
 	if (!baton.vg)
 		lvmcache_fmt(info)->ops->destroy_instance(baton.fid);
 
@@ -847,7 +847,7 @@ bad:
 	return 0;
 }
 
-int pvscan_lvmetad_all_devs(struct cmd_context *cmd, activation_handler handler)
+int lvmetad_pvscan_all_devs(struct cmd_context *cmd, activation_handler handler)
 {
 	struct dev_iter *iter;
 	struct device *dev;
@@ -859,7 +859,7 @@ int pvscan_lvmetad_all_devs(struct cmd_context *cmd, activation_handler handler)
 	}
 
 	while ((dev = dev_iter_get(iter))) {
-		if (!pvscan_lvmetad_single(cmd, dev, handler)) {
+		if (!lvmetad_pvscan_single(cmd, dev, handler)) {
 			r = 0;
 			break;
 		}
diff --git a/lib/cache/lvmetad.h b/lib/cache/lvmetad.h
index cb85929..60110a0 100644
--- a/lib/cache/lvmetad.h
+++ b/lib/cache/lvmetad.h
@@ -125,10 +125,10 @@ struct volume_group *lvmetad_vg_lookup(struct cmd_context *cmd,
 /*
  * Scan a single device and update lvmetad with the result(s).
  */
-int pvscan_lvmetad_single(struct cmd_context *cmd, struct device *dev,
+int lvmetad_pvscan_single(struct cmd_context *cmd, struct device *dev,
 			  activation_handler handler);
 
-int pvscan_lvmetad_all_devs(struct cmd_context *cmd, activation_handler handler);
+int lvmetad_pvscan_all_devs(struct cmd_context *cmd, activation_handler handler);
 
 #  else		/* LVMETAD_SUPPORT */
 
@@ -148,8 +148,8 @@ int pvscan_lvmetad_all_devs(struct cmd_context *cmd, activation_handler handler)
 #    define lvmetad_pv_lookup_by_dev(cmd, dev, found)	(0)
 #    define lvmetad_vg_list_to_lvmcache(cmd)	(1)
 #    define lvmetad_vg_lookup(cmd, vgname, vgid)	(NULL)
-#    define pvscan_lvmetad_single(cmd, dev, handler)	(0)
-#    define pvscan_lvmetad_all_devs(cmd, handler)	(0)
+#    define lvmetad_pvscan_single(cmd, dev, handler)	(0)
+#    define lvmetad_pvscan_all_devs(cmd, handler)	(0)
 
 #  endif	/* LVMETAD_SUPPORT */
 
diff --git a/tools/pvscan.c b/tools/pvscan.c
index 239ce97..3d5ddef 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -142,7 +142,7 @@ static int _pvscan_lvmetad(struct cmd_context *cmd, int argc, char **argv)
 
 	/* Scan everything? */
 	if (!argc && !devno_args) {
-		if (!pvscan_lvmetad_all_devs(cmd, handler))
+		if (!lvmetad_pvscan_all_devs(cmd, handler))
 			ret = ECMD_FAILED;
 		goto out;
 	}
@@ -159,7 +159,7 @@ static int _pvscan_lvmetad(struct cmd_context *cmd, int argc, char **argv)
 			continue;
 		}
 
-		if (!pvscan_lvmetad_single(cmd, dev, handler)) {
+		if (!lvmetad_pvscan_single(cmd, dev, handler)) {
 			ret = ECMD_FAILED;
 			break;
 		}
@@ -198,7 +198,7 @@ static int _pvscan_lvmetad(struct cmd_context *cmd, int argc, char **argv)
 			continue;
 		}
 
-		if (!pvscan_lvmetad_single(cmd, dev, handler)) {
+		if (!lvmetad_pvscan_single(cmd, dev, handler)) {
 			ret = ECMD_FAILED;
 			break;
 		}


