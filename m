From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 21 May 2014 22:56:03 +0000 (UTC)
Subject: master - cleanup: indent
Message-ID: <20140521225603.AD459609E4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=aafd7c878c2a4bdcb72182bd31e52bae280898d1
Commit:        aafd7c878c2a4bdcb72182bd31e52bae280898d1
Parent:        3ac7d2deb4270504dbae369b0b1bf14cb25a1b38
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed May 21 23:10:02 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed May 21 23:14:41 2014 +0200

cleanup: indent

---
 lib/metadata/metadata.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 4791c10..fd81c1b 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -769,7 +769,7 @@ int vg_reduce(struct volume_group *vg, const char *pv_name)
 	}
 
 	log_error("Unable to remove physical volume '%s' from "
-				"volume group '%s'.", pv_name, vg->name);
+		  "volume group '%s'.", pv_name, vg->name);
 
 	return 0;
 }


