From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Fri, 11 Jan 2008 18:21:23 -0500
Subject: [PATCH] Fix 'make check' to work with the latest device-mapper
Message-ID: <4787F9F3.7000703@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Fix 'make check' runnable with recent versions of dmsetup.

'make check' uses DM_DEV_DIR environment variable to set
a sandbox for testing.
To confirm if dmsetup command supports the variable,
it checks the error message of dmsetup when invalid value is set to
the variable.

As the message of dmsetup has recently changed, 'make check'
should test for the newe version, too.
Otherwise, it skips all tests that includes activation.

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
A non-text attachment was scrubbed...
Name: fix-test-DM_DEVDIR-support-check.patch
Type: text/x-patch
Size: 1048 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20080111/be72ad6c/attachment.bin>
