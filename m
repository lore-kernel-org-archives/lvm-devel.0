From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Fri, 21 Dec 2007 20:23:22 -0500
Subject: [PATCH 4/4] Renaming temporary mirror LVs
Message-ID: <476C670A.5070708@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Temporary LVs for added mirrors are currently named as followings:
  - "<LV name>_resync<n>"
    This is a primary mirror leg for synching.
    "<n>" has no relationship to other numberings in the LV.
  - "<LV name>_mlog<n>"
    This is a mirror log for synching layer.

The patch changes their names to:
  - "<LV name>_mimagetmp_<n>"
    This is a primary mirror leg for synching.
    "<n>" is the number of the first LV of newly added images.
  - "<LV name>_mlogtmp_<n>"
    This is a mirror log for synching layer.

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
A non-text attachment was scrubbed...
Name: mimagetmp-and-mlogtmp.patch
Type: text/x-patch
Size: 4286 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20071221/309e348e/attachment.bin>
