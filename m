From: Mike Snitzer <snitzer@redhat.com>
Date: Thu, 25 Mar 2010 13:15:02 -0400
Subject: [PATCH] use a real socket for singlenode clvmd
Message-ID: <1269537302-8866-1-git-send-email-snitzer@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Using /dev/null caused clvmd to consume 100% cpu.

diff --git a/daemons/clvmd/clvmd-singlenode.c b/daemons/clvmd/clvmd-singlenode.c
index ead2031..c7114f2 100644
--- a/daemons/clvmd/clvmd-singlenode.c
+++ b/daemons/clvmd/clvmd-singlenode.c
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
 


