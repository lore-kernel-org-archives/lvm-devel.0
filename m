From: Alasdair Kergon <agk@sourceware.org>
Date: Sat, 6 Jan 2018 18:27:25 -0500
Subject: master - label: Add callback fns (partially)
Message-ID: <201801062327.w06NRPLv006235@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a9fe4886ba08771b3bc013516857109818822c6a
Commit:        a9fe4886ba08771b3bc013516857109818822c6a
Parent:        5e7d3ad749d3de735ba213ad64637182afec2586
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Sat Jan 6 02:43:54 2018 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Sat Jan 6 04:14:51 2018 +0000

label: Add callback fns (partially)

---
 lib/format1/lvm1-label.c      |   16 ++++++++---
 lib/format_pool/pool_label.c  |   10 +++++--
 lib/format_text/format-text.c |   61 ++++++++++++++++++++++++++---------------
 lib/format_text/layout.h      |    2 +
 lib/format_text/text_label.c  |   28 ++++++++++++++-----
 lib/label/label.c             |   10 +++---
 lib/label/label.h             |    4 +-
 7 files changed, 88 insertions(+), 43 deletions(-)

diff --git a/lib/format1/lvm1-label.c b/lib/format1/lvm1-label.c
index 3b8a655..6a2ec49 100644
--- a/lib/format1/lvm1-label.c
+++ b/lib/format1/lvm1-label.c
@@ -54,8 +54,8 @@ static int _lvm1_write(struct label *label __attribute__((unused)), void *buf __
 	return 0;
 }
 
