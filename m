From: Alasdair Kergon <agk@sourceware.org>
Date: Thu, 8 Feb 2018 20:32:00 -0500
Subject: master - callbacks: Miscellaneous fixes for recent changes
Message-ID: <201802090132.w191W0Cf027055@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e869a52cc4e0a65f00c8d3f40cf94b6989e60871
Commit:        e869a52cc4e0a65f00c8d3f40cf94b6989e60871
Parent:        e727da6cf111b07b302c08ed479336e4994635b0
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon Jan 22 15:41:11 2018 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Feb 6 01:09:39 2018 +0000

callbacks: Miscellaneous fixes for recent changes

---
 lib/device/dev-io.c           |    2 +-
 lib/format1/format1.c         |    2 +-
 lib/format1/lvm1-label.c      |    2 +-
 lib/format_pool/format_pool.c |    2 +-
 lib/format_text/text_label.c  |    2 +-
 lib/label/label.c             |    7 +++++--
 6 files changed, 10 insertions(+), 7 deletions(-)

diff --git a/lib/device/dev-io.c b/lib/device/dev-io.c
index 3af4236..d23f61e 100644
--- a/lib/device/dev-io.c
+++ b/lib/device/dev-io.c
@@ -154,7 +154,7 @@ static int _io(struct device_buffer *devbuf, unsigned ioflags)
 	}
 
 	if (!devbuf->buf && !(devbuf->malloc_address = devbuf->buf = dm_malloc_aligned((size_t) devbuf->where.size, 0))) {
-		log_error("Bounce buffer malloc failed");
+		log_error("I/O buffer malloc failed");
 		return 0;
 	}
 
diff --git a/lib/format1/format1.c b/lib/format1/format1.c
index b3569e0..7d84e69 100644
--- a/lib/format1/format1.c
+++ b/lib/format1/format1.c
@@ -182,7 +182,7 @@ static struct volume_group *_format1_vg_read(struct format_instance *fid,
 				     struct metadata_area *mda __attribute__((unused)),
 				     struct cached_vg_fmtdata **vg_fmtdata __attribute__((unused)),
 				     unsigned *use_previous_vg __attribute__((unused)),
-				     int single_device __attribute__((unused)))
+				     int single_device __attribute__((unused)), unsigned ioflags)
 {
 	struct volume_group *vg;
 	struct disk_list *dl;
diff --git a/lib/format1/lvm1-label.c b/lib/format1/lvm1-label.c
index 5419d92..d334fdc 100644
--- a/lib/format1/lvm1-label.c
+++ b/lib/format1/lvm1-label.c
@@ -60,7 +60,7 @@ static int _lvm1_read(struct labeller *l, struct device *dev, void *buf, unsigne
 	struct pv_disk *pvd = (struct pv_disk *) buf;
 	struct vg_disk vgd;
 	struct lvmcache_info *info;
-	struct label *label;
+	struct label *label = NULL;
 	const char *vgid = FMT_LVM1_ORPHAN_VG_NAME;
 	const char *vgname = FMT_LVM1_ORPHAN_VG_NAME;
 	unsigned exported = 0;
diff --git a/lib/format_pool/format_pool.c b/lib/format_pool/format_pool.c
index 1f257a2..c699058 100644
--- a/lib/format_pool/format_pool.c
+++ b/lib/format_pool/format_pool.c
@@ -103,7 +103,7 @@ static struct volume_group *_pool_vg_read(struct format_instance *fid,
 					  struct metadata_area *mda __attribute__((unused)),
 					  struct cached_vg_fmtdata **vg_fmtdata __attribute__((unused)),
 					  unsigned *use_previous_vg __attribute__((unused)),
-					  int single_device __attribute__((unused)), int ioflags)
+					  int single_device __attribute__((unused)), unsigned ioflags)
 {
 	struct volume_group *vg;
 	struct user_subpool *usp;
diff --git a/lib/format_text/text_label.c b/lib/format_text/text_label.c
index 49f4015..d3d92f0 100644
--- a/lib/format_text/text_label.c
+++ b/lib/format_text/text_label.c
@@ -551,7 +551,7 @@ out:
 
 bad:
 	if (read_label_callback_fn)
-		read_label_callback_fn(1, ioflags, read_label_callback_context, label);
+		read_label_callback_fn(1, ioflags, read_label_callback_context, NULL);
 
 	return 0;
 }
diff --git a/lib/label/label.c b/lib/label/label.c
index d293caf..0997b96 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -156,7 +156,7 @@ out:
 		stack;
 
 	if (flp->process_label_data_fn)
-		flp->process_label_data_fn(0, ioflags, flp->process_label_data_context, NULL);
+		flp->process_label_data_fn(!flp->ret, ioflags, flp->process_label_data_context, NULL);
 }
 
 static void _find_labeller(int failed, unsigned ioflags, void *context, const void *data)
@@ -362,7 +362,10 @@ static int _label_read(struct device *dev, uint64_t scan_sector, struct label **
 		return 0;
 	}
 
-	return flp->ret;
+	if (process_label_data_fn)
+		return 1;
+	else
+		return flp->ret;
 }
 
 /* result may be NULL if caller doesn't need it */


