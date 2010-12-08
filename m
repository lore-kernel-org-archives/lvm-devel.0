From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed,  8 Dec 2010 13:57:50 +0100
Subject: [PATCH 4/9] Use internal cookie for dm_tree functions
In-Reply-To: <cover.1291802397.git.zkabelac@redhat.com>
References: <cover.1291802397.git.zkabelac@redhat.com>
Message-ID: <29d02e7096fbe59365622fbc3d594ee725ee708b.1291802397.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Creative part of patchset - start to use internal cookie for:
dm_tree_deactivate_children()
dm_tree_activate_children()
dm_tree_preload_children()

Patch is not so simple (and I'm not 100% sure it covers all variants).
Tries to switch dm_tree cookie/shmid to internal one if the supplied
cookie/shmid is 0 - and it tries to remember this for preload.
It would make code easier if we would care only about the internal libdm
cookie/shmid and would not allow external dm_tree_set_cookie.
Actually is there any other user of dm_tree except for lvm?

The problem here is 'immediate' node - which resets cookie/shmid value.
So we would probably need to add another extra variable to set
whether libdm should use internal cookie/shmid numbers - code tries to
handle this case - but the best would be to drop support for external
cookie/shmid.

Note: get_lib_cookie always generate 'internal' cookie/shmid even if the user
supplies externally created cookie/shmid (or the cookie/shmid is not needed
because no device needs to be created/destroyed).

Primarily patch is able to show speedup from udev latency.

I think solution would be to hide this internal cookie/shmid in
dm_task_set_cookie() function - but I've currently decided to 'drop' this
larger code modification - as it may influence behavior of 'purely'
libdm users like Milan's dmcrypt or dmraid.

IMHO libdm should completly hide 'udev' existance and we should
provide library abstranction over udev - but that needs wider
agreement.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 libdm/libdm-deptree.c |  106 ++++++++++++++++++++++++++++++++++++++++++------
 1 files changed, 92 insertions(+), 14 deletions(-)

diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index 8d00514..d801eec 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -1102,6 +1102,36 @@ static int _suspend_node(const char *name, uint32_t major, uint32_t minor,
 	return r;
 }
 
+static int _use_lib_cookie(struct dm_tree_node *dnode, uint32_t *cookie)
+{
+	uint32_t c;
+
+	if (!get_lib_cookie(&c))
+		return_0;
+
+	*cookie = dm_tree_get_cookie(dnode);
+
+	if (!*cookie) {
+		*cookie = c;
+		dm_tree_set_cookie(dnode, c);
+	} else if (*cookie != c)
+		*cookie = 0;
+
+	return 1;
+}
+
+static int _wait_on_cookie(struct dm_tree_node *dnode, uint32_t cookie)
+{
+	if (!cookie && (cookie = dm_tree_get_cookie(dnode))) {
+		if (!dm_udev_wait(cookie))
+			return_0;
+
+		dm_tree_set_cookie(dnode, 0);
+	}
+
+	return 1;
+}
+
 /*
  * FIXME Don't attempt to deactivate known internal dependencies.
  */
@@ -1185,7 +1215,18 @@ int dm_tree_deactivate_children(struct dm_tree_node *dnode,
 				   const char *uuid_prefix,
 				   size_t uuid_prefix_len)
 {
-	return _dm_tree_deactivate_children(dnode, uuid_prefix, uuid_prefix_len, 0);
+	uint32_t lib_cookie;
+	int r;
+
+	if (!_use_lib_cookie(dnode, &lib_cookie))
+		return_0;
+
+	r = _dm_tree_deactivate_children(dnode, uuid_prefix, uuid_prefix_len, 0);
+
+	if (!_wait_on_cookie(dnode, lib_cookie))
+		stack;
+
+	return r;
 }
 
 void dm_tree_skip_lockfs(struct dm_tree_node *dnode)
@@ -1274,9 +1315,9 @@ int dm_tree_suspend_children(struct dm_tree_node *dnode,
 	return r;
 }
 
-int dm_tree_activate_children(struct dm_tree_node *dnode,
-				 const char *uuid_prefix,
-				 size_t uuid_prefix_len)
+static int _dm_tree_activate_children(struct dm_tree_node *dnode,
+				      const char *uuid_prefix,
+				      size_t uuid_prefix_len)
 {
 	int r = 1;
 	void *handle = NULL;
@@ -1297,7 +1338,7 @@ int dm_tree_activate_children(struct dm_tree_node *dnode,
 			continue;
 
 		if (dm_tree_node_num_children(child, 0))
-			if (!dm_tree_activate_children(child, uuid_prefix, uuid_prefix_len))
+			if (!_dm_tree_activate_children(child, uuid_prefix, uuid_prefix_len))
 				return_0;
 	}
 
@@ -1353,7 +1394,23 @@ int dm_tree_activate_children(struct dm_tree_node *dnode,
 		}
 	}
 
-	handle = NULL;
+	return r;
+}
+
+int dm_tree_activate_children(struct dm_tree_node *dnode,
+			      const char *uuid_prefix,
+			      size_t uuid_prefix_len)
+{
+	uint32_t lib_cookie;
+	int r;
+
+	if (!_use_lib_cookie(dnode, &lib_cookie))
+		return_0;
+
+	r = _dm_tree_activate_children(dnode, uuid_prefix, uuid_prefix_len);
+
+	if (!_wait_on_cookie(dnode, lib_cookie))
+		stack;
 
 	return r;
 }
