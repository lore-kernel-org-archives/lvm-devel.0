From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Fri, 12 Jan 2007 18:13:28 -0500
Subject: [PATCH] (1/4) dm_report support in libdevmapper
Message-ID: <45A81618.2080608@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

Attached patch adds dm_report API to libdevmapper.
The code is based on LVM2 lib/report with a enhancement
to option format (e.g. "name=a" to report objects whose
"name" field is "a") and generalizations.

I would like to use this from dmsetup to make "dmsetup info -c"
more flexible like LVM2 lvs/pvs/vgs commands.

Also, LVM2 can use this API instead of its own lib/report.

(Patches for dmsetup and LVM2 will follow.)

Comments are welcome.

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
A non-text attachment was scrubbed...
Name: 01-libdm-report.patch
Type: text/x-patch
Size: 33117 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20070112/6486edb7/attachment.bin>
