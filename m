From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Fri, 12 Jan 2007 18:31:58 -0500
Subject: [PATCH] (3/4) Remove old codes for "info -c" from dmsetup
In-Reply-To: <45A81618.2080608@ce.jp.nec.com>
References: <45A81618.2080608@ce.jp.nec.com>
Message-ID: <45A81A6E.9070309@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

This patch removes _display_info_cols*() functions used
for "dmsetup info -c" implementation.
These can be replaced by the new code using dm_report.

Thanks,
--
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
A non-text attachment was scrubbed...
Name: 03-dmsetup-remove-old-info-cols.patch
Type: text/x-patch
Size: 3171 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20070112/9672438d/attachment.bin>
