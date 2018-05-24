From: Marian Csontos <mcsontos@sourceware.org>
Date: Thu, 24 May 2018 11:51:58 -0400
Subject: master - format_text: Use versionsort to sort archive files
Message-ID: <201805241551.w4OFpwaP028884@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9a730233c935085ec5de9440796daa0d416ba4ba
Commit:        9a730233c935085ec5de9440796daa0d416ba4ba
Parent:        0ecf232194986b12c3ae95b3f93e7fdd56158dc1
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri Feb 9 01:08:55 2018 +0000
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Thu May 24 17:51:03 2018 +0200

format_text: Use versionsort to sort archive files

Ensure that vg_100000-* follows vg_99999-* so that the expiry logic
doesn't stop too early.

   https://bugzilla.redhat.com/1481085
---
 WHATS_NEW                 |    1 +
 lib/format_text/archive.c |    4 ++--
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 35695ab..25707ab 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.178 -
 ====================================
+  Use versionsort to fix archive file expiry beyond 100000 files.
 
 Version 2.02.178-rc1 - 24th May 2018
 ====================================
diff --git a/lib/format_text/archive.c b/lib/format_text/archive.c
index 690bc74..533e91c 100644
--- a/lib/format_text/archive.c
+++ b/lib/format_text/archive.c
@@ -135,8 +135,8 @@ static struct dm_list *_scan_archive(struct dm_pool *mem,
 
 	dm_list_init(results);
 
-	/* Sort fails beyond 5-digit indexes */
-	if ((count = scandir(dir, &dirent, NULL, alphasort)) < 0) {
+	/* Use versionsort to handle numbers beyond 5 digits */
+	if ((count = scandir(dir, &dirent, NULL, versionsort)) < 0) {
 		log_error("Couldn't scan the archive directory (%s).", dir);
 		return 0;
 	}


