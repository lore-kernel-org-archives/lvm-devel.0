From: Jim Meyering <jim@meyering.net>
Date: Tue, 11 Sep 2007 22:56:34 +0200
Subject: Diagnose invalid PE values given on the pvmove command line
Message-ID: <87tzq0syyl.fsf@rho.meyering.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

I've just checked in this patch (copy below, too):

  http://git.et.redhat.com/?p=lvm2.git;a=commitdiff;h=886549165bb

The bug would make pvmove SRC_DEV:$(echo 2^32|bc) DEST_DEV
behave just like   pvmove SRC_DEV:0 DEST_DEV
rather than diagnosing the bogus PE number of "4294967296".

I've also written a script to exercise the bug and the fix, with the goal
of checking it into LVM as the first (of many, I hope) test scripts.
The idea is that "make check" will run all such scripts.  In this
case, you'll have to run it as root, since it runs losetup and some
lvm commands.  But note that it is very careful in what it does, and in
cleaning up after itself.  All temporary files are removed, as well as
loop devices and volume groups -- even when it terminates abnormally.

I've included the script below, for review.  There's still some work to do
before I can propose a complete testing framework.  If you see anything
that can be improved in this script, please let me know.  I do realize
that the uses of losetup are currently specific to Red Hat (util-linux-ng)
and don't work with e.g., Debian's version of losetup.  Not sure what I'll
do to address that, yet.  Note that I've compromised in allowing the use
of the older (unsafe) losetup, because the race-free usage that requires
--find and --show is so new.  I might simply make the testing framework
skip this test, when a good enough version of losetup isn't available.

Jim

-------------------
Diagnose invalid PE values given on the pvmove command line (64-bit systems).

* tools/toollib.c (xstrtouint32): New function.
(_parse_pes): Use xstrtouint32; don't cast strtoul's unsigned
long to uint32_t.  Detect overflow.

Signed-off-by: Jim Meyering <jim@meyering.net>
---
 WHATS_NEW       |    1 +
 tools/toollib.c |   18 ++++++++++++++----
 2 files changed, 15 insertions(+), 4 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 81f0f58..f127611 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.29 -
 ==================================
+  Diagnose invalid PE values given on the pvmove command line (64-bit systems).
   Include strerror string in dev_open_flags' stat failure message.
   Move guts of pvresize into library.
   Avoid error when --corelog is provided without --mirrorlog. (2.02.28)
diff --git a/tools/toollib.c b/tools/toollib.c
index c2b996f..83c83c3 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -911,6 +911,18 @@ static int _add_pe_range(struct dm_pool *mem, const char *pvname,
 	return 1;
 }

+static int xstrtouint32(const char *s, char **p, int base, uint32_t *result)
+{
+	unsigned long ul;
+
+	errno = 0;
+	ul = strtoul(s, p, base);
+	if (errno || *p == s || (uint32_t) ul != ul)
+		return -1;
+	*result = ul;
+	return 0;
+}
+
 static int _parse_pes(struct dm_pool *mem, char *c, struct list *pe_ranges,
 		      const char *pvname, uint32_t size)
 {
@@ -942,8 +954,7 @@ static int _parse_pes(struct dm_pool *mem, char *c, struct list *pe_ranges,

 		/* Start extent given? */
 		if (isdigit(*c)) {
-			start = (uint32_t) strtoul(c, &endptr, 10);
-			if (endptr == c)
+			if (xstrtouint32(c, &endptr, 10, &start))
 				goto error;
 			c = endptr;
 			/* Just one number given? */
@@ -954,8 +965,7 @@ static int _parse_pes(struct dm_pool *mem, char *c, struct list *pe_ranges,
 		if (*c == '-') {
 			c++;
 			if (isdigit(*c)) {
-				end = (uint32_t) strtoul(c, &endptr, 10);
-				if (endptr == c)
+				if (xstrtouint32(c, &endptr, 10, &end))
 					goto error;
 				c = endptr;
 			}
--
1.5.3.1.19.gb5ef6-dirty

=====================================================
Here's the script:

#!/bin/sh
# Ensure that pvmove diagnoses PE-range values 2^32 and larger.

ME=$(basename "$0")
die() { echo >&2 "$ME: $@"; exit 1; }

unsafe_losetup()
{
  f=$1
  dev=$(losetup --find --show "$f" 2>/dev/null) \
      && { echo "$dev"; return 0; }
  dev=$(losetup -f 2>/dev/null) \
      && losetup "$dev" "$f" \
      && { echo "$dev"; return 0; }
  return 1
}

loop_setup()
{
  file=$1
  dd if=/dev/zero of="$file" bs=1M count=40 > /dev/null 2>&1 \
    || die "loop_setup failed: Unable to create tmp file $file"

  # NOTE: this requires a new enough version of losetup
  dev=`unsafe_losetup "$file" 2>/dev/null` \
    || die "loop_setup failed: Unable to create loopback device"

  echo "$dev"
}

pvmove_demo()
{
  f1="$(mktemp)" && d1=$(loop_setup "$f1") || return 1
  f2="$(mktemp)" && d2=$(loop_setup "$f2") || return 1
  pvcreate $d1 $d2            1>&2 || return 1
  vg=vg-pvmove-demo
  vgcreate "$vg" $d1 $d2      1>&2 || return 1
  lv=lv1
  lvcreate -L4 -n"$lv" "$vg"  1>&2 || return 1

  # With lvm-2.02.28 and earlier, on a system with 64-bit "long int",
  # the PE range parsing code would accept values up to 2^64-1, but would
  # silently truncate them to int32_t.  I.e., $d1:$(echo 2^32|bc) would be
  # treated just like $d1:0.
  lvm.static pvmove -v -n$lv $d1:4294967296 $d2 \
    && die "pvmove accepted invalid PE range: $d1:4294967296"
}

cleanup()
{
  test -n "$vg" && {
    vgchange -an "$vg"
    lvremove -ff "$vg"
    vgremove "$vg"
  }
  test -n "$d1" && losetup -d "$d1"
  test -n "$d2" && losetup -d "$d2"
  rm -f "$f1" "$f2"
}

trap 'st=$?; cleanup; exit $st' 0
trap '(exit $?); exit $?' 1 2 13 15

pvmove_demo


