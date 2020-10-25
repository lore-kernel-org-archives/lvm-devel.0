From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sun, 25 Oct 2020 19:36:58 +0000 (GMT)
Subject: stable-2.02 - cov: dmeventd plugin fix memleak
Message-ID: <20201025193658.092173861845@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=bb5f81624bc03d17a7e4ec57417b6bbcc5dc8ab8
Commit:        bb5f81624bc03d17a7e4ec57417b6bbcc5dc8ab8
Parent:        f5a2607bb194933caea62a88bd7fcc766efcd5cd
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 15 14:21:55 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Oct 25 00:56:11 2020 +0200

cov: dmeventd plugin fix memleak

Fix memory leak when policy command fails too frequently and
plugin decided to skip it.
---
 daemons/dmeventd/plugins/thin/dmeventd_thin.c | 2 +-
 daemons/dmeventd/plugins/vdo/dmeventd_vdo.c   | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/daemons/dmeventd/plugins/thin/dmeventd_thin.c b/daemons/dmeventd/plugins/thin/dmeventd_thin.c
index 29b0391be..033094714 100644
--- a/daemons/dmeventd/plugins/thin/dmeventd_thin.c
+++ b/daemons/dmeventd/plugins/thin/dmeventd_thin.c
@@ -286,7 +286,7 @@ void process_event(struct dm_task *dmt,
 		if (state->fails++ <= state->max_fails) {
 			log_debug("Postponing frequently failing policy (%u <= %u).",
 				  state->fails - 1, state->max_fails);
-			return;
+			goto out;
 		}
 		if (state->max_fails < MAX_FAILS)
 			state->max_fails <<= 1;
diff --git a/daemons/dmeventd/plugins/vdo/dmeventd_vdo.c b/daemons/dmeventd/plugins/vdo/dmeventd_vdo.c
index 389632c60..6b35b2fe9 100644
--- a/daemons/dmeventd/plugins/vdo/dmeventd_vdo.c
+++ b/daemons/dmeventd/plugins/vdo/dmeventd_vdo.c
@@ -261,7 +261,7 @@ void process_event(struct dm_task *dmt,
 		if (state->fails++ <= state->max_fails) {
 			log_debug("Postponing frequently failing policy (%u <= %u).",
 				  state->fails - 1, state->max_fails);
-			return;
+			goto out;
 		}
 		if (state->max_fails < MAX_FAILS)
 			state->max_fails <<= 1;


