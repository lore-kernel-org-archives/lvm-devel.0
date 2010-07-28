From: agk@sourceware.org <agk@sourceware.org>
Date: 28 Jul 2010 13:55:48 -0000
Subject: LVM2 ./Makefile.in ./VERSION ./WHATS_NEW ./con ...
Message-ID: <20100728135548.16522.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-07-28 13:55:43

Modified files:
	.              : Makefile.in VERSION WHATS_NEW configure 
	                 configure.in 
	daemons/clvmd  : clvm.h clvmd.c clvmd.h 
	lib/misc       : configure.h.in 

Log message:
	Change clvmd to communicate with lvm via a socket in /var/run/lvm.   (mbroz)
	
	https://bugzilla.redhat.com/show_bug.cgi?id=614248 [CVE-2010-2526]

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/Makefile.in.diff?cvsroot=lvm2&r1=1.58&r2=1.59
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION.diff?cvsroot=lvm2&r1=1.248&r2=1.249
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1674&r2=1.1675
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.diff?cvsroot=lvm2&r1=1.136&r2=1.137
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.in.diff?cvsroot=lvm2&r1=1.149&r2=1.150
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvm.h.diff?cvsroot=lvm2&r1=1.8&r2=1.9
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd.c.diff?cvsroot=lvm2&r1=1.73&r2=1.74
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd.h.diff?cvsroot=lvm2&r1=1.11&r2=1.12
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/configure.h.in.diff?cvsroot=lvm2&r1=1.25&r2=1.26

--- LVM2/Makefile.in	2010/07/20 15:25:39	1.58
+++ LVM2/Makefile.in	2010/07/28 13:55:42	1.59
@@ -84,6 +84,7 @@
 	$(INSTALL_ROOT_DIR) $(DESTDIR)$(DEFAULT_BACKUP_DIR)
 	$(INSTALL_ROOT_DIR) $(DESTDIR)$(DEFAULT_CACHE_DIR)
 	$(INSTALL_ROOT_DIR) $(DESTDIR)$(DEFAULT_LOCK_DIR)
+	$(INSTALL_ROOT_DIR) $(DESTDIR)$(DEFAULT_RUN_DIR)
 	$(INSTALL_ROOT_DATA) /dev/null $(DESTDIR)$(DEFAULT_CACHE_DIR)/.cache
 
 install_initscripts: 
--- LVM2/VERSION	2010/07/28 11:49:42	1.248
+++ LVM2/VERSION	2010/07/28 13:55:42	1.249
@@ -1 +1 @@
-2.02.71(2)-cvs (2010-07-28)
+2.02.72(2)-cvs (2010-07-28)
--- LVM2/WHATS_NEW	2010/07/28 11:49:42	1.1674
+++ LVM2/WHATS_NEW	2010/07/28 13:55:42	1.1675
@@ -1,3 +1,9 @@
+Version 2.02.72 - 28th July 2010  [CVE-2010-2526]
+=================================================
+  Change clvmd to communicate with lvm2 via a socket in /var/run/lvm.
+  Return controlled error if clvmd is run by non-root user.
+  Add configure --default-run-dir for /var/run/lvm.
+
 Version 2.02.71 - 28th July 2010
 ================================
   Document LVM fault handling in doc/lvm_fault_handling.txt.
--- LVM2/configure	2010/07/21 12:54:21	1.136
+++ LVM2/configure	2010/07/28 13:55:42	1.137
@@ -863,6 +863,7 @@
 with_udevdir
 with_dmeventd_pidfile
 with_dmeventd_path
+with_default_run_dir
 with_default_system_dir
 with_default_archive_subdir
 with_default_backup_subdir
@@ -1599,6 +1600,7 @@
                           dmeventd pidfile [/var/run/dmeventd.pid]
   --with-dmeventd-path=PATH
                           dmeventd path [EPREFIX/sbin/dmeventd]
+  --with-default-run-dir=DIR       Default run directory [/var/run/lvm]
   --with-default-system-dir=DIR
                           default LVM system directory [/etc/lvm]
   --with-default-archive-subdir=SUBDIR
