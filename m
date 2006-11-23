From: agk@sourceware.org <agk@sourceware.org>
Date: 23 Nov 2006 17:23:14 -0000
Subject: LVM2 ./WHATS_NEW scripts/lvm_dump.sh
Message-ID: <20061123172314.32465.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2006-11-23 17:23:14

Modified files:
	.              : WHATS_NEW 
	scripts        : lvm_dump.sh 

Log message:
	Improve lvm_dump.sh robustness.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.506&r2=1.507
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/lvm_dump.sh.diff?cvsroot=lvm2&r1=1.2&r2=1.3

--- LVM2/WHATS_NEW	2006/11/21 22:41:55	1.506
+++ LVM2/WHATS_NEW	2006/11/23 17:23:14	1.507
@@ -1,5 +1,6 @@
 Version 2.02.16 -
 ====================================
+  Improve lvm_dump.sh robustness.
   Update lvm2create_initrd to support gentoo.
 
 Version 2.02.15 - 21st November 2006
--- LVM2/scripts/lvm_dump.sh	2006/11/16 16:44:48	1.2
+++ LVM2/scripts/lvm_dump.sh	2006/11/23 17:23:14	1.3
@@ -1,8 +1,41 @@
 #!/bin/bash
-#
+# we use some bash-isms (getopts?)
+
 # lvm_dump: This script is used to collect pertinent information for
 #           the debugging of lvm issues.
