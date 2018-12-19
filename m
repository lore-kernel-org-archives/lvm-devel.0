From: Marian Csontos <mcsontos@sourceware.org>
Date: Wed, 19 Dec 2018 10:30:53 -0500
Subject: master - lvmlockd: Fix arguments when built without sanlock
Message-ID: <201812191530.wBJFUrOg025494@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b068f21f6a24094936a33269067c18373b48f2cd
Commit:        b068f21f6a24094936a33269067c18373b48f2cd
Parent:        93c7bca08f328f50af4ce4a93fd19b0973b9bd1f
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Tue Dec 18 16:59:48 2018 +0100
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Tue Dec 18 17:42:22 2018 +0100

lvmlockd: Fix arguments when built without sanlock

(cherry picked from commit 24254ca86671ae49431e67788c039603fe4b79fb)
---
 daemons/lvmlockd/lvmlockd-internal.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/daemons/lvmlockd/lvmlockd-internal.h b/daemons/lvmlockd/lvmlockd-internal.h
index 04645fa..ead3098 100644
--- a/daemons/lvmlockd/lvmlockd-internal.h
+++ b/daemons/lvmlockd/lvmlockd-internal.h
@@ -504,7 +504,7 @@ static inline int lm_init_vg_sanlock(char *ls_name, char *vg_name, uint32_t flag
 	return -1;
 }
 
-static inline int lm_init_lv_sanlock(char *ls_name, char *vg_name, char *lv_name, char *vg_args, char *lv_args, int sector_size, int align_size, uint64_t free_offset)
+static inline int lm_init_lv_sanlock(char *ls_name, char *vg_name, char *lv_name, char *vg_args, char *lv_args, uint64_t free_offset)
 {
 	return -1;
 }
@@ -592,7 +592,7 @@ static inline int lm_is_running_sanlock(void)
 	return 0;
 }
 
-static inline int lm_find_free_lock_sanlock(struct lockspace *ls, uint64_t *free_offset, int *sector_size, int *align_size)
+static inline int lm_find_free_lock_sanlock(struct lockspace *ls, uint64_t *free_offset)
 {
 	return -1;
 }


