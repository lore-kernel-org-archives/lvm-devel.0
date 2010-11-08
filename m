From: agk@sourceware.org <agk@sourceware.org>
Date: 8 Nov 2010 19:37:42 -0000
Subject: LVM2 ./VERSION ./VERSION_DM ./WHATS_NEW ./WHAT ...
Message-ID: <20101108193742.21585.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-11-08 19:37:41

Modified files:
	.              : VERSION VERSION_DM WHATS_NEW WHATS_NEW_DM 
	daemons/clvmd  : clvmd.c 

Log message:
	pre-release

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION.diff?cvsroot=lvm2&r1=1.258&r2=1.259
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION_DM.diff?cvsroot=lvm2&r1=1.67&r2=1.68
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1789&r2=1.1790
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.421&r2=1.422
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd.c.diff?cvsroot=lvm2&r1=1.82&r2=1.83

--- LVM2/VERSION	2010/10/25 16:38:20	1.258
+++ LVM2/VERSION	2010/11/08 19:37:40	1.259
@@ -1 +1 @@
-2.02.76(2)-cvs (2010-10-25)
+2.02.76(2)-cvs (2010-11-08)
--- LVM2/VERSION_DM	2010/10/25 16:38:20	1.67
+++ LVM2/VERSION_DM	2010/11/08 19:37:40	1.68
@@ -1 +1 @@
-1.02.57-cvs (2010-10-25)
+1.02.57-cvs (2010-11-08)
--- LVM2/WHATS_NEW	2010/11/05 18:18:11	1.1789
+++ LVM2/WHATS_NEW	2010/11/08 19:37:40	1.1790
@@ -1,16 +1,16 @@
-Version 2.02.76 - 
+Version 2.02.76 - 8th November 2010
 ===================================
   Clarify error messages when activation fails due to activation filter use.
-  Add initial script VolumeGroup.ocf for pacemaker support.
-  Fix regex optimiser not to ignore RHS of OR nodes in _find_leftmost_common.
+  Add pacemaker script VolumeGroup.ocf with configure --enable-ocf.
+  Import make.tmpl into include/ Makefile.
   Fix handling of online filesystem resize (using new fsadm return code).
   Add DIAGNOSTICS section to fsadm man page.
   Modify fsadm to return different status code for check of mounted filesystem.
   Update VG metadata only once in vgchange when making multiple changes.
   Allow independent vgchange arguments to be used together.
   Automatically unmount invalidated snapshots in dmeventd.
+  Suppress some superfluous messages from clang static analysis.
   Fix a deadlock caused by double close in clvmd.
-  Add dmeventd -R to restart dmeventd without losing monitoring state. (2.02.75)
   Fix NULL pointer dereference on too-large MDA error path in _vg_read_raw_area.
   Use static for internal _align_chunk() and _new_chunk() from pool-fast.c.
   Fix vgchange to process -a, --refresh, --monitor and --poll like lvchange.
--- LVM2/WHATS_NEW_DM	2010/11/01 13:31:55	1.421
+++ LVM2/WHATS_NEW_DM	2010/11/08 19:37:40	1.422
@@ -1,5 +1,7 @@
-Version 1.02.57
+Version 1.02.57 - 8th November 2010
 ===================================
+  Fix regex optimiser not to ignore RHS of OR nodes in _find_leftmost_common.
+  Add dmeventd -R to restart dmeventd without losing monitoring state. (1.02.56)
   Fix memory leak of field_id in _output_field function.
   Allocate buffer for reporting functions dynamically to support long outputs.
 
--- LVM2/daemons/clvmd/clvmd.c	2010/10/27 11:40:14	1.82
+++ LVM2/daemons/clvmd/clvmd.c	2010/11/08 19:37:41	1.83
@@ -184,8 +184,12 @@
 	        write(child_pipe[1], &status, sizeof(status));
 		close(child_pipe[1]);
 	}
-	if (status)
-	        exit(status);
+}
+
+static __attribute__((noreturn)) void child_init_signal_and_exit(int status) 
+{
+	child_init_signal(status);
+	exit(status);
 }
 
 static void safe_close(int *fd)
@@ -420,8 +424,10 @@
 	   potential clients will block rather than error if we are running
 	   but the cluster is not ready yet */
 	local_sock = open_local_sock();
-	if (local_sock < 0)
-		child_init_signal(DFAIL_LOCAL_SOCK);
+	if (local_sock < 0) {
+		child_init_signal_and_exit(DFAIL_LOCAL_SOCK);
+		/* NOTREACHED */
+	}
 
 	/* Set up signal handlers, USR1 is for cluster change notifications (in cman)
 	   USR2 causes child threads to exit.
@@ -498,10 +504,8 @@
 	if (!clops) {
 		DEBUGLOG("Can't initialise cluster interface\n");
 		log_error("Can't initialise cluster interface\n");
-		child_init_signal(DFAIL_CLUSTER_IF);
-#ifdef __clang__
-		__builtin_unreachable();
-#endif
+		child_init_signal_and_exit(DFAIL_CLUSTER_IF);
+		/* NOTREACHED */
 	}
 	DEBUGLOG("Cluster ready, doing some more initialisation\n");
 
@@ -517,10 +521,8 @@
 	/* Add the local socket to the list */
 	newfd = malloc(sizeof(struct local_client));
 	if (!newfd) {
-		child_init_signal(DFAIL_MALLOC);
-#ifdef __clang__
-		__builtin_unreachable();
-#endif
+		child_init_signal_and_exit(DFAIL_MALLOC);
+		/* NOTREACHED */
 	}
 
 	newfd->fd = local_sock;


