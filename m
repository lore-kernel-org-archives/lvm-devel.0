From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 15 Mar 2021 10:14:03 +0000 (GMT)
Subject: main - cache: use interruptible_usleep
Message-ID: <20210315101403.817063858039@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3608e8aee74a5c771b96d768e6c32edc728dbca0
Commit:        3608e8aee74a5c771b96d768e6c32edc728dbca0
Parent:        a3bb8f2ec195fcfbea599d6efa784cb5cbd39741
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Mar 12 13:07:05 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Mar 14 16:34:38 2021 +0100

cache: use interruptible_usleep

Reuse code for interruptible sleeping.
---
 lib/metadata/cache_manip.c | 8 +-------
 1 file changed, 1 insertion(+), 7 deletions(-)

diff --git a/lib/metadata/cache_manip.c b/lib/metadata/cache_manip.c
index 3eac736dd..98821430f 100644
--- a/lib/metadata/cache_manip.c
+++ b/lib/metadata/cache_manip.c
@@ -470,13 +470,7 @@ int lv_cache_wait_for_clean(struct logical_volume *cache_lv, int *is_clean)
 
 	//FIXME: use polling to do this...
 	for (;;) {
-		sigint_allow();
-		if (cleaner_policy)
-			/* TODO: Use centralized place */
-			usleep(500000);
-		sigint_restore();
-		if (sigint_caught()) {
-			sigint_clear();
+		if (cleaner_policy && interruptible_usleep(500000)) {
 			log_error("Flushing of %s aborted.", display_lvname(cache_lv));
 			if (cache_seg->cleaner_policy) {
 				cache_seg->cleaner_policy = 0;


