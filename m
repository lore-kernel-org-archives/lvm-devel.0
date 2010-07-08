From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 8 Jul 2010 18:24:31 -0000
Subject: LVM2 lib/format1/format1.c lib/format_pool/for ...
Message-ID: <20100708182431.7914.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-07-08 18:24:30

Modified files:
	lib/format1    : format1.c 
	lib/format_pool: format_pool.c 
	lib/format_text: archiver.c format-text.c 
	lib/metadata   : metadata-exported.h metadata.c metadata.h 
	tools          : vgconvert.c 

Log message:
	Pass metadataignore to pv_create, pv_setup, _mda_setup, and add_mda.
	
	Pass metadataignore through PV creation / setup paths.
	As a result of this cleanup, we can remove the unnecessary setting
	of mda_ignore bits inside pvcreate_single(), after call to pv_create.
	For now, just set metadataignore to '0' in some places.  This is
	equivalent to the prior functionality, although the 0 is given
	by the caller not hardcoded in _mda_setup() call.
	
	Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/format1.c.diff?cvsroot=lvm2&r1=1.119&r2=1.120
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_pool/format_pool.c.diff?cvsroot=lvm2&r1=1.30&r2=1.31
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/archiver.c.diff?cvsroot=lvm2&r1=1.32&r2=1.33
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.c.diff?cvsroot=lvm2&r1=1.139&r2=1.140
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.164&r2=1.165
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.386&r2=1.387
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.h.diff?cvsroot=lvm2&r1=1.215&r2=1.216
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgconvert.c.diff?cvsroot=lvm2&r1=1.41&r2=1.42

--- LVM2/lib/format1/format1.c	2010/06/29 14:52:56	1.119
+++ LVM2/lib/format1/format1.c	2010/07/08 18:24:29	1.120
@@ -294,13 +294,15 @@
 }
 
 static int _format1_pv_setup(const struct format_type *fmt,
-		     uint64_t pe_start, uint32_t extent_count,
-		     uint32_t extent_size,
-		     unsigned long data_alignment __attribute((unused)),
-		     unsigned long data_alignment_offset __attribute((unused)),
-		     int pvmetadatacopies __attribute((unused)),
-		     uint64_t pvmetadatasize __attribute((unused)), struct dm_list *mdas __attribute((unused)),
-		     struct physical_volume *pv, struct volume_group *vg __attribute((unused)))
+			     uint64_t pe_start, uint32_t extent_count,
+			     uint32_t extent_size,
+			     unsigned long data_alignment __attribute((unused)),
+			     unsigned long data_alignment_offset __attribute((unused)),
+			     int pvmetadatacopies __attribute((unused)),
+			     uint64_t pvmetadatasize __attribute((unused)),
+			     unsigned metadataignore __attribute((unused)),
+			     struct dm_list *mdas __attribute((unused)),
+			     struct physical_volume *pv, struct volume_group *vg __attribute((unused)))
 {
 	if (pv->size > MAX_PV_SIZE)
 		pv->size--;
--- LVM2/lib/format_pool/format_pool.c	2010/06/29 14:52:56	1.30
+++ LVM2/lib/format_pool/format_pool.c	2010/07/08 18:24:29	1.31
@@ -196,6 +196,7 @@
 			  unsigned long data_alignment_offset __attribute((unused)),
 			  int pvmetadatacopies __attribute((unused)),
 			  uint64_t pvmetadatasize __attribute((unused)),
+			  unsigned metadataignore __attribute((unused)),
 			  struct dm_list *mdas __attribute((unused)),
 			  struct physical_volume *pv __attribute((unused)),
 			  struct volume_group *vg __attribute((unused)))
