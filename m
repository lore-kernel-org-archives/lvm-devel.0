From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 5 Oct 2010 17:34:08 -0000
Subject: LVM2 ./WHATS_NEW lib/format1/format1.c lib/for ...
Message-ID: <20101005173408.13885.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-10-05 17:34:07

Modified files:
	.              : WHATS_NEW 
	lib/format1    : format1.c 
	lib/format_pool: format_pool.c 
	lib/format_text: format-text.c text_label.c 
	lib/metadata   : metadata.c metadata.h 

Log message:
	Rename 'flags' to 'status' for struct metadata_area.
	
	In other LVM memory structures such as volume_group, the field
	used to store flags is called "status", and on-disk fields are called
	'flags', so rename the one inside metadata_area to be consistent.
	Not only is it more consistent with existing code but is cleaner
	to say "the status of this mda is ignored".
	
	Background for this patch - prajnoha pinged me on IRC this morning
	about a fix he was working on related to metadataignore when
	metadata/dirs was set.  I was reviewing my patches from this year
	and realized the 'flags' field was probably not the best choice
	when I originally did the metadataignore patches.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1745&r2=1.1746
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/format1.c.diff?cvsroot=lvm2&r1=1.124&r2=1.125
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_pool/format_pool.c.diff?cvsroot=lvm2&r1=1.32&r2=1.33
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.c.diff?cvsroot=lvm2&r1=1.146&r2=1.147
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/text_label.c.diff?cvsroot=lvm2&r1=1.37&r2=1.38
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.403&r2=1.404
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.h.diff?cvsroot=lvm2&r1=1.222&r2=1.223

--- LVM2/WHATS_NEW	2010/10/04 18:59:01	1.1745
+++ LVM2/WHATS_NEW	2010/10/05 17:34:05	1.1746
@@ -1,5 +1,6 @@
 Version 2.02.75 - 
 =====================================
+  Rename 'flags' to 'status' in struct metadata_area.
   Avoid segfault by limiting partial mode for lvm1 metadata. (2.02.74)
   Add dm_zalloc and use it and dm_pool_zalloc throughout.
   Add pv_get_property and create generic internal _get_property function.
--- LVM2/lib/format1/format1.c	2010/10/04 18:59:02	1.124
+++ LVM2/lib/format1/format1.c	2010/10/05 17:34:06	1.125
@@ -545,7 +545,7 @@
 
 	mda->ops = &_metadata_format1_ops;
 	mda->metadata_locn = NULL;
-	mda->flags = 0;
+	mda->status = 0;
 	dm_list_add(&fid->metadata_areas_in_use, &mda->list);
 
 	return fid;
--- LVM2/lib/format_pool/format_pool.c	2010/07/09 15:34:44	1.32
+++ LVM2/lib/format_pool/format_pool.c	2010/10/05 17:34:06	1.33
@@ -276,7 +276,7 @@
 
 	mda->ops = &_metadata_format_pool_ops;
 	mda->metadata_locn = NULL;
-	mda->flags = 0;
+	mda->status = 0;
 	dm_list_add(&fid->metadata_areas_in_use, &mda->list);
 
 	return fid;
--- LVM2/lib/format_text/format-text.c	2010/09/30 14:12:14	1.146
+++ LVM2/lib/format_text/format-text.c	2010/10/05 17:34:06	1.147
@@ -1947,7 +1947,7 @@
 			return_NULL;
 		mda->ops = &_metadata_text_file_backup_ops;
 		mda->metadata_locn = context;
-		mda->flags = 0;
+		mda->status = 0;
 		fid_add_mda(fid, mda);
 	} else {
 		dir_list = &((struct mda_lists *) fmt->private)->dirs;
@@ -1965,7 +1965,7 @@
 				return_NULL;
 			mda->ops = &_metadata_text_file_ops;
 			mda->metadata_locn = context;
-			mda->flags = 0;
+			mda->status = 0;
 			fid_add_mda(fid, mda);
 		}
 
@@ -1985,7 +1985,7 @@
 			/* FIXME Allow multiple dev_areas inside area */
 			memcpy(&mdac->area, &rl->dev_area, sizeof(mdac->area));
 			mda->ops = &_metadata_text_raw_ops;
-			mda->flags = 0;
+			mda->status = 0;
 			/* FIXME MISTAKE? mda->metadata_locn = context; */
 			fid_add_mda(fid, mda);
 		}
--- LVM2/lib/format_text/text_label.c	2010/07/09 15:34:44	1.37
+++ LVM2/lib/format_text/text_label.c	2010/10/05 17:34:06	1.38
@@ -216,7 +216,7 @@
 
 	mdal->ops = mda_lists->raw_ops;
 	mdal->metadata_locn = mdac;
-	mdal->flags = 0;
+	mdal->status = 0;
 
 	mdac->area.dev = dev;
 	mdac->area.start = start;
--- LVM2/lib/metadata/metadata.c	2010/09/30 20:47:18	1.403
+++ LVM2/lib/metadata/metadata.c	2010/10/05 17:34:06	1.404
@@ -3839,7 +3839,7 @@
 
 unsigned mda_is_ignored(struct metadata_area *mda)
 {
-	return (mda->flags & MDA_IGNORED);
+	return (mda->status & MDA_IGNORED);
 }
 
 void mda_set_ignored(struct metadata_area *mda, unsigned mda_ignored)
@@ -3848,9 +3848,9 @@
 	unsigned old_mda_ignored = mda_is_ignored(mda);
 
 	if (mda_ignored && !old_mda_ignored)
-		mda->flags |= MDA_IGNORED;
+		mda->status |= MDA_IGNORED;
 	else if (!mda_ignored && old_mda_ignored)
-		mda->flags &= ~MDA_IGNORED;
+		mda->status &= ~MDA_IGNORED;
 	else
 		return;	/* No change */
 
--- LVM2/lib/metadata/metadata.h	2010/09/30 20:47:18	1.222
+++ LVM2/lib/metadata/metadata.h	2010/10/05 17:34:07	1.223
@@ -182,7 +182,7 @@
 	struct dm_list list;
 	struct metadata_area_ops *ops;
 	void *metadata_locn;
-	uint32_t flags;
+	uint32_t status;
 };
 struct metadata_area *mda_copy(struct dm_pool *mem,
 			       struct metadata_area *mda);


