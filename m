From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 12 Jul 2013 11:17:57 +0000 (UTC)
Subject: master - lvchange: backup VG after changing profile
Message-ID: <20130712111757.E544660DCE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4d19fa9582a44a71a53647d6a7c6026955e805c7
Commit:        4d19fa9582a44a71a53647d6a7c6026955e805c7
Parent:        8e4a3dd9cb73e71df5f782f844da4cf461d76de6
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Jul 11 12:25:10 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Jul 11 12:25:10 2013 +0200

lvchange: backup VG after changing profile

---
 tools/lvchange.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/tools/lvchange.c b/tools/lvchange.c
index f7ce7fd..f4b5d07 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -882,6 +882,8 @@ static int lvchange_profile(struct logical_volume *lv)
 	if (!vg_write(lv->vg) || !vg_commit(lv->vg))
 		return_0;
 
+	backup(lv->vg);
+
 	return 1;
 }
 


