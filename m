From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue,  1 Sep 2020 17:02:00 +0000 (GMT)
Subject: master - gcc: change zero-sized array to fexlible array
Message-ID: <20200901170200.C0A4C38708C6@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=cc2218b4014015bd2633454e683293851183e08c
Commit:        cc2218b4014015bd2633454e683293851183e08c
Parent:        0f377a04e5563166e4b865e92bc36d088107561a
Author:        Zhao Heming <heming.zhao@suse.com>
AuthorDate:    Fri Aug 21 00:05:04 2020 +0800
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Sep 1 17:57:50 2020 +0200

gcc: change zero-sized array to fexlible array

this patch makes gcc happy with compiling option: [-Wstringop-overflow=]

Signed-off-by: Zhao Heming <heming.zhao@suse.com>
---
 device_mapper/libdm-common.c | 2 +-
 lib/activate/fs.c            | 2 +-
 libdm/libdm-common.c         | 2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/device_mapper/libdm-common.c b/device_mapper/libdm-common.c
index b6d08f557..9b87e4e74 100644
--- a/device_mapper/libdm-common.c
+++ b/device_mapper/libdm-common.c
@@ -1445,7 +1445,7 @@ struct node_op_parms {
 	char *old_name;
 	int warn_if_udev_failed;
 	unsigned rely_on_udev;
-	char names[0];
+	char names[];
 };
 
 static void _store_str(char **pos, char **ptr, const char *str)
diff --git a/lib/activate/fs.c b/lib/activate/fs.c
index b2c99fc06..96f7df678 100644
--- a/lib/activate/fs.c
+++ b/lib/activate/fs.c
@@ -313,7 +313,7 @@ struct fs_op_parms {
 	char *lv_name;
 	char *dev;
 	char *old_lv_name;
-	char names[0];
+	char names[];
 };
 
 static void _store_str(char **pos, char **ptr, const char *str)
diff --git a/libdm/libdm-common.c b/libdm/libdm-common.c
index 466c74bb9..a28829765 100644
--- a/libdm/libdm-common.c
+++ b/libdm/libdm-common.c
@@ -1443,7 +1443,7 @@ struct node_op_parms {
 	char *old_name;
 	int warn_if_udev_failed;
 	unsigned rely_on_udev;
-	char names[0];
+	char names[];
 };
 
 static void _store_str(char **pos, char **ptr, const char *str)


