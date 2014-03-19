From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 19 Mar 2014 00:02:16 +0000 (UTC)
Subject: master - pvscan: fix report of long pv names
Message-ID: <20140319000216.C983260FD8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3d7eaf9226d6e425721f12da5ff4cd47209324df
Commit:        3d7eaf9226d6e425721f12da5ff4cd47209324df
Parent:        caf93eb1cb74050658dcf1816254ae3666aa3818
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Mar 19 00:17:36 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Mar 19 00:58:01 2014 +0100

pvscan: fix report of long pv names

pvscan --uuid was broken since it was using only 128 char buffers
without checking any write size, so any longer device path leads to
crash.

Also ansure format is properly aligned into columns with this option.
---
 WHATS_NEW      |    1 +
 tools/pvscan.c |   57 ++++++++++++++++++++++++-------------------------------
 2 files changed, 26 insertions(+), 32 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 2492598..b7040d7 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.106 - 
 ====================================
+  Fix memory corruption when pvscan reports long pv names.
   Do not report internal orphan VG names when reporting pvdisplay/pvscan.
   Fix pvdisplay -c man page referencing KB instead of sectors.
   Skip redundant synchronization calls on local clvmd.
diff --git a/tools/pvscan.c b/tools/pvscan.c
index 5db627a..cb2f3f9 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -25,12 +25,12 @@ static void _pvscan_display_single(struct cmd_context *cmd,
 				   struct physical_volume *pv,
 				   void *handle __attribute__((unused)))
 {
-	char uuid[64] __attribute__((aligned(8)));
-	unsigned vg_name_len = 0;
-
-	char pv_tmp_name[NAME_LEN] = { 0 };
-	char vg_tmp_name[NAME_LEN] = { 0 };
-	char vg_name_this[NAME_LEN] = { 0 };
+	/* XXXXXX-XXXX-XXXX-XXXX-XXXX-XXXX-XXXXXX */
+	char uuid[40] __attribute__((aligned(8)));
+	const unsigned suffix = sizeof(uuid) + 10;
+	char pv_tmp_name[pv_max_name_len + suffix];
+	unsigned pv_len = pv_max_name_len;
+	const char *pvdevname = pv_dev_name(pv);
 
 	/* short listing? */
 	if (arg_count(cmd, short_ARG) > 0) {
@@ -49,46 +49,39 @@ static void _pvscan_display_single(struct cmd_context *cmd,
 		/* return; */
 	}
 
-	vg_name_len = strlen(pv_vg_name(pv)) + 1;
-
 	if (arg_count(cmd, uuid_ARG)) {
 		if (!id_write_format(&pv->id, uuid, sizeof(uuid))) {
 			stack;
 			return;
 		}
 
-		sprintf(pv_tmp_name, "%-*s with UUID %s",
-			pv_max_name_len - 2, pv_dev_name(pv), uuid);
-	} else {
-		sprintf(pv_tmp_name, "%s", pv_dev_name(pv));
+		if (dm_snprintf(pv_tmp_name, sizeof(pv_tmp_name), "%-*s with UUID %s",
+				pv_max_name_len - 2, pvdevname, uuid) < 0) {
+			log_error("Invalid PV name with uuid.");
+			return;
+		}
+		pvdevname = pv_tmp_name;
+		pv_len += suffix;
 	}
 
-	if (is_orphan(pv)) {
+	if (is_orphan(pv))
 		log_print_unless_silent("PV %-*s    %-*s %s [%s]",
-					pv_max_name_len, pv_tmp_name,
+					pv_len, pvdevname,
 					vg_max_name_len, " ",
 					pv->fmt ? pv->fmt->name : "    ",
 					display_size(cmd, pv_size(pv)));
-		return;
-	}
-
-	if (pv_status(pv) & EXPORTED_VG) {
-		strncpy(vg_name_this, pv_vg_name(pv), vg_name_len);
-		log_print_unless_silent("PV %-*s  is in exported VG %s "
-					"[%s / %s free]",
-					pv_max_name_len, pv_tmp_name,
-					vg_name_this,
+	else if (pv_status(pv) & EXPORTED_VG)
+		log_print_unless_silent("PV %-*s  is in exported VG %s [%s / %s free]",
+					pv_len, pvdevname, pv_vg_name(pv),
+					display_size(cmd, (uint64_t) pv_pe_count(pv) * pv_pe_size(pv)),
+					display_size(cmd, (uint64_t) (pv_pe_count(pv) - pv_pe_alloc_count(pv)) * pv_pe_size(pv)));
+	else
+		log_print_unless_silent("PV %-*s VG %-*s %s [%s / %s free]",
+					pv_len, pvdevname,
+					vg_max_name_len, pv_vg_name(pv),
+					pv->fmt ? pv->fmt->name : "    ",
 					display_size(cmd, (uint64_t) pv_pe_count(pv) * pv_pe_size(pv)),
 					display_size(cmd, (uint64_t) (pv_pe_count(pv) - pv_pe_alloc_count(pv)) * pv_pe_size(pv)));
-		return;
-	}
-
-	sprintf(vg_tmp_name, "%s", pv_vg_name(pv));
-	log_print_unless_silent("PV %-*s VG %-*s %s [%s / %s free]", pv_max_name_len,
-				pv_tmp_name, vg_max_name_len, vg_tmp_name,
-				pv->fmt ? pv->fmt->name : "    ",
-				display_size(cmd, (uint64_t) pv_pe_count(pv) * pv_pe_size(pv)),
-				display_size(cmd, (uint64_t) (pv_pe_count(pv) - pv_pe_alloc_count(pv)) * pv_pe_size(pv)));
 }
 
 #define REFRESH_BEFORE_AUTOACTIVATION_RETRIES 5


