From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 12 Apr 2010 19:03:00 -0000
Subject: LVM2/test Makefile.in check.sh
Message-ID: <20100412190300.1117.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2010-04-12 19:03:00

Modified files:
	test           : Makefile.in 
Added files:
	test           : check.sh 

Log message:
	Add a new helper script for the testsuite, that makes checking for various
	(lvm) properties easier and produces nicer output.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/check.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/Makefile.in.diff?cvsroot=lvm2&r1=1.35&r2=1.36

/cvs/lvm2/LVM2/test/check.sh,v  -->  standard output
revision 1.1
--- LVM2/test/check.sh
+++ -	2010-04-12 19:03:00.326635000 +0000
@@ -0,0 +1,91 @@
+#!/bin/bash
+
+set -e -o pipefail
+
+lvdevices() {
+	lvs -a -odevices --noheadings "$@" | sed 's/([^)]*)//g; s/,/ /g'
+}
+
+mirror_images_redundant()
+{
+  vg=$1
+  lv=$vg/$2
+
+  lvs -a $vg
+  for i in `lvdevices $lv`; do
+	  echo "# $i:"
+	  lvdevices $vg/$i | sort | uniq
+  done > check.tmp.all
+
+  (grep -v ^# check.tmp.all || true) | sort | uniq -d > check.tmp
+
+  test "`cat check.tmp | wc -l`" -eq 0 || {
+	  echo "mirror images of $lv expected redundant, but are not:"
+	  cat check.tmp.all
+	  exit 1
+  }
+}
+
+mirror_log_on()
+{
+  lv="$1"_mlog
+  lvdevices $lv | grep -F "$2" || {
+	  echo "mirror log $lv expected on $2 but found on:" >&2
+	  lvdevices $lv >&2
+	  exit 1
+  }
+}
+
+lv_is_contiguous()
+{
+	test `lvs -a --segments --noheadings $1 | wc -l` -eq 1 || {
+		echo "LV $1 expected to be contiguous, but is not:"
+		lvs -a --segments --noheadings $1
+		exit 1
+	}
+}
+
+lv_is_clung()
+{
+	test `lvdevices $1 | sort | uniq | wc -l` -eq 1 || {
+		echo "LV $1 expected to be clung, but is not:"
+		lvdevices $! | sort | uniq
+		exit 1
+	}
+}
+
+mirror_images_contiguous()
+{
+	for i in `lvdevices $1/$2`; do
+		lv_is_contiguous $1/$i
+	done
+}
+
+mirror_images_clung()
+{
+	for i in `lvdevices $1/$2`; do
+		lv_is_clung $1/$i
+	done
+}
+
+mirror() {
+	lv="$1/$2"
+	lvs -oattr "$lv" | grep "m" || {
+		echo "$lv expected a mirror, but is not:"
+		lvs -a $lv
+		exit 1
+	}
+	mirror_images_redundant "$1" "$2"
+	if test -n "$3"; then mirror_log_on "$lv" "$3"; fi
+}
+
+linear() {
+	lv="$1/$2"
+	lvs -ostripes "$lv" | grep "1" || {
+		echo "$lv expected linear, but is not:"
+		lvs -a "$lv" -o+devices
+		exit 1
+	}
+}
+
+"$@"
--- LVM2/test/Makefile.in	2010/04/09 21:42:51	1.35
+++ LVM2/test/Makefile.in	2010/04/12 19:02:59	1.36
@@ -55,7 +55,11 @@
 bin/harness: $(srcdir)/harness.c .bin-dir-stamp
 	$(CC) -o bin/harness $<
 
-init.sh: $(srcdir)/Makefile.in .bin-dir-stamp bin/not bin/harness $(SCRIPTS)
+bin/check: $(srcdir)/check.sh .bin-dir-stamp
+	cp $< bin/check
+	chmod +x bin/check
+
+init.sh: $(srcdir)/Makefile.in .bin-dir-stamp bin/not bin/check bin/harness $(SCRIPTS)
 	rm -f $@-t $@
 	echo 'top_srcdir=$(top_srcdir)' >> $@-t
 	echo 'abs_top_builddir=$(abs_top_builddir)' >> $@-t


