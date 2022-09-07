From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed,  7 Sep 2022 13:04:52 +0000 (GMT)
Subject: main - tests: vdo emulation without vdo binary
Message-ID: <20220907130452.D21933858428@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=15ad2b8e5585b89bc3f09a53567f17eb70f45714
Commit:        15ad2b8e5585b89bc3f09a53567f17eb70f45714
Parent:        acbeaa7a8d86acc0f0e3c04723d066d995f29fe5
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Sep 6 16:44:24 2022 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Sep 7 14:58:01 2022 +0200

tests: vdo emulation without vdo binary

Avoid inserting 'vdo' binary into path - and use
alias and VDO_BINARY shell vars for emulation.
---
 test/lib/lvm_vdo_wrapper.sh |  2 +-
 test/shell/vdo-convert.sh   | 11 ++++++++++-
 2 files changed, 11 insertions(+), 2 deletions(-)

diff --git a/test/lib/lvm_vdo_wrapper.sh b/test/lib/lvm_vdo_wrapper.sh
index d622d6456..90d0b2ce8 100755
--- a/test/lib/lvm_vdo_wrapper.sh
+++ b/test/lib/lvm_vdo_wrapper.sh
@@ -344,7 +344,7 @@ vdo_dry_ vdo_remove_ -f "$vdo_confFile" -n "$vdo_name" || true
 #
 # MAIN
 #
-case "$1" in
+case "${1-}" in
   "create") shift; vdo_create_ "$@" ;;
   "remove") shift; vdo_remove_ "$@" ;;
   "stop") shift; vdo_stop_ "$@" ;;
diff --git a/test/shell/vdo-convert.sh b/test/shell/vdo-convert.sh
index f1d04d596..5bf53d081 100644
--- a/test/shell/vdo-convert.sh
+++ b/test/shell/vdo-convert.sh
@@ -29,7 +29,16 @@ aux prepare_dmeventd
 #
 # Main
 #
-which vdo || skip
+if not which vdo ; then
+	which lvm_vdo_wrapper || skip "Missing 'lvm_vdo_wrapper'."
+	which oldvdoformat || skip "Emulation of vdo manager 'oldvdoformat' missing."
+	which oldvdoprepareforlvm || skip "Emulation of vdo manager 'oldvdoprepareforlvm' missing."
+	# enable expansion of aliasis within script itself
+	shopt -s expand_aliases
+	alias vdo='lvm_vdo_wrapper'
+	export VDO_BINARY=lvm_vdo_wrapper
+	echo "Using 'lvm_vdo_wrapper' emulation of 'vdo' manager."
+fi
 which mkfs.ext4 || skip
 export MKE2FS_CONFIG="$TESTDIR/lib/mke2fs.conf"
 

