From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 10 Feb 2021 14:43:54 +0000 (GMT)
Subject: main - lvchange: snapshot thick origin permission rw/r
Message-ID: <20210210144354.B6FEF385DC33@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=289518005834b5844f88ce1f22265df99f7072d0
Commit:        289518005834b5844f88ce1f22265df99f7072d0
Parent:        3cc9efc0ed48f7053f2e92f251586ea7d3edc06a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Feb 10 00:38:37 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Feb 10 15:39:03 2021 +0100

lvchange: snapshot thick origin permission rw/r

User is allowed to change permission for thick origin.
FIXME: it's not quite clear why few others are prohibited to change.
---
 tools/command-lines.in | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/tools/command-lines.in b/tools/command-lines.in
index 8ea65ca83..c5c93abd3 100644
--- a/tools/command-lines.in
+++ b/tools/command-lines.in
@@ -250,7 +250,7 @@ RULE: --writebehind --writemostly and LV_raid1
 RULE: --cachemode --cachepolicy --cachesettings and LV_cache LV_cachepool LV_writecache
 RULE: --errorwhenfull --discards --zero and LV_thinpool
 RULE: --permission not lv_is_external_origin lv_is_raid_metadata lv_is_raid_image LV_thinpool
-RULE: --alloc --contiguous --metadataprofile --permission --persistent --profile --readahead not lv_is_thick_origin
+RULE: --alloc --contiguous --metadataprofile --persistent --profile --readahead not lv_is_thick_origin
 RULE: --alloc --discards --zero --cachemode --cachepolicy --cachesettings not lv_is_partial
 
 # It's unfortunate that activate needs to be optionally allowed here,


