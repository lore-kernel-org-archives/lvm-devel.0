From: agk@sourceware.org <agk@sourceware.org>
Date: 9 Jul 2010 15:35:04 -0000
Subject: LVM2 ./WHATS_NEW daemons/cmirrord/clogd.c daem ...
Message-ID: <20100709153504.14637.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-07-09 15:34:48

Modified files:
	.              : WHATS_NEW 
	daemons/cmirrord: clogd.c cluster.c compat.c functions.c local.c 
	daemons/dmeventd: dmeventd.c 
	daemons/dmeventd/plugins/lvm2: dmeventd_lvm.c 
	daemons/dmeventd/plugins/mirror: dmeventd_mirror.c 
	daemons/dmeventd/plugins/snapshot: dmeventd_snapshot.c 
	lib/activate   : dev_manager.c 
	lib/cache      : lvmcache.c 
	lib/config     : config.c 
	lib/device     : dev-io.c dev-md.c 
	lib/display    : display.c 
	lib/error      : errseg.c 
	lib/filters    : filter-md.c filter-sysfs.c filter.c 
	lib/format1    : disk-rep.c disk-rep.h format1.c import-export.c 
	                 lvm1-label.c 
	lib/format_pool: disk_rep.c format_pool.c pool_label.c 
	lib/format_text: export.c format-text.c import_vsn1.c 
	                 text_label.c 
	lib/label      : label.c 
	lib/locking    : cluster_locking.c file_locking.c locking.c 
	                 no_locking.c 
	lib/metadata   : lv_manip.c metadata.c mirror.c 
	lib/mirror     : mirrored.c 
	lib/replicator : replicator.c 
	lib/report     : report.c 
	lib/snapshot   : snapshot.c 
	lib/striped    : striped.c 
	lib/unknown    : unknown.c 
	lib/zero       : zero.c 
	libdm          : libdevmapper.h libdm-common.c libdm-deptree.c 
	                 libdm-string.c 
	libdm/datastruct: hash.c 
	libdm/mm       : dbg_malloc.c 
	liblvm         : lvm_lv.c lvm_pv.c lvm_vg.c 
	tools          : dmsetup.c formats.c lvchange.c lvconvert.c 
	                 lvcreate.c lvm-static.c lvm.c lvm2cmd.c 
	                 lvmchange.c lvmcmdline.c lvmdiskscan.c 
	                 lvremove.c lvscan.c polldaemon.c pvchange.c 
	                 pvmove.c pvremove.c pvscan.c reporter.c 
	                 segtypes.c stub.h tools.h vgchange.c vgck.c 
	                 vgconvert.c vgdisplay.c vgexport.c vgimport.c 
	                 vgmerge.c vgmknodes.c vgreduce.c vgremove.c 
	                 vgscan.c 

Log message:
	Use __attribute__ consistently throughout.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1661&r2=1.1662
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/cmirrord/clogd.c.diff?cvsroot=lvm2&r1=1.10&r2=1.11
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/cmirrord/cluster.c.diff?cvsroot=lvm2&r1=1.14&r2=1.15
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/cmirrord/compat.c.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/cmirrord/functions.c.diff?cvsroot=lvm2&r1=1.20&r2=1.21
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/cmirrord/local.c.diff?cvsroot=lvm2&r1=1.8&r2=1.9
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/dmeventd.c.diff?cvsroot=lvm2&r1=1.62&r2=1.63
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/plugins/lvm2/dmeventd_lvm.c.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c.diff?cvsroot=lvm2&r1=1.35&r2=1.36
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c.diff?cvsroot=lvm2&r1=1.9&r2=1.10
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.195&r2=1.196
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.c.diff?cvsroot=lvm2&r1=1.92&r2=1.93
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/config.c.diff?cvsroot=lvm2&r1=1.79&r2=1.80
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/device/dev-io.c.diff?cvsroot=lvm2&r1=1.68&r2=1.69
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/device/dev-md.c.diff?cvsroot=lvm2&r1=1.19&r2=1.20
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/display/display.c.diff?cvsroot=lvm2&r1=1.110&r2=1.111
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/error/errseg.c.diff?cvsroot=lvm2&r1=1.20&r2=1.21
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/filters/filter-md.c.diff?cvsroot=lvm2&r1=1.8&r2=1.9
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/filters/filter-sysfs.c.diff?cvsroot=lvm2&r1=1.20&r2=1.21
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/filters/filter.c.diff?cvsroot=lvm2&r1=1.54&r2=1.55
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/disk-rep.c.diff?cvsroot=lvm2&r1=1.80&r2=1.81
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/disk-rep.h.diff?cvsroot=lvm2&r1=1.55&r2=1.56
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/format1.c.diff?cvsroot=lvm2&r1=1.120&r2=1.121
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/import-export.c.diff?cvsroot=lvm2&r1=1.113&r2=1.114
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/lvm1-label.c.diff?cvsroot=lvm2&r1=1.22&r2=1.23
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_pool/disk_rep.c.diff?cvsroot=lvm2&r1=1.16&r2=1.17
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_pool/format_pool.c.diff?cvsroot=lvm2&r1=1.31&r2=1.32
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_pool/pool_label.c.diff?cvsroot=lvm2&r1=1.9&r2=1.10
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/export.c.diff?cvsroot=lvm2&r1=1.76&r2=1.77
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.c.diff?cvsroot=lvm2&r1=1.140&r2=1.141
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/import_vsn1.c.diff?cvsroot=lvm2&r1=1.76&r2=1.77
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/text_label.c.diff?cvsroot=lvm2&r1=1.36&r2=1.37
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/label/label.c.diff?cvsroot=lvm2&r1=1.49&r2=1.50
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/cluster_locking.c.diff?cvsroot=lvm2&r1=1.44&r2=1.45
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/file_locking.c.diff?cvsroot=lvm2&r1=1.46&r2=1.47
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/locking.c.diff?cvsroot=lvm2&r1=1.84&r2=1.85
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/no_locking.c.diff?cvsroot=lvm2&r1=1.21&r2=1.22
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.230&r2=1.231
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.387&r2=1.388
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.123&r2=1.124
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/mirror/mirrored.c.diff?cvsroot=lvm2&r1=1.71&r2=1.72
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/replicator/replicator.c.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/report.c.diff?cvsroot=lvm2&r1=1.122&r2=1.123
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/snapshot/snapshot.c.diff?cvsroot=lvm2&r1=1.46&r2=1.47
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/striped/striped.c.diff?cvsroot=lvm2&r1=1.31&r2=1.32
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/unknown/unknown.c.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/zero/zero.c.diff?cvsroot=lvm2&r1=1.21&r2=1.22
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdevmapper.h.diff?cvsroot=lvm2&r1=1.119&r2=1.120
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-common.c.diff?cvsroot=lvm2&r1=1.96&r2=1.97
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-deptree.c.diff?cvsroot=lvm2&r1=1.84&r2=1.85
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-string.c.diff?cvsroot=lvm2&r1=1.11&r2=1.12
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/datastruct/hash.c.diff?cvsroot=lvm2&r1=1.10&r2=1.11
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/mm/dbg_malloc.c.diff?cvsroot=lvm2&r1=1.17&r2=1.18
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_lv.c.diff?cvsroot=lvm2&r1=1.22&r2=1.23
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_pv.c.diff?cvsroot=lvm2&r1=1.11&r2=1.12
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_vg.c.diff?cvsroot=lvm2&r1=1.41&r2=1.42
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/dmsetup.c.diff?cvsroot=lvm2&r1=1.141&r2=1.142
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/formats.c.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvchange.c.diff?cvsroot=lvm2&r1=1.121&r2=1.122
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.137&r2=1.138
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.222&r2=1.223
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvm-static.c.diff?cvsroot=lvm2&r1=1.8&r2=1.9
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvm.c.diff?cvsroot=lvm2&r1=1.112&r2=1.113
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvm2cmd.c.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmchange.c.diff?cvsroot=lvm2&r1=1.9&r2=1.10
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmcmdline.c.diff?cvsroot=lvm2&r1=1.126&r2=1.127
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmdiskscan.c.diff?cvsroot=lvm2&r1=1.20&r2=1.21
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvremove.c.diff?cvsroot=lvm2&r1=1.60&r2=1.61
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvscan.c.diff?cvsroot=lvm2&r1=1.40&r2=1.41
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/polldaemon.c.diff?cvsroot=lvm2&r1=1.33&r2=1.34
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvchange.c.diff?cvsroot=lvm2&r1=1.82&r2=1.83
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvmove.c.diff?cvsroot=lvm2&r1=1.77&r2=1.78
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvremove.c.diff?cvsroot=lvm2&r1=1.27&r2=1.28
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvscan.c.diff?cvsroot=lvm2&r1=1.51&r2=1.52
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/reporter.c.diff?cvsroot=lvm2&r1=1.61&r2=1.62
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/segtypes.c.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/stub.h.diff?cvsroot=lvm2&r1=1.46&r2=1.47
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/tools.h.diff?cvsroot=lvm2&r1=1.70&r2=1.71
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgchange.c.diff?cvsroot=lvm2&r1=1.108&r2=1.109
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgck.c.diff?cvsroot=lvm2&r1=1.25&r2=1.26
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgconvert.c.diff?cvsroot=lvm2&r1=1.42&r2=1.43
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgdisplay.c.diff?cvsroot=lvm2&r1=1.28&r2=1.29
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgexport.c.diff?cvsroot=lvm2&r1=1.23&r2=1.24
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgimport.c.diff?cvsroot=lvm2&r1=1.23&r2=1.24
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgmerge.c.diff?cvsroot=lvm2&r1=1.68&r2=1.69
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgmknodes.c.diff?cvsroot=lvm2&r1=1.8&r2=1.9
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgreduce.c.diff?cvsroot=lvm2&r1=1.102&r2=1.103
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgremove.c.diff?cvsroot=lvm2&r1=1.61&r2=1.62
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgscan.c.diff?cvsroot=lvm2&r1=1.37&r2=1.38

--- LVM2/WHATS_NEW	2010/07/09 15:26:41	1.1661
+++ LVM2/WHATS_NEW	2010/07/09 15:34:40	1.1662
@@ -1,5 +1,6 @@
 Version 2.02.71 -
 ===============================
+  Use __attribute__ consistently throughout.
   Fix redundant declarations and always compile with -Wredundant-decls.
   Fix possible hang when all mirror images of a mirrored log fail.
   Do not log backtrace in valid _lv_resume() code path.
--- LVM2/daemons/cmirrord/clogd.c	2010/03/29 14:05:17	1.10
+++ LVM2/daemons/cmirrord/clogd.c	2010/07/09 15:34:40	1.11
@@ -32,7 +32,7 @@
 static void init_all(void);
 static void cleanup_all(void);
 
-int main(int argc __attribute((unused)), char *argv[] __attribute((unused)))
+int main(int argc __attribute__((unused)), char *argv[] __attribute__((unused)))
 {
 	daemonize();
 
@@ -60,7 +60,7 @@
  * @sig: the signal
  *
  */
-static void parent_exit_handler(int sig __attribute((unused)))
+static void parent_exit_handler(int sig __attribute__((unused)))
 {
 	exit_now = 1;
 }
--- LVM2/daemons/cmirrord/cluster.c	2010/01/27 22:28:06	1.14
+++ LVM2/daemons/cmirrord/cluster.c	2010/07/09 15:34:40	1.15
@@ -215,7 +215,7 @@
 }
 
 static char rq_buffer[DM_ULOG_REQUEST_SIZE];
