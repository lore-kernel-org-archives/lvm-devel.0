From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 27 Jun 2011 12:26:55 -0000
Subject: LVM2/daemons/common daemon-client.h
Message-ID: <20110627122655.2356.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2011-06-27 12:26:54

Modified files:
	daemons/common : daemon-client.h 

Log message:
	Sketch out the actual on-wire format in daemon-client.h documentation, and add
	a simplified send interface.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/common/daemon-client.h.diff?cvsroot=lvm2&r1=1.3&r2=1.4

--- LVM2/daemons/common/daemon-client.h	2011/06/14 02:34:18	1.3
+++ LVM2/daemons/common/daemon-client.h	2011/06/27 12:26:54	1.4
@@ -20,7 +20,6 @@
 typedef struct {
 	int socket_fd; /* the fd we use to talk to the daemon */
 	int protocol;  /* version of the protocol the daemon uses */
-	char *read_buf;
 } daemon_handle;
 
 typedef struct {
@@ -31,6 +30,17 @@
 
 typedef struct {
 	char *buffer;
+	/*
+	 * The request looks like this:
+	 *    request = "id"
+	 *    arg_foo = "something"
+	 *    arg_bar = 3
+	 *    arg_wibble {
+	 *        something_special = "here"
+	 *        amount = 75
+	 *        knobs = [ "twiddle", "tweak" ]
+	 *    }
+	 */
 	struct config_node *cft;
 } daemon_request;
 
@@ -53,9 +63,22 @@
  * Send a request to the daemon, waiting for the reply. All communication with
  * the daemon is synchronous. The function handles the IO details and parses the
  * response, handling common error conditions. See "daemon_reply" for details.
+ *
+ * In case the request contains a non-NULL buffer pointer, this buffer is sent
+ * *verbatim* to the server. In this case, the cft pointer may be NULL (but will
+ * be ignored even if non-NULL). If the buffer is NULL, the cft is required to
+ * be a valid pointer, and is used to build up the request.
  */
 daemon_reply daemon_send(daemon_handle h, daemon_request r);
 
+/*
+ * A simple interface to daemon_send. This function just takes the command id
+ * and possibly a list of parameters (of the form "name = %?", "value"). The
+ * type (string, integer) of the value is indicated by a character substituted
+ * for ? in %?: d for integer, s for string.
+ */
+daemon_reply daemon_send_simple(daemon_handle h, char *id, ...);
+
 /* Shut down the communication to the daemon. Compulsory. */
 void daemon_close(daemon_handle h);
 


