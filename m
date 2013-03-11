From: Alasdair Kergon <agk@fedoraproject.org>
Date: Mon, 11 Mar 2013 20:12:29 +0000 (UTC)
Subject: master - filters: power2 devs get precedence if PVIDs match
Message-ID: <20130311201229.57043A0C5F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=cbfb5a98b5dbe699aaafbced00120f60aaa35231
Commit:        cbfb5a98b5dbe699aaafbced00120f60aaa35231
Parent:        69ae454d4d46228a5de3b95a2ddcd8b8307fed4a
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon Mar 11 20:10:49 2013 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Mon Mar 11 20:10:49 2013 +0000

filters: power2 devs get precedence if PVIDs match

Give precedence to EMC "power2" devices with duplicate PVIDs like
we already do with "emcpower" devices.
---
 WHATS_NEW            |    1 +
 lib/filters/filter.c |   10 ++++++++++
 2 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index d7dda58..082b414 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Give precedence to EMC power2 devices with duplicate PVIDs.
   Add --validate option to lvm dumpconfig to validate current config on demand.
   Add --ignoreadvanced and --ignoreunsupported switch to lvm dumpconfig.
   Add --withcomments and --withversions switch to lvm dumpconfig.
diff --git a/lib/filters/filter.c b/lib/filters/filter.c
index 6981b94..7925440 100644
--- a/lib/filters/filter.c
+++ b/lib/filters/filter.c
@@ -42,6 +42,7 @@ static int _blkext_major = -1;
 static int _drbd_major = -1;
 static int _device_mapper_major = -1;
 static int _emcpower_major = -1;
+static int _power2_major = -1;
 
 int dm_major(void)
 {
@@ -71,6 +72,9 @@ int dev_subsystem_part_major(const struct device *dev)
 	if (MAJOR(dev->dev) == _emcpower_major)
 		return 1;
 
+	if (MAJOR(dev->dev) == _power2_major)
+		return 1;
+
 	if ((MAJOR(dev->dev) == _blkext_major) &&
 	    (get_primary_dev(sysfs_dir_path(), dev, &primary_dev)) &&
 	    (MAJOR(primary_dev) == _md_major))
@@ -90,6 +94,9 @@ const char *dev_subsystem_name(const struct device *dev)
 	if (MAJOR(dev->dev) == _emcpower_major)
 		return "EMCPOWER";
 
+	if (MAJOR(dev->dev) == _power2_major)
+		return "POWER2";
+
 	if (MAJOR(dev->dev) == _blkext_major)
 		return "BLKEXT";
 
@@ -228,6 +235,9 @@ static int _scan_proc_dev(const char *proc, const struct dm_config_node *cn)
 		if (!strncmp("emcpower", line + i, 8) && isspace(*(line + i + 8)))
 			_emcpower_major = line_maj;
 
+		if (!strncmp("power2", line + i, 6) && isspace(*(line + i + 6)))
+			_power2_major = line_maj;
+
 		/* Look for device-mapper device */
 		/* FIXME Cope with multiple majors */
 		if (!strncmp("device-mapper", line + i, 13) && isspace(*(line + i + 13)))


