From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Fri, 18 Jan 2008 16:44:10 -0500
Subject: [PATCH] Fix a regression in '--nosync' option for mirrored LV
Message-ID: <47911DAA.1010506@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

'--nosync' option of lvcreate is for skipping initial sync
of mirrors.
The option was implemented by passing the option to
create_mirror_log() function to control the initialization.
However, the new lv_add_mirrors() API didn't have a corresponding
option. So the option doesn't work properly.

This patch fixes it by adding a new flag for lv_add_mirrors(),
MIRROR_SKIP_INIT_SYNC, to skip initial sync.

Expected behavior is:
  * Default
      "Copy %" starts from 0 on create.
      "Copy %" resumes from the last status on reactivation.
  * '--corelog' only
      "Copy %" starts from 0 on create.
      "Copy %" starts from 0 on reactivation.
  * '--nosync' only
      "Copy %" starts from 100 on create.
      "Copy %" resumes from the last status on reactivation.
  * '--corelog' + '--nosync'
      "Copy %" starts from 100 on create.
      "Copy %" starts from 0 on reactivation.

Also attached is a test script for these combinations.
(Not in a 'make check' format as the script won't work on
 loopback devices which completes synchronization too fast.)

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
A non-text attachment was scrubbed...
Name: fix-lvcreate-nosync.patch
Type: text/x-patch
Size: 2638 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20080118/2fd07ed9/attachment.bin>
-------------- next part --------------
A non-text attachment was scrubbed...
Name: nosync-test.sh
Type: application/x-sh
Size: 1243 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20080118/2fd07ed9/attachment.sh>
