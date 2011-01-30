From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Sun, 30 Jan 2011 13:57:32 +0100
Subject: [PATCH 09/24] Align orphan strings
In-Reply-To: <cover.1296391340.git.zkabelac@redhat.com>
References: <cover.1296391340.git.zkabelac@redhat.com>
Message-ID: <53ced78e174b7eff8b62b615874a5b52e7544e55.1296391340.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

While checking for passed pointers to hash function - some buffers
were not nicely aligned - and those were mainly 'static' strings.

So this code is a bit ugly but forces 8b alignment on these strings.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/format1/format1.c         |   10 +++++++---
 lib/format1/lvm1-label.c      |    9 +++++++--
 lib/format_pool/format_pool.c |    4 +++-
 lib/format_text/format-text.c |   16 ++++++++++++----
 lib/format_text/text_label.c  |    5 +++--
 5 files changed, 32 insertions(+), 12 deletions(-)

diff --git a/lib/format1/format1.c b/lib/format1/format1.c
index fc14444..c70d857 100644
--- a/lib/format1/format1.c
+++ b/lib/format1/format1.c
@@ -578,6 +578,10 @@ struct format_type *init_format(struct cmd_context *cmd);
 struct format_type *init_format(struct cmd_context *cmd)
 #endif
 {
+	static const char lvm1_orphan_vg_name[] __attribute__((aligned(8)))
+		= FMT_LVM1_ORPHAN_VG_NAME;
+	static const char lvm1_name[] __attribute__((aligned(8)))
+		= FMT_LVM1_NAME;
 	struct format_type *fmt = dm_malloc(sizeof(*fmt));
 
 	if (!fmt)
@@ -585,9 +589,9 @@ struct format_type *init_format(struct cmd_context *cmd)
 
 	fmt->cmd = cmd;
 	fmt->ops = &_format1_ops;
-	fmt->name = FMT_LVM1_NAME;
+	fmt->name = lvm1_name;
 	fmt->alias = NULL;
-	fmt->orphan_vg_name = FMT_LVM1_ORPHAN_VG_NAME;
+	fmt->orphan_vg_name = lvm1_orphan_vg_name;
 	fmt->features = FMT_RESTRICTED_LVIDS | FMT_ORPHAN_ALLOCATABLE |
 			FMT_RESTRICTED_READAHEAD;
 	fmt->private = NULL;
@@ -597,7 +601,7 @@ struct format_type *init_format(struct cmd_context *cmd)
 		return NULL;
 	}
 
