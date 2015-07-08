From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed,  8 Jul 2015 12:56:40 +0000 (UTC)
Subject: master - coverity: fix missing initialization
Message-ID: <20150708125640.29EBC60E2F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3ec4813ba22adedb8914089b6f17fe779d76ee77
Commit:        3ec4813ba22adedb8914089b6f17fe779d76ee77
Parent:        e8dbaf62d3b3e2a175d3b0237a4d85c009d98038
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Jul 8 14:53:23 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Jul 8 14:53:30 2015 +0200

coverity: fix missing initialization

... Using uninitialized value "lockd_state" when calling "lockd_vg"
(even though lockd_vg assigns 0 to the lockd_state, but it looks at
previous state of lockd_state just before that so we need to have
that properly initialized!)

libdm/libdm-report.c:2934: uninit_use_in_call: Using uninitialized value "tm". Field "tm.tm_gmtoff" is uninitialized when calling "_get_final_time".

daemons/lvmlockd/lvmlockctl.c:273: uninit_use_in_call: Using uninitialized element of array "r_name" when calling "format_info_r_action". (just added FIXME as this looks unfinished?)
---
 daemons/lvmlockd/lvmlockctl.c |    1 +
 libdm/libdm-report.c          |    2 +-
 tools/lvconvert.c             |    2 +-
 tools/lvcreate.c              |    2 +-
 tools/lvrename.c              |    2 +-
 tools/lvresize.c              |    2 +-
 tools/polldaemon.c            |    4 ++--
 tools/pvmove.c                |    4 ++--
 tools/toollib.c               |    6 +++---
 tools/vgreduce.c              |    2 +-
 tools/vgrename.c              |    2 +-
 11 files changed, 15 insertions(+), 14 deletions(-)

