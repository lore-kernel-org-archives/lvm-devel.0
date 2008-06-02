From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 2 Jun 2008 15:54:33 -0000
Subject: LVM2/man lvchange.8
Message-ID: <20080602155433.26824.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2008-06-02 15:54:32

Modified files:
	man            : lvchange.8 

Log message:
	Trivial fix to lvchange man pg for consistency.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvchange.8.diff?cvsroot=lvm2&r1=1.15&r2=1.16

--- LVM2/man/lvchange.8	2007/12/05 22:11:20	1.15
+++ LVM2/man/lvchange.8	2008/06/02 15:54:32	1.16
@@ -30,7 +30,7 @@
 libdevmapper to activate (-ay) or deactivate (-an) the 
 logical volumes.
 .IP
-If clustered locking is enabled, -ae will activate exclusively
+If clustered locking is enabled, -aey will activate exclusively
 on one node and -aly will activate only on the local node.
 To deactivate only on the local node use -aln.
 Logical volumes with single-host snapshots are always activated 