-#
+
+# following external commands are used throughout the script
+# which, echo and test are internal in bash at least
+MKDIR=mkdir # need -p
+TAR=tar # need czf
+RM=rm # need -rf
+CP=cp
+TAIL=tail # we need -n
+LS=ls # need -la
+PS=ps # need alx
+SED=sed
+DD=dd
+CUT=cut
+DATE=date
+BASENAME=basename
+
+# user may override lvm and dmsetup location by setting LVM_BINARY
+# and DMSETUP_BINARY respectively
+LVM=${LVM_BINARY-lvm}
+DMSETUP=${DMSETUP_BINARY-dmsetup}
+
+die() {
+    code=$1; shift
+    echo "$@" 1>&2
+    exit $code
+}
+
+# which should error out if the binary is not executable, although i
+# am not sure we can rely on this
+which $LVM >& /dev/null || die 2 "Fatal: could not find lvm binary '$LVM'"
+test -x `which $LVM` || die 2 "Fatal: lvm binary '$LVM' not executable"
+which $DMSETUP >& /dev/null || die 2 "Fatal: could not find dmsetup binary '$DMSETUP'"
+test -x `which $DMSETUP` || die 2 "Fatal: dmsetup binary '$DMSETUP' not executable"
 
 function usage {
 	echo "$0 [options]"
@@ -34,23 +67,16 @@
 	esac
 done
 
-DATE=`/bin/date -u +%G%m%d%k%M%S | /usr/bin/tr -d ' '`
+NOW=`$DATE -u +%G%m%d%k%M%S | /usr/bin/tr -d ' '`
 if test -n "$userdir"; then
 	dir="$userdir"
 else
-	dirbase="lvmdump-$HOSTNAME-$DATE"
+	dirbase="lvmdump-$HOSTNAME-$NOW"
 	dir="$HOME/$dirbase"
 fi
 
-if test -e $dir; then
-	echo $dir already exists, aborting >&2
-	exit 2
-fi
-
-if ! mkdir -p $dir; then
-	echo Could not create $dir >&2
-	exit 3
-fi
+test -e $dir && die 3 "Fatal: $dir already exists"
+$MKDIR -p $dir || die 4 "Fatal: could not create $dir"
 
 log="$dir/lvmdump.log"
 
@@ -72,19 +98,19 @@
 	myecho "Gathering LVM volume info..."
 
 	myecho "  vgscan..."
-	log "vgscan -vvvv > $dir/vgscan 2>&1"
+	log "$LVM vgscan -vvvv > $dir/vgscan 2>&1"
 
 	myecho "  pvscan..."
-	log "pvscan -v >> $dir/pvscan 2>> $log"
+	log "$LVM pvscan -v >> $dir/pvscan 2>> $log"
 
 	myecho "  lvs..."
-	log "lvs -a -o +devices >> $dir/lvs 2>> $log"
+	log "$LVM lvs -a -o +devices >> $dir/lvs 2>> $log"
 
 	myecho "  pvs..."
-	log "pvs -a -v > $dir/pvs 2>> $log"
+	log "$LVM pvs -a -v > $dir/pvs 2>> $log"
 
 	echo "  vgs..."
-	log "vgs -v > $dir/vgs 2>> $log"
+	log "$LVM vgs -v > $dir/vgs 2>> $log"
 fi
 
 if (( $clustered )); then
@@ -102,41 +128,42 @@
 
 myecho "Gathering LVM & device-mapper version info..."
 echo "LVM VERSION:" > $dir/versions
-lvs --version >> $dir/versions 2>> $log
+$LVM lvs --version >> $dir/versions 2>> $log
 echo "DEVICE MAPPER VERSION:" >> $dir/versions
-dmsetup --version >> $dir/versions 2>> $log
+$DMSETUP --version >> $dir/versions 2>> $log
 
 myecho "Gathering dmsetup info..."
-log "dmsetup info -c > $dir/dmsetup_info 2>> $log"
-log "dmsetup table > $dir/dmsetup_table 2>> $log"
-log "dmsetup status > $dir/dmsetup_status 2>> $log"
+log "$DMSETUP info -c > $dir/dmsetup_info 2>> $log"
+log "$DMSETUP table > $dir/dmsetup_table 2>> $log"
+log "$DMSETUP status > $dir/dmsetup_status 2>> $log"
 
 myecho "Gathering process info..."
-log "ps alx > $dir/ps_info 2>> $log"
+log "$PS alx > $dir/ps_info 2>> $log"
 
 myecho "Gathering console messages..."
-log "tail -n 75 /var/log/messages > $dir/messages 2>> $log"
+log "$TAIL -n 75 /var/log/messages > $dir/messages 2>> $log"
 
 myecho "Gathering /etc/lvm info..."
-log "cp -a /etc/lvm $dir/lvm 2>> $log"
+log "$CP -a /etc/lvm $dir/lvm 2>> $log"
 
 myecho "Gathering /dev listing..."
-log "ls -la /dev > $dir/dev_listing 2>> $log"
+log "$LS -la /dev > $dir/dev_listing 2>> $log"
 
 if (( $metadata )); then
 	myecho "Gathering LVM metadata from Physical Volumes..."
 
-	log "mkdir -p $dir/metadata"
+	log "$MKDIR -p $dir/metadata"
 
-	pvs="$(pvs --separator , --noheadings --units s --nosuffix -o name,pe_start 2>> $log | \
-		sed -e 's/^ *//')"
+	pvs="$($LVM pvs --separator , --noheadings --units s --nosuffix -o \
+	    name,pe_start 2>> $log | $SED -e 's/^ *//')"
 	for line in "$pvs"
 	do
-		pv="$(echo $line | cut -d, -f1)"
-		pe_start="$(echo $line | cut -d, -f2)"
-		name="$(basename $pv)"
+		test -z "$line" && continue
+		pv="$(echo $line | $CUT -d, -f1)"
+		pe_start="$(echo $line | $CUT -d, -f2)"
+		name="$($BASENAME $pv)"
 		myecho "  $pv"
-		log "dd if=$pv of=$dir/metadata/$name bs=512 count=$pe_start 2>> $log"
+		log "$DD if=$pv of=$dir/metadata/$name bs=512 count=$pe_start 2>> $log"
 	done
 fi
 
@@ -144,8 +171,14 @@
 	lvm_dump="$dirbase.tgz"
 	myecho "Creating report tarball in $HOME/$lvm_dump..."
 	cd $HOME
-	tar czf $lvm_dump $dirbase 2>/dev/null
-	rm -rf $dir
+	$TAR czf $lvm_dump $dirbase 2>/dev/null
+	$RM -rf $dir
+fi
+
+if test "$UID" != "0" && test "$EUID" != "0"; then
+	myecho
+	myecho "WARNING! Running as non-privileged user, dump is likely incomplete!"
+	myecho
 fi
 
 exit 0


