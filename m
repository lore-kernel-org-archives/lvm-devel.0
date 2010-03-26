From: snitzer@sourceware.org <snitzer@sourceware.org>
Date: 26 Mar 2010 15:45:37 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/clvmd-singlenode.c
Message-ID: <20100326154537.2860.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	snitzer at sourceware.org	2010-03-26 15:45:37

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : clvmd-singlenode.c 

Log message:
	Use a real socket for singlenode clvmd to fix clvmd's high cpu load.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1483&r2=1.1484
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-singlenode.c.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/WHATS_NEW	2010/03/26 15:40:13	1.1483
+++ LVM2/WHATS_NEW	2010/03/26 15:45:36	1.1484
@@ -1,5 +1,6 @@
 Version 2.02.63 -  
 ================================
+  Use a real socket for singlenode clvmd to fix clvmd's high cpu load.
   Fix clvmd cluster propagation of dmeventd monitoring mode.
   Allow ALLOC_ANYWHERE to split contiguous areas.
   Use INTERNAL_ERROR for internal errors throughout tree.
--- LVM2/daemons/clvmd/clvmd-singlenode.c	2010/03/18 09:19:31	1.1
+++ LVM2/daemons/clvmd/clvmd-singlenode.c	2010/03/26 15:45:36	1.2
@@ -17,6 +17,7 @@
 
 #include <netinet/in.h>
 #include <sys/un.h>
+#include <sys/socket.h>
 #include <unistd.h>
 #include <fcntl.h>
 #include <configure.h>
@@ -31,18 +32,37 @@
 #include "lvm-functions.h"
 #include "clvmd.h"
 
+static const char SINGLENODE_CLVMD_SOCKNAME[] = "\0singlenode_clvmd";
 static int listen_fd = -1;
 
 static int init_comms()
 {
-	listen_fd = open("/dev/null", O_RDWR);
+	struct sockaddr_un addr;
 
-	if (listen_fd < 0)
+	listen_fd = socket(PF_UNIX, SOCK_STREAM, 0);
+	if (listen_fd < 0) {
+		DEBUGLOG("Can't create local socket: %s\n", strerror(errno));
 		return -1;
-
+	}
 	/* Set Close-on-exec */
 	fcntl(listen_fd, F_SETFD, 1);
 
+	memset(&addr, 0, sizeof(addr));
+	memcpy(addr.sun_path, SINGLENODE_CLVMD_SOCKNAME,
+	       sizeof(SINGLENODE_CLVMD_SOCKNAME));
+	addr.sun_family = AF_UNIX;
+
+	if (bind(listen_fd, (struct sockaddr *)&addr, sizeof(addr)) < 0) {
+		DEBUGLOG("Can't bind local socket: %s\n", strerror(errno));
+		close(listen_fd);
+		return -1;
+	}
+	if (listen(listen_fd, 10) < 0) {
+		DEBUGLOG("Can't listen local socket: %s\n", strerror(errno));
+		close(listen_fd);
+		return -1;
+	}
+
 	return 0;
 }
 


