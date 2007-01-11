From: agk@sourceware.org <agk@sourceware.org>
Date: 11 Jan 2007 19:52:06 -0000
Subject: LVM2 ./WHATS_NEW dmeventd/mirror/dmeventd_mirror.c
Message-ID: <20070111195206.5345.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2007-01-11 19:52:06

Modified files:
	.              : WHATS_NEW 
	dmeventd/mirror: dmeventd_mirror.c 

Log message:
	Remove dmeventd mirror status line word limit

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.535&r2=1.536
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/dmeventd/mirror/dmeventd_mirror.c.diff?cvsroot=lvm2&r1=1.10&r2=1.11

--- LVM2/WHATS_NEW	2007/01/11 17:12:26	1.535
+++ LVM2/WHATS_NEW	2007/01/11 19:52:06	1.536
@@ -1,5 +1,6 @@
 Version 2.02.18 -
 ====================================
+  Remove dmeventd mirror status line word limit.
   Use CFLAGS when linking so mixed sparc builds can supply -m64.
   Prevent permission changes on active mirrors.
   Print warning instead of error message if lvconvert cannot zero volume.
--- LVM2/dmeventd/mirror/dmeventd_mirror.c	2007/01/08 14:24:20	1.10
+++ LVM2/dmeventd/mirror/dmeventd_mirror.c	2007/01/11 19:52:06	1.11
@@ -54,54 +54,51 @@
 static int _get_mirror_event(char *params)
 {
 	int i, r = ME_INSYNC;
-
-#define MAX_ARGS 30	/* should support at least 8-way mirrors */
-/* FIXME Remove unnecessary limit.  It tells you how many devices there are - use it! */
-
-	char *args[MAX_ARGS];
+	char **args = NULL;
 	char *dev_status_str;
 	char *log_status_str;
 	char *sync_str;
 	char *p;
-	int log_argc, num_devs, num_failures=0;
-
-	/* FIXME Remove unnecessary limit - get num_devs here */
-	if (MAX_ARGS <= dm_split_words(params, MAX_ARGS, 0, args)) {
-		syslog(LOG_ERR, "Unable to split mirror parameters: Arg list too long");
-		return -E2BIG;	/* FIXME Why? Unused */
-	}
+	int log_argc, num_devs;
 
 	/*
 	 * Unused:  0 409600 mirror
 	 * Used  :  2 253:4 253:5 400/400 1 AA 3 cluster 253:3 A
-	*/
-	num_devs = atoi(args[0]);
-
-	/* FIXME *Now* split rest of args */
+	 */
 
-	dev_status_str = args[3 + num_devs];
-	log_argc = atoi(args[4 + num_devs]);
-	log_status_str = args[4 + num_devs + log_argc];
-	sync_str = args[1 + num_devs];
+	/* number of devices */
+	if (!dm_split_words(params, 1, 0, &p))
+		goto out_parse;
+
+	num_devs = atoi(p);
+	p += strlen(p) + 1;
+
+	/* devices names + max log parameters */
+	args = dm_malloc((num_devs + 8) * sizeof(char *));
+	if (!args || dm_split_words(p, num_devs + 8, 0, args) < num_devs)
+		goto out_parse;
+
+	dev_status_str = args[2 + num_devs];
+	log_argc = atoi(args[3 + num_devs]);
+	log_status_str = args[3 + num_devs + log_argc];
+	sync_str = args[num_devs];
 
 	/* Check for bad mirror devices */
 	for (i = 0; i < num_devs; i++)
 		if (dev_status_str[i] == 'D') {
-			syslog(LOG_ERR, "Mirror device, %s, has failed.\n", args[i+1]);
-			num_failures++;
+			syslog(LOG_ERR, "Mirror device, %s, has failed.\n", args[i]);
+			r = ME_FAILURE;
 		}
 
-	/* Check for bad log device */
-	if (log_status_str[0] == 'D') {
+	/* Check for bad disk log device */
+	if (log_argc > 1 && log_status_str[0] == 'D') {
 		syslog(LOG_ERR, "Log device, %s, has failed.\n",
-		       args[3 + num_devs + log_argc]);
-		num_failures++;
+		       args[2 + num_devs + log_argc]);
+		r = ME_FAILURE;
 	}
 
-	if (num_failures) {
-		r = ME_FAILURE;
+	if (r == ME_FAILURE)
 		goto out;
-	}
 
 	p = strstr(sync_str, "/");
 	if (p) {
@@ -109,16 +106,19 @@
 		if (strcmp(sync_str, p+1))
 			r = ME_IGNORE;
 		p[0] = '/';
-	} else {
-		/*
-		 * How the hell did we get this?
-		 * Might mean all our parameters are screwed.
-		 */
-		syslog(LOG_ERR, "Unable to parse sync string.");
-		r = ME_IGNORE;
-	}
- out:
+	} else
+		goto out_parse;
+
+out:
+	if (args)
+		dm_free(args);
 	return r;
+	
+out_parse:
+	if (args)
+		dm_free(args);
+	syslog(LOG_ERR, "Unable to parse mirror status string.");
+	return ME_IGNORE;
 }
 
 static void _temporary_log_fn(int level, const char *file,


