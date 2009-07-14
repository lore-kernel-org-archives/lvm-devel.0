From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 14 Jul 2009 12:17:15 -0000
Subject: LVM2 ./WHATS_NEW lib/commands/toolcontext.c
Message-ID: <20090714121715.5020.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-07-14 12:17:15

Modified files:
	.              : WHATS_NEW 
	lib/commands   : toolcontext.c 

Log message:
	Enable use of new multi-segment registration for static registration too.
	
	so it allows this use:
	
	#ifdef MYNEWSEG_INTERNAL
	if (!init_mynewseg_segtypes(&seglib))
	return 0;
	#endif

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1182&r2=1.1183
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.c.diff?cvsroot=lvm2&r1=1.78&r2=1.79

--- LVM2/WHATS_NEW	2009/07/14 11:01:26	1.1182
+++ LVM2/WHATS_NEW	2009/07/14 12:17:14	1.1183
@@ -1,5 +1,6 @@
 Version 2.02.49 - 
 ================================
+  Enable use of new multi-segment registration for static registration too.
   Exclude VG_GLOBAL from vg_write_lock_held so scans open devs read-only again.
   Add unit test case for liblvm VG create/delete APIs.
   Add liblvm APIs to implement creation and deletion of VGs.
--- LVM2/lib/commands/toolcontext.c	2009/07/08 18:12:08	1.78
+++ LVM2/lib/commands/toolcontext.c	2009/07/14 12:17:15	1.79
@@ -855,10 +855,10 @@
 static int _init_segtypes(struct cmd_context *cmd)
 {
 	struct segment_type *segtype;
+	struct segtype_library seglib = { .cmd = cmd };
 
 #ifdef HAVE_LIBDL
 	const struct config_node *cn;
-	struct segtype_library seglib;
 #endif
 
 	if (!(segtype = init_striped_segtype(cmd)))


