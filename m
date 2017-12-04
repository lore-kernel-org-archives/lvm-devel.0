From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 4 Dec 2017 09:58:21 -0500
Subject: master - cleanup: drop unneeded check
Message-ID: <201712041458.vB4EwLkv007231@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=406b566cfc4be2cc04157ea7bd3c24ea729a4bb5
Commit:        406b566cfc4be2cc04157ea7bd3c24ea729a4bb5
Parent:        5abf6b7c21c86531eedeebe56de2633d43ef1879
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Dec 4 15:45:49 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Dec 4 15:45:49 2017 +0100

cleanup: drop unneeded check

Code already has dereferenced UUID before this point,
and its already given we require name & uuid when ading new node
(although uuid could be empty string).
---
 libdm/libdm-deptree.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index 48323de..34a1547 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -513,14 +513,13 @@ static struct dm_tree_node *_create_dm_tree_node(struct dm_tree *dtree,
 	dev = MKDEV((dev_t)info->major, (dev_t)info->minor);
 
 	if (!dm_hash_insert_binary(dtree->devs, (const char *) &dev,
-				sizeof(dev), node)) {
+				   sizeof(dev), node)) {
 		log_error("dtree node hash insertion failed");
 		dm_pool_free(dtree->mem, node);
 		return NULL;
 	}
 
-	if (uuid && *uuid &&
-	    !dm_hash_insert(dtree->uuids, uuid, node)) {
+	if (*uuid && !dm_hash_insert(dtree->uuids, uuid, node)) {
 		log_error("dtree uuid hash insertion failed");
 		dm_hash_remove_binary(dtree->devs, (const char *) &dev,
 				      sizeof(dev));