-	if (!(label_register_handler(FMT_LVM1_NAME, fmt->labeller))) {
+	if (!(label_register_handler(lvm1_name, fmt->labeller))) {
 		log_error("Couldn't register lvm1 label handler.");
 		return NULL;
 	}
diff --git a/lib/format1/lvm1-label.c b/lib/format1/lvm1-label.c
index 07596a5..2af444a 100644
--- a/lib/format1/lvm1-label.c
+++ b/lib/format1/lvm1-label.c
@@ -57,11 +57,16 @@ static int _lvm1_write(struct label *label __attribute__((unused)), void *buf __
 static int _lvm1_read(struct labeller *l, struct device *dev, void *buf,
 		 struct label **label)
 {
+	static const char orphan_vgid[] __attribute__((aligned(8)))
+		= FMT_LVM1_ORPHAN_VG_NAME;
+	static const char orphan_vg_name[] __attribute__((aligned(8)))
+		= FMT_LVM1_ORPHAN_VG_NAME;
+
 	struct pv_disk *pvd = (struct pv_disk *) buf;
 	struct vg_disk vgd;
 	struct lvmcache_info *info;
-	const char *vgid = FMT_LVM1_ORPHAN_VG_NAME;
-	const char *vgname = FMT_LVM1_ORPHAN_VG_NAME;
+	const char *vgid = orphan_vgid;
+	const char *vgname = orphan_vg_name;
 	unsigned exported = 0;
 
 	munge_pvd(dev, pvd);
diff --git a/lib/format_pool/format_pool.c b/lib/format_pool/format_pool.c
index 730da87..6f6f261 100644
--- a/lib/format_pool/format_pool.c
+++ b/lib/format_pool/format_pool.c
@@ -308,6 +308,8 @@ struct format_type *init_format(struct cmd_context *cmd);
 struct format_type *init_format(struct cmd_context *cmd)
 #endif
 {
+	static const char pool_orphan_vg_name[] __attribute__((aligned(8)))
+		= FMT_POOL_ORPHAN_VG_NAME;
 	struct format_type *fmt = dm_malloc(sizeof(*fmt));
 
 	if (!fmt) {
@@ -320,7 +322,7 @@ struct format_type *init_format(struct cmd_context *cmd)
 	fmt->ops = &_format_pool_ops;
 	fmt->name = FMT_POOL_NAME;
 	fmt->alias = NULL;
-	fmt->orphan_vg_name = FMT_POOL_ORPHAN_VG_NAME;
+	fmt->orphan_vg_name = pool_orphan_vg_name;
 	fmt->features = 0;
 	fmt->private = NULL;
 
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index c186757..8abc564 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -1594,6 +1594,8 @@ static int _populate_pv_fields(struct lvmcache_info *info,
 			       struct physical_volume *pv,
 			       int scan_label_only)
 {
+	static const char orphan_vg_name[] __attribute__((aligned(8)))
+		= FMT_TEXT_ORPHAN_VG_NAME;
 	struct data_area_list *da;
 
 	/* Have we already cached vgname? */
@@ -1612,7 +1614,7 @@ static int _populate_pv_fields(struct lvmcache_info *info,
 	pv->dev = info->dev;
 	pv->fmt = info->fmt;
 	pv->size = info->device_size >> SECTOR_SHIFT;
-	pv->vg_name = FMT_TEXT_ORPHAN_VG_NAME;
+	pv->vg_name = orphan_vg_name;
 	memcpy(&pv->id, &info->dev->pvid, sizeof(pv->id));
 
 	/* Currently only support exactly one data area */
@@ -2132,6 +2134,12 @@ static int _get_config_disk_area(struct cmd_context *cmd,
 
 struct format_type *create_text_format(struct cmd_context *cmd)
 {
+	static const char text_name[] __attribute__((aligned(8)))
+		= FMT_TEXT_NAME;
+	static const char text_alias[] __attribute__((aligned(8)))
+		= FMT_TEXT_ALIAS;
+	static const char orphan_vg_name[] __attribute__((aligned(8)))
+		= ORPHAN_VG_NAME(FMT_TEXT_NAME);
 	struct format_type *fmt;
 	const struct config_node *cn;
 	const struct config_value *cv;
@@ -2142,9 +2150,9 @@ struct format_type *create_text_format(struct cmd_context *cmd)
 
 	fmt->cmd = cmd;
 	fmt->ops = &_text_handler;
-	fmt->name = FMT_TEXT_NAME;
-	fmt->alias = FMT_TEXT_ALIAS;
-	fmt->orphan_vg_name = ORPHAN_VG_NAME(FMT_TEXT_NAME);
+	fmt->name = text_name;
+	fmt->alias = text_alias;
+	fmt->orphan_vg_name = orphan_vg_name;
 	fmt->features = FMT_SEGMENTS | FMT_MDAS | FMT_TAGS | FMT_PRECOMMIT |
 			FMT_UNLIMITED_VOLS | FMT_RESIZE_PV |
 			FMT_UNLIMITED_STRIPESIZE;
diff --git a/lib/format_text/text_label.c b/lib/format_text/text_label.c
index e459cde..ce250e6 100644
--- a/lib/format_text/text_label.c
+++ b/lib/format_text/text_label.c
@@ -253,6 +253,8 @@ static int _text_initialise_label(struct labeller *l __attribute__((unused)),
 static int _text_read(struct labeller *l, struct device *dev, void *buf,
 		 struct label **label)
 {
+	static const char text_orphan_vg_name[] __attribute__((aligned(8)))
+		= FMT_TEXT_ORPHAN_VG_NAME;
 	struct label_header *lh = (struct label_header *) buf;
 	struct pv_header *pvhdr;
 	struct lvmcache_info *info;
@@ -269,8 +271,7 @@ static int _text_read(struct labeller *l, struct device *dev, void *buf,
 	pvhdr = (struct pv_header *) ((void *) buf + xlate32(lh->offset_xl));
 
 	if (!(info = lvmcache_add(l, (char *)pvhdr->pv_uuid, dev,
-				  FMT_TEXT_ORPHAN_VG_NAME,
-				  FMT_TEXT_ORPHAN_VG_NAME, 0)))
+				  text_orphan_vg_name, text_orphan_vg_name, 0)))
 		return_0;
 	*label = info->label;
 
-- 
1.7.3.5


