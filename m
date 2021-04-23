From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 23 Apr 2021 21:05:45 +0000 (GMT)
Subject: main - cov: check _insert_dev return value
Message-ID: <20210423210545.E92B9393BC13@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7e135868374601020920094f135d678c688d0950
Commit:        7e135868374601020920094f135d678c688d0950
Parent:        d7237ca63a1497fc06a975639331ea7869b02c1a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Apr 22 12:30:26 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 23 23:00:55 2021 +0200

cov: check _insert_dev return value

Although we try later to validate device was inserted,
we can validate return value and early-exit.
---
 lib/device/dev-cache.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index aa93b5758..dddf84e4d 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -1510,7 +1510,8 @@ struct device *dev_cache_get(struct cmd_context *cmd, const char *name, struct d
 	 * for st_rdev.
 	 */
 	if (!dev) {
-		_insert_dev(name, st.st_rdev);
+		if (!_insert_dev(name, st.st_rdev))
+			return_NULL;
 
 		/* Get the struct dev that was just added. */
 		dev = (struct device *) dm_hash_lookup(_cache.names, name);


