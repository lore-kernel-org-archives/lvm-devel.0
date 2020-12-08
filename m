From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue,  8 Dec 2020 21:17:47 +0000 (GMT)
Subject: stable-2.02 - tests: few more fsadm checks
Message-ID: <20201208211747.A60BE385042B@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=92a67e3d3f84825c7be92d0d2259fa92b56092b9
Commit:        92a67e3d3f84825c7be92d0d2259fa92b56092b9
Parent:        307acb072b68956bf7c08dc88b6927f6abf3d2e4
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Dec 7 16:20:00 2020 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Dec 8 22:17:17 2020 +0100

tests: few more fsadm checks

---
 test/shell/fsadm.sh | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/test/shell/fsadm.sh b/test/shell/fsadm.sh
index 910edddd8..67f9660e6 100644
--- a/test/shell/fsadm.sh
+++ b/test/shell/fsadm.sh
@@ -96,9 +96,19 @@ lvcreate -n $lv1 -L20M $vg
 lvcreate -n ${lv1}bar -L10M $vg
 trap 'cleanup_mounted_and_teardown' EXIT
 
+# prints help
+fsadm
+
+# check needs arg
+not fsadm check
+
 if check_missing ext2; then
 	mkfs.ext2 -b4096 -j "$dev_vg_lv"
 
+	# Check 'check' works
+	fsadm check $vg_lv
+	# Check 'resize' without size parameter works
+	fsadm resize $vg_lv
 	fsadm --lvresize resize $vg_lv 30M
 	# Fails - not enough space for 4M fs
 	not fsadm -y --lvresize resize "$dev_vg_lv" 4M


