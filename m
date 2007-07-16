From: Jim Meyering <jim@meyering.net>
Date: Mon, 16 Jul 2007 19:45:32 +0200
Subject: SAME_INODE comparison
In-Reply-To: <87k5t0z1xf.fsf@rho.meyering.net> (Jim Meyering's message of
	"Mon\, 16 Jul 2007 19\:35\:56 +0200")
References: <87k5t0z1xf.fsf@rho.meyering.net>
Message-ID: <87bqecz1hf.fsf@rho.meyering.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Jim Meyering <jim@meyering.net> wrote:
> In the context of the preceding message, I saw code using memcmp
> to compare two stat buffers to see if they refer to the same inode.
>
> Any objection to using this macro,
>
> # define SAME_INODE(Stat_buf_1, Stat_buf_2) \
>    ((Stat_buf_1).st_ino == (Stat_buf_2).st_ino \
>     && (Stat_buf_1).st_dev == (Stat_buf_2).st_dev)

In case you want something concrete, here's the proposed patch:

When testing same-stat-buffer, test st_dev in addition to st_ino.
 * lib/misc/lib.h (SAME_INODE): Define.
 * lib/filters/filter-persistent.c (persistent_filter_dump):
 Use SAME_INODE in place of a direct st_ino-only comparison.
 * lib/locking/file_locking.c (_release_lock, _lock_file): Likewise.
 * WHATS_NEW: Mention this.

Signed-off-by: Jim Meyering <jim@meyering.net>
---
 WHATS_NEW                       |    1 +
 lib/filters/filter-persistent.c |    2 +-
 lib/locking/file_locking.c      |    4 ++--
 lib/misc/lib.h                  |    4 ++++
 4 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 56f579e..bef5755 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.27 - 
 ================================
+  When testing same-stat-buffer, test st_dev in addition to st_ino.
   Fix configure libdevmapper.h check when --with-dmdir is used.
   Turn _add_pv_to_vg() into external library function add_pv_to_vg().
   Add pv_by_path() external library function.
diff --git a/lib/filters/filter-persistent.c b/lib/filters/filter-persistent.c
index 91e7147..ab64cd7 100644
--- a/lib/filters/filter-persistent.c
+++ b/lib/filters/filter-persistent.c
@@ -208,7 +208,7 @@ int persistent_filter_dump(struct dev_filter *f)
 			goto out;
 		}
 
-		if (!memcmp(&info.st_ino, &info2.st_ino, sizeof(ino_t)))
+		if (SAME_INODE(info, info2))
 			break;
 	
 		fcntl_unlock_file(lockfd);
diff --git a/lib/locking/file_locking.c b/lib/locking/file_locking.c
index 3126411..8354629 100644
--- a/lib/locking/file_locking.c
+++ b/lib/locking/file_locking.c
@@ -64,7 +64,7 @@ static int _release_lock(const char *file, int unlock)
 			if (!flock(ll->lf, LOCK_NB | LOCK_EX) &&
 			    !stat(ll->res, &buf1) &&
 			    !fstat(ll->lf, &buf2) &&
-			    !memcmp(&buf1.st_ino, &buf2.st_ino, sizeof(ino_t)))
+			    SAME_INODE(buf1, buf2))
 				if (unlink(ll->res))
 					log_sys_error("unlink", ll->res);
 
@@ -189,7 +189,7 @@ static int _lock_file(const char *file, int flags)
 		}
 
 		if (!stat(ll->res, &buf1) && !fstat(ll->lf, &buf2) &&
-		    !memcmp(&buf1.st_ino, &buf2.st_ino, sizeof(ino_t)))
+		    SAME_INODE(buf1, buf2))
 			break;
 	} while (!(flags & LCK_NONBLOCK));
 
diff --git a/lib/misc/lib.h b/lib/misc/lib.h
index c3d5231..8e37930 100644
--- a/lib/misc/lib.h
+++ b/lib/misc/lib.h
@@ -32,4 +32,8 @@
 
 #include <libdevmapper.h>
 
+#define SAME_INODE(Stat_buf_1, Stat_buf_2) \
+   ((Stat_buf_1).st_ino == (Stat_buf_2).st_ino \
+    && (Stat_buf_1).st_dev == (Stat_buf_2).st_dev)
+
 #endif
-- 
1.5.3.rc1.27.ga5e40


