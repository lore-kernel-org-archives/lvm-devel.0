From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 2 Jun 2011 09:02:04 -0000
Subject: LVM2 ./WHATS_NEW scripts/lvmdump.sh
Message-ID: <20110602090204.11553.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2011-06-02 09:02:03

Modified files:
	.              : WHATS_NEW 
	scripts        : lvmdump.sh 

Log message:
	Always use append to file in lvmdump (selinux policy - no file truncation).
	
	Workaround dmsetup ls --tree (terminal ioctl for width).
	(Until isatty() will be allowed by selinux policy.)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2005&r2=1.2006
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/lvmdump.sh.diff?cvsroot=lvm2&r1=1.16&r2=1.17

--- LVM2/WHATS_NEW	2011/06/01 21:16:55	1.2005
+++ LVM2/WHATS_NEW	2011/06/02 09:02:03	1.2006
@@ -1,5 +1,6 @@
 Version 2.02.86 -  
 =================================
+  Always use append to file in lvmdump (selinux policy - no file truncation).
   Propagate test mode to clvmd to skip activation and changes to held locks.
   Defer writing PV labels to vg_write.
   Store label_sector only in struct physical_volume.
--- LVM2/scripts/lvmdump.sh	2011/02/01 21:39:15	1.16
+++ LVM2/scripts/lvmdump.sh	2011/06/02 09:02:03	1.17
@@ -55,7 +55,7 @@
 	echo "    -d <directory> dump into a directory instead of tarball"
 	echo "    -c if running clvmd, gather cluster data as well"
 	echo ""
-	
+
 	exit 1
 }
 
@@ -116,7 +116,7 @@
 	myecho "Gathering LVM volume info..."
 
 	myecho "  vgscan..."
-	log "\"$LVM\" vgscan -vvvv > \"$dir/vgscan\" 2>&1"
+	log "\"$LVM\" vgscan -vvvv >> \"$dir/vgscan\" 2>&1"
 
 	myecho "  pvscan..."
 	log "\"$LVM\" pvscan -v >> \"$dir/pvscan\" 2>> \"$log\""
@@ -125,10 +125,10 @@
 	log "\"$LVM\" lvs -a -o +devices >> \"$dir/lvs\" 2>> \"$log\""
 
 	myecho "  pvs..."
-	log "\"$LVM\" pvs -a -v > \"$dir/pvs\" 2>> \"$log\""
+	log "\"$LVM\" pvs -a -v >> \"$dir/pvs\" 2>> \"$log\""
 
 	myecho "  vgs..."
-	log "\"$LVM\" vgs -v > \"$dir/vgs\" 2>> \"$log\""
+	log "\"$LVM\" vgs -v >> \"$dir/vgs\" 2>> \"$log\""
 fi
 
 if (( $clustered )); then
@@ -146,7 +146,7 @@
 	echo "----------------------------------"
 	if [ -f /proc/cluster/dlm_locks ]
 	then
-		echo clvmd > /proc/cluster/dlm_locks
+		echo clvmd >> /proc/cluster/dlm_locks
 		cat /proc/cluster/dlm_locks
 		echo
 		echo "RESOURCE DIR:"
@@ -166,11 +166,11 @@
 		echo "MASTER:"
 		cat /debug/dlm/clvmd_master
 	fi
-	} > $dir/cluster_info
+	} >> $dir/cluster_info
 fi
 
 myecho "Gathering LVM & device-mapper version info..."
-echo "LVM VERSION:" > "$dir/versions"
+echo "LVM VERSION:" >> "$dir/versions"
 "$LVM" lvs --version >> "$dir/versions" 2>> "$log"
 echo "DEVICE MAPPER VERSION:" >> "$dir/versions"
 "$DMSETUP" --version >> "$dir/versions" 2>> "$log"
@@ -180,25 +180,27 @@
 "$DMSETUP" targets >> "$dir/versions" 2>> "$log"
 
 myecho "Gathering dmsetup info..."
-log "\"$DMSETUP\" info -c > \"$dir/dmsetup_info\" 2>> \"$log\""
-log "\"$DMSETUP\" table > \"$dir/dmsetup_table\" 2>> \"$log\""
-log "\"$DMSETUP\" status > \"$dir/dmsetup_status\" 2>> \"$log\""
-log "\"$DMSETUP\" ls --tree > \"$dir/dmsetup_ls_tree\" 2>> \"$log\""
+log "\"$DMSETUP\" info -c >> \"$dir/dmsetup_info\" 2>> \"$log\""
+log "\"$DMSETUP\" table >> \"$dir/dmsetup_table\" 2>> \"$log\""
+log "\"$DMSETUP\" status >> \"$dir/dmsetup_status\" 2>> \"$log\""
+
+# cat as workaround to avoid tty ioctl (selinux)
+log "\"$DMSETUP\" ls --tree 2>> \"$log\" | cat >> \"$dir/dmsetup_ls_tree\""
 
 myecho "Gathering process info..."
-log "$PS alx > \"$dir/ps_info\" 2>> \"$log\""
+log "$PS alx >> \"$dir/ps_info\" 2>> \"$log\""
 
 myecho "Gathering console messages..."
-log "$TAIL -n 75 /var/log/messages > \"$dir/messages\" 2>> \"$log\""
+log "$TAIL -n 75 /var/log/messages >> \"$dir/messages\" 2>> \"$log\""
 
 myecho "Gathering /etc/lvm info..."
 log "$CP -a /etc/lvm \"$dir/lvm\" 2>> \"$log\""
 
 myecho "Gathering /dev listing..."
-log "$LS -laR /dev > \"$dir/dev_listing\" 2>> \"$log\""
+log "$LS -laR /dev >> \"$dir/dev_listing\" 2>> \"$log\""
 
 myecho "Gathering /sys/block listing..."
-log "$LS -laR /sys/block > \"$dir/sysblock_listing\"  2>> \"$log\""
+log "$LS -laR /sys/block >> \"$dir/sysblock_listing\"  2>> \"$log\""
 log "$LS -laR /sys/devices/virtual/block >> \"$dir/sysblock_listing\"  2>> \"$log\""
 
 if (( $metadata )); then
@@ -233,4 +235,3 @@
 fi
 
 exit 0
-


