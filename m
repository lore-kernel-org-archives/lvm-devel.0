From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun,  2 Jun 2013 21:17:58 +0000 (UTC)
Subject: master - filters: compile fix
Message-ID: <20130602211758.C409961383@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4a657a13b1c6e4570c15c14fd8acb910b106f5cf
Commit:        4a657a13b1c6e4570c15c14fd8acb910b106f5cf
Parent:        5467a3b2b70a2550eb84423a20873ad7d520907b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Jun 2 23:16:41 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Jun 2 23:16:41 2013 +0200

filters: compile fix

Add missing cast in previous commit.
---
 lib/filters/filter-composite.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/filters/filter-composite.c b/lib/filters/filter-composite.c
index e183c00..bc37213 100644
--- a/lib/filters/filter-composite.c
+++ b/lib/filters/filter-composite.c
@@ -64,7 +64,7 @@ static void _wipe(struct dev_filter *f)
 {
 	struct dev_filter **filters;
 
-	for (filters = f->private; *filters; filters++)
+	for (filters = (struct dev_filter **) f->private; *filters; filters++)
 		if ((*filters)->wipe)
 			(*filters)->wipe(*filters);
 }


