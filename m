From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 23 May 2011 14:46:49 -0000
Subject: LVM2/daemons/lvmetad DESIGN
Message-ID: <20110523144649.7647.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2011-05-23 14:46:49

Modified files:
	daemons/lvmetad: DESIGN 

Log message:
	Mention code layout in lvmetad DESIGN.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/lvmetad/DESIGN.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/daemons/lvmetad/DESIGN	2011/05/12 17:49:46	1.1
+++ LVM2/daemons/lvmetad/DESIGN	2011/05/23 14:46:48	1.2
@@ -184,3 +184,14 @@
 externally, it should be very amenable to automated testing. We need to provide
 a client that can feed arbitrary, synthetic metadata to the daemon and request
 the data back, providing reasonable (nearly unit-level) testing infrastructure.
+
+Battle plan & code layout
+=========================
+
+- config_tree from lib/config needs to move to libdm/
+- daemon/common *client* code can go to libdm/ as well (say
+  libdm/libdm-daemon.{h,c} or such)
+- daemon/common *server* code stays, is built in daemon/ toplevel as a static
+  library, say libdaemon-common.a
+- daemon/lvmetad *client* code goes to lib/lvmetad
+- daemon/lvmetad *server* code stays (links in daemon/libdaemon_common.a)


