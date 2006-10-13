From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Fri, 13 Oct 2006 17:00:09 -0400
Subject: [PATCH LVM2] (6/12) move _add_pvs() to the earlier part of the file
In-Reply-To: <452FFCFB.6090805@ce.jp.nec.com>
References: <452FFCFB.6090805@ce.jp.nec.com>
Message-ID: <452FFE59.6090606@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This move the location of _add_pvs() for later patches.
No funtional change.


$ diffstat -p1 06.add_pvs.patch
 lib/metadata/lv_manip.c |   50 +++++++++++++++++++++++++----------------------- 1 file changed, 27 insertions(+), 23 deletions(-)


-- 
Jun'ichi Nomura, NEC Corporation of America


-------------- next part --------------
A non-text attachment was scrubbed...
Name: 06.add_pvs.patch
Type: text/x-patch
Size: 1773 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20061013/deaaa367/attachment.bin>
