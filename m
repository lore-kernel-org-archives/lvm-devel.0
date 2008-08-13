From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 13 Aug 2008 14:28:18 -0000
Subject: LVM2/test t-covercmd.sh
Message-ID: <20080813142818.1213.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2008-08-13 14:28:18

Modified files:
	test           : t-covercmd.sh 

Log message:
	valid parameter for lvchange -p is 'rw'

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-covercmd.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/test/t-covercmd.sh	2008/08/13 13:49:07	1.1
+++ LVM2/test/t-covercmd.sh	2008/08/13 14:28:17	1.2
@@ -71,7 +71,7 @@
 test_expect_success "test various lvm utils" \
   'lvmdiskscan &&
    for i in dumpconfig formats segtypes ; do lvm $i ; done &&
-   for i in pr pw an ay -refresh  "-monitor y" "-monitor n" \
+   for i in pr \"p rw\" an ay -refresh  "-monitor y" "-monitor n" \
       "-persistent n" -resync \
       "-addtag MYTAG" "-deltag MYTAG"; \
       do lvchange -$i "$vg"/"$lv" ; done &&


