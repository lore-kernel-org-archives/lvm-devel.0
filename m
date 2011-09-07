From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 7 Sep 2011 08:34:23 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/metadata-exporte ...
Message-ID: <20110907083423.20624.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-09-07 08:34:22

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : metadata-exported.h metadata.c 

Log message:
	Minor change for pv_create api
	
	Switch int to unsigned type.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2095&r2=1.2096
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.207&r2=1.208
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.466&r2=1.467

--- LVM2/WHATS_NEW	2011/09/07 08:31:16	1.2095
+++ LVM2/WHATS_NEW	2011/09/07 08:34:21	1.2096
@@ -1,5 +1,6 @@
 Version 2.02.89 - 
 ==================================
+  Switch int to unsigned type for pvmetadatacopies for pv_create().
   Replace :space: with [\t ] for awk in vgimportclone (not widely supported).
   Begin using 64-bit status field flags.
   Detect sscanf recovering_region input error in cmirrord pull_state().
--- LVM2/lib/metadata/metadata-exported.h	2011/09/06 22:43:57	1.207
+++ LVM2/lib/metadata/metadata-exported.h	2011/09/07 08:34:22	1.208
@@ -455,7 +455,7 @@
 				  uint32_t existing_extent_count,
 				  uint32_t existing_extent_size,
 				  uint64_t label_sector,
-				  int pvmetadatacopies,
+				  unsigned pvmetadatacopies,
 				  uint64_t pvmetadatasize,
 				  unsigned metadataignore);
 int pv_resize(struct physical_volume *pv, struct volume_group *vg,
--- LVM2/lib/metadata/metadata.c	2011/08/30 14:55:17	1.466
+++ LVM2/lib/metadata/metadata.c	2011/09/07 08:34:22	1.467
@@ -1621,7 +1621,7 @@
 				  uint32_t existing_extent_count,
 				  uint32_t existing_extent_size,
 				  uint64_t label_sector,
-				  int pvmetadatacopies,
+				  unsigned pvmetadatacopies,
 				  uint64_t pvmetadatasize,
 				  unsigned metadataignore)
 {


