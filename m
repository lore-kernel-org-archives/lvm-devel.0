From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 10 Nov 2011 12:44:01 -0000
Subject: LVM2/test/lib aux.sh
Message-ID: <20111110124401.8290.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-11-10 12:44:00

Modified files:
	test/lib       : aux.sh 

Log message:
	Add generic function to check for target version
	
	So the test script may use a simple line like i.e.:
	
	aux target_at_least dm-thin-pool 1 0 0 || skip
	aux target_at_least snapshot-origin 1 6 || skip

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/lib/aux.sh.diff?cvsroot=lvm2&r1=1.33&r2=1.34

--- LVM2/test/lib/aux.sh	2011/10/23 15:43:10	1.33
+++ LVM2/test/lib/aux.sh	2011/11/10 12:44:00	1.34
@@ -448,6 +448,39 @@
 	fi
 }
 
+#
+# Check wheter kernel [dm module] target exist
+# at least in expected version
+#
+# [dm-]target-name major minor revision
+#
+# i.e.   dm_target_at_least  dm-thin-pool  1 0
+target_at_least()
+{
+	case "$1" in
+	  dm-*) modprobe "$1" ;;
+	esac
+
+	version=$(dmsetup targets 2>/dev/null | grep "${1##dm-} " 2>/dev/null)
+	version=${version##* v}
+	shift
+	major=$(echo $version | cut -d. -f1)
+	minor=$(echo $version | cut -d. -f2)
+	revision=$(echo $version | cut -d. -f3)
+
+	test -z "$1" && return 0
+	test -z "$major" && return 1
+	test "$major" -gt "$1" && return 0
+	test "$major" -lt "$1" && return 1
+	test -z "$2" && return 0
+	test -z "$minor" && return 1
+	test "$minor" -gt "$2" && return 0
+	test "$minor" -lt "$2" && return 1
+	test -z "$4" && return 0
+	test -z "$revision" && return 1
+	test "$revision" -lt "$3" && return 1
+}
+
 test -f DEVICES && devs=$(cat DEVICES)
 test -f LOOP && LOOP=$(cat LOOP)
 


