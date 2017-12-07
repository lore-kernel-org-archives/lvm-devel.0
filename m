From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 7 Dec 2017 15:03:36 -0500
Subject: master - thin: missing type is error
Message-ID: <201712072003.vB7K3axo005579@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c3e224ad0ebd473268b171204c8985c9c642f590
Commit:        c3e224ad0ebd473268b171204c8985c9c642f590
Parent:        2208ebfe16e5b5cd54c762a5a06edd0681d62fa9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Dec 6 13:21:01 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Dec 7 20:59:37 2017 +0100

thin: missing type is error

---
 libdm/libdm-deptree.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index b844a57..1ef1700 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -1394,9 +1394,9 @@ static int _thin_pool_get_status(struct dm_tree_node *dnode,
 
 	dm_get_next_target(dmt, NULL, &start, &length, &type, &params);
 
-	if (type && (strcmp(type, "thin-pool") != 0)) {
+	if (!type || (strcmp(type, "thin-pool") != 0)) {
 		log_error("Expected thin-pool target for %s and got %s.",
-			  _node_name(dnode), type);
+			  _node_name(dnode), type ? : "no target");
 		goto out;
 	}
 


