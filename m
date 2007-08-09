From: pcaulfield@sourceware.org <pcaulfield@sourceware.org>
Date: 9 Aug 2007 09:53:33 -0000
Subject: LVM2 ./WHATS_NEW scripts/lvm_dump.sh
Message-ID: <20070809095333.12244.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	pcaulfield at sourceware.org	2007-08-09 09:53:33

Modified files:
	.              : WHATS_NEW 
	scripts        : lvm_dump.sh 

Log message:
	Add more cluster/clvmd information to lvmdump

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.679&r2=1.680
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/lvm_dump.sh.diff?cvsroot=lvm2&r1=1.6&r2=1.7

--- LVM2/WHATS_NEW	2007/08/07 09:06:04	1.679
+++ LVM2/WHATS_NEW	2007/08/09 09:53:33	1.680
@@ -1,5 +1,6 @@
 Version 2.02.28 -
 ================================
+  Add more cluster info to lvmdump
   Add const attributes where possible, first cut.
   Add support for renaming mirrored LVs.
   Factor out core of lvrename() to lv_rename lvm library function.
--- LVM2/scripts/lvm_dump.sh	2007/07/02 20:18:38	1.6
+++ LVM2/scripts/lvm_dump.sh	2007/08/09 09:53:33	1.7
@@ -116,15 +116,45 @@
 
 if (( $clustered )); then
 	myecho "Gathering cluster info..."
+	echo "NODES: " > $dir/cluster_info
+	echo "----------------------------------" >> $dir/cluster_info
+	log "cman_tool nodes >> $dir/cluster_info 2>> $log"
+	echo " " >> $dir/cluster_info
+
 	echo "STATUS: " > $dir/cluster_info
 	echo "----------------------------------" >> $dir/cluster_info
 	log "cman_tool status >> $dir/cluster_info 2>> $log"
-	echo " " >> $dir/lvm_info
+	echo " " >> $dir/cluster_info
 
 	echo "SERVICES: " >> $dir/cluster_info
 	echo "----------------------------------" >> $dir/cluster_info
 	log "cman_tool services >> $dir/cluster_info 2>> $log"
-	echo " " >> $dir/lvm_info
+	echo " " >> $dir/cluster_info
+
+	echo "LOCKS: "  >> $dir/cluster_info
+	echo "----------------------------------" >> $dir/cluster_info
+	if [ -f /proc/cluster/dlm_locks ]
+	then
+		echo "clvmd" > /proc/cluster/dlm_locks
+		cat /proc/cluster/dlm_locks >> $dir/cluster_info
+		echo " " >> $dir/cluster_info
+		echo "RESOURCE DIR: "  >> $dir/cluster_info
+		cat /proc/cluster/dlm_dir >> $dir/cluster_info
+		echo " " >> $dir/cluster_info
+		echo "DEBUG LOG: "  >> $dir/cluster_info
+		cat /proc/cluster/dlm_debug >> $dir/cluster_info
+		echo " " >> $dir/cluster_info
+	fi
+	if [ -f /debug/dlm/clvmd ]
+	then
+		cat /debug/dlm/clvmd >> $dir/cluster_info
+		echo " " >> $dir/cluster_info
+		echo "WAITERS: "  >> $dir/cluster_info
+		cat /debug/dlm/clvmd_waiters >> $dir/cluster_info
+		echo " " >> $dir/cluster_info
+		echo "MASTER: "  >> $dir/cluster_info
+		cat /debug/dlm/clvmd_master >> $dir/cluster_info
+	fi
 fi
 
 myecho "Gathering LVM & device-mapper version info..."


