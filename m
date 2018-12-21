From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 21 Dec 2018 17:26:57 -0500
Subject: master - Revert "lvmlockd: Fix arguments when built without sanlock"
Message-ID: <201812212226.wBLMQvQ6004481@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1fc5d8c4285fd42441a4f57e4c8fc242397b84f3
Commit:        1fc5d8c4285fd42441a4f57e4c8fc242397b84f3
Parent:        26ead4bf45e94e6cfee2036d1c0c800abf4344b3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Dec 21 22:41:00 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Dec 21 22:41:00 2018 +0100

Revert "lvmlockd: Fix arguments when built without sanlock"

This reverts commit b068f21f6a24094936a33269067c18373b48f2cd.

This revert was incorrect.
---
 daemons/lvmlockd/lvmlockd-internal.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/daemons/lvmlockd/lvmlockd-internal.h b/daemons/lvmlockd/lvmlockd-internal.h
index ead3098..04645fa 100644
--- a/daemons/lvmlockd/lvmlockd-internal.h
+++ b/daemons/lvmlockd/lvmlockd-internal.h
@@ -504,7 +504,7 @@ static inline int lm_init_vg_sanlock(char *ls_name, char *vg_name, uint32_t flag
 	return -1;
 }
 
-static inline int lm_init_lv_sanlock(char *ls_name, char *vg_name, char *lv_name, char *vg_args, char *lv_args, uint64_t free_offset)
+static inline int lm_init_lv_sanlock(char *ls_name, char *vg_name, char *lv_name, char *vg_args, char *lv_args, int sector_size, int align_size, uint64_t free_offset)
 {
 	return -1;
 }
@@ -592,7 +592,7 @@ static inline int lm_is_running_sanlock(void)
 	return 0;
 }
 
-static inline int lm_find_free_lock_sanlock(struct lockspace *ls, uint64_t *free_offset)
+static inline int lm_find_free_lock_sanlock(struct lockspace *ls, uint64_t *free_offset, int *sector_size, int *align_size)
 {
 	return -1;
 }


