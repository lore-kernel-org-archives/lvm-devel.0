From: David Teigland <teigland@fedoraproject.org>
Date: Wed, 19 Aug 2015 17:18:24 +0000 (UTC)
Subject: master - lvmlockd: change log_error to log_debug for non error
Message-ID: <20150819171824.73F8160528@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ce2e60ab45a5e275adb40380e3a9886a1c1e4ce7
Commit:        ce2e60ab45a5e275adb40380e3a9886a1c1e4ce7
Parent:        9c5a85ce249f6a076ac1623ad6ad8f29bdbbb199
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Aug 19 11:43:39 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Aug 19 11:43:39 2015 -0500

lvmlockd: change log_error to log_debug for non error

It's not uncommon for a command like vgchange -an to
deactivate and unlock LVs that were not active, so
don't lock that as an error.
---
 daemons/lvmlockd/lvmlockd-core.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/daemons/lvmlockd/lvmlockd-core.c b/daemons/lvmlockd/lvmlockd-core.c
index 86bb89b..dddae23 100644
--- a/daemons/lvmlockd/lvmlockd-core.c
+++ b/daemons/lvmlockd/lvmlockd-core.c
@@ -1283,7 +1283,7 @@ static int res_unlock(struct lockspace *ls, struct resource *r,
 	}
 
 	if (act->op != LD_OP_CLOSE)
-		log_error("S %s R %s res_unlock no locks", ls->name, r->name);
+		log_debug("S %s R %s res_unlock no locks", ls->name, r->name);
 	return -ENOENT;
 
 do_unlock:


