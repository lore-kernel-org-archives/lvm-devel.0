From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu,  3 Mar 2016 13:19:33 +0000 (UTC)
Subject: master - metadata: add add_glv_to_indirect_glvs and remove_glv_from_indirect_glvs
Message-ID: <20160303131933.4575F61B8D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=eeaa5a4481e04c0131152fd88e6ea2651949ae35
Commit:        eeaa5a4481e04c0131152fd88e6ea2651949ae35
Parent:        937f72b168302c9d8acb1a8e06525106df00fe2f
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Mar 1 15:19:57 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Mar 3 11:26:51 2016 +0100

metadata: add add_glv_to_indirect_glvs and remove_glv_from_indirect_glvs

The add_glv_to_indirect_glvs is a helper function that registers a
volume represented by struct generic_logical_volume instance ("glv")
as an indirect user of another volume ("origin_glv") and vice versa -
it also registers the other volume ("origin_glv") as indirect_origin
of user volume ("glv").

The remove_glv_from_indirect_glvs does the opposite.
---
 lib/metadata/lv_manip.c |   58 +++++++++++++++++++++++++++++++++++++++++++++++
 lib/metadata/metadata.h |    6 +++++
 2 files changed, 64 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index da60770..399668c 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -5343,6 +5343,64 @@ struct glv_list *get_or_create_glvl(struct dm_pool *mem, struct logical_volume *
 	return glvl;
 }
 
+int add_glv_to_indirect_glvs(struct dm_pool *mem,
+				  struct generic_logical_volume *origin_glv,
+				  struct generic_logical_volume *glv)
+{
+	struct glv_list *glvl;
+
+	if (!(glvl = dm_pool_zalloc(mem, sizeof(struct glv_list)))) {
+		log_error("Failed to allocate generic volume list item "
+			  "for indirect glv %s", glv->is_historical ? glv->historical->name
+								    : glv->live->name);
+		return 0;
+	}
+
+	glvl->glv = glv;
+
+	if (glv->is_historical)
+		glv->historical->indirect_origin = origin_glv;
+	else
+		first_seg(glv->live)->indirect_origin = origin_glv;
+
+	if (origin_glv) {
+		if (origin_glv->is_historical)
+			dm_list_add(&origin_glv->historical->indirect_glvs, &glvl->list);
+		else
+			dm_list_add(&origin_glv->live->indirect_glvs, &glvl->list);
+	}
+
+	return 1;
+}
+
+int remove_glv_from_indirect_glvs(struct generic_logical_volume *origin_glv,
+				  struct generic_logical_volume *glv)
+{
+	struct glv_list *glvl, *tglvl;
+	struct dm_list *list = origin_glv->is_historical ? &origin_glv->historical->indirect_glvs
+							 : &origin_glv->live->indirect_glvs;
+
+	dm_list_iterate_items_safe(glvl, tglvl, list) {
+		if (glvl->glv != glv)
+			continue;
+
+		dm_list_del(&glvl->list);
+
+		if (glvl->glv->is_historical)
+			glvl->glv->historical->indirect_origin = NULL;
+		else
+			first_seg(glvl->glv->live)->indirect_origin = NULL;
+
+		return 1;
+	}
+
+	log_error(INTERNAL_ERROR "%s logical volume %s is not a user of %s.",
+		  glv->is_historical ? "historical" : "Live",
+		  glv->is_historical ? glv->historical->name : glv->live->name,
+		  origin_glv->is_historical ? origin_glv->historical->name : origin_glv->live->name);
+	return 0;
+}
+
 struct logical_volume *alloc_lv(struct dm_pool *mem)
 {
 	struct logical_volume *lv;
diff --git a/lib/metadata/metadata.h b/lib/metadata/metadata.h
index 91e5961..33cbfa6 100644
--- a/lib/metadata/metadata.h
+++ b/lib/metadata/metadata.h
@@ -440,6 +440,12 @@ int lv_split_segment(struct logical_volume *lv, uint32_t le);
 int add_seg_to_segs_using_this_lv(struct logical_volume *lv, struct lv_segment *seg);
 int remove_seg_from_segs_using_this_lv(struct logical_volume *lv, struct lv_segment *seg);
 
+int add_glv_to_indirect_glvs(struct dm_pool *mem,
+			     struct generic_logical_volume *origin_glv,
+			     struct generic_logical_volume *user_glv);
+int remove_glv_from_indirect_glvs(struct generic_logical_volume *glv,
+				  struct generic_logical_volume *user_glv);
+
 int for_each_sub_lv_except_pools(struct logical_volume *lv,
 				 int (*fn)(struct logical_volume *lv, void *data),
 				 void *data);