@@ -17816,6 +17818,21 @@
 
 fi
 
+
+
+
+# Check whether --with-default-run-dir was given.
+if test "${with_default_run_dir+set}" = set; then
+  withval=$with_default_run_dir;  DEFAULT_RUN_DIR="$withval"
+else
+   DEFAULT_RUN_DIR="/var/run/lvm"
+fi
+
+cat >>confdefs.h <<_ACEOF
+#define DEFAULT_RUN_DIR "$DEFAULT_RUN_DIR"
+_ACEOF
+
+
 ################################################################################
 
 # Check whether --with-default-system-dir was given.
--- LVM2/configure.in	2010/07/20 15:25:39	1.149
+++ LVM2/configure.in	2010/07/28 13:55:42	1.150
@@ -1127,6 +1127,13 @@
 			   [Path to dmeventd binary.])
 fi
 
+AH_TEMPLATE(DEFAULT_RUN_DIR, [Name of default run directory.])
+AC_ARG_WITH(default-run-dir,
+	    [  --with-default-run-dir=DIR       Default run directory [[/var/run/lvm]] ],
+	    [ DEFAULT_RUN_DIR="$withval" ],
+	    [ DEFAULT_RUN_DIR="/var/run/lvm" ])
+AC_DEFINE_UNQUOTED(DEFAULT_RUN_DIR,["$DEFAULT_RUN_DIR"] )
+
 ################################################################################
 dnl -- various defaults
 AC_ARG_WITH(default-system-dir,
--- LVM2/daemons/clvmd/clvm.h	2010/04/20 14:07:38	1.8
+++ LVM2/daemons/clvmd/clvm.h	2010/07/28 13:55:43	1.9
@@ -22,6 +22,8 @@
 #ifndef _CLVM_H
 #define _CLVM_H
 
+#include "configure.h"
+
 struct clvm_header {
 	uint8_t  cmd;	        /* See below */
 	uint8_t  flags;	        /* See below */
@@ -45,9 +47,8 @@
 #define CLVMD_FLAG_SYSTEMLV     2	/* Data in system LV under my node name */
 #define CLVMD_FLAG_NODEERRS     4       /* Reply has errors in node-specific portion */
 
-/* Name of the local socket to communicate between libclvm and clvmd */
-//static const char CLVMD_SOCKNAME[]="/var/run/clvmd";
-static const char CLVMD_SOCKNAME[] = "\0clvmd";
+/* Name of the local socket to communicate between lvm and clvmd */
+static const char CLVMD_SOCKNAME[]= DEFAULT_RUN_DIR "/clvmd.sock";
 
 /* Internal commands & replies */
 #define CLVMD_CMD_REPLY    1
--- LVM2/daemons/clvmd/clvmd.c	2010/07/13 13:51:02	1.73
+++ LVM2/daemons/clvmd/clvmd.c	2010/07/28 13:55:43	1.74
@@ -123,6 +123,7 @@
 static int process_reply(const struct clvm_header *msg, int msglen,
 			 const char *csid);
 static int open_local_sock(void);
+static void close_local_sock(int local_socket);
 static int check_local_clvmd(void);
 static struct local_client *find_client(int clientid);
 static void main_loop(int local_sock, int cmd_timeout);
@@ -276,6 +277,23 @@
 	unlink(CLVMD_PIDFILE);
 }
 
+/*
+ * clvmd require dm-ioctl capability for operation
+ */
+static void check_permissions()
+{
+	if (getuid() || geteuid()) {
+		log_error("Cannot run as a non-root user.");
+
+		 /*
+		  * Fail cleanly here if not run as root, instead of failing
+		  * later when attempting a root-only operation 
+		  * Preferred exit code from an initscript for this.
+		  */
+		exit(4);
+	}
+}
+
 int main(int argc, char *argv[])
 {
 	int local_sock;
@@ -305,9 +323,11 @@
 			exit(0);
 
 		case 'R':
+			check_permissions();
 			return refresh_clvmd(1)==1?0:1;
 
 		case 'S':
+			check_permissions();
 			return restart_clvmd(clusterwide_opt)==1?0:1;
 
 		case 'C':
@@ -353,6 +373,8 @@
 		}
 	}
 
