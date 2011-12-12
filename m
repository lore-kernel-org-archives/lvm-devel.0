From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 12 Dec 2011 00:01:13 -0000
Subject: LVM2/test/lib aux.sh
Message-ID: <20111212000113.16730.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2011-12-12 00:01:13

Modified files:
	test/lib       : aux.sh 

Log message:
	Use a more canonic regex escaping in the default lvm.conf file for testing.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/lib/aux.sh.diff?cvsroot=lvm2&r1=1.34&r2=1.35

--- LVM2/test/lib/aux.sh	2011/11/10 12:44:00	1.34
+++ LVM2/test/lib/aux.sh	2011/12/12 00:01:12	1.35
@@ -380,7 +380,7 @@
         cat > CONFIG_VALUES <<-EOF
 devices/dir = "$DM_DEV_DIR"
 devices/scan = "$DM_DEV_DIR"
-devices/filter = [ "a/dev\/mirror/", "a/dev\/mapper\/.*pv[0-9_]*$/", "r/.*/" ]
+devices/filter = [ "a/dev\\\\/mirror/", "a/dev\\\\/mapper\\\\/.*pv[0-9_]*$/", "r/.*/" ]
 devices/cache_dir = "$TESTDIR/etc"
 devices/sysfs_scan = 0
 devices/default_data_alignment = 1


