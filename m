From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 14 May 2010 12:03:33 -0000
Subject: LVM2/lib/activate dev_manager.c
Message-ID: <20100514120333.1313.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2010-05-14 12:03:32

Modified files:
	lib/activate   : dev_manager.c 

Log message:
	Fix device_is_usable to properly detect only internal LV names.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.188&r2=1.189

--- LVM2/lib/activate/dev_manager.c	2010/05/13 18:38:38	1.188
+++ LVM2/lib/activate/dev_manager.c	2010/05/14 12:03:32	1.189
@@ -133,7 +133,7 @@
 	const char *name, *uuid;
 	uint64_t start, length;
 	char *target_type = NULL;
-	char *params;
+	char *params, *vgname = NULL, *lvname, *layer;
 	void *next = NULL;
 	int r = 0;
 
@@ -175,15 +175,23 @@
 	/* FIXME Also check dependencies? */
 
 	/* Check internal lvm devices */
-	if (is_reserved_lvname(name) && uuid &&
-	    !strncmp(uuid, UUID_PREFIX, sizeof(UUID_PREFIX) - 1)) {
-		log_debug("%s: Reserved internal LVM device not usable.", dev_name(dev));
-		goto out;
+	if (uuid && !strncmp(uuid, UUID_PREFIX, sizeof(UUID_PREFIX) - 1)) {
+		if (!(vgname = dm_strdup(name)) ||
+		    !dm_split_lvm_name(NULL, NULL, &vgname, &lvname, &layer))
+			goto_out;
+
+		if (lvname && (is_reserved_lvname(lvname) || layer)) {
+			log_debug("%s: Reserved internal LV device %s/%s%s%s not usable.",
+				  dev_name(dev), vgname, lvname, layer ? "-" : "",
+				  layer ?: "");
+			goto out;
+		}
 	}
 
 	r = 1;
 
       out:
+	dm_free(vgname);
 	dm_task_destroy(dmt);
 	return r;
 }


