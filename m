From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed,  1 Jul 2015 11:44:53 +0000 (UTC)
Subject: master - libdm: enhance tracing messages
Message-ID: <20150701114453.A13E960392@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=21c0b1134f7812300aea1e24da11ac1d93bac7b5
Commit:        21c0b1134f7812300aea1e24da11ac1d93bac7b5
Parent:        04ae5007e3952c3d071cfcd03e03db87332b9027
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jul 1 13:29:32 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jul 1 13:44:28 2015 +0200

libdm: enhance tracing messages

Use new _node_name() and print name major:minor for thin-pool device.
---
 WHATS_NEW_DM          |    1 +
 libdm/libdm-deptree.c |   17 ++++++++++-------
 2 files changed, 11 insertions(+), 7 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 91643af..38045d6 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.101 -
 =================================
+  Thin pool trace messages show a device name and major:minor.
 
 Version 1.02.100 - 30th June 2015
 =================================
diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index cb43afe..e344d1a 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -1456,7 +1456,9 @@ static int _thin_pool_status_transaction_id(struct dm_tree_node *dnode, uint64_t
 		goto out;
 	}
 
-	log_debug_activation("Thin pool transaction id: %" PRIu64 " status: %s.", *transaction_id, params);
+	log_debug_activation("Found transaction id %" PRIu64 " for thin pool %s "
+			     "with status line: %s.",
+			     *transaction_id, _node_name(dnode), params);
 
 	r = 1;
 out:
@@ -1570,15 +1572,16 @@ static int _node_send_messages(struct dm_tree_node *dnode,
 	if (trans_id == seg->transaction_id) {
 		dnode->props.send_messages = 0; /* messages already committed */
 		if (have_messages)
-			log_debug_activation("Thin pool transaction_id matches %" PRIu64
-					     ", skipping messages.", trans_id);
+			log_debug_activation("Thin pool %s transaction_id matches %"
+					     PRIu64 ", skipping messages.",
+					     _node_name(dnode), trans_id);
 		return 1;
 	}
 
 	/* Error if there are no stacked messages or id mismatches */
 	if (trans_id != (seg->transaction_id - have_messages)) {
-		log_error("Thin pool transaction_id is %" PRIu64 ", while expected %" PRIu64 ".",
-			  trans_id, seg->transaction_id - have_messages);
+		log_error("Thin pool %s transaction_id is %" PRIu64 ", while expected %" PRIu64 ".",
+			  _node_name(dnode), trans_id, seg->transaction_id - have_messages);
 		return 0;
 	}
 
@@ -1592,9 +1595,9 @@ static int _node_send_messages(struct dm_tree_node *dnode,
 			if (!_thin_pool_status_transaction_id(dnode, &trans_id))
 				return_0;
 			if (trans_id != tmsg->message.u.m_set_transaction_id.new_id) {
-				log_error("Thin pool transaction_id is %" PRIu64
+				log_error("Thin pool %s transaction_id is %" PRIu64
 					  " and does not match expected  %" PRIu64 ".",
-					  trans_id,
+					  _node_name(dnode), trans_id,
 					  tmsg->message.u.m_set_transaction_id.new_id);
 				return 0;
 			}


