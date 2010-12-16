From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 16 Dec 2010 11:36:20 +0100
Subject: [PATCH 12/20] Add test for allocation results for node clonning
In-Reply-To: <cover.1292495195.git.zkabelac@redhat.com>
References: <cover.1292495195.git.zkabelac@redhat.com>
Message-ID: <d7b14d331c5c974c72566293af539c8944d9f5cd.1292495195.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add checks for clonning allocation a fail-out when something is
not allocated correctly.

Also move var declaration at begining of function.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/config/config.c |   47 ++++++++++++++++++++++++++++++-----------------
 1 files changed, 30 insertions(+), 17 deletions(-)

diff --git a/lib/config/config.c b/lib/config/config.c
index 1df8d09..56216a2 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -1330,30 +1330,43 @@ unsigned maybe_config_section(const char *str, unsigned len)
 
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
+	if (!(new_cv = _create_value(mem)))
+		return_NULL;
+
+	new_cv->type = v->type;
+	if (v->type == CFG_STRING) {
+		if (!(new_cv->v.str = dm_pool_strdup(mem, v->v.str)))
+			return_NULL;
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
+	if (!(new_cn = _create_node(mem)))
+		return_NULL;
+
+	if ((cn->key && !(new_cn->key = dm_pool_strdup(mem, cn->key))) ||
+	    (cn->child && !(new_cn->child = clone_config_node(mem, cn->child, 1))) ||
+	    (cn->v && !(new_cn->v = _clone_config_value(mem, cn->v))) ||
+	    (siblings && cn->sib && !(new_cn->sib = clone_config_node(mem, cn->sib, siblings))))
+		return_NULL; /* 'new_cn' released with mem pool */
+
+	return new_cn;
 }
-- 
1.7.3.3


