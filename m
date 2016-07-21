From: Bryn Reeves <bmr@fedoraproject.org>
Date: Thu, 21 Jul 2016 16:30:02 +0000 (UTC)
Subject: master - vgcreate: check vg_name and PV arguments
Message-ID: <20160721163002.911B7602A3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a81c1749923ba8861f1af91be61765f0599bf61c
Commit:        a81c1749923ba8861f1af91be61765f0599bf61c
Parent:        259f9dd71817ad33195384dbeca14b39dfb77ae1
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Thu Jul 21 17:28:26 2016 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Thu Jul 21 17:28:26 2016 +0100

vgcreate: check vg_name and PV arguments

---
 tools/vgcreate.c |   12 ++++++++++++
 1 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/tools/vgcreate.c b/tools/vgcreate.c
index af0c363..85b0b82 100644
--- a/tools/vgcreate.c
+++ b/tools/vgcreate.c
@@ -38,6 +38,18 @@ int vgcreate(struct cmd_context *cmd, int argc, char **argv)
 	argc--;
 	argv++;
 
+	if (strchr(vg_name, '/')) {
+		log_error("Volume group name expected before physical volume "
+			  "arguments");
+		return EINVALID_CMD_LINE;
+	}
+
+	if (!argc) {
+		log_error("Please provide physical volumes for new volume "
+			  "group %s", vg_name);
+		return EINVALID_CMD_LINE;
+	}
+
 	pvcreate_params_set_defaults(&pp);
 
 	if (!pvcreate_params_from_args(cmd, &pp))


