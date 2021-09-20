From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 20 Sep 2021 13:29:58 +0000 (GMT)
Subject: main - tests: use single funtion to get random value
Message-ID: <20210920132958.8ECE43858C60@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b6e9892bc6ae23406847a20236c7c954792468e5
Commit:        b6e9892bc6ae23406847a20236c7c954792468e5
Parent:        a428856a212fc9f24374de84b7f3b781502c8cf6
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Sep 20 10:32:32 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 20 14:18:13 2021 +0200

tests: use single funtion to get random value

---
 test/unit/bcache_utils_t.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/test/unit/bcache_utils_t.c b/test/unit/bcache_utils_t.c
index 3dea17ac5..517a46e1d 100644
--- a/test/unit/bcache_utils_t.c
+++ b/test/unit/bcache_utils_t.c
@@ -339,7 +339,7 @@ static void _test_zero_many_boundaries(void *fixture)
 
 static void _set_cycle(struct fixture *f, uint64_t b, uint64_t e)
 {
-	uint8_t val = random();
+	uint8_t val = _random_pattern();
 
 	_verify(f, b, e, INIT_PATTERN);
 	_do_set(f, b, e, val); 


