From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 16 Sep 2011 12:10:03 -0000
Subject: LVM2 ./WHATS_NEW tools/lvmcmdline.c
Message-ID: <20110916121003.24495.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-09-16 12:10:03

Modified files:
	.              : WHATS_NEW 
	tools          : lvmcmdline.c 

Log message:
	Fix command line option decoding
	
	LVM has huge set of options now - it's approaching 60 short-arg less options
	and we get interesting case of misdetection for 'merge' option which has been
	put into the middle of options with 'short_arg' - thus certainly past 65. (ASCII 'A').
	
	To avoid confusion of short_arg with long_opt number - add  '128' to all such
	non-short-arg options.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2114&r2=1.2115
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmcmdline.c.diff?cvsroot=lvm2&r1=1.147&r2=1.148

--- LVM2/WHATS_NEW	2011/09/16 12:01:48	1.2114
+++ LVM2/WHATS_NEW	2011/09/16 12:10:02	1.2115
@@ -1,5 +1,6 @@
 Version 2.02.89 - 
 ==================================
+  Fix command line option decoding.
   Reset LV status when unlinking LV from VG.
   Fix overly strict extent-count divisibility requirements for striped mirrors.
   Fix rounding direction in lvresize when reducing volume size.
--- LVM2/tools/lvmcmdline.c	2011/09/02 01:32:08	1.147
+++ LVM2/tools/lvmcmdline.c	2011/09/16 12:10:02	1.148
@@ -641,7 +641,7 @@
 		if (a->short_arg)
 			(*o)->val = a->short_arg;
 		else
-			(*o)->val = arg;
+			(*o)->val = arg + 128;
 		(*o)++;
 	}
 #endif
@@ -662,7 +662,7 @@
 		 * the_args.
 		 */
 		if ((a->short_arg && (opt == a->short_arg)) ||
-		    (!a->short_arg && (opt == arg)))
+		    (!a->short_arg && (opt == (arg + 128))))
 			return arg;
 	}
 


