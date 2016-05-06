From: David Teigland <teigland@fedoraproject.org>
Date: Fri,  6 May 2016 14:01:07 +0000 (UTC)
Subject: master - test: vgsplit-usage
Message-ID: <20160506140107.70CEE60722@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4c5ad5a04c2d28920e1f5abb72d88e3af49fb2f0
Commit:        4c5ad5a04c2d28920e1f5abb72d88e3af49fb2f0
Parent:        29a8012724071fb07b72ef7ba2abd4e17d324a4c
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Apr 25 14:22:42 2016 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri May 6 09:00:00 2016 -0500

test: vgsplit-usage

Restart clvmd between testing each mdatype to
avoid a problem with dev state being kept from
one test to the next.
---
 test/shell/vgsplit-usage.sh |   15 ++++++++++++++-
 1 files changed, 14 insertions(+), 1 deletions(-)

diff --git a/test/shell/vgsplit-usage.sh b/test/shell/vgsplit-usage.sh
index 4f5c6d4..f404a5b 100644
--- a/test/shell/vgsplit-usage.sh
+++ b/test/shell/vgsplit-usage.sh
@@ -152,8 +152,22 @@ lvcreate -l 4 -n $lv2 $vg1
 vgchange -an $vg1
 not vgsplit $vg1 $vg2 "$dev3" 2>err;
 vgremove -f $vg2 $vg1
+
+# Restart clvm because using the same
+# devs as lvm1 and then lvm2 causes problems.
+if test -e LOCAL_CLVMD ; then
+	kill $(< LOCAL_CLVMD)
+	for i in $(seq 1 100) ; do
+		test $i -eq 100 && die "Shutdown of clvmd is too slow."
+		pgrep clvmd || break
+		sleep .1
+	done # wait for the pid removal
+	aux prepare_clvmd
+fi
+
 done
 
+if test -z "$LVM_TEST_LVM1" ; then
 # ONLY LVM2 metadata
 # setup PVs" '
 pvcreate --metadatacopies 0 "$dev5"
@@ -168,7 +182,6 @@ check pvlv_counts $vg1 2 1 0
 vgremove -f $vg1
 
 # vgsplit rejects split because metadata types differ
-if test -n "$LVM_TEST_LVM1" ; then
 pvcreate -ff -M1 "$dev3" "$dev4"
 pvcreate -ff "$dev1" "$dev2"
 vgcreate -M1 $vg1 "$dev3" "$dev4"


