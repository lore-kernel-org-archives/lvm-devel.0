From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 28 Jan 2012 20:12:30 -0000
Subject: LVM2 ./WHATS_NEW lib/activate/dev_manager.c
Message-ID: <20120128201230.26959.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-01-28 20:12:29

Modified files:
	.              : WHATS_NEW 
	lib/activate   : dev_manager.c 

Log message:
	Fix data% reporting
	
	For reading % of mapped size of thin volume use as origin for
	old style snapshot '-real' device needs to be queried.
	Fix log_error report given for lvs -a in this case.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2246&r2=1.2247
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.268&r2=1.269

--- LVM2/WHATS_NEW	2012/01/27 01:23:40	1.2246
+++ LVM2/WHATS_NEW	2012/01/28 20:12:26	1.2247
@@ -1,5 +1,6 @@
 Version 2.02.90 - 
 ===================================
+  Fix data% report for thin volume used as origin for non-thin snapshot.
 
 Version 2.02.89 - 26th January 2012
 ===================================
--- LVM2/lib/activate/dev_manager.c	2012/01/25 11:10:06	1.268
+++ LVM2/lib/activate/dev_manager.c	2012/01/28 20:12:29	1.269
@@ -953,12 +953,13 @@
 {
 	char *name;
 	const char *dlid;
+	const char *layer = lv_is_origin(lv) ? "real" : NULL;
 
 	/* Build a name for the top layer */
-	if (!(name = dm_build_dm_name(dm->mem, lv->vg->name, lv->name, NULL)))
+	if (!(name = dm_build_dm_name(dm->mem, lv->vg->name, lv->name, layer)))
 		return_0;
 
-	if (!(dlid = build_dm_uuid(dm->mem, lv->lvid.s, NULL)))
+	if (!(dlid = build_dm_uuid(dm->mem, lv->lvid.s, layer)))
 		return_0;
 
 	log_debug("Getting device status percentage for %s", name);


