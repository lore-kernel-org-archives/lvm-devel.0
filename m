From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 16 Oct 2020 19:11:01 +0000 (GMT)
Subject: stable-2.02 - cleanup: matching declaration order
Message-ID: <20201016191101.E300B396E814@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8e778995dee7f812505f6dbf920e350b705e57c1
Commit:        8e778995dee7f812505f6dbf920e350b705e57c1
Parent:        7c80bf4daa569c994073eb525b8550df614eed19
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Aug 29 21:37:39 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 16 16:02:06 2020 +0200

cleanup: matching declaration order

Cosmetic
---
 daemons/dmeventd/dmeventd.c           |  2 +-
 daemons/dmeventd/libdevmapper-event.c |  2 +-
 daemons/lvmlockd/lvmlockd-client.h    |  2 +-
 daemons/lvmlockd/lvmlockd-core.c      |  8 ++++----
 lib/activate/activate.c               |  6 +++---
 lib/cache/lvmcache.c                  |  2 +-
 tools/reporter.c                      | 10 +++++-----
 7 files changed, 16 insertions(+), 16 deletions(-)

diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index 1b84c28ba..976ab5d47 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -2030,8 +2030,8 @@ static int _reinstate_registrations(struct dm_event_fifos *fifos)
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
index f9a8a2b4d..962928c8c 100644
--- a/daemons/dmeventd/libdevmapper-event.c
+++ b/daemons/dmeventd/libdevmapper-event.c
@@ -605,8 +605,8 @@ static int _do_event(int cmd, char *dmeventd_path, struct dm_event_daemon_messag
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
index 99aa86f94..dda4b17de 100644
--- a/daemons/lvmlockd/lvmlockd-client.h
+++ b/daemons/lvmlockd/lvmlockd-client.h
@@ -22,9 +22,9 @@ static inline daemon_handle lvmlockd_open(const char *sock)
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
index 0bf2927c5..1c87626ea 100644
--- a/daemons/lvmlockd/lvmlockd-core.c
+++ b/daemons/lvmlockd/lvmlockd-core.c
@@ -6035,14 +6035,14 @@ static void usage(char *prog, FILE *file)
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
index fb6f54541..50269acd1 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -2441,8 +2441,8 @@ int lv_suspend_if_active(struct cmd_context *cmd, const char *lvid_s, unsigned o
 			 const struct logical_volume *lv, const struct logical_volume *lv_pre)
 {
 	struct lv_activate_opts laopts = {
-		.origin_only = origin_only,
-		.exclusive = exclusive
+		.exclusive = exclusive,
+		.origin_only = origin_only
 	};
 
 	return _lv_suspend(cmd, lvid_s, &laopts, 0, lv, lv_pre);
@@ -2601,8 +2601,8 @@ int lv_resume_if_active(struct cmd_context *cmd, const char *lvid_s,
 			unsigned revert, const struct logical_volume *lv)
 {
 	struct lv_activate_opts laopts = {
-		.origin_only = origin_only,
 		.exclusive = exclusive,
+		.origin_only = origin_only,
 		.revert = revert
 	};
 
diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 2bda26b87..00d401319 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -2276,8 +2276,8 @@ int lvmcache_update_vg(struct volume_group *vg, unsigned precommitted)
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
index 2d8342151..9eac55269 100644
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


