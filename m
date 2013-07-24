From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Wed, 24 Jul 2013 19:27:26 +0000 (UTC)
Subject: master - Revert a previous change
Message-ID: <20130724192726.A95266109F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f5a205668b9965a7a2471d9e7cbcd3db49a495c7
Commit:        f5a205668b9965a7a2471d9e7cbcd3db49a495c7
Parent:        cb9256111a8635b354c5b0ac3f3ab8fdab6068e3
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Wed Jul 24 14:18:07 2013 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Wed Jul 24 14:18:07 2013 -0500

Revert a previous change

commit d00d45a8b609d50302c94a0fff20849f0cc13a48 introduced changes
that are causing cluster mirror tests to fail.  Ultimately, I think
the change was right, but a proper clean-up will have to wait.
The portion of the commit we are reverting correlates to the
following commit comment:
    2) lib/metadata/mirror.c:_delete_lv() - should have been calling
       _activate_lv_like_model() with 'mirror_lv'.  This is because
       'mirror_lv' is the LV that the overall operation is being
       performed on.  We need to use this LV as the basis for
       determining whether to activate locally, or across the
       cluster, etc.
It appears that when legs or logs are removed from a mirror, they
are being activated before they are deleted in order to make them
top-level LVs that can be acted upon.  When doing this, it appears
they are not activated based on the characteristics of the mirror
from which they came.  IOW, if the mirror was exclusively active,
the sub-LVs are activated globally.  This is a no-no.  This then
made it impossible to activate_lv_like_model if the model was
"mirror_lv" instead of "lv" in _delete_lv().  Thus, at some point
this change should probably be put back and those location where
the sub-LVs are being improperly activated "shared" instead of
EX should be corrected.
---
 lib/metadata/mirror.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/mirror.c b/lib/metadata/mirror.c
index 8748d89..24c9786 100644
--- a/lib/metadata/mirror.c
+++ b/lib/metadata/mirror.c
@@ -434,7 +434,8 @@ static int _delete_lv(struct logical_volume *mirror_lv, struct logical_volume *l
 		}
 	}
 
-	if (!_activate_lv_like_model(mirror_lv, lv))
+	/* FIXME: the 'model' should be 'mirror_lv' not 'lv', I think. */
+	if (!_activate_lv_like_model(lv, lv))
 		return_0;
 
 	/* FIXME Is this superfluous now? */


