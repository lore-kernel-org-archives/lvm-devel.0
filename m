From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 24 Jun 2008 20:10:32 -0000
Subject: LVM2 lib/metadata/metadata-exported.h lib/meta ...
Message-ID: <20080624201032.9501.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2008-06-24 20:10:32

Modified files:
	lib/metadata   : metadata-exported.h metadata.c 
	tools          : pvcreate.c vgconvert.c 

Log message:
	Refactor pv_create() to take cmd_context - no functional change.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.48&r2=1.49
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.182&r2=1.183
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvcreate.c.diff?cvsroot=lvm2&r1=1.62&r2=1.63
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgconvert.c.diff?cvsroot=lvm2&r1=1.27&r2=1.28

--- LVM2/lib/metadata/metadata-exported.h	2008/04/23 14:33:05	1.48
+++ LVM2/lib/metadata/metadata-exported.h	2008/06/24 20:10:31	1.49
@@ -347,7 +347,7 @@
 
 /* pe_start and pe_end relate to any existing data so that new metadata
 * areas can avoid overlap */
-pv_t *pv_create(const struct format_type *fmt,
+pv_t *pv_create(const struct cmd_context *cmd,
 		      struct device *dev,
 		      struct id *id,
 		      uint64_t size,
--- LVM2/lib/metadata/metadata.c	2008/06/23 19:04:34	1.182
+++ LVM2/lib/metadata/metadata.c	2008/06/24 20:10:31	1.183
@@ -747,7 +747,7 @@
  * Note:
  *   FIXME - liblvm todo - tidy up arguments for external use (fmt, mdas, etc)
  */
-pv_t *pv_create(const struct format_type *fmt,
+pv_t *pv_create(const struct cmd_context *cmd,
 		struct device *dev,
 		struct id *id, uint64_t size,
 		uint64_t pe_start,
@@ -756,7 +756,7 @@
 		int pvmetadatacopies,
 		uint64_t pvmetadatasize, struct list *mdas)
 {
-	return _pv_create(fmt, dev, id, size, pe_start,
+	return _pv_create(cmd->fmt, dev, id, size, pe_start,
 			  existing_extent_count,
 			  existing_extent_size,
 			  pvmetadatacopies,
--- LVM2/tools/pvcreate.c	2008/04/08 12:49:21	1.62
+++ LVM2/tools/pvcreate.c	2008/06/24 20:10:32	1.63
@@ -225,7 +225,7 @@
 	}
 
 	list_init(&mdas);
-	if (!(pv = pv_create(cmd->fmt, dev, idp, size, pe_start,
+	if (!(pv = pv_create(cmd, dev, idp, size, pe_start,
 			     extent_count, extent_size,
 			     pvmetadatacopies, pvmetadatasize, &mdas))) {
 		log_error("Failed to setup physical volume \"%s\"", pv_name);
--- LVM2/tools/vgconvert.c	2007/11/14 00:08:25	1.27
+++ LVM2/tools/vgconvert.c	2008/06/24 20:10:32	1.28
@@ -112,7 +112,7 @@
 		    + pe_start - 1;
 
 		list_init(&mdas);
-		if (!(pv = pv_create(cmd->fmt, pv_dev(existing_pv),
+		if (!(pv = pv_create(cmd, pv_dev(existing_pv),
 				     &existing_pv->id, size,
 				     pe_start, pv_pe_count(existing_pv),
 				     pv_pe_size(existing_pv), pvmetadatacopies,


