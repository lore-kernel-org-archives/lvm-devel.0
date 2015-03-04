From: Alasdair Kergon <agk@fedoraproject.org>
Date: Wed,  4 Mar 2015 01:01:47 +0000 (UTC)
Subject: master - vgchange: Prevent lvm1 system ID changes.
Message-ID: <20150304010147.828946111C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=dcba4781eaa5545981a831c3c27374d3fce085fe
Commit:        dcba4781eaa5545981a831c3c27374d3fce085fe
Parent:        340369ab2526bc3cf5c52c2738998e589865f4a2
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Wed Mar 4 00:50:54 2015 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Wed Mar 4 00:50:54 2015 +0000

vgchange: Prevent lvm1 system ID changes.

(This system_id setting code shouldn't be in two places.)
---
 tools/vgchange.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/tools/vgchange.c b/tools/vgchange.c
index 8371310..3f97722 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -523,6 +523,13 @@ static int _vgchange_system_id(struct cmd_context *cmd, struct volume_group *vg)
 	const char *system_id;
 	const char *system_id_arg_str = arg_str_value(cmd, systemid_ARG, NULL);
 
+	/* FIXME Merge with vg_set_system_id() */
+	if (systemid_on_pvs(vg)) {
+		log_error("Metadata format %s does not support this type of system ID.",
+			  vg->fid->fmt->name);
+		return 0;
+	}
+
 	if (!(system_id = system_id_from_string(cmd, system_id_arg_str))) {
 		log_error("Unable to set system ID.");
 		return 0;


