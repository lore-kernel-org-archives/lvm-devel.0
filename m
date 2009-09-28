From: agk@sourceware.org <agk@sourceware.org>
Date: 28 Sep 2009 16:23:48 -0000
Subject: LVM2 ./WHATS_NEW ./configure ./configure.in do ...
Message-ID: <20090928162348.17412.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-09-28 16:23:46

Modified files:
	.              : WHATS_NEW configure configure.in 
	doc            : example.conf 
	lib/commands   : toolcontext.c toolcontext.h 
	lib/config     : defaults.h 
	lib/display    : display.c 
	lib/misc       : configure.h.in 
	lib/striped    : striped.c 

Log message:
	Add global/si_unit_consistency to enable cleaned-up use of units in output.
	Add configure --enable-units-compat to set si_unit_consistency off by default.
	
	Use standard output units for 'PE Size' and 'Stripe size' in pv/lvdisplay.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1273&r2=1.1274
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.diff?cvsroot=lvm2&r1=1.106&r2=1.107
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.in.diff?cvsroot=lvm2&r1=1.114&r2=1.115
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/doc/example.conf.diff?cvsroot=lvm2&r1=1.49&r2=1.50
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.c.diff?cvsroot=lvm2&r1=1.84&r2=1.85
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.h.diff?cvsroot=lvm2&r1=1.33&r2=1.34
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/defaults.h.diff?cvsroot=lvm2&r1=1.51&r2=1.52
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/display/display.c.diff?cvsroot=lvm2&r1=1.101&r2=1.102
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/configure.h.in.diff?cvsroot=lvm2&r1=1.13&r2=1.14
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/striped/striped.c.diff?cvsroot=lvm2&r1=1.28&r2=1.29

--- LVM2/WHATS_NEW	2009/09/26 00:42:47	1.1273
+++ LVM2/WHATS_NEW	2009/09/28 16:23:44	1.1274
@@ -1,5 +1,8 @@
 Version 2.02.54 -
 =====================================
+  Use standard output units for 'PE Size' and 'Stripe size' in pv/lvdisplay.
+  Add configure --enable-units-compat to set si_unit_consistency off by default.
+  Add global/si_unit_consistency to enable cleaned-up use of units in output.
 
 Version 2.02.53 - 25th September 2009
 =====================================
--- LVM2/configure	2009/09/16 23:22:40	1.106
+++ LVM2/configure	2009/09/28 16:23:45	1.107
@@ -825,6 +825,7 @@
 enable_udev_sync
 enable_udev_rules
 enable_compat
+enable_units_compat
 enable_ioctl
 enable_o_direct
 enable_applib
@@ -1514,6 +1515,8 @@
   --enable-udev_sync      Enable synchronisation with udev processing
   --enable-udev_rules     Install rule files needed for udev synchronisation
   --enable-compat         Enable support for old device-mapper versions
+  --enable-units-compat   Enable output compatibility with old versions that
+                          that don't use KiB-style unit suffixes
   --disable-driver        Disable calls to device-mapper in the kernel
   --disable-o_direct      Disable O_DIRECT
   --enable-applib         Build application library
@@ -12216,6 +12219,23 @@
 
 
 ################################################################################
+# Check whether --enable-units-compat was given.
+if test "${enable_units_compat+set}" = set; then
+  enableval=$enable_units_compat; UNITS_COMPAT=$enableval
+else
+  UNITS_COMPAT=no
+fi
+
+
+if test x$UNITS_COMPAT = xyes; then
+
+cat >>confdefs.h <<\_ACEOF
+#define DEFAULT_SI_UNIT_CONSISTENCY 0
+_ACEOF
+
+fi
+
+################################################################################
 # Check whether --enable-ioctl was given.
 if test "${enable_ioctl+set}" = set; then
   enableval=$enable_ioctl; DM_IOCTLS=$enableval
--- LVM2/configure.in	2009/09/16 23:22:40	1.114
+++ LVM2/configure.in	2009/09/28 16:23:45	1.115
@@ -679,6 +679,17 @@
   DM_COMPAT=$enableval, DM_COMPAT=no)
 
 ################################################################################
+dnl -- Compatible units suffix mode
+AC_ARG_ENABLE(units-compat,
+  [  --enable-units-compat   Enable output compatibility with old versions that
+                          that don't use KiB-style unit suffixes],
+  UNITS_COMPAT=$enableval, UNITS_COMPAT=no)
+
+if test x$UNITS_COMPAT = xyes; then
+	AC_DEFINE([DEFAULT_SI_UNIT_CONSISTENCY], 0, [Define to 0 to reinstate the pre-2.02.54 handling of unit suffixes.])
+fi
+
+################################################################################
 dnl -- Disable ioctl
 AC_ARG_ENABLE(ioctl,   [  --disable-driver        Disable calls to device-mapper in the kernel],
   DM_IOCTLS=$enableval)
--- LVM2/doc/example.conf	2009/09/16 23:48:41	1.49
+++ LVM2/doc/example.conf	2009/09/28 16:23:45	1.50
@@ -236,6 +236,13 @@
     # Default value for --units argument
     units = "h"
 
+    # Since version 2.02.54, the tools distinguish between powers of
+    # 1024 bytes (e.g. KiB, MiB, GiB) and powers of 1000 bytes (e.g.
+    # KB, MB, GB).
+    # If you have scripts that depend on the old behaviour, set this to 0
+    # temporarily until you update them.
+    si_unit_consistency = 1
+
     # Whether or not to communicate with the kernel device-mapper.
     # Set to 0 if you want to use the tools to manipulate LVM metadata 
     # without activating any logical volumes.
--- LVM2/lib/commands/toolcontext.c	2009/08/04 15:36:14	1.84
+++ LVM2/lib/commands/toolcontext.c	2009/09/28 16:23:45	1.85
@@ -293,6 +293,10 @@
 		}
 	}
 