-static int handle_cluster_request(struct clog_cpg *entry __attribute((unused)),
+static int handle_cluster_request(struct clog_cpg *entry __attribute__((unused)),
 				  struct clog_request *rq, int server)
 {
 	int r = 0;
@@ -855,7 +855,7 @@
 	return r;
 }
 
-static int do_cluster_work(void *data __attribute((unused)))
+static int do_cluster_work(void *data __attribute__((unused)))
 {
 	int r = SA_AIS_OK;
 	struct clog_cpg *entry, *tmp;
@@ -927,8 +927,8 @@
 	return 0;
 }
 
-static void cpg_message_callback(cpg_handle_t handle, const struct cpg_name *gname __attribute((unused)),
-				 uint32_t nodeid, uint32_t pid __attribute((unused)),
+static void cpg_message_callback(cpg_handle_t handle, const struct cpg_name *gname __attribute__((unused)),
+				 uint32_t nodeid, uint32_t pid __attribute__((unused)),
 				 void *msg, size_t msg_len)
 {
 	int i;
@@ -1366,7 +1366,7 @@
 	}
 }
 
-static void cpg_config_callback(cpg_handle_t handle, const struct cpg_name *gname __attribute((unused)),
+static void cpg_config_callback(cpg_handle_t handle, const struct cpg_name *gname __attribute__((unused)),
 				const struct cpg_address *member_list,
 				size_t member_list_entries,
 				const struct cpg_address *left_list,
--- LVM2/daemons/cmirrord/compat.c	2010/01/18 21:07:24	1.4
+++ LVM2/daemons/cmirrord/compat.c	2010/07/09 15:34:41	1.5
@@ -21,7 +21,7 @@
  */
 #define COMPAT_OFFSET 256
 
-static void v5_data_endian_switch(struct clog_request *rq, int to_network __attribute((unused)))
+static void v5_data_endian_switch(struct clog_request *rq, int to_network __attribute__((unused)))
 {
 	int i, end;
 	int64_t *pi64;
--- LVM2/daemons/cmirrord/functions.c	2010/06/21 16:07:06	1.20
+++ LVM2/daemons/cmirrord/functions.c	2010/07/09 15:34:41	1.21
@@ -290,7 +290,7 @@
 }
 
 /* FIXME Rewrite this function taking advantage of the udev changes (where in use) to improve its efficiency! */
-static int find_disk_path(char *major_minor_str, char *path_rtn, int *unlink_path __attribute((unused)))
+static int find_disk_path(char *major_minor_str, char *path_rtn, int *unlink_path __attribute__((unused)))
 {
 	int r;
 	DIR *dp;
@@ -1369,7 +1369,7 @@
 	return 0;
 }
 
-static int core_status_info(struct log_c *lc __attribute((unused)), struct dm_ulog_request *rq)
+static int core_status_info(struct log_c *lc __attribute__((unused)), struct dm_ulog_request *rq)
 {
 	int r;
 	char *data = (char *)rq->data;
--- LVM2/daemons/cmirrord/local.c	2010/01/19 15:58:45	1.8
+++ LVM2/daemons/cmirrord/local.c	2010/07/09 15:34:41	1.9
@@ -214,7 +214,7 @@
  *
  * Returns: 0 on success, -EXXX on failure
  */
-static int do_local_work(void *data __attribute((unused)))
+static int do_local_work(void *data __attribute__((unused)))
 {
 	int r;
 	struct clog_request *rq;
--- LVM2/daemons/dmeventd/dmeventd.c	2010/05/14 14:56:39	1.62
+++ LVM2/daemons/dmeventd/dmeventd.c	2010/07/09 15:34:41	1.63
@@ -476,14 +476,14 @@
 	dm_lib_exit();
 }
 
-static void _exit_timeout(void *unused __attribute((unused)))
+static void _exit_timeout(void *unused __attribute__((unused)))
 {
 	_timeout_running = 0;
 	pthread_mutex_unlock(&_timeout_mutex);
 }
 
 /* Wake up monitor threads every so often. */
-static void *_timeout_thread(void *unused __attribute((unused)))
+static void *_timeout_thread(void *unused __attribute__((unused)))
 {
 	struct timespec timeout;
 	time_t curr_time;
@@ -1492,7 +1492,7 @@
 	_unlock_mutex();
 }
 
-static void _sig_alarm(int signum __attribute((unused)))
+static void _sig_alarm(int signum __attribute__((unused)))
 {
 	pthread_testcancel();
 }
@@ -1524,7 +1524,7 @@
  * Set the global variable which the process should
  * be watching to determine when to exit.
  */
-static void _exit_handler(int sig __attribute((unused)))
+static void _exit_handler(int sig __attribute__((unused)))
 {
 	/*
 	 * We exit when '_exit_now' is set.
--- LVM2/daemons/dmeventd/plugins/lvm2/dmeventd_lvm.c	2010/05/14 14:56:39	1.3
+++ LVM2/daemons/dmeventd/plugins/lvm2/dmeventd_lvm.c	2010/07/09 15:34:41	1.4
@@ -49,9 +49,9 @@
  * configurable and we don't have that option yet
  */
 static void _temporary_log_fn(int level,
-			      const char *file __attribute((unused)),
-			      int line __attribute((unused)),
-			      int dm_errno __attribute((unused)),
+			      const char *file __attribute__((unused)),
+			      int line __attribute__((unused)),
+			      int dm_errno __attribute__((unused)),
 			      const char *message)
 {
 	level &= ~(_LOG_STDERR | _LOG_ONCE);
--- LVM2/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c	2010/05/14 14:56:39	1.35
+++ LVM2/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c	2010/07/09 15:34:41	1.36
@@ -167,8 +167,8 @@
 }
 
 void process_event(struct dm_task *dmt,
-		   enum dm_event_mask event __attribute((unused)),
-		   void **unused __attribute((unused)))
+		   enum dm_event_mask event __attribute__((unused)),
+		   void **unused __attribute__((unused)))
 {
 	void *next = NULL;
 	uint64_t start, length;
@@ -224,10 +224,10 @@
 }
 
 int register_device(const char *device,
-		    const char *uuid __attribute((unused)),
-		    int major __attribute((unused)),
-		    int minor __attribute((unused)),
-		    void **unused __attribute((unused)))
+		    const char *uuid __attribute__((unused)),
+		    int major __attribute__((unused)),
+		    int minor __attribute__((unused)),
+		    void **unused __attribute__((unused)))
 {
 	int r = dmeventd_lvm2_init();
 	syslog(LOG_INFO, "Monitoring mirror device %s for events.", device);
@@ -235,10 +235,10 @@
 }
 
 int unregister_device(const char *device,
-		      const char *uuid __attribute((unused)),
-		      int major __attribute((unused)),
-		      int minor __attribute((unused)),
-		      void **unused __attribute((unused)))
+		      const char *uuid __attribute__((unused)),
+		      int major __attribute__((unused)),
+		      int minor __attribute__((unused)),
+		      void **unused __attribute__((unused)))
 {
 	syslog(LOG_INFO, "No longer monitoring mirror device %s for events.",
 	       device);
--- LVM2/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c	2010/05/11 08:32:22	1.9
+++ LVM2/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c	2010/07/09 15:34:41	1.10
@@ -70,7 +70,7 @@
 }
 
 void process_event(struct dm_task *dmt,
-		   enum dm_event_mask event __attribute((unused)),
+		   enum dm_event_mask event __attribute__((unused)),
 		   void **private)
 {
 	void *next = NULL;
@@ -113,9 +113,9 @@
 }
 
 int register_device(const char *device,
-		    const char *uuid __attribute((unused)),
-		    int major __attribute((unused)),
-		    int minor __attribute((unused)),
+		    const char *uuid __attribute__((unused)),
+		    int major __attribute__((unused)),
+		    int minor __attribute__((unused)),
 		    void **private)
 {
 	int *percent_warning = (int*)private;
@@ -128,10 +128,10 @@
 }
 
 int unregister_device(const char *device,
-		      const char *uuid __attribute((unused)),
-		      int major __attribute((unused)),
-		      int minor __attribute((unused)),
-		      void **unused __attribute((unused)))
+		      const char *uuid __attribute__((unused)),
+		      int major __attribute__((unused)),
+		      int minor __attribute__((unused)),
+		      void **unused __attribute__((unused)))
 {
 	syslog(LOG_INFO, "No longer monitoring snapshot %s\n",
 	       device);
--- LVM2/lib/activate/dev_manager.c	2010/05/24 15:32:20	1.195
+++ LVM2/lib/activate/dev_manager.c	2010/07/09 15:34:42	1.196
@@ -1752,7 +1752,7 @@
 {
 	struct dm_tree *dtree;
 	struct dm_tree_node *root;
-	char dlid[sizeof(UUID_PREFIX) + sizeof(struct id) - 1] __attribute((aligned(8)));
+	char dlid[sizeof(UUID_PREFIX) + sizeof(struct id) - 1] __attribute__((aligned(8)));
 	int r = 1;
 
 	if (!(dtree = dm_tree_create())) {
--- LVM2/lib/cache/lvmcache.c	2010/06/28 20:34:58	1.92
+++ LVM2/lib/cache/lvmcache.c	2010/07/09 15:34:42	1.93
@@ -90,7 +90,7 @@
  */
 static void _store_metadata(struct volume_group *vg, unsigned precommitted)
 {
-	char uuid[64] __attribute((aligned(8)));
+	char uuid[64] __attribute__((aligned(8)));
 	struct lvmcache_vginfo *vginfo;
 	int size;
 
@@ -275,7 +275,7 @@
 	return 1;
 }
 
-void lvmcache_lock_vgname(const char *vgname, int read_only __attribute((unused)))
+void lvmcache_lock_vgname(const char *vgname, int read_only __attribute__((unused)))
 {
 	if (!_lock_hash && !lvmcache_init()) {
 		log_error("Internal cache initialisation failed");
@@ -374,7 +374,7 @@
 	struct dm_list *devh, *tmp;
 	struct dm_list devs;
 	struct device_list *devl;
-	char vgid_found[ID_LEN + 1] __attribute((aligned(8)));
+	char vgid_found[ID_LEN + 1] __attribute__((aligned(8)));
 
 	if (!(vginfo = vginfo_from_vgname(vgname, vgid)))
 		return NULL;
@@ -411,7 +411,7 @@
 struct lvmcache_vginfo *vginfo_from_vgid(const char *vgid)
 {
 	struct lvmcache_vginfo *vginfo;
-	char id[ID_LEN + 1] __attribute((aligned(8)));
+	char id[ID_LEN + 1] __attribute__((aligned(8)));
 
 	if (!_vgid_hash || !vgid)
 		return NULL;
@@ -492,7 +492,7 @@
 struct lvmcache_info *info_from_pvid(const char *pvid, int valid_only)
 {
 	struct lvmcache_info *info;
-	char id[ID_LEN + 1] __attribute((aligned(8)));
+	char id[ID_LEN + 1] __attribute__((aligned(8)));
 
 	if (!_pvid_hash || !pvid)
 		return NULL;
@@ -930,8 +930,8 @@
 			  struct lvmcache_vginfo *primary_vginfo)
 {
 	struct lvmcache_vginfo *last_vginfo = primary_vginfo;
-	char uuid_primary[64] __attribute((aligned(8)));
-	char uuid_new[64] __attribute((aligned(8)));
+	char uuid_primary[64] __attribute__((aligned(8)));
+	char uuid_new[64] __attribute__((aligned(8)));
 	int use_new = 0;
 
 	/* Pre-existing VG takes precedence. Unexported VG takes precedence. */
@@ -1219,7 +1219,7 @@
 {
 	struct pv_list *pvl;
 	struct lvmcache_info *info;
-	char pvid_s[ID_LEN + 1] __attribute((aligned(8)));
+	char pvid_s[ID_LEN + 1] __attribute__((aligned(8)));
 
 	pvid_s[sizeof(pvid_s) - 1] = '\0';
 
@@ -1247,7 +1247,7 @@
 {
 	struct label *label;
 	struct lvmcache_info *existing, *info;
-	char pvid_s[ID_LEN + 1] __attribute((aligned(8)));
+	char pvid_s[ID_LEN + 1] __attribute__((aligned(8)));
 
 	if (!_vgname_hash && !lvmcache_init()) {
 		log_error("Internal cache initialisation failed");
--- LVM2/lib/config/config.c	2010/04/12 11:52:53	1.79
+++ LVM2/lib/config/config.c	2010/07/09 15:34:42	1.80
@@ -159,7 +159,7 @@
 	return 1;
 }
 
-struct config_tree *create_config_tree_from_string(struct cmd_context *cmd __attribute((unused)),
+struct config_tree *create_config_tree_from_string(struct cmd_context *cmd __attribute__((unused)),
 						   const char *config_settings)
 {
 	struct cs *c;
--- LVM2/lib/device/dev-io.c	2010/05/05 22:37:53	1.68
+++ LVM2/lib/device/dev-io.c	2010/07/09 15:34:42	1.69
@@ -678,7 +678,7 @@
 int dev_set(struct device *dev, uint64_t offset, size_t len, int value)
 {
 	size_t s;
-	char buffer[4096] __attribute((aligned(8)));
+	char buffer[4096] __attribute__((aligned(8)));
 
 	if (!dev_open(dev))
 		return_0;
--- LVM2/lib/device/dev-md.c	2009/08/19 15:34:43	1.19
+++ LVM2/lib/device/dev-md.c	2010/07/09 15:34:42	1.20
@@ -320,14 +320,14 @@
 
 #else
 
-int dev_is_md(struct device *dev __attribute((unused)),
-	      uint64_t *sb __attribute((unused)))
+int dev_is_md(struct device *dev __attribute__((unused)),
+	      uint64_t *sb __attribute__((unused)))
 {
 	return 0;
 }
 
-unsigned long dev_md_stripe_width(const char *sysfs_dir __attribute((unused)),
-				  struct device *dev  __attribute((unused)))
+unsigned long dev_md_stripe_width(const char *sysfs_dir __attribute__((unused)),
+				  struct device *dev  __attribute__((unused)))
 {
 	return 0UL;
 }
--- LVM2/lib/display/display.c	2010/06/28 20:32:21	1.110
+++ LVM2/lib/display/display.c	2010/07/09 15:34:42	1.111
@@ -307,7 +307,7 @@
 
 void pvdisplay_colons(const struct physical_volume *pv)
 {
-	char uuid[64] __attribute((aligned(8)));
+	char uuid[64] __attribute__((aligned(8)));
 
 	if (!pv)
 		return;
@@ -358,9 +358,9 @@
 /* FIXME Include label fields */
 void pvdisplay_full(const struct cmd_context *cmd,
 		    const struct physical_volume *pv,
-		    void *handle __attribute((unused)))
+		    void *handle __attribute__((unused)))
 {
-	char uuid[64] __attribute((aligned(8)));
+	char uuid[64] __attribute__((aligned(8)));
 	const char *size;
 
 	uint32_t pe_free;
@@ -423,12 +423,12 @@
 	log_print(" ");
 }
 
-int pvdisplay_short(const struct cmd_context *cmd __attribute((unused)),
-		    const struct volume_group *vg __attribute((unused)),
+int pvdisplay_short(const struct cmd_context *cmd __attribute__((unused)),
+		    const struct volume_group *vg __attribute__((unused)),
 		    const struct physical_volume *pv,
-		    void *handle __attribute((unused)))
+		    void *handle __attribute__((unused)))
 {
-	char uuid[64] __attribute((aligned(8)));
+	char uuid[64] __attribute__((aligned(8)));
 
 	if (!pv)
 		return 0;
@@ -469,11 +469,11 @@
 
 int lvdisplay_full(struct cmd_context *cmd,
 		   const struct logical_volume *lv,
-		   void *handle __attribute((unused)))
+		   void *handle __attribute__((unused)))
 {
 	struct lvinfo info;
 	int inkernel, snap_active = 0;
-	char uuid[64] __attribute((aligned(8)));
+	char uuid[64] __attribute__((aligned(8)));
 	struct lv_segment *snap_seg = NULL, *mirror_seg = NULL;
 	float snap_percent;	/* fused, fsize; */
 	percent_range_t percent_range;
@@ -646,7 +646,7 @@
 	return 1;
 }
 
-void vgdisplay_extents(const struct volume_group *vg __attribute((unused)))
+void vgdisplay_extents(const struct volume_group *vg __attribute__((unused)))
 {
 }
 
@@ -654,7 +654,7 @@
 {
 	uint32_t access_str;
 	uint32_t active_pvs;
-	char uuid[64] __attribute((aligned(8)));
+	char uuid[64] __attribute__((aligned(8)));
 
 	active_pvs = vg->pv_count - vg_missing_pv_count(vg);
 
@@ -728,7 +728,7 @@
 {
 	uint32_t active_pvs;
 	const char *access_str;
-	char uuid[64] __attribute((aligned(8)));
+	char uuid[64] __attribute__((aligned(8)));
 
 	active_pvs = vg->pv_count - vg_missing_pv_count(vg);
 
--- LVM2/lib/error/errseg.c	2009/02/28 20:04:24	1.20
+++ LVM2/lib/error/errseg.c	2010/07/09 15:34:43	1.21
@@ -40,20 +40,20 @@
 }
 
 #ifdef DEVMAPPER_SUPPORT
-static int _errseg_add_target_line(struct dev_manager *dm __attribute((unused)),
-				struct dm_pool *mem __attribute((unused)),
-				struct cmd_context *cmd __attribute((unused)),
-				void **target_state __attribute((unused)),
-				struct lv_segment *seg __attribute((unused)),
+static int _errseg_add_target_line(struct dev_manager *dm __attribute__((unused)),
+				struct dm_pool *mem __attribute__((unused)),
+				struct cmd_context *cmd __attribute__((unused)),
+				void **target_state __attribute__((unused)),
+				struct lv_segment *seg __attribute__((unused)),
 				struct dm_tree_node *node, uint64_t len,
-				uint32_t *pvmove_mirror_count __attribute((unused)))
+				uint32_t *pvmove_mirror_count __attribute__((unused)))
 {
 	return dm_tree_node_add_error_target(node, len);
 }
 
 static int _errseg_target_present(struct cmd_context *cmd,
-				  const struct lv_segment *seg __attribute((unused)),
-				  unsigned *attributes __attribute((unused)))
+				  const struct lv_segment *seg __attribute__((unused)),
+				  unsigned *attributes __attribute__((unused)))
 {
 	static int _errseg_checked = 0;
 	static int _errseg_present = 0;
@@ -70,7 +70,7 @@
 #endif
 
 static int _errseg_modules_needed(struct dm_pool *mem,
-				  const struct lv_segment *seg __attribute((unused)),
+				  const struct lv_segment *seg __attribute__((unused)),
 				  struct dm_list *modules)
 {
 	if (!str_list_add(mem, modules, "error")) {
--- LVM2/lib/filters/filter-md.c	2008/01/31 12:19:35	1.8
+++ LVM2/lib/filters/filter-md.c	2010/07/09 15:34:43	1.9
@@ -19,7 +19,7 @@
 
 #ifdef linux
 
-static int _ignore_md(struct dev_filter *f __attribute((unused)),
+static int _ignore_md(struct dev_filter *f __attribute__((unused)),
 		      struct device *dev)
 {
 	int ret;
--- LVM2/lib/filters/filter-sysfs.c	2008/09/19 03:42:37	1.20
+++ LVM2/lib/filters/filter-sysfs.c	2010/07/09 15:34:43	1.21
@@ -326,7 +326,7 @@
 
 #else
 
-struct dev_filter *sysfs_filter_create(const char *sysfs_dir __attribute((unused)))
+struct dev_filter *sysfs_filter_create(const char *sysfs_dir __attribute__((unused)))
 {
 	return NULL;
 }
--- LVM2/lib/filters/filter.c	2010/07/02 02:09:57	1.54
+++ LVM2/lib/filters/filter.c	2010/07/09 15:34:43	1.55
@@ -121,7 +121,7 @@
 	{NULL, 0}
 };
 
-static int _passes_lvm_type_device_filter(struct dev_filter *f __attribute((unused)),
+static int _passes_lvm_type_device_filter(struct dev_filter *f __attribute__((unused)),
 					  struct device *dev)
 {
 	const char *name = dev_name(dev);
--- LVM2/lib/format1/disk-rep.c	2009/10/27 17:00:46	1.80
+++ LVM2/lib/format1/disk-rep.c	2010/07/09 15:34:44	1.81
@@ -247,7 +247,7 @@
 {
 	unsigned num_read = 0;
 	struct uuid_list *ul;
-	char buffer[NAME_LEN] __attribute((aligned(8)));
+	char buffer[NAME_LEN] __attribute__((aligned(8)));
 	uint64_t pos = data->pvd.pv_uuidlist_on_disk.base;
 	uint64_t end = pos + data->pvd.pv_uuidlist_on_disk.size;
 
@@ -650,7 +650,7 @@
 /*
  * assumes the device has been opened.
  */
-static int __write_all_pvd(const struct format_type *fmt __attribute((unused)),
+static int __write_all_pvd(const struct format_type *fmt __attribute__((unused)),
 			   struct disk_list *data)
 {
 	const char *pv_name = dev_name(data->dev);
--- LVM2/lib/format1/disk-rep.h	2010/04/06 14:04:20	1.55
+++ LVM2/lib/format1/disk-rep.h	2010/07/09 15:34:44	1.56
@@ -148,7 +148,7 @@
 
 struct uuid_list {
 	struct dm_list list;
-	char uuid[NAME_LEN] __attribute((aligned(8)));
+	char uuid[NAME_LEN] __attribute__((aligned(8)));
 };
 
 struct lvd_list {
@@ -161,11 +161,11 @@
 	struct dm_pool *mem;
 	struct device *dev;
 
-	struct pv_disk pvd __attribute((aligned(8)));
-	struct vg_disk vgd __attribute((aligned(8)));
-	struct dm_list uuids __attribute((aligned(8)));
-	struct dm_list lvds __attribute((aligned(8)));
-	struct pe_disk *extents __attribute((aligned(8)));
+	struct pv_disk pvd __attribute__((aligned(8)));
+	struct vg_disk vgd __attribute__((aligned(8)));
+	struct dm_list uuids __attribute__((aligned(8)));
+	struct dm_list lvds __attribute__((aligned(8)));
+	struct pe_disk *extents __attribute__((aligned(8)));
 };
 
 /*
--- LVM2/lib/format1/format1.c	2010/07/08 18:24:29	1.120
+++ LVM2/lib/format1/format1.c	2010/07/09 15:34:44	1.121
@@ -163,7 +163,7 @@
 
 static struct volume_group *_format1_vg_read(struct format_instance *fid,
 				     const char *vg_name,
-				     struct metadata_area *mda __attribute((unused)))
+				     struct metadata_area *mda __attribute__((unused)))
 {
 	struct dm_pool *mem = dm_pool_create("lvm1 vg_read", VG_MEMPOOL_CHUNK);
 	struct dm_list pvs;
@@ -241,7 +241,7 @@
 }
 
 static int _format1_vg_write(struct format_instance *fid, struct volume_group *vg,
-		     struct metadata_area *mda __attribute((unused)))
+		     struct metadata_area *mda __attribute__((unused)))
 {
 	struct dm_pool *mem = dm_pool_create("lvm1 vg_write", VG_MEMPOOL_CHUNK);
 	struct dm_list pvds;
@@ -262,8 +262,8 @@
 }
 
 static int _format1_pv_read(const struct format_type *fmt, const char *pv_name,
-		    struct physical_volume *pv, struct dm_list *mdas __attribute((unused)),
-		    int scan_label_only __attribute((unused)))
+		    struct physical_volume *pv, struct dm_list *mdas __attribute__((unused)),
+		    int scan_label_only __attribute__((unused)))
 {
 	struct dm_pool *mem = dm_pool_create("lvm1 pv_read", 1024);
 	struct disk_list *dl;
@@ -296,13 +296,13 @@
 static int _format1_pv_setup(const struct format_type *fmt,
 			     uint64_t pe_start, uint32_t extent_count,
 			     uint32_t extent_size,
-			     unsigned long data_alignment __attribute((unused)),
-			     unsigned long data_alignment_offset __attribute((unused)),
-			     int pvmetadatacopies __attribute((unused)),
-			     uint64_t pvmetadatasize __attribute((unused)),
-			     unsigned metadataignore __attribute((unused)),
-			     struct dm_list *mdas __attribute((unused)),
-			     struct physical_volume *pv, struct volume_group *vg __attribute((unused)))
+			     unsigned long data_alignment __attribute__((unused)),
+			     unsigned long data_alignment_offset __attribute__((unused)),
+			     int pvmetadatacopies __attribute__((unused)),
+			     uint64_t pvmetadatasize __attribute__((unused)),
+			     unsigned metadataignore __attribute__((unused)),
+			     struct dm_list *mdas __attribute__((unused)),
+			     struct physical_volume *pv, struct volume_group *vg __attribute__((unused)))
 {
 	if (pv->size > MAX_PV_SIZE)
 		pv->size--;
@@ -354,7 +354,7 @@
 }
 
 static int _format1_pv_write(const struct format_type *fmt, struct physical_volume *pv,
-		     struct dm_list *mdas __attribute((unused)), int64_t sector __attribute((unused)))
+		     struct dm_list *mdas __attribute__((unused)), int64_t sector __attribute__((unused)))
 {
 	struct dm_pool *mem;
 	struct disk_list *dl;
@@ -439,7 +439,7 @@
 	return 1;
 }
 
-static int _format1_segtype_supported(struct format_instance *fid __attribute((unused)),
+static int _format1_segtype_supported(struct format_instance *fid __attribute__((unused)),
 				      const struct segment_type *segtype)
 {
 	if (!(segtype->flags & SEG_FORMAT1_SUPPORT))
@@ -454,9 +454,9 @@
 };
 
 static struct format_instance *_format1_create_instance(const struct format_type *fmt,
-						const char *vgname __attribute((unused)),
-						const char *vgid __attribute((unused)),
-						void *private __attribute((unused)))
+						const char *vgname __attribute__((unused)),
+						const char *vgid __attribute__((unused)),
+						void *private __attribute__((unused)))
 {
 	struct format_instance *fid;
 	struct metadata_area *mda;
@@ -482,7 +482,7 @@
 	return fid;
 }
 
-static void _format1_destroy_instance(struct format_instance *fid __attribute((unused)))
+static void _format1_destroy_instance(struct format_instance *fid __attribute__((unused)))
 {
 }
 
--- LVM2/lib/format1/import-export.c	2010/04/06 14:04:54	1.113
+++ LVM2/lib/format1/import-export.c	2010/07/09 15:34:44	1.114
@@ -137,7 +137,7 @@
 	return 1;
 }
 
-int export_pv(struct cmd_context *cmd, struct dm_pool *mem __attribute((unused)),
+int export_pv(struct cmd_context *cmd, struct dm_pool *mem __attribute__((unused)),
 	      struct volume_group *vg,
 	      struct pv_disk *pvd, struct physical_volume *pv)
 {
@@ -552,7 +552,7 @@
 /*
  * FIXME: More inefficient code.
  */
-int import_snapshots(struct dm_pool *mem __attribute((unused)), struct volume_group *vg,
+int import_snapshots(struct dm_pool *mem __attribute__((unused)), struct volume_group *vg,
 		     struct dm_list *pvds)
 {
 	struct logical_volume *lvs[MAX_LV];
@@ -641,7 +641,7 @@
  * This calculates the nasty pv_number field
  * used by LVM1.
  */
-void export_numbers(struct dm_list *pvds, struct volume_group *vg __attribute((unused)))
+void export_numbers(struct dm_list *pvds, struct volume_group *vg __attribute__((unused)))
 {
 	struct disk_list *dl;
 	int pv_num = 1;
--- LVM2/lib/format1/lvm1-label.c	2009/12/11 13:16:38	1.22
+++ LVM2/lib/format1/lvm1-label.c	2010/07/09 15:34:44	1.23
@@ -30,7 +30,7 @@
 		  op);
 }
 
-static int _lvm1_can_handle(struct labeller *l __attribute((unused)), void *buf, uint64_t sector)
+static int _lvm1_can_handle(struct labeller *l __attribute__((unused)), void *buf, uint64_t sector)
 {
 	struct pv_disk *pvd = (struct pv_disk *) buf;
 	uint32_t version;
@@ -48,7 +48,7 @@
 	return 0;
 }
 
-static int _lvm1_write(struct label *label __attribute((unused)), void *buf __attribute((unused)))
+static int _lvm1_write(struct label *label __attribute__((unused)), void *buf __attribute__((unused)))
 {
 	_not_supported("write");
 	return 0;
@@ -87,14 +87,14 @@
 	return 1;
 }
 
-static int _lvm1_initialise_label(struct labeller *l __attribute((unused)), struct label *label)
+static int _lvm1_initialise_label(struct labeller *l __attribute__((unused)), struct label *label)
 {
 	strcpy(label->type, "LVM1");
 
 	return 1;
 }
 
-static void _lvm1_destroy_label(struct labeller *l __attribute((unused)), struct label *label __attribute((unused)))
+static void _lvm1_destroy_label(struct labeller *l __attribute__((unused)), struct label *label __attribute__((unused)))
 {
 }
 
--- LVM2/lib/format_pool/disk_rep.c	2009/10/27 17:00:46	1.16
+++ LVM2/lib/format_pool/disk_rep.c	2010/07/09 15:34:44	1.17
@@ -34,10 +34,10 @@
 #define CPOUT_64(x, y) {(y) = xlate64_be((x));}
 
 static int __read_pool_disk(const struct format_type *fmt, struct device *dev,
-			    struct dm_pool *mem __attribute((unused)), struct pool_list *pl,
-			    const char *vg_name __attribute((unused)))
+			    struct dm_pool *mem __attribute__((unused)), struct pool_list *pl,
+			    const char *vg_name __attribute__((unused)))
 {
-	char buf[512] __attribute((aligned(8)));
+	char buf[512] __attribute__((aligned(8)));
 
 	/* FIXME: Need to check the cache here first */
 	if (!dev_read(dev, UINT64_C(0), 512, buf)) {
@@ -58,7 +58,7 @@
 
 	dm_list_iterate_items(pl, head) {
 		if (id_equal(&data->pv_uuid, &pl->pv_uuid)) {
-			char uuid[ID_LEN + 7] __attribute((aligned(8)));
+			char uuid[ID_LEN + 7] __attribute__((aligned(8)));
 
 			id_write_format(&pl->pv_uuid, uuid, ID_LEN + 7);
 
@@ -84,7 +84,7 @@
 	struct lvmcache_info *info;
 	struct id pvid;
 	struct id vgid;
-	char uuid[ID_LEN + 7] __attribute((aligned(8)));
+	char uuid[ID_LEN + 7] __attribute__((aligned(8)));
 	struct pool_disk *pd = &pl->pd;
 
 	pool_label_in(pd, buf);
--- LVM2/lib/format_pool/format_pool.c	2010/07/08 18:24:29	1.31
+++ LVM2/lib/format_pool/format_pool.c	2010/07/09 15:34:44	1.32
@@ -158,7 +158,7 @@
 
 static struct volume_group *_pool_vg_read(struct format_instance *fid,
 				     const char *vg_name,
-				     struct metadata_area *mda __attribute((unused)))
+				     struct metadata_area *mda __attribute__((unused)))
 {
 	struct dm_pool *mem = dm_pool_create("pool vg_read", VG_MEMPOOL_CHUNK);
 	struct dm_list pds;
@@ -188,26 +188,26 @@
 	return NULL;
 }
 
-static int _pool_pv_setup(const struct format_type *fmt __attribute((unused)),
-			  uint64_t pe_start __attribute((unused)),
-			  uint32_t extent_count __attribute((unused)),
-			  uint32_t extent_size __attribute((unused)),
-			  unsigned long data_alignment __attribute((unused)),
-			  unsigned long data_alignment_offset __attribute((unused)),
-			  int pvmetadatacopies __attribute((unused)),
-			  uint64_t pvmetadatasize __attribute((unused)),
-			  unsigned metadataignore __attribute((unused)),
-			  struct dm_list *mdas __attribute((unused)),
-			  struct physical_volume *pv __attribute((unused)),
-			  struct volume_group *vg __attribute((unused)))
+static int _pool_pv_setup(const struct format_type *fmt __attribute__((unused)),
+			  uint64_t pe_start __attribute__((unused)),
+			  uint32_t extent_count __attribute__((unused)),
+			  uint32_t extent_size __attribute__((unused)),
+			  unsigned long data_alignment __attribute__((unused)),
+			  unsigned long data_alignment_offset __attribute__((unused)),
+			  int pvmetadatacopies __attribute__((unused)),
+			  uint64_t pvmetadatasize __attribute__((unused)),
+			  unsigned metadataignore __attribute__((unused)),
+			  struct dm_list *mdas __attribute__((unused)),
+			  struct physical_volume *pv __attribute__((unused)),
+			  struct volume_group *vg __attribute__((unused)))
 {
 	return 1;
 }
 
 static int _pool_pv_read(const struct format_type *fmt, const char *pv_name,
 			 struct physical_volume *pv,
-			 struct dm_list *mdas __attribute((unused)),
-			 int scan_label_only __attribute((unused)))
+			 struct dm_list *mdas __attribute__((unused)),
+			 int scan_label_only __attribute__((unused)))
 {
 	struct dm_pool *mem = dm_pool_create("pool pv_read", 1024);
 	struct pool_list *pl;
@@ -249,9 +249,9 @@
 /* *INDENT-ON* */
 
 static struct format_instance *_pool_create_instance(const struct format_type *fmt,
-						const char *vgname __attribute((unused)),
-						const char *vgid __attribute((unused)),
-						void *private __attribute((unused)))
+						const char *vgname __attribute__((unused)),
+						const char *vgid __attribute__((unused)),
+						void *private __attribute__((unused)))
 {
 	struct format_instance *fid;
 	struct metadata_area *mda;
@@ -282,7 +282,7 @@
 	return fid;
 }
 
-static void _pool_destroy_instance(struct format_instance *fid __attribute((unused)))
+static void _pool_destroy_instance(struct format_instance *fid __attribute__((unused)))
 {
 }
 
--- LVM2/lib/format_pool/pool_label.c	2009/12/11 13:16:38	1.9
+++ LVM2/lib/format_pool/pool_label.c	2010/07/09 15:34:44	1.10
@@ -29,7 +29,7 @@
 		  op);
 }
 
-static int _pool_can_handle(struct labeller *l __attribute((unused)), void *buf, uint64_t sector)
+static int _pool_can_handle(struct labeller *l __attribute__((unused)), void *buf, uint64_t sector)
 {
 
 	struct pool_disk pd;
@@ -50,7 +50,7 @@
 	return 0;
 }
 
-static int _pool_write(struct label *label __attribute((unused)), void *buf __attribute((unused)))
+static int _pool_write(struct label *label __attribute__((unused)), void *buf __attribute__((unused)))
 {
 	_pool_not_supported("write");
 	return 0;
@@ -64,14 +64,14 @@
 	return read_pool_label(&pl, l, dev, buf, label);
 }
 
-static int _pool_initialise_label(struct labeller *l __attribute((unused)), struct label *label)
+static int _pool_initialise_label(struct labeller *l __attribute__((unused)), struct label *label)
 {
 	strcpy(label->type, "POOL");
 
 	return 1;
 }
 
-static void _pool_destroy_label(struct labeller *l __attribute((unused)), struct label *label __attribute((unused)))
+static void _pool_destroy_label(struct labeller *l __attribute__((unused)), struct label *label __attribute__((unused)))
 {
 }
 
--- LVM2/lib/format_text/export.c	2010/06/28 20:37:10	1.76
+++ LVM2/lib/format_text/export.c	2010/07/09 15:34:44	1.77
@@ -183,7 +183,7 @@
 }
 
 static int _out_with_comment_raw(struct formatter *f,
-				 const char *comment __attribute((unused)),
+				 const char *comment __attribute__((unused)),
 				 const char *fmt, va_list ap)
 {
 	int n;
@@ -413,7 +413,7 @@
 
 static const char *_get_pv_name(struct formatter *f, struct physical_volume *pv)
 {
-	char uuid[64] __attribute((aligned(8)));
+	char uuid[64] __attribute__((aligned(8)));
 
 	if (!pv || !id_write_format(&pv->id, uuid, sizeof(uuid)))
 		return_NULL;
--- LVM2/lib/format_text/format-text.c	2010/07/08 18:24:30	1.140
+++ LVM2/lib/format_text/format-text.c	2010/07/09 15:34:44	1.141
@@ -80,7 +80,7 @@
  * NOTE: Currently there can be only one vg per text file.
  */
 
-static int _text_vg_setup(struct format_instance *fid __attribute((unused)),
+static int _text_vg_setup(struct format_instance *fid __attribute__((unused)),
 			  struct volume_group *vg)
 {
 	if (vg->extent_size & (vg->extent_size - 1)) {
@@ -108,7 +108,7 @@
 /*
  * Check if metadata area belongs to vg
  */
-static int _mda_in_vg_raw(struct format_instance *fid __attribute((unused)),
+static int _mda_in_vg_raw(struct format_instance *fid __attribute__((unused)),
 			     struct volume_group *vg, struct metadata_area *mda)
 {
 	struct mda_context *mdac = (struct mda_context *) mda->metadata_locn;
@@ -279,7 +279,7 @@
 
 
 
-static int _text_lv_setup(struct format_instance *fid __attribute((unused)),
+static int _text_lv_setup(struct format_instance *fid __attribute__((unused)),
 			  struct logical_volume *lv)
 {
 /******** FIXME Any LV size restriction?
@@ -396,7 +396,7 @@
 				       int *precommitted)
 {
 	size_t len;
-	char vgnamebuf[NAME_LEN + 2] __attribute((aligned(8)));
+	char vgnamebuf[NAME_LEN + 2] __attribute__((aligned(8)));
 	struct raw_locn *rlocn, *rlocn_precommitted;
 	struct lvmcache_info *info;
 
@@ -892,7 +892,7 @@
 	return vg;
 }
 
-static int _vg_write_file(struct format_instance *fid __attribute((unused)),
+static int _vg_write_file(struct format_instance *fid __attribute__((unused)),
 			  struct volume_group *vg, struct metadata_area *mda)
 {
 	struct text_context *tc = (struct text_context *) mda->metadata_locn;
@@ -958,7 +958,7 @@
 	return 1;
 }
 
-static int _vg_commit_file_backup(struct format_instance *fid __attribute((unused)),
+static int _vg_commit_file_backup(struct format_instance *fid __attribute__((unused)),
 				  struct volume_group *vg,
 				  struct metadata_area *mda)
 {
@@ -1025,8 +1025,8 @@
 	return 1;
 }
 
-static int _vg_remove_file(struct format_instance *fid __attribute((unused)),
-			   struct volume_group *vg __attribute((unused)),
+static int _vg_remove_file(struct format_instance *fid __attribute__((unused)),
+			   struct volume_group *vg __attribute__((unused)),
 			   struct metadata_area *mda)
 {
 	struct text_context *tc = (struct text_context *) mda->metadata_locn;
@@ -1105,8 +1105,8 @@
 	uint32_t wrap = 0;
 	const char *vgname = NULL;
 	unsigned int len = 0;
-	char buf[NAME_LEN + 1] __attribute((aligned(8)));
-	char uuid[64] __attribute((aligned(8)));
+	char buf[NAME_LEN + 1] __attribute__((aligned(8)));
+	char uuid[64] __attribute__((aligned(8)));
 	uint64_t buffer_size, current_usage;
 
 	if (mda_free_sectors)
@@ -1251,7 +1251,7 @@
 		      int pvmetadatacopies, uint64_t pvmetadatasize,
 		      unsigned metadataignore, struct dm_list *mdas,
 		      struct physical_volume *pv,
-		      struct volume_group *vg __attribute((unused)))
+		      struct volume_group *vg __attribute__((unused)))
 {
 	uint64_t mda_adjustment, disk_size, alignment, alignment_offset;
 	uint64_t start1, mda_size1;	/* First area - start of disk */
@@ -1407,7 +1407,7 @@
 	struct lvmcache_info *info;
 	struct mda_context *mdac;
 	struct metadata_area *mda;
-	char buf[MDA_HEADER_SIZE] __attribute((aligned(8)));
+	char buf[MDA_HEADER_SIZE] __attribute__((aligned(8)));
 	struct mda_header *mdah = (struct mda_header *) buf;
 	uint64_t adjustment;
 	struct data_area_list *da;
@@ -1689,7 +1689,7 @@
 	return 1;
 }
 
-static void _text_destroy_instance(struct format_instance *fid __attribute((unused)))
+static void _text_destroy_instance(struct format_instance *fid __attribute__((unused)))
 {
 }
 
@@ -2106,7 +2106,7 @@
 	}
 
 	if (!(dev_area.dev = device_from_pvid(cmd, &id, NULL))) {
-		char buffer[64] __attribute((aligned(8)));
+		char buffer[64] __attribute__((aligned(8)));
 
 		if (!id_write_format(&id, buffer, sizeof(buffer)))
 			log_error("Couldn't find device.");
--- LVM2/lib/format_text/import_vsn1.c	2010/06/28 20:37:10	1.76
+++ LVM2/lib/format_text/import_vsn1.c	2010/07/09 15:34:44	1.77
@@ -156,9 +156,9 @@
 
 static int _read_pv(struct format_instance *fid, struct dm_pool *mem,
 		    struct volume_group *vg, struct config_node *pvn,
-		    struct config_node *vgn __attribute((unused)),
+		    struct config_node *vgn __attribute__((unused)),
 		    struct dm_hash_table *pv_hash,
-		    struct dm_hash_table *lv_hash __attribute((unused)),
+		    struct dm_hash_table *lv_hash __attribute__((unused)),
 		    unsigned *scan_done_once,
 		    unsigned report_missing_devices)
 {
@@ -194,7 +194,7 @@
 	 * Convert the uuid into a device.
 	 */
 	if (!(pv->dev = device_from_pvid(fid->fmt->cmd, &pv->id, scan_done_once))) {
-		char buffer[64] __attribute((aligned(8)));
+		char buffer[64] __attribute__((aligned(8)));
 
 		if (!id_write_format(&pv->id, buffer, sizeof(buffer)))
 			buffer[0] = '\0';
@@ -491,14 +491,14 @@
 	return 1;
 }
 
-static int _read_lvnames(struct format_instance *fid __attribute((unused)),
+static int _read_lvnames(struct format_instance *fid __attribute__((unused)),
 			 struct dm_pool *mem,
 			 struct volume_group *vg, struct config_node *lvn,
-			 struct config_node *vgn __attribute((unused)),
-			 struct dm_hash_table *pv_hash __attribute((unused)),
+			 struct config_node *vgn __attribute__((unused)),
+			 struct dm_hash_table *pv_hash __attribute__((unused)),
 			 struct dm_hash_table *lv_hash,
-			 unsigned *scan_done_once __attribute((unused)),
-			 unsigned report_missing_devices __attribute((unused)))
+			 unsigned *scan_done_once __attribute__((unused)),
+			 unsigned report_missing_devices __attribute__((unused)))
 {
 	struct logical_volume *lv;
 	struct config_node *cn;
@@ -563,14 +563,14 @@
 	return link_lv_to_vg(vg, lv);
 }
 
-static int _read_lvsegs(struct format_instance *fid __attribute((unused)),
+static int _read_lvsegs(struct format_instance *fid __attribute__((unused)),
 			struct dm_pool *mem,
 			struct volume_group *vg, struct config_node *lvn,
-			struct config_node *vgn __attribute((unused)),
+			struct config_node *vgn __attribute__((unused)),
 			struct dm_hash_table *pv_hash,
 			struct dm_hash_table *lv_hash,
-			unsigned *scan_done_once __attribute((unused)),
-			unsigned report_missing_devices __attribute((unused)))
+			unsigned *scan_done_once __attribute__((unused)),
+			unsigned report_missing_devices __attribute__((unused)))
 {
 	struct logical_volume *lv;
 
--- LVM2/lib/format_text/text_label.c	2010/06/30 19:28:35	1.36
+++ LVM2/lib/format_text/text_label.c	2010/07/09 15:34:44	1.37
@@ -23,9 +23,9 @@
 #include <sys/stat.h>
 #include <fcntl.h>
 
-static int _text_can_handle(struct labeller *l __attribute((unused)),
+static int _text_can_handle(struct labeller *l __attribute__((unused)),
 			    void *buf,
-			    uint64_t sector __attribute((unused)))
+			    uint64_t sector __attribute__((unused)))
 {
 	struct label_header *lh = (struct label_header *) buf;
 
@@ -44,7 +44,7 @@
 	struct metadata_area *mda;
 	struct mda_context *mdac;
 	struct data_area_list *da;
-	char buffer[64] __attribute((aligned(8)));
+	char buffer[64] __attribute__((aligned(8)));
 	int da1, mda1, mda2;
 
 	/* FIXME Move to where label is created */
@@ -242,7 +242,7 @@
 	}
 }
 
-static int _text_initialise_label(struct labeller *l __attribute((unused)),
+static int _text_initialise_label(struct labeller *l __attribute__((unused)),
 				  struct label *label)
 {
 	strncpy(label->type, LVM2_LABEL, sizeof(label->type));
@@ -343,7 +343,7 @@
 	return 1;
 }
 
-static void _text_destroy_label(struct labeller *l __attribute((unused)),
+static void _text_destroy_label(struct labeller *l __attribute__((unused)),
 				struct label *label)
 {
 	struct lvmcache_info *info = (struct lvmcache_info *) label->info;
--- LVM2/lib/label/label.c	2009/07/15 20:02:47	1.49
+++ LVM2/lib/label/label.c	2010/07/09 15:34:44	1.50
@@ -114,7 +114,7 @@
 	struct lvmcache_info *info;
 	uint64_t sector;
 	int found = 0;
-	char readbuf[LABEL_SCAN_SIZE] __attribute((aligned(8)));
+	char readbuf[LABEL_SCAN_SIZE] __attribute__((aligned(8)));
 
 	if (!dev_read(dev, scan_sector << SECTOR_SHIFT,
 		      LABEL_SCAN_SIZE, readbuf)) {
@@ -190,8 +190,8 @@
 /* FIXME Also wipe associated metadata area headers? */
 int label_remove(struct device *dev)
 {
-	char buf[LABEL_SIZE] __attribute((aligned(8)));
-	char readbuf[LABEL_SCAN_SIZE] __attribute((aligned(8)));
+	char buf[LABEL_SIZE] __attribute__((aligned(8)));
+	char readbuf[LABEL_SCAN_SIZE] __attribute__((aligned(8)));
 	int r = 1;
 	uint64_t sector;
 	int wipe;
@@ -260,7 +260,7 @@
 int label_read(struct device *dev, struct label **result,
 		uint64_t scan_sector)
 {
-	char buf[LABEL_SIZE] __attribute((aligned(8)));
+	char buf[LABEL_SIZE] __attribute__((aligned(8)));
 	struct labeller *l;
 	uint64_t sector;
 	struct lvmcache_info *info;
@@ -299,7 +299,7 @@
 /* Caller may need to use label_get_handler to create label struct! */
 int label_write(struct device *dev, struct label *label)
 {
-	char buf[LABEL_SIZE] __attribute((aligned(8)));
+	char buf[LABEL_SIZE] __attribute__((aligned(8)));
 	struct label_header *lh = (struct label_header *) buf;
 	int r = 1;
 
@@ -347,7 +347,7 @@
 int label_verify(struct device *dev)
 {
 	struct labeller *l;
-	char buf[LABEL_SIZE] __attribute((aligned(8)));
+	char buf[LABEL_SIZE] __attribute__((aligned(8)));
 	uint64_t sector;
 	struct lvmcache_info *info;
 	int r = 0;
--- LVM2/lib/locking/cluster_locking.c	2010/05/19 02:36:33	1.44
+++ LVM2/lib/locking/cluster_locking.c	2010/07/09 15:34:45	1.45
@@ -97,7 +97,7 @@
 /* Send a request and return the status */
 static int _send_request(char *inbuf, int inlen, char **retbuf)
 {
-	char outbuf[PIPE_BUF] __attribute((aligned(8)));
+	char outbuf[PIPE_BUF] __attribute__((aligned(8)));
 	struct clvm_header *outheader = (struct clvm_header *) outbuf;
 	int len;
 	int off;
@@ -199,7 +199,7 @@
 static int _cluster_request(char clvmd_cmd, const char *node, void *data, int len,
 			   lvm_response_t ** response, int *num)
 {
-	char outbuf[sizeof(struct clvm_header) + len + strlen(node) + 1] __attribute((aligned(8)));
+	char outbuf[sizeof(struct clvm_header) + len + strlen(node) + 1] __attribute__((aligned(8)));
 	char *inptr;
 	char *retbuf = NULL;
 	int status;
--- LVM2/lib/locking/file_locking.c	2010/05/19 02:36:33	1.46
+++ LVM2/lib/locking/file_locking.c	2010/07/09 15:34:45	1.47
@@ -112,7 +112,7 @@
 		log_sys_error("signal", "_remove_ctrl_c_handler");
 }
 
-static void _trap_ctrl_c(int sig __attribute((unused)))
+static void _trap_ctrl_c(int sig __attribute__((unused)))
 {
 	_remove_ctrl_c_handler();
 	log_error("CTRL-c detected: giving up waiting for lock");
--- LVM2/lib/locking/locking.c	2010/05/19 02:36:33	1.84
+++ LVM2/lib/locking/locking.c	2010/07/09 15:34:45	1.85
@@ -127,7 +127,7 @@
 	sigaction(SIGINT, &_oldhandler, NULL);
 }
 
-static void _block_signals(uint32_t flags __attribute((unused)))
+static void _block_signals(uint32_t flags __attribute__((unused)))
 {
 	sigset_t set;
 
@@ -396,7 +396,7 @@
 
 int lock_vol(struct cmd_context *cmd, const char *vol, uint32_t flags)
 {
-	char resource[258] __attribute((aligned(8)));
+	char resource[258] __attribute__((aligned(8)));
 	lv_operation_t lv_op;
 
 	switch (flags & (LCK_SCOPE_MASK | LCK_TYPE_MASK)) {
--- LVM2/lib/locking/no_locking.c	2010/01/22 09:45:29	1.21
+++ LVM2/lib/locking/no_locking.c	2010/07/09 15:34:45	1.22
@@ -79,7 +79,7 @@
 	return _no_lock_resource(cmd, resource, flags);
 }
 
-int init_no_locking(struct locking_type *locking, struct cmd_context *cmd __attribute((unused)))
+int init_no_locking(struct locking_type *locking, struct cmd_context *cmd __attribute__((unused)))
 {
 	locking->lock_resource = _no_lock_resource;
 	locking->reset_locking = _no_reset_locking;
@@ -89,7 +89,7 @@
 	return 1;
 }
 
-int init_readonly_locking(struct locking_type *locking, struct cmd_context *cmd __attribute((unused)))
+int init_readonly_locking(struct locking_type *locking, struct cmd_context *cmd __attribute__((unused)))
 {
 	locking->lock_resource = _readonly_lock_resource;
 	locking->reset_locking = _no_reset_locking;
--- LVM2/lib/metadata/lv_manip.c	2010/05/21 12:36:31	1.230
+++ LVM2/lib/metadata/lv_manip.c	2010/07/09 15:34:45	1.231
@@ -951,7 +951,7 @@
 	return 1;
 }
 
-static int _is_condition(struct cmd_context *cmd __attribute((unused)),
+static int _is_condition(struct cmd_context *cmd __attribute__((unused)),
 			 struct pv_segment *pvseg, uint32_t s,
 			 void *data)
 {
@@ -1743,8 +1743,8 @@
 	      const struct segment_type *segtype,
 	      uint32_t stripes, uint32_t stripe_size,
 	      uint32_t mirrors, uint32_t extents,
-	      struct physical_volume *mirrored_pv __attribute((unused)),
-	      uint32_t mirrored_pe __attribute((unused)),
+	      struct physical_volume *mirrored_pv __attribute__((unused)),
+	      uint32_t mirrored_pe __attribute__((unused)),
 	      uint64_t status, struct dm_list *allocatable_pvs,
 	      alloc_policy_t alloc)
 {
@@ -2072,7 +2072,7 @@
 }
 
 static int _add_pvs(struct cmd_context *cmd, struct pv_segment *peg,
-		    uint32_t s __attribute((unused)), void *data)
+		    uint32_t s __attribute__((unused)), void *data)
 {
 	struct seg_pvs *spvs = (struct seg_pvs *) data;
 	struct pv_list *pvl;
--- LVM2/lib/metadata/metadata.c	2010/07/08 18:24:30	1.387
+++ LVM2/lib/metadata/metadata.c	2010/07/09 15:34:45	1.388
@@ -172,7 +172,7 @@
 	struct pv_list *pvl;
 	struct format_instance *fid = vg->fid;
 	struct dm_pool *mem = vg->vgmem;
-	char uuid[64] __attribute((aligned(8)));
+	char uuid[64] __attribute__((aligned(8)));
 	struct dm_list *mdas;
 
 	log_verbose("Adding physical volume '%s' to volume group '%s'",
@@ -1491,7 +1491,7 @@
  * Separate metadata areas after splitting a VG.
  * Also accepts orphan VG as destination (for vgreduce).
  */
-int vg_split_mdas(struct cmd_context *cmd __attribute((unused)),
+int vg_split_mdas(struct cmd_context *cmd __attribute__((unused)),
 		  struct volume_group *vg_from, struct volume_group *vg_to)
 {
 	struct dm_list *mdas_from_in_use, *mdas_to_in_use;
@@ -1683,7 +1683,7 @@
 	struct device *dev;
 	struct dm_list mdas;
 	struct pvcreate_params default_pp;
-	char buffer[64] __attribute((aligned(8)));
+	char buffer[64] __attribute__((aligned(8)));
 
 	pvcreate_params_set_defaults(&default_pp);
 	if (!pp)
@@ -2122,7 +2122,7 @@
 /*
  * Determine whether two vgs are compatible for merging.
  */
-int vgs_are_compatible(struct cmd_context *cmd __attribute((unused)),
+int vgs_are_compatible(struct cmd_context *cmd __attribute__((unused)),
 		       struct volume_group *vg_from,
 		       struct volume_group *vg_to)
 {
@@ -2411,7 +2411,7 @@
 {
 	struct pv_list *pvl, *pvl2;
 	struct lv_list *lvl, *lvl2;
-	char uuid[64] __attribute((aligned(8)));
+	char uuid[64] __attribute__((aligned(8)));
 	int r = 1;
 	uint32_t hidden_lv_count = 0, lv_count = 0, lv_visible_count = 0;
 	uint32_t pv_count = 0;
@@ -2900,7 +2900,7 @@
 	struct dm_list *pvids;
 	struct pv_list *pvl, *pvl2;
 	struct dm_list all_pvs;
-	char uuid[64] __attribute((aligned(8)));
+	char uuid[64] __attribute__((aligned(8)));
 
 	if (is_orphan_vg(vgname)) {
 		if (use_precommitted) {
@@ -3638,7 +3638,7 @@
 	return _get_pvs(cmd, NULL);
 }
 
-int pv_write(struct cmd_context *cmd __attribute((unused)),
+int pv_write(struct cmd_context *cmd __attribute__((unused)),
 	     struct physical_volume *pv,
 	     struct dm_list *mdas, int64_t label_sector)
 {
--- LVM2/lib/metadata/mirror.c	2010/07/09 15:08:15	1.123
+++ LVM2/lib/metadata/mirror.c	2010/07/09 15:34:45	1.124
@@ -1064,8 +1064,8 @@
 	return 1;
 }
 
-static int _no_removable_images(struct logical_volume *lv __attribute((unused)),
-				void *baton __attribute((unused))) {
+static int _no_removable_images(struct logical_volume *lv __attribute__((unused)),
+				void *baton __attribute__((unused))) {
 	return 0;
 }
 
@@ -1110,7 +1110,7 @@
 	return 1;
 }
 
-static int get_mirror_fault_policy(struct cmd_context *cmd __attribute((unused)),
+static int get_mirror_fault_policy(struct cmd_context *cmd __attribute__((unused)),
 				   int log_policy)
 {
 	const char *policy;
@@ -1432,7 +1432,7 @@
 struct logical_volume *find_pvmove_lv_from_pvname(struct cmd_context *cmd,
 						  struct volume_group *vg,
 						  const char *name,
-						  const char *uuid __attribute((unused)),
+						  const char *uuid __attribute__((unused)),
 						  uint32_t lv_type)
 {
 	struct physical_volume *pv;
@@ -2000,7 +2000,7 @@
  * 'mirror' is the number of mirrors to be removed.
  * 'pvs' is removable pvs.
  */
-int lv_remove_mirrors(struct cmd_context *cmd __attribute((unused)),
+int lv_remove_mirrors(struct cmd_context *cmd __attribute__((unused)),
 		      struct logical_volume *lv,
 		      uint32_t mirrors, uint32_t log_count,
 		      int (*is_removable)(struct logical_volume *, void *),
--- LVM2/lib/mirror/mirrored.c	2010/05/24 23:11:35	1.71
+++ LVM2/lib/mirror/mirrored.c	2010/07/09 15:34:45	1.72
@@ -610,7 +610,7 @@
 
 /* FIXME This gets run while suspended and performs banned operations. */
 static int _target_set_events(struct lv_segment *seg,
-			      int evmask __attribute((unused)), int set)
+			      int evmask __attribute__((unused)), int set)
 {
 	char *dso, *uuid;
 	struct logical_volume *lv;
--- LVM2/lib/replicator/replicator.c	2010/05/21 13:17:21	1.1
+++ LVM2/lib/replicator/replicator.c	2010/07/09 15:34:45	1.2
@@ -221,7 +221,7 @@
 /* Import replicator segment */
 static int _replicator_text_import(struct lv_segment *seg,
 				   const struct config_node *sn,
-				   struct dm_hash_table *pv_hash __attribute((unused)))
+				   struct dm_hash_table *pv_hash __attribute__((unused)))
 {
 	const struct config_node *cn;
 	struct logical_volume *rlog_lv;
@@ -377,8 +377,8 @@
 
 /* Check for module presence */
 static int _replicator_target_present(struct cmd_context *cmd,
-				      const struct lv_segment *seg __attribute((unused)),
-				      unsigned *attributes __attribute((unused)))
+				      const struct lv_segment *seg __attribute__((unused)),
+				      unsigned *attributes __attribute__((unused)))
 {
 	static int _checked = 0;
 	static int _present = 0;
@@ -394,7 +394,7 @@
 #endif
 
 static int _replicator_modules_needed(struct dm_pool *mem,
-				      const struct lv_segment *seg __attribute((unused)),
+				      const struct lv_segment *seg __attribute__((unused)),
 				      struct dm_list *modules)
 {
 	if (!str_list_add(mem, modules, REPLICATOR_MODULE))
@@ -520,7 +520,7 @@
 /* Import replicator segment */
 static int _replicator_dev_text_import(struct lv_segment *seg,
 				       const struct config_node *sn,
-				       struct dm_hash_table *pv_hash __attribute((unused)))
+				       struct dm_hash_table *pv_hash __attribute__((unused)))
 {
 	const struct config_node *cn;
 	struct logical_volume *replicator;
@@ -721,8 +721,8 @@
 
 /* Check for module presence */
 static int _replicator_dev_target_present(struct cmd_context *cmd,
-					  const struct lv_segment *seg __attribute((unused)),
-					  unsigned *attributes __attribute((unused)))
+					  const struct lv_segment *seg __attribute__((unused)),
+					  unsigned *attributes __attribute__((unused)))
 {
 	static int _checked = 0;
 	static int _present = 0;
--- LVM2/lib/report/report.c	2010/06/28 20:40:01	1.122
+++ LVM2/lib/report/report.c	2010/07/09 15:34:46	1.123
@@ -56,16 +56,16 @@
 /*
  * Data-munging functions to prepare each data type for display and sorting
  */
-static int _string_disp(struct dm_report *rh, struct dm_pool *mem __attribute((unused)),
+static int _string_disp(struct dm_report *rh, struct dm_pool *mem __attribute__((unused)),
 			struct dm_report_field *field,
-			const void *data, void *private __attribute((unused)))
+			const void *data, void *private __attribute__((unused)))
 {
 	return dm_report_field_string(rh, field, (const char **) data);
 }
 
-static int _dev_name_disp(struct dm_report *rh, struct dm_pool *mem __attribute((unused)),
+static int _dev_name_disp(struct dm_report *rh, struct dm_pool *mem __attribute__((unused)),
 			  struct dm_report_field *field,
-			  const void *data, void *private __attribute((unused)))
+			  const void *data, void *private __attribute__((unused)))
 {
 	const char *name = dev_name(*(const struct device * const *) data);
 
@@ -147,23 +147,23 @@
 	return 1;
 }
 
-static int _devices_disp(struct dm_report *rh __attribute((unused)), struct dm_pool *mem,
+static int _devices_disp(struct dm_report *rh __attribute__((unused)), struct dm_pool *mem,
 			 struct dm_report_field *field,
-			 const void *data, void *private __attribute((unused)))
+			 const void *data, void *private __attribute__((unused)))
 {
 	return _format_pvsegs(mem, field, data, 0);
 }
 
-static int _peranges_disp(struct dm_report *rh __attribute((unused)), struct dm_pool *mem,
+static int _peranges_disp(struct dm_report *rh __attribute__((unused)), struct dm_pool *mem,
 			  struct dm_report_field *field,
-			  const void *data, void *private __attribute((unused)))
+			  const void *data, void *private __attribute__((unused)))
 {
 	return _format_pvsegs(mem, field, data, 1);
 }
 
-static int _tags_disp(struct dm_report *rh __attribute((unused)), struct dm_pool *mem,
+static int _tags_disp(struct dm_report *rh __attribute__((unused)), struct dm_pool *mem,
 		      struct dm_report_field *field,
-		      const void *data, void *private __attribute((unused)))
+		      const void *data, void *private __attribute__((unused)))
 {
 	const struct dm_list *tags = (const struct dm_list *) data;
 	struct str_list *sl;
@@ -238,9 +238,9 @@
 	return _string_disp(rh, mem, field, &pv->fmt->name, private);
 }
 
-static int _lvkmaj_disp(struct dm_report *rh, struct dm_pool *mem __attribute((unused)),
+static int _lvkmaj_disp(struct dm_report *rh, struct dm_pool *mem __attribute__((unused)),
 			struct dm_report_field *field,
-			const void *data, void *private __attribute((unused)))
+			const void *data, void *private __attribute__((unused)))
 {
 	const struct logical_volume *lv = (const struct logical_volume *) data;
 	struct lvinfo info;
@@ -251,9 +251,9 @@
 	return dm_report_field_int32(rh, field, &_minusone32);
 }
 
-static int _lvkmin_disp(struct dm_report *rh, struct dm_pool *mem __attribute((unused)),
+static int _lvkmin_disp(struct dm_report *rh, struct dm_pool *mem __attribute__((unused)),
 			struct dm_report_field *field,
-			const void *data, void *private __attribute((unused)))
+			const void *data, void *private __attribute__((unused)))
 {
 	const struct logical_volume *lv = (const struct logical_volume *) data;
 	struct lvinfo info;
@@ -280,9 +280,9 @@
 	return (percent_range == PERCENT_100) ? 1 : 0;
 }
 
-static int _lvstatus_disp(struct dm_report *rh __attribute((unused)), struct dm_pool *mem,
+static int _lvstatus_disp(struct dm_report *rh __attribute__((unused)), struct dm_pool *mem,
 			  struct dm_report_field *field,
-			  const void *data, void *private __attribute((unused)))
+			  const void *data, void *private __attribute__((unused)))
 {
 	const struct logical_volume *lv = (const struct logical_volume *) data;
 	struct lvinfo info;
@@ -386,9 +386,9 @@
 	return 1;
 }
 
-static int _pvstatus_disp(struct dm_report *rh __attribute((unused)), struct dm_pool *mem,
+static int _pvstatus_disp(struct dm_report *rh __attribute__((unused)), struct dm_pool *mem,
 			  struct dm_report_field *field,
-			  const void *data, void *private __attribute((unused)))
+			  const void *data, void *private __attribute__((unused)))
 {
 	const uint32_t status = *(const uint32_t *) data;
 	char *repstr;
@@ -412,9 +412,9 @@
 	return 1;
 }
 
-static int _vgstatus_disp(struct dm_report *rh __attribute((unused)), struct dm_pool *mem,
+static int _vgstatus_disp(struct dm_report *rh __attribute__((unused)), struct dm_pool *mem,
 			  struct dm_report_field *field,
-			  const void *data, void *private __attribute((unused)))
+			  const void *data, void *private __attribute__((unused)))
 {
 	const struct volume_group *vg = (const struct volume_group *) data;
 	char *repstr;
@@ -455,10 +455,10 @@
 	return 1;
 }
 
-static int _segtype_disp(struct dm_report *rh __attribute((unused)),
-			 struct dm_pool *mem __attribute((unused)),
+static int _segtype_disp(struct dm_report *rh __attribute__((unused)),
+			 struct dm_pool *mem __attribute__((unused)),
 			 struct dm_report_field *field,
-			 const void *data, void *private __attribute((unused)))
+			 const void *data, void *private __attribute__((unused)))
 {
 	const struct lv_segment *seg = (const struct lv_segment *) data;
 
@@ -471,9 +471,9 @@
 	return 1;
 }
 
-static int _loglv_disp(struct dm_report *rh, struct dm_pool *mem __attribute((unused)),
+static int _loglv_disp(struct dm_report *rh, struct dm_pool *mem __attribute__((unused)),
 		       struct dm_report_field *field,
-		       const void *data, void *private __attribute((unused)))
+		       const void *data, void *private __attribute__((unused)))
 {
 	const struct logical_volume *lv = (const struct logical_volume *) data;
 	struct lv_segment *seg;
@@ -491,7 +491,7 @@
 
 static int _lvname_disp(struct dm_report *rh, struct dm_pool *mem,
 			struct dm_report_field *field,
-			const void *data, void *private __attribute((unused)))
+			const void *data, void *private __attribute__((unused)))
 {
 	const struct logical_volume *lv = (const struct logical_volume *) data;
 	char *repstr, *lvname;
@@ -525,7 +525,7 @@
 
 static int _lvpath_disp(struct dm_report *rh, struct dm_pool *mem,
 			struct dm_report_field *field,
-			const void *data, void *private __attribute((unused)))
+			const void *data, void *private __attribute__((unused)))
 {
 	const struct logical_volume *lv = (const struct logical_volume *) data;
 	char *repstr;
@@ -560,9 +560,9 @@
 	return 1;
 }
 
-static int _movepv_disp(struct dm_report *rh, struct dm_pool *mem __attribute((unused)),
+static int _movepv_disp(struct dm_report *rh, struct dm_pool *mem __attribute__((unused)),
 			struct dm_report_field *field,
-			const void *data, void *private __attribute((unused)))
+			const void *data, void *private __attribute__((unused)))
 {
 	const struct logical_volume *lv = (const struct logical_volume *) data;
 	const char *name;
@@ -579,9 +579,9 @@
 	return 1;
 }
 
-static int _convertlv_disp(struct dm_report *rh, struct dm_pool *mem __attribute((unused)),
+static int _convertlv_disp(struct dm_report *rh, struct dm_pool *mem __attribute__((unused)),
 			   struct dm_report_field *field,
-			   const void *data, void *private __attribute((unused)))
+			   const void *data, void *private __attribute__((unused)))
 {
 	const struct logical_volume *lv = (const struct logical_volume *) data;
 	const char *name = NULL;
@@ -605,7 +605,7 @@
 	return 1;
 }
 
-static int _size32_disp(struct dm_report *rh __attribute((unused)), struct dm_pool *mem,
+static int _size32_disp(struct dm_report *rh __attribute__((unused)), struct dm_pool *mem,
 			struct dm_report_field *field,
 			const void *data, void *private)
 {
@@ -633,7 +633,7 @@
 	return 1;
 }
 
-static int _size64_disp(struct dm_report *rh __attribute((unused)),
+static int _size64_disp(struct dm_report *rh __attribute__((unused)),
 			struct dm_pool *mem,
 			struct dm_report_field *field,
 			const void *data, void *private)
@@ -663,7 +663,7 @@
 
 static int _lvreadahead_disp(struct dm_report *rh, struct dm_pool *mem,
 			     struct dm_report_field *field,
-			     const void *data, void *private __attribute((unused)))
+			     const void *data, void *private __attribute__((unused)))
 {
 	const struct logical_volume *lv = (const struct logical_volume *) data;
 
@@ -714,10 +714,10 @@
 }
 
 static int _segstartpe_disp(struct dm_report *rh,
-			    struct dm_pool *mem __attribute((unused)),
+			    struct dm_pool *mem __attribute__((unused)),
 			    struct dm_report_field *field,
 			    const void *data,
-			    void *private __attribute((unused)))
+			    void *private __attribute__((unused)))
 {
 	const struct lv_segment *seg = (const struct lv_segment *) data;
 
@@ -835,9 +835,9 @@
 	return _size64_disp(rh, mem, field, &freespace, private);
 }
 
-static int _uuid_disp(struct dm_report *rh __attribute((unused)), struct dm_pool *mem,
+static int _uuid_disp(struct dm_report *rh __attribute__((unused)), struct dm_pool *mem,
 		      struct dm_report_field *field,
-		      const void *data, void *private __attribute((unused)))
+		      const void *data, void *private __attribute__((unused)))
 {
 	char *repstr = NULL;
 
@@ -853,16 +853,16 @@
 	return 1;
 }
 
-static int _uint32_disp(struct dm_report *rh, struct dm_pool *mem __attribute((unused)),
+static int _uint32_disp(struct dm_report *rh, struct dm_pool *mem __attribute__((unused)),
 			struct dm_report_field *field,
-			const void *data, void *private __attribute((unused)))
+			const void *data, void *private __attribute__((unused)))
 {
 	return dm_report_field_uint32(rh, field, data);
 }
 
-static int _int32_disp(struct dm_report *rh, struct dm_pool *mem __attribute((unused)),
+static int _int32_disp(struct dm_report *rh, struct dm_pool *mem __attribute__((unused)),
 		       struct dm_report_field *field,
-		       const void *data, void *private __attribute((unused)))
+		       const void *data, void *private __attribute__((unused)))
 {
 	return dm_report_field_int32(rh, field, data);
 }
@@ -1062,9 +1062,9 @@
 	return _uint32_disp(rh, mem, field, &count, private);
 }
 
-static int _snpercent_disp(struct dm_report *rh __attribute((unused)), struct dm_pool *mem,
+static int _snpercent_disp(struct dm_report *rh __attribute__((unused)), struct dm_pool *mem,
 			   struct dm_report_field *field,
-			   const void *data, void *private __attribute((unused)))
+			   const void *data, void *private __attribute__((unused)))
 {
 	const struct logical_volume *lv = (const struct logical_volume *) data;
 	struct lvinfo info;
@@ -1122,10 +1122,10 @@
 	return 1;
 }
 
-static int _copypercent_disp(struct dm_report *rh __attribute((unused)),
+static int _copypercent_disp(struct dm_report *rh __attribute__((unused)),
 			     struct dm_pool *mem,
 			     struct dm_report_field *field,
-			     const void *data, void *private __attribute((unused)))
+			     const void *data, void *private __attribute__((unused)))
 {
 	struct logical_volume *lv = (struct logical_volume *) data;
 	float percent;
--- LVM2/lib/snapshot/snapshot.c	2010/04/14 13:01:43	1.46
+++ LVM2/lib/snapshot/snapshot.c	2010/07/09 15:34:46	1.47
@@ -32,7 +32,7 @@
 }
 
 static int _snap_text_import(struct lv_segment *seg, const struct config_node *sn,
-			struct dm_hash_table *pv_hash __attribute((unused)))
+			struct dm_hash_table *pv_hash __attribute__((unused)))
 {
 	uint32_t chunk_size;
 	const char *org_name, *cow_name;
@@ -103,11 +103,11 @@
 }
 
 #ifdef DEVMAPPER_SUPPORT
-static int _snap_target_percent(void **target_state __attribute((unused)),
+static int _snap_target_percent(void **target_state __attribute__((unused)),
 				percent_range_t *percent_range,
-				struct dm_pool *mem __attribute((unused)),
-				struct cmd_context *cmd __attribute((unused)),
-				struct lv_segment *seg __attribute((unused)),
+				struct dm_pool *mem __attribute__((unused)),
+				struct cmd_context *cmd __attribute__((unused)),
+				struct lv_segment *seg __attribute__((unused)),
 				char *params, uint64_t *total_numerator,
 				uint64_t *total_denominator)
 {
@@ -141,7 +141,7 @@
 
 static int _snap_target_present(struct cmd_context *cmd,
 				const struct lv_segment *seg,
-				unsigned *attributes __attribute((unused)))
+				unsigned *attributes __attribute__((unused)))
 {
 	static int _snap_checked = 0;
 	static int _snap_merge_checked = 0;
@@ -249,7 +249,7 @@
 
 /* FIXME This gets run while suspended and performs banned operations. */
 static int _target_set_events(struct lv_segment *seg,
-			      int events __attribute((unused)), int set)
+			      int events __attribute__((unused)), int set)
 {
 	char *dso, *uuid;
 	struct volume_group *vg = seg->lv->vg;
@@ -293,7 +293,7 @@
 #endif
 
 static int _snap_modules_needed(struct dm_pool *mem,
-				const struct lv_segment *seg __attribute((unused)),
+				const struct lv_segment *seg __attribute__((unused)),
 				struct dm_list *modules)
 {
 	if (!str_list_add(mem, modules, "snapshot")) {
--- LVM2/lib/striped/striped.c	2010/01/07 14:46:52	1.31
+++ LVM2/lib/striped/striped.c	2010/07/09 15:34:46	1.32
@@ -160,12 +160,12 @@
 
 #ifdef DEVMAPPER_SUPPORT
 static int _striped_add_target_line(struct dev_manager *dm,
-				struct dm_pool *mem __attribute((unused)),
-				struct cmd_context *cmd __attribute((unused)),
-				void **target_state __attribute((unused)),
+				struct dm_pool *mem __attribute__((unused)),
+				struct cmd_context *cmd __attribute__((unused)),
+				void **target_state __attribute__((unused)),
 				struct lv_segment *seg,
 				struct dm_tree_node *node, uint64_t len,
-				uint32_t *pvmove_mirror_count __attribute((unused)))
+				uint32_t *pvmove_mirror_count __attribute__((unused)))
 {
 	if (!seg->area_count) {
 		log_error(INTERNAL_ERROR "striped add_target_line called "
@@ -183,8 +183,8 @@
 }
 
 static int _striped_target_present(struct cmd_context *cmd,
-				   const struct lv_segment *seg __attribute((unused)),
-				   unsigned *attributes __attribute((unused)))
+				   const struct lv_segment *seg __attribute__((unused)),
+				   unsigned *attributes __attribute__((unused)))
 {
 	static int _striped_checked = 0;
 	static int _striped_present = 0;
--- LVM2/lib/unknown/unknown.c	2009/10/22 10:38:07	1.2
+++ LVM2/lib/unknown/unknown.c	2010/07/09 15:34:46	1.3
@@ -62,13 +62,13 @@
 }
 
 #ifdef DEVMAPPER_SUPPORT
-static int _unknown_add_target_line(struct dev_manager *dm __attribute((unused)),
-				struct dm_pool *mem __attribute((unused)),
-				struct cmd_context *cmd __attribute((unused)),
-				void **target_state __attribute((unused)),
-				struct lv_segment *seg __attribute((unused)),
+static int _unknown_add_target_line(struct dev_manager *dm __attribute__((unused)),
+				struct dm_pool *mem __attribute__((unused)),
+				struct cmd_context *cmd __attribute__((unused)),
+				void **target_state __attribute__((unused)),
+				struct lv_segment *seg __attribute__((unused)),
 				struct dm_tree_node *node, uint64_t len,
-				uint32_t *pvmove_mirror_count __attribute((unused)))
+				uint32_t *pvmove_mirror_count __attribute__((unused)))
 {
 	return dm_tree_node_add_error_target(node, len);
 }
--- LVM2/lib/zero/zero.c	2009/05/27 13:05:54	1.21
+++ LVM2/lib/zero/zero.c	2010/07/09 15:34:46	1.22
@@ -39,20 +39,20 @@
 }
 
 #ifdef DEVMAPPER_SUPPORT
-static int _zero_add_target_line(struct dev_manager *dm __attribute((unused)),
-				 struct dm_pool *mem __attribute((unused)),
-				 struct cmd_context *cmd __attribute((unused)),
-				 void **target_state __attribute((unused)),
-				 struct lv_segment *seg __attribute((unused)),
+static int _zero_add_target_line(struct dev_manager *dm __attribute__((unused)),
+				 struct dm_pool *mem __attribute__((unused)),
+				 struct cmd_context *cmd __attribute__((unused)),
+				 void **target_state __attribute__((unused)),
+				 struct lv_segment *seg __attribute__((unused)),
 				 struct dm_tree_node *node,uint64_t len,
-				 uint32_t *pvmove_mirror_count __attribute((unused)))
+				 uint32_t *pvmove_mirror_count __attribute__((unused)))
 {
 	return dm_tree_node_add_zero_target(node, len);
 }
 
 static int _zero_target_present(struct cmd_context *cmd,
-				const struct lv_segment *seg __attribute((unused)),
-				unsigned *attributes __attribute((unused)))
+				const struct lv_segment *seg __attribute__((unused)),
+				unsigned *attributes __attribute__((unused)))
 {
 	static int _zero_checked = 0;
 	static int _zero_present = 0;
@@ -67,7 +67,7 @@
 #endif
 
 static int _zero_modules_needed(struct dm_pool *mem,
-				const struct lv_segment *seg __attribute((unused)),
+				const struct lv_segment *seg __attribute__((unused)),
 				struct dm_list *modules)
 {
 	if (!str_list_add(mem, modules, "zero")) {
--- LVM2/libdm/libdevmapper.h	2010/07/05 22:22:43	1.119
+++ LVM2/libdm/libdevmapper.h	2010/07/09 15:34:47	1.120
@@ -244,7 +244,7 @@
  * Release library resources
  */
 void dm_lib_release(void);
-void dm_lib_exit(void) __attribute((destructor));
+void dm_lib_exit(void) __attribute__((destructor));
 
 /*
  * Use NULL for all devices.
--- LVM2/libdm/libdm-common.c	2010/05/27 15:02:56	1.96
+++ LVM2/libdm/libdm-common.c	2010/07/09 15:34:47	1.97
@@ -71,8 +71,8 @@
  */
 
 static void _default_log_line(int level,
-	    const char *file __attribute((unused)),
-	    int line __attribute((unused)), int dm_errno, 
+	    const char *file __attribute__((unused)),
+	    int line __attribute__((unused)), int dm_errno, 
 	    const char *f, va_list ap)
 {
 	int use_stderr = level & _LOG_STDERR;
@@ -94,8 +94,8 @@
 }
 
 static void _default_log_with_errno(int level,
-	    const char *file __attribute((unused)),
-	    int line __attribute((unused)), int dm_errno, 
+	    const char *file __attribute__((unused)),
+	    int line __attribute__((unused)), int dm_errno, 
 	    const char *f, ...)
 {
 	va_list ap;
--- LVM2/libdm/libdm-deptree.c	2010/07/02 21:16:51	1.84
+++ LVM2/libdm/libdm-deptree.c	2010/07/09 15:34:47	1.85
@@ -1435,7 +1435,7 @@
  *
  * Returns: 1 on success, 0 on failure
  */
-static int _emit_areas_line(struct dm_task *dmt __attribute((unused)),
+static int _emit_areas_line(struct dm_task *dmt __attribute__((unused)),
 			    struct load_segment *seg, char *params,
 			    size_t paramsize, int *pos)
 {
--- LVM2/libdm/libdm-string.c	2009/06/03 11:40:23	1.11
+++ LVM2/libdm/libdm-string.c	2010/07/09 15:34:47	1.12
@@ -38,7 +38,7 @@
  * Returns number of words.
  */
 int dm_split_words(char *buffer, unsigned max,
-		   unsigned ignore_comments __attribute((unused)),
+		   unsigned ignore_comments __attribute__((unused)),
 		   char **argv)
 {
 	unsigned arg;
--- LVM2/libdm/datastruct/hash.c	2009/11/03 00:45:35	1.10
+++ LVM2/libdm/datastruct/hash.c	2010/07/09 15:34:47	1.11
@@ -236,13 +236,13 @@
 	t->num_nodes = 0u;
 }
 
-char *dm_hash_get_key(struct dm_hash_table *t __attribute((unused)),
+char *dm_hash_get_key(struct dm_hash_table *t __attribute__((unused)),
 		      struct dm_hash_node *n)
 {
 	return n->key;
 }
 
-void *dm_hash_get_data(struct dm_hash_table *t __attribute((unused)),
+void *dm_hash_get_data(struct dm_hash_table *t __attribute__((unused)),
 		       struct dm_hash_node *n)
 {
 	return n->data;
--- LVM2/libdm/mm/dbg_malloc.c	2010/03/25 18:22:04	1.17
+++ LVM2/libdm/mm/dbg_malloc.c	2010/07/09 15:34:47	1.18
@@ -231,8 +231,8 @@
 	}
 }
 
-void *dm_malloc_aux(size_t s, const char *file __attribute((unused)),
-		    int line __attribute((unused)))
+void *dm_malloc_aux(size_t s, const char *file __attribute__((unused)),
+		    int line __attribute__((unused)))
 {
 	if (s > 50000000) {
 		log_error("Huge memory allocation (size %" PRIsize_t
--- LVM2/liblvm/lvm_lv.c	2010/04/19 15:22:24	1.22
+++ LVM2/liblvm/lvm_lv.c	2010/07/09 15:34:47	1.23
@@ -41,7 +41,7 @@
 
 const char *lvm_lv_get_uuid(const lv_t lv)
 {
-	char uuid[64] __attribute((aligned(8)));
+	char uuid[64] __attribute__((aligned(8)));
 
 	if (!id_write_format(&lv->lvid.id[1], uuid, sizeof(uuid))) {
 		log_error(INTERNAL_ERROR "unable to convert uuid");
--- LVM2/liblvm/lvm_pv.c	2010/04/19 15:22:24	1.11
+++ LVM2/liblvm/lvm_pv.c	2010/07/09 15:34:47	1.12
@@ -19,7 +19,7 @@
 
 const char *lvm_pv_get_uuid(const pv_t pv)
 {
-	char uuid[64] __attribute((aligned(8)));
+	char uuid[64] __attribute__((aligned(8)));
 
 	if (!id_write_format(&pv->id, uuid, sizeof(uuid))) {
 		log_error(INTERNAL_ERROR "Unable to convert uuid");
--- LVM2/liblvm/lvm_vg.c	2010/06/30 18:03:53	1.41
+++ LVM2/liblvm/lvm_vg.c	2010/07/09 15:34:47	1.42
@@ -332,7 +332,7 @@
 
 const char *lvm_vg_get_uuid(const vg_t vg)
 {
-	char uuid[64] __attribute((aligned(8)));
+	char uuid[64] __attribute__((aligned(8)));
 
 	if (!id_write_format(&vg->id, uuid, sizeof(uuid))) {
 		log_error(INTERNAL_ERROR "Unable to convert uuid");
--- LVM2/tools/dmsetup.c	2010/07/08 14:29:28	1.141
+++ LVM2/tools/dmsetup.c	2010/07/09 15:34:48	1.142
@@ -502,7 +502,7 @@
 	return 1;
 }
 
-static int _load(int argc, char **argv, void *data __attribute((unused)))
+static int _load(int argc, char **argv, void *data __attribute__((unused)))
 {
 	int r = 0;
 	struct dm_task *dmt;
@@ -562,7 +562,7 @@
 	return r;
 }
 
-static int _create(int argc, char **argv, void *data __attribute((unused)))
+static int _create(int argc, char **argv, void *data __attribute__((unused)))
 {
 	int r = 0;
 	struct dm_task *dmt;
@@ -644,7 +644,7 @@
 	return r;
 }
 
-static int _rename(int argc, char **argv, void *data __attribute((unused)))
+static int _rename(int argc, char **argv, void *data __attribute__((unused)))
 {
 	int r = 0;
 	struct dm_task *dmt;
@@ -691,7 +691,7 @@
 	return r;
 }
 
-static int _message(int argc, char **argv, void *data __attribute((unused)))
+static int _message(int argc, char **argv, void *data __attribute__((unused)))
 {
 	int r = 0, i;
 	size_t sz = 1;
@@ -758,7 +758,7 @@
 	return r;
 }
 
-static int _setgeometry(int argc, char **argv, void *data __attribute((unused)))
+static int _setgeometry(int argc, char **argv, void *data __attribute__((unused)))
 {
 	int r = 0;
 	struct dm_task *dmt;
@@ -797,7 +797,7 @@
 	return r;
 }
 
-static int _splitname(int argc, char **argv, void *data __attribute((unused)))
+static int _splitname(int argc, char **argv, void *data __attribute__((unused)))
 {
 	struct dmsetup_report_obj obj;
 	int r = 1;
@@ -831,7 +831,7 @@
 		return (uint32_t) value;
 }
 
-static int _udevflags(int args, char **argv, void *data __attribute((unused)))
+static int _udevflags(int args, char **argv, void *data __attribute__((unused)))
 {
 	uint32_t cookie;
 	uint16_t flags;
@@ -873,7 +873,7 @@
 	return 1;
 }
 
-static int _udevcomplete(int argc, char **argv, void *data __attribute((unused)))
+static int _udevcomplete(int argc, char **argv, void *data __attribute__((unused)))
 {
 	uint32_t cookie;
 
@@ -899,7 +899,7 @@
 static const char _cmd_not_supported[] = "Command not supported. Recompile with \"--enable-udev-sync\" to enable.";
 
 static int _udevcreatecookie(int argc, char **argv,
-				  void *data __attribute((unused)))
+				  void *data __attribute__((unused)))
 {
 	log_error(_cmd_not_supported);
 
@@ -907,21 +907,21 @@
 }
 
 static int _udevreleasecookie(int argc, char **argv,
-				void *data __attribute((unused)))
+				void *data __attribute__((unused)))
 {
 	log_error(_cmd_not_supported);
 
 	return 0;
 }
 
-static int _udevcomplete_all(int argc __attribute((unused)), char **argv __attribute((unused)), void *data __attribute((unused)))
+static int _udevcomplete_all(int argc __attribute__((unused)), char **argv __attribute__((unused)), void *data __attribute__((unused)))
 {
 	log_error(_cmd_not_supported);
 
 	return 0;
 }
 
-static int _udevcookies(int argc __attribute((unused)), char **argv __attribute((unused)), void *data __attribute((unused)))
+static int _udevcookies(int argc __attribute__((unused)), char **argv __attribute__((unused)), void *data __attribute__((unused)))
 {
 	log_error(_cmd_not_supported);
 
@@ -996,7 +996,7 @@
 }
 
 static int _udevcreatecookie(int argc, char **argv,
-				  void *data __attribute((unused)))
+				  void *data __attribute__((unused)))
 {
 	uint32_t cookie;
 
@@ -1010,7 +1010,7 @@
 }
 
 static int _udevreleasecookie(int argc, char **argv,
-				void *data __attribute((unused)))
+				void *data __attribute__((unused)))
 {
 	if (argv[1] && !(_udev_cookie = _get_cookie_value(argv[1])))
 		return 0;
@@ -1051,7 +1051,7 @@
 	return ret;
 }
 
-static int _udevcomplete_all(int argc __attribute((unused)), char **argv __attribute((unused)), void *data __attribute((unused)))
+static int _udevcomplete_all(int argc __attribute__((unused)), char **argv __attribute__((unused)), void *data __attribute__((unused)))
 {
 	int max_id, id, sid;
 	struct seminfo sinfo;
@@ -1100,7 +1100,7 @@
 	return 1;
 }
 
-static int _udevcookies(int argc __attribute((unused)), char **argv __attribute((unused)), void *data __attribute((unused)))
+static int _udevcookies(int argc __attribute__((unused)), char **argv __attribute__((unused)), void *data __attribute__((unused)))
 {
 	int max_id, id, sid;
 	struct seminfo sinfo;
@@ -1139,7 +1139,7 @@
 }
 #endif	/* UDEV_SYNC_SUPPORT */
 
-static int _version(int argc __attribute((unused)), char **argv __attribute((unused)), void *data __attribute((unused)))
+static int _version(int argc __attribute__((unused)), char **argv __attribute__((unused)), void *data __attribute__((unused)))
 {
 	char version[80];
 
@@ -1216,22 +1216,22 @@
 	return r;
 }
 
-static int _suspend(int argc, char **argv, void *data __attribute((unused)))
+static int _suspend(int argc, char **argv, void *data __attribute__((unused)))
 {
 	return _simple(DM_DEVICE_SUSPEND, argc > 1 ? argv[1] : NULL, 0, 1);
 }
 
-static int _resume(int argc, char **argv, void *data __attribute((unused)))
+static int _resume(int argc, char **argv, void *data __attribute__((unused)))
 {
 	return _simple(DM_DEVICE_RESUME, argc > 1 ? argv[1] : NULL, 0, 1);
 }
 
-static int _clear(int argc, char **argv, void *data __attribute((unused)))
+static int _clear(int argc, char **argv, void *data __attribute__((unused)))
 {
 	return _simple(DM_DEVICE_CLEAR, argc > 1 ? argv[1] : NULL, 0, 1);
 }
 
-static int _wait(int argc, char **argv, void *data __attribute((unused)))
+static int _wait(int argc, char **argv, void *data __attribute__((unused)))
 {
 	const char *name = NULL;
 
@@ -1325,7 +1325,7 @@
 	return size;
 }
 
-static int _error_device(int argc __attribute((unused)), char **argv __attribute((unused)), void *data)
+static int _error_device(int argc __attribute__((unused)), char **argv __attribute__((unused)), void *data)
 {
 	struct dm_names *names = (struct dm_names *) data;
 	struct dm_task *dmt;
@@ -1373,7 +1373,7 @@
 	return r;
 }
 
-static int _remove(int argc, char **argv, void *data __attribute((unused)))
+static int _remove(int argc, char **argv, void *data __attribute__((unused)))
 {
 	int r;
 
@@ -1383,14 +1383,14 @@
 	return _simple(DM_DEVICE_REMOVE, argc > 1 ? argv[1] : NULL, 0, 0);
 }
 
-static int _count_devices(int argc __attribute((unused)), char **argv __attribute((unused)), void *data __attribute((unused)))
+static int _count_devices(int argc __attribute__((unused)), char **argv __attribute__((unused)), void *data __attribute__((unused)))
 {
 	_num_devices++;
 
 	return 1;
 }
 
-static int _remove_all(int argc __attribute((unused)), char **argv __attribute((unused)), void *data __attribute((unused)))
+static int _remove_all(int argc __attribute__((unused)), char **argv __attribute__((unused)), void *data __attribute__((unused)))
 {
 	int r;
 
@@ -1428,7 +1428,7 @@
 		printf("%s\t(%u, %u)\n", name, info.major, info.minor);
 }
 
-static int _mknodes(int argc, char **argv, void *data __attribute((unused)))
+static int _mknodes(int argc, char **argv, void *data __attribute__((unused)))
 {
 	return dm_mknodes(argc > 1 ? argv[1] : NULL);
 }
@@ -1599,7 +1599,7 @@
 }
 
 /* Show target names and their version numbers */
-static int _targets(int argc __attribute((unused)), char **argv __attribute((unused)), void *data __attribute((unused)))
+static int _targets(int argc __attribute__((unused)), char **argv __attribute__((unused)), void *data __attribute__((unused)))
 {
 	int r = 0;
 	struct dm_task *dmt;
@@ -1739,7 +1739,7 @@
 	return r;
 }
 
-static int _display_name(int argc __attribute((unused)), char **argv __attribute((unused)), void *data)
+static int _display_name(int argc __attribute__((unused)), char **argv __attribute__((unused)), void *data)
 {
 	struct dm_names *names = (struct dm_names *) data;
 
@@ -1962,7 +1962,7 @@
 }
 
 static void _display_tree_node(struct dm_tree_node *node, unsigned depth,
-			       unsigned first_child __attribute((unused)),
+			       unsigned first_child __attribute__((unused)),
 			       unsigned last_child, unsigned has_children)
 {
 	int offset;
@@ -2054,7 +2054,7 @@
 	}
 }
 
-static int _add_dep(int argc __attribute((unused)), char **argv __attribute((unused)), void *data)
+static int _add_dep(int argc __attribute__((unused)), char **argv __attribute__((unused)), void *data)
 {
 	struct dm_names *names = (struct dm_names *) data;
 
@@ -2081,9 +2081,9 @@
 	return 1;
 }
 
-static int _display_tree(int argc __attribute((unused)),
-			 char **argv __attribute((unused)),
-			 void *data __attribute((unused)))
+static int _display_tree(int argc __attribute__((unused)),
+			 char **argv __attribute__((unused)),
+			 void *data __attribute__((unused)))
 {
 	if (!_build_whole_deptree())
 		return 0;
@@ -2100,9 +2100,9 @@
 /* dm specific display functions */
 
 static int _int32_disp(struct dm_report *rh,
-		       struct dm_pool *mem __attribute((unused)),
+		       struct dm_pool *mem __attribute__((unused)),
 		       struct dm_report_field *field, const void *data,
-		       void *private __attribute((unused)))
+		       void *private __attribute__((unused)))
 {
 	const int32_t value = *(const int32_t *)data;
 
@@ -2110,9 +2110,9 @@
 }
 
 static int _uint32_disp(struct dm_report *rh,
-			struct dm_pool *mem __attribute((unused)),
+			struct dm_pool *mem __attribute__((unused)),
 			struct dm_report_field *field, const void *data,
-			void *private __attribute((unused)))
+			void *private __attribute__((unused)))
 {
 	const uint32_t value = *(const int32_t *)data;
 
@@ -2120,9 +2120,9 @@
 }
 
 static int _dm_name_disp(struct dm_report *rh,
-			 struct dm_pool *mem __attribute((unused)),
+			 struct dm_pool *mem __attribute__((unused)),
 			 struct dm_report_field *field, const void *data,
-			 void *private __attribute((unused)))
+			 void *private __attribute__((unused)))
 {
 	const char *name = dm_task_get_name((const struct dm_task *) data);
 
@@ -2130,9 +2130,9 @@
 }
 
 static int _dm_uuid_disp(struct dm_report *rh,
-			 struct dm_pool *mem __attribute((unused)),
+			 struct dm_pool *mem __attribute__((unused)),
 			 struct dm_report_field *field,
-			 const void *data, void *private __attribute((unused)))
+			 const void *data, void *private __attribute__((unused)))
 {
 	const char *uuid = dm_task_get_uuid((const struct dm_task *) data);
 
@@ -2143,9 +2143,9 @@
 }
 
 static int _dm_read_ahead_disp(struct dm_report *rh,
-			       struct dm_pool *mem __attribute((unused)),
+			       struct dm_pool *mem __attribute__((unused)),
 			       struct dm_report_field *field, const void *data,
-			       void *private __attribute((unused)))
+			       void *private __attribute__((unused)))
 {
 	uint32_t value;
 
@@ -2156,9 +2156,9 @@
 }
 
 static int _dm_info_status_disp(struct dm_report *rh,
-				struct dm_pool *mem __attribute((unused)),
+				struct dm_pool *mem __attribute__((unused)),
 				struct dm_report_field *field, const void *data,
-				void *private __attribute((unused)))
+				void *private __attribute__((unused)))
 {
 	char buf[5];
 	const char *s = buf;
@@ -2174,10 +2174,10 @@
 }
 
 static int _dm_info_table_loaded_disp(struct dm_report *rh,
-				      struct dm_pool *mem __attribute((unused)),
+				      struct dm_pool *mem __attribute__((unused)),
 				      struct dm_report_field *field,
 				      const void *data,
-				      void *private __attribute((unused)))
+				      void *private __attribute__((unused)))
 {
 	const struct dm_info *info = data;
 
@@ -2198,10 +2198,10 @@
 }
 
 static int _dm_info_suspended_disp(struct dm_report *rh,
-				   struct dm_pool *mem __attribute((unused)),
+				   struct dm_pool *mem __attribute__((unused)),
 				   struct dm_report_field *field,
 				   const void *data,
-				   void *private __attribute((unused)))
+				   void *private __attribute__((unused)))
 {
 	const struct dm_info *info = data;
 
@@ -2214,10 +2214,10 @@
 }
 
 static int _dm_info_read_only_disp(struct dm_report *rh,
-				   struct dm_pool *mem __attribute((unused)),
+				   struct dm_pool *mem __attribute__((unused)),
 				   struct dm_report_field *field,
 				   const void *data,
-				   void *private __attribute((unused)))
+				   void *private __attribute__((unused)))
 {
 	const struct dm_info *info = data;
 
@@ -2431,35 +2431,35 @@
 }
 
 static int _dm_subsystem_disp(struct dm_report *rh,
-			       struct dm_pool *mem __attribute((unused)),
+			       struct dm_pool *mem __attribute__((unused)),
 			       struct dm_report_field *field, const void *data,
-			       void *private __attribute((unused)))
+			       void *private __attribute__((unused)))
 {
 	return dm_report_field_string(rh, field, (const char **) data);
 }
 
 static int _dm_vg_name_disp(struct dm_report *rh,
-			     struct dm_pool *mem __attribute((unused)),
+			     struct dm_pool *mem __attribute__((unused)),
 			     struct dm_report_field *field, const void *data,
-			     void *private __attribute((unused)))
+			     void *private __attribute__((unused)))
 {
 
 	return dm_report_field_string(rh, field, (const char **) data);
 }
 
 static int _dm_lv_name_disp(struct dm_report *rh,
-			     struct dm_pool *mem __attribute((unused)),
+			     struct dm_pool *mem __attribute__((unused)),
 			     struct dm_report_field *field, const void *data,
-			     void *private __attribute((unused)))
+			     void *private __attribute__((unused)))
 
 {
 	return dm_report_field_string(rh, field, (const char **) data);
 }
 
 static int _dm_lv_layer_name_disp(struct dm_report *rh,
-				   struct dm_pool *mem __attribute((unused)),
+				   struct dm_pool *mem __attribute__((unused)),
 				   struct dm_report_field *field, const void *data,
-				   void *private __attribute((unused)))
+				   void *private __attribute__((unused)))
 
 {
 	return dm_report_field_string(rh, field, (const char **) data);
@@ -2743,9 +2743,9 @@
 		     "[-o offset] [-f|loop_device] [file]\n\n");
 }
 
-static int _help(int argc __attribute((unused)),
-		 char **argv __attribute((unused)),
-		 void *data __attribute((unused)))
+static int _help(int argc __attribute__((unused)),
+		 char **argv __attribute__((unused)),
+		 void *data __attribute__((unused)))
 {
 	_usage(stderr);
 
@@ -2899,7 +2899,7 @@
  *  create a table for a mapped device using the loop target.
  */
 static int _loop_table(char *table, size_t tlen, char *file,
-		       char *dev __attribute((unused)), off_t off)
+		       char *dev __attribute__((unused)), off_t off)
 {
 	struct stat fbuf;
 	off_t size, sectors;
--- LVM2/tools/formats.c	2008/01/30 14:00:01	1.4
+++ LVM2/tools/formats.c	2010/07/09 15:34:48	1.5
@@ -15,8 +15,8 @@
 
 #include "tools.h"
 
-int formats(struct cmd_context *cmd, int argc __attribute((unused)),
-	    char **argv __attribute((unused)))
+int formats(struct cmd_context *cmd, int argc __attribute__((unused)),
+	    char **argv __attribute__((unused)))
 {
 	display_formats(cmd);
 
--- LVM2/tools/lvchange.c	2010/06/28 19:10:16	1.121
+++ LVM2/tools/lvchange.c	2010/07/09 15:34:48	1.122
@@ -515,7 +515,7 @@
 }
 
 static int lvchange_single(struct cmd_context *cmd, struct logical_volume *lv,
-			   void *handle __attribute((unused)))
+			   void *handle __attribute__((unused)))
 {
 	int doit = 0, docmds = 0;
 	int dmeventd_mode, archived = 0;
--- LVM2/tools/lvconvert.c	2010/07/06 17:02:03	1.137
+++ LVM2/tools/lvconvert.c	2010/07/09 15:34:48	1.138
@@ -326,7 +326,7 @@
 
 static struct volume_group *_get_lvconvert_vg(struct cmd_context *cmd,
 					      const char *name,
-					      const char *uuid __attribute((unused)))
+					      const char *uuid __attribute__((unused)))
 {
 	dev_close_all();
 
@@ -338,11 +338,11 @@
 				  NULL, 0);
 }
 
-static struct logical_volume *_get_lvconvert_lv(struct cmd_context *cmd __attribute((unused)),
+static struct logical_volume *_get_lvconvert_lv(struct cmd_context *cmd __attribute__((unused)),
 						struct volume_group *vg,
 						const char *name,
 						const char *uuid,
-						uint32_t lv_type __attribute((unused)))
+						uint32_t lv_type __attribute__((unused)))
 {
 	struct logical_volume *lv = find_lv(vg, name);
 
@@ -355,7 +355,7 @@
 static int _finish_lvconvert_mirror(struct cmd_context *cmd,
 				    struct volume_group *vg,
 				    struct logical_volume *lv,
-				    struct dm_list *lvs_changed __attribute((unused)))
+				    struct dm_list *lvs_changed __attribute__((unused)))
 {
 	int r = 0;
 
@@ -402,7 +402,7 @@
 static int _finish_lvconvert_merge(struct cmd_context *cmd,
 				   struct volume_group *vg,
 				   struct logical_volume *lv,
-				   struct dm_list *lvs_changed __attribute((unused)))
+				   struct dm_list *lvs_changed __attribute__((unused)))
 {
 	struct lv_segment *snap_seg = find_merging_cow(lv);
 	if (!snap_seg) {
@@ -422,7 +422,7 @@
 
 static progress_t _poll_merge_progress(struct cmd_context *cmd,
 				       struct logical_volume *lv,
-				       const char *name __attribute((unused)),
+				       const char *name __attribute__((unused)),
 				       struct daemon_parms *parms)
 {
 	float percent = 0.0;
@@ -605,7 +605,7 @@
 }
 
 static int _is_partial_lv(struct logical_volume *lv,
-			  void *baton __attribute((unused)))
+			  void *baton __attribute__((unused)))
 {
 	return lv->status & PARTIAL_LV;
 }
--- LVM2/tools/lvcreate.c	2010/05/11 21:40:11	1.222
+++ LVM2/tools/lvcreate.c	2010/07/09 15:34:48	1.223
@@ -236,7 +236,7 @@
  * Generic mirror parameter checks.
  * FIXME: Should eventually be moved into lvm library.
  */
-static int _validate_mirror_params(const struct cmd_context *cmd __attribute((unused)),
+static int _validate_mirror_params(const struct cmd_context *cmd __attribute__((unused)),
 				   const struct lvcreate_params *lp)
 {
 	int pagesize = lvm_getpagesize();
--- LVM2/tools/lvm-static.c	2009/01/20 20:37:41	1.8
+++ LVM2/tools/lvm-static.c	2010/07/09 15:34:48	1.9
@@ -22,8 +22,8 @@
 	return lvm2_main(argc, argv);
 }
 
-int lvm_shell(struct cmd_context *cmd __attribute((unused)),
-	      struct cmdline_context *cmdline __attribute((unused)))
+int lvm_shell(struct cmd_context *cmd __attribute__((unused)),
+	      struct cmdline_context *cmdline __attribute__((unused)))
 {
 	return 0;
 }
--- LVM2/tools/lvm.c	2010/07/01 11:04:58	1.112
+++ LVM2/tools/lvm.c	2010/07/09 15:34:48	1.113
@@ -122,7 +122,7 @@
 
 /* Custom completion function */
 static char **_completion(const char *text, int start_pos,
-			  int end_pos __attribute((unused)))
+			  int end_pos __attribute__((unused)))
 {
 	char **match_list = NULL;
 	int p = 0;
--- LVM2/tools/lvm2cmd.c	2008/01/31 12:19:36	1.4
+++ LVM2/tools/lvm2cmd.c	2010/07/09 15:34:48	1.5
@@ -20,8 +20,8 @@
 	return cmdlib_lvm2_init(0);
 }
 
-int lvm_shell(struct cmd_context *cmd __attribute((unused)),
-	      struct cmdline_context *cmdline __attribute((unused)))
+int lvm_shell(struct cmd_context *cmd __attribute__((unused)),
+	      struct cmdline_context *cmdline __attribute__((unused)))
 {
 	return 0;
 }
--- LVM2/tools/lvmchange.c	2009/12/03 19:18:34	1.9
+++ LVM2/tools/lvmchange.c	2010/07/09 15:34:48	1.10
@@ -15,8 +15,8 @@
 
 #include "tools.h"
 
-int lvmchange(struct cmd_context *cmd __attribute((unused)),
-	      int argc __attribute((unused)), char **argv __attribute((unused)))
+int lvmchange(struct cmd_context *cmd __attribute__((unused)),
+	      int argc __attribute__((unused)), char **argv __attribute__((unused)))
 {
 	log_error("With LVM2 and the device mapper, this program is obsolete.");
 	return ECMD_FAILED;
--- LVM2/tools/lvmcmdline.c	2010/06/30 20:21:03	1.126
+++ LVM2/tools/lvmcmdline.c	2010/07/09 15:34:48	1.127
@@ -60,7 +60,7 @@
 
 /* Command line args */
 /* FIXME: Move static _the_args into cmd? */
-unsigned arg_count(const struct cmd_context *cmd __attribute((unused)), int a)
+unsigned arg_count(const struct cmd_context *cmd __attribute__((unused)), int a)
 {
 	return _the_args[a].count;
 }
@@ -70,7 +70,7 @@
 	return arg_count(cmd, a) ? 1 : 0;
 }
 
-const char *arg_value(struct cmd_context *cmd __attribute((unused)), int a)
+const char *arg_value(struct cmd_context *cmd __attribute__((unused)), int a)
 {
 	return _the_args[a].value;
 }
@@ -117,12 +117,12 @@
 	return arg_count(cmd, a) ? _the_args[a].percent : def;
 }
 
-int arg_count_increment(struct cmd_context *cmd __attribute((unused)), int a)
+int arg_count_increment(struct cmd_context *cmd __attribute__((unused)), int a)
 {
 	return _the_args[a].count++;
 }
 
-int yes_no_arg(struct cmd_context *cmd __attribute((unused)), struct arg *a)
+int yes_no_arg(struct cmd_context *cmd __attribute__((unused)), struct arg *a)
 {
 	a->sign = SIGN_NONE;
 	a->percent = PERCENT_NONE;
@@ -143,7 +143,7 @@
 	return 1;
 }
 
-int yes_no_excl_arg(struct cmd_context *cmd __attribute((unused)),
+int yes_no_excl_arg(struct cmd_context *cmd __attribute__((unused)),
 		    struct arg *a)
 {
 	a->sign = SIGN_NONE;
@@ -225,7 +225,7 @@
 }
 
 /* Size stored in sectors */
-static int _size_arg(struct cmd_context *cmd __attribute((unused)), struct arg *a, int factor)
+static int _size_arg(struct cmd_context *cmd __attribute__((unused)), struct arg *a, int factor)
 {
 	char *ptr;
 	int i;
@@ -307,7 +307,7 @@
 	return _size_arg(cmd, a, 2048);
 }
 
-int int_arg(struct cmd_context *cmd __attribute((unused)), struct arg *a)
+int int_arg(struct cmd_context *cmd __attribute__((unused)), struct arg *a)
 {
 	char *ptr;
 
@@ -317,7 +317,7 @@
 	return 1;
 }
 
-int int_arg_with_sign(struct cmd_context *cmd __attribute((unused)), struct arg *a)
+int int_arg_with_sign(struct cmd_context *cmd __attribute__((unused)), struct arg *a)
 {
 	char *ptr;
 
@@ -327,7 +327,7 @@
 	return 1;
 }
 
-int int_arg_with_sign_and_percent(struct cmd_context *cmd __attribute((unused)),
+int int_arg_with_sign_and_percent(struct cmd_context *cmd __attribute__((unused)),
 				  struct arg *a)
 {
 	char *ptr;
@@ -360,7 +360,7 @@
 	return 1;
 }
 
-int minor_arg(struct cmd_context *cmd __attribute((unused)), struct arg *a)
+int minor_arg(struct cmd_context *cmd __attribute__((unused)), struct arg *a)
 {
 	char *ptr;
 
@@ -375,7 +375,7 @@
 	return 1;
 }
 
-int major_arg(struct cmd_context *cmd __attribute((unused)), struct arg *a)
+int major_arg(struct cmd_context *cmd __attribute__((unused)), struct arg *a)
 {
 	char *ptr;
 
@@ -392,13 +392,13 @@
 	return 1;
 }
 
-int string_arg(struct cmd_context *cmd __attribute((unused)),
-	       struct arg *a __attribute((unused)))
+int string_arg(struct cmd_context *cmd __attribute__((unused)),
+	       struct arg *a __attribute__((unused)))
 {
 	return 1;
 }
 
-int tag_arg(struct cmd_context *cmd __attribute((unused)), struct arg *a)
+int tag_arg(struct cmd_context *cmd __attribute__((unused)), struct arg *a)
 {
 	char *pos = a->value;
 
@@ -413,7 +413,7 @@
 	return 1;
 }
 
-int permission_arg(struct cmd_context *cmd __attribute((unused)), struct arg *a)
+int permission_arg(struct cmd_context *cmd __attribute__((unused)), struct arg *a)
 {
 	a->sign = SIGN_NONE;
 
@@ -429,7 +429,7 @@
 	return 1;
 }
 
-int alloc_arg(struct cmd_context *cmd __attribute((unused)), struct arg *a)
+int alloc_arg(struct cmd_context *cmd __attribute__((unused)), struct arg *a)
 {
 	alloc_policy_t alloc;
 
@@ -452,7 +452,7 @@
 /*
  * Positive integer, zero or "auto".
  */
-int readahead_arg(struct cmd_context *cmd __attribute((unused)), struct arg *a)
+int readahead_arg(struct cmd_context *cmd __attribute__((unused)), struct arg *a)
 {
 	if (!strcasecmp(a->value, "auto")) {
 		a->ui_value = DM_READ_AHEAD_AUTO;
@@ -476,7 +476,7 @@
 /*
  * Non-zero, positive integer, "all", or "unmanaged"
  */
-int metadatacopies_arg(struct cmd_context *cmd __attribute((unused)),
+int metadatacopies_arg(struct cmd_context *cmd __attribute__((unused)),
 			 struct arg *a)
 {
 	if (!strncmp(cmd->command->name, "vg", 2)) {
@@ -763,9 +763,9 @@
 	return 1;
 }
 
-int version(struct cmd_context *cmd __attribute((unused)),
-	    int argc __attribute((unused)),
-	    char **argv __attribute((unused)))
+int version(struct cmd_context *cmd __attribute__((unused)),
+	    int argc __attribute__((unused)),
+	    char **argv __attribute__((unused)))
 {
 	char vsn[80];
 
@@ -890,7 +890,7 @@
 	}
 }
 
-int help(struct cmd_context *cmd __attribute((unused)), int argc, char **argv)
+int help(struct cmd_context *cmd __attribute__((unused)), int argc, char **argv)
 {
 	int ret = ECMD_PROCESSED;
 
--- LVM2/tools/lvmdiskscan.c	2007/08/20 20:55:30	1.20
+++ LVM2/tools/lvmdiskscan.c	2010/07/09 15:34:48	1.21
@@ -91,8 +91,8 @@
 	return 1;
 }
 
-int lvmdiskscan(struct cmd_context *cmd, int argc __attribute((unused)),
-		char **argv __attribute((unused)))
+int lvmdiskscan(struct cmd_context *cmd, int argc __attribute__((unused)),
+		char **argv __attribute__((unused)))
 {
 	uint64_t size;
 	struct dev_iter *iter;
--- LVM2/tools/lvremove.c	2010/04/23 19:27:11	1.60
+++ LVM2/tools/lvremove.c	2010/07/09 15:34:48	1.61
@@ -16,7 +16,7 @@
 #include "tools.h"
 
 static int lvremove_single(struct cmd_context *cmd, struct logical_volume *lv,
-			   void *handle __attribute((unused)))
+			   void *handle __attribute__((unused)))
 {
 	struct logical_volume *origin;
 
--- LVM2/tools/lvscan.c	2009/10/01 00:35:30	1.40
+++ LVM2/tools/lvscan.c	2010/07/09 15:34:48	1.41
@@ -16,7 +16,7 @@
 #include "tools.h"
 
 static int lvscan_single(struct cmd_context *cmd, struct logical_volume *lv,
-			 void *handle __attribute((unused)))
+			 void *handle __attribute__((unused)))
 {
 	struct lvinfo info;
 	int lv_total = 0;
--- LVM2/tools/polldaemon.c	2010/04/13 01:43:56	1.33
+++ LVM2/tools/polldaemon.c	2010/07/09 15:34:48	1.34
@@ -19,7 +19,7 @@
 #include <signal.h>
 #include <sys/wait.h>
 
-static void _sigchld_handler(int sig __attribute((unused)))
+static void _sigchld_handler(int sig __attribute__((unused)))
 {
 	while (wait4(-1, NULL, WNOHANG | WUNTRACED, NULL) > 0) ;
 }
--- LVM2/tools/pvchange.c	2010/07/07 21:30:07	1.82
+++ LVM2/tools/pvchange.c	2010/07/09 15:34:48	1.83
@@ -19,7 +19,7 @@
 
 static int _pvchange_single(struct cmd_context *cmd, struct volume_group *vg,
 			    struct physical_volume *pv,
-			    void *handle __attribute((unused)))
+			    void *handle __attribute__((unused)))
 {
 	uint32_t orig_pe_alloc_count;
 	/* FIXME Next three only required for format1. */
@@ -29,7 +29,7 @@
 	const char *pv_name = pv_dev_name(pv);
 	const char *tag = NULL;
 	const char *orig_vg_name;
-	char uuid[64] __attribute((aligned(8)));
+	char uuid[64] __attribute__((aligned(8)));
 
 	int allocatable = 0;
 	int tagarg = 0;
--- LVM2/tools/pvmove.c	2010/05/24 15:32:21	1.77
+++ LVM2/tools/pvmove.c	2010/07/09 15:34:48	1.78
@@ -596,7 +596,7 @@
 
 static struct volume_group *_get_move_vg(struct cmd_context *cmd,
 					 const char *name,
-					 const char *uuid __attribute((unused)))
+					 const char *uuid __attribute__((unused)))
 {
 	struct physical_volume *pv;
 
--- LVM2/tools/pvremove.c	2009/12/03 19:18:34	1.27
+++ LVM2/tools/pvremove.c	2010/07/09 15:34:48	1.28
@@ -90,7 +90,7 @@
 }
 
 static int pvremove_single(struct cmd_context *cmd, const char *pv_name,
-			   void *handle __attribute((unused)))
+			   void *handle __attribute__((unused)))
 {
 	struct device *dev;
 	int ret = ECMD_FAILED;
--- LVM2/tools/pvscan.c	2010/05/07 15:24:18	1.51
+++ LVM2/tools/pvscan.c	2010/07/09 15:34:48	1.52
@@ -20,9 +20,9 @@
 
 static void _pvscan_display_single(struct cmd_context *cmd,
 				   struct physical_volume *pv,
-				   void *handle __attribute((unused)))
+				   void *handle __attribute__((unused)))
 {
-	char uuid[64] __attribute((aligned(8)));
+	char uuid[64] __attribute__((aligned(8)));
 	unsigned vg_name_len = 0;
 
 	char pv_tmp_name[NAME_LEN] = { 0, };
@@ -96,8 +96,8 @@
 					   pv_pe_size(pv)));
 }
 
-int pvscan(struct cmd_context *cmd, int argc __attribute((unused)),
-	   char **argv __attribute((unused)))
+int pvscan(struct cmd_context *cmd, int argc __attribute__((unused)),
+	   char **argv __attribute__((unused)))
 {
 	int new_pvs_found = 0;
 	int pvs_found = 0;
--- LVM2/tools/reporter.c	2010/06/17 13:15:52	1.61
+++ LVM2/tools/reporter.c	2010/07/09 15:34:48	1.62
@@ -16,7 +16,7 @@
 #include "tools.h"
 #include "report.h"
 
-static int _vgs_single(struct cmd_context *cmd __attribute((unused)),
+static int _vgs_single(struct cmd_context *cmd __attribute__((unused)),
 		       const char *vg_name, struct volume_group *vg,
 		       void *handle)
 {
@@ -41,7 +41,7 @@
 	return ECMD_PROCESSED;
 }
 
-static int _segs_single(struct cmd_context *cmd __attribute((unused)),
+static int _segs_single(struct cmd_context *cmd __attribute__((unused)),
 			struct lv_segment *seg, void *handle)
 {
 	if (!report_object(handle, seg->lv->vg, seg->lv, NULL, seg, NULL)) {
@@ -133,7 +133,7 @@
 	int ret = ECMD_PROCESSED;
 	const char *vg_name = NULL;
 	struct volume_group *old_vg = vg;
-	char uuid[64] __attribute((aligned(8)));
+	char uuid[64] __attribute__((aligned(8)));
 
 	if (is_pv(pv) && !is_orphan(pv) && !vg) {
 		vg_name = pv_vg_name(pv);
--- LVM2/tools/segtypes.c	2008/01/30 14:00:02	1.4
+++ LVM2/tools/segtypes.c	2010/07/09 15:34:48	1.5
@@ -15,8 +15,8 @@
 
 #include "tools.h"
 
-int segtypes(struct cmd_context *cmd, int argc __attribute((unused)),
-	     char **argv __attribute((unused)))
+int segtypes(struct cmd_context *cmd, int argc __attribute__((unused)),
+	     char **argv __attribute__((unused)))
 {
 	display_segtypes(cmd);
 
--- LVM2/tools/stub.h	2007/08/20 20:55:30	1.46
+++ LVM2/tools/stub.h	2010/07/09 15:34:48	1.47
@@ -17,23 +17,23 @@
 	log_error("Command not implemented yet."); return ECMD_FAILED
 
 /*int e2fsadm(struct cmd_context *cmd, int argc, char **argv) unimplemented*/
-int lvmsadc(struct cmd_context *cmd __attribute((unused)),
-	    int argc __attribute((unused)),
-	    char **argv __attribute((unused)))
+int lvmsadc(struct cmd_context *cmd __attribute__((unused)),
+	    int argc __attribute__((unused)),
+	    char **argv __attribute__((unused)))
 {
 	unimplemented;
 }
 
-int lvmsar(struct cmd_context *cmd __attribute((unused)),
-	   int argc __attribute((unused)),
-	   char **argv __attribute((unused)))
+int lvmsar(struct cmd_context *cmd __attribute__((unused)),
+	   int argc __attribute__((unused)),
+	   char **argv __attribute__((unused)))
 {
 	unimplemented;
 }
 
-int pvdata(struct cmd_context *cmd __attribute((unused)),
-	   int argc __attribute((unused)),
-	   char **argv __attribute((unused)))
+int pvdata(struct cmd_context *cmd __attribute__((unused)),
+	   int argc __attribute__((unused)),
+	   char **argv __attribute__((unused)))
 {
 	log_error("There's no 'pvdata' command in LVM2.");
 	log_error("Use lvs, pvs, vgs instead; or use vgcfgbackup and read the text file backup.");
--- LVM2/tools/tools.h	2010/06/30 20:21:03	1.70
+++ LVM2/tools/tools.h	2010/07/09 15:34:48	1.71
@@ -152,7 +152,7 @@
 int segtype_arg(struct cmd_context *cmd, struct arg *a);
 int alloc_arg(struct cmd_context *cmd, struct arg *a);
 int readahead_arg(struct cmd_context *cmd, struct arg *a);
-int metadatacopies_arg(struct cmd_context *cmd __attribute((unused)), struct arg *a);
+int metadatacopies_arg(struct cmd_context *cmd __attribute__((unused)), struct arg *a);
 
 /* we use the enums to access the switches */
 unsigned arg_count(const struct cmd_context *cmd, int a);
--- LVM2/tools/vgchange.c	2010/06/30 20:03:53	1.108
+++ LVM2/tools/vgchange.c	2010/07/09 15:34:48	1.109
@@ -476,7 +476,7 @@
 	return ECMD_PROCESSED;
 }
 
-static int _vgchange_uuid(struct cmd_context *cmd __attribute((unused)),
+static int _vgchange_uuid(struct cmd_context *cmd __attribute__((unused)),
 			  struct volume_group *vg)
 {
 	struct lv_list *lvl;
@@ -564,7 +564,7 @@
 
 static int vgchange_single(struct cmd_context *cmd, const char *vg_name,
 			   struct volume_group *vg,
-			   void *handle __attribute((unused)))
+			   void *handle __attribute__((unused)))
 {
 	int dmeventd_mode, r = ECMD_FAILED;
 
--- LVM2/tools/vgck.c	2009/09/15 01:38:59	1.25
+++ LVM2/tools/vgck.c	2010/07/09 15:34:48	1.26
@@ -16,10 +16,10 @@
 #include "tools.h"
 #include "metadata.h"
 
-static int vgck_single(struct cmd_context *cmd __attribute((unused)),
+static int vgck_single(struct cmd_context *cmd __attribute__((unused)),
 		       const char *vg_name,
 		       struct volume_group *vg,
-		       void *handle __attribute((unused)))
+		       void *handle __attribute__((unused)))
 {
 	if (!vg_check_status(vg, EXPORTED_VG)) {
 		stack;
--- LVM2/tools/vgconvert.c	2010/07/08 18:24:30	1.42
+++ LVM2/tools/vgconvert.c	2010/07/09 15:34:48	1.43
@@ -17,7 +17,7 @@
 
 static int vgconvert_single(struct cmd_context *cmd, const char *vg_name,
 			    struct volume_group *vg,
-			    void *handle __attribute((unused)))
+			    void *handle __attribute__((unused)))
 {
 	struct physical_volume *pv, *existing_pv;
 	struct logical_volume *lv;
--- LVM2/tools/vgdisplay.c	2010/05/21 12:21:52	1.28
+++ LVM2/tools/vgdisplay.c	2010/07/09 15:34:48	1.29
@@ -17,7 +17,7 @@
 
 static int vgdisplay_single(struct cmd_context *cmd, const char *vg_name,
 			    struct volume_group *vg,
-			    void *handle __attribute((unused)))
+			    void *handle __attribute__((unused)))
 {
 	/* FIXME Do the active check here if activevolumegroups_ARG ? */
 	vg_check_status(vg, EXPORTED_VG);
--- LVM2/tools/vgexport.c	2009/09/15 01:38:59	1.23
+++ LVM2/tools/vgexport.c	2010/07/09 15:34:48	1.24
@@ -15,10 +15,10 @@
 
 #include "tools.h"
 
-static int vgexport_single(struct cmd_context *cmd __attribute((unused)),
+static int vgexport_single(struct cmd_context *cmd __attribute__((unused)),
 			   const char *vg_name,
 			   struct volume_group *vg,
-			   void *handle __attribute((unused)))
+			   void *handle __attribute__((unused)))
 {
 	struct pv_list *pvl;
 	struct physical_volume *pv;
--- LVM2/tools/vgimport.c	2009/09/15 01:38:59	1.23
+++ LVM2/tools/vgimport.c	2010/07/09 15:34:48	1.24
@@ -15,10 +15,10 @@
 
 #include "tools.h"
 
-static int vgimport_single(struct cmd_context *cmd __attribute((unused)),
+static int vgimport_single(struct cmd_context *cmd __attribute__((unused)),
 			   const char *vg_name,
 			   struct volume_group *vg,
-			   void *handle __attribute((unused)))
+			   void *handle __attribute__((unused)))
 {
 	struct pv_list *pvl;
 	struct physical_volume *pv;
--- LVM2/tools/vgmerge.c	2010/06/28 20:39:08	1.68
+++ LVM2/tools/vgmerge.c	2010/07/09 15:34:48	1.69
@@ -92,7 +92,7 @@
 	/* Fix up LVIDs */
 	dm_list_iterate_items(lvl1, &vg_to->lvs) {
 		union lvid *lvid1 = &lvl1->lv->lvid;
-		char uuid[64] __attribute((aligned(8)));
+		char uuid[64] __attribute__((aligned(8)));
 
 		dm_list_iterate_items(lvl2, &vg_from->lvs) {
 			union lvid *lvid2 = &lvl2->lv->lvid;
--- LVM2/tools/vgmknodes.c	2009/09/14 22:47:50	1.8
+++ LVM2/tools/vgmknodes.c	2010/07/09 15:34:48	1.9
@@ -16,7 +16,7 @@
 #include "tools.h"
 
 static int _vgmknodes_single(struct cmd_context *cmd, struct logical_volume *lv,
-			     void *handle __attribute((unused)))
+			     void *handle __attribute__((unused)))
 {
 	if (arg_count(cmd, refresh_ARG) && lv_is_visible(lv))
 		if (!lv_refresh(cmd, lv)) {
--- LVM2/tools/vgreduce.c	2010/04/13 17:26:20	1.102
+++ LVM2/tools/vgreduce.c	2010/07/09 15:34:48	1.103
@@ -18,7 +18,7 @@
 
 static int _remove_pv(struct volume_group *vg, struct pv_list *pvl, int silent)
 {
-	char uuid[64] __attribute((aligned(8)));
+	char uuid[64] __attribute__((aligned(8)));
 
 	if (vg->pv_count == 1) {
 		log_error("Volume Groups must always contain at least one PV");
@@ -376,7 +376,7 @@
 /* Or take pv_name instead? */
 static int _vgreduce_single(struct cmd_context *cmd, struct volume_group *vg,
 			    struct physical_volume *pv,
-			    void *handle __attribute((unused)))
+			    void *handle __attribute__((unused)))
 {
 	struct pv_list *pvl;
 	struct volume_group *orphan_vg = NULL;
--- LVM2/tools/vgremove.c	2010/06/30 18:03:53	1.61
+++ LVM2/tools/vgremove.c	2010/07/09 15:34:48	1.62
@@ -17,7 +17,7 @@
 
 static int vgremove_single(struct cmd_context *cmd, const char *vg_name,
 			   struct volume_group *vg,
-			   void *handle __attribute((unused)))
+			   void *handle __attribute__((unused)))
 {
 	unsigned lv_count, missing;
 	force_t force;
--- LVM2/tools/vgscan.c	2009/09/15 01:38:59	1.37
+++ LVM2/tools/vgscan.c	2010/07/09 15:34:48	1.38
@@ -17,7 +17,7 @@
 
 static int vgscan_single(struct cmd_context *cmd, const char *vg_name,
 			 struct volume_group *vg,
-			 void *handle __attribute((unused)))
+			 void *handle __attribute__((unused)))
 {
 	log_print("Found %svolume group \"%s\" using metadata type %s",
 		  vg_is_exported(vg) ? "exported " : "", vg_name,


