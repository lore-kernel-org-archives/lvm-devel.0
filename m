From: Alasdair Kergon <agk@fedoraproject.org>
Date: Wed, 25 Feb 2015 16:35:53 +0000 (UTC)
Subject: master - toolcontext: Fix lvmlocal.conf load fail path.
Message-ID: <20150225163553.DFCE0609CB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4ff9abd01f60e3bfe433da5596078a12fb49f9eb
Commit:        4ff9abd01f60e3bfe433da5596078a12fb49f9eb
Parent:        1e59c0346a3d9f5d125708529bd6d2ff4d0a16d5
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Wed Feb 25 16:36:47 2015 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Wed Feb 25 16:36:47 2015 +0000

toolcontext: Fix lvmlocal.conf load fail path.

---
 lib/commands/toolcontext.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index c917b0a..1936ea7 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -1741,7 +1741,7 @@ struct cmd_context *create_toolcontext(unsigned is_long_lived,
 
 	/* Load lvmlocal.conf */
 	if (*cmd->system_dir && !_load_config_file(cmd, "", 1))
-		return_0;
+		goto_out;
 
 	if (!_init_tag_configs(cmd))
 		goto_out;


