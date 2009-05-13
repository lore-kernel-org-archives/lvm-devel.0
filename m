From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 13 May 2009 19:18:48 -0000
Subject: LVM2/test test-utils.sh
Message-ID: <20090513191848.32327.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-05-13 19:18:47

Modified files:
	test           : test-utils.sh 

Log message:
	Update test-utils to cope with ":" in device names and allow configurable names.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/test-utils.sh.diff?cvsroot=lvm2&r1=1.11&r2=1.12

--- LVM2/test/test-utils.sh	2009/04/24 08:00:48	1.11
+++ LVM2/test/test-utils.sh	2009/05/13 19:18:47	1.12
@@ -33,7 +33,7 @@
 	test -n "$PREFIX" && {
 		rm -rf $G_root_/dev/$PREFIX*
 		while dmsetup table | grep -q ^$PREFIX; do
-			for s in `dmsetup table | grep ^$PREFIX| cut -f1 -d:`; do
+			for s in `dmsetup table | grep ^$PREFIX| awk '{ print substr($1,1,length($1)-1) }'`; do
 				dmsetup resume $s 2>/dev/null > /dev/null || true
 				dmsetup remove $s 2>/dev/null > /dev/null || true
 			done
@@ -99,6 +99,8 @@
 	test -z "$n" && n=3
 	local devsize="$2"
 	test -z "$devsize" && devsize=33
+	local pvname="$3"
+	test -z "$pvname" && pvname="pv"
 
 	prepare_loop $(($n*$devsize))
 
@@ -111,7 +113,7 @@
 	local size=$(($loopsz/$n))
 
 	for i in `seq 1 $n`; do
-		local name="${PREFIX}pv$i"
+		local name="${PREFIX}$pvname$i"
 		local dev="$G_dev_/mapper/$name"
 		eval "dev$i=$dev"
 		devs="$devs $dev"


