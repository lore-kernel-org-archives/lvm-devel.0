From: David Teigland <teigland@fedoraproject.org>
Date: Wed, 26 Aug 2015 20:52:38 +0000 (UTC)
Subject: master - lvmlockd: fix dlm EAGAIN checks
Message-ID: <20150826205238.BDAE860F47@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d56ae01ebc0100af4caecd45c58f6e36f10bb173
Commit:        d56ae01ebc0100af4caecd45c58f6e36f10bb173
Parent:        b9ca9d73c1037657660bb3c966e9039ff75144c1
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Aug 24 15:54:25 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Aug 26 15:25:38 2015 -0500

lvmlockd: fix dlm EAGAIN checks

libdlm returns EAGAIN in errno
---
 daemons/lvmlockd/lvmlockd-dlm.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/daemons/lvmlockd/lvmlockd-dlm.c b/daemons/lvmlockd/lvmlockd-dlm.c
index c96866b..1d7cfe6 100644
--- a/daemons/lvmlockd/lvmlockd-dlm.c
+++ b/daemons/lvmlockd/lvmlockd-dlm.c
@@ -384,7 +384,7 @@ static int lm_adopt_dlm(struct lockspace *ls, struct resource *r, int ld_mode,
 			  (void *)1, (void *)1, (void *)1,
 			  NULL, NULL);
 
-	if (rv == -EAGAIN) {
+	if (rv == -1 && errno == -EAGAIN) {
 		log_debug("S %s R %s adopt_dlm adopt mode %d try other mode",
 			  ls->name, r->name, ld_mode);
 		rv = -EUCLEAN;
@@ -471,12 +471,12 @@ int lm_lock_dlm(struct lockspace *ls, struct resource *r, int ld_mode,
 	rv = dlm_ls_lock_wait(lmd->dh, mode, lksb, flags,
 			      r->name, strlen(r->name),
 			      0, NULL, NULL, NULL);
-	if (rv == -EAGAIN) {
-		log_error("S %s R %s lock_dlm mode %d rv EAGAIN", ls->name, r->name, mode);
+	if (rv == -1 && errno == EAGAIN) {
+		log_debug("S %s R %s lock_dlm acquire mode %d rv EAGAIN", ls->name, r->name, mode);
 		return -EAGAIN;
 	}
 	if (rv < 0) {
-		log_error("S %s R %s lock_dlm error %d", ls->name, r->name, rv);
+		log_error("S %s R %s lock_dlm acquire error %d errno %d", ls->name, r->name, rv, errno);
 		return rv;
 	}
 
@@ -549,7 +549,7 @@ int lm_convert_dlm(struct lockspace *ls, struct resource *r,
 	rv = dlm_ls_lock_wait(lmd->dh, mode, lksb, flags,
 			      r->name, strlen(r->name),
 			      0, NULL, NULL, NULL);
-	if (rv == -EAGAIN) {
+	if (rv == -1 && errno == EAGAIN) {
 		/* FIXME: When does this happen?  Should something different be done? */
 		log_error("S %s R %s convert_dlm mode %d rv EAGAIN", ls->name, r->name, mode);
 		return -EAGAIN;


