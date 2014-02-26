From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed, 26 Feb 2014 14:13:24 +0000 (UTC)
Subject: master - lvmetad: Make "reason" in a token_mismatch reply more informative.
Message-ID: <20140226141324.8241160D46@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4143b284f8871b57b416eeab795489fcc66ed017
Commit:        4143b284f8871b57b416eeab795489fcc66ed017
Parent:        40e6176d251b68f5be8ca7925a2f073982de6cec
Author:        Petr Rockai <me@mornfall.net>
AuthorDate:    Wed Feb 26 15:10:21 2014 +0100
Committer:     Petr Rockai <me@mornfall.net>
CommitterDate: Wed Feb 26 15:10:21 2014 +0100

lvmetad: Make "reason" in a token_mismatch reply more informative.

---
 daemons/lvmetad/lvmetad-core.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index ab0573f..e6e222f 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -1095,7 +1095,8 @@ static response handler(daemon_state s, client_handle h, request r)
 		return daemon_reply_simple("token_mismatch",
 					   "expected = %s", state->token,
 					   "received = %s", token,
-					   "reason = %s", "token mismatch", NULL);
+					   "reason = %s",
+					   "lvmetad cache is invalid due to a global_filter change or due to a running rescan", NULL);
 	}
 	pthread_mutex_unlock(&state->token_lock);
 


