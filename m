From: David Teigland <teigland@sourceware.org>
Date: Thu, 2 Mar 2017 15:00:41 -0500
Subject: master - lvcreate: allow chunksize option when creating cache
Message-ID: <201703022000.v22K0fI5014889@int-mx11.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=910918d1c24f5edd07abd638958bc52da1e147c8
Commit:        910918d1c24f5edd07abd638958bc52da1e147c8
Parent:        6360ba3d2d7b1ab9e32ad5c660473d2a290ef3fd
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Mar 2 13:58:27 2017 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Mar 2 13:58:27 2017 -0600

lvcreate: allow chunksize option when creating cache

---
 tools/command-lines.in |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/tools/command-lines.in b/tools/command-lines.in
index 295958c..f6a4414 100644
--- a/tools/command-lines.in
+++ b/tools/command-lines.in
@@ -699,7 +699,8 @@ OO_LVCREATE: --addtag Tag, --alloc Alloc, --autobackup Bool, --activate Active,
 --reportformat ReportFmt, --setactivationskip Bool, --wipesignatures Bool,
 --zero Bool
 
-OO_LVCREATE_CACHE: --cachemode CacheMode, --cachepolicy String, --cachesettings String
+OO_LVCREATE_CACHE: --cachemode CacheMode, --cachepolicy String, --cachesettings String,
+--chunksize SizeKB
 
 OO_LVCREATE_POOL: --poolmetadatasize SizeMB, --poolmetadataspare Bool, --chunksize SizeKB
 


