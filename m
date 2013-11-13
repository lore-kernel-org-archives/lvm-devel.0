From: Alasdair Kergon <agk@fedoraproject.org>
Date: Wed, 13 Nov 2013 14:11:30 +0000 (UTC)
Subject: master - gcc: replace #ifdef linux with __linux__
Message-ID: <20131113141130.146D960F88@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=527db4645fdbf10361797c871b9cadf6c5e73405
Commit:        527db4645fdbf10361797c871b9cadf6c5e73405
Parent:        d8085edf65006a50608edb821b3d30947abaa838
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Wed Nov 13 13:56:29 2013 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Wed Nov 13 13:56:29 2013 +0000

gcc: replace #ifdef linux with __linux__

---
 WHATS_NEW                                     |    1 +
 daemons/dmeventd/dmeventd.c                   |   10 +++++-----
 daemons/dmeventd/plugins/thin/dmeventd_thin.c |    2 +-
 lib/activate/activate.c                       |    4 ++--
 lib/commands/toolcontext.c                    |    2 +-
 lib/device/dev-io.c                           |    2 +-
 lib/device/dev-md.c                           |    2 +-
 lib/device/dev-swap.c                         |    2 +-
 lib/device/dev-type.c                         |    2 +-
 lib/device/dev-type.h                         |    2 +-
 lib/filters/filter-md.c                       |    2 +-
 lib/filters/filter-mpath.c                    |    2 +-
 lib/filters/filter-sysfs.c                    |    2 +-
 lib/mm/xlate.h                                |    2 +-
 libdaemon/server/daemon-server.c              |    8 ++++----
 libdm/ioctl/libdm-iface.c                     |    2 +-
 libdm/libdm-common.c                          |    4 ++--
 libdm/misc/dm-ioctl.h                         |    2 +-
 tools/dmsetup.c                               |    2 +-
 19 files changed, 28 insertions(+), 27 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index af1a26a..ff6041d 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -18,6 +18,7 @@ Version 2.02.104 -
   Remove 2>/dev/null from three lvm commands executed by vgimportclone.
   Add configure --enable-udev-systemd-background-jobs.
   Add lvm2-pvscan at .service to run pvscan as a service for lvmetad/autoactivation.
+  Use #ifdef __linux__ instead of linux throughout.
   Fix lvconvert swap of poolmetadata volume for active thin pool.
   Check for open count with a timeout before removal/deactivation of an LV.
   Report RAID images split with tracking as out-of-sync ("I").
diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index 3754714..bdaf552 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -39,7 +39,7 @@
 #include <arpa/inet.h>		/* for htonl, ntohl */
 #include <fcntl.h>		/* for musl libc */
 
-#ifdef linux
+#ifdef __linux__
 /*
  * Kernel version 2.6.36 and higher has
  * new OOM killer adjustment interface.
@@ -1619,7 +1619,7 @@ static void _exit_handler(int sig __attribute__((unused)))
 	_exit_now = 1;
 }
 
-#ifdef linux
+#ifdef __linux__
 static int _set_oom_adj(const char *oom_adj_path, int val)
 {
 	FILE *fp;
@@ -1810,7 +1810,7 @@ static void _daemonize(void)
 		fd = rlim.rlim_cur;
 
 	for (--fd; fd >= 0; fd--) {
-#ifdef linux
+#ifdef __linux__
 		/* Do not close fds preloaded by systemd! */
 		if (_systemd_activation &&
 		    (fd == SD_FD_FIFO_SERVER || fd == SD_FD_FIFO_CLIENT))
@@ -1963,7 +1963,7 @@ int main(int argc, char *argv[])
 	if (_restart)
 		restart();
 
-#ifdef linux
+#ifdef __linux__
 	_systemd_activation = _systemd_handover(&fifos);
 #endif
 
@@ -1985,7 +1985,7 @@ int main(int argc, char *argv[])
 	signal(SIGHUP, &_exit_handler);
 	signal(SIGQUIT, &_exit_handler);
 
-#ifdef linux
+#ifdef __linux__
 	/* Systemd has adjusted oom killer for us already */
 	if (!_systemd_activation && !_protect_against_oom_killer())
 		syslog(LOG_ERR, "Failed to protect against OOM killer");
