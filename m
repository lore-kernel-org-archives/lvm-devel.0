From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri,  5 Oct 2012 08:38:15 +0000 (UTC)
Subject: master - test: check data_percent is equal to snap_percent
Message-ID: <20121005083815.711C2A0C55@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=39f3c9de0babbe54cecb4cee5b163bf72eab61f4
Commit:        39f3c9de0babbe54cecb4cee5b163bf72eab61f4
Parent:        1da6c1495aea539ccd869b157162aaff9f96b385
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 5 10:32:49 2012 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 5 10:37:41 2012 +0200

test: check data_percent is equal to snap_percent

---
 test/api/percent.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/test/api/percent.c b/test/api/percent.c
index db686d7..c5fa434 100644
--- a/test/api/percent.c
+++ b/test/api/percent.c
@@ -23,6 +23,7 @@ int main(int argc, char *argv[])
 	vg_t vg = NULL;
 	lv_t lv;
 	struct lvm_property_value v;
+	struct lvm_property_value d;
 
 	handle = lvm_init(NULL);
         assert(handle);
@@ -51,6 +52,10 @@ int main(int argc, char *argv[])
         assert(v.is_valid);
         assert(v.value.integer == 50 * PERCENT_1);
 
+	d = lvm_lv_get_property(lv, "data_percent");
+	assert(d.is_valid);
+	assert(d.value.integer == v.value.integer);
+
         lvm_vg_close(vg);
 
 	lvm_quit(handle);


