From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 17 Mar 2021 00:00:37 +0000 (GMT)
Subject: main - cleanup: typo
Message-ID: <20210317000037.C8074386185F@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0363e4de70148c7fad5c46c40bc4db30be123545
Commit:        0363e4de70148c7fad5c46c40bc4db30be123545
Parent:        e6912cc61cd33e040dcab326b3ea7c292ff3f699
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Mar 15 18:59:15 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Mar 15 18:59:15 2021 +0100

cleanup: typo

---
 lib/filters/filter-sysfs.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/filters/filter-sysfs.c b/lib/filters/filter-sysfs.c
index b626144b2..32ac324dd 100644
--- a/lib/filters/filter-sysfs.c
+++ b/lib/filters/filter-sysfs.c
@@ -218,14 +218,14 @@ static int _read_devs(struct dev_set *ds, const char *dir, unsigned sysfs_depth)
 
 		if (dm_snprintf(path, sizeof(path), "%s/%s", dir,
 				 d->d_name) < 0) {
-			log_warn("WARGNING: sysfs path name too long: %s in %s.",
+			log_warn("WARNING: sysfs path name too long: %s in %s.",
 				 d->d_name, dir);
 			continue;
 		}
 
 		/* devices have a "dev" file */
 		if (dm_snprintf(file, sizeof(file), "%s/dev", path) < 0) {
-			log_warn("WARGNING: sysfs path name too long: %s in %s.",
+			log_warn("WARNING: sysfs path name too long: %s in %s.",
 				 d->d_name, dir);
 			continue;
 		}


