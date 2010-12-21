From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 21 Dec 2010 16:41:49 +0100
Subject: [PATCH 17/23] Add check for dm_snprintf result
In-Reply-To: <cover.1292945707.git.zkabelac@redhat.com>
References: <cover.1292945707.git.zkabelac@redhat.com>
Message-ID: <a8e673868df6582ac8916843f7f5c77d8dcdb2cf.1292945707.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Check whether dm_snprintf() was successfull.
For cluster lock use one dm_snprintf() instead of two calls with
just one different letter. (For file lock we print different
resouce string for P_ - skiping '#' sign - is that needed ?

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/locking/cluster_locking.c |   14 ++++++++------
 lib/locking/file_locking.c    |   16 ++++++++++++----
 2 files changed, 20 insertions(+), 10 deletions(-)

diff --git a/lib/locking/cluster_locking.c b/lib/locking/cluster_locking.c
index eea9974..8b7fe99 100644
--- a/lib/locking/cluster_locking.c
+++ b/lib/locking/cluster_locking.c
@@ -409,12 +409,14 @@ int lock_resource(struct cmd_context *cmd, const char *resource, uint32_t flags)
 		}
 
 		/* If the VG name is empty then lock the unused PVs */
-		if (is_orphan_vg(resource) || is_global_vg(resource) || (flags & LCK_CACHE))
-			dm_snprintf(lockname, sizeof(lockname), "P_%s",
-				    resource);
-		else
-			dm_snprintf(lockname, sizeof(lockname), "V_%s",
-				    resource);
+		if (dm_snprintf(lockname, sizeof(lockname), "%c_%s",
+				(is_orphan_vg(resource) ||
+				 is_global_vg(resource) ||
+				 (flags & LCK_CACHE)) ?  'P' : 'V',
+				resource)  < 0) {
+			log_error("Locking resource %s too long.", resource);
+			return 0;
+		}
 
 		lock_scope = "VG";
 		clvmd_cmd = CLVMD_CMD_LOCK_VG;
diff --git a/lib/locking/file_locking.c b/lib/locking/file_locking.c
index 9137a30..bfee314 100644
--- a/lib/locking/file_locking.c
+++ b/lib/locking/file_locking.c
@@ -269,11 +269,19 @@ static int _file_lock_resource(struct cmd_context *cmd, const char *resource,
 			break;
 
 		if (is_orphan_vg(resource) || is_global_vg(resource))
-			dm_snprintf(lockfile, sizeof(lockfile),
-				     "%s/P_%s", _lock_dir, resource + 1);
+			if (dm_snprintf(lockfile, sizeof(lockfile),
+					"%s/P_%s", _lock_dir, resource + 1) < 0) {
+				log_error("Too long locking filename %s/P_%s.",
+					  _lock_dir, resource + 1);
+				return 0;
+			}
 		else
-			dm_snprintf(lockfile, sizeof(lockfile),
-				     "%s/V_%s", _lock_dir, resource);
+			if (dm_snprintf(lockfile, sizeof(lockfile),
+					"%s/V_%s", _lock_dir, resource) < 0) {
+				log_error("Too long locking filename %s/V_%s.",
+					  _lock_dir, resource);
+				return 0;
+			}
 
 		if (!_lock_file(lockfile, flags))
 			return_0;
-- 
1.7.3.4


