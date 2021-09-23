From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 23 Sep 2021 14:52:35 +0000 (GMT)
Subject: main - gcc: match types
Message-ID: <20210923145235.11F523858D34@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ee15065a0f77bf01d1f4184462844f690cde64a8
Commit:        ee15065a0f77bf01d1f4184462844f690cde64a8
Parent:        9eafd44734d32207dce7d0b0829e3c94c07d95c9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Sep 22 16:45:33 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Sep 22 17:18:50 2021 +0200

gcc: match types

---
 daemons/dmeventd/libdevmapper-event.c | 2 +-
 device_mapper/datastruct/bitset.c     | 3 ++-
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/daemons/dmeventd/libdevmapper-event.c b/daemons/dmeventd/libdevmapper-event.c
index 237be9fec..30df1da21 100644
--- a/daemons/dmeventd/libdevmapper-event.c
+++ b/daemons/dmeventd/libdevmapper-event.c
@@ -710,7 +710,7 @@ static char *_fetch_string(char **src, const int delimiter)
 {
 	char *p, *ret;
 	size_t len = (p = strchr(*src, delimiter)) ?
-		p - *src : strlen(*src);
+		(size_t)(p - *src) : strlen(*src);
 
 	if ((ret = strndup(*src, len)))
 		*src += len + 1;
diff --git a/device_mapper/datastruct/bitset.c b/device_mapper/datastruct/bitset.c
index c99927cc1..080ed760e 100644
--- a/device_mapper/datastruct/bitset.c
+++ b/device_mapper/datastruct/bitset.c
@@ -150,7 +150,8 @@ dm_bitset_t dm_bitset_parse_list(const char *str, struct dm_pool *mem,
 				 size_t min_num_bits)
 {
 	unsigned a, b;
-	int c, old_c, totaldigits, ndigits, nmaskbits;
+	int c, old_c, totaldigits, ndigits;
+	size_t nmaskbits;
 	int at_start, in_range;
 	dm_bitset_t mask = NULL;
 	const char *start = str;


