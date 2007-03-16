From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 16 Mar 2007 17:15:36 -0000
Subject: LVM2 ./WHATS_NEW scripts/clvmd_init_rhel4 scri ...
Message-ID: <20070316171536.30325.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2007-03-16 17:15:36

Modified files:
	.              : WHATS_NEW 
	scripts        : clvmd_init_rhel4 lvm2_monitoring_init_rhel4 

Log message:
	Fix processing of exit status in init scripts

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.587&r2=1.588
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/clvmd_init_rhel4.diff?cvsroot=lvm2&r1=1.11&r2=1.12
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/lvm2_monitoring_init_rhel4.diff?cvsroot=lvm2&r1=1.2&r2=1.3

--- LVM2/WHATS_NEW	2007/03/15 14:00:29	1.587
+++ LVM2/WHATS_NEW	2007/03/16 17:15:36	1.588
@@ -1,5 +1,6 @@
 Version 2.02.24 -
 ====================================
+  Fix processing of exit status in init scripts
   Fix vgremove to require at least one vg argument.
   Fix reading of striped LVs in LVM1 format.
   Flag nolocking as clustered so clvmd startup sees clustered LVs. (2.02.10)
--- LVM2/scripts/clvmd_init_rhel4	2006/11/30 10:16:48	1.11
+++ LVM2/scripts/clvmd_init_rhel4	2007/03/16 17:15:36	1.12
@@ -43,16 +43,10 @@
 		then
 			for vg in $LVM_VGS
 			do
-				if ! action "Activating VG $vg:" $VGCHANGE -ayl $vg
-				then
-					rtrn=$?
-                                fi
+				action "Activating VG $vg:" $VGCHANGE -ayl $vg || rtrn=$?
 			done
 		else
-			if ! action "Activating VGs:" $VGCHANGE -ayl
-			then
-				rtrn=$?
-                        fi
+			action "Activating VGs:" $VGCHANGE -ayl || rtrn=$?
 		fi
 	done
 
@@ -67,19 +61,13 @@
 		then
 			for vg in $LVM_VGS
 			do
-				if ! action "Deactivating VG $vg:" $VGCHANGE -anl $vg
-				then
-					rtrn=$?
-				fi
+				action "Deactivating VG $vg:" $VGCHANGE -anl $vg || rtrn=$?
 			done
 		else
 			# Hack to only deactivate clustered volumes
 			clustervgs=`$VGDISPLAY 2> /dev/null | awk 'BEGIN {RS="VG Name"} {if (/Clustered/) print $1;}'`
 			for vg in $clustervgs; do
-				if ! action "Deactivating VG $vg:" $VGCHANGE -anl $vg
-				then
-					rtrn=$?
-				fi
+				action "Deactivating VG $vg:" $VGCHANGE -anl $vg || rtrn=$?
 			done
 		fi
 
--- LVM2/scripts/lvm2_monitoring_init_rhel4	2007/01/30 18:02:15	1.2
+++ LVM2/scripts/lvm2_monitoring_init_rhel4	2007/03/16 17:15:36	1.3
@@ -34,10 +34,7 @@
 	VGS=`vgs --noheadings -o name`
 	for vg in $VGS
 	do
-	    if ! action "Starting monitoring for VG $vg:" $VGCHANGE --monitor y $vg
-	    then
-		ret=$?
-	    fi
+	    action "Starting monitoring for VG $vg:" $VGCHANGE --monitor y $vg || ret=$?
 	done
 
 	return $ret
@@ -55,10 +52,7 @@
 	VGS=`vgs --noheadings -o name`
 	for vg in $VGS
 	do
-	    if ! action "Stopping monitoring for VG $vg:" $VGCHANGE --monitor n $vg
-	    then
-		ret=$?
-	    fi
+	    action "Stopping monitoring for VG $vg:" $VGCHANGE --monitor n $vg || ret=$?
 	done
 	return $ret
 }


