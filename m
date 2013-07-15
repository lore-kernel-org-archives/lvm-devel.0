From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 15 Jul 2013 14:02:57 +0000 (UTC)
Subject: master - libdm: thin pool target sends messages once
Message-ID: <20130715140257.5022E60642@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5658ec2bdc9e5ea816a1dd227ffbb74d6cbfb8f5
Commit:        5658ec2bdc9e5ea816a1dd227ffbb74d6cbfb8f5
Parent:        e5c30061fc5652846a61fcd460c6a1636d346a7c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jul 15 11:53:30 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 15 15:45:28 2013 +0200

libdm: thin pool target sends messages once

Clear send_messages flag when they have been delivered successfully.
There is no need to validate it for all other activations of the same
node in the dm_tree.

Also add extra debug message which shows the reason for skipping
sending of messages because the transaction_id has already the matching
value.
---
 WHATS_NEW_DM          |    1 +
 libdm/libdm-deptree.c |   15 +++++++++++----
 2 files changed, 12 insertions(+), 4 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index e784ada..b269f55 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.78 - 
 ===================================
+  Process thin messages once to active thin pool target for dm_tree.
   Optimize out setting the same value or read_ahead.
   Add DM_ARRAY_SIZE public macro.
   Move syslog code out of signal handle in dmeventd.
diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index fae9445..34cd960 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -1484,8 +1484,12 @@ static int _node_send_messages(struct dm_tree_node *dnode,
 	if (!_thin_pool_status_transaction_id(dnode, &trans_id))
 		goto_bad;
 
-	if (trans_id == seg->transaction_id)
+	if (trans_id == seg->transaction_id) {
+		if (!dm_list_empty(&seg->thin_messages))
+			log_debug_activation("Thin pool transaction_id matches %" PRIu64
+					     ", skipping messages.", trans_id);
 		return 1; /* In sync - skip messages */
+	}
 
 	if (trans_id != (seg->transaction_id - 1)) {
 		log_error("Thin pool transaction_id=%" PRIu64 ", while expected: %" PRIu64 ".",
@@ -1784,9 +1788,12 @@ int dm_tree_activate_children(struct dm_tree_node *dnode,
 	 * resume should continue further, just whole command
 	 * has to report failure.
 	 */
-	if (r && dnode->props.send_messages &&
-	    !(r = _node_send_messages(dnode, uuid_prefix, uuid_prefix_len)))
-		stack;
+	if (r && dnode->props.send_messages) {
+		if (!(r = _node_send_messages(dnode, uuid_prefix, uuid_prefix_len)))
+			stack;
+		else
+			dnode->props.send_messages = 0; /* messages posted */
+	}
 
 	handle = NULL;
 


