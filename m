From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 15 Mar 2017 20:19:37 -0400
Subject: master - mirror: revert 76f6951c3e8f0933df9730a42e9c46f273d1da24
Message-ID: <201703160019.v2G0JbtD019152@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=07ded8059cbd36a8104491dc81907325f3413919
Commit:        07ded8059cbd36a8104491dc81907325f3413919
Parent:        4a727a3ccd178d4762f0b7a8a48a24f7667e8c51
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Mar 16 01:17:57 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Mar 16 01:17:57 2017 +0100

mirror: revert 76f6951c3e8f0933df9730a42e9c46f273d1da24

Effectively revert whole  76f6951c3e8f0933df9730a42e9c46f273d1da24.
We need to figure out some other solution.

At this moment usage of --config  with 'repair' of blocked mirror
is 'freezing' combination.
---
 daemons/dmeventd/plugins/mirror/dmeventd_mirror.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c b/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c
index 35224b5..e99b7a2 100644
--- a/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c
+++ b/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c
@@ -186,8 +186,9 @@ int register_device(const char *device,
 	if (!dmeventd_lvm2_init_with_pool("mirror_state", state))
 		goto_bad;
 
+        /* CANNOT use --config as this disables cached content */
 	if (!dmeventd_lvm2_command(state->mem, state->cmd_lvconvert, sizeof(state->cmd_lvconvert),
-				   "lvconvert --config global{use_lvmetad = 0}' --repair --use-policies", device))
+				   "lvconvert --repair --use-policies", device))
 		goto_bad;
 
 	*user = state;


