From: David Teigland <teigland@fedoraproject.org>
Date: Tue, 12 Jan 2016 17:53:55 +0000 (UTC)
Subject: master - pvmove: disallow moving PVs under sanlock leases
Message-ID: <20160112175355.D8254606DC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0c6946b4ce2fc664a66cd68a4fb2324bfb69b5ab
Commit:        0c6946b4ce2fc664a66cd68a4fb2324bfb69b5ab
Parent:        176b4aaebeb8b885d5df16172a5bc32481beda59
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Jan 12 11:51:12 2016 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Jan 12 11:53:33 2016 -0600

pvmove: disallow moving PVs under sanlock leases

Fail with an error message if pvmove tries to move PVs
under the lvmlock LV.
---
 tools/pvmove.c |   28 ++++++++++++++++++++++++++++
 1 files changed, 28 insertions(+), 0 deletions(-)

diff --git a/tools/pvmove.c b/tools/pvmove.c
index a7943fa..d3eb1ab 100644
--- a/tools/pvmove.c
+++ b/tools/pvmove.c
@@ -643,6 +643,28 @@ static int _set_up_pvmove(struct cmd_context *cmd, const char *pv_name,
 		goto out_ret;
 	}
 
+	/*
+	 * We cannot move blocks from under the sanlock leases, so disallow
+	 * pvmoving any PVs used by the lvmlock LV.
+	 */
+	if (vg->lock_type && !strcmp(vg->lock_type, "sanlock")) {
+		struct lv_segment *lvseg;
+		struct physical_volume *sanlock_pv;
+		unsigned s;
+
+		dm_list_iterate_items(lvseg, &vg->sanlock_lv->segments) {
+			for (s = 0; s < lvseg->area_count; s++) {
+				if (seg_type(lvseg, s) == AREA_PV) {
+					sanlock_pv = seg_pv(lvseg, s);
+					if (sanlock_pv->dev == pv->dev) {
+						log_error("Cannot pvmove device %s used for sanlock leases.", pv_dev_name(pv));
+						goto out;
+					}
+				}
+			}
+		}
+	}
+
 	exclusive = _pvmove_is_exclusive(cmd, vg);
 
 	if ((lv_mirr = find_pvmove_lv(vg, pv_dev(pv), PVMOVE))) {
@@ -894,6 +916,12 @@ int pvmove(struct cmd_context *cmd, int argc, char **argv)
 			return ECMD_FAILED;
 		}
 
+		/*
+		 * FIXME: use process_each_pv() where the "single" function
+		 * depends on the abort arg.  The single functions would not
+		 * need to use find_pv_by_name() (which includes a hidden
+		 * equivalent of process_each_pv), or vg_read().
+		 */
 		if (!arg_count(cmd, abort_ARG)) {
 			if ((ret = _set_up_pvmove(cmd, pv_name, argc, argv, lvid, &vg_name, &lv_name)) != ECMD_PROCESSED) {
 				stack;


