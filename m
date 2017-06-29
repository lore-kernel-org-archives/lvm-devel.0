From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 29 Jun 2017 16:26:14 -0400
Subject: master - lvmdump: double quote
Message-ID: <201706292026.v5TKQEbC025800@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e292c1a1cac4edc394fe9daa9ef11b691216740d
Commit:        e292c1a1cac4edc394fe9daa9ef11b691216740d
Parent:        6330e2dc8621e0383a5606acbfb9687a34f1a668
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jun 28 20:48:19 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 29 22:23:16 2017 +0200

lvmdump: double quote

Double quote to prevent globbing and word splitting.
---
 scripts/lvmdump.sh.in |   52 ++++++++++++++++++++++++------------------------
 1 files changed, 26 insertions(+), 26 deletions(-)

diff --git a/scripts/lvmdump.sh.in b/scripts/lvmdump.sh.in
index 6467863..6744058 100644
--- a/scripts/lvmdump.sh.in
+++ b/scripts/lvmdump.sh.in
@@ -1,7 +1,7 @@
 #!/bin/bash
 # We use some bash-isms (getopts?)
 
-# Copyright (C) 2007-2015 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2007-2017 Red Hat, Inc. All rights reserved.
 #
 # This file is part of LVM2.
 #
@@ -53,7 +53,7 @@ LVMPOLLD_SOCKET=${LVM_LVMPOLLD_SOCKET-/var/run/lvm/lvmpolld.socket}
 die() {
     code=$1; shift
     echo "$@" 1>&2
-    exit $code
+    exit "$code"
 }
 
 "$LVM" version >& /dev/null || die 2 "Could not run lvm binary '$LVM'"
@@ -106,12 +106,12 @@ else
 	dir="$HOME/$dirbase"
 fi
 
