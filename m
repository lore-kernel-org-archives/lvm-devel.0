From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Wed, 21 Nov 2007 21:09:38 -0500
Subject: [PATCH mirror 10/13] Generalize "mlog" handling of dtree
In-Reply-To: <4744DF34.7090701@ce.jp.nec.com>
References: <4744DF34.7090701@ce.jp.nec.com>
Message-ID: <4744E4E2.8030700@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Currently, "_mlog" is handled specially in dtree.
It puts a restriction to log LV naming and actually,
current code can't allow multiple mirror logs in a LV.

This is a problem if we allow to add temporary mirror logs
for resynching newly added mirrors.

The patch changes the addition of mirror log to dtree:
  BEFORE: Adds a device with lv->name + "_mlog"
  AFTER:  Adds seg->log_lv

If there is a case where log LV is not set in seg->log_lv
but should be treated as a part of dtree, this change breaks the case.
I would like to know if there's such a case.

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America

-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvm2-deptree-generalize-mlog.patch
Type: text/x-patch
Size: 974 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20071121/e961fddc/attachment.bin>
