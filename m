From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue,  1 Sep 2020 17:02:05 +0000 (GMT)
Subject: master - cov: always sure we end with '0'
Message-ID: <20200901170205.53ECE3951C06@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1705b439b1babfcae75b1d54d45eb7909cbccfb9
Commit:        1705b439b1babfcae75b1d54d45eb7909cbccfb9
Parent:        de837c15a55f4951f0b3181f4835fed2d824698b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Aug 29 19:56:37 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Sep 1 17:57:50 2020 +0200

cov: always sure we end with '0'

Use easier dm_strncpy().
---
 lib/label/hints.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/lib/label/hints.c b/lib/label/hints.c
index 3125ae01d..c9d339861 100644
--- a/lib/label/hints.c
+++ b/lib/label/hints.c
@@ -818,8 +818,7 @@ static int _read_hint_file(struct cmd_context *cmd, struct dm_list *hints, int *
 	while ((dev = dev_iter_get(cmd, iter))) {
 		if (!_dev_in_hint_hash(cmd, dev))
 			continue;
-		memset(devpath, 0, sizeof(devpath));
-		strncpy(devpath, dev_name(dev), PATH_MAX);
+		(void) dm_strncpy(devpath, dev_name(dev), sizeof(devpath));
 		calc_hash = calc_crc(calc_hash, (const uint8_t *)devpath, strlen(devpath));
 		calc_count++;
 	}


