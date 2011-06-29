From: agk@sourceware.org <agk@sourceware.org>
Date: 29 Jun 2011 21:56:47 -0000
Subject: LVM2 ./WHATS_NEW_DM man/dmsetup.8.in test/lib/ ...
Message-ID: <20110629215647.3712.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-06-29 21:56:46

Modified files:
	.              : WHATS_NEW_DM 
	man            : dmsetup.8.in 
	test/lib       : utils.sh 
	tools          : dmsetup.c 

Log message:
	Add age filter to dmsetup udevcomplete_all to minimise concurrency problems.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.475&r2=1.476
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/dmsetup.8.in.diff?cvsroot=lvm2&r1=1.40&r2=1.41
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/lib/utils.sh.diff?cvsroot=lvm2&r1=1.7&r2=1.8
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/dmsetup.c.diff?cvsroot=lvm2&r1=1.162&r2=1.163

--- LVM2/WHATS_NEW_DM	2011/06/27 21:43:58	1.475
+++ LVM2/WHATS_NEW_DM	2011/06/29 21:56:46	1.476
@@ -1,5 +1,6 @@
 Version 1.02.65 - 
 ==================================
+  Add age_in_minutes parameter to dmsetup udevcomplete_all.
   Return immediately from dm_lib_exit() if called more than once.
   Disable udev fallback by default and add --verifyudev option to dmsetup.
   Warn if a table is loaded while a device is known to be in suspended state.
--- LVM2/man/dmsetup.8.in	2011/06/27 21:43:59	1.40
+++ LVM2/man/dmsetup.8.in	2011/06/29 21:56:46	1.41
@@ -80,6 +80,7 @@
 .I cookie
 .br
 .B dmsetup udevcomplete_all
+.I [age_in_minutes]
 .br
 .B dmsetup udevcookies
 .br
@@ -389,8 +390,10 @@
 .br
 Wake any processes that are waiting for udev to complete processing the specified cookie.
 .br
-.IP \fBudevcomplete_all
-Remove all cookies. Any process waiting on a cookie will be resumed immediately.
+.IP \fBudevcomplete_all 
+.I[age_in_minutes]
+Remove all cookies older than the specified number of minutes. 
+Any process waiting on a cookie will be resumed immediately.
 .br
 .IP \fBudevcookies
 List all existing cookies. Cookies are system-wide semaphores with keys
--- LVM2/test/lib/utils.sh	2011/06/29 18:18:18	1.7
+++ LVM2/test/lib/utils.sh	2011/06/29 21:56:46	1.8
@@ -149,7 +149,9 @@
 
 teardown_udev_cookies() {
     if test "$DM_UDEV_SYNCHRONISATION" = 1; then
-	dmsetup udevcomplete_all -y
+	# Delete any cookies created more than 10 minutes ago 
+	# and not used in the last 10 minutes.
+	dmsetup udevcomplete_all -y 10
     fi
 }
 
--- LVM2/tools/dmsetup.c	2011/06/27 21:43:59	1.162
+++ LVM2/tools/dmsetup.c	2011/06/29 21:56:46	1.163
@@ -1085,10 +1085,19 @@
 	struct seminfo sinfo;
 	struct semid_ds sdata;
 	int counter = 0;
