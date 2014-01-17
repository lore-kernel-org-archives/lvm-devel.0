From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 17 Jan 2014 10:01:00 +0000 (UTC)
Subject: master - cleanup: indent
Message-ID: <20140117100100.ACE5560D96@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d98511c717d64f111208e647e861620e310118d6
Commit:        d98511c717d64f111208e647e861620e310118d6
Parent:        5eee73bd7cb8e4712ad5e5d13a3bffb78e02c9ca
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jan 8 16:51:11 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jan 17 10:48:49 2014 +0100

cleanup: indent

---
 libdm/libdm-deptree.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index 7bc1f33..db88d9d 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -1620,8 +1620,8 @@ static int _dm_tree_deactivate_children(struct dm_tree_node *dnode,
 }
 
 int dm_tree_deactivate_children(struct dm_tree_node *dnode,
-				   const char *uuid_prefix,
-				   size_t uuid_prefix_len)
+				const char *uuid_prefix,
+				size_t uuid_prefix_len)
 {
 	return _dm_tree_deactivate_children(dnode, uuid_prefix, uuid_prefix_len, 0);
 }


