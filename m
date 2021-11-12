From: David Teigland <teigland@sourceware.org>
Date: Fri, 12 Nov 2021 18:27:04 +0000 (GMT)
Subject: main - pvscan: consistent creation of pvs_lookup file
Message-ID: <20211112182704.7AC14385840B@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5dbf316cee12484ad701367ff519bebe1523ef9a
Commit:        5dbf316cee12484ad701367ff519bebe1523ef9a
Parent:        b945ea1c93a1f6ac76a082391652193b475950c7
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Nov 12 10:06:54 2021 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Nov 12 11:40:06 2021 -0600

pvscan: consistent creation of pvs_lookup file

Consistently create the pvs_lookup file for VGs with
more than one PV.  Previously the file create would be
skipped if all the PVs happened to already be online.
That led to unpredicatable results in an uncommon case
(when the last PV to come online is the only PV with
metadata.)
---
 tools/pvscan.c | 43 ++++++++++++++++++++++++++++++-------------
 1 file changed, 30 insertions(+), 13 deletions(-)

diff --git a/tools/pvscan.c b/tools/pvscan.c
index df1722c45..d360ec87f 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -289,7 +289,7 @@ static int _write_lookup_file(struct cmd_context *cmd, struct volume_group *vg)
 		line[ID_LEN+1] = '\0';
 
 		if (write(fd, &line, ID_LEN+1) < 0)
-			log_sys_debug("write", path);
+			log_error_pvscan(cmd, "Failed to write lookup entry %s %s", path, line);
 	}
 
 	if (close(fd))
@@ -1137,22 +1137,39 @@ static int _online_devs(struct cmd_context *cmd, int do_all, struct dm_list *pvs
 
 			if (vg) {
 				/*
-				 * Use the VG metadata from this PV for a list of all
-				 * PVIDs.  Write a lookup file of PVIDs in case another
-				 * pvscan needs it.  After writing lookup file, recheck
-				 * pvid files to resolve a possible race with another
-				 * pvscan reading the lookup file that missed it.
+				 * Check if the VG is complete by checking that
+				 * pvs_online/<pvid> files exist for all vg->pvs.
 				 */
 				log_debug("checking all pvid files from vg %s", vg->name);
 				_count_pvid_files(vg, &pvs_online, &pvs_offline);
-	
-				if (pvs_offline && _write_lookup_file(cmd, vg)) {
-					log_debug("rechecking all pvid files from vg %s", vg->name);
-					_count_pvid_files(vg, &pvs_online, &pvs_offline);
-					if (!pvs_offline)
-						log_print_pvscan(cmd, "VG %s complete after recheck.", vg->name);
+
+				/*
+				 * When there is more than one PV in the VG, write
+				 * /run/lvm/pvs_lookup/<vgname> with a list of PVIDs in
+				 * the VG.  This is used in case a later PV comes
+				 * online that has no metadata, in which case pvscan
+				 * for that PV needs to use the lookup file to check if
+				 * the VG is complete.  The lookup file is also used by
+				 * vgchange -aay --autoactivation event <vgname>
+				 * to check if all pvs_online files for the VG exist.
+				 *
+				 * For multiple concurrent pvscan's, they will race to
+				 * create the lookup file and the first will succeed.
+				 *
+				 * After writing the lookup file, recheck pvid files to
+				 * resolve a possible race with another pvscan reading
+				 * the lookup file that missed it.
+				 */
+				if (dm_list_size(&vg->pvs) > 1) {
+					if (_write_lookup_file(cmd, vg)) {
+						if (pvs_offline) {
+							log_debug("rechecking all pvid files from vg %s", vg->name);
+							_count_pvid_files(vg, &pvs_online, &pvs_offline);
+							if (!pvs_offline)
+								log_print_pvscan(cmd, "VG %s complete after recheck.", vg->name);
+						}
+					}
 				}
-	
 				vgname = vg->name;
 			} else {
 				/*


