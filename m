From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 31 Oct 2011 12:22:51 -0000
Subject: LVM2 ./WHATS_NEW_DM scripts/dm_event_systemd_r ...
Message-ID: <20111031122251.20828.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2011-10-31 12:22:50

Modified files:
	.              : WHATS_NEW_DM 
	scripts        : dm_event_systemd_red_hat.service.in 

Log message:
	Add "ExecReload" to dm-event.service for systemd to reload dmeventd properly.
	
	Normally, restart simply means "stop and start" for systemd. However, if
	we're installing new versions of the dmeventd binary/libdevmapper, we need
	to restart dmeventd. This fails if we have some devices monitored - we need
	to call "dmeventd -R" instead.
	
	The "ExecReload" did not work quite well in some old versions of systemd,
	systemd assumed that only the configuration is reloaded on "ExecReload",
	not the whole binary itself so it lost track of dmeventd daemon (it lost new
	dmeventd PID). This is fixed and seems to be working fine now with recent
	versions of dmeventd.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.519&r2=1.520
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/dm_event_systemd_red_hat.service.in.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/WHATS_NEW_DM	2011/10/28 20:06:49	1.519
+++ LVM2/WHATS_NEW_DM	2011/10/31 12:22:49	1.520
@@ -1,5 +1,6 @@
 Version 1.02.68 -
 ==================================
+  Add ExecReload to dm-event.service for systemd to reload dmeventd properly.
   Add dm_config_tree_find_str_allow_empty.
   Fix compile-time pool memory locking with DEBUG_MEM.
   Fix valgrind error reports in free of pool chunks with DEBUG_MEM.
--- LVM2/scripts/dm_event_systemd_red_hat.service.in	2011/07/28 12:54:28	1.1
+++ LVM2/scripts/dm_event_systemd_red_hat.service.in	2011/10/31 12:22:50	1.2
@@ -7,6 +7,7 @@
 [Service]
 Type=forking
 ExecStart=@sbindir@/dmeventd
+ExecReload=@sbindir@/dmeventd -R
 PIDFile=@DMEVENTD_PIDFILE@
 OOMScoreAdjust=-1000
 


