From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sat, 21 Jan 2017 16:46:20 +0000 (UTC)
Subject: master - dmeventd_thin: internal command without lvm prefix
Message-ID: <20170121164620.872D360797@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2e0605d6db9723d4bea472b21352d398f29e226e
Commit:        2e0605d6db9723d4bea472b21352d398f29e226e
Parent:        85dab3963fbf8b3cc1be84f2d7c43257075ac2a3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Jan 21 17:37:01 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Jan 21 17:42:19 2017 +0100

dmeventd_thin: internal command without lvm prefix

Internal command processing needs to go without 'lvm ' prefix.
---
 daemons/dmeventd/plugins/thin/dmeventd_thin.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/daemons/dmeventd/plugins/thin/dmeventd_thin.c b/daemons/dmeventd/plugins/thin/dmeventd_thin.c
index a676de3..a6a534d 100644
--- a/daemons/dmeventd/plugins/thin/dmeventd_thin.c
+++ b/daemons/dmeventd/plugins/thin/dmeventd_thin.c
@@ -375,7 +375,8 @@ int register_device(const char *device,
 
 		dm_split_words(str, maxcmd - 1, 0, state->argv);
 		_init_thread_signals(state);
-	}
+	} else
+		memmove(state->cmd_str, state->cmd_str + 4, strlen(state->cmd_str + 4) + 1);
 
 	state->pid = -1;
 	*user = state;