--- LVM2/lib/format_text/archiver.c	2010/06/29 15:03:59	1.32
+++ LVM2/lib/format_text/archiver.c	2010/07/08 18:24:29	1.33
@@ -327,7 +327,8 @@
 		}
 		if (!vg->fid->fmt->ops->
 		    pv_setup(vg->fid->fmt, UINT64_C(0), 0, 0, 0, 0, 0UL,
-			     UINT64_C(0), &vg->fid->metadata_areas_in_use, pv, vg)) {
+			     UINT64_C(0), 0,
+			     &vg->fid->metadata_areas_in_use, pv, vg)) {
 			log_error("Format-specific setup for %s failed",
 				  pv_dev_name(pv));
 			return 0;
--- LVM2/lib/format_text/format-text.c	2010/06/30 17:13:05	1.139
+++ LVM2/lib/format_text/format-text.c	2010/07/08 18:24:30	1.140
@@ -1248,8 +1248,8 @@
    Always have an mda between end-of-label and pe_align() boundary */
 static int _mda_setup(const struct format_type *fmt,
 		      uint64_t pe_start, uint64_t pe_end,
-		      int pvmetadatacopies,
-		      uint64_t pvmetadatasize, struct dm_list *mdas,
+		      int pvmetadatacopies, uint64_t pvmetadatasize,
+		      unsigned metadataignore, struct dm_list *mdas,
 		      struct physical_volume *pv,
 		      struct volume_group *vg __attribute((unused)))
 {
@@ -1337,7 +1337,7 @@
 	/* FIXME If creating new mdas, wipe them! */
 	if (mda_size1) {
 		if (!add_mda(fmt, fmt->cmd->mem, mdas, pv->dev, start1,
-			     mda_size1, 0))
+			     mda_size1, metadataignore))
 			return 0;
 
 		if (!dev_set((struct device *) pv->dev, start1,
@@ -1384,7 +1384,7 @@
 
 	if (mda_size2) {
 		if (!add_mda(fmt, fmt->cmd->mem, mdas, pv->dev, start2,
-			     mda_size2, 0)) return 0;
+			     mda_size2, metadataignore)) return 0;
 		if (!dev_set(pv->dev, start2,
 			     (size_t) (mda_size1 >
 				       wipe_size ? : mda_size1), 0)) {
@@ -1766,12 +1766,12 @@
  *   setting of pv->pe_start to .pv_write
  */
 static int _text_pv_setup(const struct format_type *fmt,
-		     uint64_t pe_start, uint32_t extent_count,
-		     uint32_t extent_size, unsigned long data_alignment,
-		     unsigned long data_alignment_offset,
-		     int pvmetadatacopies,
-		     uint64_t pvmetadatasize, struct dm_list *mdas,
-		     struct physical_volume *pv, struct volume_group *vg)
+			  uint64_t pe_start, uint32_t extent_count,
+			  uint32_t extent_size, unsigned long data_alignment,
+			  unsigned long data_alignment_offset,
+			  int pvmetadatacopies, uint64_t pvmetadatasize,
+			  unsigned metadataignore, struct dm_list *mdas,
+			  struct physical_volume *pv, struct volume_group *vg)
 {
 	struct metadata_area *mda, *mda_new, *mda2;
 	struct mda_context *mdac, *mdac2;
@@ -1894,7 +1894,7 @@
 		if (extent_count)
 			pe_end = pe_start + extent_count * extent_size - 1;
 		if (!_mda_setup(fmt, pe_start, pe_end, pvmetadatacopies,
-				pvmetadatasize, mdas, pv, vg))
+				pvmetadatasize, metadataignore,  mdas, pv, vg))
 			return_0;
 	}
 
