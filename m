From: David Teigland <teigland@fedoraproject.org>
Date: Mon,  9 Nov 2015 19:26:34 +0000 (UTC)
Subject: master - vgrename: check if new and old names match
Message-ID: <20151109192634.EB633605B5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7ec61cd5b9d4fcafa5313602f0a0696fa4690f6c
Commit:        7ec61cd5b9d4fcafa5313602f0a0696fa4690f6c
Parent:        cd937efa77dcd8713aa7679728001c11e20fab70
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Nov 9 13:23:59 2015 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Nov 9 13:23:59 2015 -0600

vgrename: check if new and old names match

When the first arg is a UUID and vgrename translates
that UUID to a current VG name, the old and new VG
names are not being checked for equality.  If they
are equal, it produces an internal error rather than
a proper error.
---
 tools/vgrename.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/tools/vgrename.c b/tools/vgrename.c
index 316228a..07d992e 100644
--- a/tools/vgrename.c
+++ b/tools/vgrename.c
@@ -110,7 +110,13 @@ static int vg_rename_path(struct cmd_context *cmd, const char *old_vg_path,
 	log_suppress(2);
 	found_id = id_read_format(&id, vg_name_old);
 	log_suppress(0);
+
 	if (found_id && (vg_name = lvmcache_vgname_from_vgid(cmd->mem, (char *)id.uuid))) {
+		if (!strcmp(vg_name, vg_name_new)) {
+			log_error("New VG name must differ from the old VG name.");
+			return 0;
+		}
+
 		vg_name_old = vg_name;
 		vgid = (char *)id.uuid;
 	} else


