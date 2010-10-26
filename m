From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 26 Oct 2010 10:14:42 -0000
Subject: LVM2/daemons/cmirrord functions.c
Message-ID: <20101026101442.23189.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-10-26 10:14:41

Modified files:
	daemons/cmirrord: functions.c 

Log message:
	Add missing return for NULL passed buffer
	
	Function pull_stateo() checks for NULL 'buf' - but return for this error
	path was missing.  cmirror code never calls this function with NULL 'buf',
	so this fix has no effect on current code base, but makes clang happier.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/cmirrord/functions.c.diff?cvsroot=lvm2&r1=1.24&r2=1.25

--- LVM2/daemons/cmirrord/functions.c	2010/08/30 18:37:42	1.24
+++ LVM2/daemons/cmirrord/functions.c	2010/10/26 10:14:41	1.25
@@ -1809,8 +1809,10 @@
 	int bitset_size;
 	struct log_c *lc;
 
-	if (!buf)
+	if (!buf) {
 		LOG_ERROR("pull_state: buf == NULL");
+		return -EINVAL;
+	}
 
 	lc = get_log(uuid, luid);
 	if (!lc) {


