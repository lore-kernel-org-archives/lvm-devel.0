From: Alasdair Kergon <agk@sourceware.org>
Date: Mon, 10 Jul 2017 20:44:07 -0400
Subject: master - commands: fix lvm shell segfaults
Message-ID: <201707110044.v6B0i7KH012459@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3cd492cd599262872b212a4fc9eefc7050ce1517
Commit:        3cd492cd599262872b212a4fc9eefc7050ce1517
Parent:        56768ce36be4a63cda0fec1d06ca061d39288135
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Jul 11 01:42:06 2017 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Jul 11 01:42:06 2017 +0100

commands: fix lvm shell segfaults

Don't check for -h/--help if argc is 1.
---
 WHATS_NEW          |    1 +
 tools/lvmcmdline.c |   24 +++++++++++++-----------
 2 files changed, 14 insertions(+), 11 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 062a440..29678f4 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.173 - 
 =================================
+  Accept 'lvm -h' and 'lvm --help' as well as 'lvm help' for help.
   Suppress error message from accept() on clean lvmetad shutdown.
   Tidy clvmd client list processing and fix segfaults.
   Protect clvmd debug log messages with mutex and add client id.
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 70371d0..700593c 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -3430,17 +3430,19 @@ int lvm2_main(int argc, char **argv)
 			log_sys_error("unsetenv", "LVM_DID_EXEC");
 	}
 
-	/* "version" command is simple enough so it doesn't need any complex init */
-	if (!alias && argc > 1 && !strcmp(argv[1], "version"))
-		return lvm_return_code(version(NULL, argc, argv));
-
-	/* turn 'lvm -h' and 'lvm --help' into 'lvm help' */
-	if (!alias && (!strcmp(argv[1], "-h") || !strcmp(argv[1], "--help")))
-		argv[1] = (char *)"help";
-
-	if (!alias && (*argv[1] == '-')) {
-		log_error("Specify options after a command: lvm [command] [options].");
-		return -1;
+	if (!alias && argc > 1) {
+		/* "version" command is simple enough so it doesn't need any complex init */
+		if (!strcmp(argv[1], "version"))
+			return lvm_return_code(version(NULL, argc, argv));
+
+		/* turn 'lvm -h' and 'lvm --help' into 'lvm help' */
+		if (!strcmp(argv[1], "-h") || !strcmp(argv[1], "--help"))
+			argv[1] = (char *)"help";
+
+		if (*argv[1] == '-') {
+			log_error("Specify options after a command: lvm [command] [options].");
+			return -1;
+		}
 	}
 
 	if (!(cmd = init_lvm(0, 0)))


