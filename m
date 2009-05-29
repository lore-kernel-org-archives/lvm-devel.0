From: snitzer@sourceware.org <snitzer@sourceware.org>
Date: 29 May 2009 18:54:49 -0000
Subject: LVM2/scripts clvmd_init_red_hat.in
Message-ID: <20090529185449.27305.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	snitzer at sourceware.org	2009-05-29 18:54:49

Modified files:
	scripts        : clvmd_init_red_hat.in 

Log message:
	Fix 'service-default-enabled' rpmlint in clvmd initscript

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/clvmd_init_red_hat.in.diff?cvsroot=lvm2&r1=1.3&r2=1.4

--- LVM2/scripts/clvmd_init_red_hat.in	2009/05/29 18:34:10	1.3
+++ LVM2/scripts/clvmd_init_red_hat.in	2009/05/29 18:54:48	1.4
@@ -9,7 +9,7 @@
 # Provides: clvmd
 # Required-Start: $local_fs
 # Required-Stop: $local_fs
-# Default-Start: 2 3 4 5
+# Default-Start:
 # Default-Stop: 0 1 6
 # Short-Description: Clustered LVM Daemon
 ### END INIT INFO


