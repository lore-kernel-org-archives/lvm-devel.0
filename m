From: David Teigland <teigland@sourceware.org>
Date: Fri, 20 Jan 2023 18:06:16 +0000 (GMT)
Subject: main - lvresize: enable crypt resizing with --force
Message-ID: <20230120180616.4EA603858434@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ed808a9b548ca59221d512bfb7ae581e8367fe50
Commit:        ed808a9b548ca59221d512bfb7ae581e8367fe50
Parent:        3bb55765286dc8e4f0000957d85a6b8ee2752852
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Jan 20 11:56:40 2023 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Jan 20 12:04:55 2023 -0600

lvresize: enable crypt resizing with --force

Update previous commit
  "lvresize: only resize crypt when fs resize is enabled"
to enable crypt resizing when --force is set and --resizefs
is not set.  This is because it's been allowed in the past
and people have used it, but it's not a good idea.
---
 lib/metadata/lv_manip.c | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index cfb118f11..f06b08254 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -6417,9 +6417,13 @@ static int _fs_reduce(struct cmd_context *cmd, struct logical_volume *lv,
 			goto out;
 		}
 		if (!strcmp(lp->fsopt, "checksize")) {
-			log_error("crypt reduce is required (see --resizefs or cryptsetup resize.)");
-			ret = 0;
-			goto out;
+			if (!lp->force) {
+				log_error("crypt reduce is required (see --resizefs or cryptsetup resize.)");
+				ret = 0;
+				goto out;
+			}
+			/* This is only because it has been allowed in the past. */
+			log_print("Forcing cryptsetup resize (--resizefs preferred.)");
 		}
 		if (test_mode()) {
 			ret = 1;

