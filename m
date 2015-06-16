From: David Teigland <teigland@fedoraproject.org>
Date: Tue, 16 Jun 2015 19:24:45 +0000 (UTC)
Subject: master - Ignore hyphens in long option names
Message-ID: <20150616192445.C69F460DB6@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1f318dbcee07a309a2b2e8f391897a744e68c477
Commit:        1f318dbcee07a309a2b2e8f391897a744e68c477
Parent:        7fe5e4010ce210b54cfcd7b81d088227fde9b23a
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Jun 16 09:35:52 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Jun 16 09:35:52 2015 -0500

Ignore hyphens in long option names

The hyphens are removed from long option names before
being read.  This means that:

- Option name specifications in args.h must not include hyphens.
  (The hyphen in 'use-policies' is removed.)

- A user can include hyphens anywhere in the option name.
  All the following are equivalent:
  --vgmetadatacopies,
  --vg-metadata-copies,
  --v-g-m-e-t-a-d-a-t-a-c-o-p-i-e-s-
---
 tools/args.h |    2 +-
 tools/lvm.c  |   25 +++++++++++++++++++++++++
 2 files changed, 26 insertions(+), 1 deletions(-)

diff --git a/tools/args.h b/tools/args.h
index 7b715f5..b5c4243 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -117,7 +117,7 @@ arg(cachesettings_ARG, '\0', "cachesettings", string_arg, ARG_GROUPABLE)
 arg(unconfigured_ARG, '\0', "unconfigured", NULL, 0)
 arg(units_ARG, '\0', "units", string_arg, 0)
 arg(unquoted_ARG, '\0', "unquoted", NULL, 0)
-arg(use_policies_ARG, '\0', "use-policies", NULL, 0)
+arg(use_policies_ARG, '\0', "usepolicies", NULL, 0)
 arg(validate_ARG, '\0', "validate", NULL, 0)
 arg(version_ARG, '\0', "version", NULL, 0)
 arg(vgmetadatacopies_ARG, '\0', "vgmetadatacopies", metadatacopies_arg, 0)
diff --git a/tools/lvm.c b/tools/lvm.c
index f9ab438..00cd16f 100644
--- a/tools/lvm.c
+++ b/tools/lvm.c
@@ -16,8 +16,33 @@
 #include "tools.h"
 #include "lvm2cmdline.h"
 
+#define MAX_ARG_LEN 64
+
 int main(int argc, char **argv)
 {
+	char arg_new[MAX_ARG_LEN];
+	char *arg;
+	int i, j, j_new;
+
+	for (i = 1; i < argc; i++) {
+		arg = argv[i];
+
+		if (arg[0] == '-' && arg[1] == '-' && strlen(arg) < MAX_ARG_LEN) {
+			memset(arg_new, 0, sizeof(arg_new));
+			arg_new[0] = '-';
+			arg_new[1] = '-';
+
+			for (j = 2, j_new = 2; j < strlen(arg) + 1; j++) {
+				if (arg[j] == '-')
+					continue;
+				arg_new[j_new] = arg[j];
+				j_new++;
+			}
+
+			memcpy(argv[i], arg_new, strlen(arg_new) + 1);
+		}
+	}
+
 	return lvm2_main(argc, argv);
 }
 


