From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 15 Jul 2013 14:02:50 +0000 (UTC)
Subject: master - cleanup: update comments
Message-ID: <20130715140250.ECFE060642@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9ba77833504fb08456db1fab8a4061b689f7922c
Commit:        9ba77833504fb08456db1fab8a4061b689f7922c
Parent:        a9dbe2c4fa5a9fa18fa1e0223a622708693be27a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Jul 6 11:04:19 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 15 15:40:46 2013 +0200

cleanup: update comments

Add and indent.
---
 lib/display/display.c   |    2 +-
 lib/metadata/lv_manip.c |    2 +-
 tools/lvcreate.c        |    2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/lib/display/display.c b/lib/display/display.c
index e2b0f76..3f7f360 100644
--- a/lib/display/display.c
+++ b/lib/display/display.c
@@ -928,7 +928,7 @@ char yes_no_prompt(const char *prompt, ...)
 		}
 
 		if ((c = getchar()) == EOF) {
-			ret = 'n';
+			ret = 'n'; /* SIGINT */
 			break;
 		}
 
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index ee65332..fa63b78 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -5655,7 +5655,7 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg, struct l
 			}
 			if (lv_is_active(org) && !lv_is_external_origin(org)) {
 				log_error("Cannot use active LV for the external origin.");
-				return 0; // We can't be sure device it is read-only
+				return 0; // We can't be sure device is read-only
 			}
 			if (!attach_thin_external_origin(first_seg(lv), org)) {
 				stack;
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index f69c084..d9578aa 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -634,7 +634,7 @@ static int _read_activation_params(struct lvcreate_params *lp, struct cmd_contex
 		else
 			lp->read_ahead = (lp->read_ahead / pagesize) * pagesize;
 		log_warn("WARNING: Overriding readahead to %u sectors, a multiple "
-			    "of %uK page size.", lp->read_ahead, pagesize >> 1);
+			 "of %uK page size.", lp->read_ahead, pagesize >> 1);
 	}
 
 	/*


