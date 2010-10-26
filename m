From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 26 Oct 2010 08:53:25 -0000
Subject: LVM2/lib/log log.c
Message-ID: <20101026085325.8197.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-10-26 08:53:25

Modified files:
	lib/log        : log.c 

Log message:
	Remove bufused for calculation
	
	As bufused is assigned 0 in preceding source line
	clang Idempotent operation

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/log/log.c.diff?cvsroot=lvm2&r1=1.59&r2=1.60

--- LVM2/lib/log/log.c	2010/05/05 22:37:53	1.59
+++ LVM2/lib/log/log.c	2010/10/26 08:53:25	1.60
@@ -359,7 +359,7 @@
 		_already_logging = 1;
 		memset(&buf, ' ', sizeof(buf));
 		bufused = 0;
-		if ((n = dm_snprintf(buf, sizeof(buf) - bufused - 1,
+		if ((n = dm_snprintf(buf, sizeof(buf) - 1,
 				      "%s:%d %s%s", file, line, log_command_name(),
 				      _msg_prefix)) == -1)
 			goto done;


