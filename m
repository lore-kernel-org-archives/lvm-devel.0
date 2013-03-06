From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Wed,  6 Mar 2013 14:43:19 +0000 (UTC)
Subject: master - clean-up: Typo 's/should had/should have/'
Message-ID: <20130306144319.F095FA0C29@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ed6f3945fd86385c172da5d6884c01d8c0b6a51b
Commit:        ed6f3945fd86385c172da5d6884c01d8c0b6a51b
Parent:        6b777ccbb5dca4a6d80b8b0bf071993c049f6a9f
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Wed Mar 6 08:42:03 2013 -0600
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Wed Mar 6 08:42:03 2013 -0600

clean-up:  Typo 's/should had/should have/'

---
 lib/activate/fs.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/activate/fs.c b/lib/activate/fs.c
index fe53349..7483044 100644
--- a/lib/activate/fs.c
+++ b/lib/activate/fs.c
@@ -205,7 +205,7 @@ static int _mk_link(const char *dev_dir, const char *vg_name,
 			return 0;
 		}
 	} else if (dm_udev_get_sync_support() && udev_checking() && check_udev)
-		log_warn("The link %s should had been created by udev "
+		log_warn("The link %s should have been created by udev "
 			  "but it was not found. Falling back to "
 			  "direct link creation.", lv_path);
 


