From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed,  8 Dec 2010 13:57:54 +0100
Subject: [PATCH 8/9] Locking with unlock_fs
In-Reply-To: <cover.1291802397.git.zkabelac@redhat.com>
References: <cover.1291802397.git.zkabelac@redhat.com>
Message-ID: <ab45cb0fdd5ad713224c7dd2ddaabf437bd54294.1291802397.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add support for LCK_UNLOCK_FS

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/locking/cluster_locking.c |    7 +++++++
 lib/locking/file_locking.c    |    6 ++++++
 2 files changed, 13 insertions(+), 0 deletions(-)

diff --git a/lib/locking/cluster_locking.c b/lib/locking/cluster_locking.c
index eea9974..3ef9cfb 100644
--- a/lib/locking/cluster_locking.c
+++ b/lib/locking/cluster_locking.c
@@ -401,6 +401,13 @@ int lock_resource(struct cmd_context *cmd, const char *resource, uint32_t flags)
 
 	switch (flags & LCK_SCOPE_MASK) {
 	case LCK_VG:
+		/* If unlock fs requested wait until devices are ready */
+		if (flags & LCK_UNLOCK_FS) {
+			log_very_verbose("Requesting unlock fs");
+			return _lock_for_cluster(cmd, CLVMD_CMD_UNLOCK_FS,
+						 LCK_CLUSTER_VG, resource);
+		}
+
 		if (flags == LCK_VG_BACKUP) {
 			log_very_verbose("Requesting backup of VG metadata for %s",
 					 resource);
diff --git a/lib/locking/file_locking.c b/lib/locking/file_locking.c
index ed1ccd5..8461140 100644
--- a/lib/locking/file_locking.c
+++ b/lib/locking/file_locking.c
@@ -258,6 +258,12 @@ static int _file_lock_resource(struct cmd_context *cmd, const char *resource,
 
 	switch (flags & LCK_SCOPE_MASK) {
 	case LCK_VG:
+		if (flags & LCK_UNLOCK_FS) {
+			/* Wait until devices are ready */
+			fs_unlock();
+			break;
+		}
+
 		/* Skip cache refresh for VG_GLOBAL - the caller handles it */
 		if (strcmp(resource, VG_GLOBAL))
 			lvmcache_drop_metadata(resource, 0);
-- 
1.7.3.3


