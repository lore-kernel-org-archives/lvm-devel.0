From: Alasdair Kergon <agk@sourceware.org>
Date: Thu, 8 Feb 2018 20:32:30 -0500
Subject: master - format_text: Use versionsort to sort archive files
Message-ID: <201802090132.w191WUg5027516@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1b6d0346a37d34394471080ec2aff55cea1bdafe
Commit:        1b6d0346a37d34394471080ec2aff55cea1bdafe
Parent:        d6cabbbc53de615fe92ff6372a570285704b59d2
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri Feb 9 01:08:55 2018 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Feb 9 01:08:55 2018 +0000

format_text: Use versionsort to sort archive files

Ensure that vg_100000-* follows vg_99999-* so that the expiry logic
doesn't stop too early.

   https://bugzilla.redhat.com/1481085
---
 WHATS_NEW                 |    1 +
 lib/format_text/archive.c |    4 ++--
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 9e6cb39..197adc3 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.178 - 
 =====================================
+  Use versionsort to fix archive file expiry beyond 100000 files.
   Add devices/use_aio, aio_max, aio_memory to configure AIO limits.
   Support asynchronous I/O when scanning devices.
   Detect asynchronous I/O capability in configure or accept --disable-aio.
diff --git a/lib/format_text/archive.c b/lib/format_text/archive.c
index 4d4e7ac..a81a83b 100644
--- a/lib/format_text/archive.c
+++ b/lib/format_text/archive.c
@@ -136,8 +136,8 @@ static struct dm_list *_scan_archive(struct dm_pool *mem,
 
 	dm_list_init(results);
 
-	/* Sort fails beyond 5-digit indexes */
-	if ((count = scandir(dir, &dirent, NULL, alphasort)) < 0) {
+	/* Use versionsort to handle numbers beyond 5 digits */
+	if ((count = scandir(dir, &dirent, NULL, versionsort)) < 0) {
 		log_error("Couldn't scan the archive directory (%s).", dir);
 		return 0;
 	}


