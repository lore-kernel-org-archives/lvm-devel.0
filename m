From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 28 Jun 2011 21:28:35 -0000
Subject: LVM2/tools lvconvert.c
Message-ID: <20110628212835.24252.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2011-06-28 21:28:35

Modified files:
	tools          : lvconvert.c 

Log message:
	Remove unnecesary conditional.
	
	The conditional is not just unnecessary, it would have been wrong.  The code
	is suppose to be checking if the 'splitmirrors_ARG' is negative, but it
	instead is checking 'mirrors_ARG'.  Rather than changing the argument being
	checked, I've pulled the check entirely because 'splitmirrors_ARG' is already
	guarenteed to not be negative by virtue of the fact that it is a 'int_arg'.
	Negative values will be caught in _process_command_line().

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.163&r2=1.164

--- LVM2/tools/lvconvert.c	2011/06/01 12:24:16	1.163
+++ LVM2/tools/lvconvert.c	2011/06/28 21:28:35	1.164
@@ -169,11 +169,6 @@
 			return_0;
 
 		lp->keep_mimages = 1;
-		if (arg_sign_value(cmd, mirrors_ARG, 0) == SIGN_MINUS) {
-			log_error("Argument to --splitmirrors"
-				  " cannot be negative");
-			return 0;
-		}
 		lp->mirrors = arg_uint_value(cmd, splitmirrors_ARG, 0);
 		lp->mirrors_sign = SIGN_MINUS;
 	} else if (arg_count(cmd, name_ARG)) {


