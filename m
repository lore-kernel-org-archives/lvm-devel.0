From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu,  3 Sep 2015 21:36:05 +0000 (UTC)
Subject: master - libdm: relocate parsing of thin-pool status
Message-ID: <20150903213605.0BE3D60EB9@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a3c7e326c3e9950fe74e433c406d6e1b5a53bf25
Commit:        a3c7e326c3e9950fe74e433c406d6e1b5a53bf25
Parent:        5ce334923f1f82e0ca5dcbd0f5e830109c1f9c0b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Sep 2 11:10:59 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Sep 3 23:34:36 2015 +0200

libdm: relocate parsing of thin-pool status

Use single routine for parsing status.

Internally we do not need to allocate pool memory for
passed struct.
---
 WHATS_NEW_DM          |    1 +
 libdm/libdm-deptree.c |  111 +++++++++++++++++++++++++-----------------------
 2 files changed, 59 insertions(+), 53 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 8d74222..c40a023 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.107 - 
 ===================================
+  Parse thin-pool status with one single routine internally.
   Fix devmapper.pc pkgconfig file to not reference non-existent rt.pc file.
   Reinstate dm_task_get_info at Base to libdevmapper exports. (1.02.106)
 
diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index 84f1d28..d40362d 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -1427,7 +1427,50 @@ static int _suspend_node(const char *name, uint32_t major, uint32_t minor,
 	return r;
 }
 
-static int _thin_pool_status_transaction_id(struct dm_tree_node *dnode, uint64_t *transaction_id)
+static int _thin_pool_parse_status(const char *params,
+				   struct dm_status_thin_pool *s)
+{
+	int pos;
+
+	if (!params) {
+		log_error("Failed to parse invalid thin params.");
+		return 0;
+	}
+
+	/* FIXME: add support for held metadata root */
+	if (sscanf(params, FMTu64 " " FMTu64 "/" FMTu64 " " FMTu64 "/" FMTu64 "%n",
+		   &s->transaction_id,
+		   &s->used_metadata_blocks,
+		   &s->total_metadata_blocks,
+		   &s->used_data_blocks,
+		   &s->total_data_blocks, &pos) < 5) {
+		log_error("Failed to parse thin pool params: %s.", params);
+		return 0;
+	}
+
+	/* New status flags */
+	if (strstr(params + pos, "no_discard_passdown"))
+		s->discards = DM_THIN_DISCARDS_NO_PASSDOWN;
+	else if (strstr(params + pos, "ignore_discard"))
+		s->discards = DM_THIN_DISCARDS_IGNORE;
+	else /* default discard_passdown */
+		s->discards = DM_THIN_DISCARDS_PASSDOWN;
+
+	if (strstr(params + pos, "ro "))
+		s->read_only = 1;
+	else if (strstr(params + pos, "fail"))
+		s->fail = 1;
+	else if (strstr(params + pos, "out_of_data_space"))
+		s->out_of_data_space = 1;
+
+	if (strstr(params + pos, "error_if_no_space"))
+		s->error_if_no_space = 1;
+
+	return 1;
+}
+
+static int _thin_pool_get_status(struct dm_tree_node *dnode,
+				 struct dm_status_thin_pool *s)
 {
 	struct dm_task *dmt;
 	int r = 0;
@@ -1458,14 +1501,12 @@ static int _thin_pool_status_transaction_id(struct dm_tree_node *dnode, uint64_t
 		goto out;
 	}
 
-	if (!params || (sscanf(params, FMTu64, transaction_id) != 1)) {
-		log_error("Failed to parse transaction_id from %s.", params);
-		goto out;
-	}
+	if (!_thin_pool_parse_status(params, s))
+		goto_out;
 
 	log_debug_activation("Found transaction id %" PRIu64 " for thin pool %s "
 			     "with status line: %s.",
-			     *transaction_id, _node_name(dnode), params);
+			     s->transaction_id, _node_name(dnode), params);
 
 	r = 1;
 out:
