From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 24 Mar 2011 10:45:02 -0000
Subject: LVM2/daemons/clvmd clvmd-singlenode.c
Message-ID: <20110324104502.9024.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-03-24 10:45:01

Modified files:
	daemons/clvmd  : clvmd-singlenode.c 

Log message:
	Release allocated memory on closedown
	
	Release allocated buffers before exit() in debug singlenode - so it's not
	poping out in valgrind as memory leak.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-singlenode.c.diff?cvsroot=lvm2&r1=1.9&r2=1.10

--- LVM2/daemons/clvmd/clvmd-singlenode.c	2010/12/13 10:43:56	1.9
+++ LVM2/daemons/clvmd/clvmd-singlenode.c	2011/03/24 10:45:00	1.10
@@ -28,6 +28,8 @@
 
 static const char SINGLENODE_CLVMD_SOCKNAME[] = DEFAULT_RUN_DIR "/clvmd_singlenode.sock";
 static int listen_fd = -1;
+static int *_locks = NULL;
+static char **_resources = NULL;
 
 static void close_comms(void)
 {
@@ -97,6 +99,10 @@
 
 	DEBUGLOG("cluster_closedown\n");
 	destroy_lvhash();
+	dm_free(_locks);
+	dm_free(_resources);
+	_locks = NULL;
+	_resources = NULL;
 }
 
 static void _get_our_csid(char *csid)
@@ -136,8 +142,6 @@
 
 int _lock_file(const char *file, uint32_t flags);
 
-static int *_locks = NULL;
-static char **_resources = NULL;
 static int _lock_max = 1;
 static pthread_mutex_t _lock_mutex = PTHREAD_MUTEX_INITIALIZER;
 


