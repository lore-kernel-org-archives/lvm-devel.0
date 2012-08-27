From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 27 Aug 2012 12:43:31 +0000 (UTC)
Subject: master - config: require dm_config_create_value for dm_config_node's value
Message-ID: <20120827124331.1F0BFA1043@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=847e2856a29c41756cc5bbaf70eb87ea030826f4
Commit:        847e2856a29c41756cc5bbaf70eb87ea030826f4
Parent:        2a70e98b05603bf8fc59929fd2709fb5d2b859e6
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Aug 27 14:19:30 2012 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Aug 27 14:33:54 2012 +0200

config: require dm_config_create_value for dm_config_node's value

If we were defining a section (which is a node without a value) and
the value was created automatically on dm_config_create_node call,
we were wasting resources as the next step after creating the config
node itself was assigning NULL for the node's value.

The dm_config_node_create + dm_config_create_value sequence should be
used instead for settings and dm_config_node_create alone for sections.

The majority of the code already used the correct sequence. Though
with dm_config_node_create fn creating the value as well, the pool
memory was being trashed this way.

This patch removes the node value initialization on dm_config_create_node
fn call and keeps it for the direct dm_config_create_value fn call.
---
 WHATS_NEW_DM                   |    1 +
 daemons/lvmetad/lvmetad-core.c |    7 +++++++
 libdm/libdm-config.c           |    9 ++-------
 3 files changed, 10 insertions(+), 7 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index d0e8f7d..c46db61 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.77 -
 =================================
+  Don't create value for dm_config_node and require dm_config_create_value call.
   Check for existing new_name for dmsetup rename.
   Fix memory leak in dmsetup _get_split_name() error path.
 
diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index 3ca3fd5..146ee69 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -520,12 +520,19 @@ static response vg_lookup(lvmetad_state *s, request r)
 	if (!(res.cft->root = n = dm_config_create_node(res.cft, "response")))
 		goto bad;
 
+	if (!(n->v = dm_config_create_value(cft)))
+		goto bad;
+
 	n->parent = res.cft->root;
 	n->v->type = DM_CFG_STRING;
 	n->v->v.str = "OK";
 
 	if (!(n = n->sib = dm_config_create_node(res.cft, "name")))
 		goto bad;
+
+	if (!(n->v = dm_config_create_value(res.cft)))
+		goto bad;
+
 	n->parent = res.cft->root;
 	n->v->type = DM_CFG_STRING;
 	n->v->v.str = name;
diff --git a/libdm/libdm-config.c b/libdm/libdm-config.c
index f8c0954..c19f51d 100644
--- a/libdm/libdm-config.c
+++ b/libdm/libdm-config.c
@@ -1169,14 +1169,9 @@ struct dm_config_node *dm_config_create_node(struct dm_config_tree *cft, const c
 		log_error("Failed to create config node's key.");
 		return NULL;
 	}
-	if (!(cn->v = _create_value(cft->mem))) {
-		log_error("Failed to create config node's value.");
-		return NULL;
-	}
 	cn->parent = NULL;
-	cn->v->type = DM_CFG_INT;
-	cn->v->v.i = 0;
-	cn->v->next = NULL;
+	cn->v = NULL;
+
 	return cn;
 }
 


