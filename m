From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon, 30 Nov 2009 12:37:12 +0100
Subject: [PATCH 12/23] Replicator: add sorted vg_name_list
In-Reply-To: <1259581043-15308-12-git-send-email-zkabelac@redhat.com>
References: <1259581043-15308-1-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-2-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-3-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-4-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-5-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-6-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-7-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-8-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-9-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-10-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-11-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-12-git-send-email-zkabelac@redhat.com>
Message-ID: <1259581043-15308-13-git-send-email-zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Introduce  vg_name_list structure to keep information about needed
volume group name and the actual pointer to opened VG.

VG must be opened in alphabetical order, thus elements in the list
are being kept ordered all the time.

Two funtions extends dm_list vg_name_list_add(), vg_name_list_lookup().

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/metadata/metadata-exported.h |   16 ++++++++++++++
 lib/metadata/replicator_manip.c  |   41 ++++++++++++++++++++++++++++++++++++++
 2 files changed, 57 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 57985b3..2eb2a42 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -281,6 +281,14 @@ struct lv_segment_area {
 
 struct segment_type;
 
+/* List with VG names
+ * similar to  str_list with one extra pointer */
+struct vg_name_list {
+	struct dm_list list;
+	const char *name;
+	struct volume_group *vg;
+};
+
 /* ++ replicator datatypes */
 typedef enum {
 	REPLICATOR_ACTION_WARN,
@@ -778,6 +786,14 @@ int lv_is_slog(const struct logical_volume *lv);
 /* return first replicator_dev in site in case the lv is replicator-dev, NULL otherwise */
 struct logical_volume *first_replicator_dev(const struct logical_volume *lv);
 /* --  metadata/replicator_manip.c */
+/*
+ * maintain the alphabeticaly ordered list, avoid duplications
+ * return either newly created or already present vg_name_list entry
+ */
+struct vg_name_list *vg_name_list_add(struct dm_pool *mem, struct dm_list *, const char *name);
+/* find element with given name in vg_name_list list */
+struct vg_name_list *vg_name_list_lookup(struct dm_list *, const char *name);
+
 
 struct logical_volume *find_pvmove_lv(struct volume_group *vg,
 				      struct device *dev, uint32_t lv_type);
diff --git a/lib/metadata/replicator_manip.c b/lib/metadata/replicator_manip.c
index ddbe4ee..8bb4ca2 100644
--- a/lib/metadata/replicator_manip.c
+++ b/lib/metadata/replicator_manip.c
@@ -307,3 +307,44 @@ struct logical_volume *first_replicator_dev(const struct logical_volume *lv)
 
 	return NULL;
 }
+
+/* Add to sorted list */
+struct vg_name_list *vg_name_list_add(struct dm_pool *mem, struct dm_list *l, const char *name)
+{
+	struct vg_name_list *vnl, *ins;
+
+	/* Already in the list */
+	if ((vnl = vg_name_list_lookup(l, name)))
+		return vnl;
+
+	if (!(vnl = dm_pool_alloc(mem, sizeof(*vnl))))
+		return_NULL;
+
+	if (!(vnl->name = dm_pool_strdup(mem, name))) {
+		dm_pool_free(mem, vnl);
+		return_NULL;
+	}
+
+	vnl->vg = NULL;
+	dm_list_iterate_items(ins, l)
+		if (strcmp(name, ins->name) < 0) {
+			l = &ins->list;
+			break;
+		}
+
+	dm_list_add(l, &vnl->list);
+
+	return vnl;
+}
+
+/* Lookup element with given name in ordered vg_name_list */
+struct vg_name_list *vg_name_list_lookup(struct dm_list *l, const char *name)
+{
+	struct vg_name_list *vnl;
+
+	dm_list_iterate_items(vnl, l)
+		if (!strcmp(name, vnl->name))
+			return vnl;
+
+	return NULL;
+}
-- 
1.6.5.3


