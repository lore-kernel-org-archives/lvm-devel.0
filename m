From: Tony Asleson <tasleson@sourceware.org>
Date: Fri, 10 Mar 2023 18:52:37 +0000 (GMT)
Subject: main - lvmdbustest: Add notes on error injection testing
Message-ID: <20230310185237.CA48E385840E@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=baf99ff974b408c59dd4f51db6e006d659c061e7
Commit:        baf99ff974b408c59dd4f51db6e006d659c061e7
Parent:        1c550d7124d4bc1954f7d1d7efc372e1d996b570
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Fri Mar 10 10:44:55 2023 -0600
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Fri Mar 10 12:51:53 2023 -0600

lvmdbustest: Add notes on error injection testing

Not doing this by default for automated build testing as it generates a
lot of output and slows things down by another ~10%.
---
 test/dbus/lvmdbustest.py | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/test/dbus/lvmdbustest.py b/test/dbus/lvmdbustest.py
index e1c994e90..00d9303b6 100755
--- a/test/dbus/lvmdbustest.py
+++ b/test/dbus/lvmdbustest.py
@@ -2577,6 +2577,12 @@ if __name__ == '__main__':
 	r = AggregateResults()
 	mode = int(test_shell)
 
+	# To test with error injection, simply set the env. variable LVM_BINARY to the error inject script
+	# and the LVM_MAN_IN_MIDDLE variable to the lvm binary to test which defaults to "/usr/sbin/lvm"
+	# An example
+	# export LVM_BINARY=/home/tasleson/projects/lvm2/test/dbus/lvm_error_inject.py
+	# export LVM_MAN_IN_MIDDLE=/home/tasleson/projects/lvm2/tools/lvm
+
 	if mode == 0:
 		std_err_print('\n*** Testing only lvm fork & exec test mode ***\n')
 	elif mode == 1:

