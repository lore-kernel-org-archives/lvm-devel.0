From: agk@sourceware.org <agk@sourceware.org>
Date: 11 Jan 2007 20:11:20 -0000
Subject: LVM2/dmeventd/mirror dmeventd_mirror.c
Message-ID: <20070111201120.22188.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2007-01-11 20:11:20

Modified files:
	dmeventd/mirror: dmeventd_mirror.c 

Log message:
	fail if status args are missing

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/dmeventd/mirror/dmeventd_mirror.c.diff?cvsroot=lvm2&r1=1.11&r2=1.12

--- LVM2/dmeventd/mirror/dmeventd_mirror.c	2007/01/11 19:52:06	1.11
+++ LVM2/dmeventd/mirror/dmeventd_mirror.c	2007/01/11 20:11:19	1.12
@@ -58,7 +58,7 @@
 	char *dev_status_str;
 	char *log_status_str;
 	char *sync_str;
-	char *p;
+	char *p = NULL;
 	int log_argc, num_devs;
 
 	/*
@@ -70,12 +70,13 @@
 	if (!dm_split_words(params, 1, 0, &p))
 		goto out_parse;
 
-	num_devs = atoi(p);
+	if (!(num_devs = atoi(p)))
+		goto out_parse;
 	p += strlen(p) + 1;
 
 	/* devices names + max log parameters */
 	args = dm_malloc((num_devs + 8) * sizeof(char *));
-	if (!args || dm_split_words(p, num_devs + 8, 0, args) < num_devs)
+	if (!args || dm_split_words(p, num_devs + 8, 0, args) < num_devs + 8)
 		goto out_parse;
 
 	dev_status_str = args[2 + num_devs];


