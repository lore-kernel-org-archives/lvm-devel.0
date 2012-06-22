From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 22 Jun 2012 11:51:19 +0000 (UTC)
Subject: master - cleanup: replace memset with struct initilization
Message-ID: <20120622115119.8E90A1688@lists.fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6f3cd63551db013e3cf5dfcebc41115322d5cfe9
Commit:        6f3cd63551db013e3cf5dfcebc41115322d5cfe9
Parent:        da42ee3a1f0280742e87a96f5d0694fb869a23e0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jun 21 21:19:28 2012 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jun 22 13:23:03 2012 +0200

cleanup: replace memset with struct initilization

Simplifies the code, properly detects too long socket paths,
drops unused parameter.
---
 daemons/clvmd/clvmd-openais.c    |    3 +--
 daemons/clvmd/clvmd-singlenode.c |   14 ++++++++------
 daemons/clvmd/clvmd.c            |   25 +++++++++++++++----------
 daemons/clvmd/refresh_clvmd.c    |   12 ++++++------
 daemons/cmirrord/cluster.c       |    3 +--
 daemons/cmirrord/functions.c     |    8 ++------
 daemons/dmeventd/dmeventd.c      |   12 +++---------
 lib/cache/lvmetad.c              |    2 --
 lib/commands/toolcontext.c       |    4 +---
 lib/format1/import-export.c      |    3 +--
 lib/format1/vg_number.c          |    4 +---
 lib/format_text/format-text.c    |    3 +--
 lib/locking/cluster_locking.c    |   11 ++++++-----
 lib/metadata/lv_manip.c          |    4 +---
 libdaemon/client/daemon-client.c |    5 ++---
 libdaemon/server/daemon-server.c |    7 ++-----
 libdm/libdm-deptree.c            |    4 +---
 liblvm/lvm_lv.c                  |    4 ++--
 liblvm/lvm_misc.c                |    3 +--
 tools/pvscan.c                   |    8 +++-----
 tools/toollib.c                  |    1 -
 unit-tests/mm/pool_valgrind_t.c  |    4 +---
 22 files changed, 59 insertions(+), 85 deletions(-)

diff --git a/daemons/clvmd/clvmd-openais.c b/daemons/clvmd/clvmd-openais.c
index 5f237e9..9ce73d6 100644
--- a/daemons/clvmd/clvmd-openais.c
+++ b/daemons/clvmd/clvmd-openais.c
@@ -197,14 +197,13 @@ static int add_internal_client(int fd, fd_callback_t callback)
 
 	DEBUGLOG("Add_internal_client, fd = %d\n", fd);
 
-	client = malloc(sizeof(struct local_client));
+	client = calloc(1, sizeof(struct local_client));
 	if (!client)
 	{
 		DEBUGLOG("malloc failed\n");
 		return -1;
 	}
 
-	memset(client, 0, sizeof(struct local_client));
 	client->fd = fd;
 	client->type = CLUSTER_INTERNAL;
 	client->callback = callback;
diff --git a/daemons/clvmd/clvmd-singlenode.c b/daemons/clvmd/clvmd-singlenode.c
index 298abcb..3b35bf5 100644
--- a/daemons/clvmd/clvmd-singlenode.c
+++ b/daemons/clvmd/clvmd-singlenode.c
@@ -48,8 +48,15 @@ static void close_comms(void)
 
 static int init_comms(void)
 {
-	struct sockaddr_un addr;
 	mode_t old_mask;
+	struct sockaddr_un addr = { .sun_family = AF_UNIX };
+
+	if (!dm_strncpy(addr.sun_path, SINGLENODE_CLVMD_SOCKNAME,
+			sizeof(addr.sun_path))) {
+		DEBUGLOG("%s: singlenode socket name too long.",
+			 SINGLENODE_CLVMD_SOCKNAME);
+		return -1;
+	}
 
 	close_comms();
 
@@ -67,11 +74,6 @@ static int init_comms(void)
 		goto error;
 	}
 
