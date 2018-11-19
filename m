From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 19 Nov 2018 12:09:31 -0500
Subject: master - sanlock: update headers
Message-ID: <201811191709.wAJH9Vt5030125@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b968c73d2171b10f457babb2a5c428ffdc5ed21c
Commit:        b968c73d2171b10f457babb2a5c428ffdc5ed21c
Parent:        b2261b5d81732d8d8c3445e9b8c4ce935bcc49d4
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Nov 19 16:55:11 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 19 16:55:11 2018 +0100

sanlock: update headers

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


