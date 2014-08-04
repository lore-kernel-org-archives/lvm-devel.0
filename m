From: Petr Rockai <mornfall@fedoraproject.org>
Date: Mon,  4 Aug 2014 15:37:01 +0000 (UTC)
Subject: master - lvscan: Fix possible gcc warnings in --cache implementation.
Message-ID: <20140804153701.4270F6104E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2dac5525fb39f83a8088c10ae6c9bc0131a01433
Commit:        2dac5525fb39f83a8088c10ae6c9bc0131a01433
Parent:        46262f163b2a6c802f91076c2675bda4be5d8a2d
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Mon Aug 4 17:36:12 2014 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Mon Aug 4 17:36:12 2014 +0200

lvscan: Fix possible gcc warnings in --cache implementation.

---
 tools/lvscan.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/tools/lvscan.c b/tools/lvscan.c
index 0cfbe83..487c4cf 100644
--- a/tools/lvscan.c
+++ b/tools/lvscan.c
@@ -18,20 +18,20 @@
 static int _lvscan_single_lvmetad(struct cmd_context *cmd, struct logical_volume *lv)
 {
 	struct pv_list *pvl;
-	struct dm_list pvs;
-	char pvid_s[64];
+	struct dm_list all_pvs;
+	char pvid_s[64] __attribute__((aligned(8)));
 
 	if (!lvmetad_used()) {
 		log_verbose("Ignoring lvscan --cache because lvmetad is not in use.");
 		return ECMD_PROCESSED;
 	}
 
-	dm_list_init(&pvs);
+	dm_list_init(&all_pvs);
 
-	if (!get_pv_list_for_lv(lv->vg->vgmem, lv, &pvs))
+	if (!get_pv_list_for_lv(lv->vg->vgmem, lv, &all_pvs))
 		return ECMD_FAILED;
 
-	dm_list_iterate_items(pvl, &pvs) {
+	dm_list_iterate_items(pvl, &all_pvs) {
 		if (!pvl->pv->dev) {
 			id_write_format(&pvl->pv->id, pvid_s, sizeof(pvid_s));
 			log_warn("WARNING: Device for PV %s already missing, skipping.",


