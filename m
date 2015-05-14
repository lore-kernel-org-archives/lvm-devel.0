From: David Teigland <teigland@fedoraproject.org>
Date: Thu, 14 May 2015 14:27:35 +0000 (UTC)
Subject: master - config: avoid configurable description text
Message-ID: <20150514142735.A025860AA3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=cf93fe39e33a3550725a06272f6008b02281918f
Commit:        cf93fe39e33a3550725a06272f6008b02281918f
Parent:        4931d0132c45d3da5cce12ccf76ac2a8774cef39
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu May 14 09:25:48 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu May 14 09:25:48 2015 -0500

config: avoid configurable description text

It's just simpler to avoid configurable values in
the description text by rewording to avoid them.
---
 lib/config/config_settings.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index d1d35b1..a7cb5d0 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -903,7 +903,7 @@ cfg(global_system_id_source_CFG, "system_id_source", global_CFG_SECTION, 0, CFG_
 	"'local' section of an lvm configuration file, e.g. lvmlocal.conf.\n"
 	"uname - Set the system ID from the hostname (uname) of the system.\n"
 	"System IDs beginning localhost are not permitted.\n"
-	"machineid - Use the contents of the file " DEFAULT_ETC_DIR "/machine-id to set the\n"
+	"machineid - Use the contents of the machine-id file to set the\n"
 	"system ID.  Some systems create this file at installation time.\n"
 	"See 'man machine-id'.\n"
 	"file - Use the contents of another file (system_id_file) to set\n"


