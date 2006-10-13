From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Fri, 13 Oct 2006 17:14:37 -0400
Subject: [PATCH LVM2] (11/12) extending parallel_area to cover log device
In-Reply-To: <452FFCFB.6090805@ce.jp.nec.com>
References: <452FFCFB.6090805@ce.jp.nec.com>
Message-ID: <453001BD.5080503@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patch extends parallel_area to include log device appropriately.

o The log device is considered as covering the whole range of the segment
  including newly allocated extents.
  However, current parallel_areas list is not composed as so.

  For example, if you have a mirrored LV with length 10,
  parallel_areas would say: there are parallel PVs for the extents from
  0 to 9.
  If you are going to extend the mirrored LV, nothing constraints
  extents allocated for le 10 or higher.

  In this case, the existing log device should be taken as parallel to
  all extents including le 10 or higher.

o _for_each_pv() is changed to accept flags which controls what type
  of segments _for_each_pv() walks through.


$ diffstat -p1 11.log_coverage.patch
 lib/metadata/lv_manip.c |   71 +++++++++++++++++++++++++++++++++++++----------- 1 file changed, 56 insertions(+), 15 deletions(-)


Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America


-------------- next part --------------
A non-text attachment was scrubbed...
Name: 11.log_coverage.patch
Type: text/x-patch
Size: 5820 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20061013/d4739cbb/attachment.bin>
