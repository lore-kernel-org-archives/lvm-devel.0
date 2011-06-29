From: agk@sourceware.org <agk@sourceware.org>
Date: 29 Jun 2011 12:37:51 -0000
Subject: LVM2/test/lib aux.sh
Message-ID: <20110629123751.16458.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-06-29 12:37:51

Modified files:
	test/lib       : aux.sh 

Log message:
	Add uuids to dmsetup create cmds.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/lib/aux.sh.diff?cvsroot=lvm2&r1=1.14&r2=1.15

--- LVM2/test/lib/aux.sh	2011/06/29 12:33:18	1.14
+++ LVM2/test/lib/aux.sh	2011/06/29 12:37:51	1.15
@@ -116,7 +116,7 @@
 }
 
 make_ioerror() {
-	echo 0 10000000 error | dmsetup create ioerror
+	echo 0 10000000 error | dmsetup create -u TEST-ioerror ioerror
 	ln -s $DM_DEV_DIR/mapper/ioerror $DM_DEV_DIR/ioerror
 }
 
@@ -239,7 +239,7 @@
 		local dev="$DM_DEV_DIR/mapper/$name"
 		devs="$devs $dev"
 		echo 0 $size linear $LOOP $((($i-1)*$size)) > $name.table
-		dmsetup create $name $name.table
+		dmsetup create -u TEST-$name $name $name.table
 	done
 	finish_udev_transaction
 
@@ -271,7 +271,7 @@
 	init_udev_transaction
 	for dev in "$@"; do
 		local name=`echo "$dev" | sed -e 's,.*/,,'`
-		dmsetup create $name $name.table || dmsetup load $name $name.table
+		dmsetup create -u TEST-$name $name $name.table || dmsetup load $name $name.table
 		dmsetup resume $dev
 	done
 	finish_udev_transaction


