From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 1 Mar 2012 22:06:19 -0000
Subject: LVM2 ./WHATS_NEW_DM daemons/dmeventd/dmeventd.c
Message-ID: <20120301220619.24575.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-03-01 22:06:19

Modified files:
	.              : WHATS_NEW_DM 
	daemons/dmeventd: dmeventd.c 

Log message:
	Improve logging
	
	Use %m for strerror.
	Switch to use 0 for fail return code.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.579&r2=1.580
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/dmeventd.c.diff?cvsroot=lvm2&r1=1.92&r2=1.93

--- LVM2/WHATS_NEW_DM	2012/03/01 21:56:44	1.579
+++ LVM2/WHATS_NEW_DM	2012/03/01 22:06:18	1.580
@@ -1,5 +1,6 @@
 Version 1.02.73 - 
 ====================================
+  Improve logging for fifo startup in dmeventd.
   Add few pointer validation in dmsetup.
   Support dm_task_get_driver_version() query without version string.
   Log failure of pthread_join when cleaning unused threads in dmeventd.
--- LVM2/daemons/dmeventd/dmeventd.c	2012/03/01 21:12:39	1.92
+++ LVM2/daemons/dmeventd/dmeventd.c	2012/03/01 22:06:18	1.93
@@ -1245,67 +1245,66 @@
 /* Open fifos used for client communication. */
 static int _open_fifos(struct dm_event_fifos *fifos)
 {
-	int orig_errno;
 	struct stat st;
 
 	/* Create client fifo. */
 	(void) dm_prepare_selinux_context(fifos->client_path, S_IFIFO);
 	if ((mkfifo(fifos->client_path, 0600) == -1) && errno != EEXIST) {
-		syslog(LOG_ERR, "%s: Failed to create client fifo.\n", __func__);
-		orig_errno = errno;
+		syslog(LOG_ERR, "%s: Failed to create client fifo %s: %m.\n",
+		       __func__, fifos->client_path);
 		(void) dm_prepare_selinux_context(NULL, 0);
-		stack;
-		return -orig_errno;
+		return 0;
 	}
 
 	/* Create server fifo. */
 	(void) dm_prepare_selinux_context(fifos->server_path, S_IFIFO);
 	if ((mkfifo(fifos->server_path, 0600) == -1) && errno != EEXIST) {
-		syslog(LOG_ERR, "%s: Failed to create server fifo.\n", __func__);
-		orig_errno = errno;
+		syslog(LOG_ERR, "%s: Failed to create server fifo %s: %m.\n",
+		       __func__, fifos->server_path);
 		(void) dm_prepare_selinux_context(NULL, 0);
-		stack;
-		return -orig_errno;
+		return 0;
 	}
 
 	(void) dm_prepare_selinux_context(NULL, 0);
 
 	/* Warn about wrong permissions if applicable */
 	if ((!stat(fifos->client_path, &st)) && (st.st_mode & 0777) != 0600)
-		syslog(LOG_WARNING, "Fixing wrong permissions on %s",
+		syslog(LOG_WARNING, "Fixing wrong permissions on %s: %m.\n",
 		       fifos->client_path);
 
 	if ((!stat(fifos->server_path, &st)) && (st.st_mode & 0777) != 0600)
-		syslog(LOG_WARNING, "Fixing wrong permissions on %s",
+		syslog(LOG_WARNING, "Fixing wrong permissions on %s: %m.\n",
 		       fifos->server_path);
 
 	/* If they were already there, make sure permissions are ok. */
 	if (chmod(fifos->client_path, 0600)) {
-		syslog(LOG_ERR, "Unable to set correct file permissions on %s",
+		syslog(LOG_ERR, "Unable to set correct file permissions on %s: %m.\n",
 		       fifos->client_path);
-		return -errno;
+		return 0;
 	}
 
 	if (chmod(fifos->server_path, 0600)) {
-		syslog(LOG_ERR, "Unable to set correct file permissions on %s",
+		syslog(LOG_ERR, "Unable to set correct file permissions on %s: %m.\n",
 		       fifos->server_path);
-		return -errno;
+		return 0;
 	}
 
 	/* Need to open read+write or we will block or fail */
 	if ((fifos->server = open(fifos->server_path, O_RDWR)) < 0) {
-		stack;
-		return -errno;
+		syslog(LOG_ERR, "Failed to open fifo server %s: %m.\n",
+		       fifos->server_path);
+		return 0;
 	}
 
 	/* Need to open read+write for select() to work. */
 	if ((fifos->client = open(fifos->client_path, O_RDWR)) < 0) {
-		stack;
-		close(fifos->server);
-		return -errno;
+		syslog(LOG_ERR, "Failed to open fifo client %s: %m", fifos->client_path);
+		if (close(fifos->server))
+			syslog(LOG_ERR, "Failed to close fifo server %s: %m", fifos->server_path);
+		return 0;
 	}
 
-	return 0;
+	return 1;
 }
 
 /*
@@ -1973,7 +1972,7 @@
 
 	pthread_mutex_init(&_global_mutex, NULL);
 
-	if (!_systemd_activation && _open_fifos(&fifos))
+	if (!_systemd_activation && !_open_fifos(&fifos))
 		exit(EXIT_FIFO_FAILURE);
 
 	/* Signal parent, letting them know we are ready to go. */


