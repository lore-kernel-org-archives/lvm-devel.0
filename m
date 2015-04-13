From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 13 Apr 2015 18:40:30 +0000 (UTC)
Subject: master - config: update descriptions
Message-ID: <20150413184030.A0A926007A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=29220a181ac3ad0faf63681e465f0a9ba9e625dd
Commit:        29220a181ac3ad0faf63681e465f0a9ba9e625dd
Parent:        e4261ba03784f122759670cc2022a2dcb5f5a3ef
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Apr 13 13:39:30 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Apr 13 13:40:11 2015 -0500

config: update descriptions

- filter, preferred_names
---
 lib/config/config_settings.h |   41 ++++++++++++++++++++++++-----------------
 1 files changed, 24 insertions(+), 17 deletions(-)

diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index ecdf368..84c81c6 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -159,10 +159,11 @@ cfg(devices_external_device_info_source_CFG, "external_device_info_source", devi
 	"only if LVM is compiled with udev support.\n")
 
 cfg_array(devices_preferred_names_CFG, "preferred_names", devices_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(1, 2, 19),
-	"If several entries in the scanned directories correspond to the\n"
-	"same block device and the tools need to display a name for the device,\n"
-	"all the path names are matched against each item in this list of\n"
-	"regular expressions. The first match is used.\n"
+	"Select which path name to display for a block device.\n"
+	"If multiple path names exist for a block device,\n"
+	"and LVM needs to display a name for the device,\n"
+	"the path names are matched against each item in\n"
+	"this list of regular expressions. The first match is used.\n"
 	"Try to avoid using undescriptive /dev/dm-N names, if present.\n"
 	"If no preferred name matches, or if preferred_names are not\n"
 	"defined, built-in rules are used until one produces a preference.\n"
@@ -175,33 +176,39 @@ cfg_array(devices_preferred_names_CFG, "preferred_names", devices_CFG_SECTION, C
 	"preferred_names = [ \"^/dev/mpath/\", \"^/dev/mapper/mpath\", \"^/dev/[hs]d\" ]\n")
 
 cfg_array(devices_filter_CFG, "filter", devices_CFG_SECTION, CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(1, 0, 0),
-	"Patterns used to accept or reject devices found by a scan.\n"
-	"Patterns are regular expressions delimited by any character\n"
-	"and preceded by 'a' for accept or 'r' for reject.\n"
-	"The list is traversed in order, and the first regex that matches\n"
-	"determines if the device is accepted or rejected (ignored).\n"
-	"Devices that don't match any patterns are accepted.\n"
-	"If there are several names for the same device, e.g. from symlinks,\n"
-	"the first pattern matching any of the names determines if the\n"
-	"device is accepted or rejected (depending on whether the first\n"
-	"matching pattern is 'a' or 'r'.)\n"
+	"Limit the block devices that are used by LVM.\n"
+	"This is a list of regular expressions used to accept or\n"
+	"reject block device path names.  Each regex is delimited\n"
+	"by a vertical bar '|' (or any character) and is preceded\n"
+	"by 'a' to accept the path, or by 'r' to reject the path.\n"
+	"The first regex in the list to match the path is used,\n"
+	"producing the 'a' or 'r' result for the device.\n"
+	"When multiple path names exist for a block device, if any\n"
+	"path name matches an 'a' pattern before an 'r' pattern,\n"
+	"then the device is accepted. If all the path names match\n"
+	"an 'r' pattern first, then the device is rejected.\n"
+	"Unmatching path names do not affect the accept or reject\n"
+	"decision. If no path names for a device match a pattern,\n"
+	"then the device is accepted.\n"
+	"Be careful mixing 'a' and 'r' patterns, as the combination\n"
+	"might produce unexpected results (test any changes.)\n"
 	"Run vgscan after changing the filter to regenerate the cache.\n"
 	"See the use_lvmetad comment for a special case regarding filters.\n"
 	"Example:\n"
 	"Accept every block device.\n"
-	"filter = [ \"a/.*/\" ]\n"
+	"filter = [ \"a|.*/|" ]\n"
 	"Example:\n"
 	"Reject the cdrom drive.\n"
 	"filter = [ \"r|/dev/cdrom|\" ]\n"
 	"Example:\n"
 	"Work with just loopback devices, e.g. for testing.\n"
-	"filter = [ \"a/loop/\", \"r/.*/\" ]\n"
+	"filter = [ \"a|loop|\", \"r|.*|\" ]\n"
 	"Example:\n"
 	"Accept all loop devices and ide drives except hdc.\n"
 	"filter =[ \"a|loop|\", \"r|/dev/hdc|\", \"a|/dev/ide|\", \"r|.*|\" ]\n"
 	"Example:\n"
 	"Use anchors to be very specific.\n"
-	"filter = [ \"a|^/dev/hda8$|\", \"r/.*/\" ]\n")
+	"filter = [ \"a|^/dev/hda8$|\", \"r|.*/|" ]\n")
 
 cfg_array(devices_global_filter_CFG, "global_filter", devices_CFG_SECTION, CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(2, 2, 98),
 	"Since filter is often overridden from the command line,\n"