-static int _lvm1_read(struct labeller *l, struct device *dev, void *buf,
-		 struct label **label)
+static int _lvm1_read(struct labeller *l, struct device *dev, void *buf, struct label **label,
+		      lvm_callback_fn_t read_label_callback_fn, void *read_label_callback_context)
 {
 	struct pv_disk *pvd = (struct pv_disk *) buf;
 	struct vg_disk vgd;
@@ -63,6 +63,7 @@ static int _lvm1_read(struct labeller *l, struct device *dev, void *buf,
 	const char *vgid = FMT_LVM1_ORPHAN_VG_NAME;
 	const char *vgname = FMT_LVM1_ORPHAN_VG_NAME;
 	unsigned exported = 0;
+	int r;
 
 	munge_pvd(dev, pvd);
 
@@ -76,7 +77,8 @@ static int _lvm1_read(struct labeller *l, struct device *dev, void *buf,
 
 	if (!(info = lvmcache_add(l, (char *)pvd->pv_uuid, dev, vgname, vgid,
 				  exported)))
-		return_0;
+		goto_out;
+
 	*label = lvmcache_get_label(info);
 
 	lvmcache_set_device_size(info, ((uint64_t)xlate32(pvd->pv_size)) << SECTOR_SHIFT);
@@ -86,7 +88,13 @@ static int _lvm1_read(struct labeller *l, struct device *dev, void *buf,
 	lvmcache_del_bas(info);
 	lvmcache_make_valid(info);
 
-	return 1;
+	r = 1;
+
+out:
+        if (read_label_callback_fn)
+                read_label_callback_fn(!r, read_label_callback_context, NULL);
+
+	return r;
 }
 
 static int _lvm1_initialise_label(struct labeller *l __attribute__((unused)), struct label *label)
diff --git a/lib/format_pool/pool_label.c b/lib/format_pool/pool_label.c
index 2e30a7b..cd6c82a 100644
--- a/lib/format_pool/pool_label.c
+++ b/lib/format_pool/pool_label.c
@@ -55,12 +55,16 @@ static int _pool_write(struct label *label __attribute__((unused)), void *buf __
 	return 0;
 }
 
-static int _pool_read(struct labeller *l, struct device *dev, void *buf,
-		 struct label **label)
+static int _pool_read(struct labeller *l, struct device *dev, void *buf, struct label **label,
+		      lvm_callback_fn_t read_label_callback_fn, void *read_label_callback_context)
 {
 	struct pool_list pl;
+	int r;
 
-	return read_pool_label(&pl, l, dev, buf, label);
+	r = read_pool_label(&pl, l, dev, buf, label);
+
+	if (read_label_callback_fn)
+		read_label_callback_fn(!r, read_label_callback_context, NULL);
 }
 
 static int _pool_initialise_label(struct labeller *l __attribute__((unused)), struct label *label)
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index a0aff4d..2158b5f 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -329,6 +329,8 @@ static void _xlate_mdah(struct mda_header *mdah)
 struct process_raw_mda_header_params {
 	struct mda_header *mdah;
 	struct device_area dev_area;
+	lvm_callback_fn_t mdah_callback_fn;
+	void *mdah_callback_context;
 	int ret;
 };
 
@@ -338,10 +340,13 @@ static void _process_raw_mda_header(int failed, void *context, void *data)
 	struct mda_header *mdah = prmp->mdah;
 	struct device_area *dev_area = &prmp->dev_area;
 
-	if (!dev_close(dev_area->dev)) {
-		prmp->ret = 0;
+	if (!dev_close(dev_area->dev))
 		goto_out;
-	}
+
+	if (failed)
+		goto_bad;
+
+	memcpy(mdah, data, MDA_HEADER_SIZE);
 
 	if (mdah->checksum_xl != xlate32(calc_crc(INITIAL_CRC, (uint8_t *)mdah->magic,
 						  MDA_HEADER_SIZE -
@@ -349,8 +354,7 @@ static void _process_raw_mda_header(int failed, void *context, void *data)
 		log_error("Incorrect metadata area header checksum on %s"
 			  " at offset " FMTu64, dev_name(dev_area->dev),
 			  dev_area->start);
-		prmp->ret = 0;
-		goto out;
+		goto bad;
 	}
 
 	_xlate_mdah(mdah);
@@ -359,31 +363,37 @@ static void _process_raw_mda_header(int failed, void *context, void *data)
 		log_error("Wrong magic number in metadata area header on %s"
 			  " at offset " FMTu64, dev_name(dev_area->dev),
 			  dev_area->start);
-		prmp->ret = 0;
-		goto out;
+		goto bad;
 	}
 
 	if (mdah->version != FMTT_VERSION) {
 		log_error("Incompatible metadata area header version: %d on %s"
 			  " at offset " FMTu64, mdah->version,
 			  dev_name(dev_area->dev), dev_area->start);
-		prmp->ret = 0;
-		goto out;
+		goto bad;
 	}
 
 	if (mdah->start != dev_area->start) {
 		log_error("Incorrect start sector in metadata area header: "
 			  FMTu64 " on %s at offset " FMTu64, mdah->start,
 			  dev_name(dev_area->dev), dev_area->start);
-		prmp->ret = 0;
-		goto out;
+		goto bad;
 	}
 
+	goto out;
+
+bad:
+	prmp->ret = 0;
 out:
-	;
+	if (!failed)
+		dm_free(data);
+
+	if (prmp->mdah_callback_fn)
+		prmp->mdah_callback_fn(!prmp->ret, prmp->mdah_callback_context, mdah);
 }
 
-static struct mda_header *_raw_read_mda_header(struct dm_pool *mem, struct device_area *dev_area, int primary_mda)
+static struct mda_header *_raw_read_mda_header(struct dm_pool *mem, struct device_area *dev_area, int primary_mda,
+					       lvm_callback_fn_t mdah_callback_fn, void *mdah_callback_context)
 {
 	struct mda_header *mdah;
 	struct process_raw_mda_header_params *prmp;
@@ -406,15 +416,13 @@ static struct mda_header *_raw_read_mda_header(struct dm_pool *mem, struct devic
 
 	prmp->mdah = mdah;
 	prmp->dev_area = *dev_area;
+	prmp->mdah_callback_fn = mdah_callback_fn;
+	prmp->mdah_callback_context = mdah_callback_context;
 	prmp->ret = 1;
 
-	if (!dev_read_buf(dev_area->dev, dev_area->start, MDA_HEADER_SIZE, MDA_HEADER_REASON(primary_mda), mdah)) {
-		if (!dev_close(dev_area->dev))
-			stack;
-		return_NULL;
-	}
-
-	_process_raw_mda_header(0, prmp, NULL);
+	if (!dev_read_callback(dev_area->dev, dev_area->start, MDA_HEADER_SIZE, MDA_HEADER_REASON(primary_mda),
+			       _process_raw_mda_header, prmp))
+		stack;
 
 	if (!prmp->ret)
 		return_NULL;
@@ -424,7 +432,16 @@ static struct mda_header *_raw_read_mda_header(struct dm_pool *mem, struct devic
 
 struct mda_header *raw_read_mda_header(struct dm_pool *mem, struct device_area *dev_area, int primary_mda)
 {
-	return _raw_read_mda_header(mem, dev_area, primary_mda);
+	return _raw_read_mda_header(mem, dev_area, primary_mda, NULL, NULL);
+}
+
+int raw_read_mda_header_callback(struct dm_pool *mem, struct device_area *dev_area, int primary_mda,
+				 lvm_callback_fn_t mdah_callback_fn, void *mdah_callback_context)
+{
+	if (!_raw_read_mda_header(mem, dev_area, primary_mda, mdah_callback_fn, mdah_callback_context))
+		return_0;
+
+	return 1;
 }
 
 static int _raw_write_mda_header(const struct format_type *fmt,
@@ -2002,7 +2019,7 @@ static int _mda_export_text_raw(struct metadata_area *mda,
 {
 	struct mda_context *mdc = (struct mda_context *) mda->metadata_locn;
 
-	if (!mdc || !_raw_read_mda_header(cft->mem, &mdc->area, mda_is_primary(mda)))
+	if (!mdc || !_raw_read_mda_header(cft->mem, &mdc->area, mda_is_primary(mda), NULL, NULL))
 		return 1; /* pretend the MDA does not exist */
 
 	return config_make_nodes(cft, parent, NULL,
diff --git a/lib/format_text/layout.h b/lib/format_text/layout.h
index c0906a6..3320b0c 100644
--- a/lib/format_text/layout.h
+++ b/lib/format_text/layout.h
@@ -82,6 +82,8 @@ struct mda_header {
 } __attribute__ ((packed));
 
 struct mda_header *raw_read_mda_header(struct dm_pool *mem, struct device_area *dev_area, int primary_mda);
+int raw_read_mda_header_callback(struct dm_pool *mem, struct device_area *dev_area, int primary_mda,
+				 lvm_callback_fn_t mdah_callback_fn, void *mdah_callback_context);
 
 struct mda_lists {
 	struct dm_list dirs;
diff --git a/lib/format_text/text_label.c b/lib/format_text/text_label.c
index 05e1626..3f090b4 100644
--- a/lib/format_text/text_label.c
+++ b/lib/format_text/text_label.c
@@ -322,6 +322,9 @@ static int _text_initialise_label(struct labeller *l __attribute__((unused)),
 struct update_mda_baton {
 	struct lvmcache_info *info;
 	struct label *label;
+	int nr_outstanding_mdas;
+	lvm_callback_fn_t read_label_callback_fn;
+	void *read_label_callback_context;
 	int ret;
 };
 
@@ -338,6 +341,8 @@ static void _process_vgsummary(int failed, void *context, void *data)
 	struct process_mda_header_params *pmp = context;
 	struct lvmcache_vgsummary *vgsummary = data;
 
+	--pmp->umb->nr_outstanding_mdas;
+
 	if (!lvmcache_update_vgname_and_id(pmp->umb->info, vgsummary)) {
 		pmp->umb->ret = 0;
 		pmp->ret = 0;
@@ -388,7 +393,6 @@ static int _update_mda(struct metadata_area *mda, void *baton)
 	const struct format_type *fmt = umb->label->labeller->fmt;
 	struct dm_pool *mem = umb->label->labeller->fmt->cmd->mem;
 	struct mda_context *mdac = (struct mda_context *) mda->metadata_locn;
-	struct mda_header *mdah;
 
 	if (!(pmp = dm_pool_zalloc(mem, sizeof(*pmp)))) {
 		log_error("struct process_mda_header_params allocation failed");
@@ -408,25 +412,25 @@ static int _update_mda(struct metadata_area *mda, void *baton)
 		return 1;
 	}
 
+	umb->nr_outstanding_mdas++;
 	pmp->dev = mdac->area.dev;
 
 	pmp->umb = umb;
 	pmp->mda = mda;
 	pmp->ret = 1;
 
-	if (!(mdah = raw_read_mda_header(fmt->cmd->mem, &mdac->area, mda_is_primary(mda)))) {
+	if (!raw_read_mda_header_callback(fmt->cmd->mem, &mdac->area, mda_is_primary(mda), _process_mda_header, pmp)) {
 		stack;
 		if (!dev_close(pmp->dev))
 			stack;
 		return 1;
 	}
 
-	_process_mda_header(0, pmp, mdah);
-
 	return pmp->ret;
 }
 
-static int _text_read(struct labeller *l, struct device *dev, void *buf, struct label **label)
+static int _text_read(struct labeller *l, struct device *dev, void *buf, struct label **label,
+		      lvm_callback_fn_t read_label_callback_fn, void *read_label_callback_context)
 {
 	struct label_header *lh = (struct label_header *) buf;
 	struct pv_header *pvhdr;
@@ -503,17 +507,27 @@ out:
 
 	umb->info = info;
 	umb->label = *label;
+	umb->read_label_callback_fn = read_label_callback_fn;
+	umb->read_label_callback_context = read_label_callback_context;
+	umb->nr_outstanding_mdas = 1;
+
 	umb->ret = 1;
 
 	if (!lvmcache_foreach_mda(info, _update_mda, umb))
 		return_0;
 
-	if (umb->ret)
-		lvmcache_make_valid(info);
+	if (!--umb->nr_outstanding_mdas)
+		if (umb->ret)
+			lvmcache_make_valid(info);
+
+	if (umb->read_label_callback_fn)
+		umb->read_label_callback_fn(!umb->ret, umb->read_label_callback_context, NULL);
 
 	return 1;
 
 bad:
+	if (umb->read_label_callback_fn)
+		umb->read_label_callback_fn(1, umb->read_label_callback_context, NULL);
 	return 0;
 }
 
diff --git a/lib/label/label.c b/lib/label/label.c
index a187bad..0ed5c6a 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -129,8 +129,9 @@ struct find_labeller_params {
 	int ret;
 };
 
-static void _set_label_read_result(int failed, struct find_labeller_params *flp)
+static void _set_label_read_result(int failed, void *context, void *data)
 {
+	struct find_labeller_params *flp = context;
 	struct label **result = flp->result;
 
 	if (failed)
@@ -219,10 +220,9 @@ static void _find_labeller(int failed, void *context, void *data)
 			_update_lvmcache_orphan(info);
 		log_very_verbose("%s: No label detected", dev_name(dev));
 		flp->ret = 0;
+		_set_label_read_result(1, flp, NULL);
 	} else
-		flp->ret = (l->ops->read)(l, dev, labelbuf, result);
-
-	_set_label_read_result(!flp->ret, flp);
+		flp->ret = (l->ops->read)(l, dev, labelbuf, result, &_set_label_read_result, flp);
 }
 
 /* FIXME Also wipe associated metadata area headers? */
@@ -339,7 +339,7 @@ static int _label_read(struct device *dev, uint64_t scan_sector, struct label **
 
 	if (!(readbuf = dev_read(dev, scan_sector << SECTOR_SHIFT, LABEL_SCAN_SIZE, DEV_IO_LABEL))) {
 		log_debug_devs("%s: Failed to read label area", dev_name(dev));
-		_set_label_read_result(1, flp);
+		_set_label_read_result(1, flp, NULL);
 		return 0;
 	}
 
diff --git a/lib/label/label.h b/lib/label/label.h
index ea11290..984acce 100644
--- a/lib/label/label.h
+++ b/lib/label/label.h
@@ -62,8 +62,8 @@ struct label_ops {
 	/*
 	 * Read a label from a volume.
 	 */
-	int (*read) (struct labeller * l, struct device * dev,
-		     void *buf, struct label ** label);
+	int (*read) (struct labeller *l, struct device *dev, void *buf, struct label **label,
+		     lvm_callback_fn_t label_read_callback_fn, void *label_read_callback_context);
 
 	/*
 	 * Populate label_type etc.


