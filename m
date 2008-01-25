From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Fri, 25 Jan 2008 15:58:25 -0500
Subject: [PATCH 2/3] Factor out seg->log_lv manipulation
Message-ID: <479A4D71.30606@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add attach_mirror_log()/detach_mirror_log()

With the recent changes to the internal stacking management,
it's mandatory to update lv->segs_using_this_lv after
seg->log_lv manipulation.

To avoid future problem, the attached patch changes
internal _add/remove_mirror_log() to attach/detach_mirror_log()
so that functions like lvconvert can use it.

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
A non-text attachment was scrubbed...
Name: refactor-log-attach-detach.patch
Type: text/x-patch
Size: 7811 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20080125/e82f5b54/attachment.bin>
