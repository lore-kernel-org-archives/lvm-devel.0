From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 23 Apr 2021 21:05:42 +0000 (GMT)
Subject: main - cov: set error_vg only when pointer is non null
Message-ID: <20210423210542.806D0394480D@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7e77e250a9249f6b7c9bc63b88de393c02ef6a61
Commit:        7e77e250a9249f6b7c9bc63b88de393c02ef6a61
Parent:        d1f9845c96284ee72692b7701a2dd1b86006524e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Apr 22 12:41:25 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 23 22:58:45 2021 +0200

cov: set error_vg only when pointer is non null

---
 lib/metadata/metadata.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 4471f7c86..002d80c01 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -4954,7 +4954,8 @@ struct volume_group *vg_read(struct cmd_context *cmd, const char *vg_name, const
 		log_very_verbose("Reading orphan VG %s.", vg_name);
 		vg = vg_read_orphans(cmd, vg_name);
 		*error_flags = 0;
-		*error_vg = NULL;
+		if (error_vg)
+			*error_vg = NULL;
 		return vg;
 	}
 


