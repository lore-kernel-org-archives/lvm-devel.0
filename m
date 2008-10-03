From: agk@sourceware.org <agk@sourceware.org>
Date: 3 Oct 2008 14:22:18 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/metadata.c lib/d ...
Message-ID: <20081003142218.19858.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-10-03 14:22:18

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : metadata.c 
	lib/device     : dev-md.c 

Log message:
	Fix conversion of md chunk size into sectors.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.970&r2=1.971
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.193&r2=1.194
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/device/dev-md.c.diff?cvsroot=lvm2&r1=1.12&r2=1.13

--- LVM2/WHATS_NEW	2008/10/01 22:48:26	1.970
+++ LVM2/WHATS_NEW	2008/10/03 14:22:17	1.971
@@ -1,7 +1,8 @@
 Version 2.02.41 -
 =====================================
+  Fix conversion of md chunk size into sectors.
   Free text metadata buffer after a failure writing it.
-  Fix misleading error message when there is no allocatable extents in VG.
+  Fix misleading error message when there are no allocatable extents in VG.
   Fix handling of PVs which reappeared with old metadata version.
   Fix mirror DSO to call vgreduce with proper parameters.
   Fix validation of --minor and --major in lvcreate to require -My always.
--- LVM2/lib/metadata/metadata.c	2008/09/25 15:59:10	1.193
+++ LVM2/lib/metadata/metadata.c	2008/10/03 14:22:18	1.194
@@ -75,13 +75,18 @@
 	/*
 	 * Align to chunk size of underlying md device if present
 	 */
-	if (pv->dev &&
-	    find_config_tree_bool(pv->fmt->cmd, "devices/md_chunk_alignment",
+	if (!pv->dev)
+		goto out;
+
+	if (find_config_tree_bool(pv->fmt->cmd, "devices/md_chunk_alignment",
 				  DEFAULT_MD_CHUNK_ALIGNMENT))
 		pv->pe_align = MAX(pv->pe_align,
 				   dev_md_chunk_size(pv->fmt->cmd->sysfs_dir,
 						     pv->dev));
 
+	log_very_verbose("%s: Setting PE alignment to %lu sectors.",
+			 dev_name(pv->dev), pv->pe_align);
+
 out:
 	return pv->pe_align;
 }
--- LVM2/lib/device/dev-md.c	2008/09/19 07:18:03	1.12
+++ LVM2/lib/device/dev-md.c	2008/10/03 14:22:18	1.13
@@ -133,7 +133,7 @@
 	char path[PATH_MAX+1], buffer[64];
 	FILE *fp;
 	struct stat info;
-	unsigned long chunk_size = 0UL;
+	unsigned long chunk_size_bytes = 0UL;
 
 	if (MAJOR(dev->dev) != md_major())
 		return 0;
@@ -165,20 +165,20 @@
 		goto out;
 	}
 
-	if (sscanf(buffer, "%lu", &chunk_size) != 1) {
+	if (sscanf(buffer, "%lu", &chunk_size_bytes) != 1) {
 		log_error("sysfs file %s not in expected format: %s", path,
 			  buffer);
 		goto out;
 	}
 
-	log_very_verbose("Found chunksize %lu for md device %s.", chunk_size,
-			 dev_name(dev));
+	log_very_verbose("Device %s md chunk size is %lu bytes.",
+			 dev_name(dev), chunk_size_bytes);
 
 out:
 	if (fclose(fp))
 		log_sys_error("fclose", path);
 
-	return chunk_size;
+	return chunk_size_bytes >> SECTOR_SHIFT;
 }
 
 #else


