From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 16 Feb 2023 23:10:56 +0000 (GMT)
Subject: main - tests: check failing vdo conversion
Message-ID: <20230216231056.BEBFF3858C78@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=06c5c29443fdd48730a282a5db16e46c793db27b
Commit:        06c5c29443fdd48730a282a5db16e46c793db27b
Parent:        d58b475f6320257e72f01be3c57badd65af28d56
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Feb 17 00:06:56 2023 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Feb 17 00:08:50 2023 +0100

tests: check failing vdo conversion

When we detect not usable vdo on a machine, check lvconvert fails.
---
 test/shell/lvconvert-vdo.sh | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/test/shell/lvconvert-vdo.sh b/test/shell/lvconvert-vdo.sh
index c42d8f25a..7c0bce56b 100644
--- a/test/shell/lvconvert-vdo.sh
+++ b/test/shell/lvconvert-vdo.sh
@@ -18,12 +18,18 @@ SKIP_WITH_LVMPOLLD=1
 #
 # Main
 #
-aux have_vdo 6 2 0 || skip
-
 aux prepare_vg 2 6400
 
 # Conversion to vdo-pool
 lvcreate -L5G -n $lv1 $vg
+
+if not aux have_vdo 6 2 0 ; then
+# For unsupported VDO let's check lvconvert fails
+	not lvconvert --yes --type vdo-pool $vg/$lv1 |& tee out
+	vgremove -ff $vg
+	exit
+fi
+
 # Check there is big prompting warning
 not lvconvert --type vdo-pool $vg/$lv1 |& tee out
 grep "WARNING" out

