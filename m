From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 24 Feb 2012 13:11:57 -0000
Subject: LVM2/scripts lvm2_lvmetad_init_red_hat.in
Message-ID: <20120224131157.989.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2012-02-24 13:11:57

Modified files:
	scripts        : lvm2_lvmetad_init_red_hat.in 

Log message:
	The daemon as well as the first scan must be both executed properly, otherwise it's an error!

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/lvm2_lvmetad_init_red_hat.in.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/scripts/lvm2_lvmetad_init_red_hat.in	2012/02/24 13:03:51	1.1
+++ LVM2/scripts/lvm2_lvmetad_init_red_hat.in	2012/02/24 13:11:57	1.2
@@ -54,7 +54,7 @@
 start()
 {
 	ret=0
-	action "Starting LVM metadata daemon:" $DAEMON || ${lvm_vgscan} || ret=$?
+	action "Starting LVM metadata daemon:" $DAEMON && ${lvm_vgscan} || ret=$?
 	return $ret
 }
 


