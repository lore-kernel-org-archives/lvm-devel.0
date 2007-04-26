From: Jim Meyering <jim@meyering.net>
Date: Thu, 26 Apr 2007 18:21:04 +0200
Subject: clvmd-command.c: unchecked realloc return value: potential DoS?
Message-ID: <87ejm72jkf.fsf@rho.meyering.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

While this "case:" is solely for CLVMD_CMD_TEST, which is documented like this:

  #define CLVMD_CMD_TEST     4	/* Just for mucking about */

we wouldn't want a malicious client to be able to DoS a server
by provoking a low-memory condition and then sending a test message.

Here's the code:

int do_command(struct local_client *client, struct clvm_header *msg, int msglen,
	       char **buf, int buflen, int *retlen)
{
	...
	switch (msg->cmd) {
		/* Just a test message */
	case CLVMD_CMD_TEST:
		if (arglen > buflen) {
			buflen = arglen + 200;
			*buf = realloc(*buf, buflen);
		}
		uname(&nodeinfo);
		*retlen = 1 + snprintf(*buf, buflen, "TEST from %s: %s v%s",
				       nodeinfo.nodename, args,
				       nodeinfo.release);
		break;

Here's an untested patch:

	* daemons/clvmd/clvmd-command.c (do_command): Don't dereference NULL
	upon failed realloc.

Index: daemons/clvmd/clvmd-command.c
===================================================================
RCS file: /cvs/lvm2/LVM2/daemons/clvmd/clvmd-command.c,v
retrieving revision 1.14
diff -u -p -r1.14 clvmd-command.c
--- daemons/clvmd/clvmd-command.c	11 Dec 2006 14:00:26 -0000	1.14
+++ daemons/clvmd/clvmd-command.c	26 Apr 2007 16:10:17 -0000
@@ -95,13 +95,22 @@ int do_command(struct local_client *clie
 		/* Just a test message */
 	case CLVMD_CMD_TEST:
 		if (arglen > buflen) {
+			char *new_buf;
 			buflen = arglen + 200;
-			*buf = realloc(*buf, buflen);
+			new_buf = realloc(*buf, buflen);
+			if (new_buf == NULL) {
+				status = errno;
+				free (*buf);
+			}
+			*buf = new_buf;
+		}
+		if (*buf) {
+			uname(&nodeinfo);
+			*retlen = 1 + snprintf(*buf, buflen,
+					       "TEST from %s: %s v%s",
+					       nodeinfo.nodename, args,
+					       nodeinfo.release);
 		}
-		uname(&nodeinfo);
-		*retlen = 1 + snprintf(*buf, buflen, "TEST from %s: %s v%s",
-				       nodeinfo.nodename, args,
-				       nodeinfo.release);
 		break;

 	case CLVMD_CMD_LOCK_VG:

------------------------------
BTW, in the same function, I noticed that "*retlen" is not set consistently.
In the CLVMD_CMD_TEST and CLVMD_CMD_LOCK_VG cases, it's set to
"1 + snprintf(...)", so it includes the trailing NUL byte.
But here, it doesn't:

	case CLVMD_CMD_GET_CLUSTERNAME:
		status = clops->get_cluster_name(*buf, buflen);
		if (!status)
			*retlen = strlen(*buf);
		break;

I don't know enough to say whether there's a bug, but it's worth
fixing in any case, e.g.,

			*retlen = 1 + strlen(*buf);


