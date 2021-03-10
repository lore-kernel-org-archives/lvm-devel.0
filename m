From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 10 Mar 2021 23:19:27 +0000 (GMT)
Subject: main - lv_check_not_in_use: correct check
Message-ID: <20210310231927.1AD423858001@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=127c2fc6e287f0f7edb9c0a061aaaba31bf47e45
Commit:        127c2fc6e287f0f7edb9c0a061aaaba31bf47e45
Parent:        d4293b579df61b5eb96dfcce5a7ec8f2116e9561
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Mar 10 14:05:03 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Mar 10 23:32:12 2021 +0100

lv_check_not_in_use: correct check

Since lv_info() may return 0 without setting info struct,
make the test correct and even more readable.
---
 lib/activate/activate.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index c450eab14..4452d4d40 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -834,8 +834,10 @@ int lv_check_not_in_use(const struct logical_volume *lv, int error_if_used)
 	struct lvinfo info;
 	unsigned int open_count_check_retries;
 
-	if (!lv_info(lv->vg->cmd, lv, 0, &info, 1, 0) || !info.exists || !info.open_count)
-		return !info.exists ? 2 : 1;
+	if (!lv_info(lv->vg->cmd, lv, 0, &info, 1, 0) || !info.exists)
+		return 2;
+	else if (!info.open_count)
+		return 1;
 
 	/* If sysfs is not used, use open_count information only. */
 	if (dm_sysfs_dir()) {


