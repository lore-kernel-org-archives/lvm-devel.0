From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 25 Jun 2018 09:10:19 -0400
Subject: master - device_mapper: split code for sending message
Message-ID: <201806251310.w5PDAJj0031473@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=739a213d2ee01cc95861c342fde73e87088de6bb
Commit:        739a213d2ee01cc95861c342fde73e87088de6bb
Parent:        a1c81c009a59c2476ffca8a8cf2cd06f0674e46d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Jun 23 21:00:40 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jun 25 15:07:55 2018 +0200

device_mapper: split code for sending message

Move message sending from _thin_pool_node_message to
new _node_message for possible better code sharing.
---
 device_mapper/libdm-deptree.c |   63 ++++++++++++++++++++++++-----------------
 1 files changed, 37 insertions(+), 26 deletions(-)

diff --git a/device_mapper/libdm-deptree.c b/device_mapper/libdm-deptree.c
index 4875858..5327b2e 100644
--- a/device_mapper/libdm-deptree.c
+++ b/device_mapper/libdm-deptree.c
@@ -1428,9 +1428,42 @@ out:
 	return r;
 }
 
-static int _thin_pool_node_message(struct dm_tree_node *dnode, struct thin_message *tm)
+static int _node_message(uint32_t major, uint32_t minor,
+			 int expected_errno, const char *message)
 {
 	struct dm_task *dmt;
+	int r;
+
+	if (!(dmt = dm_task_create(DM_DEVICE_TARGET_MSG)))
+		return_0;
+
+	if (!dm_task_set_major(dmt, major) ||
+	    !dm_task_set_minor(dmt, minor)) {
+		log_error("Failed to set message major minor.");
+		goto out;
+	}
+
+	if (!dm_task_set_message(dmt, message))
+		goto_out;
+
+	/* Internal functionality of dm_task */
+	dmt->expected_errno = expected_errno;
+
+	if (!dm_task_run(dmt)) {
+		log_error("Failed to process message \"%s\".", message);
+		goto out;
+	}
+
+	r = 1;
+out:
+	dm_task_destroy(dmt);
+
+	return r;
+}
+
+
+static int _thin_pool_node_message(struct dm_tree_node *dnode, struct thin_message *tm)
+{
 	struct dm_thin_message *m = &tm->message;
 	char buf[64];
 	int r;
@@ -1470,33 +1503,11 @@ static int _thin_pool_node_message(struct dm_tree_node *dnode, struct thin_messa
 		return 0;
 	}
 
-	r = 0;
-
-	if (!(dmt = dm_task_create(DM_DEVICE_TARGET_MSG)))
+	if (!_node_message(dnode->info.major, dnode->info.minor,
+			   tm->expected_errno, buf))
 		return_0;
 
-	if (!dm_task_set_major(dmt, dnode->info.major) ||
-	    !dm_task_set_minor(dmt, dnode->info.minor)) {
-		log_error("Failed to set message major minor.");
-		goto out;
-	}
-
-	if (!dm_task_set_message(dmt, buf))
-		goto_out;
-
-	/* Internal functionality of dm_task */
-	dmt->expected_errno = tm->expected_errno;
-
-	if (!dm_task_run(dmt)) {
-		log_error("Failed to process thin pool message \"%s\".", buf);
-		goto out;
-	}
-
-	r = 1;
-out:
-	dm_task_destroy(dmt);
-
-	return r;
+	return 1;
 }
 
 static struct load_segment *_get_last_load_segment(struct dm_tree_node *node)


