From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue,  4 Jun 2013 19:23:54 +0000 (UTC)
Subject: dev-mornfall-activate - CLEAN-UP: Better string checking to avoid substring matches
Message-ID: <20130604192354.71E5860E4F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c363c74a251a5745e8ac6e274d1f7a1e32fa1843
Commit:        c363c74a251a5745e8ac6e274d1f7a1e32fa1843
Parent:        58734d2538854ef79e6605ba69c57723737d12c2
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Fri Apr 12 11:30:04 2013 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Fri Apr 12 11:30:04 2013 -0500

CLEAN-UP:  Better string checking to avoid substring matches

Commit 9fd7ac7d035f0b2f8dcc3cb19935eb181816bd76 introduced a way a
method of avoiding reading from mirrors with a device failure.  If
a device was found to be dead, the mapping table was checked for
'handle_errors' or 'block_on_error'.  These strings were checked for
in the table string via 'strstr', which could also match on strings
like, 'no_handle_errors' or 'no_block_on_error'.  No such strings
exist, but we don't want to have problems in the future if they do.
So, we check for ' <string>{'\0'|' '}'.
---
 lib/activate/dev_manager.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 8c06476..00c0126 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -239,7 +239,7 @@ static int _ignore_blocked_mirror_devices(struct device *dev,
 	dev_t log_dev;
 	char *images_health, *log_health;
 	uint64_t s,l;
-	char *params, *target_type = NULL;
+	char *p, *params, *target_type = NULL;
 	void *next = NULL;
 	struct dm_task *dmt = NULL;
 	int r = 0;
@@ -306,8 +306,10 @@ static int _ignore_blocked_mirror_devices(struct device *dev,
 			if (strcmp(target_type, "mirror"))
 				goto_out;
 
-			if (strstr(params, "block_on_error") ||
-			    strstr(params, "handle_errors")) {
+			if (((p = strstr(params, " block_on_error")) &&
+			     (p[15] == '\0' || p[15] == ' ')) ||
+			    ((p = strstr(params, " handle_errors")) &&
+			     (p[14] == '\0' || p[14] == ' '))) {
 				log_debug_activation("%s: I/O blocked to mirror device",
 						     dev_name(dev));
 				goto out;


