From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 26 Aug 2014 12:17:32 +0000 (UTC)
Subject: master - libdm: add check transaction_id after message
Message-ID: <20140826121732.8F0FC61018@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8f518cf1979e4cbfce40f6ae1bed02bd5b9a5b35
Commit:        8f518cf1979e4cbfce40f6ae1bed02bd5b9a5b35
Parent:        0794a10f91557d58e865faff4c60aef6336ecf22
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Aug 21 15:39:27 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Aug 26 14:12:20 2014 +0200

libdm: add check transaction_id after message

Add extra safety detection for thin pool transaction id
and query pool status after confirmed message.

In case there is a missmatch, immeditelly abort further
processing.
---
 WHATS_NEW_DM          |    1 +
 libdm/libdm-deptree.c |   16 ++++++++++++++--
 2 files changed, 15 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 9f16797..484cb7e 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.89 -
 =================================
+  Add extra check for matching transation_id after message submitting.
   Add dm_report_field_string_list_unsorted for str. list report without sorting.
   Support --deferred with dmsetup remove to defer removal of open devices.
   Update dm-ioctl.h to include DM_DEFERRED_REMOVE flag.
diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index 55f061a..0048b1c 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -1561,7 +1561,7 @@ static int _node_send_messages(struct dm_tree_node *dnode,
 
 	/* Error if there are no stacked messages or id mismatches */
 	if (trans_id != (seg->transaction_id - have_messages)) {
-		log_error("Thin pool transaction_id=%" PRIu64 ", while expected: %" PRIu64 ".",
+		log_error("Thin pool transaction_id is %" PRIu64 ", while expected %" PRIu64 ".",
 			  trans_id, seg->transaction_id - have_messages);
 		return 0;
 	}
@@ -1569,9 +1569,21 @@ static int _node_send_messages(struct dm_tree_node *dnode,
 	if (!send)
 		return 1; /* transaction_id is matching */
 
-	dm_list_iterate_items(tmsg, &seg->thin_messages)
+	dm_list_iterate_items(tmsg, &seg->thin_messages) {
 		if (!(_thin_pool_node_message(dnode, tmsg)))
 			return_0;
+		if (tmsg->message.type == DM_THIN_MESSAGE_SET_TRANSACTION_ID) {
+			if (!_thin_pool_status_transaction_id(dnode, &trans_id))
+				return_0;
+			if (trans_id != tmsg->message.u.m_set_transaction_id.new_id) {
+				log_error("Thin pool transaction_id is %" PRIu64
+					  " and does not match expected  %" PRIu64 ".",
+					  trans_id,
+					  tmsg->message.u.m_set_transaction_id.new_id);
+				return 0;
+			}
+		}
+	}
 
 	dnode->props.send_messages = 0; /* messages posted */
 