-	memset(&addr, 0, sizeof(addr));
-	memcpy(addr.sun_path, SINGLENODE_CLVMD_SOCKNAME,
-	       sizeof(SINGLENODE_CLVMD_SOCKNAME));
-	addr.sun_family = AF_UNIX;
-
 	if (bind(listen_fd, (struct sockaddr *)&addr, sizeof(addr)) < 0) {
 		DEBUGLOG("Can't bind local socket: %s\n", strerror(errno));
 		goto error;
diff --git a/daemons/clvmd/clvmd.c b/daemons/clvmd/clvmd.c
index 0b866e6..4efa237 100644
--- a/daemons/clvmd/clvmd.c
+++ b/daemons/clvmd/clvmd.c
@@ -2092,20 +2092,23 @@ static int add_to_lvmqueue(struct local_client *client, struct clvm_header *msg,
 static int check_local_clvmd(void)
 {
 	int local_socket;
-	struct sockaddr_un sockaddr;
 	int ret = 0;
+	struct sockaddr_un sockaddr = { .sun_family = AF_UNIX };
+
+	if (!dm_strncpy(sockaddr.sun_path, CLVMD_SOCKNAME, sizeof(sockaddr.sun_path))) {
+		log_error("%s: clvmd socket name too long.", CLVMD_SOCKNAME);
+		return -1;
+	}
 
 	/* Open local socket */
 	if ((local_socket = socket(PF_UNIX, SOCK_STREAM, 0)) < 0) {
+		log_sys_error("socket", "local socket");
 		return -1;
 	}
 
-	memset(&sockaddr, 0, sizeof(sockaddr));
-	memcpy(sockaddr.sun_path, CLVMD_SOCKNAME, sizeof(CLVMD_SOCKNAME));
-	sockaddr.sun_family = AF_UNIX;
-
 	if (connect(local_socket,(struct sockaddr *) &sockaddr,
 		    sizeof(sockaddr))) {
+		log_sys_error("connect", "local socket");
 		ret = -1;
 	}
 
@@ -2127,9 +2130,14 @@ static void close_local_sock(int local_socket)
 /* Open the local socket, that's the one we talk to libclvm down */
 static int open_local_sock(void)
 {
-	int local_socket = -1;
-	struct sockaddr_un sockaddr;
 	mode_t old_mask;
+	int local_socket = -1;
+	struct sockaddr_un sockaddr = { .sun_family = AF_UNIX };
+
+	if (!dm_strncpy(sockaddr.sun_path, CLVMD_SOCKNAME, sizeof(sockaddr.sun_path))) {
+		log_error("%s: clvmd socket name too long.", CLVMD_SOCKNAME);
+		return -1;
+	}
 
 	close_local_sock(local_socket);
 
@@ -2148,9 +2156,6 @@ static int open_local_sock(void)
 		DEBUGLOG("setting CLOEXEC on local_socket failed: %s\n", strerror(errno));
 	fcntl(local_socket, F_SETFL, fcntl(local_socket, F_GETFL, 0) | O_NONBLOCK);
 
-	memset(&sockaddr, 0, sizeof(sockaddr));
-	memcpy(sockaddr.sun_path, CLVMD_SOCKNAME, sizeof(CLVMD_SOCKNAME));
-	sockaddr.sun_family = AF_UNIX;
 
 	if (bind(local_socket, (struct sockaddr *) &sockaddr, sizeof(sockaddr))) {
 		log_error("can't bind local socket: %m");
diff --git a/daemons/clvmd/refresh_clvmd.c b/daemons/clvmd/refresh_clvmd.c
index 9ce02f2..28b5625 100644
--- a/daemons/clvmd/refresh_clvmd.c
+++ b/daemons/clvmd/refresh_clvmd.c
@@ -47,7 +47,12 @@ static int _clvmd_sock = -1;
 static int _open_local_sock(void)
 {
 	int local_socket;
-	struct sockaddr_un sockaddr;
+	struct sockaddr_un sockaddr = { .sun_family = AF_UNIX };
+
+	if (!dm_strncpy(sockaddr.sun_path, CLVMD_SOCKNAME, sizeof(sockaddr.sun_path))) {
+		fprintf(stderr, "%s: clvmd socket name too long.", CLVMD_SOCKNAME);
+		return -1;
+	}
 
 	/* Open local socket */
 	if ((local_socket = socket(PF_UNIX, SOCK_STREAM, 0)) < 0) {
@@ -55,11 +60,6 @@ static int _open_local_sock(void)
 		return -1;
 	}
 
-	memset(&sockaddr, 0, sizeof(sockaddr));
-	memcpy(sockaddr.sun_path, CLVMD_SOCKNAME, sizeof(CLVMD_SOCKNAME));
-
-	sockaddr.sun_family = AF_UNIX;
-
 	if (connect(local_socket,(struct sockaddr *) &sockaddr,
 		    sizeof(sockaddr))) {
 		int saved_errno = errno;
diff --git a/daemons/cmirrord/cluster.c b/daemons/cmirrord/cluster.c
index 9fbf800..70c76c3 100644
--- a/daemons/cmirrord/cluster.c
+++ b/daemons/cmirrord/cluster.c
@@ -1249,7 +1249,7 @@ static void cpg_join_callback(struct clog_cpg *match,
 	uint32_t my_pid = (uint32_t)getpid();
 	uint32_t lowest = match->lowest_id;
 	struct clog_request *rq;
-	char dbuf[32];
+	char dbuf[32] = { 0 };
 
 	/* Assign my_cluster_id */
 	if ((my_cluster_id == 0xDEAD) && (joined->pid == my_pid))
@@ -1265,7 +1265,6 @@ static void cpg_join_callback(struct clog_cpg *match,
 	if (joined->nodeid == my_cluster_id)
 		goto out;
 
-	memset(dbuf, 0, sizeof(dbuf));
 	for (i = 0; i < member_list_entries - 1; i++)
 		sprintf(dbuf+strlen(dbuf), "%u-", member_list[i].nodeid);
 	sprintf(dbuf+strlen(dbuf), "(%u)", joined->nodeid);
diff --git a/daemons/cmirrord/functions.c b/daemons/cmirrord/functions.c
index 3e8fd20..f6e0918 100644
--- a/daemons/cmirrord/functions.c
+++ b/daemons/cmirrord/functions.c
@@ -235,11 +235,9 @@ static int rw_log(struct log_c *lc, int do_write)
  */
 static int read_log(struct log_c *lc)
 {
-	struct log_header lh;
+	struct log_header lh = { 0 };
 	size_t bitset_size;
 
-	memset(&lh, 0, sizeof(struct log_header));
-
 	if (rw_log(lc, 0))
 		return -EIO; /* Failed disk read */
 
@@ -1724,14 +1722,12 @@ int do_request(struct clog_request *rq, int server)
 static void print_bits(dm_bitset_t bs, int print)
 {
 	int i, size;
-	char outbuf[128];
+	char outbuf[128] = { 0 };
 	unsigned char *buf = (unsigned char *)(bs + 1);
 
 	size = (*bs % 8) ? 1 : 0;
 	size += (*bs / 8);
 
-	memset(outbuf, 0, sizeof(outbuf));
-
 	for (i = 0; i < size; i++) {
 		if (!(i % 16)) {
 			if (outbuf[0] != '\0') {
diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index 91ef690..2ffe7f4 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -1437,11 +1437,9 @@ static int _do_process_request(struct dm_event_daemon_message *msg)
 {
 	int ret;
 	char *answer;
-	static struct message_data message_data;
+	struct message_data message_data = { .msg =  msg };
 
 	/* Parse the message. */
-	memset(&message_data, 0, sizeof(message_data));
-	message_data.msg = msg;
 	if (msg->cmd == DM_EVENT_CMD_HELLO || msg->cmd == DM_EVENT_CMD_DIE)  {
 		ret = 0;
 		answer = msg->data;
@@ -1473,9 +1471,7 @@ static int _do_process_request(struct dm_event_daemon_message *msg)
 static void _process_request(struct dm_event_fifos *fifos)
 {
 	int die = 0;
-	struct dm_event_daemon_message msg;
-
-	memset(&msg, 0, sizeof(msg));
+	struct dm_event_daemon_message msg = { 0 };
 
 	/*
 	 * Read the request from the client (client_read, client_write
@@ -1580,10 +1576,8 @@ static void _sig_alarm(int signum __attribute__((unused)))
 static void _init_thread_signals(void)
 {
 	sigset_t my_sigset;
-	struct sigaction act;
+	struct sigaction act = { .sa_handler = _sig_alarm };
 
-	memset(&act, 0, sizeof(act));
-	act.sa_handler = _sig_alarm;
 	sigaction(SIGALRM, &act, NULL);
 	sigfillset(&my_sigset);
 
diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index f2bb8eb..291adfa 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -669,7 +669,6 @@ int pvscan_lvmetad_single(struct cmd_context *cmd, struct device *dev)
 {
 	struct label *label;
 	struct lvmcache_info *info;
-	struct physical_volume pv;
 	struct _pvscan_lvmetad_baton baton;
 	/* Create a dummy instance. */
 	struct format_instance_ctx fic = { .type = 0 };
@@ -687,7 +686,6 @@ int pvscan_lvmetad_single(struct cmd_context *cmd, struct device *dev)
 	}
 
 	info = (struct lvmcache_info *) label->info;
-	memset(&pv, 0, sizeof(pv));
 
 	baton.vg = NULL;
 	baton.fid = lvmcache_fmt(info)->ops->create_instance(lvmcache_fmt(info),
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index cc23163..529bd51 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -736,11 +736,9 @@ static struct dev_filter *_init_filter_components(struct cmd_context *cmd)
 {
 	int nr_filt = 0;
 	const struct dm_config_node *cn;
-	struct dev_filter *filters[MAX_FILTERS];
+	struct dev_filter *filters[MAX_FILTERS] = { 0 };
 	struct dev_filter *composite;
 
-	memset(filters, 0, sizeof(filters));
-
 	/*
 	 * Filters listed in order: top one gets applied first.
 	 * Failure to initialise some filters is not fatal.
diff --git a/lib/format1/import-export.c b/lib/format1/import-export.c
index f1a874d..1370d12 100644
--- a/lib/format1/import-export.c
+++ b/lib/format1/import-export.c
@@ -556,7 +556,7 @@ int export_lvs(struct disk_list *dl, struct volume_group *vg,
 int import_snapshots(struct dm_pool *mem __attribute__((unused)), struct volume_group *vg,
 		     struct dm_list *pvds)
 {
-	struct logical_volume *lvs[MAX_LV];
+	struct logical_volume *lvs[MAX_LV] = { 0 };
 	struct disk_list *dl;
 	struct lvd_list *ll;
 	struct lv_disk *lvd;
@@ -564,7 +564,6 @@ int import_snapshots(struct dm_pool *mem __attribute__((unused)), struct volume_
 	struct logical_volume *org, *cow;
 
 	/* build an index of lv numbers */
-	memset(lvs, 0, sizeof(lvs));
 	dm_list_iterate_items(dl, pvds) {
 		dm_list_iterate_items(ll, &dl->lvds) {
 			lvd = &ll->lvd;
diff --git a/lib/format1/vg_number.c b/lib/format1/vg_number.c
index 47570f5..ed52554 100644
--- a/lib/format1/vg_number.c
+++ b/lib/format1/vg_number.c
@@ -29,7 +29,7 @@ int get_free_vg_number(struct format_instance *fid, struct dev_filter *filter,
 	struct dm_list all_pvs;
 	struct disk_list *dl;
 	struct dm_pool *mem = dm_pool_create("lvm1 vg_number", 10 * 1024);
-	int numbers[MAX_VG], i, r = 0;
+	int i, r = 0, numbers[MAX_VG] = { 0 };
 
 	dm_list_init(&all_pvs);
 
@@ -39,8 +39,6 @@ int get_free_vg_number(struct format_instance *fid, struct dev_filter *filter,
 	if (!read_pvs_in_vg(fid->fmt, NULL, filter, mem, &all_pvs))
 		goto_out;
 
-	memset(numbers, 0, sizeof(numbers));
-
 	dm_list_iterate_items(dl, &all_pvs) {
 		if (!*dl->pvd.vg_name || !strcmp((char *)dl->pvd.vg_name, candidate_vg))
 			continue;
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 3c89dfa..aea03c9 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -1266,11 +1266,10 @@ static int _write_single_mda(struct metadata_area *mda, void *baton)
 	struct _write_single_mda_baton *p = baton;
 	struct mda_context *mdac;
 
-	char buf[MDA_HEADER_SIZE] __attribute__((aligned(8)));
+	char buf[MDA_HEADER_SIZE] __attribute__((aligned(8))) = { 0 };
 	struct mda_header *mdah = (struct mda_header *) buf;
 
 	mdac = mda->metadata_locn;
-	memset(&buf, 0, sizeof(buf));
 	mdah->size = mdac->area.size;
 	rlocn_set_ignored(mdah->raw_locns, mda_is_ignored(mda));
 
diff --git a/lib/locking/cluster_locking.c b/lib/locking/cluster_locking.c
index 3e2543b..f9d6328 100644
--- a/lib/locking/cluster_locking.c
+++ b/lib/locking/cluster_locking.c
@@ -65,7 +65,12 @@ static int _clvmd_sock = -1;
 static int _open_local_sock(int suppress_messages)
 {
 	int local_socket;
-	struct sockaddr_un sockaddr;
+	struct sockaddr_un sockaddr = { .sun_family = AF_UNIX };
+
+	if (!dm_strncpy(sockaddr.sun_path, CLVMD_SOCKNAME, sizeof(sockaddr.sun_path))) {
+		log_error("%s: clvmd socket name too long.", CLVMD_SOCKNAME);
+		return -1;
+	}
 
 	/* Open local socket */
 	if ((local_socket = socket(PF_UNIX, SOCK_STREAM, 0)) < 0) {
@@ -74,10 +79,6 @@ static int _open_local_sock(int suppress_messages)
 		return -1;
 	}
 
-	memset(&sockaddr, 0, sizeof(sockaddr));
-	memcpy(sockaddr.sun_path, CLVMD_SOCKNAME, sizeof(CLVMD_SOCKNAME));
-
-	sockaddr.sun_family = AF_UNIX;
 
 	if (connect(local_socket,(struct sockaddr *) &sockaddr,
 		    sizeof(sockaddr))) {
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 3913680..5c715a8 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -180,13 +180,11 @@ static struct seg_pvs *_find_seg_pvs_by_le(struct dm_list *list, uint32_t le)
  */
 uint32_t find_free_lvnum(struct logical_volume *lv)
 {
-	int lvnum_used[MAX_RESTRICTED_LVS + 1];
+	int lvnum_used[MAX_RESTRICTED_LVS + 1] = { 0 };
 	uint32_t i = 0;
 	struct lv_list *lvl;
 	int lvnum;
 
-	memset(&lvnum_used, 0, sizeof(lvnum_used));
-
 	dm_list_iterate_items(lvl, &lv->vg->lvs) {
 		lvnum = lvnum_from_lvid(&lvl->lv->lvid);
 		if (lvnum <= MAX_RESTRICTED_LVS)
diff --git a/libdaemon/client/daemon-client.c b/libdaemon/client/daemon-client.c
index 906de38..6aad75c 100644
--- a/libdaemon/client/daemon-client.c
+++ b/libdaemon/client/daemon-client.c
@@ -26,17 +26,16 @@
 daemon_handle daemon_open(daemon_info i) {
 	daemon_handle h = { .protocol_version = 0, .error = 0 };
 	daemon_reply r = { .cft = NULL };
-	struct sockaddr_un sockaddr;
+	struct sockaddr_un sockaddr = { .sun_family = AF_UNIX };
 
 	if ((h.socket_fd = socket(PF_UNIX, SOCK_STREAM /* | SOCK_NONBLOCK */, 0)) < 0)
 		goto error;
 
-	memset(&sockaddr, 0, sizeof(sockaddr));
 	if (!dm_strncpy(sockaddr.sun_path, i.socket, sizeof(sockaddr.sun_path))) {
 		fprintf(stderr, "%s: daemon socket path too long.\n", i.socket);
 		goto error;
 	}
-	sockaddr.sun_family = AF_UNIX;
+
 	if (connect(h.socket_fd,(struct sockaddr *) &sockaddr, sizeof(sockaddr)))
 		goto error;
 
diff --git a/libdaemon/server/daemon-server.c b/libdaemon/server/daemon-server.c
index 568ef36..65b28e4 100644
--- a/libdaemon/server/daemon-server.c
+++ b/libdaemon/server/daemon-server.c
@@ -129,7 +129,7 @@ union sockaddr_union {
 static int _handle_preloaded_socket(int fd, const char *path)
 {
 	struct stat st_fd;
-	union sockaddr_union sockaddr;
+	union sockaddr_union sockaddr = { .sa.sa_family = 0 };
 	int type = 0;
 	socklen_t len = sizeof(type);
 	size_t path_len = strlen(path);
@@ -144,7 +144,6 @@ static int _handle_preloaded_socket(int fd, const char *path)
 	    len != sizeof(type) || type != SOCK_STREAM)
 		return 0;
 
-	memset(&sockaddr, 0, sizeof(sockaddr));
 	len = sizeof(sockaddr);
 	if (getsockname(fd, &sockaddr.sa, &len) < 0 ||
 	    len < sizeof(sa_family_t) ||
@@ -204,7 +203,7 @@ out:
 static int _open_socket(daemon_state s)
 {
 	int fd = -1;
-	struct sockaddr_un sockaddr;
+	struct sockaddr_un sockaddr = { .sun_family = AF_UNIX };
 	mode_t old_mask;
 
 	(void) dm_prepare_selinux_context(s.socket_path, S_IFSOCK);
@@ -223,12 +222,10 @@ static int _open_socket(daemon_state s)
 	fcntl(fd, F_SETFL, fcntl(fd, F_GETFL, 0) | O_NONBLOCK);
 
 	fprintf(stderr, "[D] creating %s\n", s.socket_path);
-	memset(&sockaddr, 0, sizeof(sockaddr));
 	if (!dm_strncpy(sockaddr.sun_path, s.socket_path, sizeof(sockaddr.sun_path))) {
 		fprintf(stderr, "%s: daemon socket path too long.\n", s.socket_path);
 		goto error;
 	}
-	sockaddr.sun_family = AF_UNIX;
 
 	if (bind(fd, (struct sockaddr *) &sockaddr, sizeof(sockaddr))) {
 		perror("can't bind local socket.");
diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index 5ce44d0..6b428d6 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -1082,7 +1082,7 @@ struct dm_tree_node *dm_tree_add_new_dev_with_udev_flags(struct dm_tree *dtree,
 							 uint16_t udev_flags)
 {
 	struct dm_tree_node *dnode;
-	struct dm_info info;
+	struct dm_info info = { 0 };
 	const char *name2;
 	const char *uuid2;
 
@@ -1102,8 +1102,6 @@ struct dm_tree_node *dm_tree_add_new_dev_with_udev_flags(struct dm_tree *dtree,
 			return NULL;
 		}
 
-		memset(&info, 0, sizeof(info));
-
 		if (!(dnode = _create_dm_tree_node(dtree, name2, uuid2, &info,
 						   context, 0)))
 			return_NULL;
diff --git a/liblvm/lvm_lv.c b/liblvm/lvm_lv.c
index 336b714..23ccbe8 100644
--- a/liblvm/lvm_lv.c
+++ b/liblvm/lvm_lv.c
@@ -144,7 +144,7 @@ static int _lv_set_default_linear_params(struct cmd_context *cmd,
  */
 lv_t lvm_vg_create_lv_linear(vg_t vg, const char *name, uint64_t size)
 {
-	struct lvcreate_params lp;
+	struct lvcreate_params lp = { 0 };
 	uint64_t extents;
 	struct lv_list *lvl;
 
@@ -152,7 +152,7 @@ lv_t lvm_vg_create_lv_linear(vg_t vg, const char *name, uint64_t size)
 		return NULL;
 	if (!vg_check_write_mode(vg))
 		return NULL;
-	memset(&lp, 0, sizeof(lp));
+
 	extents = extents_from_size(vg->cmd, size / SECTOR_SIZE,
 				    vg->extent_size);
 	_lv_set_default_params(&lp, vg, name, extents);
diff --git a/liblvm/lvm_misc.c b/liblvm/lvm_misc.c
index 3bf6a04..0a0ea12 100644
--- a/liblvm/lvm_misc.c
+++ b/liblvm/lvm_misc.c
@@ -50,9 +50,8 @@ struct lvm_property_value get_property(const pv_t pv, const vg_t vg,
 				       const pvseg_t pvseg, const char *name)
 {
 	struct lvm_property_type prop;
-	struct lvm_property_value v;
+	struct lvm_property_value v = { 0 };
 
-	memset(&v, 0, sizeof(v));
 	prop.id = name;
 
 	if (pv) {
diff --git a/tools/pvscan.c b/tools/pvscan.c
index f0e7408..62034c9 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -28,9 +28,9 @@ static void _pvscan_display_single(struct cmd_context *cmd,
 	char uuid[64] __attribute__((aligned(8)));
 	unsigned vg_name_len = 0;
 
-	char pv_tmp_name[NAME_LEN] = { 0, };
-	char vg_tmp_name[NAME_LEN] = { 0, };
-	char vg_name_this[NAME_LEN] = { 0, };
+	char pv_tmp_name[NAME_LEN] = { 0 };
+	char vg_tmp_name[NAME_LEN] = { 0 };
+	char vg_name_this[NAME_LEN] = { 0 };
 
 	/* short listing? */
 	if (arg_count(cmd, short_ARG) > 0) {
@@ -49,8 +49,6 @@ static void _pvscan_display_single(struct cmd_context *cmd,
 		/* return; */
 	}
 
-	memset(pv_tmp_name, 0, sizeof(pv_tmp_name));
-
 	vg_name_len = strlen(pv_vg_name(pv)) + 1;
 
 	if (arg_count(cmd, uuid_ARG)) {
diff --git a/tools/toollib.c b/tools/toollib.c
index d5ad805..361052b 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -674,7 +674,6 @@ static int _process_all_devs(struct cmd_context *cmd, void *handle,
 			dm_list_init(&pv_dummy.tags);
 			dm_list_init(&pv_dummy.segments);
 			pv_dummy.dev = dev;
-			pv_dummy.fmt = NULL;
 			pv = &pv_dummy;
 		}
 		ret = process_single_pv(cmd, NULL, pv, handle);
diff --git a/unit-tests/mm/pool_valgrind_t.c b/unit-tests/mm/pool_valgrind_t.c
index b430a9c..704f116 100644
--- a/unit-tests/mm/pool_valgrind_t.c
+++ b/unit-tests/mm/pool_valgrind_t.c
@@ -158,11 +158,9 @@ static void check_object_growth()
 {
 	int i;
 	struct dm_pool *p = dm_pool_create("", 32);
-	char data[100];
+	char data[100] = { 0 };
 	void *obj;
 
-	memset(data, 0, sizeof(data));
-
 	dm_pool_begin_object(p, 43);
 	for (i = 1; i < 100; i++)
 		dm_pool_grow_object(p, data, i);


