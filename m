From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 2 Oct 2007 16:09:46 -0000
Subject: LVM2 ./WHATS_NEW scripts/lvm_dump.sh
Message-ID: <20071002160946.11656.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2007-10-02 16:09:46

Modified files:
	.              : WHATS_NEW 
	scripts        : lvm_dump.sh 

Log message:
	Fix underquotations in lvm_dump.sh.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.715&r2=1.716
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/lvm_dump.sh.diff?cvsroot=lvm2&r1=1.10&r2=1.11

--- LVM2/WHATS_NEW	2007/10/02 15:48:57	1.715
+++ LVM2/WHATS_NEW	2007/10/02 16:09:46	1.716
@@ -1,6 +1,7 @@
 Version 2.02.29 -
 ==================================
   Fix a bug in lvm_dump.sh checks for lvm/dmsetup binaries.
+  Fix underquotations in lvm_dump.sh.
   Refactor lvcreate stripe and mirror parameter validation.
   All tools: print --help output to stdout, not stderr.
   After a diagnostic, suggest --help, rather than printing all --help output.
--- LVM2/scripts/lvm_dump.sh	2007/10/02 15:48:58	1.10
+++ LVM2/scripts/lvm_dump.sh	2007/10/02 16:09:46	1.11
@@ -91,11 +91,11 @@
 
 myecho() {
 	echo "$@"
-	echo "$@" >> $log
+	echo "$@" >> "$log"
 }
 
 log() {
-	echo "$@" >> $log
+	echo "$@" >> "$log"
 	eval "$@"
 }
 
@@ -107,19 +107,19 @@
 	myecho "Gathering LVM volume info..."
 
 	myecho "  vgscan..."
-	log "$LVM vgscan -vvvv > $dir/vgscan 2>&1"
+	log "\"$LVM\" vgscan -vvvv > \"$dir/vgscan\" 2>&1"
 
 	myecho "  pvscan..."
-	log "$LVM pvscan -v >> $dir/pvscan 2>> $log"
+	log "\"$LVM\" pvscan -v >> \"$dir/pvscan\" 2>> \"$log\""
 
 	myecho "  lvs..."
-	log "$LVM lvs -a -o +devices >> $dir/lvs 2>> $log"
+	log "\"$LVM\" lvs -a -o +devices >> \"$dir/lvs\" 2>> \"$log\""
 
 	myecho "  pvs..."
-	log "$LVM pvs -a -v > $dir/pvs 2>> $log"
+	log "\"$LVM\" pvs -a -v > \"$dir/pvs\" 2>> \"$log\""
 
-	echo "  vgs..."
-	log "$LVM vgs -v > $dir/vgs 2>> $log"
+	myecho "  vgs..."
+	log "\"$LVM\" vgs -v > \"$dir/vgs\" 2>> \"$log\""
 fi
 
 if (( $clustered )); then
@@ -129,7 +129,7 @@
 	for i in nodes status services; do
 		cap_i=$(echo $i|tr a-z A-Z)
 		printf "$cap_i:\n----------------------------------\n"
-		log "cman_tool $i 2>> $log"
+		log "cman_tool $i 2>> \"$log\""
 		echo
 	done
 
@@ -161,50 +161,50 @@
 fi
 
 myecho "Gathering LVM & device-mapper version info..."
-echo "LVM VERSION:" > $dir/versions
-"$LVM" lvs --version >> $dir/versions 2>> $log
-echo "DEVICE MAPPER VERSION:" >> $dir/versions
-"$DMSETUP" --version >> $dir/versions 2>> $log
-echo "KERNEL VERSION:" >> $dir/versions
-"$UNAME" -a >> $dir/versions 2>> $log
-echo "DM TARGETS VERSIONS:" >> $dir/versions
-"$DMSETUP" targets >> $dir/versions 2>> $log
+echo "LVM VERSION:" > "$dir/versions"
+"$LVM" lvs --version >> "$dir/versions" 2>> "$log"
+echo "DEVICE MAPPER VERSION:" >> "$dir/versions"
+"$DMSETUP" --version >> "$dir/versions" 2>> "$log"
+echo "KERNEL VERSION:" >> "$dir/versions"
+"$UNAME" -a >> "$dir/versions" 2>> "$log"
+echo "DM TARGETS VERSIONS:" >> "$dir/versions"
+"$DMSETUP" targets >> "$dir/versions" 2>> "$log"
 
 myecho "Gathering dmsetup info..."
