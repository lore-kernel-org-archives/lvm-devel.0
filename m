From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  5 Dec 2016 16:15:03 +0000 (UTC)
Subject: master - striped: implement compatible target name
Message-ID: <20161205161503.BDBB5600D3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6a450952add6bc389537aec23fc727ef6e156671
Commit:        6a450952add6bc389537aec23fc727ef6e156671
Parent:        254f73e3efe27e55637e8d3c23abf607564650d7
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Dec 1 16:09:53 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Dec 5 17:02:01 2016 +0100

striped: implement compatible target name

Linear is handled by striped target.
---
 WHATS_NEW             |    1 +
 lib/striped/striped.c |    6 ++++++
 2 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 82222d7..541e3ec 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.169 - 
 =====================================
+  Implement compatible target function for stripe segment.
   Use status info to report merge failed and snapshot invalid lvs fields.
 
 Version 2.02.168 - 30th November 2016
diff --git a/lib/striped/striped.c b/lib/striped/striped.c
index 7d19786..e1de9c9 100644
--- a/lib/striped/striped.c
+++ b/lib/striped/striped.c
@@ -159,6 +159,11 @@ static int _striped_merge_segments(struct lv_segment *seg1, struct lv_segment *s
 }
 
 #ifdef DEVMAPPER_SUPPORT
+static int _striped_target_status_compatible(const char *type)
+{
+	return (strcmp(type, TARGET_NAME_LINEAR) == 0);
+}
+
 static int _striped_add_target_line(struct dev_manager *dm,
 				struct dm_pool *mem __attribute__((unused)),
 				struct cmd_context *cmd __attribute__((unused)),
@@ -218,6 +223,7 @@ static struct segtype_handler _striped_ops = {
 	.text_export = _striped_text_export,
 	.merge_segments = _striped_merge_segments,
 #ifdef DEVMAPPER_SUPPORT
+	.target_status_compatible = _striped_target_status_compatible,
 	.add_target_line = _striped_add_target_line,
 	.target_present = _striped_target_present,
 #endif


