From: Alasdair Kergon <agk@sourceware.org>
Date: Thu, 11 Jan 2018 19:50:52 -0500
Subject: master - libdm: Fix a size_t in _dm_malloc_aligned_aux message.
Message-ID: <201801120050.w0C0oqAe015688@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e4e2abc8bc2f257c2d0f9458bab7c87d34626be3
Commit:        e4e2abc8bc2f257c2d0f9458bab7c87d34626be3
Parent:        5bbe68cf15b00987e6644c956cf602251ac91581
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Thu Jan 11 22:19:41 2018 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Jan 12 00:42:53 2018 +0000

libdm: Fix a size_t in _dm_malloc_aligned_aux message.

---
 libdm/mm/dbg_malloc.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/libdm/mm/dbg_malloc.c b/libdm/mm/dbg_malloc.c
index f108e7b..280213b 100644
--- a/libdm/mm/dbg_malloc.c
+++ b/libdm/mm/dbg_malloc.c
@@ -304,7 +304,7 @@ static void *_dm_malloc_aligned_aux(size_t s, size_t a, const char *file __attri
 	}
 
 	if ((r = posix_memalign(&memptr, a, s))) {
-		log_error("Failed to allocate %" PRIsize_t " bytes aligned to %d: %s", s, a, strerror(r));
+		log_error("Failed to allocate %" PRIsize_t " bytes aligned to %" PRIsize_t ": %s", s, a, strerror(r));
 		return 0;
 	}
 


