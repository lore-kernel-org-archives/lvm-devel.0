From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 29 Jun 2010 13:29:54 -0000
Subject: LVM2/lib/format_text format-text.c
Message-ID: <20100629132954.3839.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-06-29 13:29:53

Modified files:
	lib/format_text: format-text.c 

Log message:
	Attempt to fix intermittent failure with non-debug configured vgcfgbackup.
	
	There's an intermittent failure with vgcfgbackup that seems to have been
	introduced with the metadataignore / vgmetadatacopies patchset.
	Intermittent failures are often the result of uninitialized data,
	so this patch calls zalloc in a few places it might matter.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.c.diff?cvsroot=lvm2&r1=1.133&r2=1.134

--- LVM2/lib/format_text/format-text.c	2010/06/28 20:35:17	1.133
+++ LVM2/lib/format_text/format-text.c	2010/06/29 13:29:53	1.134
@@ -1919,7 +1919,7 @@
 	dm_list_init(&fid->metadata_areas_ignored);
 
 	if (!vgname) {
-		if (!(mda = dm_pool_alloc(fmt->cmd->mem, sizeof(*mda))))
+		if (!(mda = dm_pool_zalloc(fmt->cmd->mem, sizeof(*mda))))
 			return_NULL;
 		mda->ops = &_metadata_text_file_backup_ops;
 		mda->metadata_locn = context;
@@ -1936,7 +1936,7 @@
 			}
 
 			context = create_text_context(fmt->cmd, path, NULL);
-			if (!(mda = dm_pool_alloc(fmt->cmd->mem, sizeof(*mda))))
+			if (!(mda = dm_pool_zalloc(fmt->cmd->mem, sizeof(*mda))))
 				return_NULL;
 			mda->ops = &_metadata_text_file_ops;
 			mda->metadata_locn = context;
@@ -1950,10 +1950,10 @@
 			if (!_raw_holds_vgname(fid, &rl->dev_area, vgname))
 				continue;
 
-			if (!(mda = dm_pool_alloc(fmt->cmd->mem, sizeof(*mda))))
+			if (!(mda = dm_pool_zalloc(fmt->cmd->mem, sizeof(*mda))))
 				return_NULL;
 
-			if (!(mdac = dm_pool_alloc(fmt->cmd->mem, sizeof(*mdac))))
+			if (!(mdac = dm_pool_zalloc(fmt->cmd->mem, sizeof(*mdac))))
 				return_NULL;
 			mda->metadata_locn = mdac;
 			/* FIXME Allow multiple dev_areas inside area */