@@ -1553,7 +1594,7 @@ static int _node_send_messages(struct dm_tree_node *dnode,
 {
 	struct load_segment *seg;
 	struct thin_message *tmsg;
-	uint64_t trans_id;
+	struct dm_status_thin_pool stp = { 0 };
 	const char *uuid;
 	int have_messages;
 
@@ -1572,23 +1613,23 @@ static int _node_send_messages(struct dm_tree_node *dnode,
 		return 1;
 	}
 
-	if (!_thin_pool_status_transaction_id(dnode, &trans_id))
+	if (!_thin_pool_get_status(dnode, &stp))
 		return_0;
 
 	have_messages = !dm_list_empty(&seg->thin_messages) ? 1 : 0;
-	if (trans_id == seg->transaction_id) {
+	if (stp.transaction_id == seg->transaction_id) {
 		dnode->props.send_messages = 0; /* messages already committed */
 		if (have_messages)
 			log_debug_activation("Thin pool %s transaction_id matches %"
 					     PRIu64 ", skipping messages.",
-					     _node_name(dnode), trans_id);
+					     _node_name(dnode), stp.transaction_id);
 		return 1;
 	}
 
 	/* Error if there are no stacked messages or id mismatches */
-	if ((trans_id + 1) != seg->transaction_id) {
+	if ((stp.transaction_id + 1) != seg->transaction_id) {
 		log_error("Thin pool %s transaction_id is %" PRIu64 ", while expected %" PRIu64 ".",
-			  _node_name(dnode), trans_id, seg->transaction_id - have_messages);
+			  _node_name(dnode), stp.transaction_id, seg->transaction_id - have_messages);
 		return 0;
 	}
 
@@ -1599,12 +1640,12 @@ static int _node_send_messages(struct dm_tree_node *dnode,
 		if (!(_thin_pool_node_message(dnode, tmsg)))
 			return_0;
 		if (tmsg->message.type == DM_THIN_MESSAGE_SET_TRANSACTION_ID) {
-			if (!_thin_pool_status_transaction_id(dnode, &trans_id))
+			if (!_thin_pool_get_status(dnode, &stp))
 				return_0;
-			if (trans_id != tmsg->message.u.m_set_transaction_id.new_id) {
+			if (stp.transaction_id != tmsg->message.u.m_set_transaction_id.new_id) {
 				log_error("Thin pool %s transaction_id is %" PRIu64
 					  " and does not match expected  %" PRIu64 ".",
-					  _node_name(dnode), trans_id,
+					  _node_name(dnode), stp.transaction_id,
 					  tmsg->message.u.m_set_transaction_id.new_id);
 				return 0;
 			}
@@ -4003,48 +4044,17 @@ int dm_get_status_thin_pool(struct dm_pool *mem, const char *params,
 			    struct dm_status_thin_pool **status)
 {
 	struct dm_status_thin_pool *s;
-	int pos;
-
-	if (!params) {
-		log_error("Failed to parse invalid thin pool params.");
-		return 0;
-	}
 
 	if (!(s = dm_pool_zalloc(mem, sizeof(struct dm_status_thin_pool)))) {
 		log_error("Failed to allocate thin_pool status structure.");
 		return 0;
 	}
 
-	/* FIXME: add support for held metadata root */
-	if (sscanf(params, FMTu64 " " FMTu64 "/" FMTu64 " " FMTu64 "/" FMTu64 "%n",
-		   &s->transaction_id,
-		   &s->used_metadata_blocks,
-		   &s->total_metadata_blocks,
-		   &s->used_data_blocks,
-		   &s->total_data_blocks, &pos) < 5) {
+	if (!_thin_pool_parse_status(params, s)) {
 		dm_pool_free(mem, s);
-		log_error("Failed to parse thin pool params: %s.", params);
-		return 0;
+		return_0;
 	}
 
-	/* New status flags */
-	if (strstr(params + pos, "no_discard_passdown"))
-		s->discards = DM_THIN_DISCARDS_NO_PASSDOWN;
-	else if (strstr(params + pos, "ignore_discard"))
-		s->discards = DM_THIN_DISCARDS_IGNORE;
-	else /* default discard_passdown */
-		s->discards = DM_THIN_DISCARDS_PASSDOWN;
-
-	if (strstr(params + pos, "ro "))
-		s->read_only = 1;
-	else if (strstr(params + pos, "fail"))
-		s->fail = 1;
-	else if (strstr(params + pos, "out_of_data_space"))
-		s->out_of_data_space = 1;
-
-	if (strstr(params + pos, "error_if_no_space"))
-		s->error_if_no_space = 1;
-
 	*status = s;
 
 	return 1;
@@ -4055,11 +4065,6 @@ int dm_get_status_thin(struct dm_pool *mem, const char *params,
 {
 	struct dm_status_thin *s;
 
-	if (!params) {
-		log_error("Failed to parse invalid thin params.");
-		return 0;
-	}
-
 	if (!(s = dm_pool_zalloc(mem, sizeof(struct dm_status_thin)))) {
 		log_error("Failed to allocate thin status structure.");
 		return 0;


