From: agk@sourceware.org <agk@sourceware.org>
Date: 9 Mar 2010 12:31:53 -0000
Subject: LVM2/lib/mm memlock.c
Message-ID: <20100309123153.15850.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-03-09 12:31:52

Modified files:
	lib/mm         : memlock.c 

Log message:
	some missing debug messages

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/mm/memlock.c.diff?cvsroot=lvm2&r1=1.21&r2=1.22

--- LVM2/lib/mm/memlock.c	2010/03/09 10:25:50	1.21
+++ LVM2/lib/mm/memlock.c	2010/03/09 12:31:51	1.22
@@ -141,13 +141,18 @@
 	}
 
 	/* Select readable maps */
-	if (fr != 'r')
+	if (fr != 'r') {
+		log_debug("mlock area unreadable '%s': Skipping.", line);
 		return 1;
+	}
 
 	/* always ignored areas */
 	for (i = 0; i < sizeof(_ignore_maps) / sizeof(_ignore_maps[0]); ++i)
-		if (strstr(line + pos, _ignore_maps[i]))
+		if (strstr(line + pos, _ignore_maps[i])) {
+			log_debug("mlock ignore filter '%s' matches '%s': Skipping.",
+				  _ignore_maps[i], line);
 			return 1;
+		}
 
 	sz = to - from;
 	if (!(cn = find_config_tree_node(cmd, "activation/mlock_filter"))) {


