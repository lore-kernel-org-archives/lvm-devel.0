From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 19 Mar 2013 14:30:06 +0000 (UTC)
Subject: master - metadata: add 'allow_orphan' arg to find_pv_by_name fn
Message-ID: <20130319143006.C4F2576E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=59878d0129f63c3e8c1c4bc9715a400dc8fa808a
Commit:        59878d0129f63c3e8c1c4bc9715a400dc8fa808a
Parent:        5b6bab2e30f9f3f8f447e33c19590533c8c92123
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Mar 19 14:05:19 2013 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Mar 19 14:57:31 2013 +0100

metadata: add 'allow_orphan' arg to find_pv_by_name fn

Before, the find_pv_by_name call always failed if the PV found was orphan.
However, we might use this function even for a PV that is not part of any VG.
This patch adds 'allow_orphan' arg to find_pv_by_name fn that allows that.
---
 lib/metadata/metadata-exported.h |    3 ++-
 lib/metadata/metadata.c          |    5 +++--
 lib/metadata/mirror.c            |    2 +-
 tools/pvmove.c                   |    4 ++--
 4 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index c2728d5..f218f47 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -690,7 +690,8 @@ struct lv_list *find_lv_in_vg(const struct volume_group *vg,
 struct logical_volume *find_lv(const struct volume_group *vg,
 			       const char *lv_name);
 struct physical_volume *find_pv_by_name(struct cmd_context *cmd,
-					const char *pv_name);
+					const char *pv_name,
+					int allow_orphan);
 
 const char *find_vgname_from_pvname(struct cmd_context *cmd,
 				    const char *pvname);
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 7c2846c..fdf47db 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -1802,7 +1802,8 @@ struct physical_volume *find_pv(struct volume_group *vg, struct device *dev)
 
 /* FIXME: liblvm todo - make into function that returns handle */
 struct physical_volume *find_pv_by_name(struct cmd_context *cmd,
-					const char *pv_name)
+					const char *pv_name,
+					int allow_orphan)
 {
 	struct physical_volume *pv;
 
@@ -1822,7 +1823,7 @@ struct physical_volume *find_pv_by_name(struct cmd_context *cmd,
 		}
 	}
 
-	if (is_orphan_vg(pv->vg_name)) {
+	if (!allow_orphan && is_orphan_vg(pv->vg_name)) {
 		log_error("Physical volume %s not in a volume group", pv_name);
 		goto bad;
 	}
diff --git a/lib/metadata/mirror.c b/lib/metadata/mirror.c
index 04a5638..fecab45 100644
--- a/lib/metadata/mirror.c
+++ b/lib/metadata/mirror.c
@@ -1572,7 +1572,7 @@ struct logical_volume *find_pvmove_lv_from_pvname(struct cmd_context *cmd,
 	struct physical_volume *pv;
 	struct logical_volume *lv;
 
-	if (!(pv = find_pv_by_name(cmd, name)))
+	if (!(pv = find_pv_by_name(cmd, name, 0)))
 		return_NULL;
 
 	lv = find_pvmove_lv(vg, pv->dev, lv_type);
diff --git a/tools/pvmove.c b/tools/pvmove.c
index fcc5b31..575f296 100644
--- a/tools/pvmove.c
+++ b/tools/pvmove.c
@@ -494,7 +494,7 @@ static int _set_up_pvmove(struct cmd_context *cmd, const char *pv_name,
 	argv++;
 
 	/* Find PV (in VG) */
-	if (!(pv = find_pv_by_name(cmd, pv_name))) {
+	if (!(pv = find_pv_by_name(cmd, pv_name, 0))) {
 		stack;
 		return EINVALID_CMD_LINE;
 	}
@@ -676,7 +676,7 @@ static struct volume_group *_get_move_vg(struct cmd_context *cmd,
 	struct volume_group *vg;
 
 	/* Reread all metadata in case it got changed */
-	if (!(pv = find_pv_by_name(cmd, name))) {
+	if (!(pv = find_pv_by_name(cmd, name, 0))) {
 		log_error("ABORTING: Can't reread PV %s", name);
 		/* What more could we do here? */
 		return NULL;


