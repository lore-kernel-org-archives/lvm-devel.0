From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 10 Mar 2012 10:39:28 -0000
Subject: LVM2/daemons/clvmd clvm.h
Message-ID: <20120310103928.27875.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2012-03-10 10:39:28

Modified files:
	daemons/clvmd  : clvm.h 

Log message:
	Remove some whitespaces.
	(Test commit.)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvm.h.diff?cvsroot=lvm2&r1=1.11&r2=1.12

--- LVM2/daemons/clvmd/clvm.h	2012/01/21 05:31:54	1.11
+++ LVM2/daemons/clvmd/clvm.h	2012/03/10 10:39:28	1.12
@@ -30,14 +30,14 @@
 	uint16_t xid;	        /* Transaction ID */
 	uint32_t clientid;	/* Only used in Daemon->Daemon comms */
 	int32_t  status;	/* For replies, whether request succeeded */
-	uint32_t arglen;	/* Length of argument below. 
-				   If >1500 then it will be passed 
+	uint32_t arglen;	/* Length of argument below.
+				   If >1500 then it will be passed
 				   around the cluster in the system LV */
 	char node[1];		/* Actually a NUL-terminated string, node name.
-				   If this is empty then the command is 
-				   forwarded to all cluster nodes unless 
+				   If this is empty then the command is
+				   forwarded to all cluster nodes unless
 				   FLAG_LOCAL or FLAG_REMOTE is also set. */
-	char args[1];		/* Arguments for the command follow the 
+	char args[1];		/* Arguments for the command follow the
 				   node name, This member is only
 				   valid if the node name is empty */
 } __attribute__ ((packed));
@@ -54,7 +54,7 @@
 /* Internal commands & replies */
 #define CLVMD_CMD_REPLY    1
 #define CLVMD_CMD_VERSION  2	/* Send version around cluster when we start */
-#define CLVMD_CMD_GOAWAY   3	/* Die if received this - we are running 
+#define CLVMD_CMD_GOAWAY   3	/* Die if received this - we are running
 				   an incompatible version */
 #define CLVMD_CMD_TEST     4	/* Just for mucking about */
 


