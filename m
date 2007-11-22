From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Wed, 21 Nov 2007 21:09:48 -0500
Subject: [PATCH mirror 11/13] Allow multiple mirror logs in the mirror LV tree
In-Reply-To: <4744DF34.7090701@ce.jp.nec.com>
References: <4744DF34.7090701@ce.jp.nec.com>
Message-ID: <4744E4EC.6010500@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

With the "10/13" patch,  mirror LV can have multiple logs in
its layers.
This patch enables the namings of "lv_mlog_<n>" and
removes a code to force corelog from lvconvert.

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America

-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvm2-stacked-mirror-multi-mlogs.patch
Type: text/x-patch
Size: 1008 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20071121/f6e3d066/attachment.bin>
