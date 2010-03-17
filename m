From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed, 17 Mar 2010 13:59:02 -0400
Subject: [PATCH] Avoid scanning all pvs in the system if operating on a device with mdas.
In-Reply-To: <1268847147.2476.2.camel@f10-node1>
References: <1268847147.2476.2.camel@f10-node1>
Message-ID: <1268848742-27785-1-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

When we pv_read() a device that has an orphan vgname, we might need to scan
the system to be sure this is true.  However, if the PV has mdas, there's
no way possible for it to have an orphan vgname unless it is a true orphan.
Some areas of the code were optimized to take advantage of this fact, while
others were not (we would still do the expensive scan if a device had mdas
but had an orphan VG).

This patch unifies the code so that every place we are operating on such
a PV, we skip the expensive scan if there are mdas.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/metadata/metadata.c |   13 +++++++++----
 tools/toollib.c         |    8 ++++++--
 2 files changed, 15 insertions(+), 6 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 4060ca2..020e897 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -1251,11 +1251,14 @@ static int pvcreate_check(struct cmd_context *cmd, const char *name,
 	struct device *dev;
 	uint64_t md_superblock, swap_signature;
 	int wipe_md, wipe_swap;
+	struct dm_list mdas;
+
+	dm_list_init(&mdas);
 
 	/* FIXME Check partition type is LVM unless --force is given */
 
 	/* Is there a pv here already? */
-	pv = pv_read(cmd, name, NULL, NULL, 0, 0);
+	pv = pv_read(cmd, name, &mdas, NULL, 0, 0);
 
 	/*
 	 * If a PV has no MDAs it may appear to be an orphan until the
@@ -1263,7 +1266,7 @@ static int pvcreate_check(struct cmd_context *cmd, const char *name,
 	 * this means checking every VG by scanning every PV on the
 	 * system.
 	 */
-	if (pv && is_orphan(pv)) {
+	if (pv && is_orphan(pv) && !dm_list_size(&mdas)) {
 		if (!scan_vgs_for_pvs(cmd))
 			return_0;
 		pv = pv_read(cmd, name, NULL, NULL, 0, 0);
@@ -1747,14 +1750,16 @@ struct physical_volume *find_pv_by_name(struct cmd_context *cmd,
 static struct physical_volume *_find_pv_by_name(struct cmd_context *cmd,
 			 			const char *pv_name)
 {
+	struct dm_list mdas;
 	struct physical_volume *pv;
 
-	if (!(pv = _pv_read(cmd, cmd->mem, pv_name, NULL, NULL, 1, 0))) {
+	dm_list_init(&mdas);
+	if (!(pv = _pv_read(cmd, cmd->mem, pv_name, &mdas, NULL, 1, 0))) {
 		log_error("Physical volume %s not found", pv_name);
 		return NULL;
 	}
 
-	if (is_orphan_vg(pv->vg_name)) {
+	if (is_orphan_vg(pv->vg_name) && !dm_list_size(&mdas)) {
 		/* If a PV has no MDAs - need to search all VGs for it */
 		if (!scan_vgs_for_pvs(cmd))
 			return_NULL;
diff --git a/tools/toollib.c b/tools/toollib.c
index 0d3fe0a..efe870c 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -642,6 +642,7 @@ int process_each_pv(struct cmd_context *cmd, int argc, char **argv,
 	struct str_list *sll;
 	char *tagname;
 	int scanned = 0;
+	struct dm_list mdas;
 
 	dm_list_init(&tags);
 
@@ -682,7 +683,9 @@ int process_each_pv(struct cmd_context *cmd, int argc, char **argv,
 				}
 				pv = pvl->pv;
 			} else {
-				if (!(pv = pv_read(cmd, argv[opt], NULL,
+
+				dm_list_init(&mdas);
+				if (!(pv = pv_read(cmd, argv[opt], &mdas,
 						   NULL, 1, scan_label_only))) {
 					log_error("Failed to read physical "
 						  "volume \"%s\"", argv[opt]);
@@ -697,7 +700,8 @@ int process_each_pv(struct cmd_context *cmd, int argc, char **argv,
 				 * means checking every VG by scanning every
 				 * PV on the system.
 				 */
-				if (!scanned && is_orphan(pv)) {
+				if (!scanned && is_orphan(pv) &&
+				    !dm_list_size(&mdas)) {
 					if (!scan_label_only &&
 					    !scan_vgs_for_pvs(cmd)) {
 						stack;
-- 
1.6.0.6


