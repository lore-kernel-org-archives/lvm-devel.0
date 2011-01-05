From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 5 Jan 2011 00:26:24 -0000
Subject: LVM2/test lib/test.sh lib/utils.sh mkdtemp
Message-ID: <20110105002624.11703.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2011-01-05 00:26:20

Modified files:
	test/lib       : test.sh utils.sh 
Removed files:
	test           : mkdtemp 

Log message:
	Move the mkdtemp functionality into test/lib/utils.sh.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/lib/test.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/lib/utils.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/mkdtemp.diff?cvsroot=lvm2&r1=1.2&r2=NONE

--- LVM2/test/lib/test.sh	2011/01/05 00:16:21	1.1
+++ LVM2/test/lib/test.sh	2011/01/05 00:26:19	1.2
@@ -21,7 +21,7 @@
 OLDPWD="`pwd`"
 PREFIX="LVMTEST$$"
 
-TESTDIR=$($abs_srcdir/mkdtemp ${LVM_TEST_DIR-$(pwd)} $PREFIX.XXXXXXXXXX) \
+TESTDIR=$(mkdtemp ${LVM_TEST_DIR-$(pwd)} $PREFIX.XXXXXXXXXX) \
 	|| { echo "failed to create temporary directory in ${LVM_TEST_DIR-$(pwd)}"; exit 1; }
 
 export PREFIX
--- LVM2/test/lib/utils.sh	2011/01/05 00:16:21	1.1
+++ LVM2/test/lib/utils.sh	2011/01/05 00:26:19	1.2
@@ -10,6 +10,97 @@
 
 set -e
 
+die() { echo >&2 "$@"; exit 1; }
+
+MAX_TRIES=4
+
+rand_bytes()
+{
+  n=$1
+
+  chars=abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789
+
+  dev_rand=/dev/urandom
+  if test -r "$dev_rand"; then
+    # Note: 256-length($chars) == 194; 3 copies of $chars is 186 + 8 = 194.
+    head -c$n "$dev_rand" | tr -c $chars 01234567$chars$chars$chars
+    return
+  fi
+
+  cmds='date; date +%N; free; who -a; w; ps auxww; ps ef; netstat -n'
+  data=$( (eval "$cmds") 2>&1 | gzip )
+
+  n_plus_50=$(expr $n + 50)
+
+  # Ensure that $data has length at least 50+$n
+  while :; do
+    len=$(echo "$data"|wc -c)
+    test $n_plus_50 -le $len && break;
+    data=$( (echo "$data"; eval "$cmds") 2>&1 | gzip )
+  done
+
+  echo "$data" \
+    | dd bs=1 skip=50 count=$n 2>/dev/null \
+    | tr -c $chars 01234567$chars$chars$chars
+}
+
+mkdtemp()
+{
+  case $# in
+  2);;
+  *) die "Usage: mkdtemp DIR TEMPLATE";;
+  esac
+
+  destdir=$1
+  template=$2
+
+  case $template in
+  *XXXX) ;;
+  *) die "invalid template: $template (must have a suffix of at least 4 X's)";;
+  esac
+
+  fail=0
+
+  # First, try to use mktemp.
+  d=$(env -u TMPDIR mktemp -d -t -p "$destdir" "$template" 2>/dev/null) \
+    || fail=1
+
+  # The resulting name must be in the specified directory.
+  case $d in "$destdir"*);; *) fail=1;; esac
+
+  # It must have created the directory.
+  test -d "$d" || fail=1
+
+  # It must have 0700 permissions.
+  perms=$(ls -dgo "$d" 2>/dev/null) || fail=1
+  case $perms in drwx------*) ;; *) fail=1;; esac
+
+  test $fail = 0 && {
+    echo "$d"
+    return
+  }
+
+  # If we reach this point, we'll have to create a directory manually.
+
+  # Get a copy of the template without its suffix of X's.
+  base_template=$(echo "$template"|sed 's/XX*$//')
+
+  # Calculate how many X's we've just removed.
+  nx=$(expr length "$template" - length "$base_template")
+
+  err=
+  i=1
+  while :; do
+    X=$(rand_bytes $nx)
+    candidate_dir="$destdir/$base_template$X"
+    err=$(mkdir -m 0700 "$candidate_dir" 2>&1) \
+      && { echo "$candidate_dir"; return; }
+    test $MAX_TRIES -le $i && break;
+    i=$(expr $i + 1)
+  done
+  die "$err"
+}
+
 STACKTRACE() {
     trap - ERR;
     i=0;


