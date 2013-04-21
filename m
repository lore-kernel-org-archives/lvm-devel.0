From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun, 21 Apr 2013 21:17:08 +0000 (UTC)
Subject: master - cleanup: cast to len's type
Message-ID: <20130421211708.2B8B016CF@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d38af2857fe86a5e0916d67aee7597e5a0dea6c8
Commit:        d38af2857fe86a5e0916d67aee7597e5a0dea6c8
Parent:        4eb8db26ac9ddd679a32788e8d02ad1e8979e68d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Apr 20 20:55:10 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Apr 21 23:14:05 2013 +0200

cleanup: cast to len's type

Cleanup different signess gcc warning.
---
 daemons/clvmd/clvmd.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/daemons/clvmd/clvmd.c b/daemons/clvmd/clvmd.c
index a64bd54..a276cbc 100644
--- a/daemons/clvmd/clvmd.c
+++ b/daemons/clvmd/clvmd.c
@@ -1217,7 +1217,7 @@ static int read_from_local_sock(struct local_client *thisfd)
 			missing_len = 0;
 
 		/* We need at least sizeof(struct clvm_header) bytes in buffer */
-		if (len < sizeof(struct clvm_header) || argslen < 0 ||
+		if (len < (int)sizeof(struct clvm_header) || argslen < 0 ||
 		    missing_len > MAX_MISSING_LEN) {
 			struct clvm_header reply = {
 				.cmd = CLVMD_CMD_REPLY,


