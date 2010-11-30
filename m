From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 30 Nov 2010 23:03:36 -0000
Subject: LVM2 WHATS_NEW
Message-ID: <20101130230336.19443.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2010-11-30 23:03:35

Modified files:
	.              : WHATS_NEW 

Log message:
	What's new.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1818&r2=1.1819

--- LVM2/WHATS_NEW	2010/11/30 22:40:19	1.1818
+++ LVM2/WHATS_NEW	2010/11/30 23:03:35	1.1819
@@ -1,5 +1,6 @@
 Version 2.02.78 - 
 ====================================
+  Avoid misleading warnings in vgextend --restoremissing in certain cases.
   Add error path stack traces for _process_mapper_dir(), _create_and_load_v4().
   Add missing test for failed pool allocation in write_config_node().
   Replace snprintf with dm_snprintf in clvmd-command.c.


