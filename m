From: Heinz Mauelshagen <mauelsha@fedoraproject.org>
Date: Thu, 20 Aug 2015 17:07:06 +0000 (UTC)
Subject: master - cmirrord: add --foreground and --help options.
Message-ID: <20150820170706.4220C60182@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=92a4b5cc3c83e1ef24092b826722ffa0e90eb697
Commit:        92a4b5cc3c83e1ef24092b826722ffa0e90eb697
Parent:        c0d6056870769a1f64204532471a8f9bd398093e
Author:        Ferenc W??gner <wferi@niif.hu>
AuthorDate:    Wed Jul 8 14:41:23 2015 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Thu Aug 20 19:06:47 2015 +0200

cmirrord: add --foreground and --help options.

---
 daemons/cmirrord/clogd.c |   42 +++++++++++++++++++++++++++++++++++++++---
 1 files changed, 39 insertions(+), 3 deletions(-)

diff --git a/daemons/cmirrord/clogd.c b/daemons/cmirrord/clogd.c
index b4736e1..6638843 100644
--- a/daemons/cmirrord/clogd.c
+++ b/daemons/cmirrord/clogd.c
@@ -15,6 +15,7 @@
 #include "link_mon.h"
 #include "local.h"
 
+#include <getopt.h>
 #include <errno.h>
 #include <fcntl.h>
 #include <sys/socket.h>
@@ -32,14 +33,49 @@ static void daemonize(void);
 static void init_all(void);
 static void cleanup_all(void);
 
-int main(int argc __attribute__((unused)), char *argv[] __attribute__((unused)))
+static void usage (FILE *dest)
 {
-	daemonize();
+	fprintf (dest, "Usage: cmirrord [options]\n"
+		 "   -f, --foreground    stay in the foreground, log to the terminal\n"
+		 "   -h, --help          print this help\n");
+}
+
+int main(int argc, char *argv[])
+{
+	int foreground_mode = 0;
+	struct option longopts[] = {
+		{ "foreground", no_argument, NULL, 'f' },
+		{ "help"      , no_argument, NULL, 'h' },
+		{ 0, 0, 0, 0 }
+	};
+	int opt;
+
+	while ((opt = getopt_long (argc, argv, "fh", longopts, NULL)) != -1) {
+		switch (opt) {
+		case 'f':
+			foreground_mode = 1;
+			break;
+		case 'h':
+			usage (stdout);
+			exit (0);
+		default:
+			usage (stderr);
+			exit (2);
+		}
+	}
+	if (optind < argc) {
+		usage (stderr);
+		exit (2);
+	}
+
+	if (!foreground_mode)
+		daemonize();
 
 	init_all();
 
 	/* Parent can now exit, we're ready to handle requests */
-	kill(getppid(), SIGTERM);
+	if (!foreground_mode)
+		kill(getppid(), SIGTERM);
 
 	LOG_PRINT("Starting cmirrord:");
 	LOG_PRINT(" Built: "__DATE__" "__TIME__"\n");


