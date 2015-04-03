From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri,  3 Apr 2015 15:18:39 +0000 (UTC)
Subject: master - pvmove: don't crash when name is not found
Message-ID: <20150403151839.DCE6C60AAB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4f94669eca3c2a90577a972fd748f4b0c4e89928
Commit:        4f94669eca3c2a90577a972fd748f4b0c4e89928
Parent:        c88ffbf9dfab5c636b45c51fda6ecf1e6f270b85
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Apr 3 17:14:50 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 3 17:18:11 2015 +0200

pvmove: don't crash when name is not found

If the device name is not found in our metadata,
we cannot call strdup few lines later with NULL name.

More intersting story goes behind how it happens -
pvmove removal is unfortunatelly 'multi-state' process
and at some point (for now)  we have in lvm2 metadata
LV  pvmove0 as stripe  and mirror image as error.

If such metadata are left - we fail with any further removal.
---
 tools/polldaemon.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/tools/polldaemon.c b/tools/polldaemon.c
index 6cdcbbb..1b6e1b4 100644
--- a/tools/polldaemon.c
+++ b/tools/polldaemon.c
@@ -223,6 +223,12 @@ static int _poll_vg(struct cmd_context *cmd, const char *vgname,
 		if (!name && !parms->aborting)
 			continue;
 
+		if (!name) {
+			log_error("Device name for LV %s not found in metadata. "
+				  "(unfinished pvmove mirror removal?)", display_lvname(lv));
+			goto err;
+		}
+
 		/* FIXME Need to do the activation from _set_up_pvmove here
 		 *       if it's not running and we're not aborting. */
 		if (!lv_is_active(lv)) {


