From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue,  3 Jan 2017 13:56:06 +0000 (UTC)
Subject: master - lvmcmdline: support uint32
Message-ID: <20170103135606.AB29B6100A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9f65a3f0c54fc349da279f9a9e8f1b214945489e
Commit:        9f65a3f0c54fc349da279f9a9e8f1b214945489e
Parent:        e75f0b7c771ac6b3a2925af92a9f3098fa8381a7
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jan 3 13:02:52 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jan 3 14:55:16 2017 +0100

lvmcmdline: support uint32

Add simple function to wrap usage for only uint32 numbers.
Unlike  'int_arg'  which accepts full range of 64bit number
this function will error on numbers out of this range:

   <0, UINT32_MAX>
---
 tools/lvmcmdline.c |    8 ++++++++
 tools/tools.h      |    1 +
 2 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 9a4deb7..ae26957 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -554,6 +554,14 @@ int int_arg(struct cmd_context *cmd __attribute__((unused)), struct arg_values *
 	return 1;
 }
 
+int uint32_arg(struct cmd_context *cmd, struct arg_values *av)
+{
+	if (!int_arg(cmd, av) || (av->ui64_value > UINT32_MAX))
+		return 0;
+
+	return 1;
+}
+
 int int_arg_with_sign(struct cmd_context *cmd __attribute__((unused)), struct arg_values *av)
 {
 	char *ptr;
diff --git a/tools/tools.h b/tools/tools.h
index f6d224f..1419af9 100644
--- a/tools/tools.h
+++ b/tools/tools.h
@@ -144,6 +144,7 @@ int size_kb_arg(struct cmd_context *cmd, struct arg_values *av);
 int size_mb_arg(struct cmd_context *cmd, struct arg_values *av);
 int size_mb_arg_with_percent(struct cmd_context *cmd, struct arg_values *av);
 int int_arg(struct cmd_context *cmd, struct arg_values *av);
+int uint32_arg(struct cmd_context *cmd, struct arg_values *av);
 int int_arg_with_sign(struct cmd_context *cmd, struct arg_values *av);
 int int_arg_with_sign_and_percent(struct cmd_context *cmd, struct arg_values *av);
 int major_arg(struct cmd_context *cmd, struct arg_values *av);