+	check_permissions();
+
 	/* Setting debug options on an existing clvmd */
 	if (debug_opt && !check_local_clvmd()) {
 
@@ -521,6 +543,7 @@
 	/* Do some work */
 	main_loop(local_sock, cmd_timeout);
 
+	close_local_sock(local_sock);
 	destroy_lvm();
 
 	return 0;
@@ -864,7 +887,6 @@
 
       closedown:
 	clops->cluster_closedown();
-	close(local_sock);
 }
 
 static __attribute__ ((noreturn)) void wait_for_child(int c_pipe, int timeout)
@@ -1963,20 +1985,30 @@
 	return ret;
 }
 
+static void close_local_sock(int local_socket)
+{
+	if (local_socket != -1 && close(local_socket))
+		stack;
+
+	if (CLVMD_SOCKNAME[0] != '\0' && unlink(CLVMD_SOCKNAME))
+		stack;
+}
 
 /* Open the local socket, that's the one we talk to libclvm down */
 static int open_local_sock()
 {
-	int local_socket;
+	int local_socket = -1;
 	struct sockaddr_un sockaddr;
+	mode_t old_mask;
+
+	close_local_sock(local_socket);
+	old_mask = umask(0077);
 
 	/* Open local socket */
-	if (CLVMD_SOCKNAME[0] != '\0')
-		unlink(CLVMD_SOCKNAME);
 	local_socket = socket(PF_UNIX, SOCK_STREAM, 0);
 	if (local_socket < 0) {
 		log_error("Can't create local socket: %m");
-		return -1;
+		goto error;
 	}
 
 	/* Set Close-on-exec & non-blocking */
@@ -1989,18 +2021,19 @@
 	sockaddr.sun_family = AF_UNIX;
 	if (bind(local_socket, (struct sockaddr *) &sockaddr, sizeof(sockaddr))) {
 		log_error("can't bind local socket: %m");
-		close(local_socket);
-		return -1;
+		goto error;
 	}
 	if (listen(local_socket, 1) != 0) {
 		log_error("listen local: %m");
-		close(local_socket);
-		return -1;
+		goto error;
 	}
-	if (CLVMD_SOCKNAME[0] != '\0')
-		chmod(CLVMD_SOCKNAME, 0600);
 
+	umask(old_mask);
 	return local_socket;
+error:
+	close_local_sock(local_socket);
+	umask(old_mask);
+	return -1;
 }
 
 void process_message(struct local_client *client, const char *buf, int len,
--- LVM2/daemons/clvmd/clvmd.h	2007/08/17 11:51:23	1.11
+++ LVM2/daemons/clvmd/clvmd.h	2010/07/28 13:55:43	1.12
@@ -20,9 +20,6 @@
 #define CLVMD_MINOR_VERSION 2
 #define CLVMD_PATCH_VERSION 1
 
-/* Name of the cluster LVM admin lock */
-#define ADMIN_LOCK_NAME "CLVMD_ADMIN"
-
 /* Default time (in seconds) we will wait for all remote commands to execute
    before declaring them dead */
 #define DEFAULT_CMD_TIMEOUT 60
--- LVM2/lib/misc/configure.h.in	2010/07/13 13:51:03	1.25
+++ LVM2/lib/misc/configure.h.in	2010/07/28 13:55:43	1.26
@@ -35,6 +35,9 @@
 /* Name of default locking directory. */
 #undef DEFAULT_LOCK_DIR
 
+/* Name of default run directory. */
+#undef DEFAULT_RUN_DIR
+
 /* Define to 0 to reinstate the pre-2.02.54 handling of unit suffixes. */
 #undef DEFAULT_SI_UNIT_CONSISTENCY
 


