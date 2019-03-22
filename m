From: Marian Csontos <mcsontos@sourceware.org>
Date: Fri, 22 Mar 2019 06:01:31 -0400
Subject: stable-2.02 - build: make generate
Message-ID: <201903221001.x2MA1VCP007639@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=717957ddc5bcca529a4fe830e272c678a935e2ee
Commit:        717957ddc5bcca529a4fe830e272c678a935e2ee
Parent:        9b04851fc574ce9cffd30a51d2b750955239f316
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Fri Mar 22 11:00:13 2019 +0100
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Fri Mar 22 11:01:04 2019 +0100

build: make generate

---
 conf/example.conf.in |   24 ++++++++++++++++++++++++
 1 files changed, 24 insertions(+), 0 deletions(-)

diff --git a/conf/example.conf.in b/conf/example.conf.in
index e6f3462..38855e9 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -185,6 +185,20 @@ devices {
 	# present on the system. sysfs must be part of the kernel and mounted.)
 	sysfs_scan = 1
 
+	# Configuration option devices/scan_lvs.
+	# Scan LVM LVs for layered PVs, allowing LVs to be used as PVs.
+	# When 1, LVM will detect PVs layered on LVs, and caution must be
+	# taken to avoid a host accessing a layered VG that may not belong
+	# to it, e.g. from a guest image. This generally requires excluding
+	# the LVs with device filters. Also, when this setting is enabled,
+	# every LVM command will scan every active LV on the system (unless
+	# filtered), which can cause performance problems on systems with
+	# many active LVs. When this setting is 0, LVM will not detect or
+	# use PVs that exist on LVs, and will not allow a PV to be created on
+	# an LV. The LVs are ignored using a built in device filter that
+	# identifies and excludes LVs.
+	scan_lvs = 0
+
 	# Configuration option devices/multipath_component_detection.
 	# Ignore devices that are components of DM multipath devices.
 	multipath_component_detection = 1
@@ -1113,6 +1127,16 @@ global {
 	# When enabled, an LVM command that changes PVs, changes VG metadata,
 	# or changes the activation state of an LV will send a notification.
 	notify_dbus = 1
+
+	# Configuration option global/io_memory_size.
+	# The amount of memory in KiB that LVM allocates to perform disk io.
+	# LVM performance may benefit from more io memory when there are many
+	# disks or VG metadata is large. Increasing this size may be necessary
+	# when a single copy of VG metadata is larger than the current setting.
+	# This value should usually not be decreased from the default; setting
+	# it too low can result in lvm failing to read VGs.
+	# This configuration option has an automatic default value.
+	# io_memory_size = 8192
 }
 
 # Configuration section activation.


