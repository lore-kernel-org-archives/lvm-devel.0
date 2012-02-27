From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 27 Feb 2012 15:45:50 -0000
Subject: LVM2/scripts lvm2_lvmetad_systemd_red_hat.sock ...
Message-ID: <20120227154550.7956.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2012-02-27 15:45:49

Modified files:
	scripts        : lvm2_lvmetad_systemd_red_hat.socket.in 

Log message:
	lvmetad.socket

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/lvm2_lvmetad_systemd_red_hat.socket.in.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/scripts/lvm2_lvmetad_systemd_red_hat.socket.in	2012/02/23 13:31:49	1.1
+++ LVM2/scripts/lvm2_lvmetad_systemd_red_hat.socket.in	2012/02/27 15:45:49	1.2
@@ -3,7 +3,7 @@
 DefaultDependencies=no
 
 [Socket]
-ListenStream=@DEFAULT_RUN_DIR@/lvmetad.sock
+ListenStream=@DEFAULT_RUN_DIR@/lvmetad.socket
 SocketMode=0600
 
 [Install]


