From: agk@sourceware.org <agk@sourceware.org>
Date: 3 Jun 2008 17:48:13 -0000
Subject: LVM2/tools lvm.c lvmcmdline.c
Message-ID: <20080603174813.15733.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-06-03 17:48:13

Modified files:
	tools          : lvm.c lvmcmdline.c 

Log message:
	suppress warning on silent failure with ECMD_PROCESSED

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvm.c.diff?cvsroot=lvm2&r1=1.106&r2=1.107
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmcmdline.c.diff?cvsroot=lvm2&r1=1.64&r2=1.65

--- LVM2/tools/lvm.c	2008/05/30 15:27:44	1.106
+++ LVM2/tools/lvm.c	2008/06/03 17:48:13	1.107
@@ -236,7 +236,7 @@
 			log_error("No such command '%s'.  Try 'help'.",
 				  argv[0]);
 
-                if (ret && !error_message_produced()) {
+                if ((ret != ECMD_PROCESSED) && !error_message_produced()) {
 			log_debug("Internal error: Failed command did not use log_error");
 			log_error("Command failed with status code %d.", ret);
 		}
--- LVM2/tools/lvmcmdline.c	2008/05/30 15:27:44	1.64
+++ LVM2/tools/lvmcmdline.c	2008/06/03 17:48:13	1.65
@@ -1099,7 +1099,7 @@
 		if (!strcmp(argv[0], "quit") || !strcmp(argv[0], "exit"))
 			break;
 		ret = lvm_run_command(cmd, argc, argv);
-		if (ret) {
+		if (ret != ECMD_PROCESSED) {
 			if (!error_message_produced()) {
 				log_debug("Internal error: Failed command did not use log_error");
 				log_error("Command failed with status code %d.", ret);
@@ -1227,7 +1227,7 @@
 	if (ret == ENO_SUCH_CMD)
 		log_error("No such command.  Try 'help'.");
 
-	if (ret && !error_message_produced()) {
+	if ((ret != ECMD_PROCESSED) && !error_message_produced()) {
 		log_debug("Internal error: Failed command did not use log_error");
 		log_error("Command failed with status code %d.", ret);
 	}


