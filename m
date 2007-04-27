From: Jim Meyering <jim@meyering.net>
Date: Fri, 27 Apr 2007 18:02:55 +0200
Subject: more warning-removal patches
Message-ID: <87vefhyfdc.fsf@rho.meyering.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

These changes remove the last of the -Wformat-security warnings:

	* daemons/clvmd/clvmd-command.c (do_command): Avoid using
	a non-literal snprintf format string.  Use "%s".
	* daemons/clvmd/clvmd.c (send_message): Likewise, but for log_error.
	* daemons/clvmd/clvmd-cman.c (_cluster_send_message): Likewise.

Index: daemons/clvmd/clvmd-command.c
===================================================================
RCS file: /cvs/lvm2/LVM2/daemons/clvmd/clvmd-command.c,v
retrieving revision 1.14
diff -u -p -r1.14 clvmd-command.c
--- daemons/clvmd/clvmd-command.c	11 Dec 2006 14:00:26 -0000	1.14
+++ daemons/clvmd/clvmd-command.c	27 Apr 2007 16:01:01 -0000
@@ -118,7 +118,7 @@ int do_command(struct local_client *clie
 		/* Replace EIO with something less scary */
 		if (status == EIO) {
 			*retlen =
-			    1 + snprintf(*buf, buflen,
+			    1 + snprintf(*buf, buflen, "%s",
 					 get_last_lvm_error());
 			return EIO;
 		}
@@ -141,7 +141,7 @@ int do_command(struct local_client *clie

 	/* Check the status of the command and return the error text */
 	if (status) {
-		*retlen = 1 + snprintf(*buf, buflen, strerror(status));
+		*retlen = 1 + snprintf(*buf, buflen, "%s", strerror(status));
 	}

 	return status;
Index: daemons/clvmd/clvmd.c
===================================================================
RCS file: /cvs/lvm2/LVM2/daemons/clvmd/clvmd.c,v
retrieving revision 1.34
diff -u -p -r1.34 clvmd.c
--- daemons/clvmd/clvmd.c	29 Mar 2007 13:59:33 -0000	1.34
+++ daemons/clvmd/clvmd.c	27 Apr 2007 16:01:02 -0000
@@ -1701,7 +1701,7 @@ static int send_message(void *buf, int m
 			if (retry_cnt > MAX_RETRIES)
 			{
 				errno = saved_errno;
-				log_error(errtext);
+				log_error("%s", errtext);
 				errno = saved_errno;
 				break;
 			}
@@ -1725,7 +1725,7 @@ static int send_message(void *buf, int m

 					continue;
 				}
-				log_error(errtext);
+				log_error("%s", errtext);
 				break;
 			}
 			ptr += len;
Index: daemons/clvmd/clvmd-cman.c
===================================================================
RCS file: /cvs/lvm2/LVM2/daemons/clvmd/clvmd-cman.c,v
retrieving revision 1.17
diff -u -p -r1.17 clvmd-cman.c
--- daemons/clvmd/clvmd-cman.c	23 Apr 2007 14:55:28 -0000	1.17
+++ daemons/clvmd/clvmd-cman.c	27 Apr 2007 16:01:02 -0000
@@ -137,7 +137,7 @@ static int _cluster_send_message(void *b

 	if (cman_send_data(c_handle, buf, msglen, 0, CLUSTER_PORT_CLVMD, nodeid) <= 0)
 	{
-		log_error(errtext);
+		log_error("%s", errtext);
 	}
 	return msglen;
 }


