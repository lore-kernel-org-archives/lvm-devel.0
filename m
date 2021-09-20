From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 20 Sep 2021 13:29:57 +0000 (GMT)
Subject: main - tests: fix test of read buffer
Message-ID: <20210920132957.6FF293858C3B@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a428856a212fc9f24374de84b7f3b781502c8cf6
Commit:        a428856a212fc9f24374de84b7f3b781502c8cf6
Parent:        becffe4567543e3e0c51c728a4b266cf94fd2cdf
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Sep 19 20:17:22 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 20 14:18:13 2021 +0200

tests: fix test of read buffer

Patch 7aba7fe68b6da2ca8ec7b01f5730396d64426fb0 incorrectly
converted  SECTOR_SIZE * BLOCK_SIZE_SECTORS to sizeof(f->data).
---
 test/unit/io_engine_t.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/test/unit/io_engine_t.c b/test/unit/io_engine_t.c
index a1b219530..c864fa338 100644
--- a/test/unit/io_engine_t.c
+++ b/test/unit/io_engine_t.c
@@ -154,7 +154,7 @@ static void _test_read(void *fixture)
 	T_ASSERT(io.completed);
 	T_ASSERT(!io.error);
 
-	_check_buffer(f->data, 123, sizeof(f->data));
+	_check_buffer(f->data, 123, SECTOR_SIZE * BLOCK_SIZE_SECTORS);
 }
 
 static void _test_write(void *fixture)


