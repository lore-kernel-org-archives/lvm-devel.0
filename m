From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue,  4 Jun 2013 19:27:40 +0000 (UTC)
Subject: dev-mornfall-activate - lvresize: drop monitoring of 100% covered origin
Message-ID: <20130604192740.2125A61095@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b08c3464898f1c1e45fcac95258a495286e4dd47
Commit:        b08c3464898f1c1e45fcac95258a495286e4dd47
Parent:        3ced1bf694359a67162cccc7f0e3d94e50929f6e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed May 29 21:23:18 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu May 30 17:35:23 2013 +0200

lvresize: drop monitoring of 100% covered origin

---
 tools/lvresize.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/tools/lvresize.c b/tools/lvresize.c
index a32930e..ae42ce8 100644
--- a/tools/lvresize.c
+++ b/tools/lvresize.c
@@ -868,6 +868,10 @@ static int _lvresize(struct cmd_context *cmd, struct volume_group *vg,
 		return ECMD_FAILED;
 	}
 
+	if (lv_is_cow_covering_origin(lv))
+		if (!monitor_dev_for_events(cmd, lv, 0, 0))
+			stack;
+
 	backup(vg);
 
 	/*


