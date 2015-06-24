From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 24 Jun 2015 09:27:50 +0000 (UTC)
Subject: master - config: devices/filter and devices/global_filter setting have 'a/.*/' as default value
Message-ID: <20150624092750.0FCFC60DF6@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=63c5aaaaf22716f8a04df43b7f7ac4611445b677
Commit:        63c5aaaaf22716f8a04df43b7f7ac4611445b677
Parent:        c725648f6c3c5709c0a6823900c716d67a31818d
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Jun 24 11:21:12 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Jun 24 11:23:54 2015 +0200

config: devices/filter and devices/global_filter setting have 'a/.*/' as default value

---
 lib/config/config_settings.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index e5edf6d..2c5e2f8 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -220,7 +220,7 @@ cfg_array(devices_preferred_names_CFG, "preferred_names", devices_CFG_SECTION, C
 	"Example:\n"
 	"preferred_names = [ \"^/dev/mpath/\", \"^/dev/mapper/mpath\", \"^/dev/[hs]d\" ]\n")
 
-cfg_array(devices_filter_CFG, "filter", devices_CFG_SECTION, CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(1, 0, 0), NULL, 0, NULL,
+cfg_array(devices_filter_CFG, "filter", devices_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, "#Sa|.*/|", vsn(1, 0, 0), NULL, 0, NULL,
 	"Limit the block devices that are used by LVM commands.\n"
 	"This is a list of regular expressions used to accept or\n"
 	"reject block device path names.  Each regex is delimited\n"
@@ -255,7 +255,7 @@ cfg_array(devices_filter_CFG, "filter", devices_CFG_SECTION, CFG_DEFAULT_UNDEFIN
 	"Use anchors to be very specific.\n"
 	"filter = [ \"a|^/dev/hda8$|\", \"r|.*/|\" ]\n")
 
-cfg_array(devices_global_filter_CFG, "global_filter", devices_CFG_SECTION, CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(2, 2, 98), NULL, 0, NULL,
+cfg_array(devices_global_filter_CFG, "global_filter", devices_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, "#Sa|.*/|", vsn(2, 2, 98), NULL, 0, NULL,
 	"Limit the block devices that are used by LVM system components.\n"
 	"Because devices/filter may be overridden from the command line,\n"
 	"it is not suitable for system-wide device filtering, e.g. udev\n"


