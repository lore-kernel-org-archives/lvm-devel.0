From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri, 18 Sep 2015 13:20:00 +0000 (UTC)
Subject: master - uuid: Report invalid character.
Message-ID: <20150918132001.03ABA60155@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=90ad817a43a8c2ef6ca9d6797d5b9e50c6a87cfd
Commit:        90ad817a43a8c2ef6ca9d6797d5b9e50c6a87cfd
Parent:        5bc8c713e2d25d5b4b3d2ba827905aecf378f721
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Fri Sep 18 14:19:32 2015 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Sep 18 14:19:32 2015 +0100

uuid: Report invalid character.

---
 lib/uuid/uuid.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/uuid/uuid.c b/lib/uuid/uuid.c
index c85b822..67162dd 100644
--- a/lib/uuid/uuid.c
+++ b/lib/uuid/uuid.c
@@ -140,7 +140,7 @@ int id_valid(struct id *id)
 
 	for (i = 0; i < ID_LEN; i++)
 		if (!_inverse_c[id->uuid[i]]) {
-			log_error("UUID contains invalid character");
+			log_error("UUID contains invalid character '%c'", id->uuid[i]);
 			return 0;
 		}
 


