From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 30 Mar 2010 14:41:59 -0000
Subject: LVM2/lib/mm memlock.c
Message-ID: <20100330144159.19588.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-03-30 14:41:58

Modified files:
	lib/mm         : memlock.c 

Log message:
	Count only readable size for memlock stats.
	
	As we mlock() only readable pages, makes statistics only
	for readable bytes.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/mm/memlock.c.diff?cvsroot=lvm2&r1=1.23&r2=1.24

--- LVM2/lib/mm/memlock.c	2010/03/30 14:41:23	1.23
+++ LVM2/lib/mm/memlock.c	2010/03/30 14:41:58	1.24
@@ -80,12 +80,7 @@
 static char _procselfmaps[PATH_MAX] = "";
 #define SELF_MAPS "/self/maps"
 
-struct maps_stats {
-	size_t r_size;
-	size_t w_size;
-	size_t x_size;
-};
-static struct maps_stats _mstats; /* statistic for maps locking */
+static size_t _mstats; /* statistic for maps locking */
 
 static void _touch_memory(void *mem, size_t size)
 {
@@ -125,7 +120,7 @@
  * format described in kernel/Documentation/filesystem/proc.txt
  */
 static int _maps_line(struct cmd_context *cmd, lvmlock_t lock,
-		      const char* line, struct maps_stats* mstats)
+		      const char* line, size_t* mstats)
 {
 	const struct config_node *cn;
 	struct config_value *cv;
@@ -175,13 +170,7 @@
 		}
 	}
 
-	if (fr == 'r')
-		mstats->r_size += sz;
-	if (fw == 'w')
-		mstats->w_size += sz;
-	if (fx == 'x')
-		mstats->x_size += sz;
-
+	*mstats += sz;
 	log_debug("%s %10ldKiB %12lx - %12lx %c%c%c%c %s",
 		  (lock == LVM_MLOCK) ? "mlock" : "munlock",
 		  ((long)sz + 1023) / 1024, from, to, fr, fw, fx, fp, line + pos);
@@ -201,7 +190,7 @@
 	return 1;
 }
 
-static int _memlock_maps(struct cmd_context *cmd, lvmlock_t lock, struct maps_stats *mstats)
+static int _memlock_maps(struct cmd_context *cmd, lvmlock_t lock, size_t *mstats)
 {
 	char *line = NULL;
 	size_t len;
@@ -228,19 +217,18 @@
 	}
 
 	/* Reset statistic counters */
-	memset(mstats, 0, sizeof(*mstats));
+	*mstats = 0;
 	rewind(_mapsh);
 
 	while ((n = getline(&line, &len, _mapsh)) != -1) {
 		line[n > 0 ? n - 1 : 0] = '\0'; /* remove \n */
-		if (!(ret = _maps_line(cmd, lock, line, mstats)))
-			break;
+		if (!_maps_line(cmd, lock, line, mstats))
+                        ret = 0;
 	}
 
 	free(line);
 
-	log_debug("Mapped sizes: r=%ld, w=%ld, x=%ld",
-		  (long)mstats->r_size,  (long)mstats->w_size, (long)mstats->x_size);
+	log_debug("Mapped size: %ld", (long)*mstats);
 
 	return ret;
 }
@@ -288,7 +276,7 @@
 
 static void _unlock_mem(struct cmd_context *cmd)
 {
-	struct maps_stats unlock_mstats;
+	size_t unlock_mstats;
 
 	log_very_verbose("Unlocking memory");
 
@@ -299,10 +287,9 @@
 		if (fclose(_mapsh))
 			log_sys_error("fclose", _procselfmaps);
 
-		if (_mstats.r_size < unlock_mstats.r_size)
-			log_error(INTERNAL_ERROR "Maps lock(%ld,%ld,%ld) < unlock(%ld,%ld,%ld)",
-				  (long)_mstats.r_size, (long)_mstats.w_size, (long)_mstats.x_size,
-				  (long)unlock_mstats.r_size, (long)unlock_mstats.w_size, (long)unlock_mstats.x_size);
+		if (_mstats < unlock_mstats)
+			log_error(INTERNAL_ERROR "Maps lock %ld < unlock %ld",
+				  (long)_mstats, (long)unlock_mstats);
 	}
 
 	if (setpriority(PRIO_PROCESS, 0, _priority))


