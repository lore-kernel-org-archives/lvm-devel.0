From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 26 Jul 2009 02:02:23 -0000
Subject: LVM2/lib/metadata metadata-exported.h metadata.c
Message-ID: <20090726020223.9205.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-26 02:02:22

Modified files:
	lib/metadata   : metadata-exported.h metadata.c 

Log message:
	Remove use of void * from pvcreate_single.
	
	We should use struct pvcreate_params to utilize compiler typechecking.
	
	Author: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.98&r2=1.99
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.265&r2=1.266

--- LVM2/lib/metadata/metadata-exported.h	2009/07/26 01:53:57	1.98
+++ LVM2/lib/metadata/metadata-exported.h	2009/07/26 02:02:22	1.99
@@ -355,7 +355,7 @@
 };
 
 pv_t * pvcreate_single(struct cmd_context *cmd, const char *pv_name,
-		       void *handle);
+		       struct pvcreate_params *pp);
 
 /*
 * Utility functions
--- LVM2/lib/metadata/metadata.c	2009/07/26 01:54:20	1.265
+++ LVM2/lib/metadata/metadata.c	2009/07/26 02:02:22	1.266
@@ -1119,19 +1119,16 @@
  * pv_t * (non-NULL): handle to physical volume created
  */
 pv_t * pvcreate_single(struct cmd_context *cmd, const char *pv_name,
-		       void *handle)
+		       struct pvcreate_params *pp)
 {
-	struct pvcreate_params *pp;
 	void *pv;
 	struct device *dev;
 	struct dm_list mdas;
 	struct pvcreate_params default_pp;
 
 	fill_default_pvcreate_params(&default_pp);
-	if (!handle)
+	if (!pp)
 		pp = &default_pp;
-	else
-		pp = (struct pvcreate_params *) handle;
 
 	if (pp->idp) {
 		if ((dev = device_from_pvid(cmd, pp->idp)) &&


