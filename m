From: fabbione@sourceware.org <fabbione@sourceware.org>
Date: 14 Oct 2009 04:10:42 -0000
Subject: LVM2 WHATS_NEW configure configure.in
Message-ID: <20091014041042.28270.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	fabbione at sourceware.org	2009-10-14 04:10:41

Modified files:
	.              : WHATS_NEW configure configure.in 

Log message:
	configure.in: don't set default file owner and group
	
	Per discussion on lvm-devel mailing list and part of debian patch set,
	don't set defaults for owner and group, since nobody seems to use them, and
	still allow override.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1295&r2=1.1296
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.diff?cvsroot=lvm2&r1=1.111&r2=1.112
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.in.diff?cvsroot=lvm2&r1=1.119&r2=1.120

--- LVM2/WHATS_NEW	2009/10/13 02:35:26	1.1295
+++ LVM2/WHATS_NEW	2009/10/14 04:10:41	1.1296
@@ -1,5 +1,6 @@
 Version 2.02.54 -
 =====================================
+  Set default owner and group to null.
   Add dmeventd.static to the build.
   Disable realtime support code by default.
   Make clvmd return 0 on success rather than 1.
--- LVM2/configure	2009/10/12 16:59:20	1.111
+++ LVM2/configure	2009/10/14 04:10:41	1.112
@@ -1531,8 +1531,8 @@
 Optional Packages:
   --with-PACKAGE[=ARG]    use PACKAGE [ARG=yes]
   --without-PACKAGE       do not use PACKAGE (same as --with-PACKAGE=no)
-  --with-user=USER        Set the owner of installed files [USER=root]
-  --with-group=GROUP      Set the group owner of installed files [GROUP=root]
+  --with-user=USER        Set the owner of installed files [USER=]
+  --with-group=GROUP      Set the group owner of installed files [GROUP=]
   --with-device-uid=UID   Set the owner used for new device nodes [UID=0]
   --with-device-gid=UID   Set the group used for new device nodes [GID=0]
   --with-device-mode=MODE Set the mode used for new device nodes [MODE=0600]
@@ -9078,7 +9078,7 @@
 ################################################################################
 { $as_echo "$as_me:$LINENO: checking file owner" >&5
 $as_echo_n "checking file owner... " >&6; }
-OWNER="root"
+OWNER=""
 
 
 # Check whether --with-user was given.
@@ -9096,7 +9096,7 @@
 ################################################################################
 { $as_echo "$as_me:$LINENO: checking group owner" >&5
 $as_echo_n "checking group owner... " >&6; }
-GROUP="root"
+GROUP=""
 
 # Check whether --with-group was given.
 if test "${with_group+set}" = set; then
--- LVM2/configure.in	2009/10/12 16:59:20	1.119
+++ LVM2/configure.in	2009/10/14 04:10:41	1.120
@@ -144,10 +144,10 @@
 ################################################################################
 dnl -- Setup the ownership of the files
 AC_MSG_CHECKING(file owner)
-OWNER="root"
+OWNER=""
 
 AC_ARG_WITH(user,
-  [  --with-user=USER        Set the owner of installed files [[USER=root]] ],
+  [  --with-user=USER        Set the owner of installed files [[USER=]] ],
   [ OWNER="$withval" ])
 AC_MSG_RESULT($OWNER)
 
@@ -158,9 +158,9 @@
 ################################################################################
 dnl -- Setup the group ownership of the files
 AC_MSG_CHECKING(group owner)
-GROUP="root"
+GROUP=""
 AC_ARG_WITH(group,
-  [  --with-group=GROUP      Set the group owner of installed files [[GROUP=root]] ],
+  [  --with-group=GROUP      Set the group owner of installed files [[GROUP=]] ],
   [ GROUP="$withval" ])
 AC_MSG_RESULT($GROUP)
 


