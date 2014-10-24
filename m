From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 24 Oct 2014 14:40:38 +0000 (UTC)
Subject: master - cleanup: simplier lv name construction
Message-ID: <20141024144038.E92D660CE2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b726003b859a5e2f7580855c10fe201f67e1dc06
Commit:        b726003b859a5e2f7580855c10fe201f67e1dc06
Parent:        9e85dbbfd0d965215a9fce55c29cfb967d0d6103
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 24 14:22:13 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 24 16:39:31 2014 +0200

cleanup: simplier lv name construction

Using NAME_LEN max lv name size.
---
 lib/metadata/lv_manip.c |   24 ++++++------------------
 1 files changed, 6 insertions(+), 18 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 244db1b..3d6bb26 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -6053,8 +6053,7 @@ struct logical_volume *insert_layer_for_lv(struct cmd_context *cmd,
 {
 	static const char _suffixes[][8] = { "_tdata", "_cdata", "_corig" };
 	int r;
-	char *name;
-	size_t len;
+	char name[NAME_LEN];
 	struct dm_str_list *sl;
 	struct logical_volume *layer_lv;
 	struct segment_type *segtype;
@@ -6063,16 +6062,8 @@ struct logical_volume *insert_layer_for_lv(struct cmd_context *cmd,
 	unsigned exclusive = 0;
 
 	/* create an empty layer LV */
-	len = strlen(lv_where->name) + 32;
-	if (!(name = alloca(len))) {
-		log_error("layer name allocation failed. "
-			  "Remove new LV and retry.");
-		return NULL;
-	}
-
-	if (dm_snprintf(name, len, "%s%s", lv_where->name, layer_suffix) < 0) {
-		log_error("layer name allocation failed. "
-			  "Remove new LV and retry.");
+	if (dm_snprintf(name, sizeof(name), "%s%s", lv_where->name, layer_suffix) < 0) {
+		log_error("Layered name is too long. Please use shorter LV name.");
 		return NULL;
 	}
 
@@ -6453,8 +6444,7 @@ static struct logical_volume *_create_virtual_origin(struct cmd_context *cmd,
 						     uint64_t voriginextents)
 {
 	const struct segment_type *segtype;
-	size_t len;
-	char *vorigin_name;
+	char vorigin_name[NAME_LEN];
 	struct logical_volume *lv;
 
 	if (!(segtype = get_segtype_from_string(cmd, "zero"))) {
@@ -6462,10 +6452,8 @@ static struct logical_volume *_create_virtual_origin(struct cmd_context *cmd,
 		return NULL;
 	}
 
-	len = strlen(lv_name) + 32;
-	if (!(vorigin_name = alloca(len)) ||
-	    dm_snprintf(vorigin_name, len, "%s_vorigin", lv_name) < 0) {
-		log_error("Virtual origin name allocation failed.");
+	if (dm_snprintf(vorigin_name, sizeof(vorigin_name), "%s_vorigin", lv_name) < 0) {
+		log_error("Virtual origin name is too long.");
 		return NULL;
 	}
 


