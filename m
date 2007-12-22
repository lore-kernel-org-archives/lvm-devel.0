From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Fri, 21 Dec 2007 20:22:57 -0500
Subject: [PATCH 1/4] Fix '--nosync' option of lvcreate and remove unnecessary tag collection
Message-ID: <476C66F1.7020803@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patch fixes 2 things.

While converting lvcreate to use the newly added lv_add_mirrors(),
I mistakenly moved the MIRROR_NOTSYNCED flag setting *after*
lv_create_empty().
As a result, '--nosync' option of lvcreate becomes nop.
This patch moves the flag setting and makes nosync option working again.

In the old code, tag list is created and passed for mirror log creation
function because the log was created before the LV.
In the current code, linear LV is created first and the log creation
function takes tag list from the LV. So we don't need to create
tag list in lvcreate.

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
A non-text attachment was scrubbed...
Name: revive-nosync-option.patch
Type: text/x-patch
Size: 1701 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20071221/e5e7b214/attachment.bin>
