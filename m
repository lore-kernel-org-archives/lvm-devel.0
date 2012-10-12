From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 12 Oct 2012 10:22:19 +0000 (UTC)
Subject: master - thin: lvm2api return origin property for thin LV
Message-ID: <20121012102219.6B98BA2BCE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=be291e106458a0ae1024bd517a37d471c032c505
Commit:        be291e106458a0ae1024bd517a37d471c032c505
Parent:        abb07a1b5ee2bbe4def9218c6fdf05b0a5718e12
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 12 12:02:15 2012 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 12 12:20:55 2012 +0200

thin: lvm2api return origin property for thin LV

---
 WHATS_NEW               |    1 +
 lib/metadata/lv.c       |    4 ++++
 test/api/thin_percent.c |    4 ++++
 3 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index e419a46..047e2ed 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.98 -
 =================================
+  Fix lvm2api origin reporting for thin snapshot volume.
   Add configure --enable-python_bindings for liblvm2app to new python subdir.
   Add implementation of lvm2api function lvm_percent_to_float.
   Allow non power of 2 thin chunk sizes if thin pool driver supports that.
diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index 33e3270..4032f34 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -160,6 +160,10 @@ char *lv_origin_dup(struct dm_pool *mem, const struct logical_volume *lv)
 {
 	if (lv_is_cow(lv))
 		return lv_name_dup(mem, origin_from_cow(lv));
+
+	if (lv_is_thin_volume(lv) && first_seg(lv)->origin)
+		return lv_name_dup(mem, first_seg(lv)->origin);
+
 	return NULL;
 }
 
diff --git a/test/api/thin_percent.c b/test/api/thin_percent.c
index 5338164..2c8b19b 100644
--- a/test/api/thin_percent.c
+++ b/test/api/thin_percent.c
@@ -57,6 +57,10 @@ int main(int argc, char *argv[])
 	assert(v.is_valid);
 	assert(v.value.integer == PERCENT_INVALID);
 
+	v = lvm_lv_get_property(lv, "origin");
+	assert(v.is_valid);
+	assert(strcmp(v.value.string, "thin") == 0);
+
 	lvm_vg_close(vg);
 	lvm_quit(handle);
 


