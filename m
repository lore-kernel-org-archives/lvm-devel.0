From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  9 Nov 2015 09:28:13 +0000 (UTC)
Subject: master - lvmetad: check for allocation fail
Message-ID: <20151109092813.E440161102@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=91bde0f4a105fb0d2ad8407b63942f2790447846
Commit:        91bde0f4a105fb0d2ad8407b63942f2790447846
Parent:        297d6773afbddd747bc1c56fd01182b9ca798f60
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Nov 8 19:38:19 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 9 10:19:19 2015 +0100

lvmetad: check for allocation fail

Coverity: missing check for root != NULL as this pointer is
later dereferenced in add_last_node().
---
 WHATS_NEW                      |    1 +
 daemons/lvmetad/lvmetad-core.c |    4 +++-
 2 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index a30786a..d0a1476 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.135 - 
 ====================================
+  Add missing test for failing node allocation in lvmetad.
   Correct configure messages when enabling/disabling lvmlockd.
 
 Version 2.02.134 - 9th November 2015
diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index 8e911cd..1de2ad3 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -504,7 +504,9 @@ static response pv_list(lvmetad_state *s, request r)
 		return res; /* FIXME error reporting */
 
 	/* The response field */
-	res.cft->root = make_text_node(res.cft, "response", "OK", NULL, NULL);
+	if (!(res.cft->root = make_text_node(res.cft, "response", "OK", NULL, NULL)))
+		return res; /* FIXME doomed */
+
 	cn_pvs = make_config_node(res.cft, "physical_volumes", NULL, res.cft->root);
 
 	lock_pvid_to_pvmeta(s);


