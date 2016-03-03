From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu,  3 Mar 2016 13:19:31 +0000 (UTC)
Subject: master - metadata: add get_or_create_glv and get_or_create_glvl
Message-ID: <20160303131931.2F58A61B8D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=937f72b168302c9d8acb1a8e06525106df00fe2f
Commit:        937f72b168302c9d8acb1a8e06525106df00fe2f
Parent:        e573eca554374ba6889a7f89fcb9850ae13c793e
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Mar 1 15:19:23 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Mar 3 11:26:51 2016 +0100

metadata: add get_or_create_glv and get_or_create_glvl

The get_or_create_glv is helper function that retrieves any existing
generic_logical_volume wrapper for the LV. If the wrapper does not exist
yet, it's created.

The get_org_create_glvl is the same as get_or_create_glv but it creates
the glv_list wrapper in addition so it can be added to a list.
---
 lib/metadata/lv_manip.c          |   36 ++++++++++++++++++++++++++++++++++++
 lib/metadata/metadata-exported.h |    3 +++
 2 files changed, 39 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 069042c..da60770 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -5307,6 +5307,42 @@ char *generate_lv_name(struct volume_group *vg, const char *format,
 	return buffer;
 }
 
+struct generic_logical_volume *get_or_create_glv(struct dm_pool*mem, struct logical_volume *lv, int *glv_created)
+{
+	struct generic_logical_volume *glv;
+
+	if (!(glv = lv->this_glv)) {
+		if (!(glv = dm_pool_zalloc(mem, sizeof(struct generic_logical_volume)))) {
+			log_error("Failed to allocate generic logical volume structure.");
+			return NULL;
+		}
+		glv->live = lv;
+		lv->this_glv = glv;
+		if (glv_created)
+			*glv_created = 1;
+	} else if (glv_created)
+		*glv_created = 0;
+
+	return glv;
+}
+
+struct glv_list *get_or_create_glvl(struct dm_pool *mem, struct logical_volume *lv, int *glv_created)
+{
+	struct glv_list *glvl;
+
+	if (!(glvl = dm_pool_zalloc(mem, sizeof(struct glv_list)))) {
+		log_error("Failed to allocate generic logical volume list item.");
+		return NULL;
+	}
+
+	if (!(glvl->glv = get_or_create_glv(mem, lv, glv_created))) {
+		dm_pool_free(mem, glvl);
+		return_NULL;
+	}
+
+	return glvl;
+}
+
 struct logical_volume *alloc_lv(struct dm_pool *mem)
 {
 	struct logical_volume *lv;
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 97cba51..76597ba 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -1238,6 +1238,9 @@ dm_percent_t copy_percent(const struct logical_volume *lv_mirr);
 char *generate_lv_name(struct volume_group *vg, const char *format,
 		       char *buffer, size_t len);
 
+struct generic_logical_volume *get_or_create_glv(struct dm_pool *mem, struct logical_volume *lv, int *glv_created);
+struct glv_list *get_or_create_glvl(struct dm_pool *mem, struct logical_volume *lv, int *glv_created);
+
 /*
 * Begin skeleton for external LVM library
 */


