From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 13 Sep 2021 10:36:19 +0000 (GMT)
Subject: main - cov: remove unused variable setting
Message-ID: <20210913103619.6682F3858002@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9ba76450f4a206ee48b0b6e49d35c2c33032bb58
Commit:        9ba76450f4a206ee48b0b6e49d35c2c33032bb58
Parent:        3b2a4e3e6f081002ab92f5f78326d2c1dfa879bf
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Sep 11 22:40:31 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 13 12:34:41 2021 +0200

cov: remove unused variable setting

Since there is no use for &end after strtol, remove it.
---
 lib/report/report.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/lib/report/report.c b/lib/report/report.c
index a28744a49..60df417a4 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -882,7 +882,6 @@ static int _translate_time_items(struct dm_report *rh, struct time_info *info,
 	long multiplier = 1;
 	struct tm tm_now;
 	time_id_t id;
-	char *end;
 	long num;
 	struct tm tm; /* absolute time */
 	time_t t = 0; /* offset into past before absolute time */
@@ -899,7 +898,7 @@ static int _translate_time_items(struct dm_report *rh, struct time_info *info,
 
 		if (_is_time_num(id)) {
 			errno = 0;
-			num = strtol(ti->s, &end, 10);
+			num = strtol(ti->s, NULL, 10);
 			if (errno) {
 				log_error("_translate_time_items: invalid time.");
 				return 0;


