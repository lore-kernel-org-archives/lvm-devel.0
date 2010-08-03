From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 3 Aug 2010 13:06:39 -0000
Subject: LVM2 daemons/clvmd/clvmd-singlenode.c daemons/ ...
Message-ID: <20100803130639.16137.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-08-03 13:06:36

Modified files:
	daemons/clvmd  : clvmd-singlenode.c clvmd.c lvm-functions.c 
	lib/format_text: import.c 
	lib/locking    : file_locking.c 
	libdm          : libdm-common.c 
	libdm/ioctl    : libdm-iface.c 

Log message:
	Use void parameter for function definition.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-singlenode.c.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd.c.diff?cvsroot=lvm2&r1=1.75&r2=1.76
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/lvm-functions.c.diff?cvsroot=lvm2&r1=1.96&r2=1.97
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/import.c.diff?cvsroot=lvm2&r1=1.50&r2=1.51
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/file_locking.c.diff?cvsroot=lvm2&r1=1.47&r2=1.48
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-common.c.diff?cvsroot=lvm2&r1=1.98&r2=1.99
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/ioctl/libdm-iface.c.diff?cvsroot=lvm2&r1=1.77&r2=1.78

--- LVM2/daemons/clvmd/clvmd-singlenode.c	2010/07/28 14:01:41	1.5
+++ LVM2/daemons/clvmd/clvmd-singlenode.c	2010/08/03 13:06:35	1.6
@@ -29,7 +29,7 @@
 static const char SINGLENODE_CLVMD_SOCKNAME[] = DEFAULT_RUN_DIR "/clvmd_singlenode.sock";
 static int listen_fd = -1;
 
-static void close_comms()
+static void close_comms(void)
 {
 	if (listen_fd != -1 && close(listen_fd))
 		stack;
@@ -37,7 +37,7 @@
 	listen_fd = -1;
 }
 
-static int init_comms()
+static int init_comms(void)
 {
 	struct sockaddr_un addr;
 	mode_t old_mask;
@@ -112,7 +112,7 @@
 	return 0;
 }
 
-static int _get_num_nodes()
+static int _get_num_nodes(void)
 {
 	return 1;
 }
@@ -222,7 +222,7 @@
 	return 0;
 }
 
-static int _is_quorate()
+static int _is_quorate(void)
 {
 	return 1;
 }
--- LVM2/daemons/clvmd/clvmd.c	2010/07/28 14:01:41	1.75
+++ LVM2/daemons/clvmd/clvmd.c	2010/08/03 13:06:35	1.76
@@ -280,7 +280,7 @@
 /*
  * clvmd require dm-ioctl capability for operation
  */
-static void check_permissions()
+static void check_permissions(void)
 {
 	if (getuid() || geteuid()) {
 		log_error("Cannot run as a non-root user.");
--- LVM2/daemons/clvmd/lvm-functions.c	2010/07/01 21:23:48	1.96
+++ LVM2/daemons/clvmd/lvm-functions.c	2010/08/03 13:06:35	1.97
@@ -624,7 +624,7 @@
 /* Only called at gulm startup. Drop any leftover VG or P_orphan locks
    that might be hanging around if we died for any reason
 */
-static void drop_vg_locks()
+static void drop_vg_locks(void)
 {
 	char vg[128];
 	char line[255];
@@ -810,7 +810,7 @@
 }
 
 /* This checks some basic cluster-LVM configuration stuff */
-static void check_config()
+static void check_config(void)
 {
 	int locking_type;
 
--- LVM2/lib/format_text/import.c	2010/03/31 17:23:19	1.50
+++ LVM2/lib/format_text/import.c	2010/08/03 13:06:35	1.51
@@ -25,7 +25,7 @@
 
 static int _text_import_initialised = 0;
 
-static void _init_text_import()
+static void _init_text_import(void)
 {
 	if (_text_import_initialised)
 		return;
--- LVM2/lib/locking/file_locking.c	2010/07/09 15:34:45	1.47
+++ LVM2/lib/locking/file_locking.c	2010/08/03 13:06:35	1.48
@@ -118,7 +118,7 @@
 	log_error("CTRL-c detected: giving up waiting for lock");
 }
 
-static void _install_ctrl_c_handler()
+static void _install_ctrl_c_handler(void)
 {
 	_handler_installed = 1;
 
--- LVM2/libdm/libdm-common.c	2010/08/03 07:56:03	1.98
+++ LVM2/libdm/libdm-common.c	2010/08/03 13:06:36	1.99
@@ -930,7 +930,7 @@
 
 #else		/* UDEV_SYNC_SUPPORT */
 
-static int _check_semaphore_is_supported()
+static int _check_semaphore_is_supported(void)
 {
 	int maxid;
 	union semun arg;
@@ -976,7 +976,7 @@
 	return 0;
 }
 
-static void _check_udev_sync_requirements_once()
+static void _check_udev_sync_requirements_once(void)
 {
 	if (_semaphore_supported < 0)
 		_semaphore_supported = _check_semaphore_is_supported();
--- LVM2/libdm/ioctl/libdm-iface.c	2010/07/28 10:30:28	1.77
+++ LVM2/libdm/ioctl/libdm-iface.c	2010/08/03 13:06:36	1.78
@@ -139,7 +139,7 @@
 	return (void *) (((unsigned long) ptr + agn) & ~agn);
 }
 
-static int _uname()
+static int _uname(void)
 {
 	static int _uts_set = 0;
 	struct utsname _uts;


