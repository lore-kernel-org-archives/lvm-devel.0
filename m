From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 20 Dec 2010 13:53:12 -0000
Subject: LVM2 ./WHATS_NEW lib/config/config.c
Message-ID: <20101220135312.16380.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-12-20 13:53:11

Modified files:
	.              : WHATS_NEW 
	lib/config     : config.c 

Log message:
	Add checks for allocation errors in config node clonning.
	
	Add checks for clonning allocation a fail-out when something is
	not allocated correctly.
	
	Also move var declaration to the begining of the function
	and fix log_error messages.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1844&r2=1.1845
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/config.c.diff?cvsroot=lvm2&r1=1.86&r2=1.87

--- LVM2/WHATS_NEW	2010/12/20 13:45:39	1.1844
+++ LVM2/WHATS_NEW	2010/12/20 13:53:10	1.1845
@@ -1,5 +1,6 @@
 Version 2.02.79 -  
 ===================================
+  Add checks for allocation errors in config node clonning.
   Fix error path if regex engine cannot be created in _build_matcher().
   Use char* arithmetic in target_version(), _process_all(), _targets().
   Fixing const cast gcc warnings in the code.
--- LVM2/lib/config/config.c	2010/12/20 13:19:13	1.86
+++ LVM2/lib/config/config.c	2010/12/20 13:53:11	1.87
@@ -1330,30 +1330,53 @@
 
 static struct config_value *_clone_config_value(struct dm_pool *mem, const struct config_value *v)
 {
+	struct config_value *new_cv;
+
 	if (!v)
 		return NULL;
-	struct config_value *new = _create_value(mem);
-	new->type = v->type;
-	if (v->type == CFG_STRING)
-		new->v.str = dm_pool_strdup(mem, v->v.str);
-	else
-		new->v = v->v;
-	new->next = _clone_config_value(mem, v->next);
-	return new;
+
+	if (!(new_cv = _create_value(mem))) {
+		log_error("Failed to clone config value.");
+		return NULL;
+	}
+
+	new_cv->type = v->type;
+	if (v->type == CFG_STRING) {
+		if (!(new_cv->v.str = dm_pool_strdup(mem, v->v.str))) {
+			log_error("Failed to clone config string value.");
+			return NULL;
+		}
+	} else
+		new_cv->v = v->v;
+
+	if (v->next && !(new_cv->next = _clone_config_value(mem, v->next)))
+		return_NULL;
+
+	return new_cv;
 }
 
 struct config_node *clone_config_node(struct dm_pool *mem, const struct config_node *cn,
 				      int siblings)
 {
+	struct config_node *new_cn;
+
 	if (!cn)
 		return NULL;
-	struct config_node *new = _create_node(mem);
-	new->key = dm_pool_strdup(mem, cn->key);
-	new->child = clone_config_node(mem, cn->child, 1);
-	new->v = _clone_config_value(mem, cn->v);
-	if (siblings)
-		new->sib = clone_config_node(mem, cn->sib, siblings);
-	else
-		new->sib = NULL;
-	return new;
+
+	if (!(new_cn = _create_node(mem))) {
+		log_error("Failed to clone config node.");
+		return NULL;
+	}
+
+	if ((cn->key && !(new_cn->key = dm_pool_strdup(mem, cn->key)))) {
+		log_error("Failed to clone config node key.");
+		return NULL;
+	}
+
+	if ((cn->v && !(new_cn->v = _clone_config_value(mem, cn->v))) ||
+	    (cn->child && !(new_cn->child = clone_config_node(mem, cn->child, 1))) ||
+	    (siblings && cn->sib && !(new_cn->sib = clone_config_node(mem, cn->sib, siblings))))
+		return_NULL; /* 'new_cn' released with mem pool */
+
+	return new_cn;
 }


