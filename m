From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 15 Oct 2010 09:48:25 -0000
Subject: LVM2/lib/mm memlock.c
Message-ID: <20101015094825.26746.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-10-15 09:48:23

Modified files:
	lib/mm         : memlock.c 

Log message:
	Speedup memory un/locking
	
	Move the call of find_config_tree_node() from inner loop to outer
	section of maps scanning.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/mm/memlock.c.diff?cvsroot=lvm2&r1=1.30&r2=1.31

--- LVM2/lib/mm/memlock.c	2010/09/30 11:32:41	1.30
+++ LVM2/lib/mm/memlock.c	2010/10/15 09:48:23	1.31
@@ -121,10 +121,9 @@
  * mlock/munlock memory areas from /proc/self/maps
  * format described in kernel/Documentation/filesystem/proc.txt
  */
-static int _maps_line(struct cmd_context *cmd, lvmlock_t lock,
+static int _maps_line(const struct config_node *cn, lvmlock_t lock,
 		      const char* line, size_t* mstats)
 {
-	const struct config_node *cn;
 	struct config_value *cv;
 	long from, to;
 	int pos, i;
@@ -153,7 +152,7 @@
 		}
 
 	sz = to - from;
-	if (!(cn = find_config_tree_node(cmd, "activation/mlock_filter"))) {
+	if (!cn) {
 		/* If no blacklist configured, use an internal set */
 		for (i = 0; i < sizeof(_blacklist_maps) / sizeof(_blacklist_maps[0]); ++i)
 			if (strstr(line + pos, _blacklist_maps[i])) {
@@ -195,6 +194,7 @@
 
 static int _memlock_maps(struct cmd_context *cmd, lvmlock_t lock, size_t *mstats)
 {
+	const struct config_node *cn;
 	char *line, *line_end;
 	size_t len;
 	ssize_t n;
@@ -250,10 +250,11 @@
 	}
 
 	line = _maps_buffer;
+	cn = find_config_tree_node(cmd, "activation/mlock_filter");
 
 	while ((line_end = strchr(line, '\n'))) {
 		*line_end = '\0'; /* remove \n */
-		if (!_maps_line(cmd, lock, line, mstats))
+		if (!_maps_line(cn, lock, line, mstats))
 			ret = 0;
 		line = line_end + 1;
 	}


