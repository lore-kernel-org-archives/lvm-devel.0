From: tasleson <tasleson@fedoraproject.org>
Date: Mon, 10 Oct 2016 21:35:25 +0000 (UTC)
Subject: master - lvmdbustest.py: Add profile and path for lvm binary
Message-ID: <20161010213525.17C1760C40@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=20e74313cd8abaa691fb4f1015a84b34171aa08a
Commit:        20e74313cd8abaa691fb4f1015a84b34171aa08a
Parent:        be06fa695ea9833bcc25c09a17c6396cca07be31
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Mon Oct 10 16:26:38 2016 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Mon Oct 10 16:33:42 2016 -0500

lvmdbustest.py: Add profile and path for lvm binary

---
 test/api/dbustest.sh |   14 ++++++++++++++
 1 files changed, 14 insertions(+), 0 deletions(-)

diff --git a/test/api/dbustest.sh b/test/api/dbustest.sh
index 8741eb9..16dc186 100644
--- a/test/api/dbustest.sh
+++ b/test/api/dbustest.sh
@@ -18,5 +18,19 @@ SKIP_WITH_CLVMD=1
 
 aux prepare_pvs 6
 
+# We need the lvmdbusd.profile for the daemon to utilize JSON
+# output
+mkdir -p $TESTDIR/etc/profile/
+cp -v $TESTOLDPWD/../conf/lvmdbusd.profile $TESTDIR/etc/profile/.
+
+# Need to set this up so that the lvmdbusd service knows which
+# binary to be running, which should be the one we just built
+export LVM_BINARY=$TESTOLDPWD/../tools/lvm
+
 aux prepare_lvmdbusd
+
+# Lets limit testing until the lvm SIGABRT is fixed as
+# we are running into that when using the lvm shell
+export LVM_DBUS_TEST_SHELL=0
+
 $test_data_dir/dbus/lvmdbustest.py -v


