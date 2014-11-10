From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 10 Nov 2014 23:56:27 +0000 (UTC)
Subject: master - dev_manager: workaround to allow top-level _tmeta, _tdata
Message-ID: <20141110235627.1E79E6030A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ca509c97467f5f077463c54fee185442cb98f817
Commit:        ca509c97467f5f077463c54fee185442cb98f817
Parent:        a7fc1082987c3d5842664fd7817ec01e1ddec9cc
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Nov 11 00:50:13 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Nov 11 00:53:37 2014 +0100

dev_manager: workaround to allow top-level _tmeta, _tdata

---
 lib/activate/dev_manager.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 1666d41..2651ec8 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -2889,6 +2889,10 @@ static int _clean_tree(struct dev_manager *dm, struct dm_tree_node *root, char *
 		if (!*layer && (!(layer = strchr(uuid + 4, '-')) || strstr(layer, "-pool") || strstr(layer, "-tpool")))
 			continue;
 
+		/* FIXME: we still occasionally need to activate these at top-level */
+		if (strstr(lvname, "_tmeta") || strstr(lvname, "_tdata"))
+			continue;
+
 		/* If operation was performed on a partial tree, don't remove it */
 		if (non_toplevel_tree_dlid && !strcmp(non_toplevel_tree_dlid, uuid))
 			continue;


