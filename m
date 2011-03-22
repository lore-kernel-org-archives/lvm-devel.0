From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 22 Mar 2011 22:34:12 +0100
Subject: [PATCH 3/8] Proposal - char alignment on word
In-Reply-To: <cover.1300829383.git.zkabelac@redhat.com>
References: <cover.1300829383.git.zkabelac@redhat.com>
Message-ID: <81de94e0e17d686524064b48f7f396f11e97ea2b.1300829383.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Align strdup char* allocation just on 2 bytes.
It looks like wasting space to aling strings on 8 bytes.
(Could be even 1byte - but for hashing it might eventually get better
perfomance - but probably hardly measurable).

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 libdm/mm/pool.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/libdm/mm/pool.c b/libdm/mm/pool.c
index 825f7ca..608826b 100644
--- a/libdm/mm/pool.c
+++ b/libdm/mm/pool.c
@@ -27,7 +27,7 @@ void dm_pools_check_leaks(void);
 
 char *dm_pool_strdup(struct dm_pool *p, const char *str)
 {
-	char *ret = dm_pool_alloc(p, strlen(str) + 1);
+	char *ret = dm_pool_alloc_aligned(p, strlen(str) + 1, 2);
 
 	if (ret)
 		strcpy(ret, str);
@@ -37,7 +37,7 @@ char *dm_pool_strdup(struct dm_pool *p, const char *str)
 
 char *dm_pool_strndup(struct dm_pool *p, const char *str, size_t n)
 {
-	char *ret = dm_pool_alloc(p, n + 1);
+	char *ret = dm_pool_alloc_aligned(p, n + 1, 2);
 
 	if (ret) {
 		strncpy(ret, str, n);
-- 
1.7.4.1


