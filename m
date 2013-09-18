From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed, 18 Sep 2013 08:38:13 +0000 (UTC)
Subject: master - vgcfgrestore: Remove the VG from lvmetad before overwriting it.
Message-ID: <20130918083813.5E81960E7A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a6af611ae127de202be9e172099c6efe9ed41d7e
Commit:        a6af611ae127de202be9e172099c6efe9ed41d7e
Parent:        c2dd0a832a8f06471f86e8244884c4dc902cc9f7
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Wed Sep 18 10:34:38 2013 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Wed Sep 18 10:37:29 2013 +0200

vgcfgrestore: Remove the VG from lvmetad before overwriting it.

---
 tools/vgcfgrestore.c |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/tools/vgcfgrestore.c b/tools/vgcfgrestore.c
index 36396c3..f560836 100644
--- a/tools/vgcfgrestore.c
+++ b/tools/vgcfgrestore.c
@@ -57,6 +57,14 @@ int vgcfgrestore(struct cmd_context *cmd, int argc, char **argv)
 		return ECMD_FAILED;
 	}
 
+	if (lvmetad_active()) {
+		struct volume_group *vg = lvmetad_vg_lookup(cmd, vg_name, NULL);
+		if (vg) {
+			lvmetad_vg_remove(vg);
+			release_vg(vg);
+		}
+	}
+
 	cmd->handles_unknown_segments = 1;
 
 	if (!(arg_count(cmd, file_ARG) ?


