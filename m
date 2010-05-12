From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 12 May 2010 13:15:39 -0000
Subject: LVM2/test t-lvconvert-mirror-basic.sh t-lvconv ...
Message-ID: <20100512131539.28715.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2010-05-12 13:15:38

Modified files:
	test           : t-lvconvert-mirror-basic.sh 
Added files:
	test           : t-lvconvert-mirror-basic-0.sh 
	                 t-lvconvert-mirror-basic-1.sh 
	                 t-lvconvert-mirror-basic-2.sh 
	                 t-lvconvert-mirror-basic-3.sh 

Log message:
	Chop up the big t-lvconvert-mirror-basic loop across 4 separate test scripts
	(and use sourcing to avoid code duplication).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvconvert-mirror-basic-0.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvconvert-mirror-basic-1.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvconvert-mirror-basic-2.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvconvert-mirror-basic-3.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvconvert-mirror-basic.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2

/cvs/lvm2/LVM2/test/t-lvconvert-mirror-basic-0.sh,v  -->  standard output
revision 1.1
--- LVM2/test/t-lvconvert-mirror-basic-0.sh
+++ -	2010-05-12 13:15:39.141989000 +0000
@@ -0,0 +1,2 @@
+. ./t-lvconvert-mirror-basic.sh
+test_many 0
/cvs/lvm2/LVM2/test/t-lvconvert-mirror-basic-1.sh,v  -->  standard output
revision 1.1
--- LVM2/test/t-lvconvert-mirror-basic-1.sh
+++ -	2010-05-12 13:15:39.225899000 +0000
@@ -0,0 +1,2 @@
+. ./t-lvconvert-mirror-basic.sh
+test_many 1
/cvs/lvm2/LVM2/test/t-lvconvert-mirror-basic-2.sh,v  -->  standard output
revision 1.1
--- LVM2/test/t-lvconvert-mirror-basic-2.sh
+++ -	2010-05-12 13:15:39.310482000 +0000
@@ -0,0 +1,2 @@
+. ./t-lvconvert-mirror-basic.sh
+test_many 2
/cvs/lvm2/LVM2/test/t-lvconvert-mirror-basic-3.sh,v  -->  standard output
revision 1.1
--- LVM2/test/t-lvconvert-mirror-basic-3.sh
+++ -	2010-05-12 13:15:39.395233000 +0000
@@ -0,0 +1,2 @@
+. ./t-lvconvert-mirror-basic.sh
+test_many 3
--- LVM2/test/t-lvconvert-mirror-basic.sh	2010/05/12 10:08:35	1.1
+++ LVM2/test/t-lvconvert-mirror-basic.sh	2010/05/12 13:15:38	1.2
@@ -121,9 +121,9 @@
 
 aux prepare_vg 5
 
-# Test conversion combinations from linear <-> 4-way mirrors
-for i in $(seq 0 4); do
-	for j in $(seq 0 4); do
+test_many() {
+	i=$1
+	for j in $(seq 0 3); do
 		for k in core disk mirrored; do
 			for l in core disk mirrored; do
 				if test "$i" -eq "$j" && test "$k" = "$l"; then continue; fi
@@ -135,5 +135,4 @@
 			done
 		done
 	done
-done
-
+}


