From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 1 Feb 2012 13:08:40 -0000
Subject: LVM2 ./WHATS_NEW scripts/dm_event_systemd_red_ ...
Message-ID: <20120201130840.14675.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2012-02-01 13:08:39

Modified files:
	.              : WHATS_NEW 
	scripts        : dm_event_systemd_red_hat.service.in 
	                 lvm2_monitoring_systemd_red_hat.service.in 

Log message:
	Clean up systemd unit ordering and requirements.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2250&r2=1.2251
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/dm_event_systemd_red_hat.service.in.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/lvm2_monitoring_systemd_red_hat.service.in.diff?cvsroot=lvm2&r1=1.2&r2=1.3

--- LVM2/WHATS_NEW	2012/02/01 10:46:45	1.2250
+++ LVM2/WHATS_NEW	2012/02/01 13:08:39	1.2251
@@ -1,5 +1,6 @@
 Version 2.02.90 - 
 ===================================
+  Clean up systemd unit ordering and requirements.
   Fix lcov reports when srcdir != builddir.
   Allow ALLOC_NORMAL to track reserved extents for log and data on same PV.
   Automatically detect whether corosync clvmd needs to use confdb or cmap.
--- LVM2/scripts/dm_event_systemd_red_hat.service.in	2011/10/31 12:22:50	1.2
+++ LVM2/scripts/dm_event_systemd_red_hat.service.in	2012/02/01 13:08:39	1.3
@@ -1,6 +1,7 @@
 [Unit]
 Description=Device-mapper event daemon
-After=fedora-storage-init.service fedora-storage-init-late.service
+Requires=dm-event.socket
+After=dm-event.socket
 Before=local-fs.target
 DefaultDependencies=no
 
--- LVM2/scripts/lvm2_monitoring_systemd_red_hat.service.in	2011/08/11 15:27:46	1.2
+++ LVM2/scripts/lvm2_monitoring_systemd_red_hat.service.in	2012/02/01 13:08:39	1.3
@@ -1,7 +1,7 @@
 [Unit]
 Description=Monitoring of LVM2 mirrors, snapshots etc. using dmeventd or progress polling
 Requires=dm-event.socket
-After=fedora-storage-init.service fedora-storage-init-late.service
+After=dm-event.socket fedora-storage-init.service fedora-storage-init-late.service
 Before=local-fs.target
 DefaultDependencies=no
 Conflicts=shutdown.target
@@ -15,4 +15,3 @@
 
 [Install]
 WantedBy=sysinit.target
-Also=dm-event.socket


