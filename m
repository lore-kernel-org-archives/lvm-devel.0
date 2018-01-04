From: Alasdair Kergon <agk@sourceware.org>
Date: Thu, 4 Jan 2018 13:40:28 -0500
Subject: master - format_text: Split out raw_read_mda_header processing
Message-ID: <201801041840.w04IeSlL014182@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d61b1369d0764841522494ef3ba0ef4b5e89c723
Commit:        d61b1369d0764841522494ef3ba0ef4b5e89c723
Parent:        139209ef42f8ea986c22fb3c889dbf893da7160b
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Thu Jan 4 15:52:59 2018 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Thu Jan 4 15:52:59 2018 +0000

format_text: Split out raw_read_mda_header processing

---
 lib/format_text/format-text.c |   67 ++++++++++++++++++++++++++++------------
 1 files changed, 47 insertions(+), 20 deletions(-)

diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index c57ffd2..4404c04 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -226,6 +226,7 @@ static int _pv_analyze_mda_raw (const struct format_type * fmt,
 							prev_sector);
 		if (prev_sector > prev_sector2)
 			goto_out;
+
 		/*
 		 * FIXME: for some reason, the whole metadata region from
 		 * area->start to area->start+area->size is not used.
@@ -241,7 +242,7 @@ static int _pv_analyze_mda_raw (const struct format_type * fmt,
 			if (!(buf = dev_read_circular(area->dev, offset, size, offset2, size2, MDA_CONTENT_REASON(mda_is_primary(mda)))))
 				goto_out;
 		} else if (!(buf = dev_read(area->dev, offset, size, MDA_CONTENT_REASON(mda_is_primary(mda)))))
-				goto_out;
+			goto_out;
 
 		/*
 		 * FIXME: We could add more sophisticated metadata detection
@@ -325,19 +326,19 @@ static void _xlate_mdah(struct mda_header *mdah)
 	}
 }
 
-static int _raw_read_mda_header(struct mda_header *mdah, struct device_area *dev_area, int primary_mda)
-{
-	if (!dev_open_readonly(dev_area->dev))
-		return_0;
+struct process_raw_mda_header_params {
+	struct mda_header *mdah;
+	struct device_area dev_area;
+};
 
-	if (!dev_read_buf(dev_area->dev, dev_area->start, MDA_HEADER_SIZE, MDA_HEADER_REASON(primary_mda), mdah)) {
-		if (!dev_close(dev_area->dev))
-			stack;
-		return_0;
-	}
+static int _process_raw_mda_header(struct process_raw_mda_header_params *prmp)
+{
+	struct mda_header *mdah = prmp->mdah;
+	struct device_area *dev_area = &prmp->dev_area;
+	int r = 0;
 
 	if (!dev_close(dev_area->dev))
-		return_0;
+		goto_out;
 
 	if (mdah->checksum_xl != xlate32(calc_crc(INITIAL_CRC, (uint8_t *)mdah->magic,
 						  MDA_HEADER_SIZE -
@@ -345,7 +346,7 @@ static int _raw_read_mda_header(struct mda_header *mdah, struct device_area *dev
 		log_error("Incorrect metadata area header checksum on %s"
 			  " at offset " FMTu64, dev_name(dev_area->dev),
 			  dev_area->start);
-		return 0;
+		goto out;
 	}
 
 	_xlate_mdah(mdah);
@@ -354,43 +355,70 @@ static int _raw_read_mda_header(struct mda_header *mdah, struct device_area *dev
 		log_error("Wrong magic number in metadata area header on %s"
 			  " at offset " FMTu64, dev_name(dev_area->dev),
 			  dev_area->start);
-		return 0;
+		goto out;
 	}
 
 	if (mdah->version != FMTT_VERSION) {
 		log_error("Incompatible metadata area header version: %d on %s"
 			  " at offset " FMTu64, mdah->version,
 			  dev_name(dev_area->dev), dev_area->start);
-		return 0;
+		goto out;
 	}
 
 	if (mdah->start != dev_area->start) {
 		log_error("Incorrect start sector in metadata area header: "
 			  FMTu64 " on %s at offset " FMTu64, mdah->start,
 			  dev_name(dev_area->dev), dev_area->start);
-		return 0;
+		goto out;
 	}
 
-	return 1;
+	r = 1;
+
+out:
+	return r;
 }
 
-struct mda_header *raw_read_mda_header(struct dm_pool *mem, struct device_area *dev_area, int primary_mda)
+static struct mda_header *_raw_read_mda_header(struct dm_pool *mem, struct device_area *dev_area, int primary_mda)
 {
 	struct mda_header *mdah;
+	struct process_raw_mda_header_params *prmp;
 
 	if (!(mdah = dm_pool_alloc(mem, MDA_HEADER_SIZE))) {
 		log_error("struct mda_header allocation failed");
 		return NULL;
 	}
 
-	if (!_raw_read_mda_header(mdah, dev_area, primary_mda)) {
+	if (!(prmp = dm_pool_zalloc(mem, sizeof (*prmp)))) {
+		log_error("struct process_raw_mda_header_params allocation failed");
 		dm_pool_free(mem, mdah);
 		return NULL;
 	}
 
+	if (!dev_open_readonly(dev_area->dev)) {
+		dm_pool_free(mem, mdah);
+		return_NULL;
+	}
+
+	prmp->mdah = mdah;
+	prmp->dev_area = *dev_area;
+
+	if (!dev_read_buf(dev_area->dev, dev_area->start, MDA_HEADER_SIZE, MDA_HEADER_REASON(primary_mda), mdah)) {
+		if (!dev_close(dev_area->dev))
+			stack;
+		return_NULL;
+	}
+
+	if (!_process_raw_mda_header(prmp))
+		return_NULL;
+
 	return mdah;
 }
 
+struct mda_header *raw_read_mda_header(struct dm_pool *mem, struct device_area *dev_area, int primary_mda)
+{
+	return _raw_read_mda_header(mem, dev_area, primary_mda);
+}
+
 static int _raw_write_mda_header(const struct format_type *fmt,
 				 struct device *dev, int primary_mda,
 				 uint64_t start_byte, struct mda_header *mdah)
@@ -1899,9 +1927,8 @@ static int _mda_export_text_raw(struct metadata_area *mda,
 				struct dm_config_node *parent)
 {
 	struct mda_context *mdc = (struct mda_context *) mda->metadata_locn;
-	char mdah[MDA_HEADER_SIZE]; /* temporary */
 
-	if (!mdc || !_raw_read_mda_header((struct mda_header *)mdah, &mdc->area, mda_is_primary(mda)))
+	if (!mdc || !_raw_read_mda_header(cft->mem, &mdc->area, mda_is_primary(mda)))
 		return 1; /* pretend the MDA does not exist */
 
 	return config_make_nodes(cft, parent, NULL,


