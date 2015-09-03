From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu,  3 Sep 2015 21:36:24 +0000 (UTC)
Subject: master - cleanup: use just 2 decimal digits
Message-ID: <20150903213624.2596560F7F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ee8200f1c6d8613ae1f55b41d5eb758b547c6a4b
Commit:        ee8200f1c6d8613ae1f55b41d5eb758b547c6a4b
Parent:        0a389691dcf9a31bb0da26089febb0bdd93545d7
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Sep 2 16:13:50 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Sep 3 23:34:37 2015 +0200

cleanup: use just 2 decimal digits

---
 lib/activate/dev_manager.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index d4a349b..c8e9589 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -1117,7 +1117,7 @@ static int _percent_run(struct dev_manager *dm, const char *name,
 			goto_out;
 	}
 
-	log_debug_activation("LV percent: %f", dm_percent_to_float(*overall_percent));
+	log_debug_activation("LV percent: %.2f", dm_percent_to_float(*overall_percent));
 	r = 1;
 
       out:


