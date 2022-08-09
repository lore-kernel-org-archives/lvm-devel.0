From: Marian Csontos <mcsontos@sourceware.org>
Date: Tue,  9 Aug 2022 14:18:05 +0000 (GMT)
Subject: main - config: add correct unconfigured value for use_devicesfile
Message-ID: <20220809141805.95276385AC2F@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2fc52b6c41172fc4ae15e736fae095aa681ff03a
Commit:        2fc52b6c41172fc4ae15e736fae095aa681ff03a
Parent:        4e6ed2c458a47b2ea4b43c4e0b00ec070040a592
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Tue Aug 9 16:04:09 2022 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Tue Aug 9 16:17:45 2022 +0200

config: add correct unconfigured value for use_devicesfile

---
 conf/example.conf.in         | 2 +-
 lib/config/config_settings.h | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/conf/example.conf.in b/conf/example.conf.in
index 4e5482fee..5fadeac12 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -126,7 +126,7 @@ devices {
 	# be used, regardless of this setting, when the --devicesfile
 	# option is set to a specific file name.
 	# This configuration option has an automatic default value.
-	# use_devicesfile = 0
+	# use_devicesfile = @DEFAULT_USE_DEVICES_FILE@
 
 	# Configuration option devices/devicesfile.
 	# The name of the system devices file, listing devices that LVM should use.
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index e97e12152..d2811df2b 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -277,7 +277,7 @@ cfg_array(devices_preferred_names_CFG, "preferred_names", devices_CFG_SECTION, C
 	"preferred_names = [ \"^/dev/mpath/\", \"^/dev/mapper/mpath\", \"^/dev/[hs]d\" ]\n"
 	"#\n")
 
-cfg(devices_use_devicesfile_CFG, "use_devicesfile", devices_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_BOOL, DEFAULT_USE_DEVICES_FILE, vsn(2, 3, 12), NULL, 0, NULL,
+cfg(devices_use_devicesfile_CFG, "use_devicesfile", devices_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_BOOL, DEFAULT_USE_DEVICES_FILE, vsn(2, 3, 12), "@DEFAULT_USE_DEVICES_FILE@", 0, NULL,
 	"Enable or disable the use of a devices file.\n"
 	"When enabled, lvm will only use devices that\n"
 	"are lised in the devices file. A devices file will\n"

