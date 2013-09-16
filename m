From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 16 Sep 2013 09:23:09 +0000 (UTC)
Subject: master - tests: add help function
Message-ID: <20130916092309.DB7D66101B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d6090a10f01e6daf5c66e7098a3b0f85560a80ce
Commit:        d6090a10f01e6daf5c66e7098a3b0f85560a80ce
Parent:        1d068682404c7af35c0b40586a6e5479443fc851
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Sep 16 11:02:58 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 16 11:22:04 2013 +0200

tests: add help function

Add mkdev_md5sum to create and checksum given LV.
Add dev_md5sum to verify device has matching md5 sum.
---
 test/lib/aux.sh   |    6 ++++++
 test/lib/check.sh |    8 ++++++++
 2 files changed, 14 insertions(+), 0 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index e07397d..6194492 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -506,6 +506,12 @@ unhide_dev() {
 	lvmconf "$filter"
 }
 
+mkdev_md5sum() {
+	rm -f debug.log
+	mkfs.ext2 "$DM_DEV_DIR/$1/$2" || return 1
+	md5sum "$DM_DEV_DIR/$1/$2" > "md5.$1-$2"
+}
+
 generate_config() {
 	if test -n "$profile_name"; then
 		config_values=PROFILE_VALUES_$profile_name
diff --git a/test/lib/check.sh b/test/lib/check.sh
index 8b2cfce..6eedb47 100644
--- a/test/lib/check.sh
+++ b/test/lib/check.sh
@@ -280,5 +280,13 @@ pvlv_counts() {
 	vg_field $local_vg snap_count $num_snaps
 }
 
+# Compare md5 check generated from get dev_md5sum
+dev_md5sum() {
+	md5sum -c "md5.$1-$2" || \
+		(get lv_field $1/$2 "name,size,seg_pe_ranges"
+		 die "LV $1/$2 has different MD5 check sum!")
+}
+
+#set -x
 unset LVM_VALGRIND
 "$@"


