From: David Teigland <teigland@fedoraproject.org>
Date: Wed,  8 Jul 2015 16:02:46 +0000 (UTC)
Subject: master - lvmlockd: fix unreachable code
Message-ID: <20150708160246.8FA7260D37@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=de13abdfdf44c1119ee03c2514dd886191f3d9c3
Commit:        de13abdfdf44c1119ee03c2514dd886191f3d9c3
Parent:        2566bdfbc3dd1ca7296d8828bb4235c18e06672e
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Jul 8 11:02:11 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Jul 8 11:02:11 2015 -0500

lvmlockd: fix unreachable code

---
 daemons/lvmlockd/lvmlockd-core.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/daemons/lvmlockd/lvmlockd-core.c b/daemons/lvmlockd/lvmlockd-core.c
index b247bb5..73a2fb3 100644
--- a/daemons/lvmlockd/lvmlockd-core.c
+++ b/daemons/lvmlockd/lvmlockd-core.c
@@ -920,9 +920,9 @@ static int lm_unlock(struct lockspace *ls, struct resource *r, struct action *ac
 	int rv;
 
 	if (ls->lm_type == LD_LM_DLM)
-		return lm_unlock_dlm(ls, r, r_version, lmu_flags);
+		rv = lm_unlock_dlm(ls, r, r_version, lmu_flags);
 	else if (ls->lm_type == LD_LM_SANLOCK)
-		return lm_unlock_sanlock(ls, r, r_version, lmu_flags);
+		rv = lm_unlock_sanlock(ls, r, r_version, lmu_flags);
 	else
 		return -1;
 


