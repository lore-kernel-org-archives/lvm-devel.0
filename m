From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 17 Feb 2021 12:01:25 +0000 (GMT)
Subject: stable-2.02 - lvchange: snapshot thick origin permission rw/r
Message-ID: <20210217120125.63167389850A@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=02978e1f0135b75789669ee4042855b08f57f8b4
Commit:        02978e1f0135b75789669ee4042855b08f57f8b4
Parent:        7bb472bc30c88fc56ff7007d540777a30b144185
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Feb 10 00:38:37 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Feb 17 12:14:54 2021 +0100

lvchange: snapshot thick origin permission rw/r

User is allowed to change permission for thick origin.
FIXME: it's not quite clear why few others are prohibited to change.
---
 tools/command-lines.in | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/tools/command-lines.in b/tools/command-lines.in
index c7fe577ab..fff3f16f9 100644
--- a/tools/command-lines.in
+++ b/tools/command-lines.in
@@ -249,7 +249,7 @@ RULE: --writebehind --writemostly and LV_raid1
 RULE: --cachemode --cachepolicy --cachesettings and LV_cache LV_cachepool
 RULE: --errorwhenfull --discards --zero and LV_thinpool
 RULE: --permission not lv_is_external_origin lv_is_raid_metadata lv_is_raid_image LV_thinpool
-RULE: --alloc --contiguous --metadataprofile --permission --persistent --profile --readahead not lv_is_thick_origin
+RULE: --alloc --contiguous --metadataprofile --persistent --profile --readahead not lv_is_thick_origin
 RULE: --alloc --discards --zero --cachemode --cachepolicy --cachesettings not lv_is_partial
 
 # It's unfortunate that activate needs to be optionally allowed here,


