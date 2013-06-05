From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed,  5 Jun 2013 12:06:14 +0000 (UTC)
Subject: dev-mornfall-lvmcache - metadata: Avoid pv_read in find_pv_by_name.
Message-ID: <20130605120614.1F73361057@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4db47137a42e3320d92e59795cb51c3a87987727
Commit:        4db47137a42e3320d92e59795cb51c3a87987727
Parent:        4e9bbccb33da4dd23b6707914188f7ae611ec698
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Tue Feb 19 02:32:25 2013 +0100
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Wed Jun 5 12:37:37 2013 +0200

metadata: Avoid pv_read in find_pv_by_name.

---
 lib/metadata/metadata.c |   34 ++++++++++++++++++++--------------
 1 files changed, 20 insertions(+), 14 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 31c9eba..61dc1bd 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -1309,7 +1309,7 @@ static int pvcreate_check(struct cmd_context *cmd, const char *name,
 	/* FIXME Check partition type is LVM unless --force is given */
 
 	/* Is there a pv here already? */
-	if (!(pv = pv_read(cmd, name, 0, 0)))
+	if (!(pv = find_pv_by_name(cmd, name, 1)))
 		stack;
 
 	/*
@@ -1805,23 +1805,29 @@ struct physical_volume *find_pv_by_name(struct cmd_context *cmd,
 					const char *pv_name,
 					int allow_orphan)
 {
-	struct physical_volume *pv;
+	struct device *dev;
+	struct pv_list *pvl;
+	struct dm_list *pvslist;
+	struct physical_volume *pv = NULL;
+
+	lvmcache_seed_infos_from_lvmetad(cmd);
 
-	if (!(pv = _pv_read(cmd, cmd->mem, pv_name, NULL, 1, 0))) {
+	if (!(dev = dev_cache_get(pv_name, cmd->filter))) {
 		log_error("Physical volume %s not found", pv_name);
-		goto bad;
+		return_NULL;
 	}
 
-	if (is_orphan_vg(pv->vg_name) && !dm_list_size(&pv->fid->metadata_areas_in_use)) {
-		/* If a PV has no MDAs - need to search all VGs for it */
-		if (!scan_vgs_for_pvs(cmd, 1))
-			goto_bad;
-		free_pv_fid(pv);
-		if (!(pv = _pv_read(cmd, cmd->mem, pv_name, NULL, 1, 0))) {
-			log_error("Physical volume %s not found", pv_name);
-			goto bad;
-		}
-	}
+	if (!(pvslist = get_pvs(cmd)))
+		return_NULL;
+
+	dm_list_iterate_items(pvl, pvslist)
+		if (pvl->pv->dev == dev)
+			pv = pvl->pv;
+		else
+			free_pv_fid(pvl->pv);
+
+	if (!pv)
+		log_error("Physical volume %s not found", pv_name);
 
 	if (pv && !allow_orphan && is_orphan_vg(pv->vg_name)) {
 		log_error("Physical volume %s not in a volume group", pv_name);


