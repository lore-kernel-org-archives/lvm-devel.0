From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Fri, 04 Jan 2008 10:12:52 -0500
Subject: [PATCH lvconvert 8/11] Add internal 'CONVERTING' flag for LVs under conversion
In-Reply-To: <477E48D8.4050404@ce.jp.nec.com>
References: <477E48D8.4050404@ce.jp.nec.com>
Message-ID: <477E4CF4.3080506@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add 'CONVERTING' flag for LVs under conversion.
Reporting code and daemon restarting code will use it.

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvconvert-add-flag.patch
Type: text/x-patch
Size: 2571 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20080104/6377cdc4/attachment.bin>
