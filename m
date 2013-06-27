From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 27 Jun 2013 13:27:43 +0000 (UTC)
Subject: master - cleanup: clear outdated comment (TODO already done)
Message-ID: <20130627132743.F37A360315@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6de45db5b53636afff1e7e0a5d5efd012c1b7f20
Commit:        6de45db5b53636afff1e7e0a5d5efd012c1b7f20
Parent:        9233e6d0bb5b3b21cc67fd0baae3fb4cb099bdcb
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Jun 27 15:26:39 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Jun 27 15:26:39 2013 +0200

cleanup: clear outdated comment (TODO already done)

---
 lib/format_text/format-text.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 3157252..fae3ad7 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -1544,9 +1544,6 @@ static int _text_pv_initialise(const struct format_type *fmt,
 		 * value (e.g. backups). Also, if creating an EA, try to place
 		 * it in between the final alignment and existing PE start
 		 * if possible.
-		 * TODO: Support restoring existing EA from MDA instead like
-		 *       we do for PE start? This would require adding EA info
-		 *       in MDA then!
 		 */
 		pv->pe_start = rp->pe_start;
 		if (rp->ba_size) {


