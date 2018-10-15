From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 15 Oct 2018 11:55:23 -0400
Subject: master - cov: add check for positive value
Message-ID: <201810151555.w9FFtNYi020594@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=eb566e034fecd27ced0dc1133e19ced2636b3714
Commit:        eb566e034fecd27ced0dc1133e19ced2636b3714
Parent:        9b7121226258f7dfe759cc1f8625cbfb80fec161
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 15 15:02:09 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 15 17:49:44 2018 +0200

cov: add check for positive value

As pgsize parameter for _init_free_list() can't be negative,
report problem in case for any reason we would get negative number.
---
 lib/device/bcache.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/lib/device/bcache.c b/lib/device/bcache.c
index 43ca63e..8b2c7f8 100644
--- a/lib/device/bcache.c
+++ b/lib/device/bcache.c
@@ -881,6 +881,11 @@ struct bcache *bcache_create(sector_t block_sectors, unsigned nr_cache_blocks,
 	unsigned max_io = engine->max_io(engine);
 	long pgsize = sysconf(_SC_PAGESIZE);
 
+	if (pgsize < 0) {
+		log_warn("WARNING: _SC_PAGESIZE returns negative value.");
+		return NULL;
+	}
+
 	if (!nr_cache_blocks) {
 		log_warn("bcache must have@least one cache block");
 		return NULL;


