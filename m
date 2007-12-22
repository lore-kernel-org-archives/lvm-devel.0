From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Sat, 22 Dec 2007 02:00:30 -0500
Subject: [PATCH 2/3] Polldaemon configurable progress title
Message-ID: <476CB60E.2080509@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

polldaemon, which is used by pvmove, prints "Moved: x%" periodically
to show the progress of its work.
However, it can be used for other purpose like waiting for
sync completion of newly added mirror.
This patch change the strings "Moved" configurable by
a parameter passed to poll_daemon().

This is prepration for the next patch which changes lvconvert to
use polldaemon.

Thanks,
--
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
An embedded and charset-unspecified text was scrubbed...
Name: polldaemon-progress_title.patch
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20071222/2fd2d25c/attachment.ksh>