diff --git a/daemons/dmeventd/plugins/thin/dmeventd_thin.c b/daemons/dmeventd/plugins/thin/dmeventd_thin.c
index 8b173f1..3126bfa 100644
--- a/daemons/dmeventd/plugins/thin/dmeventd_thin.c
+++ b/daemons/dmeventd/plugins/thin/dmeventd_thin.c
@@ -44,7 +44,7 @@ struct dso_state {
 
 
 /* TODO - move this mountinfo code into library to be reusable */
-#ifdef linux
+#ifdef __linux__
 #  include "kdev_t.h"
 #else
 #  define MAJOR(x) major((x))
diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 7e6a5ac..0597409 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -910,8 +910,8 @@ int lv_raid_message(const struct logical_volume *lv, const char *msg)
 		if (lv_is_thin_pool(lv) &&
 		    (lv_is_raid(seg_lv(first_seg(lv), 0)) ||
 		     lv_is_raid(first_seg(lv)->metadata_lv))) {
-			log_error("Thinpool data or metadata volume"
-				  " must be specified. (e.g. \"%s/%s_tdata\")",
+			log_error("Thin pool data or metadata volume "
+				  "must be specified. (E.g. \"%s/%s_tdata\")",
 				  lv->vg->name, lv->name);
 			return 0;
 		}
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 3ed359d..d13d8d5 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -49,7 +49,7 @@
 #include <syslog.h>
 #include <time.h>
 
-#ifdef linux
+#ifdef __linux__
 #  include <malloc.h>
 #endif
 
diff --git a/lib/device/dev-io.c b/lib/device/dev-io.c
index 34e3064..6c8613c 100644
--- a/lib/device/dev-io.c
+++ b/lib/device/dev-io.c
@@ -27,7 +27,7 @@
 #include <unistd.h>
 #include <sys/ioctl.h>
 
-#ifdef linux
+#ifdef __linux__
 #  define u64 uint64_t		/* Missing without __KERNEL__ */
 #  undef WNOHANG		/* Avoid redefinition */
 #  undef WUNTRACED		/* Avoid redefinition */
diff --git a/lib/device/dev-md.c b/lib/device/dev-md.c
index a8bbe81..9af8074 100644
--- a/lib/device/dev-md.c
+++ b/lib/device/dev-md.c
@@ -18,7 +18,7 @@
 #include "metadata.h"
 #include "xlate.h"
 
-#ifdef linux
+#ifdef __linux__
 
 /* Lifted from <linux/raid/md_p.h> because of difficulty including it */
 
diff --git a/lib/device/dev-swap.c b/lib/device/dev-swap.c
index 6faa810..cc44008 100644
--- a/lib/device/dev-swap.c
+++ b/lib/device/dev-swap.c
@@ -15,7 +15,7 @@
 #include "lib.h"
 #include "dev-type.h"
 
-#ifdef linux
+#ifdef __linux__
 
 #define MAX_PAGESIZE	(64 * 1024)
 #define SIGNATURE_SIZE  10
diff --git a/lib/device/dev-type.c b/lib/device/dev-type.c
index 11f0407..a98cf45 100644
--- a/lib/device/dev-type.c
+++ b/lib/device/dev-type.c
@@ -443,7 +443,7 @@ out:
 	return ret;
 }
 
-#ifdef linux
+#ifdef __linux__
 
 static unsigned long _dev_topology_attribute(struct dev_types *dt,
 					     const char *attribute,
diff --git a/lib/device/dev-type.h b/lib/device/dev-type.h
index 1227ab0..2fa32db 100644
--- a/lib/device/dev-type.h
+++ b/lib/device/dev-type.h
@@ -19,7 +19,7 @@
 
 #define NUMBER_OF_MAJORS 4096
 
-#ifdef linux
+#ifdef __linux__
 #  define MAJOR(dev)	((dev & 0xfff00) >> 8)
 #  define MINOR(dev)	((dev & 0xff) | ((dev >> 12) & 0xfff00))
 #  define MKDEV(ma,mi)	((mi & 0xff) | (ma << 8) | ((mi & ~0xff) << 12))
diff --git a/lib/filters/filter-md.c b/lib/filters/filter-md.c
index 0089f93..fe79f3d 100644
--- a/lib/filters/filter-md.c
+++ b/lib/filters/filter-md.c
@@ -16,7 +16,7 @@
 #include "lib.h"
 #include "filter.h"
 
-#ifdef linux
+#ifdef __linux__
 
 static int _ignore_md(struct dev_filter *f __attribute__((unused)),
 		      struct device *dev)
diff --git a/lib/filters/filter-mpath.c b/lib/filters/filter-mpath.c
index a9881fd..10106f0 100644
--- a/lib/filters/filter-mpath.c
+++ b/lib/filters/filter-mpath.c
@@ -16,7 +16,7 @@
 #include "filter.h"
 #include "activate.h"
 
-#ifdef linux
+#ifdef __linux__
 
 #include <dirent.h>
 
diff --git a/lib/filters/filter-sysfs.c b/lib/filters/filter-sysfs.c
index e03beca..af3ed07 100644
--- a/lib/filters/filter-sysfs.c
+++ b/lib/filters/filter-sysfs.c
@@ -15,7 +15,7 @@
 #include "lib.h"
 #include "filter.h"
 
-#ifdef linux
+#ifdef __linux__
 
 #include <dirent.h>
 
diff --git a/lib/mm/xlate.h b/lib/mm/xlate.h
index 57d7241..0d243c4 100644
--- a/lib/mm/xlate.h
+++ b/lib/mm/xlate.h
@@ -16,7 +16,7 @@
 #ifndef _LVM_XLATE_H
 #define _LVM_XLATE_H
 
-#ifdef linux
+#ifdef __linux__
 #  include <endian.h>
 #  include <byteswap.h>
 #else
diff --git a/libdaemon/server/daemon-server.c b/libdaemon/server/daemon-server.c
index b114b9f..156925a 100644
--- a/libdaemon/server/daemon-server.c
+++ b/libdaemon/server/daemon-server.c
@@ -54,7 +54,7 @@ static void _exit_handler(int sig __attribute__((unused)))
 
 #define EXIT_ALREADYRUNNING 13
 
-#ifdef linux
+#ifdef __linux__
 
 #include <stddef.h>
 
@@ -318,7 +318,7 @@ static void _daemonise(daemon_state s)
 		fd = rlim.rlim_cur;
 
 	for (--fd; fd >= 0; fd--) {
-#ifdef linux
+#ifdef __linux__
 		/* Do not close fds preloaded by systemd! */
 		if (_systemd_activation && fd == SD_FD_SOCKET_SERVER)
 			continue;
@@ -469,7 +469,7 @@ void daemon_start(daemon_state s)
 	if (setenv("LC_ALL", "C", 1))
 		perror("Cannot set LC_ALL to C");
 
-#ifdef linux
+#ifdef __linux__
 	_systemd_activation = _systemd_handover(&s);
 #endif
 
@@ -504,7 +504,7 @@ void daemon_start(daemon_state s)
 	signal(SIGALRM, &_exit_handler);
 	signal(SIGPIPE, SIG_IGN);
 
-#ifdef linux
+#ifdef __linux__
 	/* Systemd has adjusted oom killer for us already */
 	if (s.avoid_oom && !_systemd_activation && !_protect_against_oom_killer())
 		ERROR(&s, "Failed to protect against OOM killer");
diff --git a/libdm/ioctl/libdm-iface.c b/libdm/ioctl/libdm-iface.c
index c530bb7..7b1fead 100644
--- a/libdm/ioctl/libdm-iface.c
+++ b/libdm/ioctl/libdm-iface.c
@@ -23,7 +23,7 @@
 #include <sys/utsname.h>
 #include <limits.h>
 
-#ifdef linux
+#ifdef __linux__
 #  include "kdev_t.h"
 #  include <linux/limits.h>
 #else
diff --git a/libdm/libdm-common.c b/libdm/libdm-common.c
index 9a52f2e..febcd0e 100644
--- a/libdm/libdm-common.c
+++ b/libdm/libdm-common.c
@@ -32,7 +32,7 @@
 #  include <libudev.h>
 #endif
 
-#ifdef linux
+#ifdef __linux__
 #  include <linux/fs.h>
 #endif
 
@@ -1069,7 +1069,7 @@ static int _rename_dev_node(const char *old_name, const char *new_name,
 	return 1;
 }
 
-#ifdef linux
+#ifdef __linux__
 static int _open_dev_node(const char *dev_name)
 {
 	int fd = -1;
diff --git a/libdm/misc/dm-ioctl.h b/libdm/misc/dm-ioctl.h
index dae2bcb..76316b0 100644
--- a/libdm/misc/dm-ioctl.h
+++ b/libdm/misc/dm-ioctl.h
@@ -8,7 +8,7 @@
 #ifndef _LINUX_DM_IOCTL_V4_H
 #define _LINUX_DM_IOCTL_V4_H
 
-#ifdef linux
+#ifdef __linux__
 #  include <linux/types.h>
 #endif
 
diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index e25d109..4433571 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -84,7 +84,7 @@ extern char *optarg;
        __result; }))
 #endif
 
-#ifdef linux
+#ifdef __linux__
 #  include "kdev_t.h"
 #else
 #  define MAJOR(x) major((x))


