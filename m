From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Fri, 13 Oct 2006 17:14:46 -0400
Subject: [PATCH LVM2] (12/12) sort the allocation requests
In-Reply-To: <452FFCFB.6090805@ce.jp.nec.com>
References: <452FFCFB.6090805@ce.jp.nec.com>
Message-ID: <453001C6.4040600@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patch adds sorting of allocation requests.

o This patch sorts the allocation request based on its type.
  Allocation for log device is done before allocation of others.


$ diffstat -p1 12.sort_requests.patch
 lib/metadata/lv_manip.c |   21 +++++++++++++++++++++
 1 file changed, 21 insertions(+)


Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America


-------------- next part --------------
A non-text attachment was scrubbed...
Name: 12.sort_requests.patch
Type: text/x-patch
Size: 1235 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20061013/ad75d725/attachment.bin>