+	cmd->si_unit_consistency = find_config_tree_int(cmd,
+						  "global/si_unit_consistency",
+						  DEFAULT_SI_UNIT_CONSISTENCY);
+
 	return 1;
 }
 
--- LVM2/lib/commands/toolcontext.h	2009/08/04 15:36:14	1.33
+++ LVM2/lib/commands/toolcontext.h	2009/09/28 16:23:45	1.34
@@ -70,6 +70,7 @@
 	unsigned is_long_lived:1;	/* Optimises persistent_filter handling */
 	unsigned handles_missing_pvs:1;
 	unsigned partial_activation:1;
+	unsigned si_unit_consistency:1;
 
 	struct dev_filter *filter;
 	int dump_filter;	/* Dump filter when exiting? */
--- LVM2/lib/config/defaults.h	2009/09/02 14:47:40	1.51
+++ LVM2/lib/config/defaults.h	2009/09/28 16:23:46	1.52
@@ -92,6 +92,10 @@
 #define DEFAULT_SUFFIX 1
 #define DEFAULT_HOSTTAGS 0
 
+#ifndef DEFAULT_SI_UNIT_CONSISTENCY
+#  define DEFAULT_SI_UNIT_CONSISTENCY 1
+#endif
+
 #ifdef DEVMAPPER_SUPPORT
 #  define DEFAULT_ACTIVATION 1
 #  define DEFAULT_RESERVED_MEMORY 8192
--- LVM2/lib/display/display.c	2009/09/15 18:35:14	1.101
+++ LVM2/lib/display/display.c	2009/09/28 16:23:46	1.102
@@ -344,7 +344,12 @@
 	/* LV count is no longer available when displaying PV
 	   log_print("Cur LV                %u", vg->lv_count);
 	 */
-	log_print("PE Size (KByte)       %" PRIu32, pv->pe_size / 2);
+
+	if (cmd->si_unit_consistency)
+		log_print("PE Size               %s", display_size(cmd, (uint64_t) pv->pe_size));
+	else
+		log_print("PE Size (KByte)       %" PRIu32, pv->pe_size / 2);
+
 	log_print("Total PE              %u", pv->pe_count);
 	log_print("Free PE               %" PRIu32, pe_free);
 	log_print("Allocated PE          %u", pv->pe_alloc_count);
@@ -489,7 +494,7 @@
 	log_print("Segments               %u", dm_list_size(&lv->segments));
 
 /********* FIXME Stripes & stripesize for each segment
-	log_print("Stripe size (KByte)    %u", lv->stripesize / 2);
+	log_print("Stripe size            %s", display_size(cmd, (uint64_t) lv->stripesize));
 ***********/
 
 	log_print("Allocation             %s", get_alloc_string(lv->alloc));
--- LVM2/lib/misc/configure.h.in	2009/09/14 22:57:46	1.13
+++ LVM2/lib/misc/configure.h.in	2009/09/28 16:23:46	1.14
@@ -17,6 +17,9 @@
 /* Define to 1 if using `alloca.c'. */
 #undef C_ALLOCA
 
+/* Define to 0 to reinstate the pre-2.02.54 handling of unit suffixes. */
+#undef DEFAULT_SI_UNIT_CONSISTENCY
+
 /* Define to 1 to enable LVM2 device-mapper interaction. */
 #undef DEVMAPPER_SUPPORT
 
--- LVM2/lib/striped/striped.c	2009/07/09 11:29:01	1.28
+++ LVM2/lib/striped/striped.c	2009/09/28 16:23:46	1.29
@@ -40,7 +40,14 @@
 		display_stripe(seg, 0, "  ");
 	else {
 		log_print("  Stripes\t\t%u", seg->area_count);
-		log_print("  Stripe size\t\t%u KB", seg->stripe_size / 2);
+
+		if (seg->lv->vg->cmd->si_unit_consistency)
+			log_print("  Stripe size\t\t%s",
+				  display_size(seg->lv->vg->cmd,
+					       (uint64_t) seg->stripe_size));
+		else
+			log_print("  Stripe size\t\t%u KB",
+				  seg->stripe_size / 2);
 
 		for (s = 0; s < seg->area_count; s++) {
 			log_print("  Stripe %d:", s);


