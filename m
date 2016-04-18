From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 18 Apr 2016 10:59:08 +0000 (UTC)
Subject: master - debug: update message in libdm
Message-ID: <20160418105908.053B861B7F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e2ceb90095ab008c13a3d0db0bbf1bc2bd8557f2
Commit:        e2ceb90095ab008c13a3d0db0bbf1bc2bd8557f2
Parent:        f5cf6cc9ed756ec1e98d62a31aba803577443ad7
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Apr 17 14:51:58 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Apr 18 12:32:56 2016 +0200

debug: update message in libdm

When dm_tree_find_node_by_uuid() fails to find passed uuid,
report in lof_debug the complete original uuid,
not the one stripped of LVM- prefix.

TODO: inspect manipulation with LVM- prefix here.
---
 WHATS_NEW_DM          |    1 +
 libdm/libdm-deptree.c |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 08d7d45..e2301ea 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.122 - 9th April 2016
 =================================
+  Do not strip LVM- when debug reporting not found uuid.
   Change log_debug ioctl flags from single characters into words.
 
 Version 1.02.121 - 26th March 2016
diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index f8b6d89..6f18ae2 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -599,7 +599,7 @@ static struct dm_tree_node *_find_dm_tree_node_by_uuid(struct dm_tree *dtree,
 		return node;
 	}
 
-	log_debug("Not matched uuid %s in deptree.", uuid + default_uuid_prefix_len);
+	log_debug("Not matched uuid %s in deptree.", uuid);
 	return NULL;
 }
 


