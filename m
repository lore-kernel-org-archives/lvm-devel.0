From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 25 Mar 2014 10:23:47 +0000 (UTC)
Subject: master - cleanup: drop init of already zalloced mem
Message-ID: <20140325102347.67BCD60F9D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=89575d68957dacdcad7d106e3ffd71ff96d3144f
Commit:        89575d68957dacdcad7d106e3ffd71ff96d3144f
Parent:        406ec4162f86d872e041d7aa524d1f7dfd0d1cc0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Mar 24 09:22:59 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Mar 25 11:22:59 2014 +0100

cleanup: drop init of already zalloced mem

---
 lib/format_text/format-text.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index a652590..c987cd6 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -1865,7 +1865,6 @@ static int _create_vg_text_instance(struct format_instance *fid,
 		return 0;
 	}
 
-	fidtc->raw_metadata_buf = NULL;
 	fid->private = (void *) fidtc;
 
 	if (type & FMT_INSTANCE_PRIVATE_MDAS) {