diff --git a/daemons/lvmlockd/lvmlockctl.c b/daemons/lvmlockd/lvmlockctl.c
index 51b5734..33f0a6f 100644
--- a/daemons/lvmlockd/lvmlockctl.c
+++ b/daemons/lvmlockd/lvmlockctl.c
@@ -270,6 +270,7 @@ static void format_info_line(char *line)
 
 	} else if (!strncmp(line, "info=r_action ", strlen("info=r_action "))) {
 		/* will use info from previous r */
+		/* FIXME: r_name and r_type uninitialized here??? */
 		format_info_r_action(line, r_name, r_type);
 	} else {
 		printf("UN %s\n", line);
diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index 455123f..c08dcab 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -2911,7 +2911,7 @@ static void _get_final_time(time_range_t range, struct tm *tm,
 static int _parse_formatted_date_time(char *str, struct time_value *tval)
 {
 	time_range_t range = RANGE_NONE;
-	struct tm tm;
+	struct tm tm = {0};
 	int gmt_offset;
 	int tz_supplied;
 
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 528c351..b10798e 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -3314,7 +3314,7 @@ static int lvconvert_single(struct cmd_context *cmd, struct lvconvert_params *lp
 	struct volume_group *vg;
 	int ret = ECMD_FAILED;
 	int saved_ignore_suspended_devices = ignore_suspended_devices();
-	uint32_t lockd_state;
+	uint32_t lockd_state = 0;
 
 	if (arg_count(cmd, repair_ARG)) {
 		init_ignore_suspended_devices(1);
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index f316767..4019b5d 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -1453,7 +1453,7 @@ int lvcreate(struct cmd_context *cmd, int argc, char **argv)
 	};
 	struct lvcreate_cmdline_params lcp = { 0 };
 	struct volume_group *vg;
-	uint32_t lockd_state;
+	uint32_t lockd_state = 0;
 
 	if (!_lvcreate_params(cmd, argc, argv, &lp, &lcp)) {
 		stack;
diff --git a/tools/lvrename.c b/tools/lvrename.c
index 6bbf31b..7b0791a 100644
--- a/tools/lvrename.c
+++ b/tools/lvrename.c
@@ -27,7 +27,7 @@ int lvrename(struct cmd_context *cmd, int argc, char **argv)
 	char *st;
 	struct volume_group *vg;
 	struct lv_list *lvl;
-	uint32_t lockd_state;
+	uint32_t lockd_state = 0;
 	int r = ECMD_FAILED;
 
 	if (argc == 3) {
diff --git a/tools/lvresize.c b/tools/lvresize.c
index 30ac4f9..3188f27 100644
--- a/tools/lvresize.c
+++ b/tools/lvresize.c
@@ -169,7 +169,7 @@ int lvresize(struct cmd_context *cmd, int argc, char **argv)
 	struct volume_group *vg;
 	struct dm_list *pvh = NULL;
 	struct logical_volume *lv;
-	uint32_t lockd_state;
+	uint32_t lockd_state = 0;
 	int r = ECMD_FAILED;
 
 	if (!_lvresize_params(cmd, argc, argv, &lp))
diff --git a/tools/polldaemon.c b/tools/polldaemon.c
index da890dc..ab9e474 100644
--- a/tools/polldaemon.c
+++ b/tools/polldaemon.c
@@ -139,7 +139,7 @@ int wait_for_single_lv(struct cmd_context *cmd, struct poll_operation_id *id,
 	struct volume_group *vg;
 	struct logical_volume *lv;
 	int finished = 0;
-	uint32_t lockd_state;
+	uint32_t lockd_state = 0;
 
 	/* Poll for completion */
 	while (!finished) {
@@ -369,7 +369,7 @@ static int report_progress(struct cmd_context *cmd, struct poll_operation_id *id
 {
 	struct volume_group *vg;
 	struct logical_volume *lv;
-	uint32_t lockd_state;
+	uint32_t lockd_state = 0;
 	int ret;
 
 	/*
diff --git a/tools/pvmove.c b/tools/pvmove.c
index 17416d4..70826c6 100644
--- a/tools/pvmove.c
+++ b/tools/pvmove.c
@@ -600,7 +600,7 @@ static int _set_up_pvmove(struct cmd_context *cmd, const char *pv_name,
 	struct dm_list *lvs_changed;
 	struct physical_volume *pv;
 	struct logical_volume *lv_mirr;
-	uint32_t lockd_state;
+	uint32_t lockd_state = 0;
 	unsigned flags = PVMOVE_FIRST_TIME;
 	unsigned exclusive;
 	int r = ECMD_FAILED;
@@ -726,7 +726,7 @@ static int _read_poll_id_from_pvname(struct cmd_context *cmd, const char *pv_nam
 	struct logical_volume *lv;
 	struct physical_volume *pv;
 	struct volume_group *vg;
-	uint32_t lockd_state;
+	uint32_t lockd_state = 0;
 
 	if (!pv_name) {
 		log_error(INTERNAL_ERROR "Invalid PV name parameter.");
diff --git a/tools/toollib.c b/tools/toollib.c
index 15bfa51..8c301bb 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1889,7 +1889,7 @@ static int _process_vgnameid_list(struct cmd_context *cmd, uint32_t flags,
 	struct vgnameid_list *vgnl;
 	const char *vg_name;
 	const char *vg_uuid;
-	uint32_t lockd_state;
+	uint32_t lockd_state = 0;
 	int selected;
 	int whole_selected = 0;
 	int ret_max = ECMD_PROCESSED;
@@ -2341,7 +2341,7 @@ static int _process_lv_vgnameid_list(struct cmd_context *cmd, uint32_t flags,
 	struct dm_str_list *sl;
 	struct dm_list *tags_arg;
 	struct dm_list lvnames;
-	uint32_t lockd_state;
+	uint32_t lockd_state = 0;
 	const char *vg_name;
 	const char *vg_uuid;
 	const char *vgn;
@@ -2873,7 +2873,7 @@ static int _process_pvs_in_vgs(struct cmd_context *cmd, uint32_t flags,
 	struct vgnameid_list *vgnl;
 	const char *vg_name;
 	const char *vg_uuid;
-	uint32_t lockd_state;
+	uint32_t lockd_state = 0;
 	int ret_max = ECMD_PROCESSED;
 	int ret;
 	int skip;
diff --git a/tools/vgreduce.c b/tools/vgreduce.c
index 693f538..5d43c94 100644
--- a/tools/vgreduce.c
+++ b/tools/vgreduce.c
@@ -141,7 +141,7 @@ int vgreduce(struct cmd_context *cmd, int argc, char **argv)
 {
 	struct volume_group *vg;
 	const char *vg_name;
-	uint32_t lockd_state;
+	uint32_t lockd_state = 0;
 	int ret = ECMD_FAILED;
 	int fixed = 1;
 	int repairing = arg_count(cmd, removemissing_ARG);
diff --git a/tools/vgrename.c b/tools/vgrename.c
index 188061b..7e77b57 100644
--- a/tools/vgrename.c
+++ b/tools/vgrename.c
@@ -68,7 +68,7 @@ static int vg_rename_path(struct cmd_context *cmd, const char *old_vg_path,
 	const char *vgid = NULL, *vg_name, *vg_name_old;
 	char old_path[NAME_LEN], new_path[NAME_LEN];
 	struct volume_group *vg = NULL;
-	uint32_t lockd_state;
+	uint32_t lockd_state = 0;
 	int lock_vg_old_first = 1;
 
 	vg_name_old = skip_dev_dir(cmd, old_vg_path, NULL);


