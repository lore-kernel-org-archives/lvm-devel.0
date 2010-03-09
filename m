From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 9 Mar 2010 10:25:51 -0000
Subject: LVM2/lib/mm memlock.c
Message-ID: <20100309102551.1173.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-03-09 10:25:50

Modified files:
	lib/mm         : memlock.c 

Log message:
	Update comments for selecting maps
	Use dm_snprintf and check result whether we create correct /proc path name

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/mm/memlock.c.diff?cvsroot=lvm2&r1=1.20&r2=1.21

--- LVM2/lib/mm/memlock.c	2010/03/09 03:16:11	1.20
+++ LVM2/lib/mm/memlock.c	2010/03/09 10:25:50	1.21
@@ -78,7 +78,7 @@
 static unsigned _use_mlockall;
 static FILE *_mapsh;
 static char _procselfmaps[PATH_MAX] = "";
-static const char _selfmaps[] = "/self/maps";
+#define SELF_MAPS "/self/maps"
 
 struct maps_stats {
 	size_t r_size;
@@ -140,7 +140,7 @@
 		return 0;
 	}
 
-	/* skip  ---p,  select with r,w,x */
+	/* Select readable maps */
 	if (fr != 'r')
 		return 1;
 
@@ -244,13 +244,14 @@
 	_use_mlockall = find_config_tree_bool(cmd, "activation/use_mlockall", DEFAULT_USE_MLOCKALL);
 
 	if (!_use_mlockall) {
-		/* Initialise static variables first time */
+		/* Reset statistic counters */
 		memset(&_mstats, 0, sizeof(_mstats));
 
-		if (!*_procselfmaps) {
-			_procselfmaps[PATH_MAX - 1] = '\0';
-			strncpy(_procselfmaps, cmd->proc_dir, PATH_MAX - 1);
-			strncat(_procselfmaps, _selfmaps, PATH_MAX - 1);
+		if (!*_procselfmaps &&
+		    dm_snprintf(_procselfmaps, sizeof(_procselfmaps),
+				"%s" SELF_MAPS, cmd->proc_dir) < 0) {
+			log_error("proc_dir too long");
+			return;
 		}
 
 		if (!(_mapsh = fopen(_procselfmaps, "r"))) {


