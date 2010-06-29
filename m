From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 29 Jun 2010 22:37:33 -0000
Subject: LVM2/lib format_text/format-text.c metadata/me ...
Message-ID: <20100629223733.9488.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-06-29 22:37:32

Modified files:
	lib/format_text: format-text.c 
	lib/metadata   : metadata.c metadata.h 

Log message:
	Improve logging for metadata ignore by printing device name.
	
	Print device name when setting or clearing metadata ignore bit.
	Example:
	label/label.c:160       /dev/loop2: lvm2 label detected
	cache/lvmcache.c:1136         lvmcache: /dev/loop2: now in VG #orphans_lvm2 (#orphans_lvm2)
	metadata/metadata.c:4142     Setting mda ignored flag for metadata_locn /dev/loop2.
	format_text/text_label.c:318     Skipping mda with ignored flag on device /dev/loop2 at offset 4096

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.c.diff?cvsroot=lvm2&r1=1.135&r2=1.136
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.365&r2=1.366
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.h.diff?cvsroot=lvm2&r1=1.212&r2=1.213

--- LVM2/lib/format_text/format-text.c	2010/06/29 14:52:57	1.135
+++ LVM2/lib/format_text/format-text.c	2010/06/29 22:37:32	1.136
@@ -1639,6 +1639,17 @@
 	return mdac_new;
 }
 
+/*
+ * Return a string description of the metadata location.
+ */
+static const char * _metadata_locn_desc_raw(void *metadata_locn)
+{
+	struct mda_context *mdac;
+
+	mdac = (struct mda_context *) metadata_locn;
+	return dev_name(mdac->area.dev);
+}
+
 
 static int _text_pv_read(const struct format_type *fmt, const char *pv_name,
 		    struct physical_volume *pv, struct dm_list *mdas,
@@ -1732,6 +1743,7 @@
 	.vg_commit = _vg_commit_raw,
 	.vg_revert = _vg_revert_raw,
 	.mda_metadata_locn_copy = _metadata_locn_copy_raw,
+	.mda_metadata_locn_desc = _metadata_locn_desc_raw,
 	.mda_free_sectors = _mda_free_sectors_raw,
 	.mda_total_sectors = _mda_total_sectors_raw,
 	.mda_in_vg = _mda_in_vg_raw,
--- LVM2/lib/metadata/metadata.c	2010/06/29 22:25:58	1.365
+++ LVM2/lib/metadata/metadata.c	2010/06/29 22:37:32	1.366
@@ -4119,15 +4119,23 @@
 
 void mda_set_ignored(struct metadata_area *mda, unsigned ignored)
 {
+	void *locn = mda->metadata_locn;
+
 	if (ignored) {
 		mda->flags |= MDA_IGNORED;
-		log_verbose("Setting mda ignored flag for metadata_locn %p.",
-			mda->metadata_locn);
 	} else {
 		mda->flags &= ~MDA_IGNORED;
-		log_verbose("Clearing mda ignored flag for metadata_locn %p.",
-			mda->metadata_locn);
 	}
+	if (mda->ops->mda_metadata_locn_desc)
+		log_verbose("%s mda ignored flag for "
+			    "metadata_locn %s.",
+			    ignored ? "Setting" : "Clearing",
+			    mda->ops->mda_metadata_locn_desc(locn));
+	else
+		log_verbose("%s mda ignored flag for "
+			    "metadata_locn %p.",
+			    ignored ? "Setting" : "Clearing",
+			    locn);
 }
 
 uint32_t pv_mda_count(const struct physical_volume *pv)
--- LVM2/lib/metadata/metadata.h	2010/06/29 22:25:58	1.212
+++ LVM2/lib/metadata/metadata.h	2010/06/29 22:37:32	1.213
@@ -139,6 +139,10 @@
 	 * Per location copy constructor.
 	 */
 	void *(*mda_metadata_locn_copy) (struct dm_pool *mem, void *metadata_locn);
+	/*
+	 * Per location description - useful for logging.
+	 */
+	const char *(*mda_metadata_locn_desc) (void *metadata_locn);
 
 	/*
 	 * Returns number of free sectors in given metadata area.


