From: Petr Rockai <prockai@redhat.com>
Date: Mon, 29 Jul 2013 21:19:14 +0200
Subject: [PATCH 10/20] labeller: Make the use of "private" as "fmt" explicit.
In-Reply-To: <1375125564-1188-1-git-send-email-prockai@redhat.com>
References: <1375125564-1188-1-git-send-email-prockai@redhat.com>
Message-ID: <1375125564-1188-10-git-send-email-prockai@redhat.com>
	(sfid-20130729_211928_052066_DFFCB225)
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

All labellers always use the "private" (void *) field as the fmt pointer. Making
this fact explicit in the type of the labeller simplifies the label reporting
code which needs to extract the format. Moreover, it removes a number of
error-prone casts from the code.
---
 lib/cache/lvmcache.c          | 4 ++--
 lib/format1/format1.c         | 2 +-
 lib/format1/lvm1-label.c      | 2 +-
 lib/format_pool/format_pool.c | 2 +-
 lib/format_pool/pool_label.c  | 2 +-
 lib/format_text/format-text.c | 2 +-
 lib/format_text/text_label.c  | 4 ++--
 lib/label/label.c             | 4 ++--
 lib/label/label.h             | 4 ++--
 9 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index f33565c..770a1b3 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -1450,7 +1450,7 @@ struct lvmcache_info *lvmcache_add(struct labeller *labeller, const char *pvid,
 				   const char *vgname, const char *vgid,
 				   uint32_t vgstatus)
 {
-	const struct format_type *fmt = (const struct format_type *) labeller->private;
+	const struct format_type *fmt = labeller->fmt;
 	struct dev_types *dt = fmt->cmd->dev_types;
 	struct label *label;
 	struct lvmcache_info *existing, *info;
@@ -1540,7 +1540,7 @@ struct lvmcache_info *lvmcache_add(struct labeller *labeller, const char *pvid,
 		label = info->label;
 	}
 
-	info->fmt = (const struct format_type *) labeller->private;
+	info->fmt = labeller->fmt;
 	info->status |= CACHE_INVALID;
 
 	if (!_lvmcache_update_pvid(info, pvid_s)) {
diff --git a/lib/format1/format1.c b/lib/format1/format1.c
index 7014a35..509167a 100644
--- a/lib/format1/format1.c
+++ b/lib/format1/format1.c
@@ -614,7 +614,7 @@ struct format_type *init_format(struct cmd_context *cmd)
 		return NULL;
 	}
 
-	if (!(label_register_handler(FMT_LVM1_NAME, fmt->labeller))) {
+	if (!(label_register_handler(fmt->labeller))) {
 		log_error("Couldn't register lvm1 label handler.");
 		fmt->labeller->ops->destroy(fmt->labeller);
 		dm_free(fmt);
diff --git a/lib/format1/lvm1-label.c b/lib/format1/lvm1-label.c
index 6138a05..c5f9f35 100644
--- a/lib/format1/lvm1-label.c
+++ b/lib/format1/lvm1-label.c
@@ -122,7 +122,7 @@ struct labeller *lvm1_labeller_create(struct format_type *fmt)
 	}
 
 	l->ops = &_lvm1_ops;
-	l->private = (const void *) fmt;
+	l->fmt = fmt;
 
 	return l;
 }
diff --git a/lib/format_pool/format_pool.c b/lib/format_pool/format_pool.c
index 0891524..0f8f3a3 100644
--- a/lib/format_pool/format_pool.c
+++ b/lib/format_pool/format_pool.c
@@ -309,7 +309,7 @@ struct format_type *init_format(struct cmd_context *cmd)
 		return NULL;
 	}
 
-	if (!(label_register_handler(FMT_POOL_NAME, fmt->labeller))) {
+	if (!(label_register_handler(fmt->labeller))) {
 		log_error("Couldn't register pool label handler.");
 		fmt->labeller->ops->destroy(fmt->labeller);
 		dm_free(fmt);
diff --git a/lib/format_pool/pool_label.c b/lib/format_pool/pool_label.c
index 7059b98..d453dd9 100644
--- a/lib/format_pool/pool_label.c
+++ b/lib/format_pool/pool_label.c
@@ -99,7 +99,7 @@ struct labeller *pool_labeller_create(struct format_type *fmt)
 	}
 
 	l->ops = &_pool_ops;
-	l->private = (const void *) fmt;
+	l->fmt = fmt;
 
 	return l;
 }
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index b210603..b274266 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -2433,7 +2433,7 @@ struct format_type *create_text_format(struct cmd_context *cmd)
 		goto bad;
 	}
 
-	if (!(label_register_handler(FMT_TEXT_NAME, fmt->labeller))) {
+	if (!(label_register_handler(fmt->labeller))) {
 		log_error("Couldn't register text label handler.");
 		fmt->labeller->ops->destroy(fmt->labeller);
 		goto bad;
diff --git a/lib/format_text/text_label.c b/lib/format_text/text_label.c
index 3408590..516d694 100644
--- a/lib/format_text/text_label.c
+++ b/lib/format_text/text_label.c
@@ -316,7 +316,7 @@ struct _update_mda_baton {
 static int _update_mda(struct metadata_area *mda, void *baton)
 {
 	struct _update_mda_baton *p = baton;
-	const struct format_type *fmt = p->label->labeller->private; // Oh dear.
+	const struct format_type *fmt = p->label->labeller->fmt;
 	struct mda_context *mdac = (struct mda_context *) mda->metadata_locn;
 	struct mda_header *mdah;
 	const char *vgname = NULL;
@@ -471,7 +471,7 @@ struct labeller *text_labeller_create(const struct format_type *fmt)
 	}
 
 	l->ops = &_text_ops;
-	l->private = (const void *) fmt;
+	l->fmt = fmt;
 
 	return l;
 }
diff --git a/lib/label/label.c b/lib/label/label.c
index a38ba68..cff6464 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -76,11 +76,11 @@ void label_exit(void)
 	dm_list_init(&_labellers);
 }
 
-int label_register_handler(const char *name, struct labeller *handler)
+int label_register_handler(struct labeller *handler)
 {
 	struct labeller_i *li;
 
-	if (!(li = _alloc_li(name, handler)))
+	if (!(li = _alloc_li(handler->fmt->name, handler)))
 		return_0;
 
 	dm_list_add(&_labellers, &li->list);
diff --git a/lib/label/label.h b/lib/label/label.h
index f3268bb..8dc49ff 100644
--- a/lib/label/label.h
+++ b/lib/label/label.h
@@ -87,13 +87,13 @@ struct label_ops {
 
 struct labeller {
 	struct label_ops *ops;
-	const void *private;
+	struct format_type *fmt;
 };
 
 int label_init(void);
 void label_exit(void);
 
-int label_register_handler(const char *name, struct labeller *handler);
+int label_register_handler(struct labeller *handler);
 
 struct labeller *label_get_handler(const char *name);
 
-- 
1.8.2


