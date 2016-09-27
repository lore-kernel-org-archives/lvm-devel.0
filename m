From: tasleson <tasleson@fedoraproject.org>
Date: Tue, 27 Sep 2016 18:33:46 +0000 (UTC)
Subject: master - lvmdbustest.py: Make env variable work
Message-ID: <20160927183346.45E8E60D9A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ec076b1df239dff91377a6e19ea76a4047b04b32
Commit:        ec076b1df239dff91377a6e19ea76a4047b04b32
Parent:        1bc546269a7d2cae156827e282715410a4967d51
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Mon Sep 26 21:52:08 2016 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Tue Sep 27 13:28:45 2016 -0500

lvmdbustest.py: Make env variable work

---
 test/dbus/lvmdbustest.py |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/test/dbus/lvmdbustest.py b/test/dbus/lvmdbustest.py
index 31902c4..7a2c44f 100755
--- a/test/dbus/lvmdbustest.py
+++ b/test/dbus/lvmdbustest.py
@@ -1294,7 +1294,8 @@ if __name__ == '__main__':
 	# Default to no lvm shell
 	set_execution(False)
 
-	if test_shell == 0:
+	if int(test_shell) == 0:
+		print('\n Shortened fork & exec test ***\n')
 		unittest.main(exit=True)
 	else:
 		print('\n *** Testing fork & exec *** \n')