-log "$DMSETUP info -c > $dir/dmsetup_info 2>> $log"
-log "$DMSETUP table > $dir/dmsetup_table 2>> $log"
-log "$DMSETUP status > $dir/dmsetup_status 2>> $log"
+log "\"$DMSETUP\" info -c > \"$dir/dmsetup_info\" 2>> \"$log\""
+log "\"$DMSETUP\" table > \"$dir/dmsetup_table\" 2>> \"$log\""
+log "\"$DMSETUP\" status > \"$dir/dmsetup_status\" 2>> \"$log\""
 
 myecho "Gathering process info..."
-log "$PS alx > $dir/ps_info 2>> $log"
+log "$PS alx > \"$dir/ps_info\" 2>> \"$log\""
 
 myecho "Gathering console messages..."
-log "$TAIL -n 75 /var/log/messages > $dir/messages 2>> $log"
+log "$TAIL -n 75 /var/log/messages > \"$dir/messages\" 2>> \"$log\""
 
 myecho "Gathering /etc/lvm info..."
-log "$CP -a /etc/lvm $dir/lvm 2>> $log"
+log "$CP -a /etc/lvm \"$dir/lvm\" 2>> \"$log\""
 
 myecho "Gathering /dev listing..."
-log "$LS -laR /dev > $dir/dev_listing 2>> $log"
+log "$LS -laR /dev > \"$dir/dev_listing\" 2>> \"$log\""
 
 myecho "Gathering /sys/block listing..."
-log "$LS -laR /sys/block > $dir/sysblock_listing"
+log "$LS -laR /sys/block > \"$dir/sysblock_listing\""
 
 if (( $metadata )); then
 	myecho "Gathering LVM metadata from Physical Volumes..."
 
-	log "$MKDIR -p $dir/metadata"
+	log "$MKDIR -p \"$dir/metadata\""
 
-	pvs="$($LVM pvs --separator , --noheadings --units s --nosuffix -o \
-	    name,pe_start 2>> $log | $SED -e 's/^ *//')"
+	pvs="$("$LVM" pvs --separator , --noheadings --units s --nosuffix -o \
+	    name,pe_start 2>> "$log" | $SED -e 's/^ *//')"
 	for line in "$pvs"
 	do
 		test -z "$line" && continue
 		pv="$(echo $line | $CUT -d, -f1)"
 		pe_start="$(echo $line | $CUT -d, -f2)"
-		name="$($BASENAME $pv)"
+		name="$($BASENAME "$pv")"
 		myecho "  $pv"
-		log "$DD if=$pv of=$dir/metadata/$name bs=512 count=$pe_start 2>> $log"
+		log "$DD if=$pv \"of=$dir/metadata/$name\" bs=512 count=$pe_start 2>> \"$log\""
 	done
 fi
 
@@ -212,8 +212,8 @@
 	lvm_dump="$dirbase.tgz"
 	myecho "Creating report tarball in $HOME/$lvm_dump..."
 	cd "$HOME"
-	"$TAR" czf $lvm_dump $dirbase 2>/dev/null
-	"$RM" -rf $dir
+	"$TAR" czf "$lvm_dump" "$dirbase" 2>/dev/null
+	"$RM" -rf "$dir"
 fi
 
 if test "$UID" != "0" && test "$EUID" != "0"; then


