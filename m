From: David Teigland <teigland@fedoraproject.org>
Date: Fri,  4 Sep 2015 18:46:20 +0000 (UTC)
Subject: master - lvmlockd: don't stop lockspace for EREMOVED
Message-ID: <20150904184620.9905E60B39@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=10ccbc5efaecdc93f40a07a61dad3f2cf8eff73f
Commit:        10ccbc5efaecdc93f40a07a61dad3f2cf8eff73f
Parent:        43d6b5b375e97fa96c9fe498a19fe6df05dc1fb2
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Sep 4 13:41:38 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Sep 4 13:41:38 2015 -0500

lvmlockd: don't stop lockspace for EREMOVED

Undo the part of the recent EREMOVED change which
automatically stopped the lockspace for a remotely
removed VG.  It didn't always work (would not work
when lvb content was rebuilt in the dlm).  This will
be handled better when the lvb content is controlled
more strictly.
---
 daemons/lvmlockd/lvmlockd-core.c |    7 ++-----
 1 files changed, 2 insertions(+), 5 deletions(-)

diff --git a/daemons/lvmlockd/lvmlockd-core.c b/daemons/lvmlockd/lvmlockd-core.c
index ae6f5a1..af1a3a9 100644
--- a/daemons/lvmlockd/lvmlockd-core.c
+++ b/daemons/lvmlockd/lvmlockd-core.c
@@ -1763,7 +1763,7 @@ static void res_process(struct lockspace *ls, struct resource *r,
 				list_del(&act->list);
 				add_client_result(act);
 			}
-			if (rv == -EUNATCH || rv == -EREMOVED)
+			if (rv == -EUNATCH)
 				goto r_free;
 		}
 	}
@@ -1796,7 +1796,7 @@ static void res_process(struct lockspace *ls, struct resource *r,
 				list_del(&act->list);
 				add_client_result(act);
 			}
-			if (rv == -EUNATCH || rv == -EREMOVED)
+			if (rv == -EUNATCH)
 				goto r_free;
 			break;
 		}
@@ -1817,9 +1817,6 @@ r_free:
 	lm_rem_resource(ls, r);
 	list_del(&r->list);
 	free_resource(r);
-
-	if (rv == -EREMOVED)
-		ls->thread_stop = 1;
 }
 
 #define LOCKS_EXIST_ANY 1


