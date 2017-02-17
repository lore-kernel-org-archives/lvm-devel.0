From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 17 Feb 2017 12:59:47 +0000 (UTC)
Subject: master - commands: compensate --uuid
Message-ID: <20170217125947.F1B7660C2E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=56deed9d54c9070cc586f040264a8e1985b19bdc
Commit:        56deed9d54c9070cc586f040264a8e1985b19bdc
Parent:        00f299b93265ea2a9a930f26c68d887b8708da5a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Feb 17 13:57:59 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Feb 17 13:57:59 2017 +0100

commands: compensate --uuid

As we now user binary search - it's nondeterministict
which of the same 'args' will be give - so duplicates
need 'extra' care.

So provide same hack for output for --uuidstr_ARG as
for input.

Solves 'pvscan -u'.
---
 tools/command.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/tools/command.c b/tools/command.c
index 1abac20..6cd4d68 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -866,6 +866,11 @@ static void add_opt_arg(struct command *cmd, char *str, int *takes_arg, int requ
 	}
 
 	opt = opt_str_to_num(cmd, str);
+
+	/* If the binary-search finds uuidstr_ARG switch to uuid_ARG */
+	if (opt == uuidstr_ARG)
+		opt = uuid_ARG;
+
 skip:
 	if (required > 0)
 		cmd->required_opt_args[cmd->ro_count++].opt = opt;


