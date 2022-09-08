From: miaoguanqin <miaoguanqin@huawei.com>
Date: Thu, 8 Sep 2022 22:03:40 +0800
Subject: [PATCH] vgremove: PVID file leakage in /run/lvm/pvs_online
Message-ID: <2cbbffed-1d4c-b351-d9e3-8218d8964a7b@huawei.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

We found PVID file leakage problem when exec the following test;
  pvcreate /dev/sdb
  vgcreate -s 1M docker /dev/sdb
  lvcreate -L 10M docker
  pvscan --cache --listvg --checkcomplete --vgonline --udevoutput 
--journal=output /dev/sdb
  vgremove -ff docker

pvcreate operation generates a new PVID, which is used to create PVID 
pvid file
when exec pvcan. However vgremove does not delete the old PVID file.

Here, we will delete all PVID files of each pv in current vg, when exec 
vgremove.

Signed-off-by: miaoguanqin<miaopguanqin@huawei.com
---
  lib/metadata/metadata.c | 33 +++++++++++++++++++++++++++++++++
  1 file changed, 33 insertions(+)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 1cda1888f..75233d120 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -38,6 +38,30 @@
  #include <time.h>
  #include <math.h>

+
+static const char *_pvs_online_dir = DEFAULT_RUN_DIR "/pvs_online";
+
+static int remove_pvid_file(struct physical_volume *pv)
+{
+	char pvid[ID_LEN + 1] __attribute__((aligned(8))) = { 0 };
+	char path[PATH_MAX] __attribute__((aligned(8))) = { 0 };
+
+	memcpy(pvid, &pv->id.uuid, ID_LEN);
+
+	if (dm_snprintf(path, sizeof(path), "%s/%s", _pvs_online_dir, pvid) < 0) {
+		log_warn("WARNING:pvid file path is %s", path);
+		return 0;
+	}
+
+	log_warn("unlink pvid file, path is %s", path);
+
+	if (unlink(path) && (errno != ENOENT)) {
+		log_warn("WARNING:unlink pvid file path error, path is %s", path);
+		return 0;
+	}
+	return 1;
+}
+
  static struct physical_volume *_pv_read(struct cmd_context *cmd,
  					const struct format_type *fmt,
  					struct volume_group *vg,
@@ -665,6 +689,15 @@ int vg_remove_direct(struct volume_group *vg)
  				  " from volume group \"%s\"",
  				  pv_dev_name(pv), vg->name);
  			ret = 0;
+			continue;
+		}
+
+		/* Remove pvid files */
+		if(!remove_pvid_file(pv)){
+			log_error("Failed to remove pvid files \"%s\""
+				  " from volume group \"%s\"",
+				  _pvs_online_dir, vg->name);
+			ret = 0;
  		}
  	}

-- 
2.33.0

