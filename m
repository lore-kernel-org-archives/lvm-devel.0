From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 15 Jun 2011 13:29:49 -0000
Subject: LVM2 ./WHATS_NEW liblvm/lvm_base.c
Message-ID: <20110615132949.30137.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2011-06-15 13:29:48

Modified files:
	.              : WHATS_NEW 
	liblvm         : lvm_base.c 

Log message:
	Add proper udev library context initialization and finalization to liblvm.
	
	This was missing in liblvm and it caused all udev-related operations to
	not take effect when using liblvm, e.g. obtaining the list of devices from udev
	db instead of scanning the whole /dev which also recreated the .cache as a side
	effect. This was also the case with udisks-lvm-pv-export prober which is run
	from within udev rules whenever the CHANGE event is fired.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2014&r2=1.2015
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_base.c.diff?cvsroot=lvm2&r1=1.21&r2=1.22

--- LVM2/WHATS_NEW	2011/06/13 22:28:04	1.2014
+++ LVM2/WHATS_NEW	2011/06/15 13:29:48	1.2015
@@ -1,5 +1,6 @@
 Version 2.02.86 -  
 =================================
+  Add proper udev library context initialization and finalization to liblvm.
   Fix last snapshot removal to avoid table reload while a device is suspended.
   Use dm_get_suspended_counter in replacement critical_section logic.
   Downgrade critical_section errors to debug level until it is moved to libdm.
--- LVM2/liblvm/lvm_base.c	2011/05/07 13:50:11	1.21
+++ LVM2/liblvm/lvm_base.c	2011/06/15 13:29:48	1.22
@@ -31,6 +31,9 @@
 	/* FIXME: logging bound to handle
 	 */
 
+	if (!udev_init_library_context())
+		stack;
+
 	/* create context */
 	/* FIXME: split create_toolcontext */
 	/* FIXME: make all globals configurable */
@@ -69,6 +72,7 @@
 void lvm_quit(lvm_t libh)
 {
 	destroy_toolcontext((struct cmd_context *)libh);
+	udev_fin_library_context();
 }
 
 int lvm_config_reload(lvm_t libh)


