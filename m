From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 16 Sep 2020 12:14:55 +0000 (GMT)
Subject: master - tests: fix bash regex syntax
Message-ID: <20200916121455.678DD398600B@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=49292bccc3ce15a729086cc34cbe8b8230948b3b
Commit:        49292bccc3ce15a729086cc34cbe8b8230948b3b
Parent:        2c6bd480b28bec43c7c2652938233d8850f00928
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Sep 16 13:12:17 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Sep 16 14:08:05 2020 +0200

tests: fix bash regex syntax

Typo before last commit.
---
 test/shell/cache-single-split.sh              | 2 +-
 test/shell/lvextend-thin-metadata-dmeventd.sh | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/test/shell/cache-single-split.sh b/test/shell/cache-single-split.sh
index a6deb0dc9..ffe4292de 100644
--- a/test/shell/cache-single-split.sh
+++ b/test/shell/cache-single-split.sh
@@ -50,7 +50,7 @@ which mkfs.xfs || skip
 
 case $(cache_check -V) in
 # support for v2 starts with version 0.7
-0.[0..6]*) skip 'At least version 0.7 of cache_check tool is needed.' ;;
+0.[0-6]*) skip 'At least version 0.7 of cache_check tool is needed.' ;;
 esac
 
 mount_dir="mnt"
diff --git a/test/shell/lvextend-thin-metadata-dmeventd.sh b/test/shell/lvextend-thin-metadata-dmeventd.sh
index db4f7c156..3a837326c 100644
--- a/test/shell/lvextend-thin-metadata-dmeventd.sh
+++ b/test/shell/lvextend-thin-metadata-dmeventd.sh
@@ -63,7 +63,7 @@ aux have_thin 1 10 0 || skip
 BIG_DATA=""
 case $("$LVM_TEST_THIN_RESTORE_CMD" -V) in
 	# With older version of thin-tool we got slightly more compact metadata
-	0.[0..6]*) BIG_DATA="generate_more_metadata" ;;
+	0.[0-6]*) BIG_DATA="generate_more_metadata" ;;
 esac
 
 aux prepare_dmeventd


