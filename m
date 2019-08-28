From: David Teigland <teigland@sourceware.org>
Date: Wed, 28 Aug 2019 13:42:14 -0400
Subject: master - hints: check for malloc failure
Message-ID: <201908281742.x7SHgEIX011388@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5b3fbccab9e243901f512f9db3059a3c5eb09fe8
Commit:        5b3fbccab9e243901f512f9db3059a3c5eb09fe8
Parent:        12707adac8ba9e3a58175616bcd59b0e229a6705
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Aug 28 12:39:50 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Aug 28 12:41:57 2019 -0500

hints: check for malloc failure

---
 lib/label/hints.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/lib/label/hints.c b/lib/label/hints.c
index 580304d..6510fcf 100644
--- a/lib/label/hints.c
+++ b/lib/label/hints.c
@@ -608,7 +608,8 @@ static void _filter_to_str(struct cmd_context *cmd, int filter_cfg, char **strp)
 		return;
 	}
 
-	str = malloc(len);
+	if (!(str = malloc(len)))
+		return;
 	memset(str, 0, len);
 
 	for (cv = cn->v; cv; cv = cv->next) {


