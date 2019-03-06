From: David Teigland <teigland@sourceware.org>
Date: Wed, 6 Mar 2019 14:37:43 -0500
Subject: master - config: improve scan_lvs description
Message-ID: <201903061937.x26JbhaW029946@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9b2b0fef9c6c475a2023b9e5ca9525d850aed1cc
Commit:        9b2b0fef9c6c475a2023b9e5ca9525d850aed1cc
Parent:        98b7a3a42dd3adc13b87233846ae2e8e1f6b4bb0
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Mar 6 13:33:07 2019 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Mar 6 13:33:07 2019 -0600

config: improve scan_lvs description

---
 lib/config/config_settings.h |   12 +++++++++++-
 1 files changed, 11 insertions(+), 1 deletions(-)

diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index a2df3ce..efa86e7 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -352,7 +352,17 @@ cfg(devices_sysfs_scan_CFG, "sysfs_scan", devices_CFG_SECTION, 0, CFG_TYPE_BOOL,
 	"present on the system. sysfs must be part of the kernel and mounted.)\n")
 
 cfg(devices_scan_lvs_CFG, "scan_lvs", devices_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_SCAN_LVS, vsn(2, 2, 182), NULL, 0, NULL,
-	"Scan LVM LVs for layered PVs.\n")
+	"Scan LVM LVs for layered PVs, allowing LVs to be used as PVs.\n"
+	"When 1, LVM will detect PVs layered on LVs, and caution must be\n"
+	"taken to avoid a host accessing a layered VG that may not belong\n"
+	"to it, e.g. from a guest image. This generally requires excluding\n"
+	"the LVs with device filters. Also, when this setting is enabled,\n"
+	"every LVM command will scan every active LV on the system (unless\n"
+	"filtered), which can cause performance problems on systems with\n"
+	"many active LVs. When this setting is 0, LVM will not detect or\n"
+	"use PVs that exist on LVs, and will not allow a PV to be created on\n"
+	"an LV. The LVs are ignored using a built in device filter that\n"
+	"identifies and excludes LVs.\n")
 
 cfg(devices_multipath_component_detection_CFG, "multipath_component_detection", devices_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_MULTIPATH_COMPONENT_DETECTION, vsn(2, 2, 89), NULL, 0, NULL,
 	"Ignore devices that are components of DM multipath devices.\n")


