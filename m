From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 1 Mar 2012 21:12:45 -0000
Subject: LVM2 daemons/clvmd/clvmd.c daemons/dmeventd/dm ...
Message-ID: <20120301211245.7047.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-03-01 21:12:40

Modified files:
	daemons/clvmd  : clvmd.c 
	daemons/dmeventd: dmeventd.c 
	lib/config     : config.c 
	lib/locking    : file_locking.c 
	lib/log        : log.c 
	libdaemon/client: daemon-client.c 
	libdaemon/server: daemon-server.c 
	tools          : lvmdiskscan.c 

Log message:
	Few more close and dev_close trace
	
	Adding (void) where we cannot really report an error.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd.c.diff?cvsroot=lvm2&r1=1.129&r2=1.130
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/dmeventd.c.diff?cvsroot=lvm2&r1=1.91&r2=1.92
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/config.c.diff?cvsroot=lvm2&r1=1.113&r2=1.114
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/file_locking.c.diff?cvsroot=lvm2&r1=1.63&r2=1.64
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/log/log.c.diff?cvsroot=lvm2&r1=1.69&r2=1.70
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdaemon/client/daemon-client.c.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdaemon/server/daemon-server.c.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmdiskscan.c.diff?cvsroot=lvm2&r1=1.23&r2=1.24

--- LVM2/daemons/clvmd/clvmd.c	2012/02/28 11:06:56	1.129
+++ LVM2/daemons/clvmd/clvmd.c	2012/03/01 21:12:37	1.130
@@ -1052,11 +1052,11 @@
 		exit(2);
 
 	case 0:		/* Child */
-	        close(child_pipe[0]);
+		(void) close(child_pipe[0]);
 		break;
 
 	default:       /* Parent */
-		close(child_pipe[1]);
+		(void) close(child_pipe[1]);
 		wait_for_child(child_pipe[0], timeout);
 	}
 
@@ -1140,8 +1140,8 @@
 				struct local_client *lastfd = NULL;
 				struct local_client *free_fd = NULL;
 
-				close(thisfd->bits.localsock.pipe_client->fd);	/* Close pipe */
-				close(thisfd->bits.localsock.pipe);
+				(void) close(thisfd->bits.localsock.pipe_client->fd);	/* Close pipe */
+				(void) close(thisfd->bits.localsock.pipe);
 
 				/* Remove pipe client */
 				for (newfd = &local_client_head; newfd != NULL;
@@ -1329,8 +1329,8 @@
 				.status = ENOMEM
 			};
 
-			close(comms_pipe[0]);
-			close(comms_pipe[1]);
+			(void) close(comms_pipe[0]);
+			(void) close(comms_pipe[1]);
 
 			send_message(&reply, sizeof(reply), our_csid,
 				     thisfd->fd,
@@ -2107,7 +2107,9 @@
 		ret = -1;
 	}
 
-	close(local_socket);
+	if (close(local_socket))
+		log_sys_error("close", "local socket");
+
 	return ret;
 }
 
--- LVM2/daemons/dmeventd/dmeventd.c	2012/03/01 09:50:04	1.91
+++ LVM2/daemons/dmeventd/dmeventd.c	2012/03/01 21:12:39	1.92
@@ -1803,7 +1803,7 @@
 		    (fd == SD_FD_FIFO_SERVER || fd == SD_FD_FIFO_CLIENT))
 			continue;
 #endif
-		close(fd);
+		(void) close(fd);
 	}
 
 	if ((open("/dev/null", O_RDONLY) < 0) ||
--- LVM2/lib/config/config.c	2012/02/23 22:36:21	1.113
+++ LVM2/lib/config/config.c	2012/03/01 21:12:39	1.114
@@ -150,7 +150,8 @@
 	struct config_file *cf = dm_config_get_custom(cft);
 
 	if (cf && cf->dev)
-		dev_close(cf->dev);
+		if (!dev_close(cf->dev))
+			stack;
 
 	dm_config_destroy(cft);
 }
@@ -275,7 +276,8 @@
 				(checksum_fn_t) NULL, 0);
 
 	if (!cf->keep_open) {
-		dev_close(cf->dev);
+		if (!dev_close(cf->dev))
+			stack;
 		cf->dev = NULL;
 	}
 
--- LVM2/lib/locking/file_locking.c	2012/02/08 11:17:35	1.63
+++ LVM2/lib/locking/file_locking.c	2012/03/01 21:12:39	1.64
@@ -161,7 +161,8 @@
 		if (r) {
 			errno = old_errno;
 			log_sys_error("flock", file);
-			close(*fd);
+			if (close(*fd))
+				log_sys_error("close", file);
 			return 0;
 		}
 
--- LVM2/lib/log/log.c	2012/02/27 11:31:30	1.69
+++ LVM2/lib/log/log.c	2012/03/01 21:12:39	1.70
@@ -110,7 +110,7 @@
 void fin_log(void)
 {
 	if (_log_direct) {
-		dev_close(&_log_dev);
+		(void) dev_close(&_log_dev);
 		_log_direct = 0;
 	}
 
--- LVM2/libdaemon/client/daemon-client.c	2012/02/28 18:35:05	1.2
+++ LVM2/libdaemon/client/daemon-client.c	2012/03/01 21:12:40	1.3
@@ -57,7 +57,8 @@
 error:
 	h.error = errno;
 	if (h.socket_fd >= 0)
-		close(h.socket_fd);
+		if (close(h.socket_fd))
+			perror("close");
 	if (r.cft)
 		daemon_reply_destroy(r);
 	h.socket_fd = -1;
--- LVM2/libdaemon/server/daemon-server.c	2012/02/28 18:35:05	1.2
+++ LVM2/libdaemon/server/daemon-server.c	2012/03/01 21:12:40	1.3
@@ -306,7 +306,7 @@
 		if (_systemd_activation && fd == SD_FD_SOCKET_SERVER)
 			continue;
 #endif
-		close(fd);
+		(void) close(fd);
 	}
 
 	if ((open("/dev/null", O_RDONLY) < 0) ||
@@ -407,7 +407,8 @@
 	}
 fail:
 	/* TODO what should we really do here? */
-	close(b->client.socket_fd);
+	if (close(b->client.socket_fd))
+		perror("close");
 	free(baton);
 	return NULL;
 }
--- LVM2/tools/lvmdiskscan.c	2012/01/25 22:20:11	1.23
+++ LVM2/tools/lvmdiskscan.c	2012/03/01 21:12:40	1.24
@@ -72,11 +72,13 @@
 	char buffer;
 	uint64_t size;
 
-	if (!dev_open_readonly(dev)) {
-		return 0;
-	}
+	if (!dev_open_readonly(dev))
+		return_0;
+
 	if (!dev_read(dev, UINT64_C(0), (size_t) 1, &buffer)) {
-		dev_close(dev);
+		stack;
+		if (!dev_close(dev))
+			stack;
 		return 0;
 	}
 	if (!dev_get_size(dev, &size)) {


