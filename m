From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed,  5 Jun 2013 12:01:39 +0000 (UTC)
Subject: dev-mornfall-lvmcache - thin: fix cut&paste bug
Message-ID: <20130605120139.F20AB61134@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=78a42bac157edba2b68bdfd77ea5c3096845aceb
Commit:        78a42bac157edba2b68bdfd77ea5c3096845aceb
Parent:        24f8daa13d82869fbe088f7edf3c95c11660b186
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Apr 19 21:03:38 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Apr 21 23:07:00 2013 +0200

thin: fix cut&paste bug

Use proper external_lv.
(In release fix)
---
 lib/display/display.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/display/display.c b/lib/display/display.c
index c766674..26bc384 100644
--- a/lib/display/display.c
+++ b/lib/display/display.c
@@ -595,7 +595,7 @@ int lvdisplay_full(struct cmd_context *cmd,
 				  seg->origin->name);
 		if (seg->external_lv)
 			log_print("LV External origin name %s",
-				  seg->origin->name);
+				  seg->external_lv->name);
 		if (inkernel)
 			thin_active = lv_thin_percent(lv, 0, &thin_percent);
 	} else if (lv_is_thin_pool(lv)) {


