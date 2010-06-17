From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 17 Jun 2010 13:15:53 -0000
Subject: LVM2 ./WHATS_NEW tools/reporter.c
Message-ID: <20100617131553.18299.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2010-06-17 13:15:52

Modified files:
	.              : WHATS_NEW 
	tools          : reporter.c 

Log message:
	Fix exit code when requesting help using documented -o help option.
	
	IOW fix lvs -o help
	...
	Command failed with status code 5.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1616&r2=1.1617
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/reporter.c.diff?cvsroot=lvm2&r1=1.60&r2=1.61

--- LVM2/WHATS_NEW	2010/06/17 12:48:54	1.1616
+++ LVM2/WHATS_NEW	2010/06/17 13:15:51	1.1617
@@ -1,5 +1,6 @@
 Version 2.02.68 -
 ===============================
+  Fix exit code when requesting help using documented -o help option.
   Do not use internal DLM lock definitions in generic LVM2 clvmd code.
   Add dmeventd man page.
   Update lvresize/extend/reduce manpages with --nofsck, --resizefs options.
--- LVM2/tools/reporter.c	2010/04/23 19:10:20	1.60
+++ LVM2/tools/reporter.c	2010/06/17 13:15:52	1.61
@@ -362,6 +362,8 @@
 					  separator, aligned, buffered,
 					  headings, field_prefixes, quoted,
 					  columns_as_rows))) {
+		if (!strcasecmp(options, "help") || !strcmp(options, "?"))
+			return r;
 		stack;
 		return ECMD_FAILED;
 	}