--- LVM2/lib/metadata/metadata-exported.h	2010/06/30 20:03:52	1.164
+++ LVM2/lib/metadata/metadata-exported.h	2010/07/08 18:24:30	1.165
@@ -522,16 +522,17 @@
 /* pe_start and pe_end relate to any existing data so that new metadata
 * areas can avoid overlap */
 struct physical_volume *pv_create(const struct cmd_context *cmd,
-		      struct device *dev,
-		      struct id *id,
-		      uint64_t size,
-		      unsigned long data_alignment,
-		      unsigned long data_alignment_offset,
-		      uint64_t pe_start,
-		      uint32_t existing_extent_count,
-		      uint32_t existing_extent_size,
-		      int pvmetadatacopies,
-		      uint64_t pvmetadatasize, struct dm_list *mdas);
+				  struct device *dev,
+				  struct id *id,
+				  uint64_t size,
+				  unsigned long data_alignment,
+				  unsigned long data_alignment_offset,
+				  uint64_t pe_start,
+				  uint32_t existing_extent_count,
+				  uint32_t existing_extent_size,
+				  int pvmetadatacopies, uint64_t pvmetadatasize,
+				  unsigned metadataignore,
+				  struct dm_list *mdas);
 int pv_resize(struct physical_volume *pv, struct volume_group *vg,
              uint32_t new_pe_count);
 int pv_analyze(struct cmd_context *cmd, const char *pv_name,
--- LVM2/lib/metadata/metadata.c	2010/07/08 17:41:46	1.386
+++ LVM2/lib/metadata/metadata.c	2010/07/08 18:24:30	1.387
@@ -234,7 +234,7 @@
 
 	if (!fid->fmt->ops->pv_setup(fid->fmt, UINT64_C(0), 0,
 				     vg->extent_size, 0, 0, 0UL, UINT64_C(0),
-				     mdas, pv, vg)) {
+				     0, mdas, pv, vg)) {
 		log_error("Format-specific setup of physical volume '%s' "
 			  "failed.", pv_name);
 		return 0;
@@ -1684,7 +1684,6 @@
 	struct dm_list mdas;
 	struct pvcreate_params default_pp;
 	char buffer[64] __attribute((aligned(8)));
-	struct metadata_area *mda;
 
 	pvcreate_params_set_defaults(&default_pp);
 	if (!pp)
@@ -1718,8 +1717,8 @@
 	if (!(pv = pv_create(cmd, dev, pp->idp, pp->size,
 			     pp->data_alignment, pp->data_alignment_offset,
 			     pp->pe_start, pp->extent_count, pp->extent_size,
-			     pp->pvmetadatacopies,
-			     pp->pvmetadatasize,&mdas))) {
+			     pp->pvmetadatacopies, pp->pvmetadatasize,
+			     pp->metadataignore, &mdas))) {
 		log_error("Failed to setup physical volume \"%s\"", pv_name);
 		goto error;
 	}
@@ -1751,10 +1750,6 @@
 	log_very_verbose("Writing physical volume data to disk \"%s\"",
 			 pv_name);
 
-	if (pp->metadataignore)
-		dm_list_iterate_items(mda, &mdas)
-			mda_set_ignored(mda, 1);
-
 	if (!(pv_write(cmd, pv, &mdas, pp->labelsector))) {
 		log_error("Failed to write physical volume \"%s\"", pv_name);
 		goto error;
@@ -1827,8 +1822,8 @@
 				  uint64_t pe_start,
 				  uint32_t existing_extent_count,
 				  uint32_t existing_extent_size,
-				  int pvmetadatacopies,
-				  uint64_t pvmetadatasize, struct dm_list *mdas)
+				  int pvmetadatacopies, uint64_t pvmetadatasize,
+				  unsigned metadataignore, struct dm_list *mdas)
 {
 	const struct format_type *fmt = cmd->fmt;
 	struct dm_pool *mem = fmt->cmd->mem;
@@ -1877,8 +1872,8 @@
 	if (!fmt->ops->pv_setup(fmt, pe_start, existing_extent_count,
 				existing_extent_size, data_alignment,
 				data_alignment_offset,
-				pvmetadatacopies, pvmetadatasize, mdas,
-				pv, NULL)) {
+				pvmetadatacopies, pvmetadatasize,
+				metadataignore, mdas, pv, NULL)) {
 		log_error("%s: Format-specific setup of physical volume "
 			  "failed.", pv_dev_name(pv));
 		goto bad;
--- LVM2/lib/metadata/metadata.h	2010/07/07 02:53:17	1.215
+++ LVM2/lib/metadata/metadata.h	2010/07/08 18:24:30	1.216
@@ -244,8 +244,8 @@
 			 uint64_t pe_start, uint32_t extent_count,
 			 uint32_t extent_size, unsigned long data_alignment,
 			 unsigned long data_alignment_offset,
-			 int pvmetadatacopies,
-			 uint64_t pvmetadatasize, struct dm_list * mdas,
+			 int pvmetadatacopies, uint64_t pvmetadatasize,
+			 unsigned metadataignore, struct dm_list * mdas,
 			 struct physical_volume * pv, struct volume_group * vg);
 
 	/*
--- LVM2/tools/vgconvert.c	2009/10/05 20:55:57	1.41
+++ LVM2/tools/vgconvert.c	2010/07/08 18:24:30	1.42
@@ -127,7 +127,7 @@
 				     &existing_pv->id, size, 0, 0,
 				     pe_start, pv_pe_count(existing_pv),
 				     pv_pe_size(existing_pv), pvmetadatacopies,
-				     pvmetadatasize, &mdas))) {
+				     pvmetadatasize, 0, &mdas))) {
 			log_error("Failed to setup physical volume \"%s\"",
 				  pv_dev_name(existing_pv));
 			if (change_made)


