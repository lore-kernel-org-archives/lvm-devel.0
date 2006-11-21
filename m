From: agk@sourceware.org <agk@sourceware.org>
Date: 21 Nov 2006 15:13:36 -0000
Subject: LVM2/lib/config config.c
Message-ID: <20061121151336.6721.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2006-11-21 15:13:36

Modified files:
	lib/config     : config.c 

Log message:
	fix _find_config_node: null parameter is permitted

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/config.c.diff?cvsroot=lvm2&r1=1.49&r2=1.50

--- LVM2/lib/config/config.c	2006/11/16 17:36:00	1.49
+++ LVM2/lib/config/config.c	2006/11/21 15:13:36	1.50
@@ -772,7 +772,7 @@
 					     const char *path)
 {
 	const char *e;
-	const struct config_node *cn_found;
+	const struct config_node *cn_found = NULL;
 
 	while (cn) {
 		/* trim any leading slashes */


