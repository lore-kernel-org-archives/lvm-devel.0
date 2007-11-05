From: agk@sourceware.org <agk@sourceware.org>
Date: 5 Nov 2007 17:13:55 -0000
Subject: LVM2/lib/display display.c
Message-ID: <20071105171355.10622.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2007-11-05 17:13:54

Modified files:
	lib/display    : display.c 

Log message:
	attempt to fix human-readable unit output when number of sectors is odd

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/display/display.c.diff?cvsroot=lvm2&r1=1.81&r2=1.82

--- LVM2/lib/display/display.c	2007/11/05 02:10:39	1.81
+++ LVM2/lib/display/display.c	2007/11/05 17:13:54	1.82
@@ -186,17 +186,17 @@
 		return size_buf;
 	}
 
-	if (s < 10) {
+	size *= UINT64_C(512);
+
+	if (s < 10)
 		byte = cmd->current_settings.unit_factor;
-		size *= UINT64_C(512);
-	} else {
-		size /= 2;
+	else {
 		suffix = 1;
 		if (cmd->current_settings.unit_type == 'H')
 			units = UINT64_C(1000);
 		else
 			units = UINT64_C(1024);
-		byte = units * units * units * units * units;
+		byte = units * units * units * units * units * units;
 		s = 0;
 		while (size_str[s] && size < byte)
 			s++, byte /= units;


