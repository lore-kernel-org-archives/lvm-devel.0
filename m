From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Fri, 13 Oct 2006 17:14:32 -0400
Subject: [PATCH LVM2] (10/12) calculate free pe counts before allocation attempt
In-Reply-To: <452FFCFB.6090805@ce.jp.nec.com>
References: <452FFCFB.6090805@ce.jp.nec.com>
Message-ID: <453001B8.8040906@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patch adds calculation of free pe counts and checks it
before doing any allocation attempt.


$ diffstat -p1 10.calcfree.patch
 lib/metadata/lv_manip.c |   30 ++++++++++++++++++++++++++----
 1 file changed, 26 insertions(+), 4 deletions(-)


Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America


-------------- next part --------------
A non-text attachment was scrubbed...
Name: 10.calcfree.patch
Type: text/x-patch
Size: 1890 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20061013/be275032/attachment.bin>
