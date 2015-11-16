From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 16 Nov 2015 00:17:18 +0000 (UTC)
Subject: master - coverity: model FD_ZERO
Message-ID: <20151116001718.D2D486029C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5d4f5873a99c3ebe52e671f828580d4cd045e456
Commit:        5d4f5873a99c3ebe52e671f828580d4cd045e456
Parent:        8ebf2b061174daec744f9e361fa7ca28eb19ea2e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 13 20:11:52 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 16 01:16:11 2015 +0100

coverity: model FD_ZERO

Coverity is not able to understand assembly language in
system's header file, so provide model for such macro.

Note: to really see model in-use: #nodef FD_ZERO model_FD_ZERO
need to go to coverity/config/user_nodefs.h
---
 coverity/coverity_model.c |   25 +++++++++++++++++++------
 1 files changed, 19 insertions(+), 6 deletions(-)

diff --git a/coverity/coverity_model.c b/coverity/coverity_model.c
index 947e9c8..d41c67c 100644
--- a/coverity/coverity_model.c
+++ b/coverity/coverity_model.c
@@ -29,19 +29,16 @@
  */
 
 struct lv_segment;
-
-struct logical_volume {
-	struct lv_segment *seg;
-};
+struct logical_volume;
 
 struct lv_segment *first_seg(const struct logical_volume *lv)
 {
-	return lv->seg;
+	return ((struct lv_segment **)lv)[0];
 }
 
 struct lv_segment *last_seg(const struct logical_volume *lv)
 {
-	return lv->seg;
+	return ((struct lv_segment **)lv)[0];
 }
 
 /* simple_memccpy() from glibc */
@@ -58,6 +55,22 @@ void *memccpy(void *dest, const void *src, int c, size_t n)
 }
 
 /*
+ * 2 lines bellow needs to be placed in coverity/config/user_nodefs.h
+ * Not sure about any other way.
+ * Without them, coverity shows warning since x86 system header files
+ * are using inline assembly to reset fdset
+ */
+//#nodef FD_ZERO model_FD_ZERO
+//void model_FD_ZERO(void *fdset);
+
+void model_FD_ZERO(void *fdset)
+{
+	unsigned i;
+	for (i = 0; i < 1024 / 8 / sizeof(int); ++i)
+		((int*)fdset)[i];
+}
+
+/*
  * Added extra pointer check to not need these models,
  * for now just keep then in file
  */


