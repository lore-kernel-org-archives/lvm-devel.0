From: David Teigland <teigland@sourceware.org>
Date: Thu, 23 Jul 2020 20:12:08 +0000 (GMT)
Subject: master - cachevol: add LV type restrictions to command defs
Message-ID: <20200723201208.09E723857C5B@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7a507583d97c1f4b11d5f1a94958f65cf42b6f9f
Commit:        7a507583d97c1f4b11d5f1a94958f65cf42b6f9f
Parent:        085760992dc68efbda8fe8e1ad4a5a2eccef9139
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Jul 23 15:10:35 2020 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Jul 23 15:10:35 2020 -0500

cachevol: add LV type restrictions to command defs

LV type restrictions were missed on the command definitions.
---
 tools/command-lines.in | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/tools/command-lines.in b/tools/command-lines.in
index e38b6e62f..1b0ca2227 100644
--- a/tools/command-lines.in
+++ b/tools/command-lines.in
@@ -498,13 +498,13 @@ FLAGS: SECONDARY_SYNTAX
 
 ---
 
-lvconvert --type writecache --cachedevice PV LV
+lvconvert --type writecache --cachedevice PV LV_linear_striped_raid
 OO: OO_LVCONVERT, --cachesize SizeMB, --cachesettings String
 ID: lvconvert_to_writecache_with_device
 DESC: Add a writecache to an LV, using a specified cache device.
 RULE: all and lv_is_visible
 
-lvconvert --type cache --cachedevice PV LV
+lvconvert --type cache --cachedevice PV LV_linear_striped_raid_thinpool
 OO: OO_LVCONVERT, --cachesize SizeMB, --cachesettings String
 ID: lvconvert_to_cache_with_device
 DESC: Add a cache to an LV, using a specified cache device.


