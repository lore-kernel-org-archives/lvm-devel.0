From: Marian Csontos <mcsontos@sourceware.org>
Date: Tue, 18 Dec 2018 11:42:07 -0500
Subject: 2018-12-18-stable - lvmlockd: Fix arguments when built without sanlock
Message-ID: <201812181642.wBIGg75h031086@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=24254ca86671ae49431e67788c039603fe4b79fb
Commit:        24254ca86671ae49431e67788c039603fe4b79fb
Parent:        7caf8840ff6b0a056b787d6d6fbb5fea78a66f66
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Tue Dec 18 16:59:48 2018 +0100
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Tue Dec 18 17:12:01 2018 +0100

lvmlockd: Fix arguments when built without sanlock

---
 daemons/lvmlockd/lvmlockd-internal.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/daemons/lvmlockd/lvmlockd-internal.h b/daemons/lvmlockd/lvmlockd-internal.h
index d8048d8..a2280b8 100644
--- a/daemons/lvmlockd/lvmlockd-internal.h
+++ b/daemons/lvmlockd/lvmlockd-internal.h
@@ -502,7 +502,7 @@ static inline int lm_init_vg_sanlock(char *ls_name, char *vg_name, uint32_t flag
 	return -1;
 }
 
-static inline int lm_init_lv_sanlock(char *ls_name, char *vg_name, char *lv_name, char *vg_args, char *lv_args, int sector_size, int align_size, uint64_t free_offset)
+static inline int lm_init_lv_sanlock(char *ls_name, char *vg_name, char *lv_name, char *vg_args, char *lv_args, uint64_t free_offset)
 {
 	return -1;
 }
@@ -590,7 +590,7 @@ static inline int lm_is_running_sanlock(void)
 	return 0;
 }
 
-static inline int lm_find_free_lock_sanlock(struct lockspace *ls, uint64_t *free_offset, int *sector_size, int *align_size)
+static inline int lm_find_free_lock_sanlock(struct lockspace *ls, uint64_t *free_offset)
 {
 	return -1;
 }


