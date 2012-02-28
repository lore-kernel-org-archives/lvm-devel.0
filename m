From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 28 Feb 2012 09:58:20 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/clvmd.c
Message-ID: <20120228095820.11462.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-02-28 09:58:20

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : clvmd.c 

Log message:
	Limit max size of clvmd message
	
	This could be seen as some sort of simple validation - it's not easy to
	recognize a valid message for now - but we definitely do not want to
	allocate a lot of megabytes in  clvmd memory locked daemon when broken
	message gets in.
	
	Size of 8000 is just selected for now - possibly there could be much
	lower value put in.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2319&r2=1.2320
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd.c.diff?cvsroot=lvm2&r1=1.125&r2=1.126

--- LVM2/WHATS_NEW	2012/02/28 09:53:55	1.2319
+++ LVM2/WHATS_NEW	2012/02/28 09:58:19	1.2320
@@ -1,5 +1,6 @@
 Version 2.02.94 - 
 ====================================
+  Limit the max size of processed clvmd message to ~8KB.
   Do not send uninitilised bytes in cluster error reply messages.
   Use unsigned type for bitmask instead of enum type for lvm properties.
   Add missing cleanup of excl_uuid hash on some exit paths of clvmd.
--- LVM2/daemons/clvmd/clvmd.c	2012/02/28 09:53:55	1.125
+++ LVM2/daemons/clvmd/clvmd.c	2012/02/28 09:58:20	1.126
@@ -49,6 +49,7 @@
 #endif
 
 #define MAX_RETRIES 4
+#define MAX_MISSING_LEN = 8000 /* Max supported clvmd message size ? */
 
 #define ISLOCAL_CSID(c) (memcmp(c, our_csid, max_csid_len) == 0)
 
@@ -1204,7 +1205,8 @@
 			missing_len = 0;
 
 		/* We need at least sizeof(struct clvm_header) bytes in buffer */
-		if (len < sizeof(struct clvm_header) || argslen < 0) {
+		if (len < sizeof(struct clvm_header) || argslen < 0 ||
+		    missing_len > MAX_MISSING_LEN) {
 			struct clvm_header reply = {
 				.cmd = CLVMD_CMD_REPLY,
 				.status = EINVAL


