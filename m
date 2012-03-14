From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 14 Mar 2012 19:25:05 -0000
Subject: LVM2 configure configure.in
Message-ID: <20120314192505.2185.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-03-14 19:25:05

Modified files:
	.              : configure configure.in 

Log message:
	Update configure change
	
	Always define THIN_CHECK_CMD define - since for now we compile thin code
	in more places.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.diff?cvsroot=lvm2&r1=1.176&r2=1.177
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.in.diff?cvsroot=lvm2&r1=1.191&r2=1.192

--- LVM2/configure	2012/03/14 17:09:00	1.176
+++ LVM2/configure	2012/03/14 19:25:04	1.177
@@ -7064,14 +7064,14 @@
 
 		test -z "$THIN_CHECK_CMD" && as_fn_error $? "thin_check not found in path $PATH" "$LINENO" 5
 	fi
+	;;
+esac
 
 
 cat >>confdefs.h <<_ACEOF
 #define THIN_CHECK_CMD "$THIN_CHECK_CMD"
 _ACEOF
 
-	;;
-esac
 
 
 ################################################################################
--- LVM2/configure.in	2012/03/14 17:09:00	1.191
+++ LVM2/configure.in	2012/03/14 19:25:04	1.192
@@ -422,12 +422,12 @@
 		AC_PATH_PROG(THIN_CHECK_CMD, thin_check)
 		test -z "$THIN_CHECK_CMD" && AC_MSG_ERROR(thin_check not found in path $PATH)
 	fi
-
-	AC_DEFINE_UNQUOTED([THIN_CHECK_CMD], ["$THIN_CHECK_CMD"],
-			   [The path to 'thin_check', if available.])
 	;;
 esac
 
+AC_DEFINE_UNQUOTED([THIN_CHECK_CMD], ["$THIN_CHECK_CMD"],
+		   [The path to 'thin_check', if available.])
+
 
 ################################################################################
 dnl -- Disable readline


