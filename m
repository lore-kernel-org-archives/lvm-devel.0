From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 13 Apr 2015 18:48:33 +0000 (UTC)
Subject: master - config: fix description syntax errors
Message-ID: <20150413184833.E870C60A62@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fa16c9b7cbe5a4d71452247765142c670b3b0e31
Commit:        fa16c9b7cbe5a4d71452247765142c670b3b0e31
Parent:        29220a181ac3ad0faf63681e465f0a9ba9e625dd
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Apr 13 13:48:01 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Apr 13 13:48:01 2015 -0500

config: fix description syntax errors

from previous commit
---
 lib/config/config_settings.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index 84c81c6..1e53c7e 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -196,7 +196,7 @@ cfg_array(devices_filter_CFG, "filter", devices_CFG_SECTION, CFG_DEFAULT_UNDEFIN
 	"See the use_lvmetad comment for a special case regarding filters.\n"
 	"Example:\n"
 	"Accept every block device.\n"
-	"filter = [ \"a|.*/|" ]\n"
+	"filter = [ \"a|.*/|\" ]\n"
 	"Example:\n"
 	"Reject the cdrom drive.\n"
 	"filter = [ \"r|/dev/cdrom|\" ]\n"
@@ -208,7 +208,7 @@ cfg_array(devices_filter_CFG, "filter", devices_CFG_SECTION, CFG_DEFAULT_UNDEFIN
 	"filter =[ \"a|loop|\", \"r|/dev/hdc|\", \"a|/dev/ide|\", \"r|.*|\" ]\n"
 	"Example:\n"
 	"Use anchors to be very specific.\n"
-	"filter = [ \"a|^/dev/hda8$|\", \"r|.*/|" ]\n")
+	"filter = [ \"a|^/dev/hda8$|\", \"r|.*/|\" ]\n")
 
 cfg_array(devices_global_filter_CFG, "global_filter", devices_CFG_SECTION, CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(2, 2, 98),
 	"Since filter is often overridden from the command line,\n"


