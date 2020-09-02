From: David Teigland <teigland@sourceware.org>
Date: Wed,  2 Sep 2020 19:08:21 +0000 (GMT)
Subject: master - hints: remove warning when clearing hint file
Message-ID: <20200902190821.AD9853857C48@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8b9028bbe7a6f2e01ba6bddcf256d02fc11d4858
Commit:        8b9028bbe7a6f2e01ba6bddcf256d02fc11d4858
Parent:        d1019a6434a0ffb2b9ed63985e1895435ddeadcf
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Sep 2 14:06:46 2020 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Sep 2 14:06:46 2020 -0500

hints: remove warning when clearing hint file

When the hint file cannot be accessed, silently
ignore hints, like other instances do.
---
 lib/label/hints.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/label/hints.c b/lib/label/hints.c
index 8da131428..4177c678f 100644
--- a/lib/label/hints.c
+++ b/lib/label/hints.c
@@ -274,7 +274,7 @@ static int _clear_hints(struct cmd_context *cmd)
 	time_t t;
 
 	if (!(fp = fopen(_hints_file, "w"))) {
-		log_warn("Failed to clear hint file.");
+		log_debug("clear_hints open errno %d", errno);
 		/* shouldn't happen, but try to unlink in case */
 		_unlink_hints();
 		return 0;


