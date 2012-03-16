From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 16 Mar 2012 19:13:10 -0000
Subject: LVM2/test/shell dumpconfig.sh
Message-ID: <20120316191310.22319.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-03-16 19:13:10

Modified files:
	test/shell     : dumpconfig.sh 

Log message:
	Add comment about slow startup of dmeventd
	
	Separat lvm dumpconfig on extra line, so the shell trace output
	is not mixed with dump.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/dumpconfig.sh.diff?cvsroot=lvm2&r1=1.2&r2=1.3

--- LVM2/test/shell/dumpconfig.sh	2012/03/16 13:00:06	1.2
+++ LVM2/test/shell/dumpconfig.sh	2012/03/16 19:13:09	1.3
@@ -12,24 +12,34 @@
 . lib/test
 
 flatten() {
-    cat > flatten.config
-
-    for s in `egrep '^[a-z]+ {$' flatten.config | sed -e s,{$,,`; do
-	sed -e "/^$s/,/^}/p;d" flatten.config | sed -e '1d;$d' | sed -e "s,^[ \t]*,$s/,";
-    done
+	cat > flatten.config
+	for s in `egrep '^[a-z]+ {$' flatten.config | sed -e s,{$,,`; do
+		sed -e "/^$s/,/^}/p;d" flatten.config | sed -e '1d;$d' | sed -e "s,^[ \t]*,$s/,";
+	done
 }
 
-lvm dumpconfig | flatten | sort > config.dump
-flatten < etc/lvm.conf | sort > config.input
+# clvmd might not be started fast enough and
+# lvm still activates locking for all commands.
+# FIXME: Either make longer start delay,
+#  or even better do not initialize
+#  locking for commands like 'dumpconfig'
+#aux lvmconf "global/locking_type=0"
 
+lvm dumpconfig -f lvmdumpconfig
+flatten < lvmdumpconfig | sort > config.dump
+flatten < etc/lvm.conf | sort > config.input
 # check that dumpconfig output corresponds to the lvm.conf input
 diff -wu config.input config.dump
 
 # and that merging multiple config files (through tags) works
-lvm dumpconfig | flatten | not grep 'log/verbose=1'
-lvm dumpconfig | flatten | grep 'log/indent=1'
+lvm dumpconfig -f lvmdumpconfig
+flatten < lvmdumpconfig | not grep 'log/verbose=1'
+lvm dumpconfig -f lvmdumpconfig
+flatten < lvmdumpconfig | grep 'log/indent=1'
 
 aux lvmconf 'tags/@foo {}'
 echo 'log { verbose = 1 }' > etc/lvm_foo.conf
-lvm dumpconfig | flatten | grep 'log/verbose=1'
-lvm dumpconfig | flatten | grep 'log/indent=1'
+lvm dumpconfig -f lvmdumpconfig
+flatten < lvmdumpconfig | grep 'log/verbose=1'
+lvm dumpconfig -f lvmdumpconfig
+flatten < lvmdumpconfig | grep 'log/indent=1'


