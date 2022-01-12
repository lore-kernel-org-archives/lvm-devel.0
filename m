From: Lakshmi Narasimhan Sundararajan <lsundararajan@purestorage.com>
Date: Wed, 12 Jan 2022 17:10:40 +0530
Subject: Reg a deadlock specific to our environment
Message-ID: <CAFe+wq18h3W3DwmR-n6v=0cPm4XgiwRsjkq4260uRYyNhAx9Aw@mail.gmail.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi team!

Happy new year to you all!

At my workplace, we have been using dm thin as a storage backend, and
creating virtual block devices on top for application use. We have our own
IO path to service IOs from those virtual block devices.

For providing encryption support, dm crypt is used with those virtual
devices as source.

In such a scenario, when our user space storage application gets restarted,
there are calls to sanitize the storage backend. This involves reading the
thin pool information. This internally, does a vg open call, which ends up
READing to all dm devices, resulting in a deadlock during startup.
To overcome this situation, I extended a filter to ignore all devices that
have
pxd naming part of it. This solves the problem for us.

Is there a better way to handle our deadlock situation?
Is the below posted solution good to be merged back into master?

Please keep me posted. Thanks.

Environment:
[root at ip-10-13-8-103 ~]# dmsetup ls
pwx0-pxMetaFS   (253:4)
pwx0-pxpool-tpool       (253:2)
pwx0-pxpool_tdata       (253:1)
pwx0-pxpool_tmeta       (253:0)
pxd-enc975266130497825237       (253:5)
pwx0-pxpool     (253:3)
pxd-enc954172728677188600       (253:29)
pxd-enc210892910905081987       (253:23)
[root at ip-10-13-8-103 ~]# lsblk
NAME                        MAJ:MIN RM   SIZE RO TYPE  MOUNTPOINT
sdd                           8:48   0   512G  0 disk
??sdd1                        8:49   0     3G  0 part
sdb                           8:16   0   512G  0 disk
??md127                       9:127  0 511.9G  0 raid0
  ??pwx0-pxpool_tdata       253:1    0 507.9G  0 lvm
  ? ??pwx0-pxpool-tpool     253:2    0 507.9G  0 lvm
  ?   ??pwx0-pxMetaFS       253:4    0    64G  0 lvm
  ?   ??pwx0-pxpool         253:3    0 507.9G  1 lvm
  ??pwx0-pxpool_tmeta       253:0    0     2G  0 lvm
    ??pwx0-pxpool-tpool     253:2    0 507.9G  0 lvm
      ??pwx0-pxMetaFS       253:4    0    64G  0 lvm
      ??pwx0-pxpool         253:3    0 507.9G  1 lvm
pxd!pxd954172728677188600   252:2    0   200G  0 disk
??pxd-enc954172728677188600 253:29   0   200G  0 crypt
/mnt/2022-01-11_15-19-52
sdc                           8:32   0   512G  0 disk
pxd!pxd975266130497825237   252:3    0   200G  0 disk
??pxd-enc975266130497825237 253:5    0   200G  0 crypt
/mnt/2022-01-11_19-44-10
sda                           8:0    0   128G  0 disk
??sda2                        8:2    0 124.3G  0 part  /
??sda1                        8:1    0   3.7G  0 part  /boot
pxd!pxd210892910905081987   252:1    0   200G  0 disk
??pxd-enc210892910905081987 253:23   0   200G  0 crypt
/mnt/2022-01-11_08-43-01
[root at ip-10-13-8-103 ~]#



Patch follows:

diff --git a/lib/Makefile.in b/lib/Makefile.in
index c037b4162..f78dd9705 100644
--- a/lib/Makefile.in
+++ b/lib/Makefile.in
@@ -44,6 +44,7 @@ SOURCES =\
        filters/filter-regex.c \
        filters/filter-sysfs.c \
        filters/filter-md.c \
