From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 14 Mar 2012 15:51:55 -0000
Subject: LVM2 ./WHATS_NEW_DM daemons/dmeventd/dmeventd. ...
Message-ID: <20120314155155.28658.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2012-03-14 15:51:52

Modified files:
	.              : WHATS_NEW_DM 
	daemons/dmeventd: dmeventd.c 
	libdaemon/server: daemon-server.c 
	scripts        : dm_event_systemd_red_hat.service.in 
	                 lvm2_lvmetad_systemd_red_hat.service.in 

Log message:
	Use SD_ACTIVATION env. var. in systemd units to better detect systemd in use.
	
	LISTEN_PID and LISTEN_FDS environment variables are defined only during systemd
	"start" action. But we still need to know whether we're activated during
	"reload" action as well - we use the reload action to call "dmeventd -R"/"lvmetad -R"
	for statefull daemon restart. We can't use normal "restart" as that is simply
	composed of "stop" and "start" and we would lose any state the daemon has.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.593&r2=1.594
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/dmeventd.c.diff?cvsroot=lvm2&r1=1.97&r2=1.98
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdaemon/server/daemon-server.c.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/dm_event_systemd_red_hat.service.in.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/lvm2_lvmetad_systemd_red_hat.service.in.diff?cvsroot=lvm2&r1=1.4&r2=1.5

--- LVM2/WHATS_NEW_DM	2012/03/14 11:16:00	1.593
+++ LVM2/WHATS_NEW_DM	2012/03/14 15:51:51	1.594
@@ -1,5 +1,6 @@
 Version 1.02.75 - 
 ================================
+  Use SD_ACTIVATION env. var. in systemd units to better detect systemd in use.
   Do not run a new dmeventd instance on restart if there's no existing one.
   Make the time window for reading fifo longer 5sec (1.02.73).
 
--- LVM2/daemons/dmeventd/dmeventd.c	2012/03/14 11:16:01	1.97
+++ LVM2/daemons/dmeventd/dmeventd.c	2012/03/14 15:51:51	1.98
@@ -56,6 +56,7 @@
 #  define OOM_SCORE_ADJ_MIN (-1000)
 
 /* Systemd on-demand activation support */
+#  define SD_ACTIVATION_ENV_VAR_NAME "SD_ACTIVATION"
 #  define SD_LISTEN_PID_ENV_VAR_NAME "LISTEN_PID"
 #  define SD_LISTEN_FDS_ENV_VAR_NAME "LISTEN_FDS"
 #  define SD_LISTEN_FDS_START 3
@@ -1698,6 +1699,10 @@
 
 	memset(fifos, 0, sizeof(*fifos));
 
+	/* SD_ACTIVATION must be set! */
+	if (!(e = getenv(SD_ACTIVATION_ENV_VAR_NAME)) || strcmp(e, "1"))
+		goto out;
+
 	/* LISTEN_PID must be equal to our PID! */
 	if (!(e = getenv(SD_LISTEN_PID_ENV_VAR_NAME)))
 		goto out;
@@ -1729,6 +1734,7 @@
 	}
 
 out:
+	unsetenv(SD_ACTIVATION_ENV_VAR_NAME);
 	unsetenv(SD_LISTEN_PID_ENV_VAR_NAME);
 	unsetenv(SD_LISTEN_FDS_ENV_VAR_NAME);
 	return r;
--- LVM2/libdaemon/server/daemon-server.c	2012/03/08 14:54:05	1.4
+++ LVM2/libdaemon/server/daemon-server.c	2012/03/14 15:51:52	1.5
@@ -69,6 +69,7 @@
 #  define OOM_SCORE_ADJ_MIN (-1000)
 
 /* Systemd on-demand activation support */
+#  define SD_ACTIVATION_ENV_VAR_NAME "SD_ACTIVATION"
 #  define SD_LISTEN_PID_ENV_VAR_NAME "LISTEN_PID"
 #  define SD_LISTEN_FDS_ENV_VAR_NAME "LISTEN_FDS"
 #  define SD_LISTEN_FDS_START 3
@@ -164,6 +165,10 @@
 	unsigned long env_pid, env_listen_fds;
 	int r = 0;
 
+	/* SD_ACTIVATION must be set! */
+	if (!(e = getenv(SD_ACTIVATION_ENV_VAR_NAME)) || strcmp(e, "1"))
+		goto out;
+
 	/* LISTEN_PID must be equal to our PID! */
 	if (!(e = getenv(SD_LISTEN_PID_ENV_VAR_NAME)))
 		goto out;
@@ -188,6 +193,7 @@
 		ds->socket_fd = SD_FD_SOCKET_SERVER;
 
 out:
+	unsetenv(SD_ACTIVATION_ENV_VAR_NAME);
 	unsetenv(SD_LISTEN_PID_ENV_VAR_NAME);
 	unsetenv(SD_LISTEN_FDS_ENV_VAR_NAME);
 	return r;
--- LVM2/scripts/dm_event_systemd_red_hat.service.in	2012/02/01 13:08:39	1.3
+++ LVM2/scripts/dm_event_systemd_red_hat.service.in	2012/03/14 15:51:52	1.4
@@ -9,6 +9,7 @@
 Type=forking
 ExecStart=@sbindir@/dmeventd
 ExecReload=@sbindir@/dmeventd -R
+Environment=SD_ACTIVATION=1
 PIDFile=@DMEVENTD_PIDFILE@
 OOMScoreAdjust=-1000
 
--- LVM2/scripts/lvm2_lvmetad_systemd_red_hat.service.in	2012/03/08 09:49:09	1.4
+++ LVM2/scripts/lvm2_lvmetad_systemd_red_hat.service.in	2012/03/14 15:51:52	1.5
@@ -11,6 +11,7 @@
 ExecStart=@sbindir@/lvmetad
 ExecStartPost=@sbindir@/vgscan
 ExecReload=@sbindir@/lvmetad -R
+Environment=SD_ACTIVATION=1
 Restart=on-abort
 PIDFile=@DEFAULT_RUN_DIR@/lvmetad.pid
 


