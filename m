From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 17 Nov 2015 18:01:33 +0000 (UTC)
Subject: master - libdm: update error message
Message-ID: <20151117180133.C9BF160F16@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=51dfba002b05cc65346b539b4b030f0c2dfffeaf
Commit:        51dfba002b05cc65346b539b4b030f0c2dfffeaf
Parent:        931fede81b5fdc3aecd730567fefc3e31c5275ce
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Nov 16 14:39:09 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Nov 17 19:01:25 2015 +0100

libdm: update error message

Correcting error message.
---
 libdm/libdm-string.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/libdm/libdm-string.c b/libdm/libdm-string.c
index 79a969c..ef93a6b 100644
--- a/libdm/libdm-string.c
+++ b/libdm/libdm-string.c
@@ -96,7 +96,7 @@ int dm_split_lvm_name(struct dm_pool *mem, const char *dmname,
 		      char **vgname, char **lvname, char **layer)
 {
 	if (!vgname || !lvname || !layer) {
-		log_error(INTERNAL_ERROR "dm_split_lvm_name: vgname, lvname nor layer could be NULL.");
+		log_error(INTERNAL_ERROR "dm_split_lvm_name: Forbidden NULL parameter detected.");
 		return 0;
 	}
 


