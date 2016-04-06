From: Alasdair Kergon <agk@fedoraproject.org>
Date: Wed,  6 Apr 2016 21:57:44 +0000 (UTC)
Subject: master - lvmdump: If dir exists check dir perms too.
Message-ID: <20160406215744.EACF9601E9@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f19ec0e36d64bcde6cb4cbd00376fe2377e81b19
Commit:        f19ec0e36d64bcde6cb4cbd00376fe2377e81b19
Parent:        55001ae9ec2c00a070f8dfa8541f4f17a6e2a284
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Wed Apr 6 22:56:45 2016 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Wed Apr 6 22:56:45 2016 +0100

lvmdump: If dir exists check dir perms too.

---
 scripts/lvmdump.sh |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/scripts/lvmdump.sh b/scripts/lvmdump.sh
index 19b36d3..a813537 100755
--- a/scripts/lvmdump.sh
+++ b/scripts/lvmdump.sh
@@ -100,7 +100,8 @@ else
 fi
 
 if test -d $dir ; then
-	(shopt -s nullglob dotglob; cd $dir && files=(*) && ((${#files[@]}))) && die 5 "Fatal: directory $dir already exists and is not empty"
+	(shopt -s nullglob dotglob; test -r $dir -a -w $dir -a -x $dir && cd $dir && files=(*) && ((! ${#files[@]}))) || \
+		die 5 "Fatal: directory $dir already exists and is not empty or inaccessible"
 else
 	test -e $dir && die 3 "Fatal: $dir already exists"
 	$MKDIR -p $dir || die 4 "Fatal: could not create $dir"


