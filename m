From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue,  1 Sep 2020 17:02:09 +0000 (GMT)
Subject: master - cleanup: matching declaration order
Message-ID: <20200901170209.DA2EB3953D03@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=dbb19f6ace5210a880f107cbae34081db0457d1e
Commit:        dbb19f6ace5210a880f107cbae34081db0457d1e
Parent:        56c41b7522d2a9ab12f15a65b8200545a47f5412
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Aug 29 21:37:39 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Sep 1 17:57:50 2020 +0200

cleanup: matching declaration order

Cosmetic
---
 daemons/dmeventd/dmeventd.c           |  2 +-
 daemons/dmeventd/libdevmapper-event.c |  2 +-
 daemons/lvmlockd/lvmlockd-client.h    |  2 +-
 daemons/lvmlockd/lvmlockd-core.c      |  8 ++++----
 lib/activate/activate.c               |  6 +++---
 lib/cache/lvmcache.c                  |  4 ++--
 tools/reporter.c                      | 10 +++++-----
 7 files changed, 17 insertions(+), 17 deletions(-)

diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index 96e70919b..4c3ef74f1 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -2028,8 +2028,8 @@ static int _reinstate_registrations(struct dm_event_fifos *fifos)
 static void _restart_dmeventd(void)
 {
 	struct dm_event_fifos fifos = {
-		.server = -1,
 		.client = -1,
+		.server = -1,
 		/* FIXME Make these either configurable or depend directly on dmeventd_path */
 		.client_path = DM_EVENT_FIFO_CLIENT,
 		.server_path = DM_EVENT_FIFO_SERVER
diff --git a/daemons/dmeventd/libdevmapper-event.c b/daemons/dmeventd/libdevmapper-event.c
index 780d10db9..7e09ff07b 100644
--- a/daemons/dmeventd/libdevmapper-event.c
+++ b/daemons/dmeventd/libdevmapper-event.c
@@ -615,8 +615,8 @@ static int _do_event(int cmd, char *dmeventd_path, struct dm_event_daemon_messag
 {
 	int ret;
 	struct dm_event_fifos fifos = {
-		.server = -1,
 		.client = -1,
+		.server = -1,
 		/* FIXME Make these either configurable or depend directly on dmeventd_path */
 		.client_path = DM_EVENT_FIFO_CLIENT,
 		.server_path = DM_EVENT_FIFO_SERVER
diff --git a/daemons/lvmlockd/lvmlockd-client.h b/daemons/lvmlockd/lvmlockd-client.h
index 1d49dded8..539ee5cd8 100644
--- a/daemons/lvmlockd/lvmlockd-client.h
+++ b/daemons/lvmlockd/lvmlockd-client.h
@@ -23,9 +23,9 @@ static inline daemon_handle lvmlockd_open(const char *sock)
 	daemon_info lvmlockd_info = {
 		.path = "lvmlockd",
 		.socket = sock ?: LVMLOCKD_SOCKET,
+		.autostart = 0,
 		.protocol = "lvmlockd",
 		.protocol_version = 1,
-		.autostart = 0
 	};
 
 	return daemon_open(lvmlockd_info);
diff --git a/daemons/lvmlockd/lvmlockd-core.c b/daemons/lvmlockd/lvmlockd-core.c
index 84272c4d7..a0803de39 100644
--- a/daemons/lvmlockd/lvmlockd-core.c
+++ b/daemons/lvmlockd/lvmlockd-core.c
@@ -6038,14 +6038,14 @@ static void usage(char *prog, FILE *file)
 int main(int argc, char *argv[])
 {
 	daemon_state ds = {
-		.daemon_main = main_loop,
-		.daemon_init = NULL,
-		.daemon_fini = NULL,
+		.name = "lvmlockd",
 		.pidfile = getenv("LVM_LVMLOCKD_PIDFILE"),
 		.socket_path = getenv("LVM_LVMLOCKD_SOCKET"),
 		.protocol = lvmlockd_protocol,
 		.protocol_version = lvmlockd_protocol_version,
-		.name = "lvmlockd",
+		.daemon_init = NULL,
+		.daemon_fini = NULL,
+		.daemon_main = main_loop,
 	};
 
 	static struct option long_options[] = {
diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 22c4e6318..0c6bd1a9a 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -2269,8 +2269,8 @@ int lv_suspend_if_active(struct cmd_context *cmd, const char *lvid_s, unsigned o
 			 const struct logical_volume *lv, const struct logical_volume *lv_pre)
 {
 	struct lv_activate_opts laopts = {
-		.origin_only = origin_only,
-		.exclusive = exclusive
+		.exclusive = exclusive,
+		.origin_only = origin_only
 	};
 
 	return _lv_suspend(cmd, lvid_s, &laopts, 0, lv, lv_pre);
@@ -2381,8 +2381,8 @@ int lv_resume_if_active(struct cmd_context *cmd, const char *lvid_s,
 			unsigned revert, const struct logical_volume *lv)
 {
 	struct lv_activate_opts laopts = {
-		.origin_only = origin_only,
 		.exclusive = exclusive,
+		.origin_only = origin_only,
 		.revert = revert
 	};
 
diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 147d0f1cc..cad8247c7 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -1708,8 +1708,8 @@ int lvmcache_update_vg_from_write(struct volume_group *vg)
 	char pvid_s[ID_LEN + 1] __attribute__((aligned(8)));
 	struct lvmcache_vgsummary vgsummary = {
 		.vgname = vg->name,
-		.vgstatus = vg->status,
 		.vgid = vg->id,
+		.vgstatus = vg->status,
 		.system_id = vg->system_id,
 		.lock_type = vg->lock_type
 	};
@@ -1745,8 +1745,8 @@ int lvmcache_update_vg_from_read(struct volume_group *vg, unsigned precommitted)
 	char pvid_s[ID_LEN + 1] __attribute__((aligned(8)));
 	struct lvmcache_vgsummary vgsummary = {
 		.vgname = vg->name,
-		.vgstatus = vg->status,
 		.vgid = vg->id,
+		.vgstatus = vg->status,
 		.system_id = vg->system_id,
 		.lock_type = vg->lock_type
 	};
diff --git a/tools/reporter.c b/tools/reporter.c
index db982b393..9fb8b128c 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -322,8 +322,8 @@ static int _do_pvsegs_sub_single(struct cmd_context *cmd,
 	struct lv_segment *seg = pvseg->lvseg;
 
 	struct segment_type _freeseg_type = {
-		.name = "free",
 		.flags = SEG_VIRTUAL | SEG_CANNOT_BE_ZEROED,
+		.name = "free",
 	};
 
 	struct volume_group _free_vg = {
@@ -336,24 +336,24 @@ static int _do_pvsegs_sub_single(struct cmd_context *cmd,
 	};
 
 	struct logical_volume _free_logical_volume = {
-		.vg = vg ?: &_free_vg,
 		.name = "",
+		.vg = vg ?: &_free_vg,
 		.status = VISIBLE_LV,
 		.major = -1,
 		.minor = -1,
-		.tags = DM_LIST_HEAD_INIT(_free_logical_volume.tags),
+		.snapshot_segs = DM_LIST_HEAD_INIT(_free_logical_volume.snapshot_segs),
 		.segments = DM_LIST_HEAD_INIT(_free_logical_volume.segments),
+		.tags = DM_LIST_HEAD_INIT(_free_logical_volume.tags),
 		.segs_using_this_lv = DM_LIST_HEAD_INIT(_free_logical_volume.segs_using_this_lv),
 		.indirect_glvs = DM_LIST_HEAD_INIT(_free_logical_volume.indirect_glvs),
-		.snapshot_segs = DM_LIST_HEAD_INIT(_free_logical_volume.snapshot_segs),
 	};
 
 	struct lv_segment _free_lv_segment = {
 		.lv = &_free_logical_volume,
 		.segtype = &_freeseg_type,
 		.len = pvseg->len,
-		.tags = DM_LIST_HEAD_INIT(_free_lv_segment.tags),
 		.origin_list = DM_LIST_HEAD_INIT(_free_lv_segment.origin_list),
+		.tags = DM_LIST_HEAD_INIT(_free_lv_segment.tags),
 	};
 
 	struct lv_with_info_and_seg_status status = {


