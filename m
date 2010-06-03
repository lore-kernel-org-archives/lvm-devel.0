From: Peter Rajnoha <prajnoha@redhat.com>
Date: Thu, 03 Jun 2010 14:59:31 +0200
Subject: [PATCH] Uname and kernel version check cleanup
Message-ID: <4C07A733.70904@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This is just a little cleanup for uname and kernel version check - uname is called
centrally. There's also a new internal function defined: kernel_version_higher_or_equal.
It uses statically stored value of the current kernel version for comparison (and uses
former logic of KERNEL_VERSION macro), so we don't need to bother calling uname all over
the place again and again.

(The function is defined twice actually - one in libdevmapper, the other one in lvm - no
need to export this from libdevmapper I think, it would be odd...)

Peter
---
 daemons/clvmd/clvmd-command.c |    4 +-
 daemons/clvmd/clvmd-gulm.c    |    3 +-
 daemons/clvmd/clvmd.c         |    4 +-
 daemons/clvmd/tcp-comms.c     |    3 +-
 lib/commands/toolcontext.c    |    5 +---
 lib/format_text/export.c      |   30 ++++--------------------
 lib/mirror/mirrored.c         |    8 +-----
 lib/misc/lvm-wrappers.c       |   49 +++++++++++++++++++++++++++++++++++++++
 lib/misc/lvm-wrappers.h       |    6 +++++
 lib/misc/util.h               |    2 -
 libdm/ioctl/libdm-iface.c     |   51 +++++++++++++++++++++++++----------------
 libdm/libdm-common.h          |    3 ++
 libdm/libdm-deptree.c         |   19 +++++----------
 13 files changed, 108 insertions(+), 79 deletions(-)

diff --git a/daemons/clvmd/clvmd-command.c b/daemons/clvmd/clvmd-command.c
index 5e3b8c1..77b6691 100644
--- a/daemons/clvmd/clvmd-command.c
+++ b/daemons/clvmd/clvmd-command.c
@@ -56,7 +56,6 @@
 #include <configure.h>
 #include <pthread.h>
 #include <sys/types.h>
-#include <sys/utsname.h>
 #include <sys/ioctl.h>
 #include <sys/socket.h>
 #include <sys/stat.h>
@@ -74,6 +73,7 @@
 #include "locking.h"
 #include "lvm-logging.h"
 #include "lvm-functions.h"
+#include "lvm-wrappers.h"
 #include "clvmd-comms.h"
 #include "clvm.h"
 #include "clvmd.h"
