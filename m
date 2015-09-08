From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue,  8 Sep 2015 10:14:31 +0000 (UTC)
Subject: master - tests: skip raid testing on 4.[1, 2] fc24 kernels
Message-ID: <20150908101431.853566073F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=596ec5c74b604de42f105032b7e13065ea67d281
Commit:        596ec5c74b604de42f105032b7e13065ea67d281
Parent:        0ec64370b24acf837c725b614db993a663cc8103
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Sep 8 12:00:12 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Sep 8 12:12:38 2015 +0200

tests: skip raid testing on 4.[1,2] fc24 kernels

Hopefull 4.3 will be fixed and test will be updated to let
raid test running again.

Meanwhile using md-raid may effectively kill kernel,
so leave at least other tests running.
---
 test/lib/aux.sh |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index f870501..25700f6 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -1108,6 +1108,14 @@ have_raid() {
 		return 1;
 	}
 	target_at_least dm-raid "$@"
+
+	# some kernels have broken mdraid bitmaps, don't use them!
+	# may oops kernel, we know for sure all FC24 are currently broken
+	# in general any 4.1, 4.2 is likely useless unless patched
+	# hopefully 4.3 will be patched
+	case "$(uname -r)" in
+	  4.[123].*fc24*) return 1 ;;
+	esac
 }
 
 have_cache() {


