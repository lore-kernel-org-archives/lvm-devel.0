From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 8 Mar 2011 13:27:41 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/clvmd.c
Message-ID: <20110308132741.16819.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2011-03-08 13:27:40

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : clvmd.c 

Log message:
	Fix clvmd return code for bad options.
	
	We should return exit code 2 for unknown option.
	
	Patch also adds standard --help option instead.
	
	Fixes https://bugzilla.redhat.com/show_bug.cgi?id=666991

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1936&r2=1.1937
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd.c.diff?cvsroot=lvm2&r1=1.98&r2=1.99

--- LVM2/WHATS_NEW	2011/03/06 16:47:43	1.1936
+++ LVM2/WHATS_NEW	2011/03/08 13:27:39	1.1937
@@ -1,5 +1,6 @@
 Version 2.02.85 - 
 ===================================
+  Support --help option for clvmd and return error for unknown option.
   Use system page size and not hardcoded value in locking code check.
   Fix reading of released memory for printing segment type.
   Fix syslog initialisation in clvmd to respect lvm.conf setting.
--- LVM2/daemons/clvmd/clvmd.c	2011/03/03 13:05:40	1.98
+++ LVM2/daemons/clvmd/clvmd.c	2011/03/08 13:27:40	1.99
@@ -20,6 +20,7 @@
 #include "clvmd-common.h"
 
 #include <pthread.h>
+#include <getopt.h>
 
 #include "clvmd-comms.h"
 #include "clvm.h"
@@ -335,7 +336,7 @@
 	struct local_client *newfd;
 	struct utsname nodeinfo;
 	struct lvm_startup_params lvm_params;
-	signed char opt;
+	int opt;
 	int cmd_timeout = DEFAULT_CMD_TIMEOUT;
 	int start_timeout = 0;
 	if_type_t cluster_iface = IF_AUTO;
@@ -346,19 +347,21 @@
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
@@ -409,6 +412,9 @@
 			exit(0);
 			break;
 
+		default:
+			usage(argv[0], stderr);
+			exit(2);
 		}
 	}
 


