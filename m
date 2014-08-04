From: Petr Rockai <mornfall@fedoraproject.org>
Date: Mon,  4 Aug 2014 15:06:39 +0000 (UTC)
Subject: master - lvscan: Make --cache impervious to already-missing devices.
Message-ID: <20140804150639.51D9C6004F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0208665209c4e8f02841a426e6073a48195f56c1
Commit:        0208665209c4e8f02841a426e6073a48195f56c1
Parent:        03a88da86895f4700edf77af4efde62a30e67bff
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Mon Aug 4 17:02:26 2014 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Mon Aug 4 17:03:17 2014 +0200

lvscan: Make --cache impervious to already-missing devices.

---
 tools/lvscan.c |   10 +++++++++-
 1 files changed, 9 insertions(+), 1 deletions(-)

diff --git a/tools/lvscan.c b/tools/lvscan.c
index df8a12e..0cfbe83 100644
--- a/tools/lvscan.c
+++ b/tools/lvscan.c
@@ -19,6 +19,7 @@ static int _lvscan_single_lvmetad(struct cmd_context *cmd, struct logical_volume
 {
 	struct pv_list *pvl;
 	struct dm_list pvs;
+	char pvid_s[64];
 
 	if (!lvmetad_used()) {
 		log_verbose("Ignoring lvscan --cache because lvmetad is not in use.");
@@ -30,9 +31,16 @@ static int _lvscan_single_lvmetad(struct cmd_context *cmd, struct logical_volume
 	if (!get_pv_list_for_lv(lv->vg->vgmem, lv, &pvs))
 		return ECMD_FAILED;
 
-	dm_list_iterate_items(pvl, &pvs)
+	dm_list_iterate_items(pvl, &pvs) {
+		if (!pvl->pv->dev) {
+			id_write_format(&pvl->pv->id, pvid_s, sizeof(pvid_s));
+			log_warn("WARNING: Device for PV %s already missing, skipping.",
+				 pvid_s);
+			continue;
+		}
 		if (!lvmetad_pvscan_single(cmd, pvl->pv->dev, NULL))
 			return ECMD_FAILED;
+	}
 
 	return ECMD_PROCESSED;
 }


