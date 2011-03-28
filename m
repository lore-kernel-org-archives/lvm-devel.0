From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon, 28 Mar 2011 13:59:16 +0200
Subject: [PATCH 5/6] Fix signes warnings
In-Reply-To: <cover.1301313391.git.zkabelac@redhat.com>
References: <cover.1301313391.git.zkabelac@redhat.com>
Message-ID: <9fdabd5f93f6e91a823317ea5ba5c1cf5cca9fe4.1301313392.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 libdm/libdm-common.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/libdm/libdm-common.c b/libdm/libdm-common.c
index 7cce3a7..bbf0aa4 100644
--- a/libdm/libdm-common.c
+++ b/libdm/libdm-common.c
@@ -797,7 +797,7 @@ static int _other_node_ops(node_op_t type)
 	int i;
 
 	for (i = 0; i < NUM_NODES; i++)
-		if (type != i && _count_node_ops[i])
+		if ((int) type != i && _count_node_ops[i])
 			return 1;
 	return 0;
 }
@@ -959,7 +959,7 @@ int dm_set_dev_dir(const char *dev_dir)
 	slash = dev_dir[len-1] == '/' ? "" : "/";
 
 	if (snprintf(_dm_dir, sizeof _dm_dir, "%s%s%s", dev_dir, slash, DM_DIR)
-	    >= sizeof _dm_dir) {
+	    >= (int) sizeof(_dm_dir)) {
 		log_debug("Invalid dev_dir value, %s: name too long.", dev_dir);
 		return 0;
 	}
-- 
1.7.4.1


