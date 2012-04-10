From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 10 Apr 2012 23:34:42 -0000
Subject: LVM2 ./WHATS_NEW daemons/dmeventd/plugins/lvm2 ...
Message-ID: <20120410233442.27068.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2012-04-10 23:34:41

Modified files:
	.              : WHATS_NEW 
	daemons/dmeventd/plugins/lvm2: dmeventd_lvm.c 

Log message:
	Commit ID 46a75dedb4f6aa815a804f27cafbd3fd16a62011 consolidated code from the
	various dmeventd plug-ins into a new function called 'dmeventd_lvm2_command',
	but the new function did not strip off the "_mlog" extentions that the
	mirror plug-in had been doing.  This created bug 794904 - failure to replace
	devices in a redundant log.
	
	The test suite did catch this scenario because it performs repair tests (mainly)
	through the CLI and not dmeventd.  It's also not easy to test because the test
	itself will hang if the bug is encountered.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2375&r2=1.2376
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/plugins/lvm2/dmeventd_lvm.c.diff?cvsroot=lvm2&r1=1.8&r2=1.9

--- LVM2/WHATS_NEW	2012/03/30 14:59:35	1.2375
+++ LVM2/WHATS_NEW	2012/04/10 23:34:41	1.2376
@@ -1,5 +1,6 @@
 Version 2.02.96 - 
 ================================
+  Fix ability to handle failures in mirrored log (regression intro 2.02.89).
   Fix unlocking volume group in vgreduce in error path.
   Exit immediately if LISTEN_PID env var incorrect during systemd handover.
   Detect VG name being part of the LV name in lvconvert --splitmirrors -n.
--- LVM2/daemons/dmeventd/plugins/lvm2/dmeventd_lvm.c	2012/02/01 20:11:58	1.8
+++ LVM2/daemons/dmeventd/plugins/lvm2/dmeventd_lvm.c	2012/04/10 23:34:41	1.9
@@ -160,6 +160,11 @@
 		return 0;
 	}
 
+	/* strip off the mirror component designations */
+	layer = strstr(lv, "_mlog");
+	if (layer)
+		*layer = '\0';
+
 	r = dm_snprintf(buffer, size, "%s %s/%s", cmd, vg, lv);
 
 	dm_pool_free(mem, vg);


