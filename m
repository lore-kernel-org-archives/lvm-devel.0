From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri,  6 May 2016 15:21:33 +0000 (UTC)
Subject: master - activation: activation check is mandatory
Message-ID: <20160506152133.8D0F260F6C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1202713f94cb2b0f6f5160d49615f4b839a862a7
Commit:        1202713f94cb2b0f6f5160d49615f4b839a862a7
Parent:        2842a645fdb66ce1f90cad1fd206912eef365059
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri May 6 13:59:50 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri May 6 16:48:16 2016 +0200

activation: activation check is mandatory

Make missing activation() check before calling target_persent
an INTERNAL_ERROR.
---
 lib/activate/activate.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 712f86c..1ef83d3 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -636,9 +636,10 @@ int target_present_version(struct cmd_context *cmd, const char *target_name,
 			   int use_modprobe,
 			   uint32_t *maj, uint32_t *min, uint32_t *patchlevel)
 {
-	if (!activation())
-		return_0;
-
+	if (!activation()) {
+		log_error(INTERNAL_ERROR "Target present version called when activation is disabled.");
+		return 0;
+	}
 #ifdef MODPROBE_CMD
 	if (use_modprobe) {
 		if (target_version(target_name, maj, min, patchlevel))


