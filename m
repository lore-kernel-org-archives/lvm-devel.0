From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 19 Mar 2014 00:02:06 +0000 (UTC)
Subject: master - metadata: print VG with invalid chars in quotes
Message-ID: <20140319000206.5127761095@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=013f5f4550816b0ac0d7f7a92ce763624b351319
Commit:        013f5f4550816b0ac0d7f7a92ce763624b351319
Parent:        6a8d3d781112acdddf8fbb671bf9b68837f11c63
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Mar 19 00:24:36 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Mar 19 00:48:39 2014 +0100

metadata: print VG with invalid chars in quotes

We we report invalid chars, put quotes around vg name.
---
 lib/metadata/metadata.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 278b519..b5e2ed6 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -4166,7 +4166,7 @@ static struct volume_group *_vg_lock_and_read(struct cmd_context *cmd, const cha
 		consistent = 0;
 
 	if (!validate_name(vg_name) && !is_orphan_vg(vg_name)) {
-		log_error("Volume group name %s has invalid characters",
+		log_error("Volume group name \"%s\" has invalid characters.",
 			  vg_name);
 		return NULL;
 	}


