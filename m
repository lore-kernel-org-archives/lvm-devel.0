From: snitzer@sourceware.org <snitzer@sourceware.org>
Date: 17 Mar 2010 14:55:30 -0000
Subject: LVM2 ./WHATS_NEW test/test-utils.sh
Message-ID: <20100317145530.26250.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	snitzer at sourceware.org	2010-03-17 14:55:28

Modified files:
	.              : WHATS_NEW 
	test           : test-utils.sh 

Log message:
	testsuite: get stacktrace if test drops core
	
	Requires lvm be built with debugging (-g).
	Also requires 'ulimit -c' be non-zero (to drop core file).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1467&r2=1.1468
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/test-utils.sh.diff?cvsroot=lvm2&r1=1.21&r2=1.22

--- LVM2/WHATS_NEW	2010/03/17 14:45:28	1.1467
+++ LVM2/WHATS_NEW	2010/03/17 14:55:28	1.1468
@@ -1,5 +1,6 @@
 Version 2.02.63 - 
 ================================
+  Get stacktrace if testsuite test drops core and lvm was built with debugging.
   Disable long living process flag in lvm2app.
   Fix pvcreate device md filter check.
   Suppress repeated errors about the same missing PV uuids.
--- LVM2/test/test-utils.sh	2010/02/17 15:41:28	1.21
+++ LVM2/test/test-utils.sh	2010/03/17 14:55:28	1.22
@@ -24,6 +24,21 @@
 		echo "$i ${FUNC}() called from ${BASH_SOURCE[$i]}:${BASH_LINENO[$i]}"
 		i=$(($i + 1));
 	done
+
+	# Attempt to get a stacktrace if a core file exists
+	# and the lvm binary was built with debugging
+	TEST_LVM_BINARY=$(dirname $(which lvm))/../../tools/lvm
+	TEST_LVM_CORE=`ls core* | head -1`
+	GDB_BINARY=`which gdb`
+	READELF_BINARY=`which readelf`
+	if [ -n "$TEST_LVM_CORE" -a -n "$GDB_BINARY" -a -n "$READELF_BINARY" ]; then
+		if $READELF_BINARY -S $TEST_LVM_BINARY 2>&1 | grep -q .debug_info; then
+			echo bt full > gdb_commands.txt
+			echo l >> gdb_commands.txt
+			echo quit >> gdb_commands.txt
+			$GDB_BINARY -batch -c $TEST_LVM_CORE -x gdb_commands.txt $TEST_LVM_BINARY
+		fi
+	fi
 }
 
 init_udev_transaction() {


