From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 22 Aug 2017 04:34:02 -0400
Subject: master - lvmlockd: shorter code
Message-ID: <201708220834.v7M8Y29H031062@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d4ce98de4d6c7c3ddeca0e380a18bbdc102e6c3a
Commit:        d4ce98de4d6c7c3ddeca0e380a18bbdc102e6c3a
Parent:        0e42b31dc3be45c29abd90369c02c077d1763ff0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Aug 16 14:12:48 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Aug 22 10:23:31 2017 +0200

lvmlockd: shorter code

gcc warns here about storring 69 bytes in 64 byte array (losing
potentially 4 bytes from 'ls->name').

lvmlockd-core.c:2657:36: warning: ???%s??? directive output may be truncated writing up to 64 bytes into a region of size 60 [-Wformat-truncation=]
  snprintf(tmp_name, MAX_NAME, "REM:%s", ls->name);
                                    ^~
lvmlockd-core.c:2657:2: note: ???snprintf??? output between 5 and 69 bytes into a destination of size 64
  snprintf(tmp_name, MAX_NAME, "REM:%s", ls->name);
  ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Replaced with slightly better code - but it still misses error path what
to do if the name would be truncated... - so added FIXME.

Also using all bytes for snprintf() buffer size
(as the size is with \0 included)
---
 daemons/lvmlockd/lvmlockd-core.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/daemons/lvmlockd/lvmlockd-core.c b/daemons/lvmlockd/lvmlockd-core.c
index aefa98a..6fd4b88 100644
--- a/daemons/lvmlockd/lvmlockd-core.c
+++ b/daemons/lvmlockd/lvmlockd-core.c
@@ -2653,9 +2653,9 @@ out_act:
 	if (ls->lm_type == LD_LM_DLM && !strcmp(ls->name, gl_lsname_dlm))
 		global_dlm_lockspace_exists = 0;
 	/* Avoid a name collision of the same lockspace is added again before this thread is cleaned up. */
-	memset(tmp_name, 0, sizeof(tmp_name));
-	snprintf(tmp_name, MAX_NAME, "REM:%s", ls->name);
-	memcpy(ls->name, tmp_name, MAX_NAME);
+	/* FIXME: detect loss of 4 chars? (use 'size(tmp_name) == (MAX_NAME - 4)' and fail??) */
+	dm_strncpy(tmp_name, ls->name, sizeof(tmp_name));
+	snprintf(ls->name, sizeof(ls->name), "REM:%s", tmp_name);
 	pthread_mutex_unlock(&lockspaces_mutex);
 
 	/* worker_thread will join this thread, and free the ls */


