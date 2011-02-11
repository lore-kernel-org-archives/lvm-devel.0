From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri, 11 Feb 2011 11:31:00 +0100
Subject: [PATCH 14/16] Add debug message for open_count failure
In-Reply-To: <cover.1297419991.git.zkabelac@redhat.com>
References: <cover.1297419991.git.zkabelac@redhat.com>
Message-ID: <0fcc6137b1adc6f3cb9b5ba7fea8b2241ff133a6.1297419991.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Report  open_count problem as debug.

Function using _node_has_closed_parents decides whether
it's error or could be ignored.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 libdm/libdm-deptree.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index 8d00514..2293826 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -938,8 +938,11 @@ static int _node_has_closed_parents(struct dm_tree_node *node,
 		    !info.exists)
 			continue;
 
-		if (info.open_count)
+		if (info.open_count) {
+			log_debug("Node %s %d:%d is opened:%d", uuid_prefix,
+				  dinfo->major, dinfo->minor, info.open_count);
 			return 0;
+		}
 	}
 
 	return 1;
-- 
1.7.4


