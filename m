From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 23 Apr 2021 21:05:43 +0000 (GMT)
Subject: main - cov: avoid leak when repeating options
Message-ID: <20210423210543.A2151393BC13@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3d96203e21be7fcea783afaa94e10295696a4533
Commit:        3d96203e21be7fcea783afaa94e10295696a4533
Parent:        7e77e250a9249f6b7c9bc63b88de393c02ef6a61
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Apr 22 17:53:45 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 23 22:59:25 2021 +0200

cov: avoid leak when repeating options

Do not leak previous buffer, when option is set more then once.
---
 daemons/lvmlockd/lvmlockctl.c | 4 ++++
 tools/pvck.c                  | 1 +
 2 files changed, 5 insertions(+)

diff --git a/daemons/lvmlockd/lvmlockctl.c b/daemons/lvmlockd/lvmlockctl.c
index 350e78e9a..32da99c6d 100644
--- a/daemons/lvmlockd/lvmlockctl.c
+++ b/daemons/lvmlockd/lvmlockctl.c
@@ -987,18 +987,22 @@ static int read_options(int argc, char *argv[])
 			break;
 		case 'k':
 			kill_vg = 1;
+			free(arg_vg_name);
 			arg_vg_name = strdup(optarg);
 			break;
 		case 'r':
 			drop_vg = 1;
+			free(arg_vg_name);
 			arg_vg_name = strdup(optarg);
 			break;
 		case 'E':
 			gl_enable = 1;
+			free(arg_vg_name);
 			arg_vg_name = strdup(optarg);
 			break;
 		case 'D':
 			gl_disable = 1;
+			free(arg_vg_name);
 			arg_vg_name = strdup(optarg);
 			break;
 		case 'S':
diff --git a/tools/pvck.c b/tools/pvck.c
index 2af34dc57..6bc1c091f 100644
--- a/tools/pvck.c
+++ b/tools/pvck.c
@@ -1774,6 +1774,7 @@ static int _get_one_setting(struct cmd_context *cmd, struct settings *set, char
 	}
 
 	if (!strncmp(key, "backup_file", strlen("backup_file"))) {
+		free(set->backup_file);
 		if ((set->backup_file = strdup(val)))
 			return 1;
 		return 0;


