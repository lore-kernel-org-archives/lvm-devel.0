From: David Teigland <teigland@redhat.com>
Date: Fri, 4 Jan 2013 11:42:22 -0500
Subject: [PATCH] lvmetad: --dump option to print state
Message-ID: <20130104164222.GA10211@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Also add long opts for other options.
---
 daemons/lvmetad/lvmetad-core.c | 32 ++++++++++++++++++++++++++++++--
 1 file changed, 30 insertions(+), 2 deletions(-)

diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index 0a1c884..ab8d83e 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -20,11 +20,13 @@
 #include "daemon-server.h"
 #include "daemon-log.h"
 #include "lvm-version.h"
+#include "lvmetad-client.h"
 
 #include <assert.h>
 #include <pthread.h>
 #include <stdint.h>
 #include <unistd.h>
+#include <getopt.h>
 
 typedef struct {
 	log_state *log; /* convenience */
@@ -1019,6 +1021,19 @@ static response dump(lvmetad_state *s)
 	return res;
 }
 
+static void print_dump(const char *socket_path)
+{
+	daemon_handle h = lvmetad_open(socket_path);
+	daemon_reply reply;
+
+	reply = daemon_send_simple(h, "dump", NULL);
+
+	printf("%s\n", reply.buffer.mem);
+
+	daemon_reply_destroy(reply);
+	daemon_close(h);
+}
+
 static response handler(daemon_state s, client_handle h, request r)
 {
 	lvmetad_state *state = s.private;
@@ -1146,6 +1161,7 @@ static void usage(char *prog, FILE *file)
 int main(int argc, char *argv[])
 {
 	signed char opt;
+	int option_index = 0;
 	daemon_state s = { .private = NULL };
 	lvmetad_state ls;
 	int _socket_override = 1;
@@ -1165,8 +1181,17 @@ int main(int argc, char *argv[])
 	s.protocol_version = 1;
 	ls.log_config = "";
 
-	// use getopt_long
-	while ((opt = getopt(argc, argv, "?fhVl:s:")) != EOF) {
+	static struct option long_options[] = {
+		{"help",       no_argument,       0, 'h' },
+		{"dump",       no_argument,       0, 'd' },
+		{"foreground", no_argument,       0, 'f' },
+		{"log_config", required_argument, 0, 'l' },
+		{"socket",     required_argument, 0, 's' },
+		{"version",    no_argument,       0, 'V' },
+		{0,            0,                 0,  0  }
+	};
+
+	while ((opt = getopt_long(argc, argv, "hdfl:s:V", long_options, &option_index)) != EOF) {
 		switch (opt) {
 		case 'h':
 			usage(argv[0], stdout);
@@ -1174,6 +1199,9 @@ int main(int argc, char *argv[])
 		case '?':
 			usage(argv[0], stderr);
 			exit(0);
+		case 'd':
+			print_dump(s.socket_path);
+			exit(0);
 		case 'f':
 			s.foreground = 1;
 			break;
-- 
1.8.1.rc1.5.g7e0651a


