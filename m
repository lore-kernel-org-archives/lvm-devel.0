From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 12 Feb 2018 16:20:38 -0500
Subject: master - clean: drop unneeded -1 for snprintf
Message-ID: <201802122120.w1CLKc8B023695@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7239a45b79a6076c198e0542161146257114f5be
Commit:        7239a45b79a6076c198e0542161146257114f5be
Parent:        d94036f8ed412457f2044f0b36aebe24f7fcc707
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Feb 12 21:50:07 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Feb 12 22:14:25 2018 +0100

clean: drop unneeded -1 for snprintf

man gives:
snprintf() and vsnprintf() write at most size bytes
(including the terminating null byte ('\0')) to str.
---
 daemons/lvmetad/lvmetad-core.c      |    2 +-
 daemons/lvmlockd/lvmlockd-dlm.c     |    2 +-
 daemons/lvmlockd/lvmlockd-sanlock.c |    4 ++--
 lib/activate/activate.c             |    2 +-
 libdm/libdm-config.c                |    2 +-
 libdm/libdm-file.c                  |    3 +--
 libdm/libdm-string.c                |    2 +-
 7 files changed, 8 insertions(+), 9 deletions(-)

diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index 6d5f6a7..04a7224 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -2432,7 +2432,7 @@ static response get_global_info(lvmetad_state *s, request r)
 	pid = (int)daemon_request_int(r, "pid", 0);
 
 	if (s->flags & GLFL_DISABLE) {
-		snprintf(reason, REASON_BUF_SIZE - 1, "%s%s%s%s%s",
+		snprintf(reason, REASON_BUF_SIZE, "%s%s%s%s%s",
 			 (s->flags & GLFL_DISABLE_REASON_DIRECT)     ? LVMETAD_DISABLE_REASON_DIRECT "," : "",
 			 (s->flags & GLFL_DISABLE_REASON_REPAIR)     ? LVMETAD_DISABLE_REASON_REPAIR "," : "",
 			 (s->flags & GLFL_DISABLE_REASON_LVM1)       ? LVMETAD_DISABLE_REASON_LVM1 "," : "",
diff --git a/daemons/lvmlockd/lvmlockd-dlm.c b/daemons/lvmlockd/lvmlockd-dlm.c
index 9440821..d9dfabb 100644
--- a/daemons/lvmlockd/lvmlockd-dlm.c
+++ b/daemons/lvmlockd/lvmlockd-dlm.c
@@ -699,7 +699,7 @@ int lm_hosts_dlm(struct lockspace *ls, int notify)
 		return 0;
 
 	memset(ls_nodes_path, 0, sizeof(ls_nodes_path));
-	snprintf(ls_nodes_path, PATH_MAX-1, "%s/%s/nodes",
+	snprintf(ls_nodes_path, PATH_MAX, "%s/%s/nodes",
 		 DLM_LOCKSPACES_PATH, ls->name);
 
 	if (!(ls_dir = opendir(ls_nodes_path)))
diff --git a/daemons/lvmlockd/lvmlockd-sanlock.c b/daemons/lvmlockd/lvmlockd-sanlock.c
index 16db2d6..795362a 100644
--- a/daemons/lvmlockd/lvmlockd-sanlock.c
+++ b/daemons/lvmlockd/lvmlockd-sanlock.c
@@ -1069,10 +1069,10 @@ int lm_prepare_lockspace_sanlock(struct lockspace *ls)
 	 * and appending "lockctl" to get /path/to/lvmlockctl.
 	 */
 	memset(killpath, 0, sizeof(killpath));
-	snprintf(killpath, SANLK_PATH_LEN - 1, "%slockctl", LVM_PATH);
+	snprintf(killpath, SANLK_PATH_LEN, "%slockctl", LVM_PATH);
 
 	memset(killargs, 0, sizeof(killargs));
-	snprintf(killargs, SANLK_PATH_LEN - 1, "--kill %s", ls->vg_name);
+	snprintf(killargs, SANLK_PATH_LEN, "--kill %s", ls->vg_name);
 
 	rv = check_args_version(ls->vg_args, VG_LOCK_ARGS_MAJOR);
 	if (rv < 0) {
diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 7a37130..2328abe 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -606,7 +606,7 @@ int module_present(struct cmd_context *cmd, const char *target_name)
 #endif
 	struct stat st;
 	char path[PATH_MAX];
-	int i = dm_snprintf(path, (sizeof(path) - 1), "%smodule/dm_%s",
+	int i = dm_snprintf(path, sizeof(path), "%smodule/dm_%s",
 			    dm_sysfs_dir(), target_name);
 
 	if (i > 0) {
diff --git a/libdm/libdm-config.c b/libdm/libdm-config.c
index e1ca210..746ef07 100644
--- a/libdm/libdm-config.c
+++ b/libdm/libdm-config.c
@@ -244,7 +244,7 @@ static int _line_append(struct config_output *out, const char *fmt, ...)
 	 */
 
 	va_start(ap, fmt);
-	n = vsnprintf(&buf[0], sizeof buf - 1, fmt, ap);
+	n = vsnprintf(buf, sizeof(buf), fmt, ap);
 	va_end(ap);
 
 	if (n < 0) {
diff --git a/libdm/libdm-file.c b/libdm/libdm-file.c
index 2c313b3..e7416f1 100644
--- a/libdm/libdm-file.c
+++ b/libdm/libdm-file.c
@@ -187,8 +187,7 @@ retry_fcntl:
 		goto fail_close_unlink;
 	}
 
-	memset(buffer, 0, sizeof(buffer));
-	snprintf(buffer, sizeof(buffer)-1, "%u\n", getpid());
+	snprintf(buffer, sizeof(buffer), "%u\n", getpid());
 
 	bufferlen = strlen(buffer);
 	write_out = write(fd, buffer, bufferlen);
diff --git a/libdm/libdm-string.c b/libdm/libdm-string.c
index 2085aa8..cf9690c 100644
--- a/libdm/libdm-string.c
+++ b/libdm/libdm-string.c
@@ -611,7 +611,7 @@ const char *dm_size_to_string(struct dm_pool *mem, uint64_t size,
 		precision = 2;
 	}
 
-	snprintf(size_buf, SIZE_BUF - 1, "%s%.*f%s", prefix, precision,
+	snprintf(size_buf, SIZE_BUF, "%s%.*f%s", prefix, precision,
 		 (double) size / byte, include_suffix ? size_str[base + s][suffix_type] : "");
 
 	return size_buf;


