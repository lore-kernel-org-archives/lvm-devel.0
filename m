From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 15 Jun 2015 12:48:41 +0000 (UTC)
Subject: master - libdm: better debug message
Message-ID: <20150615124841.D79566006F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9a06ae7b35f4355e7be14b5fae2865b85fc60fc2
Commit:        9a06ae7b35f4355e7be14b5fae2865b85fc60fc2
Parent:        ac6b3559780ccabc8cd46353e10520677b3c1277
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jun 4 08:45:22 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jun 15 14:48:04 2015 +0200

libdm: better debug message

Print reason for failing ioctl if thin pool message fails.
---
 WHATS_NEW_DM          |    1 +
 libdm/libdm-deptree.c |    8 +++++---
 2 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 724b1c7..dda2777 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.99 - 
 ================================
+  Enhance error message when thin-pool message fails.
 
 Version 1.02.98 - 12th June 2015
 ================================
diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index 578f645..1602c62 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -1506,11 +1506,13 @@ static int _thin_pool_node_message(struct dm_tree_node *dnode, struct thin_messa
 	if (!dm_task_set_message(dmt, buf))
 		goto_out;
 
-        /* Internal functionality of dm_task */
+	/* Internal functionality of dm_task */
 	dmt->expected_errno = tm->expected_errno;
 
-	if (!dm_task_run(dmt))
-		goto_out;
+	if (!dm_task_run(dmt)) {
+		log_error("Failed to process thin pool message \"%s\".", buf);
+		goto out;
+	}
 
 	r = 1;
 out:


