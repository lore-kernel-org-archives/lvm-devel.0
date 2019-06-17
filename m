From: David Teigland <teigland@sourceware.org>
Date: Mon, 17 Jun 2019 10:40:53 -0400
Subject: master - config: remove filter typo
Message-ID: <201906171440.x5HEerah015242@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7c697c1058ed32ca6311c3fd4e05f1b444e72aa1
Commit:        7c697c1058ed32ca6311c3fd4e05f1b444e72aa1
Parent:        1d1741b23abe7f5abe2c9e15e3816957d43eab42
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Jun 17 09:38:24 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Jun 17 09:38:24 2019 -0500

config: remove filter typo

Remove unnecessary but harmless / in the filter string "a|.*/|".
---
 lib/config/config_settings.h |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index e718dec..7851a76 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -288,7 +288,7 @@ cfg_array(devices_preferred_names_CFG, "preferred_names", devices_CFG_SECTION, C
 	"preferred_names = [ \"^/dev/mpath/\", \"^/dev/mapper/mpath\", \"^/dev/[hs]d\" ]\n"
 	"#\n")
 
-cfg_array(devices_filter_CFG, "filter", devices_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, "#Sa|.*/|", vsn(1, 0, 0), NULL, 0, NULL,
+cfg_array(devices_filter_CFG, "filter", devices_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, "#Sa|.*|", vsn(1, 0, 0), NULL, 0, NULL,
 	"Limit the block devices that are used by LVM commands.\n"
 	"This is a list of regular expressions used to accept or reject block\n"
 	"device path names. Each regex is delimited by a vertical bar '|'\n"
@@ -306,7 +306,7 @@ cfg_array(devices_filter_CFG, "filter", devices_CFG_SECTION, CFG_DEFAULT_COMMENT
 	"#\n"
 	"Example\n"
 	"Accept every block device:\n"
-	"filter = [ \"a|.*/|\" ]\n"
+	"filter = [ \"a|.*|\" ]\n"
 	"Reject the cdrom drive:\n"
 	"filter = [ \"r|/dev/cdrom|\" ]\n"
 	"Work with just loopback devices, e.g. for testing:\n"
@@ -314,10 +314,10 @@ cfg_array(devices_filter_CFG, "filter", devices_CFG_SECTION, CFG_DEFAULT_COMMENT
 	"Accept all loop devices and ide drives except hdc:\n"
 	"filter = [ \"a|loop|\", \"r|/dev/hdc|\", \"a|/dev/ide|\", \"r|.*|\" ]\n"
 	"Use anchors to be very specific:\n"
-	"filter = [ \"a|^/dev/hda8$|\", \"r|.*/|\" ]\n"
+	"filter = [ \"a|^/dev/hda8$|\", \"r|.*|\" ]\n"
 	"#\n")
 
-cfg_array(devices_global_filter_CFG, "global_filter", devices_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, "#Sa|.*/|", vsn(2, 2, 98), NULL, 0, NULL,
+cfg_array(devices_global_filter_CFG, "global_filter", devices_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, "#Sa|.*|", vsn(2, 2, 98), NULL, 0, NULL,
 	"Limit the block devices that are used by LVM system components.\n"
 	"Because devices/filter may be overridden from the command line, it is\n"
 	"not suitable for system-wide device filtering, e.g. udev.\n"


