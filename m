From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 22 Feb 2016 13:28:23 +0000 (UTC)
Subject: master - lvmetad: fix error path
Message-ID: <20160222132823.A152A61025@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=30a73d1604aeb318709a01f4cc238e2d872be8de
Commit:        30a73d1604aeb318709a01f4cc238e2d872be8de
Parent:        44b3909e588bc8d1896b4a94cf7d0ce85e251960
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Feb 22 10:45:01 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Feb 22 14:15:53 2016 +0100

lvmetad: fix error path

Coverity noticed the internal error path would  be using uninit struct.
So always make sure reply is initilized.
---
 WHATS_NEW           |    1 +
 lib/cache/lvmetad.c |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index f94cabd..f15d885 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.144 - 
 =====================================
+  Fix error path for internal error in lvmetad vg lookup code.
 
 Version 2.02.143 - 21st February 2016
 =====================================
diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index 7d6356d..dbb3739 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -507,7 +507,7 @@ struct volume_group *lvmetad_vg_lookup(struct cmd_context *cmd, const char *vgna
 {
 	struct volume_group *vg = NULL;
 	struct volume_group *vg2 = NULL;
-	daemon_reply reply;
+	daemon_reply reply = { 0 };
 	int found;
 	char uuid[64];
 	struct format_instance *fid = NULL;


