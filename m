From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Fri, 04 Jan 2008 10:13:28 -0500
Subject: [PATCH lvconvert 10/11] Warn if lvconvert needs activation to complete conversion
In-Reply-To: <477E48D8.4050404@ce.jp.nec.com>
References: <477E48D8.4050404@ce.jp.nec.com>
Message-ID: <477E4D18.2080609@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

lvconvert requires activation of the LV, when it adds mirrors to
already mirrored LV. The patch makes it to print a message when
the LV was not activated.
(Alternative may force activation on lvconvert.)

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvconvert-check-active.patch
Type: text/x-patch
Size: 974 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20080104/b3f50ed3/attachment.bin>
