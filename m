From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 20 Oct 2020 20:34:09 +0000 (GMT)
Subject: master - libdm: enhance error message
Message-ID: <20201020203409.252F83861893@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4b0565b82f9f2bab0d9fdbc23c63e63cbddba61d
Commit:        4b0565b82f9f2bab0d9fdbc23c63e63cbddba61d
Parent:        4c1caa7e26b6f8011ca083395650d11943a42a8a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Sep 25 19:10:30 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 19 16:53:18 2020 +0200

libdm: enhance error message

---
 libdm/libdm-deptree.c | 33 +++++++++++++++++++++++++++++++--
 1 file changed, 31 insertions(+), 2 deletions(-)

diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index 887e8f275..ffd084e52 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -1503,8 +1503,37 @@ static int _thin_pool_node_message(struct dm_tree_node *dnode, struct thin_messa
 	}
 
 	if (!_node_message(dnode->info.major, dnode->info.minor,
-			   tm->expected_errno, buf))
-		return_0;
+			   tm->expected_errno, buf)) {
+		switch (m->type) {
+		case DM_THIN_MESSAGE_CREATE_SNAP:
+		case DM_THIN_MESSAGE_CREATE_THIN:
+			if (errno == EEXIST) {
+				/*
+				 * ATM errno from ioctl() is preserved through code error path chain
+				 * If this would ever change, another way need to be used to
+				 * obtain result from failed DM message
+				 */
+				log_error("Thin pool %s already contain thin device with device_id %u.",
+					  _node_name(dnode), m->u.m_create_snap.device_id);
+				/*
+				 * TODO:
+				 *
+				 * Give some useful advice how to solve this problem,
+				 * until lvconvert --repair can handle this automatically
+				 */
+				log_error("Manual intervention may be required to remove device dev_id=%u in thin pool metadata.",
+					  m->u.m_create_snap.device_id);
+				log_error("Optionally new thin volume with device_id=%u can be manually added into a volume group.",
+					  m->u.m_create_snap.device_id);
+				log_warn("WARNING: When uncertain how to do this, contact support!");
+				return 0;
+			}
+			/* fall through */
+		default:
+			return_0;
+		}
+
+	}
 
 	return 1;
 }


