From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 4 Jan 2011 21:16:58 -0000
Subject: LVM2/scripts cmirrord_init_red_hat.in
Message-ID: <20110104211658.15646.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2011-01-04 21:16:56

Modified files:
	scripts        : cmirrord_init_red_hat.in 

Log message:
	Fix bug 632681: cmirrord shouldn't fail 'start' if already started
	
	Return 0 from the cmirrord init script if the daemon is already
	running.
	
	http://refspecs.freestandards.org/LSB_3.1.1/LSB-Core-generic/LSB-Core-generic/iniscrptact.html

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/cmirrord_init_red_hat.in.diff?cvsroot=lvm2&r1=1.4&r2=1.5

--- LVM2/scripts/cmirrord_init_red_hat.in	2010/01/22 16:19:38	1.4
+++ LVM2/scripts/cmirrord_init_red_hat.in	2011/01/04 21:16:54	1.5
@@ -21,6 +21,7 @@
 
 start()
 {
+	rtrn=0
 	if ! pidof $DAEMON > /dev/null 
 	then 
 		echo -n "Starting $DAEMON: "


