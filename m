From: okozina <okozina@fedoraproject.org>
Date: Mon, 25 May 2015 07:12:00 +0000 (UTC)
Subject: master - lvmetad.c: ignore lvmetad global handle on disconnect
Message-ID: <20150525071200.3E55D61055@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f8bf6410954fcf82bf28852e0dba015c6b7f19dc
Commit:        f8bf6410954fcf82bf28852e0dba015c6b7f19dc
Parent:        9d558fbcc232314dc93a405b4da3079f5d8e9cb7
Author:        Ondrej Kozina <okozina@redhat.com>
AuthorDate:    Fri May 22 14:48:28 2015 +0200
Committer:     Ondrej Kozina <okozina@redhat.com>
CommitterDate: Mon May 25 09:11:04 2015 +0200

lvmetad.c: ignore lvmetad global handle on disconnect

do not unset lvmetad global handle on disconnect. This is
hotfix for issue described in:
https://www.redhat.com/archives/linux-lvm/2015-May/msg00008.html

Reported-by: Christian Hesse <list@eworm.de>
---
 lib/cache/lvmetad.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index 68162b6..73a382c 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -39,7 +39,6 @@ void lvmetad_disconnect(void)
 	if (_lvmetad_connected)
 		daemon_close(_lvmetad);
 	_lvmetad_connected = 0;
-	_lvmetad_cmd = NULL;
 }
 
 void lvmetad_init(struct cmd_context *cmd)


