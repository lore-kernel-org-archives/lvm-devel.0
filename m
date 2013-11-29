From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri, 29 Nov 2013 21:47:16 +0000 (UTC)
Subject: master - pvcreate: Avoid spurious 'not found' messages.
Message-ID: <20131129214716.2238560F7E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2e82a070f3c9224da5c9f383d47e75a1715586cf
Commit:        2e82a070f3c9224da5c9f383d47e75a1715586cf
Parent:        84394c0219e4fcee719663c710121f1bb731a538
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri Nov 29 21:45:37 2013 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Nov 29 21:45:37 2013 +0000

pvcreate: Avoid spurious 'not found' messages.

Replacement of pv_read by find_pv_by_name in commit
651d5093edde3e0ebee9d75be1c9834efc152d91 caused spurious
error messages when running pvcreate or vgextend against an
unformatted device.

Physical volume /dev/loop4 not found
Physical volume "/dev/loop4" successfully created

Physical volume /dev/loop4 not found
Physical volume /dev/loop4 not found
Physical volume "/dev/loop4" successfully created
Volume group "vg1" successfully extended
---
 lib/metadata/metadata-exported.h |    2 +-
 lib/metadata/metadata.c          |    8 ++++----
 lib/metadata/mirror.c            |    2 +-
 tools/pvmove.c                   |    4 ++--
 4 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index ece5f53..f205a14 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -847,7 +847,7 @@ struct logical_volume *find_lv(const struct volume_group *vg,
 			       const char *lv_name);
 struct physical_volume *find_pv_by_name(struct cmd_context *cmd,
 					const char *pv_name,
-					int allow_orphan);
+					int allow_orphan, int allow_unformatted);
 
 const char *find_vgname_from_pvname(struct cmd_context *cmd,
 				    const char *pvname);
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index f075c21..61816e2 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -633,7 +633,7 @@ static int vg_extend_single_pv(struct volume_group *vg, char *pv_name,
 {
 	struct physical_volume *pv;
 
-	if (!(pv = find_pv_by_name(vg->cmd, pv_name, 1)))
+	if (!(pv = find_pv_by_name(vg->cmd, pv_name, 1, 1)))
 		stack;
 	if (!pv && !pp) {
 		log_error("%s not identified as an existing "
@@ -1278,7 +1278,7 @@ static int pvcreate_check(struct cmd_context *cmd, const char *name,
 	/* FIXME Check partition type is LVM unless --force is given */
 
 	/* Is there a pv here already? */
-	if (!(pv = find_pv_by_name(cmd, name, 1)))
+	if (!(pv = find_pv_by_name(cmd, name, 1, 1)))
 		stack;
 
 	/* Allow partial & exported VGs to be destroyed. */
@@ -1781,7 +1781,7 @@ struct physical_volume *find_pv(struct volume_group *vg, struct device *dev)
 /* FIXME: liblvm todo - make into function that returns handle */
 struct physical_volume *find_pv_by_name(struct cmd_context *cmd,
 					const char *pv_name,
-					int allow_orphan)
+					int allow_orphan, int allow_unformatted)
 {
 	struct device *dev;
 	struct pv_list *pvl;
@@ -1804,7 +1804,7 @@ struct physical_volume *find_pv_by_name(struct cmd_context *cmd,
 		else
 			free_pv_fid(pvl->pv);
 
-	if (!pv)
+	if (!pv && !allow_unformatted)
 		log_error("Physical volume %s not found", pv_name);
 
 	if (pv && !allow_orphan && is_orphan_vg(pv->vg_name)) {
diff --git a/lib/metadata/mirror.c b/lib/metadata/mirror.c
index 6fc7674..18917d3 100644
--- a/lib/metadata/mirror.c
+++ b/lib/metadata/mirror.c
@@ -1577,7 +1577,7 @@ struct logical_volume *find_pvmove_lv_from_pvname(struct cmd_context *cmd,
 	struct physical_volume *pv;
 	struct logical_volume *lv;
 
-	if (!(pv = find_pv_by_name(cmd, name, 0)))
+	if (!(pv = find_pv_by_name(cmd, name, 0, 0)))
 		return_NULL;
 
 	lv = find_pvmove_lv(vg, pv->dev, lv_type);
diff --git a/tools/pvmove.c b/tools/pvmove.c
index ab2e03b..19e1482 100644
--- a/tools/pvmove.c
+++ b/tools/pvmove.c
@@ -628,7 +628,7 @@ static int _set_up_pvmove(struct cmd_context *cmd, const char *pv_name,
 	argv++;
 
 	/* Find PV (in VG) */
-	if (!(pv = find_pv_by_name(cmd, pv_name, 0))) {
+	if (!(pv = find_pv_by_name(cmd, pv_name, 0, 0))) {
 		stack;
 		return EINVALID_CMD_LINE;
 	}
@@ -809,7 +809,7 @@ static struct volume_group *_get_move_vg(struct cmd_context *cmd,
 	struct volume_group *vg;
 
 	/* Reread all metadata in case it got changed */
-	if (!(pv = find_pv_by_name(cmd, name, 0))) {
+	if (!(pv = find_pv_by_name(cmd, name, 0, 0))) {
 		log_error("ABORTING: Can't reread PV %s", name);
 		/* What more could we do here? */
 		return NULL;


