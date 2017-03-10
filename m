From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 10 Mar 2017 13:36:13 -0500
Subject: master - parser: enable --metadataprofile for pool lvconvert
Message-ID: <201703101836.v2AIaDEK009403@int-mx11.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1cfc1be85d617516d077106372b6a4836f48c1a1
Commit:        1cfc1be85d617516d077106372b6a4836f48c1a1
Parent:        07c24736e088755b01134d164c3f155e368b6bc5
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Mar 10 13:02:55 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Mar 10 19:33:00 2017 +0100

parser: enable --metadataprofile for pool lvconvert

Lvconvert can use values from profile when caching.
---
 tools/command-lines.in |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/command-lines.in b/tools/command-lines.in
index d73005f..98d5721 100644
--- a/tools/command-lines.in
+++ b/tools/command-lines.in
@@ -309,7 +309,7 @@ OO_LVCONVERT_RAID: --mirrors SNumber, --stripes_long Number,
 
 OO_LVCONVERT_POOL: --poolmetadata LV, --poolmetadatasize SizeMB,
 --poolmetadataspare Bool, --readahead Readahead, --chunksize SizeKB,
---zero Bool
+--zero Bool, --metadataprofile String
 
 OO_LVCONVERT_CACHE: --cachemode CacheMode, --cachepolicy String,
 --cachesettings String, --zero Bool


