From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  6 Oct 2014 13:33:54 +0000 (UTC)
Subject: master - cleanup: indent
Message-ID: <20141006133354.361A160DB1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b7a78d81bc52b8a9078bd9d57ab900032f8e5729
Commit:        b7a78d81bc52b8a9078bd9d57ab900032f8e5729
Parent:        d9d50e4533193d75057bb2444eb899d33598968a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 6 12:10:00 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 6 15:23:08 2014 +0200

cleanup: indent

---
 tools/lvcreate.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 97c8d94..0dc3699 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -1240,8 +1240,8 @@ int lvcreate(struct cmd_context *cmd, int argc, char **argv)
 {
 	int r = ECMD_FAILED;
 	struct lvcreate_params lp = {
-                .major = -1,
-                .minor = -1,
+		.major = -1,
+		.minor = -1,
 	};
 	struct lvcreate_cmdline_params lcp;
 	struct volume_group *vg;


