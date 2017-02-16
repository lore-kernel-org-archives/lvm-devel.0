From: David Teigland <teigland@fedoraproject.org>
Date: Thu, 16 Feb 2017 20:03:41 +0000 (UTC)
Subject: master - commands: initialize commands[] once
Message-ID: <20170216200341.1B13F60D25@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1cb95fa5a050c5056d882ef9cbb01ce8040df019
Commit:        1cb95fa5a050c5056d882ef9cbb01ce8040df019
Parent:        15f51bc42113494bfb49fbc0d6a1913f68fb80a8
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Feb 16 13:59:52 2017 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Feb 16 13:59:52 2017 -0600

commands: initialize commands[] once

When using liblvm2cmd, a process can do multiple
init/exit calls, i.e.

lvm2_init(); lvm2_run(); lvm2_exit();
lvm2_init(); lvm2_run(); lvm2_exit();
...

define_commands() needs to set up the global commands[]
definitions only the first time.
---
 tools/lvmcmdline.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index ed32f1c..e599ded 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -1130,6 +1130,10 @@ void lvm_register_commands(char *name)
 {
 	int i;
 
+	/* already initialized */
+	if (_cmdline.commands)
+		return;
+
 	memset(&commands, 0, sizeof(commands));
 
 	/*


