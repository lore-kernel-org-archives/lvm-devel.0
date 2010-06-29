From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 29 Jun 2010 22:25:59 -0000
Subject: LVM2/lib format_text/text_label.c metadata/met ...
Message-ID: <20100629222559.29966.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-06-29 22:25:58

Modified files:
	lib/format_text: text_label.c 
	lib/metadata   : metadata.c metadata.h 

Log message:
	Add some log_verbose debug statements related to metadataignore.
	
	Logging isn't ideal, especially for mda_set_ignore.  Ideally we'd
	like to display the device name and offset in this case but this
	requires a bit more work and a per-format 'mda_description' function
	pointer definition (we don't have access to mda_context in
	metadata.c).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/text_label.c.diff?cvsroot=lvm2&r1=1.32&r2=1.33
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.364&r2=1.365
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.h.diff?cvsroot=lvm2&r1=1.211&r2=1.212

--- LVM2/lib/format_text/text_label.c	2010/06/28 20:34:24	1.32
+++ LVM2/lib/format_text/text_label.c	2010/06/29 22:25:58	1.33
@@ -312,6 +312,10 @@
 		mda_set_ignored(mda, rlocn_is_ignored(mdah->raw_locns));
 
 		if (mda_is_ignored(mda)) {
+			log_verbose("Skipping mda with ignored flag on "
+				    "device %s at offset %"PRIu64,
+				    dev_name(mdac->area.dev),
+				    mdac->area.start);
 			if (!dev_close(mdac->area.dev))
 				stack;
 			continue;
--- LVM2/lib/metadata/metadata.c	2010/06/29 21:32:44	1.364
+++ LVM2/lib/metadata/metadata.c	2010/06/29 22:25:58	1.365
@@ -4117,12 +4117,17 @@
 	return (mda->flags & MDA_IGNORED);
 }
 
-void mda_set_ignored(struct metadata_area *mda, int value)
+void mda_set_ignored(struct metadata_area *mda, unsigned ignored)
 {
-	if (value)
+	if (ignored) {
 		mda->flags |= MDA_IGNORED;
-	else
+		log_verbose("Setting mda ignored flag for metadata_locn %p.",
+			mda->metadata_locn);
+	} else {
 		mda->flags &= ~MDA_IGNORED;
+		log_verbose("Clearing mda ignored flag for metadata_locn %p.",
+			mda->metadata_locn);
+	}
 }
 
 uint32_t pv_mda_count(const struct physical_volume *pv)
--- LVM2/lib/metadata/metadata.h	2010/06/28 20:34:40	1.211
+++ LVM2/lib/metadata/metadata.h	2010/06/29 22:25:58	1.212
@@ -181,7 +181,7 @@
 			       struct metadata_area *mda);
 
 unsigned mda_is_ignored(struct metadata_area *mda);
-void mda_set_ignored(struct metadata_area *mda, int value);
+void mda_set_ignored(struct metadata_area *mda, unsigned ignored);
 unsigned mda_locns_match(struct metadata_area *mda1, struct metadata_area *mda2);
 void fid_add_mda(struct format_instance *fid, struct metadata_area *mda);
 int fid_add_mdas(struct format_instance *fid, struct dm_list *mdas);


