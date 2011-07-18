From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 18 Jul 2011 13:26:10 -0000
Subject: LVM2/lib cache/lvmcache.c config/config.c conf ...
Message-ID: <20110718132610.3832.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2011-07-18 13:26:09

Modified files:
	lib/cache      : lvmcache.c 
	lib/config     : config.c config.h 
	lib/unknown    : unknown.c 

Log message:
	Slightly refactor the config code to allow better reuse (no functional change).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.c.diff?cvsroot=lvm2&r1=1.111&r2=1.112
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/config.c.diff?cvsroot=lvm2&r1=1.97&r2=1.98
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/config.h.diff?cvsroot=lvm2&r1=1.33&r2=1.34
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/unknown/unknown.c.diff?cvsroot=lvm2&r1=1.6&r2=1.7

--- LVM2/lib/cache/lvmcache.c	2011/06/01 19:29:32	1.111
+++ LVM2/lib/cache/lvmcache.c	2011/07/18 13:26:08	1.112
@@ -671,8 +671,7 @@
 	/* Build config tree from vgmetadata, if not yet cached */
 	if (!vginfo->cft &&
 	    !(vginfo->cft =
-	      create_config_tree_from_string(fid->fmt->cmd,
-					     vginfo->vgmetadata)))
+	      create_config_tree_from_string(vginfo->vgmetadata)))
 		goto_bad;
 
 	if (!(vg = import_vg_from_config_tree(vginfo->cft, fid)))
--- LVM2/lib/config/config.c	2011/05/24 14:11:39	1.97
+++ LVM2/lib/config/config.c	2011/07/18 13:26:08	1.98
@@ -159,8 +159,7 @@
 	return 1;
 }
 
-struct config_tree *create_config_tree_from_string(struct cmd_context *cmd __attribute__((unused)),
-						   const char *config_settings)
+struct config_tree *create_config_tree_from_string(const char *config_settings)
 {
 	struct cs *c;
 	struct config_tree *cft;
@@ -191,7 +190,7 @@
 int override_config_tree_from_string(struct cmd_context *cmd,
 				     const char *config_settings)
 {
-	if (!(cmd->cft_override = create_config_tree_from_string(cmd,config_settings))) {
+	if (!(cmd->cft_override = create_config_tree_from_string(config_settings))) {
 		log_error("Failed to set overridden configuration entries.");
 		return 1;
 	}
@@ -1364,8 +1363,8 @@
 	return new_cv;
 }
 
-struct config_node *clone_config_node(struct dm_pool *mem, const struct config_node *cn,
-				      int siblings)
+struct config_node *clone_config_node_with_mem(struct dm_pool *mem, const struct config_node *cn,
+					       int siblings)
 {
 	struct config_node *new_cn;
 
@@ -1383,9 +1382,45 @@
 	}
 
 	if ((cn->v && !(new_cn->v = _clone_config_value(mem, cn->v))) ||
-	    (cn->child && !(new_cn->child = clone_config_node(mem, cn->child, 1))) ||
-	    (siblings && cn->sib && !(new_cn->sib = clone_config_node(mem, cn->sib, siblings))))
+	    (cn->child && !(new_cn->child = clone_config_node_with_mem(mem, cn->child, 1))) ||
+	    (siblings && cn->sib && !(new_cn->sib = clone_config_node_with_mem(mem, cn->sib, siblings))))
 		return_NULL; /* 'new_cn' released with mem pool */
 
 	return new_cn;
 }
+
+struct config_node *clone_config_node(struct config_tree *cft, const struct config_node *node, int sib)
+{
+	struct cs *c = (struct cs *) cft;
+	return clone_config_node_with_mem(c->mem, node, sib);
+}
+
+struct config_node *create_config_node(struct config_tree *cft, const char *key)
+{
+	struct cs *c = (struct cs *) cft;
+	struct config_node *cn;
+
+	if (!(cn = _create_node(c->mem))) {
+		log_error("Failed to create config node.");
+		return NULL;
+	}
+	if (!(cn->key = dm_pool_strdup(c->mem, key))) {
+		log_error("Failed to create config node's key.");
+		return NULL;
+	}
+	if (!(cn->v = _create_value(c->mem))) {
+		log_error("Failed to create config node's value.");
+		return NULL;
+	}
+	cn->parent = NULL;
+	cn->v->type = CFG_INT;
+	cn->v->v.i = 0;
+	cn->v->next = NULL;
+	return cn;
+}
+
+struct dm_pool *config_tree_memory(struct config_tree *cft)
+{
+	struct cs *c = (struct cs *) cft;
+	return c->mem;
+}
--- LVM2/lib/config/config.h	2011/02/18 14:08:23	1.33
+++ LVM2/lib/config/config.h	2011/07/18 13:26:08	1.34
@@ -54,8 +54,8 @@
 };
 
 struct config_tree *create_config_tree(const char *filename, int keep_open);
-struct config_tree *create_config_tree_from_string(struct cmd_context *cmd,
-						   const char *config_settings);
+struct config_tree *create_config_tree_from_string(const char *config_settings);
+
 int override_config_tree_from_string(struct cmd_context *cmd,
 				     const char *config_settings);
 void destroy_config_tree(struct config_tree *cft);
@@ -120,6 +120,13 @@
 
 const char *config_parent_name(const struct config_node *n);
 
-struct config_node *clone_config_node(struct dm_pool *mem, const struct config_node *cn,
+struct config_node *clone_config_node_with_mem(struct dm_pool *mem,
+					       const struct config_node *node,
+					       int siblings);
+struct config_node *create_config_node(struct config_tree *cft, const char *key);
+struct config_node *clone_config_node(struct config_tree *cft, const struct config_node *cn,
 				      int siblings);
+
+struct dm_pool *config_tree_memory(struct config_tree *cft);
+
 #endif
--- LVM2/lib/unknown/unknown.c	2011/06/17 14:14:21	1.6
+++ LVM2/lib/unknown/unknown.c	2011/07/18 13:26:09	1.7
@@ -42,7 +42,7 @@
 		if (!strcmp(current->key, "type") || !strcmp(current->key, "start_extent") ||
 		    !strcmp(current->key, "tags") || !strcmp(current->key, "extent_count"))
 			continue;
-		new = clone_config_node(seg->lv->vg->vgmem, current, 0);
+		new = clone_config_node_with_mem(seg->lv->vg->vgmem, current, 0);
 		if (!new)
 			return_0;
 		if (last)


