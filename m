From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sun, 18 Oct 2020 21:02:21 +0000 (GMT)
Subject: stable-2.02 - libdm: enhance error message
Message-ID: <20201018210221.4D53A3857C6F@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=afffab09217ed30d4a358a13cac3eccae8e712c1
Commit:        afffab09217ed30d4a358a13cac3eccae8e712c1
Parent:        d143ee13c7bf9c710899cf299acfb18c59687835
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Sep 25 19:10:30 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Oct 18 00:28:17 2020 +0200

libdm: enhance error message

---
 libdm/libdm-deptree.c | 33 +++++++++++++++++++++++++++++++--
 1 file changed, 31 insertions(+), 2 deletions(-)

diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index 358591819..6819d6471 100644
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


