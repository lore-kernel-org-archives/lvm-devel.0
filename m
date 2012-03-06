From: agk@sourceware.org <agk@sourceware.org>
Date: 6 Mar 2012 02:54:31 -0000
Subject: LVM2/test/lib aux.sh
Message-ID: <20120306025431.19690.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2012-03-06 02:54:31

Modified files:
	test/lib       : aux.sh 

Log message:
	Change pvscan --cache syntax

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/lib/aux.sh.diff?cvsroot=lvm2&r1=1.40&r2=1.41

--- LVM2/test/lib/aux.sh	2012/03/02 18:09:47	1.40
+++ LVM2/test/lib/aux.sh	2012/03/06 02:54:31	1.41
@@ -334,7 +334,7 @@
 	    min=$(($(stat --printf=0x%T $dev)))
 	    echo "disabling device $dev ($maj:$min)"
             dmsetup remove -f $dev || true
-	    notify_lvmetad $maj:$min
+	    notify_lvmetad --major $maj --minor $min
 	done
 	finish_udev_transaction
 


