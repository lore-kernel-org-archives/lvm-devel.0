From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 27 Sep 2021 16:57:52 +0000 (GMT)
Subject: main - make: build without versionsort
Message-ID: <20210927165752.272AA385840B@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=dab4acb8f8b379f27bdd5cd2f9014385948cdcc0
Commit:        dab4acb8f8b379f27bdd5cd2f9014385948cdcc0
Parent:        df70dca995e5593e27e13cf00311d961b4def0e2
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Sep 24 23:04:37 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 27 18:56:14 2021 +0200

make: build without versionsort

Reported-by: adamboardman of gemian
---
 lib/format_text/archive.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/lib/format_text/archive.c b/lib/format_text/archive.c
index 1528cb173..103b0608d 100644
--- a/lib/format_text/archive.c
+++ b/lib/format_text/archive.c
@@ -135,6 +135,10 @@ static struct dm_list *_scan_archive(struct dm_pool *mem,
 
 	dm_list_init(results);
 
+#ifndef HAVE_VERSIONSORT
+        /* fallback to alphasort when versionsort is not defined */
+	#define versionsort     alphasort
+#endif /* !HAVE_VERSIONSORT */
 	/* Use versionsort to handle numbers beyond 5 digits */
 	if ((count = scandir(dir, &dirent, NULL, versionsort)) < 0) {
 		log_error("Couldn't scan the archive directory (%s).", dir);


