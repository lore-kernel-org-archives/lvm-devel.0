From: agk@sourceware.org <agk@sourceware.org>
Date: 23 Mar 2010 14:35:10 -0000
Subject: LVM2/daemons/clvmd clvmd-comms.h
Message-ID: <20100323143510.31787.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-03-23 14:35:09

Modified files:
	daemons/clvmd  : clvmd-comms.h 

Log message:
	Avoid duplicate definitions.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-comms.h.diff?cvsroot=lvm2&r1=1.11&r2=1.12

--- LVM2/daemons/clvmd/clvmd-comms.h	2010/03/18 09:19:31	1.11
+++ LVM2/daemons/clvmd/clvmd-comms.h	2010/03/23 14:35:08	1.12
@@ -112,9 +112,13 @@
 
 #ifdef USE_SINGLENODE
 #  define SINGLENODE_CSID_LEN (sizeof(int))
-#  define MAX_CLUSTER_MEMBER_NAME_LEN       64
+#  ifndef MAX_CLUSTER_MEMBER_NAME_LEN
+#    define MAX_CLUSTER_MEMBER_NAME_LEN       64
+#  endif
 #  define SINGLENODE_MAX_CLUSTER_MESSAGE          65535
-#  define MAX_CSID_LEN sizeof(int)
+#  ifndef MAX_CSID_LEN
+#    define MAX_CSID_LEN sizeof(int)
+#  endif
 struct cluster_ops *init_singlenode_cluster(void);
 #endif
 


