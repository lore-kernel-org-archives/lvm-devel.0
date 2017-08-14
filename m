From: Zhang Huan <zhanghuan@huayun.com>
Date: Mon, 14 Aug 2017 19:09:39 +0800
Subject: [patch review] reduce io impact for finding sanlock lv free lock offset
Message-ID: <7E0C252E-B047-47C7-A43E-75F33FC23EF2@huayun.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

commit 19d8fbd0e142c0d35eb5bcc96671682afb548a23
Author: Huan Zhang <zhanghuan@chinac.com>
Date:   Mon Aug 14 18:51:26 2017 +0800

    reduce io impact for finding sanlock lv free lock offset

    currently, lvcreate for sanlock find the free lock offset
    from the beginning of the lvmlock every time.
    after created thousands of lvs, it will issue thousands of read
    ios for lvcreate to find free lock offset.
    remeber the last free lock offset will greatly reduce the impact

    Signed-off-by: Zhang Huan <zhanghuan@huayun.com>

diff --git a/daemons/lvmlockd/lvmlockd-core.c b/daemons/lvmlockd/lvmlockd-core.c
index 01259c0..aefa98a 100644
--- a/daemons/lvmlockd/lvmlockd-core.c
+++ b/daemons/lvmlockd/lvmlockd-core.c
@@ -3304,7 +3304,6 @@ static int work_init_lv(struct action *act)
                lm_type = ls->lm_type;
                memcpy(vg_args, ls->vg_args, MAX_ARGS);
                free_offset = ls->free_lock_offset;
-               ls->free_lock_offset = 0;
        }
        pthread_mutex_unlock(&lockspaces_mutex);

diff --git a/daemons/lvmlockd/lvmlockd-sanlock.c b/daemons/lvmlockd/lvmlockd-sanlock.c
index aedd506..c6c7cc9 100644
--- a/daemons/lvmlockd/lvmlockd-sanlock.c
+++ b/daemons/lvmlockd/lvmlockd-sanlock.c
@@ -938,7 +938,9 @@ int lm_find_free_lock_sanlock(struct lockspace *ls, uint64_t *free_offset)
        struct lm_sanlock *lms = (struct lm_sanlock *)ls->lm_data;
        struct sanlk_resourced rd;
        uint64_t offset;
+       uint64_t start_offset;
        int rv;
+       int round;

        if (daemon_test) {
                *free_offset = (1048576 * LV_LOCK_BEGIN) + (1048576 * (daemon_test_lv_count + 1));
@@ -951,9 +953,22 @@ int lm_find_free_lock_sanlock(struct lockspace *ls, uint64_t *free_offset)
        rd.rs.num_disks = 1;
        strncpy(rd.rs.disks[0].path, lms->ss.host_id_disk.path, SANLK_PATH_LEN-1);

-       offset = lms->align_size * LV_LOCK_BEGIN;
+       if (ls->free_lock_offset)
+               offset = ls->free_lock_offset;
+       else
+               offset = lms->align_size * LV_LOCK_BEGIN;
+
+       start_offset = offset;

        while (1) {
+               if (offset >= start_offset && round) {
+                       /* This indicates the all space are allocated. */
+                       log_debug("S %s init_lv_san read back to start offset %llu",
+                               ls->name, (unsigned long long)offset);
+                       rv = -EMSGSIZE;
+                       return rv;
+               }
+
                rd.rs.disks[0].offset = offset;

                memset(rd.rs.name, 0, SANLK_NAME_LEN);
@@ -963,7 +978,12 @@ int lm_find_free_lock_sanlock(struct lockspace *ls, uint64_t *free_offset)
                        /* This indicates the end of the device is reached. */
                        log_debug("S %s find_free_lock_san read limit offset %llu",
                                  ls->name, (unsigned long long)offset);
-                       return -EMSGSIZE;
+                       round = 1;
+                       offset = lms->align_size * LV_LOCK_BEGIN;
+                       rd.rs.disks[0].offset = offset;
+                       memset(rd.rs.name, 0, SANLK_NAME_LEN);
+
+                       rv = sanlock_read_resource(&rd.rs, 0);
                }

                /*



Best Regards.

Zhang Huan




