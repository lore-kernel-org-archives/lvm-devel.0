From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 3 Oct 2007 15:00:53 -0000
Subject: LVM2/scripts lvm_dump.sh
Message-ID: <20071003150053.14552.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2007-10-03 15:00:52

Modified files:
	scripts        : lvm_dump.sh 

Log message:
	a) use dmsetup version to check for dmsetup, but if it fails, set
	DMSETUP=: to disable dmsetup checks (but let the script run
	nevertheless); warn the user if this is the case
	b) put the non-root and dmsetup warnings both at start and end of
	output

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/lvm_dump.sh.diff?cvsroot=lvm2&r1=1.11&r2=1.12

--- LVM2/scripts/lvm_dump.sh	2007/10/02 16:09:46	1.11
+++ LVM2/scripts/lvm_dump.sh	2007/10/03 15:00:51	1.12
@@ -44,7 +44,7 @@
 }
 
 "$LVM" version >& /dev/null || die 2 "Could not run lvm binary '$LVM'"
-"$DMSETUP" help >& /dev/null || die 2 "Fatal: could not run dmsetup binary '$DMSETUP'"
+"$DMSETUP" version >& /dev/null || DMSETUP=:
 
 function usage {
 	echo "$0 [options]"
@@ -99,7 +99,16 @@
 	eval "$@"
 }
 
-echo " "
+warnings() {
+	if test "$UID" != "0" && test "$EUID" != "0"; then
+		myecho "WARNING! Running as non-privileged user, dump is likely incomplete!"
+	elif test "$DMSETUP" = ":"; then
+		myecho "WARNING! Could not run dmsetup, dump is likely incomplete."
+	fi
+}
+
+warnings
+
 myecho "Creating dump directory: $dir"
 echo " "
 
@@ -211,16 +220,15 @@
 if test -z "$userdir"; then
 	lvm_dump="$dirbase.tgz"
 	myecho "Creating report tarball in $HOME/$lvm_dump..."
+fi
+
+warnings
+
+if test -z "$userdir"; then
 	cd "$HOME"
 	"$TAR" czf "$lvm_dump" "$dirbase" 2>/dev/null
 	"$RM" -rf "$dir"
 fi
 
-if test "$UID" != "0" && test "$EUID" != "0"; then
-	myecho
-	myecho "WARNING! Running as non-privileged user, dump is likely incomplete!"
-	myecho
-fi
-
 exit 0
 


