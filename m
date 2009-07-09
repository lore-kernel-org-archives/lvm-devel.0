From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 9 Jul 2009 11:29:42 -0000
Subject: LVM2 ./WHATS_NEW lib/format_text/import_vsn1.c
Message-ID: <20090709112942.25123.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-07-09 11:29:41

Modified files:
	.              : WHATS_NEW 
	lib/format_text: import_vsn1.c 

Log message:
	Fix and precise metadata read errors for segment areas.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1172&r2=1.1173
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/import_vsn1.c.diff?cvsroot=lvm2&r1=1.62&r2=1.63

--- LVM2/WHATS_NEW	2009/07/09 11:29:00	1.1172
+++ LVM2/WHATS_NEW	2009/07/09 11:29:41	1.1173
@@ -1,5 +1,6 @@
 Version 2.02.49 - 
 ================================
+  Fix and precise metadata read errors for segment areas.
   Fix segment metadata read function errors to use proper segment name.
   Add parent node to config_node structure.
   Fix segment import functions to print segment name and logical volume name.
--- LVM2/lib/format_text/import_vsn1.c	2009/07/09 11:28:10	1.62
+++ LVM2/lib/format_text/import_vsn1.c	2009/07/09 11:29:41	1.63
@@ -377,32 +377,29 @@
 	unsigned int s;
 	struct config_value *cv;
 	struct logical_volume *lv1;
-	const char *seg_name = sn->key;
+	struct physical_volume *pv;
+	const char *seg_name = config_parent_name(sn);
 
 	if (!seg->area_count) {
-		log_error("Zero areas not allowed for segment '%s'", sn->key);
+		log_error("Zero areas not allowed for segment %s", seg_name);
 		return 0;
 	}
 
 	for (cv = cn->v, s = 0; cv && s < seg->area_count; s++, cv = cv->next) {
 
 		/* first we read the pv */
-		const char *bad = "Badly formed areas array for "
-		    "segment '%s'.";
-		struct physical_volume *pv;
-
 		if (cv->type != CFG_STRING) {
-			log_error(bad, sn->key);
+			log_error("Bad volume name in areas array for segment %s.", seg_name);
 			return 0;
 		}
 
 		if (!cv->next) {
-			log_error(bad, sn->key);
+			log_error("Missing offset in areas array for segment %s.", seg_name);
 			return 0;
 		}
 
 		if (cv->next->type != CFG_INT) {
-			log_error(bad, sn->key);
+			log_error("Bad offset in areas array for segment %s.", seg_name);
 			return 0;
 		}
 


