From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun, 18 May 2014 18:10:54 +0000 (UTC)
Subject: master - debug: backtrace error path
Message-ID: <20140518181054.853D36026C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=58777756e8453188d9d0aeb906bb74666e5bbecc
Commit:        58777756e8453188d9d0aeb906bb74666e5bbecc
Parent:        b73a78675576c562b8bf510d16dab8a35bf4cb02
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun May 18 20:07:24 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun May 18 20:07:24 2014 +0200

debug: backtrace error path

Add backtrace for 'n' answer.
---
 lib/metadata/lv_manip.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index fa08c39..6a24873 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -3166,9 +3166,10 @@ int lv_extend(struct logical_volume *lv,
 				/* FIXME Support --force */
 				if (yes_no_prompt("Do full resync of extended "
 						  "portion of %s/%s?  [y/n]: ",
-						  lv->vg->name, lv->name) == 'y')
-					goto out;
-				r = 0;
+						  lv->vg->name, lv->name) == 'n') {
+					r = 0;
+					goto_out;
+				}
 				goto out;
 			}
 


