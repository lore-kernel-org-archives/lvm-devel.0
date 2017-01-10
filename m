From: Alasdair Kergon <agk@fedoraproject.org>
Date: Tue, 10 Jan 2017 22:30:32 +0000 (UTC)
Subject: master - devices: Recognise Veritas Dynamic Multipathing
Message-ID: <20170110223032.E15A46053A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6a20b221516fcecda25bc56996028eb50b3250f8
Commit:        6a20b221516fcecda25bc56996028eb50b3250f8
Parent:        15e657f110351ab16af8bd79e1716adce9b75beb
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Jan 10 22:23:23 2017 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Jan 10 22:23:23 2017 +0000

devices: Recognise Veritas Dynamic Multipathing

VxDMP doesn't interact very well with udev so always set
  devices/obtain_device_list_from_udev = 0
in lvm.conf on these systems.
---
 lib/device/dev-type.c     |   10 ++++++++++
 lib/device/dev-type.h     |    1 +
 lib/device/device-types.h |    1 +
 3 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/lib/device/dev-type.c b/lib/device/dev-type.c
index cc6777d..325b66b 100644
--- a/lib/device/dev-type.c
+++ b/lib/device/dev-type.c
@@ -125,6 +125,10 @@ struct dev_types *create_dev_types(const char *proc_dir,
 		if (!strncmp("emcpower", line + i, 8) && isspace(*(line + i + 8)))
 			dt->emcpower_major = line_maj;
 
+		/* Look for Veritas Dynamic Multipathing */
+		if (!strncmp("VxDMP", line + i, 5) && isspace(*(line + i + 5)))
+			dt->vxdmp_major = line_maj;
+
 		if (!strncmp("loop", line + i, 4) && isspace(*(line + i + 4)))
 			dt->loop_major = line_maj;
 
@@ -218,6 +222,9 @@ int dev_subsystem_part_major(struct dev_types *dt, struct device *dev)
 	if (MAJOR(dev->dev) == dt->power2_major)
 		return 1;
 
+	if (MAJOR(dev->dev) == dt->vxdmp_major)
+		return 1;
+
 	if ((MAJOR(dev->dev) == dt->blkext_major) &&
 	    dev_get_primary_dev(dt, dev, &primary_dev) &&
 	    (MAJOR(primary_dev) == dt->md_major))
@@ -246,6 +253,9 @@ const char *dev_subsystem_name(struct dev_types *dt, struct device *dev)
 	if (MAJOR(dev->dev) == dt->power2_major)
 		return "POWER2";
 
+	if (MAJOR(dev->dev) == dt->vxdmp_major)
+		return "VXDMP";
+
 	if (MAJOR(dev->dev) == dt->blkext_major)
 		return "BLKEXT";
 
diff --git a/lib/device/dev-type.h b/lib/device/dev-type.h
index 33622fe..b0adfe2 100644
--- a/lib/device/dev-type.h
+++ b/lib/device/dev-type.h
@@ -41,6 +41,7 @@ struct dev_types {
 	int drbd_major;
 	int device_mapper_major;
 	int emcpower_major;
+	int vxdmp_major;
 	int power2_major;
 	int dasd_major;
 	int loop_major;
diff --git a/lib/device/device-types.h b/lib/device/device-types.h
index 2c1e4ac..2834cd1 100644
--- a/lib/device/device-types.h
+++ b/lib/device/device-types.h
@@ -63,5 +63,6 @@ static const dev_known_type_t _dev_known_types[] = {
 	{"bcache", 1, "bcache block device cache"},
 	{"nvme", 64, "NVM Express"},
 	{"zvol", 16, "ZFS Zvols"},
+	{"VxDMP", 16, "Veritas Dynamic Multipathing"},
 	{"", 0, ""}
 };


