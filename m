From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu,  6 Feb 2014 16:46:15 +0000 (UTC)
Subject: master - dmeventd: use _exit(0) instead of raise(9) on dmeventd DIE message
Message-ID: <20140206164615.CCBFC600D3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=90286fa0e96dde8f79c1d06eff4a878cb3024283
Commit:        90286fa0e96dde8f79c1d06eff4a878cb3024283
Parent:        fbeb08f320414cf0b5ae22096504bc4293fe939a
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Feb 6 11:44:57 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Feb 6 17:41:13 2014 +0100

dmeventd: use _exit(0) instead of raise(9) on dmeventd DIE message

Just a cleaner way to die.
---
 daemons/dmeventd/dmeventd.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index b456ce6..04ed71e 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -1535,7 +1535,8 @@ static void _process_request(struct dm_event_fifos *fifos)
 
 	dm_free(msg.data);
 
-	if (die) raise(9);
+	if (die)
+		_exit(0);
 }
 
 static void _process_initial_registrations(void)