@@ -111,7 +111,7 @@ int do_command(struct local_client *client, struct clvm_header *msg, int msglen,
 			*buf = new_buf;
 		}
 		if (*buf) {
-			uname(&nodeinfo);
+			get_uts(&nodeinfo);
 			*retlen = 1 + snprintf(*buf, buflen,
 					       "TEST from %s: %s v%s",
 					       nodeinfo.nodename, args,
diff --git a/daemons/clvmd/clvmd-gulm.c b/daemons/clvmd/clvmd-gulm.c
index 54dce4d..32081ec 100644
--- a/daemons/clvmd/clvmd-gulm.c
+++ b/daemons/clvmd/clvmd-gulm.c
@@ -26,7 +26,6 @@
 
 #include <pthread.h>
 #include <sys/types.h>
-#include <sys/utsname.h>
 #include <sys/ioctl.h>
 #include <sys/socket.h>
 #include <sys/stat.h>
@@ -272,7 +271,7 @@ static void drop_expired_locks(char *nodename)
 
     if (!nodename)
     {
-	uname(&nodeinfo);
+	get_uts(&nodeinfo);
 	nodename = nodeinfo.nodename;
     }
 
diff --git a/daemons/clvmd/clvmd.c b/daemons/clvmd/clvmd.c
index 8dbd6ae..2e8eb51 100644
--- a/daemons/clvmd/clvmd.c
+++ b/daemons/clvmd/clvmd.c
@@ -31,7 +31,6 @@
 #include <sys/un.h>
 #include <sys/time.h>
 #include <sys/ioctl.h>
-#include <sys/utsname.h>
 #include <netinet/in.h>
 #include <stdio.h>
 #include <stdlib.h>
@@ -50,6 +49,7 @@
 
 #include "clvmd-comms.h"
 #include "lvm-functions.h"
+#include "lvm-wrappers.h"
 #include "clvm.h"
 #include "lvm-version.h"
 #include "clvmd.h"
@@ -476,7 +476,7 @@ int main(int argc, char *argv[])
 	DEBUGLOG("Cluster ready, doing some more initialisation\n");
 
 	/* Save our CSID */
-	uname(&nodeinfo);
+	get_uts(&nodeinfo);
 	clops->get_our_csid(our_csid);
 
 	/* Initialise the FD list head */
diff --git a/daemons/clvmd/tcp-comms.c b/daemons/clvmd/tcp-comms.c
index 95fb351..8d6e077 100644
--- a/daemons/clvmd/tcp-comms.c
+++ b/daemons/clvmd/tcp-comms.c
@@ -26,7 +26,6 @@
 #include <configure.h>
 #include <pthread.h>
 #include <sys/types.h>
-#include <sys/utsname.h>
 #include <sys/ioctl.h>
 #include <sys/socket.h>
 #include <sys/stat.h>
@@ -436,7 +435,7 @@ static int get_our_ip_address(char *addr, int *family)
 {
 	struct utsname info;
 
-	uname(&info);
+	get_uts(&info);
 	get_ip_address(info.nodename, addr);
 
 	return 0;
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 7c5e379..d957cc4 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -50,7 +50,6 @@
 
 #include <locale.h>
 #include <sys/stat.h>
-#include <sys/utsname.h>
 #include <syslog.h>
 #include <time.h>
 
@@ -1000,10 +999,8 @@ static int _init_hostname(struct cmd_context *cmd)
 {
 	struct utsname uts;
 
-	if (uname(&uts)) {
-		log_sys_error("uname", "_init_hostname");
+	if (!get_uts(&uts))
 		return 0;
-	}
 
 	if (!(cmd->hostname = dm_pool_strdup(cmd->libmem, uts.nodename))) {
 		log_error("_init_hostname: dm_pool_strdup failed");
diff --git a/lib/format_text/export.c b/lib/format_text/export.c
index 5f02b5d..36be8b9 100644
--- a/lib/format_text/export.c
+++ b/lib/format_text/export.c
@@ -24,7 +24,6 @@
 
 #include <stdarg.h>
 #include <time.h>
-#include <sys/utsname.h>
 
 struct formatter;
 typedef int (*out_with_comment_fn) (struct formatter * f, const char *comment,
@@ -68,23 +67,6 @@ struct formatter {
 	int header;		/* 1 => comments at start; 0 => end */
 };
 
-static struct utsname _utsname;
-
-static void _init(void)
-{
-	static int _initialised = 0;
-
-	if (_initialised)
-		return;
-
-	if (uname(&_utsname)) {
-		log_error("uname failed: %s", strerror(errno));
-		memset(&_utsname, 0, sizeof(_utsname));
-	}
-
-	_initialised = 1;
-}
-
 /*
  * Formatting functions.
  */
@@ -326,6 +308,9 @@ static int _print_header(struct formatter *f,
 {
 	char *buf;
 	time_t t;
+	struct utsname uts;
+
+	get_uts(&uts);
 
 	t = time(NULL);
 
@@ -341,9 +326,8 @@ static int _print_header(struct formatter *f,
 	}
 	outf(f, "description = \"%s\"", escape_double_quotes(buf, desc));
 	outnl(f);
-	outf(f, "creation_host = \"%s\"\t# %s %s %s %s %s", _utsname.nodename,
-	     _utsname.sysname, _utsname.nodename, _utsname.release,
-	     _utsname.version, _utsname.machine);
+	outf(f, "creation_host = \"%s\"\t# %s %s %s %s %s", uts.nodename,
+	     uts.sysname, uts.nodename, uts.release, uts.version, uts.machine);
 	outf(f, "creation_time = %lu\t# %s", t, ctime(&t));
 
 	return 1;
@@ -733,8 +717,6 @@ int text_vg_export_file(struct volume_group *vg, const char *desc, FILE *fp)
 	struct formatter *f;
 	int r;
 
-	_init();
-
 	if (!(f = dm_malloc(sizeof(*f))))
 		return_0;
 
@@ -758,8 +740,6 @@ int text_vg_export_raw(struct volume_group *vg, const char *desc, char **buf)
 	struct formatter *f;
 	int r = 0;
 
-	_init();
-
 	if (!(f = dm_malloc(sizeof(*f))))
 		return_0;
 
diff --git a/lib/mirror/mirrored.c b/lib/mirror/mirrored.c
index eca0377..dac97b1 100644
--- a/lib/mirror/mirrored.c
+++ b/lib/mirror/mirrored.c
@@ -28,8 +28,6 @@
 #include "sharedlib.h"
 #include "str_list.h"
 
-#include <sys/utsname.h>
-
 #ifdef DMEVENTD
 #  include "libdevmapper-event.h"
 #endif
@@ -473,8 +471,6 @@ static int _mirrored_target_present(struct cmd_context *cmd,
 	uint32_t maj, min, patchlevel;
 	unsigned maj2, min2, patchlevel2;
 	char vsn[80];
-	struct utsname uts;
-	unsigned kmaj, kmin, krel;
 
 	if (!_mirrored_checked) {
 		_mirrored_present = target_present(cmd, "mirror", 1);
@@ -512,9 +508,7 @@ static int _mirrored_target_present(struct cmd_context *cmd,
 			 * The dm-log-userspace module was added to the
 			 * 2.6.31 kernel.
 			 */
-			if (!uname(&uts) &&
-			    (sscanf(uts.release, "%u.%u.%u", &kmaj, &kmin, &krel) == 3) &&
-			    KERNEL_VERSION(kmaj, kmin, krel) < KERNEL_VERSION(2, 6, 31)) {
+			if (kernel_version_higher_or_equal(2, 6, 31) > 0) {
 				if (module_present(cmd, "log-clustered"))
 					_mirror_attributes |= MIRROR_LOG_CLUSTERED;
 			} else if (module_present(cmd, "log-userspace"))
diff --git a/lib/misc/lvm-wrappers.c b/lib/misc/lvm-wrappers.c
index 3ab8a71..0b015c1 100644
--- a/lib/misc/lvm-wrappers.c
+++ b/lib/misc/lvm-wrappers.c
@@ -17,6 +17,55 @@
 #include <unistd.h>
 #include <fcntl.h>
 
+static struct utsname _uts;
+
+static int _uname()
+{
+	static int _uts_set = 0;
+
+	if (_uts_set)
+		return 1;
+
+	if (uname(&_uts)) {
+		log_error("uname failed: %s", strerror(errno));
+		memset(&_uts, 0, sizeof(_uts));
+		return 0;
+	}
+
+	_uts_set = 1;
+	return 1;
+}
+
+int kernel_version_higher_or_equal(unsigned major, unsigned minor,
+				   unsigned release)
+{
+	static unsigned _kernel_vsn = 0;
+	unsigned maj, min, rel;
+
+	if (!_kernel_vsn) {
+		if (!_uname() ||
+		    !(sscanf(_uts.release, "%u.%u.%u",
+				&maj, &min, &rel) == 3)) {
+			log_error("Could not determine kernel version used.");
+			return -1;
+		}
+
+		_kernel_vsn = (maj << 16) + (min << 8) + rel;
+	}
+
+	return _kernel_vsn >= ((major << 16) + (minor << 8) + release);
+}
+
+int get_uts(struct utsname *uts)
+{
+	int r;
+
+	 r = _uname();
+	*uts = _uts;
+
+	return r;
+}
+
 int lvm_getpagesize(void)
 {
 	return getpagesize();
diff --git a/lib/misc/lvm-wrappers.h b/lib/misc/lvm-wrappers.h
index 19a7f03..9ea2756 100644
--- a/lib/misc/lvm-wrappers.h
+++ b/lib/misc/lvm-wrappers.h
@@ -16,6 +16,12 @@
 #ifndef _LVM_WRAPPERS_H
 #define _LVM_WRAPPERS_H
 
+#include <sys/utsname.h>
+
+int kernel_version_higher_or_equal(unsigned major, unsigned minor,
+				   unsigned release);
+int get_uts(struct utsname *uts);
+
 int lvm_getpagesize(void);
 
 /*
diff --git a/lib/misc/util.h b/lib/misc/util.h
index fcda369..15d2662 100644
--- a/lib/misc/util.h
+++ b/lib/misc/util.h
@@ -27,6 +27,4 @@
 
 #define uninitialized_var(x) x = x
 
-#define KERNEL_VERSION(major, minor, release) (((major) << 16) + ((minor) << 8) + (release))
-
 #endif
diff --git a/libdm/ioctl/libdm-iface.c b/libdm/ioctl/libdm-iface.c
index ed211f8..a295a29 100644
--- a/libdm/ioctl/libdm-iface.c
+++ b/libdm/ioctl/libdm-iface.c
@@ -64,9 +64,7 @@ static unsigned _dm_version_minor = 0;
 static unsigned _dm_version_patchlevel = 0;
 static int _log_suppress = 0;
 
-static int _kernel_major;
-static int _kernel_minor;
-static int _kernel_release;
+static struct utsname _uts;
 
 /*
  * If the kernel dm driver only supports one major number
@@ -142,20 +140,13 @@ static void *_align(void *ptr, unsigned int a)
 static int _uname()
 {
 	static int _uts_set = 0;
-	struct utsname _uts;
 
 	if (_uts_set)
 		return 1;
 
 	if (uname(&_uts)) {
 		log_error("uname failed: %s", strerror(errno));
-		return 0;
-	}
-	if (sscanf(_uts.release, "%d.%d.%d",
-			&_kernel_major,
-			&_kernel_minor,
-			&_kernel_release) != 3) {
-		log_error("Could not determine kernel version used.");
+		memset(&_uts, 0, sizeof(_uts));
 		return 0;
 	}
 
@@ -163,6 +154,26 @@ static int _uname()
 	return 1;
 }
 
+int kernel_version_higher_or_equal(unsigned major, unsigned minor,
+				   unsigned release)
+{
+	static unsigned _kernel_vsn = 0;
+	unsigned maj, min, rel;
+
+	if (!_kernel_vsn) {
+		if (!_uname() ||
+		    !(sscanf(_uts.release, "%u.%u.%u",
+				&maj, &min, &rel) == 3)) {
+			log_error("Could not determine kernel version used.");
+			return -1;
+		}
+
+		_kernel_vsn = (maj << 16) + (min << 8) + rel;
+	}
+
+	return _kernel_vsn >= ((major << 16) + (minor << 8) + release);
+}
+
 #ifdef DM_IOCTLS
 /*
  * Set number to NULL to populate _dm_bitset - otherwise first
@@ -293,20 +304,20 @@ static int _create_control(const char *control, uint32_t major, uint32_t minor)
 static int _create_dm_bitset(void)
 {
 #ifdef DM_IOCTLS
+	int kernel_2_6;
+
 	if (_dm_bitset || _dm_device_major)
 		return 1;
 
-	if (!_uname())
-		return 0;
-
 	/*
 	 * 2.6 kernels are limited to one major number.
 	 * Assume 2.4 kernels are patched not to.
 	 * FIXME Check _dm_version and _dm_version_minor if 2.6 changes this.
 	 */
-	if (KERNEL_VERSION(_kernel_major, _kernel_minor, _kernel_release) >=
-	    KERNEL_VERSION(2, 6, 0))
-		_dm_multiple_major_support = 0;
+	if ((kernel_2_6 = kernel_version_higher_or_equal(2, 6, 0)) < 0)
+		return 0;
+	else
+		_dm_multiple_major_support = !kernel_2_6;
 
 	if (!_dm_multiple_major_support) {
 		if (!_get_proc_number(PROC_DEVICES, DM_NAME, &_dm_device_major))
@@ -356,11 +367,12 @@ static int _open_control(void)
 #ifdef DM_IOCTLS
 	char control[PATH_MAX];
 	uint32_t major = 0, minor;
+	int kernel_autoload_support;
 
 	if (_control_fd != -1)
 		return 1;
 
-	if (!_uname())
+	if ((kernel_autoload_support = kernel_version_higher_or_equal(2, 6, 35)) < 0)
 		return 0;
 
 	snprintf(control, sizeof(control), "%s/%s", dm_dir(), DM_CONTROL_NODE);
@@ -391,8 +403,7 @@ static int _open_control(void)
 	 * and we'll create the node if needed.
 	 */
 	if (!_control_exists(control, 0, 0) ||
-	    !(KERNEL_VERSION(_kernel_major, _kernel_minor, _kernel_release) >=
-	      KERNEL_VERSION(2, 6, 35)) ||
+	    !kernel_autoload_support ||
 	    !_open_and_assign_control_fd(control)) {
 		if (!_control_device_number(&major, &minor))
 			log_error("Is device-mapper driver missing from kernel?");
diff --git a/libdm/libdm-common.h b/libdm/libdm-common.h
index fcb334f..0b1ffbd 100644
--- a/libdm/libdm-common.h
+++ b/libdm/libdm-common.h
@@ -18,6 +18,9 @@
 
 #include "libdevmapper.h"
 
+int kernel_version_higher_or_equal(unsigned major, unsigned minor,
+				   unsigned release);
+
 struct target *create_target(uint64_t start,
 			     uint64_t len,
 			     const char *type, const char *params);
diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index e1813b4..1e3085d 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -20,7 +20,6 @@
 
 #include <stdarg.h>
 #include <sys/param.h>
-#include <sys/utsname.h>
 
 #define MAX_TARGET_PARAMSIZE 500000
 
@@ -1535,17 +1534,10 @@ static int _mirror_emit_segment_line(struct dm_task *dmt, uint32_t major,
 	int block_on_error = 0;
 	int handle_errors = 0;
 	int dm_log_userspace = 0;
-	struct utsname uts;
 	unsigned log_parm_count;
 	int pos = 0;
 	char logbuf[DM_FORMAT_DEV_BUFSIZE];
 	const char *logtype;
-	unsigned kmaj, kmin, krel;
-
-	if (uname(&uts) == -1 || sscanf(uts.release, "%u.%u.%u", &kmaj, &kmin, &krel) != 3) {
-		log_error("Cannot read kernel release version");
-		return 0;
-	}
 
 	if ((seg->flags & DM_BLOCK_ON_ERROR)) {
 		/*
@@ -1558,9 +1550,10 @@ static int _mirror_emit_segment_line(struct dm_task *dmt, uint32_t major,
 		 * "handle_errors" by the dm-mirror module's version
 		 * number (>= 1.12) or by the kernel version (>= 2.6.22).
 		 */
-		if (KERNEL_VERSION(kmaj, kmin, krel) >= KERNEL_VERSION(2, 6, 22))
-			handle_errors = 1;
-		else
+		if ((handle_errors = kernel_version_higher_or_equal(2, 6, 22)) < 0)
+			return 0;
+
+		if (!handle_errors)
 			block_on_error = 1;
 	}
 
@@ -1577,8 +1570,8 @@ static int _mirror_emit_segment_line(struct dm_task *dmt, uint32_t major,
 		 * The dm-log-userspace module was added to the
 		 * 2.6.31 kernel.
 		 */
-		if (KERNEL_VERSION(kmaj, kmin, krel) >= KERNEL_VERSION(2, 6, 31))
-			dm_log_userspace = 1;
+		if ((dm_log_userspace = kernel_version_higher_or_equal(2, 6, 31)) < 0)
+			return 0;
 	}
 
 	/* Region size */


