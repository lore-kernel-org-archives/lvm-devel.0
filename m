From: meyering@sourceware.org <meyering@sourceware.org>
Date: 20 Aug 2007 12:06:36 -0000
Subject: LVM2/scripts lvm_dump.sh
Message-ID: <20070820120636.29293.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	meyering at sourceware.org	2007-08-20 12:06:36

Modified files:
	scripts        : lvm_dump.sh 

Log message:
	factor out some duplication -- mostly I/O redirection

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/lvm_dump.sh.diff?cvsroot=lvm2&r1=1.7&r2=1.8

--- LVM2/scripts/lvm_dump.sh	2007/08/09 09:53:33	1.7
+++ LVM2/scripts/lvm_dump.sh	2007/08/20 12:06:35	1.8
@@ -116,45 +116,40 @@
 
 if (( $clustered )); then
 	myecho "Gathering cluster info..."
-	echo "NODES: " > $dir/cluster_info
-	echo "----------------------------------" >> $dir/cluster_info
-	log "cman_tool nodes >> $dir/cluster_info 2>> $log"
-	echo " " >> $dir/cluster_info
-
-	echo "STATUS: " > $dir/cluster_info
-	echo "----------------------------------" >> $dir/cluster_info
-	log "cman_tool status >> $dir/cluster_info 2>> $log"
-	echo " " >> $dir/cluster_info
-
-	echo "SERVICES: " >> $dir/cluster_info
-	echo "----------------------------------" >> $dir/cluster_info
-	log "cman_tool services >> $dir/cluster_info 2>> $log"
-	echo " " >> $dir/cluster_info
 
-	echo "LOCKS: "  >> $dir/cluster_info
-	echo "----------------------------------" >> $dir/cluster_info
+	{
+	for i in nodes status services; do
+		cap_i=$(echo $i|tr a-z A-Z)
+		printf "$cap_i:\n----------------------------------\n"
+		log "cman_tool $i 2>> $log"
+		echo
+	done
+
+	echo "LOCKS:"
+	echo "----------------------------------"
 	if [ -f /proc/cluster/dlm_locks ]
 	then
-		echo "clvmd" > /proc/cluster/dlm_locks
-		cat /proc/cluster/dlm_locks >> $dir/cluster_info
-		echo " " >> $dir/cluster_info
-		echo "RESOURCE DIR: "  >> $dir/cluster_info
-		cat /proc/cluster/dlm_dir >> $dir/cluster_info
-		echo " " >> $dir/cluster_info
-		echo "DEBUG LOG: "  >> $dir/cluster_info
-		cat /proc/cluster/dlm_debug >> $dir/cluster_info
-		echo " " >> $dir/cluster_info
+		echo clvmd > /proc/cluster/dlm_locks
+		cat /proc/cluster/dlm_locks
+		echo
+		echo "RESOURCE DIR:"
+		cat /proc/cluster/dlm_dir
+		echo
+		echo "DEBUG LOG:"
+		cat /proc/cluster/dlm_debug
+		echo
 	fi
 	if [ -f /debug/dlm/clvmd ]
 	then
-		cat /debug/dlm/clvmd >> $dir/cluster_info
-		echo " " >> $dir/cluster_info
-		echo "WAITERS: "  >> $dir/cluster_info
-		cat /debug/dlm/clvmd_waiters >> $dir/cluster_info
-		echo " " >> $dir/cluster_info
-		echo "MASTER: "  >> $dir/cluster_info
-		cat /debug/dlm/clvmd_master >> $dir/cluster_info
+		cat /debug/dlm/clvmd
+		echo
+		echo "WAITERS:"
+		cat /debug/dlm/clvmd_waiters
+		echo
+		echo "MASTER:"
+		cat /debug/dlm/clvmd_master
 	fi
+	} > $dir/cluster_info
 fi
 
 myecho "Gathering LVM & device-mapper version info..."


