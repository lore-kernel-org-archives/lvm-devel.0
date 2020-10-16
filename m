From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 16 Oct 2020 19:11:03 +0000 (GMT)
Subject: stable-2.02 - cleanup: user force_t enums instead of ints
Message-ID: <20201016191103.0EC0D38618E8@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=736691ee6c1e971ad64c8e83a8f458094098ba24
Commit:        736691ee6c1e971ad64c8e83a8f458094098ba24
Parent:        8e778995dee7f812505f6dbf920e350b705e57c1
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Aug 29 21:53:05 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 16 16:02:06 2020 +0200

cleanup: user force_t enums instead of ints

---
 tools/vgextend.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/tools/vgextend.c b/tools/vgextend.c
index 5287a364e..b803be086 100644
--- a/tools/vgextend.c
+++ b/tools/vgextend.c
@@ -152,7 +152,7 @@ int vgextend(struct cmd_context *cmd, int argc, char **argv)
 	pp->preserve_existing = 1;
 
 	/* pvcreate within vgextend cannot be forced. */
-	pp->force = 0;
+	pp->force = PROMPT;
 
 	/* Check for old md signatures at the end of devices. */
 	cmd->use_full_md_check = 1;


