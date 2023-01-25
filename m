From: David Teigland <teigland@sourceware.org>
Date: Wed, 25 Jan 2023 16:13:22 +0000 (GMT)
Subject: main - Revert "lvresize: enable crypt resizing with --force"
Message-ID: <20230125161322.4F9023858D39@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8adfcddc35be16ac1d1a00a169ec89a7f12d69af
Commit:        8adfcddc35be16ac1d1a00a169ec89a7f12d69af
Parent:        49c650423a17197c66b1c839a0274db8fba9a7d9
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Jan 25 09:30:05 2023 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Jan 25 10:10:57 2023 -0600

Revert "lvresize: enable crypt resizing with --force"

It looks like force was not being used to enable crypt resize,
but rather to force an inconsistency between LV and crypt
sizes, so this is either not needed or force in this case
should have some other meaning.

This reverts commit ed808a9b548ca59221d512bfb7ae581e8367fe50.
---
 lib/metadata/lv_manip.c | 10 +++-------
 1 file changed, 3 insertions(+), 7 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index f06b08254..cfb118f11 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -6417,13 +6417,9 @@ static int _fs_reduce(struct cmd_context *cmd, struct logical_volume *lv,
 			goto out;
 		}
 		if (!strcmp(lp->fsopt, "checksize")) {
-			if (!lp->force) {
-				log_error("crypt reduce is required (see --resizefs or cryptsetup resize.)");
-				ret = 0;
-				goto out;
-			}
-			/* This is only because it has been allowed in the past. */
-			log_print("Forcing cryptsetup resize (--resizefs preferred.)");
+			log_error("crypt reduce is required (see --resizefs or cryptsetup resize.)");
+			ret = 0;
+			goto out;
 		}
 		if (test_mode()) {
 			ret = 1;

