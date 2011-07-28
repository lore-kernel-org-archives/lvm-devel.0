From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 28 Jul 2011 12:54:30 -0000
Subject: LVM2 ./WHATS_NEW_DM scripts/dm_event_systemd_r ...
Message-ID: <20110728125430.11344.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2011-07-28 12:54:29

Modified files:
	.              : WHATS_NEW_DM 
Added files:
	scripts        : dm_event_systemd_red_hat.service.in 
	                 dm_event_systemd_red_hat.socket 
	                 lvm2_monitoring_systemd_red_hat.service.in 

Log message:
	Add systemd unit files for dmeventd.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.482&r2=1.483
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/dm_event_systemd_red_hat.service.in.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/dm_event_systemd_red_hat.socket.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/lvm2_monitoring_systemd_red_hat.service.in.diff?cvsroot=lvm2&r1=NONE&r2=1.1

--- LVM2/WHATS_NEW_DM	2011/07/24 23:59:03	1.482
+++ LVM2/WHATS_NEW_DM	2011/07/28 12:54:28	1.483
@@ -1,5 +1,6 @@
 Version 1.02.66 - 
 ===============================
+  Add systemd unit files for dmeventd.
   Fix read-only identical table reload supression.
 
 Version 1.02.65 - 8th July 2011
/cvs/lvm2/LVM2/scripts/dm_event_systemd_red_hat.service.in,v  -->  standard output
revision 1.1
--- LVM2/scripts/dm_event_systemd_red_hat.service.in
+++ -	2011-07-28 12:54:29.824812000 +0000
@@ -0,0 +1,14 @@
+[Unit]
+Description=Device-mapper event daemon
+After=fedora-storage-init.service fedora-storage-init-late.service
+Before=local-fs.target
+DefaultDependencies=no
+
+[Service]
+Type=forking
+ExecStart=@sbindir@/dmeventd
+PIDFile=@DMEVENTD_PIDFILE@
+OOMScoreAdjust=-1000
+
+[Install]
+WantedBy=sysinit.target
/cvs/lvm2/LVM2/scripts/dm_event_systemd_red_hat.socket,v  -->  standard output
revision 1.1
--- LVM2/scripts/dm_event_systemd_red_hat.socket
+++ -	2011-07-28 12:54:30.179738000 +0000
@@ -0,0 +1,11 @@
+[Unit]
+Description=Device-mapper event daemon FIFOs
+DefaultDependencies=no
+
+[Socket]
+ListenFIFO=/var/run/dmeventd-server
+ListenFIFO=/var/run/dmeventd-client
+SocketMode=0600
+
+[Install]
+WantedBy=sockets.target
/cvs/lvm2/LVM2/scripts/lvm2_monitoring_systemd_red_hat.service.in,v  -->  standard output
revision 1.1
--- LVM2/scripts/lvm2_monitoring_systemd_red_hat.service.in
+++ -	2011-07-28 12:54:30.524837000 +0000
@@ -0,0 +1,17 @@
+[Unit]
+Description=Monitoring of LVM2 mirrors, snapshots etc. using dmeventd or progress polling
+Requires=dm-event.socket
+After=fedora-storage-init.service fedora-storage-init-late.service
+Before=local-fs.target
+DefaultDependencies=no
+Conflicts=shutdown.target
+
+[Service]
+Type=oneshot
+ExecStart=@sbindir@/lvm vgchange --monitor y
+ExecStop=@sbindir@/lvm vgchange --monitor n
+RemainAfterExit=yes
+
+[Install]
+WantedBy=sysinit.target
+Also=dm-event.socket


