From: 肖丁 <xiaoding@fiberhome.com>
Date: Thu, 23 Mar 2017 20:44:06 +0800
Subject: [PATCH] devices: support rbd
Message-ID: <2017032320440598730729@fiberhome.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Support Ceph rbd device
Signed-off-by: Seaton Xiao <xiaoding@fiberhome.com>
---
 lib/device/device-types.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/lib/device/device-types.h b/lib/device/device-types.h
index 2834cd1..ff53297 100644
--- a/lib/device/device-types.h
+++ b/lib/device/device-types.h
@@ -64,5 +64,6 @@ static const dev_known_type_t _dev_known_types[] = {
 	{"nvme", 64, "NVM Express"},
 	{"zvol", 16, "ZFS Zvols"},
 	{"VxDMP", 16, "Veritas Dynamic Multipathing"},
+	{"rbd", 1, "Ceph RBD device"},
 	{"", 0, ""}
 };
-- 
1.8.3.1

-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20170323/b1ca8718/attachment.htm>
