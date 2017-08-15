From: David Teigland <teigland@sourceware.org>
Date: Tue, 15 Aug 2017 13:04:10 -0400
Subject: master - lvmlockd: reduce io impact for finding sanlock lv free lock offset
Message-ID: <201708151704.v7FH4APj022772@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=43305ae8da20ac8ab4390a2aa81618f2973753af
Commit:        43305ae8da20ac8ab4390a2aa81618f2973753af
Parent:        aa75ca633285339a8be50ed5e5a661ea1654f8f7
Author:        Zhang Huan <zhanghuan@huayun.com>
AuthorDate:    Tue Aug 15 10:42:44 2017 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Aug 15 11:56:31 2017 -0500

lvmlockd: reduce io impact for finding sanlock lv free lock offset

currently, lvcreate for sanlock find the free lock offset
from the beginning of the lvmlock every time.
after created thousands of lvs, it will issue thousands of read
ios for lvcreate to find free lock offset.
remeber the last free lock offset will greatly reduce the impact

Signed-off-by: Zhang Huan <zhanghuan@huayun.com>
---
 daemons/lvmlockd/lvmlockd-core.c    |    1 -
 daemons/lvmlockd/lvmlockd-sanlock.c |   26 ++++++++++++++++++++++++--
 2 files changed, 24 insertions(+), 3 deletions(-)

diff --git a/daemons/lvmlockd/lvmlockd-core.c b/daemons/lvmlockd/lvmlockd-core.c
index 01259c0..aefa98a 100644
--- a/daemons/lvmlockd/lvmlockd-core.c
+++ b/daemons/lvmlockd/lvmlockd-core.c
@@ -3304,7 +3304,6 @@ static int work_init_lv(struct action *act)
 		lm_type = ls->lm_type;
 		memcpy(vg_args, ls->vg_args, MAX_ARGS);
 		free_offset = ls->free_lock_offset;
-		ls->free_lock_offset = 0;
 	}
 	pthread_mutex_unlock(&lockspaces_mutex);
 
diff --git a/daemons/lvmlockd/lvmlockd-sanlock.c b/daemons/lvmlockd/lvmlockd-sanlock.c
index aedd506..a10d02f 100644
--- a/daemons/lvmlockd/lvmlockd-sanlock.c
+++ b/daemons/lvmlockd/lvmlockd-sanlock.c
@@ -938,7 +938,9 @@ int lm_find_free_lock_sanlock(struct lockspace *ls, uint64_t *free_offset)
 	struct lm_sanlock *lms = (struct lm_sanlock *)ls->lm_data;
 	struct sanlk_resourced rd;
 	uint64_t offset;
+	uint64_t start_offset;
 	int rv;
+	int round = 0;
 
 	if (daemon_test) {
 		*free_offset = (1048576 * LV_LOCK_BEGIN) + (1048576 * (daemon_test_lv_count + 1));
@@ -951,9 +953,22 @@ int lm_find_free_lock_sanlock(struct lockspace *ls, uint64_t *free_offset)
 	rd.rs.num_disks = 1;
 	strncpy(rd.rs.disks[0].path, lms->ss.host_id_disk.path, SANLK_PATH_LEN-1);
 
-	offset = lms->align_size * LV_LOCK_BEGIN;
+	if (ls->free_lock_offset)
+		offset = ls->free_lock_offset;
+	else
+		offset = lms->align_size * LV_LOCK_BEGIN;
+
+	start_offset = offset;
 
 	while (1) {
+		if (offset >= start_offset && round) {
+			/* This indicates the all space are allocated. */
+			log_debug("S %s init_lv_san read back to start offset %llu",
+				ls->name, (unsigned long long)offset);
+			rv = -EMSGSIZE;
+			return rv;
+		}
+
 		rd.rs.disks[0].offset = offset;
 
 		memset(rd.rs.name, 0, SANLK_NAME_LEN);
@@ -963,7 +978,14 @@ int lm_find_free_lock_sanlock(struct lockspace *ls, uint64_t *free_offset)
 			/* This indicates the end of the device is reached. */
 			log_debug("S %s find_free_lock_san read limit offset %llu",
 				  ls->name, (unsigned long long)offset);
-			return -EMSGSIZE;
+
+			/* remember the NO SPACE offset, if no free area left,
+			 * search from this offset after extend */
+			*free_offset = offset;
+
+			offset = lms->align_size * LV_LOCK_BEGIN;
+			round = 1;
+			continue;
 		}
 
 		/*


