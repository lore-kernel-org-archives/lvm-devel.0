From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  4 Jul 2016 15:41:59 +0000 (UTC)
Subject: master - tests: try to force remove higher minor first
Message-ID: <20160704154159.EC72360E3A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2981d1e79851bc83751efc1d9ce987cdc65305bc
Commit:        2981d1e79851bc83751efc1d9ce987cdc65305bc
Parent:        c0a505b0bb4eb6584bfea54b526ce38bdfcfa838
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jul 4 15:39:44 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 4 17:40:24 2016 +0200

tests: try to force remove higher minor first

When force removing thin-pool we loose 'real' access to hidden device,
and if such pool is in suspended state, any thin volume cannot be
dropped. It likely should be also checked by dmsetup, but meanwhile
apply simple logic -  try to force remove first all higher minors first
with assumption we first create thin-pool and then thin volume
and there are usually not being released lower dm numbers to
get the order wrong.
---
 test/lib/aux.sh |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 8653149..66574df 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -419,7 +419,8 @@ teardown_devs_prefixed() {
 		while num_devs=$(dm_table | grep "$prefix" | wc -l) && \
 		    test $num_devs -lt $num_remaining_devs -a $num_devs -ne 0; do
 			test "$stray" -eq 0 || echo "Removing $num_devs stray mapped devices with names beginning with $prefix: "
-			for dm in $(dm_info name --sort open | grep "$prefix") ; do
+                        # HACK: sort also by minors - so we try to close 'possibly later' created device first
+			for dm in $(dm_info name --sort open,-minor | grep "$prefix") ; do
 				dmsetup remove -f "$dm" || true
 			done
 			num_remaining_devs=$num_devs


