From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 24 Feb 2021 11:10:41 +0000 (GMT)
Subject: stable-2.02 - cmdline: add missing comma in definition
Message-ID: <20210224111041.90B26385800C@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=844a075c01ad300439a46f2ef4c85482f83bf992
Commit:        844a075c01ad300439a46f2ef4c85482f83bf992
Parent:        85795593b8449d9fb4fed0eb252906c9a28b0ddd
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Feb 23 23:28:41 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Feb 24 11:56:12 2021 +0100

cmdline: add missing comma in definition

---
 tools/command-lines.in | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/tools/command-lines.in b/tools/command-lines.in
index fff3f16f9..7d0abd03f 100644
--- a/tools/command-lines.in
+++ b/tools/command-lines.in
@@ -309,7 +309,7 @@ OO_LVCONVERT_POOL: --poolmetadata LV, --poolmetadatasize SizeMB,
 --poolmetadataspare Bool, --readahead Readahead, --chunksize SizeKB,
 --zero Bool, --metadataprofile String
 
-OO_LVCONVERT_THIN: --discards Discards --errorwhenfull Bool
+OO_LVCONVERT_THIN: --discards Discards, --errorwhenfull Bool
 
 OO_LVCONVERT_CACHE: --cachemetadataformat CacheMetadataFormat,
 --cachemode CacheMode, --cachepolicy String,


