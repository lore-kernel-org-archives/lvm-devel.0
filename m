From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 2 Oct 2007 15:48:58 -0000
Subject: LVM2 ./WHATS_NEW scripts/lvm_dump.sh
Message-ID: <20071002154858.24543.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2007-10-02 15:48:58

Modified files:
	.              : WHATS_NEW 
	scripts        : lvm_dump.sh 

Log message:
	Fix a bug in lvm_dump.sh checks for lvm/dmsetup binaries quote the
	invocations a bit more (although i'm fairly sure there are still
	quotes missing somewhere due to the eval in log).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.714&r2=1.715
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/lvm_dump.sh.diff?cvsroot=lvm2&r1=1.9&r2=1.10

--- LVM2/WHATS_NEW	2007/09/24 13:25:31	1.714
+++ LVM2/WHATS_NEW	2007/10/02 15:48:57	1.715
@@ -1,5 +1,6 @@
 Version 2.02.29 -
 ==================================
+  Fix a bug in lvm_dump.sh checks for lvm/dmsetup binaries.
   Refactor lvcreate stripe and mirror parameter validation.
   All tools: print --help output to stdout, not stderr.
   After a diagnostic, suggest --help, rather than printing all --help output.
--- LVM2/scripts/lvm_dump.sh	2007/08/20 20:55:29	1.9
+++ LVM2/scripts/lvm_dump.sh	2007/10/02 15:48:58	1.10
@@ -17,7 +17,7 @@
 #           the debugging of lvm issues.
 
 # following external commands are used throughout the script
-# which, echo and test are internal in bash at least
+# echo and test are internal in bash at least
 MKDIR=mkdir # need -p
 TAR=tar # need czf
 RM=rm # need -rf
@@ -43,12 +43,8 @@
     exit $code
 }
 
-# which should error out if the binary is not executable, although i
-# am not sure we can rely on this
-which $LVM >& /dev/null || die 2 "Fatal: could not find lvm binary '$LVM'"
-test -x `which $LVM` || die 2 "Fatal: lvm binary '$LVM' not executable"
-which $DMSETUP >& /dev/null || die 2 "Fatal: could not find dmsetup binary '$DMSETUP'"
-test -x `which $DMSETUP` || die 2 "Fatal: dmsetup binary '$DMSETUP' not executable"
+"$LVM" version >& /dev/null || die 2 "Could not run lvm binary '$LVM'"
+"$DMSETUP" help >& /dev/null || die 2 "Fatal: could not run dmsetup binary '$DMSETUP'"
 
 function usage {
 	echo "$0 [options]"
@@ -166,13 +162,13 @@
 
 myecho "Gathering LVM & device-mapper version info..."
 echo "LVM VERSION:" > $dir/versions
-$LVM lvs --version >> $dir/versions 2>> $log
+"$LVM" lvs --version >> $dir/versions 2>> $log
 echo "DEVICE MAPPER VERSION:" >> $dir/versions
-$DMSETUP --version >> $dir/versions 2>> $log
+"$DMSETUP" --version >> $dir/versions 2>> $log
 echo "KERNEL VERSION:" >> $dir/versions
-$UNAME -a >> $dir/versions 2>> $log
+"$UNAME" -a >> $dir/versions 2>> $log
 echo "DM TARGETS VERSIONS:" >> $dir/versions
-$DMSETUP targets >> $dir/versions 2>> $log
+"$DMSETUP" targets >> $dir/versions 2>> $log
 
 myecho "Gathering dmsetup info..."
 log "$DMSETUP info -c > $dir/dmsetup_info 2>> $log"
@@ -215,9 +211,9 @@
 if test -z "$userdir"; then
 	lvm_dump="$dirbase.tgz"
 	myecho "Creating report tarball in $HOME/$lvm_dump..."
-	cd $HOME
-	$TAR czf $lvm_dump $dirbase 2>/dev/null
-	$RM -rf $dir
+	cd "$HOME"
+	"$TAR" czf $lvm_dump $dirbase 2>/dev/null
+	"$RM" -rf $dir
 fi
 
 if test "$UID" != "0" && test "$EUID" != "0"; then


