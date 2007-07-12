From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 12 Jul 2007 04:12:04 -0000
Subject: LVM2/lib/metadata metadata.c
Message-ID: <20070712041204.18616.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2007-07-12 04:12:04

Modified files:
	lib/metadata   : metadata.c 

Log message:
	Refactor vg_extend error path.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.124&r2=1.125

--- LVM2/lib/metadata/metadata.c	2007/07/11 23:33:12	1.124
+++ LVM2/lib/metadata/metadata.c	2007/07/12 04:12:04	1.125
@@ -249,15 +249,17 @@
 
 	/* attach each pv */
 	for (i = 0; i < pv_count; i++)
-		if (!_add_pv_to_vg(vg, pv_names[i])) {
-			log_error("Unable to add physical volume '%s' to "
-				  "volume group '%s'.", pv_names[i], vg->name);
-			return 0;
-		}
+		if (!_add_pv_to_vg(vg, pv_names[i]))
+			goto bad;
 
 /* FIXME Decide whether to initialise and add new mdahs to format instance */
 
 	return 1;
+	
+      bad:
+	log_error("Unable to add physical volume '%s' to "
+		  "volume group '%s'.", pv_names[i], vg->name);
+	return 0;
 }
 
 const char *strip_dir(const char *vg_name, const char *dev_dir)


