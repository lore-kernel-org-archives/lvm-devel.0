From: Thomas Woerner <twoerner@redhat.com>
Date: Mon, 20 Jul 2009 18:23:47 +0200
Subject: [PATCH 1/2] Fix compile warnings
Message-ID: <1248107028-1130-1-git-send-email-twoerner@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Fix compile warnings of an api test case.

---
 test/api/vgcreate.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/test/api/vgcreate.c b/test/api/vgcreate.c
index c09e7a8..d2b089b 100644
--- a/test/api/vgcreate.c
+++ b/test/api/vgcreate.c
@@ -23,8 +23,8 @@
 
 lvm_t handle;
 vg_t *vg;
-char *vg_name = "my_vg";
-char *device = "/dev/loop3";
+const char *vg_name = "my_vg";
+const char *device = "/dev/loop3";
 uint64_t size = 1024;
 
 int main(int argc, char *argv[])
@@ -55,7 +55,7 @@ int main(int argc, char *argv[])
 		goto bad;
 	}
 
-	printf("Setting VG %s extent_size to %d\n", vg_name, size);
+	printf("Setting VG %s extent_size to %ld\n", vg_name, size);
 	status = lvm_vg_set_extent_size(vg, size);
 	if (!status) {
 		fprintf(stderr, "Can not set physical extent "
-- 
1.6.2.5


