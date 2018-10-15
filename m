From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 15 Oct 2018 11:55:29 -0400
Subject: master - cov: fix error path
Message-ID: <201810151555.w9FFtTS8020618@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=253989ecd953b1afcaea43fa0515c55bc6533cd2
Commit:        253989ecd953b1afcaea43fa0515c55bc6533cd2
Parent:        13c49033ede4bb57878361e5ae04c96d4930e9fa
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 15 15:20:45 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 15 17:49:44 2018 +0200

cov: fix error path

Avoid calling 'bad:' section since we have not set 'fd' yet
and instead directly return failing 0 value.
---
 lib/metadata/vdo_manip.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/vdo_manip.c b/lib/metadata/vdo_manip.c
index 0b3ed19..c0446ad 100644
--- a/lib/metadata/vdo_manip.c
+++ b/lib/metadata/vdo_manip.c
@@ -102,7 +102,7 @@ static int _sysfs_get_kvdo_value(const char *dm_name, const char *vdo_param, uin
 	if (dm_snprintf(path, sizeof(path), "%skvdo/%s/%s",
 			dm_sysfs_dir(), dm_name, vdo_param) < 0) {
 		log_error("Failed to build kmod path.");
-		goto bad;
+		return 0;
 	}
 
 	if ((fd = open(path, O_RDONLY)) < 0) {


