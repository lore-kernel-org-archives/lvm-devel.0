From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun, 18 Dec 2016 18:52:23 +0000 (UTC)
Subject: master - thin: add comment with future extension
Message-ID: <20161218185223.5DC2660E36@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=79121416dfd695900a02711e6f63146e532b825b
Commit:        79121416dfd695900a02711e6f63146e532b825b
Parent:        75f23880934a8c1cb192e9a898261320db15043a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Dec 18 15:06:12 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Dec 18 19:38:51 2016 +0100

thin: add comment with future extension

It could be actually better to use even cache origin in
read-only mode so there could no be some 'acidental'
change being done on this volume.

This however need further tools enhancment - where we would need
to handle whole subtree on 'lvchange -pr/-prw'.
---
 lib/metadata/thin_manip.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/thin_manip.c b/lib/metadata/thin_manip.c
index e7a2c33..42ec552 100644
--- a/lib/metadata/thin_manip.c
+++ b/lib/metadata/thin_manip.c
@@ -99,6 +99,10 @@ int attach_thin_external_origin(struct lv_segment *seg,
 				    external_lv->name);
 			external_lv->status &= ~LVM_WRITE;
 		}
+
+		// TODO: should we mark even origin read-only ?
+		//if (lv_is_cache(external_lv)) /* read-only corigin of cache LV */
+		//	seg_lv(first_seg(external_lv), 0)->status &= ~LVM_WRITE;
 	}
 
 	return 1;


