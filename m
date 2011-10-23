From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 23 Oct 2011 15:43:11 -0000
Subject: LVM2/test/lib aux.sh
Message-ID: <20111023154311.23637.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-10-23 15:43:10

Modified files:
	test/lib       : aux.sh 

Log message:
	Used device name instead of device path
	
	Udev is tricky here - since with udev the node does not exists until
	it resume happens.  So we need to resume devices via its name.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/lib/aux.sh.diff?cvsroot=lvm2&r1=1.32&r2=1.33

--- LVM2/test/lib/aux.sh	2011/10/23 15:40:15	1.32
+++ LVM2/test/lib/aux.sh	2011/10/23 15:43:10	1.33
@@ -333,7 +333,8 @@
 	for dev in "$@"; do
 		local name=`echo "$dev" | sed -e 's,.*/,,'`
 		dmsetup create -u TEST-$name $name $name.table || dmsetup load $name $name.table
-		dmsetup resume $dev
+		# using device name (since device path does not exists yes with udev)
+		dmsetup resume $name
 	done
 	finish_udev_transaction
 }


