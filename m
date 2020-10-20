From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 20 Oct 2020 20:34:10 +0000 (GMT)
Subject: master - libdm: validate thin-pool before sending messages
Message-ID: <20201020203410.47A21395182E@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b2a326b511950c301fceb7f4901671af53f0e8af
Commit:        b2a326b511950c301fceb7f4901671af53f0e8af
Parent:        4b0565b82f9f2bab0d9fdbc23c63e63cbddba61d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Sep 28 23:12:48 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 19 16:53:18 2020 +0200

libdm: validate thin-pool before sending messages

Alhtough lvm2 does validation on its side, ensure DM code
is not sending messages to failed thin pool.
---
 libdm/libdm-deptree.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index ffd084e52..59616eb3a 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -1600,6 +1600,15 @@ static int _node_send_messages(struct dm_tree_node *dnode,
 	if (!have_messages || !send)
 		return 1; /* transaction_id is matching */
 
+	if (stp.fail || stp.read_only || stp.needs_check) {
+		log_error("Cannot send messages to thin pool %s%s%s%s.",
+			  _node_name(dnode),
+			  stp.fail ? " in failed state" : "",
+			  stp.read_only ? " with read only metadata" : "",
+			  stp.needs_check ? " which needs check first" : "");
+		return 0;
+	}
+
 	dm_list_iterate_items(tmsg, &seg->thin_messages) {
 		if (!(_thin_pool_node_message(dnode, tmsg)))
 			return_0;


