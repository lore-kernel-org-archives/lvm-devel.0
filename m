From: Dave Wysochanski <dwysocha@redhat.com>
Date: Tue,  7 Jul 2009 00:24:22 -0400
Subject: [PATCH] Remove unneeded LOCK_KEEP from vg_read() interface.
In-Reply-To: <1246940664-14890-2-git-send-email-dwysocha@redhat.com>
References: <1246940664-14890-1-git-send-email-dwysocha@redhat.com>
	<1246940664-14890-2-git-send-email-dwysocha@redhat.com>
Message-ID: <1246940664-14890-3-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Remove unneeded LOCK_KEEP from vg_read() interface.
Update comment to clarify cases where _vg_lock_and_read() may return
with an error but the lock held.  Would be nice to make the vg_read()
interface consistent with regards to lock held and error behavior.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/metadata/metadata-exported.h |    1 -
 lib/metadata/metadata.c          |    9 ++++++---
 2 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index b9e9591..6e45698 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -113,7 +113,6 @@ struct pv_segment;
 
 /* FIXME Deduce these next requirements internally instead of having caller specify. */
 #define LOCK_NONBLOCKING	0x00000100U	/* Fail if not available immediately. */
-#define LOCK_KEEP		0x00000200U	/* Do not unlock upon read failure. */
 
 /* A meta-flag, useful with toollib for_each_* functions. */
 #define READ_FOR_UPDATE 	0x00100000U
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index fda07be..3c25847 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -2793,7 +2793,6 @@ static vg_t *_vg_lock_and_read(struct cmd_context *cmd, const char *vg_name,
 			goto_bad;
 		}
 	}
-	
 
 	failure |= _vg_bad_status_bits(vg, status_flags);
 	if (failure)
@@ -2803,7 +2802,7 @@ static vg_t *_vg_lock_and_read(struct cmd_context *cmd, const char *vg_name,
 
 bad:
 	if (failure != (FAILED_NOTFOUND | READ_CHECK_EXISTENCE) &&
-	    !(misc_flags & LOCK_KEEP) && !already_locked)
+	    !already_locked)
 		unlock_vg(cmd, lock_name);
 
 	return _vg_make_handle(cmd, vg, failure);
@@ -2821,7 +2820,11 @@ bad:
  *    FAILED_RESIZEABLE
  *  - locking failed: FAILED_LOCKING
  *
- * On failures, all locks are released, unless LOCK_KEEP has been supplied.
+ * On failures, all locks are released, unless one of the following applies:
+ *  - failure == (FAILED_NOTFOUND | READ_CHECK_EXISTENCE)
+ *  - vgname_is_locked(lock_name) is true
+ * FIXME: remove the above 2 conditions if possible and make an error always
+ * release the lock.
  *
  * Volume groups are opened read-only unless flags contains READ_FOR_UPDATE.
  *
-- 
1.6.0.6


