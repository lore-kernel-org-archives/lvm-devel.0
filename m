From: David Teigland <teigland@sourceware.org>
Date: Mon, 30 Sep 2019 12:39:42 -0400
Subject: master - pvscan: use quick activation only with matching PV device names
Message-ID: <201909301639.x8UGdgjD024746@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0c23d3fc8402e49e61c9c490d9c2c9c2d58596e8
Commit:        0c23d3fc8402e49e61c9c490d9c2c9c2d58596e8
Parent:        3a8e41a67b3f0edb0fcb27302351f7d58b6ef8c5
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Sep 4 15:59:49 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Sep 30 11:38:10 2019 -0500

pvscan: use quick activation only with matching PV device names

When the PV device names in the VG metadata do not match the
current PV device names seen on the system, do not use the
optimized activation function (that avoids extra device scanning.)

When the device names do not match, it's a clue that there could
be duplicate PVs, in which case we want to scan all devicess to
find any duplicates and stop the activation if found.

This does not prevent autoactivating a VG from the incorrect
duplicate PV, because the incorrect duplicate may appear by itself
first.  At that point its duplicate PV does not exist to be seen.
(A future enhancement could use the WWID to strengthen this
detection.)
---
 tools/pvscan.c |   30 ++++++++++++++++++++++--------
 1 files changed, 22 insertions(+), 8 deletions(-)

diff --git a/tools/pvscan.c b/tools/pvscan.c
index b025ae3..96ef438 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -929,17 +929,19 @@ static int _online_vg_file_create(struct cmd_context *cmd, const char *vgname)
  * scan/read in order to process/activate the VG.
  */
 
-static int _get_devs_from_saved_vg(struct cmd_context *cmd, char *vgname,
+static int _get_devs_from_saved_vg(struct cmd_context *cmd, const char *vgname,
 				   struct dm_list *saved_vgs,
 				   struct dm_list *devs)
 {
 	char path[PATH_MAX];
 	char file_vgname[NAME_LEN];
+	char uuidstr[64] __attribute__((aligned(8)));
 	struct pv_list *pvl;
 	struct device_list *devl;
 	struct device *dev;
 	struct volume_group *vg;
 	const char *pvid;
+	const char *name1, *name2;
 	dev_t devno;
 	int file_major = 0, file_minor = 0;
 
@@ -978,6 +980,16 @@ static int _get_devs_from_saved_vg(struct cmd_context *cmd, char *vgname,
 			return 0;
 		}
 
+		name1 = dev_name(dev);
+		name2 = pvl->pv->device_hint;
+
+		if (strcmp(name1, name2)) {
+			if (!id_write_format((const struct id *)pvid, uuidstr, sizeof(uuidstr)))
+				uuidstr[0] = '\0';
+			log_print("PVID %s read from %s last written to %s.", uuidstr, name1, name2);
+			return 0;
+		}
+
 		if (!(devl = zalloc(sizeof(*devl))))
 			return_0;
 
@@ -1024,8 +1036,8 @@ static int _get_devs_from_saved_vg(struct cmd_context *cmd, char *vgname,
  * is important when there are many devs.
  */
 
-static int _pvscan_aa_direct(struct cmd_context *cmd, struct pvscan_aa_params *pp, char *vgname,
-			     struct dm_list *saved_vgs)
+static int _pvscan_aa_quick(struct cmd_context *cmd, struct pvscan_aa_params *pp, const char *vgname,
+			    struct dm_list *saved_vgs, int *no_quick)
 {
 	struct dm_list devs; /* device_list */
 	struct volume_group *vg;
@@ -1044,7 +1056,8 @@ static int _pvscan_aa_direct(struct cmd_context *cmd, struct pvscan_aa_params *p
 	 * The dev_cache gives us struct devices from the devnums.
 	 */
 	if (!_get_devs_from_saved_vg(cmd, vgname, saved_vgs, &devs)) {
-		log_error("pvscan activation for VG %s failed to find devices.", vgname);
+		log_print("pvscan[%d] VG %s not using quick activation.", getpid(), vgname);
+		*no_quick = 1;
 		return ECMD_FAILED;
 	}
 
@@ -1132,6 +1145,7 @@ static int _pvscan_aa(struct cmd_context *cmd, struct pvscan_aa_params *pp,
 {
 	struct processing_handle *handle = NULL;
 	struct dm_str_list *sl, *sl2;
+	int no_quick = 0;
 	int ret;
 
 	if (dm_list_empty(vgnames)) {
@@ -1169,12 +1183,12 @@ static int _pvscan_aa(struct cmd_context *cmd, struct pvscan_aa_params *pp,
 
 	if (dm_list_size(vgnames) == 1) {
 		dm_list_iterate_items(sl, vgnames)
-			ret = _pvscan_aa_direct(cmd, pp, (char *)sl->str, saved_vgs);
-	} else {
-		/* FIXME: suppress label scan in process_each if label scan already done? */
-		ret = process_each_vg(cmd, 0, NULL, NULL, vgnames, READ_FOR_ACTIVATE, 0, handle, _pvscan_aa_single);
+			ret = _pvscan_aa_quick(cmd, pp, sl->str, saved_vgs, &no_quick);
 	}
 
+	if ((dm_list_size(vgnames) > 1) || no_quick)
+		ret = process_each_vg(cmd, 0, NULL, NULL, vgnames, READ_FOR_ACTIVATE, 0, handle, _pvscan_aa_single);
+
 	destroy_processing_handle(cmd, handle);
 
 	return ret;


