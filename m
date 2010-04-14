From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 14 Apr 2010 13:09:19 -0000
Subject: LVM2 ./WHATS_NEW lib/format_text/archiver.c li ...
Message-ID: <20100414130919.17802.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2010-04-14 13:09:17

Modified files:
	.              : WHATS_NEW 
	lib/format_text: archiver.c format-text.c 
	lib/metadata   : metadata-exported.h metadata.c 

Log message:
	Do not reset position in metadata ring buffer on vgrename and vgcfgrestore.
	
	We should write metadata into next position in the ring buffer while calling
	vgrename and vgcfgrestore. At this code level (_vg_write_raw), we were not able
	to determine if this is a rename or not. If yes, then accompanying VG structure
	passed here has a new name set, not the old one.
	
	When looking for a location where to put metadata next, we were given a NULL
	value because of failed VG name comparison (in _find_vg_rlocn) between the
	name in existing metadata and metadata we're just about to write.
	
	This resets the position in the ring buffer, overwriting any existing metadata
	(and also incorrectly updates the cache to "orphan" afterwards).
	
	This patch just adds old_name item in struct volume_group that we can check and use
	if necessary and detect renames at lower layers as well.
	
	The same applies for vgcfgrestore, but here we're using a special value of
	old_name, an empty string, to disable the check with existing metadata totally.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1519&r2=1.1520
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/archiver.c.diff?cvsroot=lvm2&r1=1.29&r2=1.30
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.c.diff?cvsroot=lvm2&r1=1.120&r2=1.121
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.141&r2=1.142
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.336&r2=1.337

--- LVM2/WHATS_NEW	2010/04/14 13:03:06	1.1519
+++ LVM2/WHATS_NEW	2010/04/14 13:09:16	1.1520
@@ -1,5 +1,6 @@
 Version 2.02.63 -  
 ================================
+  Do not reset position in metadata ring buffer on vgrename and vgcfgrestore.
   Allow VGs with active LVs to be renamed.
   Use UUIDs instead of names while processing event handlers.
   Only pass visible LVs to tools in cmdline VG name/tag expansions without -a.
--- LVM2/lib/format_text/archiver.c	2009/09/14 19:44:16	1.29
+++ LVM2/lib/format_text/archiver.c	2010/04/14 13:09:16	1.30
@@ -306,6 +306,12 @@
 		return 0;
 	}
 
+	/*
+	 * Setting vg->old_name to a blank value will explicitly
+	 * disable any attempt to check VG name in existing metadata.
+	*/
+	vg->old_name = dm_pool_strdup(vg->vgmem, "");
+
 	/* Add any metadata areas on the PVs */
 	dm_list_iterate_items(pvl, &vg->pvs) {
 		pv = pvl->pv;
--- LVM2/lib/format_text/format-text.c	2010/03/16 17:30:01	1.120
+++ LVM2/lib/format_text/format-text.c	2010/04/14 13:09:16	1.121
@@ -380,6 +380,17 @@
 	} else
 		*precommitted = 0;
 
+	/* Do not check non-existent metadata. */
+	if (!rlocn->offset && !rlocn->size)
+		return NULL;
+
+	/*
+	 * Don't try to check existing metadata
+	 * if given vgname is an empty string.
+	 */
+	if (!*vgname)
+		return rlocn;
+
 	/* FIXME Loop through rlocns two-at-a-time.  List null-terminated. */
 	/* FIXME Ignore if checksum incorrect!!! */
 	if (!dev_read(dev_area->dev, dev_area->start + rlocn->offset,
@@ -387,9 +398,11 @@
 		goto_bad;
 
 	if (!strncmp(vgnamebuf, vgname, len = strlen(vgname)) &&
-	    (isspace(vgnamebuf[len]) || vgnamebuf[len] == '{')) {
+	    (isspace(vgnamebuf[len]) || vgnamebuf[len] == '{'))
 		return rlocn;
-	}
+	else
+		log_debug("Volume group name found in metadata does "
+			  "not match expected name %s.", vgname);
 
       bad:
 	if ((info = info_from_pvid(dev_area->dev->pvid, 0)))
@@ -542,7 +555,8 @@
 	if (!(mdah = _raw_read_mda_header(fid->fmt, &mdac->area)))
 		goto_out;
 
-	rlocn = _find_vg_rlocn(&mdac->area, mdah, vg->name, &noprecommit);
+	rlocn = _find_vg_rlocn(&mdac->area, mdah,
+			vg->old_name ? vg->old_name : vg->name, &noprecommit);
 	mdac->rlocn.offset = _next_rlocn_offset(rlocn, mdah);
 
 	if (!fidtc->raw_metadata_buf &&
@@ -647,7 +661,9 @@
 	if (!(mdah = _raw_read_mda_header(fid->fmt, &mdac->area)))
 		goto_out;
 
-	if (!(rlocn = _find_vg_rlocn(&mdac->area, mdah, vg->name, &noprecommit))) {
+	if (!(rlocn = _find_vg_rlocn(&mdac->area, mdah,
+				     vg->old_name ? vg->old_name : vg->name,
+				     &noprecommit))) {
 		mdah->raw_locns[0].offset = 0;
 		mdah->raw_locns[0].size = 0;
 		mdah->raw_locns[0].checksum = 0;
--- LVM2/lib/metadata/metadata-exported.h	2010/04/13 17:26:36	1.141
+++ LVM2/lib/metadata/metadata-exported.h	2010/04/14 13:09:17	1.142
@@ -227,6 +227,7 @@
 
 	struct id id;
 	char *name;
+	char *old_name;		/* Set during vgrename and vgcfgrestore */
 	char *system_id;
 
 	uint32_t extent_size;
--- LVM2/lib/metadata/metadata.c	2010/04/13 17:26:36	1.336
+++ LVM2/lib/metadata/metadata.c	2010/04/14 13:09:17	1.337
@@ -457,6 +457,8 @@
 	struct dm_pool *mem = vg->vgmem;
 	struct pv_list *pvl;
 
+	vg->old_name = vg->name;
+
 	if (!(vg->name = dm_pool_strdup(mem, new_name))) {
 		log_error("vg->name allocation failed for '%s'", new_name);
 		return 0;
@@ -2428,11 +2430,15 @@
 		}
 	}
 
-	/*
-	 * Instruct remote nodes to upgrade cached metadata.
-	 */
-	if (cache_updated)
+	if (cache_updated) {
+		/* Instruct remote nodes to upgrade cached metadata. */
 		remote_commit_cached_metadata(vg);
+		/*
+		 * We need to clear old_name after a successful commit.
+		 * The volume_group structure could be reused later.
+		 */
+		vg->old_name = NULL;
+	}
 
 	/* If update failed, remove any cached precommitted metadata. */
 	if (!cache_updated && !drop_cached_metadata(vg))