+       filters/filter-pxd.c \
        filters/filter-fwraid.c \
        filters/filter-mpath.c \
        filters/filter-partitioned.c \
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 479d4991c..bc2bda36c 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -1091,6 +1091,17 @@ static struct dev_filter *_init_filter_chain(struct
cmd_context *cmd)
                        nr_filt++;
        }

+       /* pxd filter used by command processing optional */
+       if (find_config_tree_bool(cmd, devices_pxd_component_detection_CFG,
NULL)) {
+               log_debug("enabled pxd component detection");
+               init_pxd_filtering(1);
+               if (!(filters[nr_filt] =
pxd_filter_create(cmd->dev_types))) {
+                       log_error("Failed to create pxd device filter");
+                       goto bad;
+               }
+               nr_filt++;
+       }
+
        /* internal filter used by command processing. */
        if (!(filters[nr_filt] = internal_filter_create())) {
                log_error("Failed to create internal device filter");
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index 2bb72ba71..b9296e0b9 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -367,6 +367,15 @@ cfg(devices_scan_lvs_CFG, "scan_lvs",
devices_CFG_SECTION, 0, CFG_TYPE_BOOL, DEF
 cfg(devices_multipath_component_detection_CFG,
"multipath_component_detection", devices_CFG_SECTION, 0, CFG_TYPE_BOOL,
DEFAULT_MULTIPATH_COMPONENT_DETECTION, vsn(2, 2, 89), NULL, 0, NULL,
        "Ignore devices that are components of DM multipath devices.\n")

+cfg(devices_pxd_component_detection_CFG, "pxd_component_detection",
devices_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_PXD_COMPONENT_DETECTION,
vsn(2, 3, 9), NULL, 0, NULL,
+       "Enable detection and exclusion of PXD component devices.\n"
+       "An PXD component device is a virtual block device that
Purestorage/Portworx\n"
+       "creates. When portworx software stack gets restarted, LVM may READ
back into\n"
+       "these virtual block devices during its internal operation causing
a deadlock.\n"
+       "Enabling this configuration while using PXD virtual device,
allows, LVM\n"
+       "to recover and progress without deadlock. This ignores all virtual
block\n"
+       "devices with 'pxd' naming part of it.\n")
+
 cfg(devices_md_component_detection_CFG, "md_component_detection",
devices_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_MD_COMPONENT_DETECTION,
vsn(1, 0, 18), NULL, 0, NULL,
        "Enable detection and exclusion of MD component devices.\n"
        "An MD component device is a block device that MD uses as part\n"
diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index be4f5ff7f..e2f5ea4f8 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -46,6 +46,7 @@
 #define DEFAULT_EXTERNAL_DEVICE_INFO_SOURCE "none"
 #define DEFAULT_SYSFS_SCAN 1
 #define DEFAULT_MD_COMPONENT_DETECTION 1
+#define DEFAULT_PXD_COMPONENT_DETECTION 0
 #define DEFAULT_FW_RAID_COMPONENT_DETECTION 0
 #define DEFAULT_MD_CHUNK_ALIGNMENT 1
 #define DEFAULT_IGNORE_LVM_MIRRORS 1
diff --git a/lib/filters/filter-pxd.c b/lib/filters/filter-pxd.c
new file mode 100644
index 000000000..03d7893e7
--- /dev/null
+++ b/lib/filters/filter-pxd.c
@@ -0,0 +1,68 @@
+/*
+ * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
+ * Copyright (C) 2004-2012 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+ */
+
+#include "base/memory/zalloc.h"
+#include "lib/misc/lib.h"
+#include "lib/filters/filter.h"
+#include "lib/commands/toolcontext.h"
+
+static int dev_is_pxd(struct dev_types *dt, struct device *dev)
+{
+       if (strstr(dev_name(dev), "pxd")) {
+               log_debug("%s found pxd device %s", __func__,
dev_name(dev));
+               return 1;
+       }
+       return 0;
+}
+
+static int _passes_pxd_filter(struct cmd_context *cmd, struct dev_filter
*f __attribute__((unused)), struct device *dev, const char *use_filter_name)
+{
+       struct dev_types *dt = (struct dev_types *) f->private;
+       int ret;
+
+       if (!pxd_filtering()) {
+               log_debug("pxd filtering not enabled - %s", dev_name(dev));
+               return 1;
+       }
+
+       return !dev_is_pxd(dt, dev);
+}
+
+static void _pxd_filter_destroy(struct dev_filter *f)
+{
+       if (f->use_count)
+               log_error(INTERNAL_ERROR "Destroying pxd filter while in
use %u times.", f->use_count);
+
+       free(f);
+}
+
+struct dev_filter *pxd_filter_create(struct dev_types *dt)
+{
+       struct dev_filter *f;
+
+       if (!(f = zalloc(sizeof(struct dev_filter)))) {
+               log_error("PXD filter allocation failed");
+               return NULL;
+       }
+
+       f->passes_filter = _passes_pxd_filter;
+       f->destroy = _pxd_filter_destroy;
+       f->use_count = 0;
+       f->private = dt;
+
+       log_debug_devs("PXD filter initialised.");
+
+       return f;
+}
diff --git a/lib/filters/filter.h b/lib/filters/filter.h
index 7333cfe3c..5e54bce8a 100644
--- a/lib/filters/filter.h
+++ b/lib/filters/filter.h
@@ -30,6 +30,7 @@ struct dev_filter *partitioned_filter_create(struct
dev_types *dt);
 struct dev_filter *persistent_filter_create(struct dev_types *dt, struct
dev_filter *f);
 struct dev_filter *sysfs_filter_create(void);
 struct dev_filter *signature_filter_create(struct dev_types *dt);
+struct dev_filter *pxd_filter_create(struct dev_types *dt);

 struct dev_filter *internal_filter_create(void);
 int internal_filter_allow(struct dm_pool *mem, struct device *dev);
diff --git a/lib/misc/lvm-globals.c b/lib/misc/lvm-globals.c
index 06855ff13..3154864ac 100644
--- a/lib/misc/lvm-globals.c
+++ b/lib/misc/lvm-globals.c
@@ -26,6 +26,7 @@ static int _silent = 0;
 static int _test = 0;
 static int _use_aio = 0;
 static int _md_filtering = 0;
+static int _pxd_filtering = 0;
 static int _internal_filtering = 0;
 static int _fwraid_filtering = 0;
 static int _pvmove = 0;
@@ -82,6 +83,11 @@ void init_md_filtering(int level)
        _md_filtering = level;
 }

+void init_pxd_filtering(int level)
+{
+       _pxd_filtering = level;
+}
+
 void init_internal_filtering(int level)
 {
        _internal_filtering = level;
@@ -260,6 +266,11 @@ int md_filtering(void)
        return _md_filtering;
 }

+int pxd_filtering(void)
+{
+       return _pxd_filtering;
+}
+
 int internal_filtering(void)
 {
        return _internal_filtering;
diff --git a/lib/misc/lvm-globals.h b/lib/misc/lvm-globals.h
index a54001c6b..aa805e077 100644
--- a/lib/misc/lvm-globals.h
+++ b/lib/misc/lvm-globals.h
@@ -27,6 +27,7 @@ void init_silent(int silent);
 void init_test(int level);
 void init_use_aio(int useaio);
 void init_md_filtering(int level);
+void init_pxd_filtering(int level);
 void init_internal_filtering(int level);
 void init_fwraid_filtering(int level);
 void init_pvmove(int level);
@@ -60,6 +61,7 @@ void set_sysfs_dir_path(const char *path);
 int test_mode(void);
 int use_aio(void);
 int md_filtering(void);
+int pxd_filtering(void);
 int internal_filtering(void);
 int fwraid_filtering(void);
 int pvmove_mode(void);
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20220112/53cce1a2/attachment.htm>
