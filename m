From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 30 Sep 2008 21:43:16 -0000
Subject: LVM2/test harness.sh
Message-ID: <20080930214316.19342.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2008-09-30 21:43:16

Modified files:
	test           : harness.sh 

Log message:
	Improve harness.sh output: also mention failing test's name near the end of its
	output. Avoids the need to scroll back just to see which failing test you are
	looking at.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/harness.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/test/harness.sh	2008/09/29 15:59:19	1.1
+++ LVM2/test/harness.sh	2008/09/30 21:43:16	1.2
@@ -18,7 +18,8 @@
 	printf -- "--- Output: $t -"
 	for i in `seq $(($len + 14)) 78`; do echo -n "-"; done; echo
 	printf "%s\n" "$out"
-	for i in `seq 1 78`; do echo -n "-"; done; echo
+	printf -- "--- End: $t ----"
+	for i in `seq $(($len + 14)) 78`; do echo -n "-"; done; echo
 	failed="$failed $t"
     fi
 done


