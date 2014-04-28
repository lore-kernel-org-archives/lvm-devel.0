From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 28 Apr 2014 10:12:53 +0000 (UTC)
Subject: master - cleanup: _move_pv is static
Message-ID: <20140428101253.86F6E61391@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5b28cbd7c2cd8413c189fff1286a579174ca082a
Commit:        5b28cbd7c2cd8413c189fff1286a579174ca082a
Parent:        4360fdf89c7f38c5de0d3e6d612f67ee915cba15
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Apr 28 12:11:44 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Apr 28 12:11:44 2014 +0200

cleanup: _move_pv is static

metadata/metadata.c:363:5: warning: no previous prototype for '_move_pv' [-Wmissing-prototypes]
---
 lib/metadata/metadata.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index edc55ef..e2abba7 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -360,8 +360,8 @@ out:
 	return r;
 }
 
-int _move_pv(struct volume_group *vg_from, struct volume_group *vg_to,
-	     const char *pv_name, int enforce_pv_from_source)
+static int _move_pv(struct volume_group *vg_from, struct volume_group *vg_to,
+		    const char *pv_name, int enforce_pv_from_source)
 {
 	struct physical_volume *pv;
 	struct pv_list *pvl;


