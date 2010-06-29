From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 29 Jun 2010 14:52:58 -0000
Subject: LVM2/lib format1/format1.c format_pool/format_ ...
Message-ID: <20100629145258.26298.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-06-29 14:52:57

Modified files:
	lib/format1    : format1.c 
	lib/format_pool: format_pool.c 
	lib/format_text: format-text.c 

Log message:
	Add more initializations of 'mda->flags' field.
	
	Mda allocation needs refactored into a single function but as an
	interim step, ensure mda->flags is initialized properly.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/format1.c.diff?cvsroot=lvm2&r1=1.118&r2=1.119
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_pool/format_pool.c.diff?cvsroot=lvm2&r1=1.29&r2=1.30
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.c.diff?cvsroot=lvm2&r1=1.134&r2=1.135

--- LVM2/lib/format1/format1.c	2010/06/28 20:33:22	1.118
+++ LVM2/lib/format1/format1.c	2010/06/29 14:52:56	1.119
@@ -467,13 +467,14 @@
 	dm_list_init(&fid->metadata_areas_ignored);
 
 	/* Define a NULL metadata area */
-	if (!(mda = dm_pool_alloc(fmt->cmd->mem, sizeof(*mda)))) {
+	if (!(mda = dm_pool_zalloc(fmt->cmd->mem, sizeof(*mda)))) {
 		dm_pool_free(fmt->cmd->mem, fid);
 		return_NULL;
 	}
 
 	mda->ops = &_metadata_format1_ops;
 	mda->metadata_locn = NULL;
+	mda->flags = 0;
 	dm_list_add(&fid->metadata_areas_in_use, &mda->list);
 
 	return fid;
--- LVM2/lib/format_pool/format_pool.c	2010/06/28 20:33:23	1.29
+++ LVM2/lib/format_pool/format_pool.c	2010/06/29 14:52:56	1.30
@@ -275,6 +275,7 @@
 
 	mda->ops = &_metadata_format_pool_ops;
 	mda->metadata_locn = NULL;
+	mda->flags = 0;
 	dm_list_add(&fid->metadata_areas_in_use, &mda->list);
 
 	return fid;
--- LVM2/lib/format_text/format-text.c	2010/06/29 13:29:53	1.134
+++ LVM2/lib/format_text/format-text.c	2010/06/29 14:52:57	1.135
@@ -1923,6 +1923,7 @@
 			return_NULL;
 		mda->ops = &_metadata_text_file_backup_ops;
 		mda->metadata_locn = context;
+		mda->flags = 0;
 		fid_add_mda(fid, mda);
 	} else {
 		dir_list = &((struct mda_lists *) fmt->private)->dirs;
@@ -1940,6 +1941,7 @@
 				return_NULL;
 			mda->ops = &_metadata_text_file_ops;
 			mda->metadata_locn = context;
+			mda->flags = 0;
 			fid_add_mda(fid, mda);
 		}
 
@@ -1959,6 +1961,7 @@
 			/* FIXME Allow multiple dev_areas inside area */
 			memcpy(&mdac->area, &rl->dev_area, sizeof(mdac->area));
 			mda->ops = &_metadata_text_raw_ops;
+			mda->flags = 0;
 			/* FIXME MISTAKE? mda->metadata_locn = context; */
 			fid_add_mda(fid, mda);
 		}


