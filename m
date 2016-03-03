From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu,  3 Mar 2016 13:19:44 +0000 (UTC)
Subject: master - metadata: add find_historical_glv fn
Message-ID: <20160303131944.55B9F60091@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c45af2df4ee1f3a7cf1e979ce5312acdc392ba68
Commit:        c45af2df4ee1f3a7cf1e979ce5312acdc392ba68
Parent:        a0842d1f259c467cb02a8dd94e3a53f543ade7fb
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Mar 1 15:21:21 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Mar 3 13:46:39 2016 +0100

metadata: add find_historical_glv fn

The find_historical_glv is helper function that looks up historical
LV in struct volume_group's historical_lvs list and returns it if
found.
---
 lib/metadata/metadata-exported.h |    5 +++++
 lib/metadata/metadata.c          |   26 ++++++++++++++++++++++++++
 2 files changed, 31 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 7f1d43c..afd4723 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -1026,6 +1026,11 @@ struct lv_list *find_lv_in_vg(const struct volume_group *vg,
 /* FIXME Merge these functions with ones above */
 struct logical_volume *find_lv(const struct volume_group *vg,
 			       const char *lv_name);
+
+struct generic_logical_volume *find_historical_glv(const struct volume_group *vg,
+						    const char *historical_lv_name,
+						    struct glv_list **glvl_found);
+
 struct physical_volume *find_pv_by_name(struct cmd_context *cmd,
 					const char *pv_name,
 					int allow_orphan, int allow_unformatted);
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 0d2211a..8b3c53c 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -2120,6 +2120,32 @@ struct logical_volume *find_lv(const struct volume_group *vg,
 	return lvl ? lvl->lv : NULL;
 }
 
+struct generic_logical_volume *find_historical_glv(const struct volume_group *vg,
+					       const char *historical_lv_name,
+					       struct glv_list **glvl_found)
+{
+	struct glv_list *glvl;
+	const char *ptr;
+
+	/* Use last component */
+	if ((ptr = strrchr(historical_lv_name, '/')))
+		ptr++;
+	else
+		ptr = historical_lv_name;
+
+	dm_list_iterate_items(glvl, &vg->historical_lvs) {
+		if (!strcmp(glvl->glv->historical->name, ptr)) {
+			if (glvl_found)
+				*glvl_found = glvl;
+			return glvl->glv;
+		}
+	}
+
+	if (glvl_found)
+		*glvl_found = NULL;
+	return NULL;
+}
+
 struct physical_volume *find_pv(struct volume_group *vg, struct device *dev)
 {
 	struct pv_list *pvl;


