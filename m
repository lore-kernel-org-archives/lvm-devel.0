From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri,  6 May 2016 15:21:29 +0000 (UTC)
Subject: master - segtype: check for activation2
Message-ID: <20160506152129.31D6560F4B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=db606591c0b8aa173661377be066be7bd78c5351
Commit:        db606591c0b8aa173661377be066be7bd78c5351
Parent:        144169b9b704a8c9693ee52bcc812c4f07d2ef8f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri May 6 13:57:36 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri May 6 16:48:16 2016 +0200

segtype: check for activation2

Previous patch 8857b227645e97b7cb52ae8d007e87e07db58b4e missed
to check for activation for raid target.
---
 lib/raid/raid.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/lib/raid/raid.c b/lib/raid/raid.c
index 67c355a..28fd45b 100644
--- a/lib/raid/raid.c
+++ b/lib/raid/raid.c
@@ -319,6 +319,9 @@ static int _raid_target_present(struct cmd_context *cmd,
 	uint32_t maj, min, patchlevel;
 	unsigned i;
 
+	if (!activation())
+		return 0;
+
 	if (!_raid_checked) {
 		_raid_checked = 1;
 


