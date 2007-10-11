From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Thu, 11 Oct 2007 18:54:50 -0400
Subject: [RFC LVM2] (1/6) Add 'const' to PV accessor functions
In-Reply-To: <470EA422.6000003@ce.jp.nec.com>
References: <470EA422.6000003@ce.jp.nec.com>
Message-ID: <470EA9BA.7080003@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Accessor functions for PV will not modify the given PV.
So we can add 'const' to it.

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America

-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvm2-add-const-to-pv-accessors.patch
Type: text/x-patch
Size: 3289 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20071011/d30fc1d0/attachment.bin>
