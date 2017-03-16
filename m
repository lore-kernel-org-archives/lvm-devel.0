From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 15 Mar 2017 20:02:27 -0400
Subject: master - mirror: avoid scanning
Message-ID: <201703160002.v2G02Rxk017621@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=115fd205debc1912e6671de802dc571324a2cc93
Commit:        115fd205debc1912e6671de802dc571324a2cc93
Parent:        849ab38e3cd6d612d55a3457f5ce94779afb6cbc
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Mar 16 00:00:52 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Mar 16 01:02:10 2017 +0100

mirror: avoid scanning

While mirror is blocked we can't try to scan device.
Regression introduce by previous commit
76f6951c3e8f0933df9730a42e9c46f273d1da24.
---
 daemons/dmeventd/plugins/mirror/dmeventd_mirror.c |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c b/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c
index 181b839..35224b5 100644
--- a/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c
+++ b/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c
@@ -186,10 +186,6 @@ int register_device(const char *device,
 	if (!dmeventd_lvm2_init_with_pool("mirror_state", state))
 		goto_bad;
 
-	if (!dmeventd_lvm2_command(state->mem, state->cmd_lvscan, sizeof(state->cmd_lvscan),
-				   "lvscan --cache", device))
-		goto_bad;
-
 	if (!dmeventd_lvm2_command(state->mem, state->cmd_lvconvert, sizeof(state->cmd_lvconvert),
 				   "lvconvert --config global{use_lvmetad = 0}' --repair --use-policies", device))
 		goto_bad;


