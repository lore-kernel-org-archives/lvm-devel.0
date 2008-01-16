From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Wed, 16 Jan 2008 15:37:15 -0500
Subject: [PATCH] Fix 'make check' to use dmsetup built in DMDIR
Message-ID: <478E6AFB.30007@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

If DMDIR is specified in configuration script,
'make check' should use it to check DM_DEV_DIR support.

-- 
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
A non-text attachment was scrubbed...
Name: use-DMDIR-for-dmsetup.patch
Type: text/x-patch
Size: 406 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20080116/7b5d59b8/attachment.bin>
