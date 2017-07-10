From: David Teigland <teigland@sourceware.org>
Date: Mon, 10 Jul 2017 12:03:36 -0400
Subject: master - lvm: run help from -h|--help
Message-ID: <201707101603.v6AG3aLQ027991@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=442d60842d2915f82bd19382b8e08d690243ddd0
Commit:        442d60842d2915f82bd19382b8e08d690243ddd0
Parent:        e9a544b94281a500bf58930c63d15aedcde961ed
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Jul 10 10:43:47 2017 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Jul 10 11:02:11 2017 -0500

lvm: run help from -h|--help

---
 tools/lvmcmdline.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 1b7940f..3fa7de5 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -3434,6 +3434,10 @@ int lvm2_main(int argc, char **argv)
 	if (!alias && argc > 1 && !strcmp(argv[1], "version"))
 		return lvm_return_code(version(NULL, argc, argv));
 
+	/* turn 'lvm -h' and 'lvm --help' into 'lvm help' */
+	if (!alias && (!strcmp(argv[1], "-h") || !strcmp(argv[1], "--help")))
+		argv[1] = (char *)"help";
+
 	if (!(cmd = init_lvm(0, 0)))
 		return -1;
 
@@ -3515,7 +3519,7 @@ int lvm2_main(int argc, char **argv)
 		ret = lvm_run_command(cmd, argc, argv);
 
 	if (ret == ENO_SUCH_CMD) {
-		log_error("No such command.  Try 'help'.");
+		log_error("No such command.  Try 'lvm help'.");
 		goto out;
 	}
 


