From: David Teigland <teigland@sourceware.org>
Date: Mon, 23 Apr 2018 09:54:29 -0400
Subject: master - test: vgsplit-usage if LVM1 tests
Message-ID: <201804231354.w3NDsTPV001464@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ae093df3f15f6d125bf85ed921e5a971b170dc23
Commit:        ae093df3f15f6d125bf85ed921e5a971b170dc23
Parent:        d75aa557845e37f5c4b90ca43c81943bd9b90094
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Feb 15 10:00:07 2018 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Apr 20 11:22:46 2018 -0500

test: vgsplit-usage if LVM1 tests

---
 test/shell/vgsplit-usage.sh |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/test/shell/vgsplit-usage.sh b/test/shell/vgsplit-usage.sh
index 98818ab..a112e86 100644
--- a/test/shell/vgsplit-usage.sh
+++ b/test/shell/vgsplit-usage.sh
@@ -184,6 +184,7 @@ check pvlv_counts $vg1 2 1 0
 vgremove -f $vg1
 
 # vgsplit rejects split because metadata types differ
+if test -n "$LVM_TEST_LVM1" ; then
 pvcreate -ff -M1 "$dev3" "$dev4"
 pvcreate -ff "$dev1" "$dev2"
 vgcreate -M1 $vg1 "$dev3" "$dev4"
@@ -192,3 +193,4 @@ not vgsplit $vg1 $vg2 "$dev3" 2>err;
 grep "Metadata types differ" err
 vgremove -f $vg1 $vg2
 fi
+fi


