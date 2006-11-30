From: pcaulfield@sourceware.org <pcaulfield@sourceware.org>
Date: 30 Nov 2006 10:16:49 -0000
Subject: LVM2 ./WHATS_NEW scripts/clvmd_init_rhel4
Message-ID: <20061130101649.30928.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	pcaulfield at sourceware.org	2006-11-30 10:16:48

Modified files:
	.              : WHATS_NEW 
	scripts        : clvmd_init_rhel4 

Log message:
	Add timeout to RHEL4 clvmd init script.
	With the previous clvmd checkin this should address bz#187812

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.508&r2=1.509
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/clvmd_init_rhel4.diff?cvsroot=lvm2&r1=1.10&r2=1.11

--- LVM2/WHATS_NEW	2006/11/30 09:44:06	1.508
+++ LVM2/WHATS_NEW	2006/11/30 10:16:47	1.509
@@ -1,5 +1,6 @@
 Version 2.02.16 -
 ====================================
+  Add startup timeout to RHEL4 clvmd startup script
   Add -T (startup timeout) switch to clvmd.
   Improve lvm_dump.sh robustness.
   Update lvm2create_initrd to support gentoo.
--- LVM2/scripts/clvmd_init_rhel4	2006/11/21 17:44:46	1.10
+++ LVM2/scripts/clvmd_init_rhel4	2006/11/30 10:16:48	1.11
@@ -15,6 +15,7 @@
 VGSCAN="/usr/sbin/vgscan"
 VGDISPLAY="/usr/sbin/vgdisplay"
 VGS="/usr/sbin/vgs"
+CLVMDOPTS="-T20"
 
 [ -f /etc/sysconfig/cluster ] && . /etc/sysconfig/cluster
 
@@ -27,7 +28,7 @@
 		if ! pidof clvmd > /dev/null 
 		then 
 			echo -n "Starting clvmd: "
-			daemon clvmd
+			daemon clvmd $CLVMDOPTS
 			rtrn=$?
 			echo
 			if [ $rtrn -ne 0 ]


