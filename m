From: David Teigland <teigland@sourceware.org>
Date: Thu,  7 Jan 2021 19:33:54 +0000 (GMT)
Subject: main - lvconvert: chunksize option was missing with cachedevice
Message-ID: <20210107193354.59F273851C35@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e9503f257ad2e61742b0cfe2780b72739d1d3978
Commit:        e9503f257ad2e61742b0cfe2780b72739d1d3978
Parent:        b84a9927b78727efffbb257a61e9e95a648cdfab
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Jan 7 13:30:48 2021 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Jan 7 13:30:48 2021 -0600

lvconvert: chunksize option was missing with cachedevice

---
 test/shell/cachevol-cachedevice.sh | 13 +++++++++++++
 tools/command-lines.in             |  2 +-
 2 files changed, 14 insertions(+), 1 deletion(-)

diff --git a/test/shell/cachevol-cachedevice.sh b/test/shell/cachevol-cachedevice.sh
index 3831ee9d4..2695c989b 100644
--- a/test/shell/cachevol-cachedevice.sh
+++ b/test/shell/cachevol-cachedevice.sh
@@ -144,6 +144,19 @@ lvconvert -y --type cache --cachedevice "$dev2" $vg/$lv1
 check lv_field $vg/$lv1 segtype cache
 check lv_field $vg/${lv1}_cache_cvol segtype linear -a
 check lv_field $vg/${lv1}_cache_cvol lv_size "60.00m"
+lvs -o chunksize $vg/$lv1 |tee out
+grep 64.00k out
+lvchange -ay $vg/$lv1
+lvchange -an $vg/$lv1
+lvremove $vg/$lv1
+
+lvcreate -n $lv1 -l8 -an $vg "$dev1"
+lvconvert -y --type cache --cachedevice "$dev2" --chunksize 128k $vg/$lv1
+check lv_field $vg/$lv1 segtype cache
+check lv_field $vg/${lv1}_cache_cvol segtype linear -a
+check lv_field $vg/${lv1}_cache_cvol lv_size "60.00m"
+lvs -o chunksize $vg/$lv1 |tee out
+grep 128.00k out
 lvchange -ay $vg/$lv1
 lvchange -an $vg/$lv1
 lvremove $vg/$lv1
diff --git a/tools/command-lines.in b/tools/command-lines.in
index 5a8523966..8ea65ca83 100644
--- a/tools/command-lines.in
+++ b/tools/command-lines.in
@@ -505,7 +505,7 @@ DESC: Add a writecache to an LV, using a specified cache device.
 RULE: all and lv_is_visible
 
 lvconvert --type cache --cachedevice PV LV_linear_striped_raid_thinpool
-OO: OO_LVCONVERT, --cachesize SizeMB, --cachesettings String
+OO: OO_LVCONVERT, --cachesize SizeMB, --cachesettings String, --chunksize SizeKB
 ID: lvconvert_to_cache_with_device
 DESC: Add a cache to an LV, using a specified cache device.
 RULE: all and lv_is_visible


