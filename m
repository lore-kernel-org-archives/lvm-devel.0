From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 25 Oct 2019 18:55:29 -0400
Subject: stable-2.02 - pvmove: detect exclusively active LVs
Message-ID: <201910252255.x9PMtTYI011955@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=cd39b67b7e91c06937d422b1f230b3b3f6e5a1ca
Commit:        cd39b67b7e91c06937d422b1f230b3b3f6e5a1ca
Parent:        96fd312e85ce38a8fc8cb80f106f3fdc49c31a97
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Oct 23 21:49:50 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Oct 26 00:29:44 2019 +0200

pvmove: detect exclusively active LVs

Before pvmove start, it need to decide if exlusive mode of pvmove
must be used - this mode needs to be used if some move LV is
already exclusively activated.
---
 tools/pvmove.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/tools/pvmove.c b/tools/pvmove.c
index 3a447c4..cecff00 100644
--- a/tools/pvmove.c
+++ b/tools/pvmove.c
@@ -397,7 +397,8 @@ static struct logical_volume *_set_up_pvmove_lv(struct cmd_context *cmd,
 			/* Presence of exclusive LV decides whether pvmove must be also exclusive */
 			if (!seg_only_exclusive(seg)) {
 				holder = lv_lock_holder(lv);
-				if (seg_only_exclusive(first_seg(holder)) || lv_is_origin(holder) || lv_is_cow(holder))
+				if (seg_only_exclusive(first_seg(holder)) || lv_is_origin(holder) ||
+				    lv_is_cow(holder) || lv_is_active_exclusive(holder))
 					needs_exclusive = 1;
 			} else
 				needs_exclusive = 1;


