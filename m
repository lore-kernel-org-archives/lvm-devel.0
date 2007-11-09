From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Fri, 09 Nov 2007 11:41:42 -0500
Subject: [PATCH] Remove LV if zeroing was requested but failed
Message-ID: <47348DC6.4020206@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

If zeroing of LV was requested for lvcreate but failed,
it seems nicer if the lvcreate fails and the (incomplete) LV is removed.

Attached patch changes lvcreate to abort in the following cases:
  - if zeroing was requested but activation was disabled
  - if zeroing was requested but activation failed,
  - if zeroing was requested but zeroing failed

A test script is also attached.

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvm2-align-result-on-zerofill-failure.patch
Type: text/x-patch
Size: 1366 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20071109/b45ae157/attachment.bin>
-------------- next part --------------
A non-text attachment was scrubbed...
Name: cleanup-lvcreate.sh
Type: application/x-sh
Size: 1766 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20071109/b45ae157/attachment.sh>
