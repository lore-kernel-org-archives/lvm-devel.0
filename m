From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 25 Feb 2016 22:36:28 +0000 (UTC)
Subject: master - cleanup: poll better check for internal errors
Message-ID: <20160225223628.137F5602B1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5c29b54d4dbf0a94525172f5526fd5ff7996de48
Commit:        5c29b54d4dbf0a94525172f5526fd5ff7996de48
Parent:        cdcf4cc794827e61a1babd549f4a0ef4e6439165
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Feb 25 13:31:31 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Feb 25 23:30:25 2016 +0100

cleanup: poll better check for internal errors

---
 tools/lvconvert.c  |   37 ++++++++++++++-------------------
 tools/polldaemon.c |   20 +++++++++---------
 tools/pvmove.c     |   57 +++++++++++++++++++++-------------------------------
 3 files changed, 49 insertions(+), 65 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 23f3cf4..f6ea614 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -722,43 +722,40 @@ static struct poll_functions _lvconvert_thin_merge_fns = {
 	.finish_copy = lvconvert_merge_finish,
 };
 
-static void _destroy_id(struct cmd_context *cmd, struct poll_operation_id *id)
-{
-	if (!id)
-		return;
-
-	dm_pool_free(cmd->mem, (void *)id);
-}
-
 static struct poll_operation_id *_create_id(struct cmd_context *cmd,
 					    const char *vg_name,
 					    const char *lv_name,
 					    const char *uuid)
 {
+	struct poll_operation_id *id;
 	char lv_full_name[NAME_LEN];
-	struct poll_operation_id *id = dm_pool_alloc(cmd->mem, sizeof(struct poll_operation_id));
-	if (!id) {
-		log_error("Poll operation ID allocation failed.");
+
+	if (!vg_name || !lv_name || !uuid) {
+		log_error(INTERNAL_ERROR "Wrong params for lvconvert _create_id.");
 		return NULL;
 	}
 
 	if (dm_snprintf(lv_full_name, sizeof(lv_full_name), "%s/%s", vg_name, lv_name) < 0) {
 		log_error(INTERNAL_ERROR "Name \"%s/%s\" is too long.", vg_name, lv_name);
-		_destroy_id(cmd, id);
 		return NULL;
 	}
 
-	id->display_name = dm_pool_strdup(cmd->mem, lv_full_name);
-	id->vg_name = vg_name ? dm_pool_strdup(cmd->mem, vg_name) : NULL;
-	id->lv_name = id->display_name ? strchr(id->display_name, '/') + 1 : NULL;
-	id->uuid = uuid ? dm_pool_strdup(cmd->mem, uuid) : NULL;
+	if (!(id = dm_pool_alloc(cmd->mem, sizeof(*id)))) {
+		log_error("Poll operation ID allocation failed.");
+		return NULL;
+	}
 
-	if (!id->vg_name || !id->lv_name || !id->display_name || !id->uuid) {
+	if (!(id->display_name = dm_pool_strdup(cmd->mem, lv_full_name)) ||
+	    !(id->lv_name = strchr(id->display_name, '/')) ||
+	    !(id->vg_name = dm_pool_strdup(cmd->mem, vg_name)) ||
+	    !(id->uuid = dm_pool_strdup(cmd->mem, uuid))) {
 		log_error("Failed to copy one or more poll operation ID members.");
-		_destroy_id(cmd, id);
-		id = NULL;
+		dm_pool_free(cmd->mem, id);
+		return NULL;
 	}
 
+	id->lv_name++; /* skip over '/' */
+
 	return id;
 }
 
@@ -801,8 +798,6 @@ int lvconvert_poll(struct cmd_context *cmd, struct logical_volume *lv,
 
 	r = _lvconvert_poll_by_id(cmd, id, background, is_merging_origin, is_merging_origin_thin);
 
-	_destroy_id(cmd, id);
-
 	return r;
 }
 
diff --git a/tools/polldaemon.c b/tools/polldaemon.c
index e662e16..8f1ff90 100644
--- a/tools/polldaemon.c
+++ b/tools/polldaemon.c
@@ -242,22 +242,22 @@ static struct poll_operation_id *copy_poll_operation_id(struct dm_pool *mem,
 {
 	struct poll_operation_id *copy;
 
-	if (!id)
-		return_NULL;
+	if (!id || !id->vg_name || !id->lv_name || !id->display_name || !id->uuid) {
+		log_error(INTERNAL_ERROR "Wrong params for copy_poll_operation_id.");
+		return NULL;
+	}
 
-	copy = (struct poll_operation_id *) dm_pool_alloc(mem, sizeof(struct poll_operation_id));
-	if (!copy) {
+	if (!(copy = dm_pool_alloc(mem, sizeof(*copy)))) {
 		log_error("Poll operation ID allocation failed.");
 		return NULL;
 	}
 
-	copy->display_name = id->display_name ? dm_pool_strdup(mem, id->display_name) : NULL;
-	copy->lv_name = id->lv_name ? dm_pool_strdup(mem, id->lv_name) : NULL;
-	copy->vg_name = id->vg_name ? dm_pool_strdup(mem, id->vg_name) : NULL;
-	copy->uuid = id->uuid ? dm_pool_strdup(mem, id->uuid) : NULL;
-
-	if (!copy->display_name || !copy->lv_name || !copy->vg_name || !copy->uuid) {
+	if (!(copy->display_name = dm_pool_strdup(mem, id->display_name)) ||
+	    !(copy->lv_name = dm_pool_strdup(mem, id->lv_name)) ||
+	    !(copy->vg_name = dm_pool_strdup(mem, id->vg_name)) ||
+	    !(copy->uuid = dm_pool_strdup(mem, id->uuid))) {
 		log_error("Failed to copy one or more poll_operation_id members.");
+		dm_pool_free(mem, copy);
 		return NULL;
 	}
 
diff --git a/tools/pvmove.c b/tools/pvmove.c
index b590745..b5df45a 100644
--- a/tools/pvmove.c
+++ b/tools/pvmove.c
@@ -751,35 +751,31 @@ static struct poll_functions _pvmove_fns = {
 	.finish_copy = pvmove_finish,
 };
 
-static void _destroy_id(struct cmd_context *cmd, struct poll_operation_id *id)
+static struct poll_operation_id *_pvmove_create_id(struct cmd_context *cmd,
+						   const char *pv_name,
+						   const char *vg_name,
+						   const char *lv_name,
+						   const char *uuid)
 {
-	if (!id)
-		return;
+	struct poll_operation_id *id;
 
-	dm_pool_free(cmd->mem, id);
-}
+	if (!vg_name || !lv_name || !pv_name || !uuid) {
+		log_error(INTERNAL_ERROR "Wrong params for _pvmove_create_id.");
+		return NULL;
+	}
 
-static struct poll_operation_id *_create_id(struct cmd_context *cmd,
-					    const char *pv_name,
-					    const char *vg_name,
-					    const char *lv_name,
-					    const char *uuid)
-{
-	struct poll_operation_id *id = dm_pool_alloc(cmd->mem, sizeof(struct poll_operation_id));
-	if (!id) {
+	if (!(id = dm_pool_alloc(cmd->mem, sizeof(*id)))) {
 		log_error("Poll operation ID allocation failed.");
 		return NULL;
 	}
 
-	id->vg_name = vg_name ? dm_pool_strdup(cmd->mem, vg_name) : NULL;
-	id->lv_name = lv_name ? dm_pool_strdup(cmd->mem, lv_name) : NULL;
-	id->display_name = pv_name ? dm_pool_strdup(cmd->mem, pv_name) : NULL;
-	id->uuid = uuid ? dm_pool_strdup(cmd->mem, uuid) : NULL;
-
-	if (!id->vg_name || !id->lv_name || !id->display_name || !id->uuid) {
+	if (!(id->vg_name = dm_pool_strdup(cmd->mem, vg_name)) ||
+	    !(id->lv_name = dm_pool_strdup(cmd->mem, lv_name)) ||
+	    !(id->display_name = dm_pool_strdup(cmd->mem, pv_name)) ||
+	    !(id->uuid = dm_pool_strdup(cmd->mem, uuid))) {
 		log_error("Failed to copy one or more poll operation ID members.");
-		_destroy_id(cmd, id);
-		id = NULL;
+		dm_pool_free(cmd->mem, id);
+		return NULL;
 	}
 
 	return id;
@@ -789,25 +785,18 @@ int pvmove_poll(struct cmd_context *cmd, const char *pv_name,
 		const char *uuid, const char *vg_name,
 		const char *lv_name, unsigned background)
 {
-	int r;
 	struct poll_operation_id *id = NULL;
 
-	if (uuid) {
-		id = _create_id(cmd, pv_name, vg_name, lv_name, uuid);
-		if (!id) {
-			log_error("Failed to allocate poll identifier for pvmove.");
-			return ECMD_FAILED;
-		}
+	if (uuid &&
+	    !(id = _pvmove_create_id(cmd, pv_name, vg_name, lv_name, uuid))) {
+		log_error("Failed to allocate poll identifier for pvmove.");
+		return ECMD_FAILED;
 	}
 
 	if (test_mode())
-		r = ECMD_PROCESSED;
-	else
-		r = poll_daemon(cmd, background, PVMOVE, &_pvmove_fns, "Moved", id);
-
-	_destroy_id(cmd, id);
+		return ECMD_PROCESSED;
 
-	return r;
+	return poll_daemon(cmd, background, PVMOVE, &_pvmove_fns, "Moved", id);
 }
 
 int pvmove(struct cmd_context *cmd, int argc, char **argv)


