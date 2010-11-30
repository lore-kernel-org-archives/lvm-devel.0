From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 30 Nov 2010 22:16:26 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/clvmd-command.c
Message-ID: <20101130221626.3517.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-11-30 22:16:25

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : clvmd-command.c 

Log message:
	Replace snprintf with dm_snprintf
	
	Use dm_snprintf with known error case return code (-1).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1815&r2=1.1816
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-command.c.diff?cvsroot=lvm2&r1=1.42&r2=1.43

--- LVM2/WHATS_NEW	2010/11/30 22:11:26	1.1815
+++ LVM2/WHATS_NEW	2010/11/30 22:16:25	1.1816
@@ -1,5 +1,6 @@
 Version 2.02.78 - 
 ====================================
+  Replace snprintf with dm_snprintf in clvmd-command.c.
   Check reallocated buffer for NULL before use in clvmd do_command().
   Fix memory leak when VG allocation policy in metadata is invalid.
   Ignore unrecognised allocation policy found in metadata instead of aborting.
--- LVM2/daemons/clvmd/clvmd-command.c	2010/11/30 22:11:26	1.42
+++ LVM2/daemons/clvmd/clvmd-command.c	2010/11/30 22:16:25	1.43
@@ -97,10 +97,10 @@
 		}
 		if (*buf) {
 			uname(&nodeinfo);
-			*retlen = 1 + snprintf(*buf, buflen,
-					       "TEST from %s: %s v%s",
-					       nodeinfo.nodename, args,
-					       nodeinfo.release);
+			*retlen = 1 + dm_snprintf(*buf, buflen,
+						  "TEST from %s: %s v%s",
+						  nodeinfo.nodename, args,
+						  nodeinfo.release);
 		}
 		break;
 
@@ -121,9 +121,8 @@
 		status = do_lock_lv(lock_cmd, lock_flags, lockname);
 		/* Replace EIO with something less scary */
 		if (status == EIO) {
-			*retlen =
-			    1 + snprintf(*buf, buflen, "%s",
-					 get_last_lvm_error());
+			*retlen = 1 + dm_snprintf(*buf, buflen, "%s",
+						  get_last_lvm_error());
 			return EIO;
 		}
 		break;
@@ -133,7 +132,7 @@
 		if (buflen < 3)
 			return EIO;
 		if ((locktype = do_lock_query(lockname)))
-			*retlen = 1 + snprintf(*buf, buflen, "%s", locktype);
+			*retlen = 1 + dm_snprintf(*buf, buflen, "%s", locktype);
 		break;
 
 	case CLVMD_CMD_REFRESH:
@@ -169,8 +168,8 @@
 
 	/* Check the status of the command and return the error text */
 	if (status) {
-		*retlen = 1 + (*buf) ? snprintf(*buf, buflen, "%s",
-						strerror(status)) : -1;
+		*retlen = 1 + (*buf) ? dm_snprintf(*buf, buflen, "%s",
+						   strerror(status)) : -1;
 	}
 
 	return status;
@@ -377,7 +376,7 @@
 	/* Propogate debug options */
 	if (debug) {
 		if (!(debug_arg = malloc(16)) ||
-		    snprintf(debug_arg, 16, "-d%d", (int)debug) < 0)
+		    dm_snprintf(debug_arg, 16, "-d%d", (int)debug) < 0)
 			goto_out;
 		argv[argc++] = debug_arg;
 	}