+	int skipped = 0;
+	unsigned age = 0;
+	time_t t;
+
+	if (argc == 2 && (sscanf(argv[1], "%i", &age) != 1)) {
+		log_error("Failed to read age_in_minutes parameter.");
+		return 0;
+	}
 
 	if (!_switches[YES_ARG]) {
-		log_warn("This operation will destroy all semaphores with keys "
+		log_warn("This operation will destroy all semaphores %s%.0d%swith keys "
 			 "that have a prefix %" PRIu16 " (0x%" PRIx16 ").",
+			 age ? "older than " : "", age, age ? " minutes " : "",
 			 DM_COOKIE_MAGIC, DM_COOKIE_MAGIC);
 
 		if (_yes_no_prompt("Do you really want to continue? [y/n]: ") == 'n') {
@@ -1109,6 +1118,13 @@
 			continue;
 
 		if (sdata.sem_perm.__key >> 16 == DM_COOKIE_MAGIC) {
+			t = time(NULL);
+
+			if (sdata.sem_ctime + age * 60 > t ||
+			    sdata.sem_otime + age * 60 > t) {
+				skipped++;
+				continue;
+			}
 			if (semctl(sid, 0, IPC_RMID, 0) < 0) {
 				log_error("Could not cleanup notification semaphore "
 					  "with semid %d and cookie value "
@@ -1122,8 +1138,8 @@
 	}
 
 	log_print("%d semaphores with keys prefixed by "
-		  "%" PRIu16 " (0x%" PRIx16 ") destroyed.",
-		  counter, DM_COOKIE_MAGIC, DM_COOKIE_MAGIC);
+		  "%" PRIu16 " (0x%" PRIx16 ") destroyed. %d skipped.",
+		  counter, DM_COOKIE_MAGIC, DM_COOKIE_MAGIC, skipped);
 
 	return 1;
 }
@@ -1134,14 +1150,15 @@
 	struct seminfo sinfo;
 	struct semid_ds sdata;
 	int val;
-	char *time_str;
+	char otime_str[26], ctime_str[26];
+	char *otimes, *ctimes;
 
 	if ((max_id = semctl(0, 0, SEM_INFO, &sinfo)) < 0) {
 		log_sys_error("sem_ctl", "SEM_INFO");
 		return 0;
 	}
 
-	printf("cookie       semid      value      last_semop_time\n");
+	printf("Cookie       Semid      Value      Last semop time           Last change time\n");
 
 	for (id = 0; id <= max_id; id++) {
 		if ((sid = semctl(id, 0, SEM_STAT, &sdata)) < 0)
@@ -1156,10 +1173,14 @@
 				continue;
 			}
 
-			time_str = ctime((const time_t *) &sdata.sem_otime);
-
-			printf("0x%-10x %-10d %-10d %s", sdata.sem_perm.__key,
-				sid, val, time_str ? time_str : "unknown\n");
+			if ((otimes = ctime_r((const time_t *) &sdata.sem_otime, (char *)&otime_str)))
+				otime_str[strlen(otimes)-1] = '\0';
+			if ((ctimes = ctime_r((const time_t *) &sdata.sem_ctime, (char *)&ctime_str)))
+				ctime_str[strlen(ctimes)-1] = '\0';
+
+			printf("0x%-10x %-10d %-10d %s  %s\n", sdata.sem_perm.__key,
+				sid, val, otimes ? : "unknown",
+				ctimes? : "unknown");
 		}
 	}
 
@@ -2728,7 +2749,7 @@
 	{"udevreleasecookie", "[<cookie>]", 0, 1, 0, _udevreleasecookie},
 	{"udevflags", "<cookie>", 1, 1, 0, _udevflags},
 	{"udevcomplete", "<cookie>", 1, 1, 0, _udevcomplete},
-	{"udevcomplete_all", "", 0, 0, 0, _udevcomplete_all},
+	{"udevcomplete_all", "<age_in_minutes>", 0, 1, 0, _udevcomplete_all},
 	{"udevcookies", "", 0, 0, 0, _udevcookies},
 	{"targets", "", 0, 0, 0, _targets},
 	{"version", "", 0, 0, 0, _version},
@@ -2745,7 +2766,7 @@
 	fprintf(out, "dmsetup [--version] [-h|--help [-c|-C|--columns]]\n"
 		"        [-v|--verbose [-v|--verbose ...]]\n"
 		"        [-r|--readonly] [--noopencount] [--nolockfs] [--inactive]\n"
-		"        [--udevcookie] [--noudevrules] [--noudevsync] [--verifyudev]\n"
+		"        [--udevcookie [cookie]] [--noudevrules] [--noudevsync] [--verifyudev]\n"
 		"        [-y|--yes] [--readahead [+]<sectors>|auto|none]\n"
 		"        [-c|-C|--columns] [-o <fields>] [-O|--sort <sort_fields>]\n"
 		"        [--nameprefixes] [--noheadings] [--separator <separator>]\n\n");


