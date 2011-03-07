From: Milan Broz <mbroz@redhat.com>
Date: Mon,  7 Mar 2011 15:45:54 +0100
Subject: [PATCH] Fix clvmd return code for bad options.
Message-ID: <1299509154-30046-1-git-send-email-mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

We should return exit code 2 for unknown options.

Patch also adds standart --help oprion instead
of nonstandard (and getopt incomatible -?).

Fixes https://bugzilla.redhat.com/show_bug.cgi?id=666991

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 daemons/clvmd/clvmd.c |   18 ++++++++++++------
 1 files changed, 12 insertions(+), 6 deletions(-)

diff --git a/daemons/clvmd/clvmd.c b/daemons/clvmd/clvmd.c
index b6fd725..56600f9 100644
--- a/daemons/clvmd/clvmd.c
+++ b/daemons/clvmd/clvmd.c
@@ -20,6 +20,7 @@
 #include "clvmd-common.h"
 
 #include <pthread.h>
+#include <getopt.h>
 
 #include "clvmd-comms.h"
 #include "clvm.h"
@@ -335,7 +336,7 @@ int main(int argc, char *argv[])
 	struct local_client *newfd;
 	struct utsname nodeinfo;
 	struct lvm_startup_params lvm_params;
-	signed char opt;
+	int opt;
 	int cmd_timeout = DEFAULT_CMD_TIMEOUT;
 	int start_timeout = 0;
 	if_type_t cluster_iface = IF_AUTO;
@@ -346,19 +347,21 @@ int main(int argc, char *argv[])
 	int clusterwide_opt = 0;
 	mode_t old_mask;
 
+	struct option longopts[] = {
+		{ "help", 0, 0, 'h' },
+		{ NULL, 0, 0, 0 }
+	};
+
 	/* Deal with command-line arguments */
 	opterr = 0;
 	optind = 0;
-	while ((opt = getopt(argc, argv, "?vVhfd::t:RST:CI:E:")) != EOF) {
+	while ((opt = getopt_long(argc, argv, "vVhfd::t:RST:CI:E:",
+				  longopts, NULL)) != -1) {
 		switch (opt) {
 		case 'h':
 			usage(argv[0], stdout);
 			exit(0);
 
-		case '?':
-			usage(argv[0], stderr);
-			exit(0);
-
 		case 'R':
 			check_permissions();
 			return refresh_clvmd(1)==1?0:1;
@@ -409,6 +412,9 @@ int main(int argc, char *argv[])
 			exit(0);
 			break;
 
+		default:
+			usage(argv[0], stderr);
+			exit(2);
 		}
 	}
 
-- 
1.7.2.3


