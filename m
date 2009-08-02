From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 2 Aug 2009 21:45:45 -0000
Subject: LVM2/test test-utils.sh t-vgsplit-stacked.sh
Message-ID: <20090802214545.8477.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2009-08-02 21:45:45

Modified files:
	test           : test-utils.sh 
Added files:
	test           : t-vgsplit-stacked.sh 

Log message:
	Add test for RHBZ 481793 (passing, thanks to vg_read changes checked in
	previously).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgsplit-stacked.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/test-utils.sh.diff?cvsroot=lvm2&r1=1.13&r2=1.14

/cvs/lvm2/LVM2/test/t-vgsplit-stacked.sh,v  -->  standard output
revision 1.1
--- LVM2/test/t-vgsplit-stacked.sh
+++ -	2009-08-02 21:45:45.854012000 +0000
@@ -0,0 +1,18 @@
+. ./test-utils.sh
+
+prepare_lvmconf '[ "a/dev\/mirror/", "a/dev\/mapper\/.*$/", "r/.*/" ]'
+aux prepare_devs 3
+
+pvcreate $devs
+vgcreate $vg1 $dev1 $dev2
+lvcreate -n $lv1 -l 100%FREE $vg1
+
+#top VG
+pvcreate $G_dev_/$vg1/$lv1
+vgcreate $vg $G_dev_/$vg1/$lv1 $dev3
+
+vgchange -a n $vg
+vgchange -a n $vg1
+
+# this should fail but not segfault, RHBZ 481793.
+not vgsplit $vg $vg1 $dev3
--- LVM2/test/test-utils.sh	2009/05/13 21:29:10	1.13
+++ LVM2/test/test-utils.sh	2009/08/02 21:45:45	1.14
@@ -178,11 +178,14 @@
 }
 
 prepare_lvmconf() {
+	local filter="$1"
+	test -z "$filter" && \
+		filter='[ "a/dev\/mirror/", "a/dev\/mapper\/.*pv[0-9_]*$/", "r/.*/" ]'
 	cat > $G_root_/etc/lvm.conf <<-EOF
   devices {
     dir = "$G_dev_"
     scan = "$G_dev_"
-    filter = [ "a/dev\/mirror/", "a/dev\/mapper\/.*pv[0-9_]*$/", "r/.*/" ]
+    filter = $filter
     cache_dir = "$G_root_/etc"
     sysfs_scan = 0
   }


