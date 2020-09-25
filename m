From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 25 Sep 2020 21:07:06 +0000 (GMT)
Subject: master - device_mapper: enhance error message
Message-ID: <20200925210706.18EB23947C02@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2bfa868f911b83f308c0fa3a09751f5b1cbddcfa
Commit:        2bfa868f911b83f308c0fa3a09751f5b1cbddcfa
Parent:        8b22e3808772601725c0e253f4aa5bed24905271
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Sep 25 19:10:30 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Sep 25 22:59:35 2020 +0200

device_mapper: enhance error message

---
 device_mapper/libdm-deptree.c | 33 +++++++++++++++++++++++++++++++--
 1 file changed, 31 insertions(+), 2 deletions(-)

diff --git a/device_mapper/libdm-deptree.c b/device_mapper/libdm-deptree.c
index 653dd0959..a98b1fcdd 100644
--- a/device_mapper/libdm-deptree.c
+++ b/device_mapper/libdm-deptree.c
@@ -1589,8 +1589,37 @@ static int _thin_pool_node_message(struct dm_tree_node *dnode, struct thin_messa
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


