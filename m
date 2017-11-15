From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 15 Nov 2017 08:09:46 -0500
Subject: master - activation: suspend pvmove using lv.
Message-ID: <201711151309.vAFD9kaq002002@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=35b207946a514c411e4d7c9be235e093ae5adf7d
Commit:        35b207946a514c411e4d7c9be235e093ae5adf7d
Parent:        9e2a68a981a44579b19108554b8f89a860eb9d59
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Nov 15 12:08:33 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Nov 15 14:03:22 2017 +0100

activation: suspend pvmove using lv.

Whenever pvmove tree is going to be generated for suspend
and such LV has a user - use this 'using LV' to generate
correct dm tree  holding all components.
---
 lib/activate/activate.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 05aea85..0dc67f2 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -2161,6 +2161,12 @@ static int _lv_suspend(struct cmd_context *cmd, const char *lvid_s,
 		}
 		if (!_lv_preload(lv_pre_tmp, laopts, &flush_required))
 			goto_out;
+
+		/* Suspending 1st. LV above PVMOVE suspends whole tree */
+		dm_list_iterate_items(sl, &pvmove_lv->segs_using_this_lv) {
+			lv = sl->seg->lv;
+			break;
+		}
 	} else {
 		if (!_lv_preload(lv_pre, laopts, &flush_required))
 			/* FIXME Revert preloading */


