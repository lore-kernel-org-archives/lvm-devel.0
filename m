From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue, 14 Apr 2015 20:22:07 +0000 (UTC)
Subject: master - libdaemon: Export chain_node from config-utils.c.
Message-ID: <20150414202207.3586560D72@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2ebb4f4ca3a9e36969007851c7be20c5dc4d85a0
Commit:        2ebb4f4ca3a9e36969007851c7be20c5dc4d85a0
Parent:        e3c831030d7bb3879cd354f1953df055b56b71f8
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Tue Mar 31 21:50:29 2015 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Tue Apr 14 20:16:53 2015 +0200

libdaemon: Export chain_node from config-utils.c.

---
 libdaemon/client/config-util.c |    6 +++---
 libdaemon/client/config-util.h |    4 ++++
 2 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/libdaemon/client/config-util.c b/libdaemon/client/config-util.c
index e5f4e22..4ebbe1b 100644
--- a/libdaemon/client/config-util.c
+++ b/libdaemon/client/config-util.c
@@ -132,9 +132,9 @@ int set_flag(struct dm_config_tree *cft, struct dm_config_node *parent,
 	return 1;
 }
 
-static void chain_node(struct dm_config_node *cn,
-		       struct dm_config_node *parent,
-		       struct dm_config_node *pre_sib)
+void chain_node(struct dm_config_node *cn,
+                struct dm_config_node *parent,
+                struct dm_config_node *pre_sib)
 {
 	cn->parent = parent;
 	cn->sib = NULL;
diff --git a/libdaemon/client/config-util.h b/libdaemon/client/config-util.h
index 47fab6b..58468ef 100644
--- a/libdaemon/client/config-util.h
+++ b/libdaemon/client/config-util.h
@@ -37,6 +37,10 @@ int buffer_line(const char *line, void *baton);
 int set_flag(struct dm_config_tree *cft, struct dm_config_node *parent,
 	     const char *field, const char *flag, int want);
 
+void chain_node(struct dm_config_node *cn,
+                struct dm_config_node *parent,
+                struct dm_config_node *pre_sib);
+
 struct dm_config_node *make_config_node(struct dm_config_tree *cft,
 					const char *key,
 					struct dm_config_node *parent,


