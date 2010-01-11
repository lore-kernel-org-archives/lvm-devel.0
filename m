From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 11 Jan 2010 15:59:56 -0000
Subject: LVM2 configure
Message-ID: <20100111155956.20048.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2010-01-11 15:59:55

Modified files:
	.              : configure 

Log message:
	Substitute UDEV_SYNC value for use in the other files and show a warning message when libudev not found and using udev_sync.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.diff?cvsroot=lvm2&r1=1.112&r2=1.113

--- LVM2/configure	2009/10/14 04:10:41	1.112
+++ LVM2/configure	2010/01/11 15:59:54	1.113
@@ -647,6 +647,7 @@
 kerneldir
 interface
 LIB_PTHREAD
+UDEV_SYNC
 UDEV_RULES
 STATIC_LINK
 STATICDIR
@@ -12306,6 +12307,9 @@
 _ACEOF
 
 			LIBS="-ludev $LIBS"
+		else
+			{ $as_echo "$as_me:$LINENO: WARNING: It won't be possible to get udev state. We will assume that udev is not running." >&5
+$as_echo "$as_me: WARNING: It won't be possible to get udev state. We will assume that udev is not running." >&2;}
 		fi
 fi
 
@@ -15525,6 +15529,7 @@
 
 
 
+
 ################################################################################
 ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile doc/Makefile include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/misc/lvm-version.h lib/snapshot/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile scripts/clvmd_init_red_hat scripts/lvm2_monitoring_init_red_hat scripts/Makefile test/Makefile test/api/Makefile tools/Makefile udev/Makefile"
 