@@ -1839,9 +1896,10 @@ out:
 	return r;
 }
 
-int dm_tree_preload_children(struct dm_tree_node *dnode,
-			     const char *uuid_prefix,
-			     size_t uuid_prefix_len)
+static int _dm_tree_preload_children(struct dm_tree_node *dnode,
+				     const char *uuid_prefix,
+				     size_t uuid_prefix_len,
+				     uint32_t* lib_cookie)
 {
 	int r = 1;
 	void *handle = NULL;
@@ -1861,7 +1919,7 @@ int dm_tree_preload_children(struct dm_tree_node *dnode,
 			continue;
 
 		if (dm_tree_node_num_children(child, 0))
-			if (!dm_tree_preload_children(child, uuid_prefix, uuid_prefix_len))
+			if (!_dm_tree_preload_children(child, uuid_prefix, uuid_prefix_len, lib_cookie))
 				return_0;
 
 		/* FIXME Cope if name exists with no uuid? */
@@ -1913,18 +1971,38 @@ int dm_tree_preload_children(struct dm_tree_node *dnode,
 
 	}
 
-	handle = NULL;
-
 	if (update_devs_flag) {
-		if (!dm_udev_wait(dm_tree_get_cookie(dnode)))
+		if (!_wait_on_cookie(dnode, *lib_cookie))
 			stack;
-		dm_tree_set_cookie(dnode, 0);
+		/* For internal lib_cookie - dm_wait in update_dev() */
 		dm_task_update_nodes();
+
+		/* For internal cookie - request regenerate */
+		if (*lib_cookie && !_use_lib_cookie(dnode, lib_cookie))
+			return_0;
 	}
 
 	return r;
 }
 
+int dm_tree_preload_children(struct dm_tree_node *dnode,
+			     const char *uuid_prefix,
+			     size_t uuid_prefix_len)
+{
+	uint32_t lib_cookie;
+	int r;
+
+	if (!_use_lib_cookie(dnode, &lib_cookie))
+		return_0;
+
+	r = _dm_tree_preload_children(dnode, uuid_prefix, uuid_prefix_len, &lib_cookie);
+
+	if (!_wait_on_cookie(dnode, lib_cookie))
+		stack;
+
+	return r;
+}
+
 /*
  * Returns 1 if unsure.
  */
-- 
1.7.3.3


