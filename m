From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 12 Nov 2010 16:04:54 -0000
Subject: LVM2 WHATS_NEW
Message-ID: <20101112160454.29731.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2010-11-12 16:04:53

Modified files:
	.              : WHATS_NEW 

Log message:
	WHATS_NEW FIXME

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1796&r2=1.1797

--- LVM2/WHATS_NEW	2010/11/11 17:29:05	1.1796
+++ LVM2/WHATS_NEW	2010/11/12 16:04:52	1.1797
@@ -3,7 +3,7 @@
   Support repetition of --addtag and --deltag arguments.
   Add infrastructure for specific cmdline arguments to be repeated in groups.
   Split the_args cmdline arguments and values into arg_props and arg_values.
-FIXME??? Fix fsadm need of using '-f' for downsize of unmounted filesystem.
+  Fix fsadm to not require '-f' for resize of unmounted filesystem.
   Fix fsadm to detect mounted filesystems on older systems. (2.0.75)
   Extend cling allocation policy to recognise PV tags (cling_by_tags).
   Add allocation/cling_tag_list to lvm.conf.


