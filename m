From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 12 Mar 2012 14:18:30 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/metadata.c
Message-ID: <20120312141830.20564.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-03-12 14:18:29

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : metadata.c 

Log message:
	Switch to normal log_verbose message
	
	Here it's not an error case - so do not push this message to stderr.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2350&r2=1.2351
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.497&r2=1.498

--- LVM2/WHATS_NEW	2012/03/12 14:15:04	1.2350
+++ LVM2/WHATS_NEW	2012/03/12 14:18:28	1.2351
@@ -1,5 +1,6 @@
 Version 2.02.96 - 
 ================================
+  Change message severity for creation of VG over uninitialised devices.
   Fix error path for failing toolcontext creation.
   Fix warn msg for thin pool chunk size and update man for chunksize (2.02.89).
 
--- LVM2/lib/metadata/metadata.c	2012/03/02 20:46:37	1.497
+++ LVM2/lib/metadata/metadata.c	2012/03/12 14:18:29	1.498
@@ -1468,8 +1468,8 @@
 			stack;
 	}
 
-	log_error("Writing physical volume data to disk \"%s\"",
-			 pv_name);
+	log_verbose("Writing physical volume data to disk \"%s\"",
+		    pv_name);
 
 	if (!(pv_write(cmd, pv, 1))) {
 		log_error("Failed to write physical volume \"%s\"", pv_name);


