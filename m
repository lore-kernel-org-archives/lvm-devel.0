From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 10 Aug 2009 17:15:02 -0000
Subject: LVM2/lib/metadata metadata.c
Message-ID: <20090810171502.3160.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-08-10 17:15:02

Modified files:
	lib/metadata   : metadata.c 

Log message:
	Remove useless _pv_write wrapper.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.277&r2=1.278

--- LVM2/lib/metadata/metadata.c	2009/08/01 17:08:44	1.277
+++ LVM2/lib/metadata/metadata.c	2009/08/10 17:15:01	1.278
@@ -45,10 +45,6 @@
 					uint64_t *label_sector,
 					int warnings, int scan_label_only);
 
-static int _pv_write(struct cmd_context *cmd __attribute((unused)),
-		     struct physical_volume *pv,
-	     	     struct dm_list *mdas, int64_t label_sector);
-
 static struct physical_volume *_find_pv_by_name(struct cmd_context *cmd,
 			 			const char *pv_name);
 
@@ -2995,18 +2991,10 @@
 	return _get_pvs(cmd, NULL);
 }
 
-/* FIXME: liblvm todo - make into function that takes handle */
 int pv_write(struct cmd_context *cmd __attribute((unused)),
 	     struct physical_volume *pv,
 	     struct dm_list *mdas, int64_t label_sector)
 {
-	return _pv_write(cmd, pv, mdas, label_sector);
-}
-
-static int _pv_write(struct cmd_context *cmd __attribute((unused)),
-		     struct physical_volume *pv,
-	     	     struct dm_list *mdas, int64_t label_sector)
-{
 	if (!pv->fmt->ops->pv_write) {
 		log_error("Format does not support writing physical volumes");
 		return 0;
@@ -3037,7 +3025,7 @@
 		return 0;
 	}
 
-	if (!_pv_write(cmd, pv, NULL, INT64_C(-1))) {
+	if (!pv_write(cmd, pv, NULL, INT64_C(-1))) {
 		log_error("Failed to clear metadata from physical "
 			  "volume \"%s\" after removal from \"%s\"",
 			  pv_dev_name(pv), old_vg_name);


