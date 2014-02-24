From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 24 Feb 2014 20:16:59 +0000 (UTC)
Subject: master - libdm: hardening transaction_id validation
Message-ID: <20140224201659.DDDD160D5B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c7b7cb60e4de1aff7f9ea9e3a8116f851ef3089c
Commit:        c7b7cb60e4de1aff7f9ea9e3a8116f851ef3089c
Parent:        6116333ccc4969e69bfd10aa0fe64238dc7f4dab
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Feb 24 10:19:50 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Feb 24 21:04:50 2014 +0100

libdm: hardening transaction_id validation

Improve testing of transation_id to not allow other difference
then either kernel TID is equal or is lower by oned and there
are queued messages for transaction.

Mark messages as submitted if the transaction_id is already matching.

Do not try to deactivate node on failure here and leave it on
proper error path of the caller.
---
 WHATS_NEW_DM          |    1 +
 libdm/libdm-deptree.c |   35 ++++++++++++++++-------------------
 2 files changed, 17 insertions(+), 19 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 072d21e..c29cb39 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.85 - 
 ===================================
+  Transaction_id could be lower by one only when messages are prepared.
   Do not call callback when preload fails.
   Wrap is_selinux_enabled() to be called just once.
   Use correctly signed 64b constant when working with raid volumes.
diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index 764074d..56ddd1a 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -1486,6 +1486,7 @@ static int _node_send_messages(struct dm_tree_node *dnode,
 	struct thin_message *tmsg;
 	uint64_t trans_id;
 	const char *uuid;
+	int have_messages;
 
 	if (!dnode->info.exists || (dm_list_size(&dnode->props.segs) != 1))
 		return 1;
@@ -1503,32 +1504,31 @@ static int _node_send_messages(struct dm_tree_node *dnode,
 	}
 
 	if (!_thin_pool_status_transaction_id(dnode, &trans_id))
-		goto_bad;
+		return_0;
 
+	have_messages = !dm_list_empty(&seg->thin_messages) ? 1 : 0;
 	if (trans_id == seg->transaction_id) {
-		if (!dm_list_empty(&seg->thin_messages))
+		dnode->props.send_messages = 0; /* messages already committed */
+		if (have_messages)
 			log_debug_activation("Thin pool transaction_id matches %" PRIu64
 					     ", skipping messages.", trans_id);
-		return 1; /* In sync - skip messages */
+		return 1;
 	}
 
-	if (trans_id != (seg->transaction_id - 1)) {
+	/* Error if there are no stacked messages or id mismatches */
+	if (trans_id != (seg->transaction_id - have_messages)) {
 		log_error("Thin pool transaction_id=%" PRIu64 ", while expected: %" PRIu64 ".",
-			  trans_id, seg->transaction_id - 1);
-		goto bad; /* Nothing to send */
+			  trans_id, seg->transaction_id - have_messages);
+		return 0;
 	}
 
 	dm_list_iterate_items(tmsg, &seg->thin_messages)
 		if (!(_thin_pool_node_message(dnode, tmsg)))
-			goto_bad;
+			return_0;
 
-	return 1;
-bad:
-	/* Try to deactivate */
-	if (!(dm_tree_deactivate_children(dnode, uuid_prefix, uuid_prefix_len)))
-		log_error("Failed to deactivate %s", dnode->name);
+	dnode->props.send_messages = 0; /* messages posted */
 
-	return 0;
+	return 1;
 }
 
 /*
@@ -1864,12 +1864,9 @@ int dm_tree_activate_children(struct dm_tree_node *dnode,
 	 * resume should continue further, just whole command
 	 * has to report failure.
 	 */
-	if (r && dnode->props.send_messages) {
-		if (!(r = _node_send_messages(dnode, uuid_prefix, uuid_prefix_len)))
-			stack;
-		else
-			dnode->props.send_messages = 0; /* messages posted */
-	}
+	if (r && dnode->props.send_messages &&
+	    !(r = _node_send_messages(dnode, uuid_prefix, uuid_prefix_len)))
+		stack;
 
 	return r;
 }


