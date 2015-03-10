From: David Teigland <teigland@fedoraproject.org>
Date: Tue, 10 Mar 2015 14:32:12 +0000 (UTC)
Subject: master - vgconvert: require lvmetad to not be used
Message-ID: <20150310143212.9690560E59@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=321e19d9cc868ae475ea1a0a4b026bf5b84ccd5a
Commit:        321e19d9cc868ae475ea1a0a4b026bf5b84ccd5a
Parent:        5dbcbbea58508854904dafe054945ea48baa1642
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Mar 10 09:31:54 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Mar 10 09:31:54 2015 -0500

vgconvert: require lvmetad to not be used

lvmetad does not work with lvm1/format1 metadata,
and vgconvert -M converts to or from lvm1 metadata,
so disallow vgconvert -M when lvmetad is used.
---
 tools/vgconvert.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/tools/vgconvert.c b/tools/vgconvert.c
index 3742237..c4bb37a 100644
--- a/tools/vgconvert.c
+++ b/tools/vgconvert.c
@@ -214,6 +214,11 @@ int vgconvert(struct cmd_context *cmd, int argc, char **argv)
 		return EINVALID_CMD_LINE;
 	}
 
+	if (arg_is_set(cmd, metadatatype_ARG) && lvmetad_used()) {
+		log_error("lvmetad must be disabled to change metadata types.");
+		return EINVALID_CMD_LINE;
+	}
+
 	if (arg_int_value(cmd, labelsector_ARG, 0) >= LABEL_SCAN_SECTORS) {
 		log_error("labelsector must be less than %lu",
 			  LABEL_SCAN_SECTORS);


