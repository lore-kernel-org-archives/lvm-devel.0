From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 18 Jul 2012 12:39:15 +0000 (UTC)
Subject: master - libdm: support reserve and release metadata snap msg
Message-ID: <20120718123915.5A66A8A1@lists.fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c4db22bd4f3d4a7328b2e03c27a5c1edb167d47f
Commit:        c4db22bd4f3d4a7328b2e03c27a5c1edb167d47f
Parent:        dcd4afc7163fa08b8bd43aeb4cabe3d8a792e20b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jul 4 11:28:53 2012 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jul 18 14:34:19 2012 +0200

libdm: support reserve and release metadata snap msg

Add support for new message types for thinp target 1.1
---
 WHATS_NEW_DM          |    1 +
 libdm/libdevmapper.h  |    2 ++
 libdm/libdm-deptree.c |    6 ++++++
 3 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index e11ebcb..416beca 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.76 - 
 ===============================
+  Add support for thin pool message release/reserve_metadata_snap.
   Add support for thin pool discard and external origin.
   Add configure --enable-udev-rule-exec-detection to detect exec path in rules.
   Use sbindir in udev rules by default and remove executable path detection.
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index 6eeaf87..549a635 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -650,6 +650,8 @@ typedef enum {
 	DM_THIN_MESSAGE_CREATE_THIN,		/* device_id */
 	DM_THIN_MESSAGE_DELETE,			/* device_id */
 	DM_THIN_MESSAGE_SET_TRANSACTION_ID,	/* current_id, new_id */
+	DM_THIN_MESSAGE_RESERVE_METADATA_SNAP,	/* 1.1 */
+	DM_THIN_MESSAGE_RELEASE_METADATA_SNAP,	/* 1.1 */
 } dm_thin_message_t;
 
 int dm_tree_node_add_thin_pool_message(struct dm_tree_node *node,
diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index a43b6a2..acd82ca 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -1411,6 +1411,12 @@ static int _thin_pool_node_message(struct dm_tree_node *dnode, struct thin_messa
 				m->u.m_set_transaction_id.current_id,
 				m->u.m_set_transaction_id.new_id);
 		break;
+	case DM_THIN_MESSAGE_RESERVE_METADATA_SNAP: /* 1.1 */
+		r = dm_snprintf(buf, sizeof(buf), "reserve_metadata_snap");
+		break;
+	case DM_THIN_MESSAGE_RELEASE_METADATA_SNAP: /* 1.1 */
+		r = dm_snprintf(buf, sizeof(buf), "release_metadata_snap");
+		break;
 	default:
 		r = -1;
 	}


