From: meyering@sourceware.org <meyering@sourceware.org>
Date: 21 Sep 2007 18:43:55 -0000
Subject: LVM2/tools lvmcmdline.c
Message-ID: <20070921184355.14469.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	meyering at sourceware.org	2007-09-21 18:43:55

Modified files:
	tools          : lvmcmdline.c 

Log message:
	Don't emit a trailing newline to stderr.
	
	* tools/lvmcmdline.c (_short_usage): Remove trailing "\n".
	Spotted by Alasdair G. Kergon.
	
	Author: Jim Meyering <jim@meyering.net>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmcmdline.c.diff?cvsroot=lvm2&r1=1.51&r2=1.52

--- LVM2/tools/lvmcmdline.c	2007/09/21 18:06:56	1.51
+++ LVM2/tools/lvmcmdline.c	2007/09/21 18:43:55	1.52
@@ -468,7 +468,7 @@
 
 static void _short_usage(const char *name)
 {
-	log_error("Run `%s --help' for more information.\n", name);
+	log_error("Run `%s --help' for more information.", name);
 }
 
 static void _usage(const char *name)


