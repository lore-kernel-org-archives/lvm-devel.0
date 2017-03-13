From: Bryn Reeves <bmr@sourceware.org>
Date: Mon, 13 Mar 2017 07:49:39 -0400
Subject: master - dmfilemapd: ensure path argument is absolute
Message-ID: <201703131149.v2DBndYX031002@int-mx10.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=77a7ed065f09f5c9e3e50622de07717a5db2249a
Commit:        77a7ed065f09f5c9e3e50622de07717a5db2249a
Parent:        9b0aba5fe9e6b22b85d7f6ff9f8fdef09db61bce
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Mon Mar 13 11:44:05 2017 +0000
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Mon Mar 13 11:44:05 2017 +0000

dmfilemapd: ensure path argument is absolute

Require that the path argument to dmfilemapd be an absolute path
and document this in tool output, libdevmapper.h and dmfilemapd.8.

The check is also enforced by dm_stats_start_filemapd() to avoid
forking a new process with an invalid path argument.
---
 daemons/dmfilemapd/dmfilemapd.c |    8 +++++++-
 libdm/libdevmapper.h            |    4 ++++
 libdm/libdm-stats.c             |    5 +++++
 man/dmfilemapd.8.in             |   24 ++++++++++++------------
 4 files changed, 28 insertions(+), 13 deletions(-)

diff --git a/daemons/dmfilemapd/dmfilemapd.c b/daemons/dmfilemapd/dmfilemapd.c
index 4f20466..2cd875b 100644
--- a/daemons/dmfilemapd/dmfilemapd.c
+++ b/daemons/dmfilemapd/dmfilemapd.c
@@ -62,7 +62,7 @@ struct filemap_monitor {
 static int _foreground;
 static int _verbose;
 
-const char *const _usage = "dmfilemapd <fd> <group_id> <path> <mode> "
+const char *const _usage = "dmfilemapd <fd> <group_id> <abs_path> <mode> "
 			   "[<foreground>[<log_level>]]";
 
 /*
@@ -296,6 +296,12 @@ static int _parse_args(int argc, char **argv, struct filemap_monitor *fm)
 		_early_log("Path argument is required.");
 		return 0;
 	}
+
+	if (argv[0] != '/') {
+		_early_log("Path argument must specify an absolute path.");
+		return 0;
+	}
+
 	fm->path = dm_strdup(argv[0]);
 	if (!fm->path) {
 		_early_log("Could not allocate memory for path argument.");
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index 9e0a837..4bd32b4 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -1421,6 +1421,10 @@ dm_filemapd_mode_t dm_filemapd_mode_from_string(const char *mode_str);
  * detected, call dm_stats_update_regions_from_fd() to update the
  * mapped regions for the file.
  *
+ * The path provided to dm_stats_start_filemapd() must be an absolute
+ * path, and should reflect the path of 'fd' at the time that it was
+ * opened.
+ *
  * The mode parameter controls the behaviour of the daemon when the
  * file being monitored is unlinked or moved: see the comments for
  * dm_filemapd_mode_t for a full description and possible values.
diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index 5fc4938..559920e 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -4951,6 +4951,11 @@ int dm_stats_start_filemapd(int fd, uint64_t group_id, const char *path,
 		return 0;
 	}
 
+	if (path[0] != '/') {
+		log_error("Path argument must specify an absolute path.");
+		return 0;
+	}
+
 	if (mode > DM_FILEMAPD_FOLLOW_PATH) {
 		log_error("Invalid dmfilemapd mode argument: "
 			  "Must be DM_FILEMAPD_FOLLOW_INODE or "
diff --git a/man/dmfilemapd.8.in b/man/dmfilemapd.8.in
index 37c76c7..8e19e4b 100644
--- a/man/dmfilemapd.8.in
+++ b/man/dmfilemapd.8.in
@@ -8,7 +8,7 @@
 .  RB [ group_id ]
 ..
 .de OPT_PATH
-.  RB [ path ]
+.  RB [ abs_path ]
 ..
 .
 .de OPT_MODE
@@ -73,12 +73,12 @@ should update. The group must exist and it should correspond to
 a set of regions created by a previous filemap operation.
 .
 .HP
-.BR path
+.BR abs_path
 .br
-The path to the file being monitored, at the time that it was
-opened. The use of \fBpath\fP by the daemon differs, depending
-on the filemap following mode in use; see \fBMODES\fP and the
-\fBmode\fP option for more information.
+The absolute path to the file being monitored, at the time that
+it was opened. The use of \fBpath\fP by the daemon differs,
+depending on the filemap following mode in use; see \fBMODES\fP
+and the \fBmode\fP option for more information.
 
 .br
 .HP
@@ -167,16 +167,16 @@ manually for debugging or testing purposes.
 Start the daemon in the background, in follow-path mode
 .br
 #
-.B dmfilemapd 3 0 vm.img path 0 0 3< vm.img
+.B dmfilemapd 3 0 /srv/images/vm.img path 0 0 3< /srv/images/vm.img
 .br
 .P
 Start the daemon in follow-inode mode, disable forking and enable
 verbose logging
 .br
 #
-.B dmfilemapd 3 0 vm.img inode 1 3 3< vm.img
+.B dmfilemapd 3 0 /var/tmp/data inode 1 3 3< /var/tmp/data
 .br
-Starting dmfilemapd with fd=3, group_id=0 mode=inode, path=vm.img
+Starting dmfilemapd with fd=3, group_id=0 mode=inode, path=/var/tmp/data
 .br
 dm version   [ opencount flush ]   [16384] (*1)
 .br
@@ -184,9 +184,9 @@ dm info   (253:0) [ opencount flush ]   [16384] (*1)
 .br
 dm message   (253:0) [ opencount flush ]  @stats_list dmstats [16384] (*1)
 .br
-Read alias 'vm.img' from aux_data
+Read alias 'data' from aux_data
 .br
-Found group_id 0: alias="vm.img"
+Found group_id 0: alias="data"
 .br
 dm_stats_walk_init: initialised flags to 4000000000000
 .br
@@ -194,7 +194,7 @@ starting stats walk with   GROUP
 .br
 exiting _filemap_monitor_get_events() with deleted=0, check=0
 .br
-waiting for FILEMAPD_WAIT
+Waiting for check interval
 .br
 .P
 .


