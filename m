From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 10 Aug 2015 18:18:18 +0000 (UTC)
Subject: master - lvmlockd: fix check for other sanlock lockspaces
Message-ID: <20150810181818.0A7FD6056C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6bd5bf3cb5a1c01ec8be8bb714c7c0461d6bec58
Commit:        6bd5bf3cb5a1c01ec8be8bb714c7c0461d6bec58
Parent:        1aa7fa354e6ed3e468dc7966f5df0009627b2b97
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Aug 10 13:16:04 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Aug 10 13:16:04 2015 -0500

lvmlockd: fix check for other sanlock lockspaces

The check for other sanlock lockspaces was not checking
that the lockspace type was sanlock, so if dlm lockspaces
were visible, they were wrongly included.
---
 daemons/lvmlockd/lvmlockd-core.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/daemons/lvmlockd/lvmlockd-core.c b/daemons/lvmlockd/lvmlockd-core.c
index 7493d11..5e4e73f 100644
--- a/daemons/lvmlockd/lvmlockd-core.c
+++ b/daemons/lvmlockd/lvmlockd-core.c
@@ -1981,11 +1981,15 @@ static int other_sanlock_vgs_exist(struct lockspace *ls_rem)
 	struct lockspace *ls;
 
 	list_for_each_entry(ls, &lockspaces_inactive, list) {
+		if (ls->lm_type != LD_LM_SANLOCK)
+			continue;
 		log_debug("other sanlock vg exists inactive %s", ls->name);
 		return 1;
 	}
 
 	list_for_each_entry(ls, &lockspaces, list) {
+		if (ls->lm_type != LD_LM_SANLOCK)
+			continue;
 		if (!strcmp(ls->name, ls_rem->name))
 			continue;
 		log_debug("other sanlock vg exists %s", ls->name);


