From: David Teigland <teigland@redhat.com>
Date: Tue, 26 Mar 2013 16:09:26 -0500
Subject: [PATCH 6/8] toollib: read vgs before processing
Message-ID: <1364332168-24676-7-git-send-email-teigland@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

In process_each_vg,lv, read all vgs, then
process each, rather than reading and
processing one at a time.

Locking is currently hidden within vg_read,
so another effect of this change is that all
locks are acquired and held together at the
start rather than being acquired and released
individually.
---
 lib/datastruct/str_list.c |  38 +++++++++++
 lib/datastruct/str_list.h |   1 +
 tools/toollib.c           | 169 ++++++++++++++++++++++++++++++++++++----------
 3 files changed, 173 insertions(+), 35 deletions(-)

diff --git a/lib/datastruct/str_list.c b/lib/datastruct/str_list.c
index dfce69c..374de5c 100644
--- a/lib/datastruct/str_list.c
+++ b/lib/datastruct/str_list.c
@@ -50,6 +50,44 @@ int str_list_add(struct dm_pool *mem, struct dm_list *sll, const char *str)
 	return 1;
 }
 
+int str_list_add_order(struct dm_pool *mem, struct dm_list *sll, const char *str)
+{
+	struct str_list *sl_tmp;
+	struct str_list *sl_new;
+
+	if (!str)
+		return_0;
+
+	/* Already in list? */
+	if (str_list_match_item(sll, str))
+		return 1;
+
+	if (!(sl_new = dm_pool_alloc(mem, sizeof(*sl_new))))
+		return_0;
+
+	sl_new->str = str;
+
+	if (dm_list_empty(sll)) {
+		dm_list_add(sll, &sl_new->list);
+		return 1;
+	}
+
+	dm_list_iterate_items(sl_tmp, sll) {
+		/*
+		 * If new str (s1) is less than existing/tmp str (s2),
+		 * then break and insert new before existing.
+		 */
+		if (strcmp(sl_new->str, sl_tmp->str) < 0)
+			break;
+	}
+
+	sl_new->list.n    = &sl_tmp->list;
+	sl_new->list.p    = sl_tmp->list.p;
+	sl_tmp->list.p->n = &sl_new->list;
+	sl_tmp->list.p    = &sl_new->list;
+	return 1;
+}
+
 void str_list_del(struct dm_list *sll, const char *str)
 {
 	struct dm_list *slh, *slht;
diff --git a/lib/datastruct/str_list.h b/lib/datastruct/str_list.h
index 42f47da..bab6d9b 100644
--- a/lib/datastruct/str_list.h
+++ b/lib/datastruct/str_list.h
@@ -18,6 +18,7 @@
 
 struct dm_list *str_list_create(struct dm_pool *mem);
 int str_list_add(struct dm_pool *mem, struct dm_list *sll, const char *str);
+int str_list_add_order(struct dm_pool *mem, struct dm_list *sll, const char *str);
 void str_list_del(struct dm_list *sll, const char *str);
 int str_list_match_item(const struct dm_list *sll, const char *str);
 int str_list_match_list(const struct dm_list *sll, const struct dm_list *sll2, const char **tag_matched);
diff --git a/tools/toollib.c b/tools/toollib.c
index b593b93..65501e8 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -16,6 +16,11 @@
 #include "tools.h"
 #include <sys/stat.h>
 
+struct vg_list {
+	struct dm_list list;
+	struct volume_group *vg;
+};
+
 const char *command_name(struct cmd_context *cmd)
 {
 	return cmd->command->name;
@@ -1419,8 +1424,8 @@ static int get_arg_vgnames(struct cmd_context *cmd,
 				ret_max = EINVALID_CMD_LINE;
 			continue;
 		}
-		if (!str_list_add(cmd->mem, arg_vgnames,
-				  dm_pool_strdup(cmd->mem, vg_name))) {
+		if (!str_list_add_order(cmd->mem, arg_vgnames,
+					dm_pool_strdup(cmd->mem, vg_name))) {
 			log_error("strlist allocation failed");
 			return ECMD_FAILED;
 		}
@@ -1449,8 +1454,8 @@ static int get_all_vgnames(struct cmd_context *cmd, struct dm_list *all_vgnames)
 		if (!vg_name)
 			continue;
 
-		if (!str_list_add(cmd->mem, all_vgnames,
-				  dm_pool_strdup(cmd->mem, vg_name))) {
+		if (!str_list_add_order(cmd->mem, all_vgnames,
+					dm_pool_strdup(cmd->mem, vg_name))) {
 			log_error("strlist allocation failed");
 			return ECMD_FAILED;
 		}
@@ -1459,14 +1464,79 @@ out:
 	return ret_max;
 }
 
+static struct vg_list *find_vgl(struct dm_list *vgl_list, const char *vg_name)
+{
+	struct vg_list *vgl;
+
+	dm_list_iterate_items(vgl, vgl_list) {
+		if (!strcmp(vg_name, vgl->vg->name))
+			return vgl;
+	}
+	return NULL;
+}
+
+static void release_vg_list(struct cmd_context *cmd, struct dm_list *vgl_list)
+{
+	struct vg_list *vgl;
+
+	dm_list_iterate_items(vgl, vgl_list) {
+		if (vg_read_error(vgl->vg))
+			release_vg(vgl->vg);
+		else
+			unlock_and_release_vg(cmd, vgl->vg, vgl->vg->name);
+	}
+}
+
+static int read_vg_name_list(struct cmd_context *cmd, uint32_t flags,
+			     struct dm_list *vg_name_list,
+			     struct dm_list *vgl_list)
+{
+	struct volume_group *vg;
+	struct vg_list *vgl;
+	struct str_list *sl;
+	const char *vg_name;
+	int ret_max = ECMD_PROCESSED;
+
+	dm_list_iterate_items(sl, vg_name_list) {
+		vg_name = sl->str;
+
+		if (!(vgl = dm_pool_alloc(cmd->mem, sizeof(*vgl)))) {
+			log_error("vg_list alloc failed");
+			release_vg_list(cmd, vgl_list);
+			return ECMD_FAILED;
+		}
+
+		vg = vg_read(cmd, vg_name, NULL, flags);
+		if (vg_read_error(vg)) {
+			if (!((flags & READ_ALLOW_INCONSISTENT) &&
+			     (vg_read_error(vg) == FAILED_INCONSISTENT))) {
+				ret_max = ECMD_FAILED;
+				release_vg(vg);
+				stack;
+				continue;
+			}
+		}
+
+		vgl->vg = vg;
+		dm_list_add(vgl_list, &vgl->list);
+
+		if (sigint_caught())
+			break;
+	}
+
+	return ret_max;
+}
+
 static int process_vg_name_list(struct cmd_context *cmd, uint32_t flags,
 				struct dm_list *vg_name_list,
 				struct dm_list *arg_vgnames,
 				struct dm_list *arg_tags,
+				struct dm_list *vgl_list,
 				void *handle,
 				process_single_vg_fn_t process_single_vg)
 {
 	struct volume_group *vg;
+	struct vg_list *vgl;
 	struct str_list *sl;
 	const char *vgname;
 	int ret_max = ECMD_PROCESSED;
@@ -1480,16 +1550,11 @@ static int process_vg_name_list(struct cmd_context *cmd, uint32_t flags,
 	dm_list_iterate_items(sl, vg_name_list) {
 		vgname = sl->str;
 
-		vg = vg_read(cmd, vgname, NULL, flags);
-		if (vg_read_error(vg)) {
-			if (!((flags & READ_ALLOW_INCONSISTENT) &&
-			     (vg_read_error(vg) == FAILED_INCONSISTENT))) {
-				ret_max = ECMD_FAILED;
-				release_vg(vg);
-				stack;
-				continue;
-			}
-		}
+		vgl = find_vgl(vgl_list, vgname);
+		if (!vgl)
+			continue;
+
+		vg = vgl->vg;
 
 		process_vg = 0;
 
@@ -1507,11 +1572,6 @@ static int process_vg_name_list(struct cmd_context *cmd, uint32_t flags,
 		if (process_vg)
 			ret = process_single_vg(cmd, vgname, vg, handle);
 
-		if (vg_read_error(vg))
-			release_vg(vg);
-		else
-			unlock_and_release_vg(cmd, vg, vgname);
-
 		if (ret > ret_max)
 			ret_max = ret;
 		if (sigint_caught())
@@ -1529,12 +1589,15 @@ int process_each_vg(struct cmd_context *cmd,
 	struct dm_list all_vgnames;
 	struct dm_list arg_vgnames;
 	struct dm_list arg_tags;
+	struct dm_list vgl_list;
 	struct dm_list *vg_name_list;
+	int ret_max = ECMD_PROCESSED;
 	int ret;
 
 	dm_list_init(&all_vgnames);
 	dm_list_init(&arg_vgnames);
 	dm_list_init(&arg_tags);
+	dm_list_init(&vgl_list);
 
 	ret = get_arg_vgnames(cmd, argc, argv, &arg_vgnames, &arg_tags);
 	if (ret != ECMD_PROCESSED)
@@ -1557,10 +1620,27 @@ int process_each_vg(struct cmd_context *cmd,
 	else
 		vg_name_list = &arg_vgnames;
 
+	ret = read_vg_name_list(cmd, flags, vg_name_list, &vgl_list);
+
+	if (ret > ret_max)
+		ret_max = ret;
+	if (sigint_caught())
+		goto out;
+
+	if (dm_list_empty(&vgl_list)) {
+		stack;
+		goto out;
+	}
+
 	ret = process_vg_name_list(cmd, flags, vg_name_list,
-				   &arg_vgnames, &arg_tags,
-				   handle, process_single_vg);
-	return ret;
+			           &arg_vgnames, &arg_tags,
+			           &vgl_list,
+			           handle, process_single_vg);
+	if (ret > ret_max)
+		ret_max = ret;
+out:
+	release_vg_list(cmd, &vgl_list);
+	return ret_max;
 }
 
 /*
@@ -1637,8 +1717,8 @@ static int get_arg_lvnames(struct cmd_context *cmd,
 		} else
 			lv_name = NULL;
 
-		if (!str_list_add(cmd->mem, arg_vgnames,
-				  dm_pool_strdup(cmd->mem, vgname))) {
+		if (!str_list_add_order(cmd->mem, arg_vgnames,
+					dm_pool_strdup(cmd->mem, vgname))) {
 			log_error("strlist allocation failed");
 			return ECMD_FAILED;
 		}
@@ -1671,10 +1751,12 @@ static int process_lv_vg_name_list(struct cmd_context *cmd, uint32_t flags,
 				   struct dm_list *arg_vgnames,
 				   struct dm_list *arg_lvnames,
 				   struct dm_list *arg_tags,
+				   struct dm_list *vgl_list,
 				   void *handle,
 				   process_single_lv_fn_t process_single_lv)
 {
 	struct volume_group *vg;
+	struct vg_list *vgl;
 	struct str_list *sl, *sll;
 	struct dm_list *tags_arg;
 	struct dm_list lvnames;
@@ -1685,6 +1767,12 @@ static int process_lv_vg_name_list(struct cmd_context *cmd, uint32_t flags,
 	dm_list_iterate_items(sl, vg_name_list) {
 		vgname = sl->str;
 
+		vgl = find_vgl(vgl_list, vgname);
+		if (!vgl)
+			continue;
+
+		vg = vgl->vg;
+
 		/*
 		 * arg_lvnames contains some elements that are just "vgname"
 		 * which means process all lvs in the vg.  Other elements
@@ -1716,19 +1804,9 @@ static int process_lv_vg_name_list(struct cmd_context *cmd, uint32_t flags,
 			}
 		}
 
-		vg = vg_read(cmd, vgname, NULL, flags);
-		if (vg_read_error(vg)) {
-			ret_max = ECMD_FAILED;
-			release_vg(vg);
-			stack;
-			continue;
-		}
-
 		ret = process_each_lv_in_vg(cmd, vg, &lvnames, tags_arg,
 					    handle, process_single_lv);
 
-		unlock_and_release_vg(cmd, vg, vgname);
-
 		if (ret > ret_max)
 			ret_max = ret;
 		if (sigint_caught())
@@ -1747,13 +1825,16 @@ int process_each_lv(struct cmd_context *cmd,
 	struct dm_list arg_vgnames;
 	struct dm_list arg_lvnames;
 	struct dm_list arg_tags;
+	struct dm_list vgl_list;
 	struct dm_list *vg_name_list;
+	int ret_max = ECMD_PROCESSED;
 	int ret;
 
 	dm_list_init(&all_vgnames);
 	dm_list_init(&arg_vgnames);
 	dm_list_init(&arg_lvnames);
 	dm_list_init(&arg_tags);
+	dm_list_init(&vgl_list);
 
 	ret = get_arg_lvnames(cmd, argc, argv,
 			      &arg_vgnames, &arg_lvnames, &arg_tags);
@@ -1777,9 +1858,27 @@ int process_each_lv(struct cmd_context *cmd,
 	else
 		vg_name_list = &arg_vgnames;
 
+	ret = read_vg_name_list(cmd, flags, vg_name_list, &vgl_list);
+
+	if (ret > ret_max)
+		ret_max = ret;
+	if (sigint_caught())
+		goto out;
+
+	if (dm_list_empty(&vgl_list)) {
+		stack;
+		goto out;
+	}
+
 	ret = process_lv_vg_name_list(cmd, flags, vg_name_list,
 				      &arg_vgnames, &arg_lvnames, &arg_tags,
+				      &vgl_list,
 				      handle, process_single_lv);
-	return ret;
+	if (ret > ret_max)
+		ret_max = ret;
+out:
+	release_vg_list(cmd, &vgl_list);
+
+	return ret_max;
 }
 
-- 
1.8.1.rc1.5.g7e0651a


