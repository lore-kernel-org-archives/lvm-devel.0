From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 7 Jan 2011 13:04:17 -0000
Subject: LVM2/test/lib aux.sh
Message-ID: <20110107130417.24365.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2011-01-07 13:04:17

Modified files:
	test/lib       : aux.sh 

Log message:
	Disable activation/monitoring in testing lvm.conf by default.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/lib/aux.sh.diff?cvsroot=lvm2&r1=1.3&r2=1.4

--- LVM2/test/lib/aux.sh	2011/01/07 13:03:04	1.3
+++ LVM2/test/lib/aux.sh	2011/01/07 13:04:17	1.4
@@ -52,7 +52,9 @@
             exit 1
         }
 
-	dmeventd -f &
+        lvmconf "activation/monitoring = 1"
+
+	dmeventd -f "$@" &
 	echo "$!" > LOCAL_DMEVENTD
 }
 
@@ -335,6 +337,7 @@
 activation/polling_interval = 0
 activation/snapshot_autoextend_percent = 50
 activation/snapshot_autoextend_threshold = 50
+activation/monitoring = 0
 EOF
     }
 


