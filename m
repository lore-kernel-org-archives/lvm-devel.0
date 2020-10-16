From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 16 Oct 2020 19:10:57 +0000 (GMT)
Subject: stable-2.02 - gcc: change zero-sized array to fexlible array
Message-ID: <20201016191057.5BA3C396EC45@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=87769c5713b9bec9482091bb6d68773a5cc887e6
Commit:        87769c5713b9bec9482091bb6d68773a5cc887e6
Parent:        1ac22fb00b5e95645eabd886967cbcaf4768ff09
Author:        Zhao Heming <heming.zhao@suse.com>
AuthorDate:    Fri Aug 21 00:05:04 2020 +0800
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 16 16:02:06 2020 +0200

gcc: change zero-sized array to fexlible array

this patch makes gcc happy with compiling option: [-Wstringop-overflow=]

Signed-off-by: Zhao Heming <heming.zhao@suse.com>
---
 lib/activate/fs.c    | 2 +-
 libdm/libdm-common.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/activate/fs.c b/lib/activate/fs.c
index eeb6c11ef..5935391ce 100644
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
index 906922426..b512efd76 100644
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


