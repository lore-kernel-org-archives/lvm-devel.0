From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue,  8 Dec 2020 19:35:13 +0000 (GMT)
Subject: main - tests: few more fsadm checks
Message-ID: <20201208193513.2C7903854805@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=57594fe673587ea33a6521733376862055ecbd65
Commit:        57594fe673587ea33a6521733376862055ecbd65
Parent:        47608ff49b874f2a34b9d8644f53028d5ffa1fd3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Dec 7 16:20:00 2020 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Dec 8 20:32:34 2020 +0100

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


