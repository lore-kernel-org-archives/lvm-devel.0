From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 30 Nov 2018 19:07:44 -0500
Subject: master - device_mapper: optimize dm_pool_strndup
Message-ID: <201812010007.wB107i6P031158@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=93dfb5dd3eb1b6f96f227cba961abfaa00d2f300
Commit:        93dfb5dd3eb1b6f96f227cba961abfaa00d2f300
Parent:        c61c4271a4d9cc990f19614d1d2e7d203d57ebfd
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Dec 1 00:34:29 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Dec 1 01:04:27 2018 +0100

device_mapper: optimize dm_pool_strndup

---
 device_mapper/mm/pool.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/device_mapper/mm/pool.c b/device_mapper/mm/pool.c
index 20d7fd9..b6478c5 100644
--- a/device_mapper/mm/pool.c
+++ b/device_mapper/mm/pool.c
@@ -59,11 +59,13 @@ char *dm_pool_strdup(struct dm_pool *p, const char *str)
 
 char *dm_pool_strndup(struct dm_pool *p, const char *str, size_t n)
 {
+	size_t slen = strlen(str);
+	size_t len = (slen < n) ? slen : n;
 	char *ret = dm_pool_alloc(p, n + 1);
 
 	if (ret) {
-		strncpy(ret, str, n);
-		ret[n] = '\0';
+		ret[len] = '\0';
+		memcpy(ret, str, len);
 	}
 
 	return ret;


