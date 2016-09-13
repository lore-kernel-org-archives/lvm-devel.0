From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 13 Sep 2016 10:26:05 +0000 (UTC)
Subject: master - libdm: cleaner debug message
Message-ID: <20160913102605.73D50610D5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a156fc9a5431cef6a3435e796da6eac4d34c905f
Commit:        a156fc9a5431cef6a3435e796da6eac4d34c905f
Parent:        5bf1778e33b07a75aeb8a0f2d42737623e9e8699
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Sep 13 09:24:38 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Sep 13 09:24:38 2016 +0200

libdm: cleaner debug message

---
 libdm/libdm-deptree.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index d74bb9c..cf6a06e 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -1783,7 +1783,7 @@ int dm_tree_suspend_children(struct dm_tree_node *dnode,
 			if (!(r = _node_send_messages(child, uuid_prefix, uuid_prefix_len, 1)))
 				stack;
 			else {
-				log_debug_activation("Sent messages to thin-pool %s."
+				log_debug_activation("Sent messages to thin-pool %s and "
 						     "skipping suspend of its children.",
 						     _node_name(child));
 				child->props.skip_suspend++;


