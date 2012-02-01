From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 1 Feb 2012 10:48:22 -0000
Subject: LVM2/lib/mm memlock.c
Message-ID: <20120201104822.32016.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-02-01 10:48:22

Modified files:
	lib/mm         : memlock.c 

Log message:
	Minor consistency update for debugging messages
	
	Use mlock/munlock for debugging lines.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/mm/memlock.c.diff?cvsroot=lvm2&r1=1.49&r2=1.50

--- LVM2/lib/mm/memlock.c	2012/01/25 13:12:59	1.49
+++ LVM2/lib/mm/memlock.c	2012/02/01 10:48:22	1.50
@@ -155,6 +155,7 @@
 	unsigned i;
 	char fr, fw, fx, fp;
 	size_t sz;
+	const char *lock_str = (lock == LVM_MLOCK) ? "mlock" : "munlock";
 
 	if (sscanf(line, "%lx-%lx %c%c%c%c%n",
 		   &from, &to, &fr, &fw, &fx, &fp, &pos) != 6) {
@@ -164,16 +165,15 @@
 
 	/* Select readable maps */
 	if (fr != 'r') {
-		log_debug("%s area unreadable %s : Skipping.",
-			  (lock == LVM_MLOCK) ? "mlock" : "munlock", line);
+		log_debug("%s area unreadable %s : Skipping.", lock_str, line);
 		return 1;
 	}
 
 	/* always ignored areas */
 	for (i = 0; i < sizeof(_ignore_maps) / sizeof(_ignore_maps[0]); ++i)
 		if (strstr(line + pos, _ignore_maps[i])) {
-			log_debug("mlock ignore filter '%s' matches '%s': Skipping.",
-				  _ignore_maps[i], line);
+			log_debug("%s ignore filter '%s' matches '%s': Skipping.",
+				  lock_str, _ignore_maps[i], line);
 			return 1;
 		}
 
@@ -182,8 +182,8 @@
 		/* If no blacklist configured, use an internal set */
 		for (i = 0; i < sizeof(_blacklist_maps) / sizeof(_blacklist_maps[0]); ++i)
 			if (strstr(line + pos, _blacklist_maps[i])) {
-				log_debug("mlock default filter '%s' matches '%s': Skipping.",
-					  _blacklist_maps[i], line);
+				log_debug("%s default filter '%s' matches '%s': Skipping.",
+					  lock_str, _blacklist_maps[i], line);
 				return 1;
 			}
 	} else {
@@ -191,8 +191,8 @@
 			if ((cv->type != DM_CFG_STRING) || !cv->v.str[0])
 				continue;
 			if (strstr(line + pos, cv->v.str)) {
-				log_debug("mlock_filter '%s' matches '%s': Skipping.",
-					  cv->v.str, line);
+				log_debug("%s_filter '%s' matches '%s': Skipping.",
+					  lock_str, cv->v.str, line);
 				return 1;
 			}
 		}
@@ -207,8 +207,7 @@
 
 #endif
 	*mstats += sz;
-	log_debug("%s %10ldKiB %12lx - %12lx %c%c%c%c%s",
-		  (lock == LVM_MLOCK) ? "mlock" : "munlock",
+	log_debug("%s %10ldKiB %12lx - %12lx %c%c%c%c%s", lock_str,
 		  ((long)sz + 1023) / 1024, from, to, fr, fw, fx, fp, line + pos);
 
 	if (lock == LVM_MLOCK) {


