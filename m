From: okozina <okozina@fedoraproject.org>
Date: Tue, 20 Oct 2015 13:46:07 +0000 (UTC)
Subject: master - lvmetad: add optional timeout option
Message-ID: <20151020134607.11D8160FFB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f67a52677bdc95209c7adfa4575c833bed1659f1
Commit:        f67a52677bdc95209c7adfa4575c833bed1659f1
Parent:        392248186e56fb216e49a2fee0caad5a506e3dd1
Author:        Ondrej Kozina <okozina@redhat.com>
AuthorDate:    Tue Oct 20 13:24:50 2015 +0200
Committer:     Ondrej Kozina <okozina@redhat.com>
CommitterDate: Tue Oct 20 15:45:14 2015 +0200

lvmetad: add optional timeout option

---
 WHATS_NEW                      |    1 +
 daemons/lvmetad/lvmetad-core.c |   40 ++++++++++++++++++++++++++++++++++++----
 2 files changed, 37 insertions(+), 4 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 763896e..983b2b4 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.133 - 
 ======================================
+  Add optional shutdown when idle support for lvmetad.
   Fix missing in-sync progress info while lvconvert used with lvmpolld.
   Add report/compact_output_cols to lvm.conf to define report cols to compact.
   Do not change logging in lvm2 library when it's already set.
diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index 89aaaf8..7ec3a3a 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2012 Red Hat, Inc.
+ * Copyright (C) 2012-2015 Red Hat, Inc.
  *
  * This file is part of LVM2.
  *
@@ -24,6 +24,7 @@
 #include "lvm-version.h"
 
 #include <assert.h>
+#include <errno.h>
 #include <pthread.h>
 
 #define LVMETAD_SOCKET DEFAULT_RUN_DIR "/lvmetad.socket"
@@ -123,6 +124,7 @@ struct vg_info {
 #define VGFL_INVALID 0x00000001
 
 typedef struct {
+	daemon_idle *idle;
 	log_state *log; /* convenience */
 	const char *log_config;
 
@@ -1592,6 +1594,9 @@ static int init(daemon_state *s)
 	/* if (ls->initial_registrations)
 	   _process_initial_registrations(ds->initial_registrations); */
 
+	if (ls->idle)
+		ls->idle->is_idle = 1;
+
 	return 1;
 }
 
@@ -1614,21 +1619,39 @@ static int fini(daemon_state *s)
 	return 1;
 }
 
+static int process_timeout_arg(const char *str, unsigned *max_timeouts)
+{
+	char *endptr;
+	unsigned long l;
+
+	errno = 0;
+	l = strtoul(str, &endptr, 10);
+	if (errno || *endptr || l >= UINT_MAX)
+		return 0;
+
+	*max_timeouts = (unsigned) l;
+
+	return 1;
+}
+
 static void usage(const char *prog, FILE *file)
 {
 	fprintf(file, "Usage:\n"
-		"%s [-V] [-h] [-f] [-l {all|wire|debug}] [-s path]\n\n"
+		"%s [-V] [-h] [-f] [-l {all|wire|debug}] [-s path] [-t secs]\n\n"
 		"   -V       Show version of lvmetad\n"
 		"   -h       Show this help information\n"
 		"   -f       Don't fork, run in the foreground\n"
 		"   -l       Logging message level (-l {all|wire|debug})\n"
 		"   -p       Set path to the pidfile\n"
-		"   -s       Set path to the socket to listen on\n\n", prog);
+		"   -s       Set path to the socket to listen on\n"
+		"   -t       Time to wait in seconds before shutdown on idle (missing or 0 = inifinite)\n\n", prog);
 }
 
 int main(int argc, char *argv[])
 {
 	signed char opt;
+	struct timeval timeout;
+	daemon_idle di = { .ptimeout = &timeout };
 	lvmetad_state ls = { .log_config = "" };
 	daemon_state s = {
 		.daemon_fini = fini,
@@ -1643,7 +1666,7 @@ int main(int argc, char *argv[])
 	};
 
 	// use getopt_long
-	while ((opt = getopt(argc, argv, "?fhVl:p:s:")) != EOF) {
+	while ((opt = getopt(argc, argv, "?fhVl:p:s:t:")) != EOF) {
 		switch (opt) {
 		case 'h':
 			usage(argv[0], stdout);
@@ -1663,6 +1686,15 @@ int main(int argc, char *argv[])
 		case 's': // --socket
 			s.socket_path = optarg;
 			break;
+		case 't':
+			if (!process_timeout_arg(optarg, &di.max_timeouts)) {
+				fprintf(stderr, "Invalid value of timeout parameter.\n");
+				exit(EXIT_FAILURE);
+			}
+			/* 0 equals to wait indefinitely */
+			if (di.max_timeouts)
+				s.idle = ls.idle = &di;
+			break;
 		case 'V':
 			printf("lvmetad version: " LVM_VERSION "\n");
 			exit(1);


