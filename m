From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 23 Feb 2012 22:30:22 -0000
Subject: LVM2 ./WHATS_NEW lib/mirror/mirrored.c
Message-ID: <20120223223022.9889.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-02-23 22:30:20

Modified files:
	.              : WHATS_NEW 
	lib/mirror     : mirrored.c 

Log message:
	Use same signed numbers
	
	Keep unsigned aritmetic.
	
	TODO: we should probably switch dm_split_words() to return unsigned numbers.
	(minor API libdm change mostly compatible)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2306&r2=1.2307
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/mirror/mirrored.c.diff?cvsroot=lvm2&r1=1.95&r2=1.96

--- LVM2/WHATS_NEW	2012/02/23 18:26:28	1.2306
+++ LVM2/WHATS_NEW	2012/02/23 22:30:20	1.2307
@@ -1,5 +1,6 @@
 Version 2.02.94 - 
 ====================================
+  Use same signed numbers in _mirrored_transient_status().
   Integrate client-side lvmetad into build.
 
 Version 2.02.93 - 23rd February 2012
--- LVM2/lib/mirror/mirrored.c	2012/02/23 22:24:47	1.95
+++ LVM2/lib/mirror/mirrored.c	2012/02/23 22:30:20	1.96
@@ -226,14 +226,14 @@
 
 static int _mirrored_transient_status(struct lv_segment *seg, char *params)
 {
-	int i, j;
+	unsigned i, j;
 	struct logical_volume *lv = seg->lv;
 	struct lvinfo info;
 	char *p = NULL;
 	char **args, **log_args;
 	struct logical_volume **images;
 	struct logical_volume *log;
-	int num_devs, log_argc;
+	unsigned num_devs, log_argc;
 	int failed = 0;
 	char *status;
 
@@ -243,12 +243,12 @@
 	if (!dm_split_words(params, 1, 0, &p))
 		return_0;
 
-	if (!(num_devs = atoi(p)))
+	if (!(num_devs = (unsigned) atoi(p)))
 		return_0;
 
 	p += strlen(p) + 1;
 
-	if (num_devs > DEFAULT_MIRROR_MAX_IMAGES || num_devs < 0) {
+	if (num_devs > DEFAULT_MIRROR_MAX_IMAGES) {
 		log_error("Unexpectedly many (%d) mirror images in %s.",
 			  num_devs, lv->name);
 		return 0;
@@ -257,12 +257,13 @@
 	args = alloca((num_devs + 5) * sizeof(char *));
 	images = alloca(num_devs * sizeof(struct logical_volume *));
 
-	if (dm_split_words(p, num_devs + 4, 0, args) < num_devs + 4)
+	/* FIXME: dm_split_words()  should return unsigned */
+	if ((unsigned)dm_split_words(p, num_devs + 4, 0, args) < num_devs + 4)
 		return_0;
 
-	log_argc = atoi(args[3 + num_devs]);
+	log_argc = (unsigned) atoi(args[3 + num_devs]);
 
-	if (log_argc > 16 || log_argc < 0) {
+	if (log_argc > 16) {
 		log_error("Unexpectedly many (%d) log arguments in %s.",
 			  log_argc, lv->name);
 		return 0;
@@ -270,8 +271,8 @@
 
 	log_args = alloca(log_argc * sizeof(char *));
 
-	if (dm_split_words(args[3 + num_devs] + strlen(args[3 + num_devs]) + 1,
-			   log_argc, 0, log_args) < log_argc)
+	if ((unsigned)dm_split_words(args[3 + num_devs] + strlen(args[3 + num_devs]) + 1,
+				     log_argc, 0, log_args) < log_argc)
 		return_0;
 
 	if (num_devs != seg->area_count) {


