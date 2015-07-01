From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed,  1 Jul 2015 11:44:51 +0000 (UTC)
Subject: master - libdm: add helper function to print _node_name
Message-ID: <20150701114451.77BCA60392@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=04ae5007e3952c3d071cfcd03e03db87332b9027
Commit:        04ae5007e3952c3d071cfcd03e03db87332b9027
Parent:        a69ded43b0364812c58eb9479c2dae4dd2febc8c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jul 1 09:54:57 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jul 1 13:41:40 2015 +0200

libdm: add helper function to print _node_name

_node_name() prepares into dm_tree internal buffer device
name and it (major:minor) for easy usage for debug messages.

To avoid any allocation a small buffer in struct dm_tree is preallocated
to store this message.
---
 libdm/libdm-deptree.c |   14 ++++++++++++++
 1 files changed, 14 insertions(+), 0 deletions(-)

diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index 8428376..cb43afe 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -301,6 +301,7 @@ struct dm_tree {
 	int no_flush;			/* 1 sets noflush (mirrors/multipath) */
 	int retry_remove;		/* 1 retries remove if not successful */
 	uint32_t cookie;
+	char buf[DM_NAME_LEN + 32];	/* print buffer for device_name (major:minor) */
 	const char **optional_uuid_suffixes;	/* uuid suffixes ignored when matching */
 };
 
@@ -595,6 +596,19 @@ static struct dm_tree_node *_find_dm_tree_node_by_uuid(struct dm_tree *dtree,
 	return NULL;
 }
 
+/* Return node's device_name (major:minor) for debug messages */
+static const char *_node_name(struct dm_tree_node *dnode)
+{
+	if (dm_snprintf(dnode->dtree->buf, sizeof(dnode->dtree->buf),
+			"%s (%" PRIu32 ":%" PRIu32 ")",
+			dnode->name, dnode->info.major, dnode->info.minor) < 0) {
+		stack;
+		return dnode->name;
+	}
+
+	return dnode->dtree->buf;
+}
+
 void dm_tree_node_set_udev_flags(struct dm_tree_node *dnode, uint16_t udev_flags)
 
 {


