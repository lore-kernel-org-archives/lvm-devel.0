From: Petr Rockai <mornfall@fedoraproject.org>
Date: Mon,  9 Jun 2014 00:35:32 +0000 (UTC)
Subject: master - lvmetad: Drop active connection upon lvmetad_set_active(0).
Message-ID: <20140609003532.D738A60DC3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1824a781db2dcdb328ba61893a1ace192cb78775
Commit:        1824a781db2dcdb328ba61893a1ace192cb78775
Parent:        488f3085279e24af21e870d5a74d0953094552f7
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Mon Jun 9 01:55:33 2014 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Mon Jun 9 01:55:33 2014 +0200

lvmetad: Drop active connection upon lvmetad_set_active(0).

---
 lib/cache/lvmetad.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index c03590e..7896ddd 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -101,6 +101,8 @@ int lvmetad_active(void)
 void lvmetad_set_active(int active)
 {
 	_lvmetad_use = active;
+	if (!active && lvmetad_active())
+		lvmetad_disconnect();
 }
 
 /*


