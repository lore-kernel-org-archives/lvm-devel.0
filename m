From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 25 Jun 2019 11:45:49 -0400
Subject: stable-2.02 - cov: validate pagesize is not negative
Message-ID: <201906251545.x5PFjn1C013797@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7232458b6c114cc83b471f08abc49fd1673831c4
Commit:        7232458b6c114cc83b471f08abc49fd1673831c4
Parent:        8bea252a636ff0de2266c1ce760b3a6047f0ff2f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jun 25 15:21:46 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jun 25 17:33:47 2019 +0200

cov: validate pagesize is not negative

As _init_free_list() cannot accept negative numbers
---
 lib/device/bcache.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/lib/device/bcache.c b/lib/device/bcache.c
index dac8be6..ccf0046 100644
--- a/lib/device/bcache.c
+++ b/lib/device/bcache.c
@@ -1040,6 +1040,11 @@ struct bcache *bcache_create(sector_t block_sectors, unsigned nr_cache_blocks,
 	unsigned max_io = engine->max_io(engine);
 	long pgsize = sysconf(_SC_PAGESIZE);
 
+	if ((pgsize = sysconf(_SC_PAGESIZE)) < 0) {
+		log_warn("bcache cannot read pagesize.");
+		return NULL;
+	}
+
 	if (!nr_cache_blocks) {
 		log_warn("bcache must have@least one cache block");
 		return NULL;