-if test -d $dir ; then
-	(shopt -s nullglob dotglob; test -r $dir -a -w $dir -a -x $dir && cd $dir && files=(*) && ((! ${#files[@]}))) || \
+if test -d "$dir" ; then
+	(shopt -s nullglob dotglob; test -r "$dir" -a -w "$dir" -a -x "$dir" && cd "$dir" && files=(*) && ((! ${#files[@]}))) || \
 		die 5 "Fatal: directory $dir already exists and is not empty or inaccessible"
 else
-	test -e $dir && die 3 "Fatal: $dir already exists"
-	$MKDIR -p $dir || die 4 "Fatal: could not create $dir"
+	test -e "$dir" && die 3 "Fatal: $dir already exists"
+	"$MKDIR" -p "$dir" || die 4 "Fatal: could not create $dir"
 fi
 
 log="$dir/lvmdump.log"
@@ -193,7 +193,7 @@ if (( $clustered )); then
 		echo "MASTER:"
 		cat /debug/dlm/clvmd_master
 	fi
-	} >> $dir/cluster_info
+	} >> "$dir/cluster_info"
 fi
 
 myecho "Gathering LVM & device-mapper version info..."
@@ -238,14 +238,14 @@ if (( $metadata )); then
 
 	log "$MKDIR -p \"$dir/metadata\""
 
-	pvs="$("$LVM" pvs --separator , --noheadings --units s --nosuffix -o \
-	    name,pe_start 2>> "$log" | $SED -e 's/^ *//')"
+	pvs=$("$LVM" pvs --separator , --noheadings --units s --nosuffix -o \
+	    name,pe_start 2>> "$log" | $SED -e 's/^ *//')
 	for line in $pvs
 	do
 		test -z "$line" && continue
-		pv="$(echo $line | $CUT -d, -f1)"
-		pe_start="$(echo $line | $CUT -d, -f2)"
-		name="$($BASENAME "$pv")"
+		pv=$(echo "$line" | "$CUT" -d, -f1)
+		pe_start=$(echo "$line" | "$CUT" -d, -f2)
+		name=$("$BASENAME" "$pv")
 		myecho "  $pv"
 		log "$DD if=$pv \"of=$dir/metadata/$name\" $DDFLAGS bs=512 count=$pe_start 2>> \"$log\""
 	done
@@ -257,21 +257,21 @@ if (( $sysreport )); then
 	sysreport_dir="$dir/sysreport"
 	log_lines=10000
 
-	SYSTEMCTL=$(which systemctl 2>> $log)
-	JOURNALCTL=$(which journalctl 2>> $log)
-	LSBLK=$(which lsblk 2>> $log)
+	SYSTEMCTL=$(which systemctl 2>> "$log")
+	JOURNALCTL=$(which journalctl 2>> "$log")
+	LSBLK=$(which lsblk 2>> "$log")
 
 	log "$MKDIR -p \"$sysreport_dir\""
 
 	if test -z "LSBLK"; then
 		myecho "WARNING: lsblk not found"
 	else
-		if $LSBLK --help | $GREP -- --output-all >/dev/null; then
+		if "$LSBLK" --help | "$GREP" -- --output-all >/dev/null; then
 			log "$LSBLK -O >> \"$sysreport_dir/lsblk_O\""
 		else
 			log "$LSBLK >> \"$sysreport_dir/lsblk\""
 		fi
-		if $LSBLK --help | $GREP -- --inverse >/dev/null; then
+		if "$LSBLK" --help | "$GREP" -- --inverse >/dev/null; then
 			log "$LSBLK -s >> \"$sysreport_dir/lsblk_s\""
 		fi
 	fi
@@ -294,7 +294,7 @@ if (( $sysreport )); then
 						   lvm2-activation-net.service \
 						   > \"$sysreport_dir/systemd_lvm2_services_status\" 2>> \"$log\""
 		log "$SYSTEMCTL list-units -l -a --no-legend --no-pager > \"$sysreport_dir/systemd_unit_list\" 2>> \"$log\""
-		for unit in $(cat $sysreport_dir/systemd_unit_list | $GREP lvm2-pvscan | cut -d " " -f 1); do
+		for unit in $(cat "$sysreport_dir/systemd_unit_list" | "$GREP" lvm2-pvscan | cut -d " " -f 1); do
 			log "$SYSTEMCTL status -l --no-pager -n $log_lines -o short-precise $unit >> \"$sysreport_dir/systemd_lvm2_pvscan_service_status\""
 		done
 	fi
@@ -316,12 +316,12 @@ fi
 
 if (( $lvmetad )); then
     (echo 'request="dump"'; echo '##') | {
-	if type -p $SOCAT >& /dev/null; then
+	if type -p "$SOCAT" >& /dev/null; then
 	    echo "$SOCAT unix-connect:$LVMETAD_SOCKET -" >> "$log"
-	    $SOCAT "unix-connect:$LVMETAD_SOCKET" - 2>> "$log"
-	elif echo | $NC -U "$LVMETAD_SOCKET"; then
+	    "$SOCAT" "unix-connect:$LVMETAD_SOCKET" - 2>> "$log"
+	elif echo | "$NC" -U "$LVMETAD_SOCKET"; then
 	    echo "$NC -U $LVMETAD_SOCKET" >> "$log"
-	    $NC -U "$LVMETAD_SOCKET" 2>> "$log"
+	    "$NC" -U "$LVMETAD_SOCKET" 2>> "$log"
 	else
 	    myecho "WARNING: Neither socat nor nc -U seems to be available." 1>&2
 	    echo "# DUMP FAILED"
@@ -332,12 +332,12 @@ fi
 
 if (( $lvmpolld )); then
     (echo 'request="dump"'; echo '##') | {
-	if type -p $SOCAT >& /dev/null; then
+	if type -p "$SOCAT" >& /dev/null; then
 	    echo "$SOCAT unix-connect:$LVMPOLLD_SOCKET -" >> "$log"
-	    $SOCAT "unix-connect:$LVMPOLLD_SOCKET" - 2>> "$log"
-	elif echo | $NC -U "$LVMPOLLD_SOCKET"; then
+	    "$SOCAT" "unix-connect:$LVMPOLLD_SOCKET" - 2>> "$log"
+	elif echo | "$NC" -U "$LVMPOLLD_SOCKET"; then
 	    echo "$NC -U $LVMPOLLD_SOCKET" >> "$log"
-	    $NC -U "$LVMPOLLD_SOCKET" 2>> "$log"
+	    "$NC" -U "$LVMPOLLD_SOCKET" 2>> "$log"
 	else
 	    myecho "WARNING: Neither socat nor nc -U seems to be available." 1>&2
 	    echo "# DUMP FAILED"


