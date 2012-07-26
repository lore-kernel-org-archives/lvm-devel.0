From: Alasdair Kergon <agk@fedoraproject.org>
Date: Thu, 26 Jul 2012 11:24:07 +0000 (UTC)
Subject: master - filters: move device_info_t definition to header
Message-ID: <20120726112407.1AA1C2300@lists.fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=45db25817ff342a86b2ddf000b4b3a4d59be8848
Commit:        45db25817ff342a86b2ddf000b4b3a4d59be8848
Parent:        9161308252336491a107983ed16481e446853e26
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Thu Jul 26 12:22:55 2012 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Thu Jul 26 12:22:55 2012 +0100

filters: move device_info_t definition to header

---
 lib/filters/device-types.h |    5 +++++
 lib/filters/filter.c       |    9 ++-------
 2 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/lib/filters/device-types.h b/lib/filters/device-types.h
index 1208160..9efbe68 100644
--- a/lib/filters/device-types.h
+++ b/lib/filters/device-types.h
@@ -13,6 +13,11 @@
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
 
+typedef struct {
+	const char name[15];
+	const int8_t max_partitions;
+} device_info_t;
+
 /*
  * Devices are only checked for partition tables if their minor number
  * is a multiple of the number corresponding to their type below
diff --git a/lib/filters/filter.c b/lib/filters/filter.c
index bab20ec..dcb6c5e 100644
--- a/lib/filters/filter.c
+++ b/lib/filters/filter.c
@@ -27,6 +27,8 @@
 #include <fcntl.h>
 #include <limits.h>
 
+#include "device-types.h"
+
 #define NUMBER_OF_MAJORS 4096
 
 #define PARTITION_SCSI_DEVICE (1 << 0)
@@ -35,13 +37,6 @@ static struct {
 	int flags;
 } _partitions[NUMBER_OF_MAJORS];
 
-typedef struct {
-	const char name[15];
-	const int8_t max_partitions;
-} device_info_t;
-
-#include "device-types.h"
-
 static int _md_major = -1;
 static int _blkext_major = -1;
 static int _drbd_major = -1;


