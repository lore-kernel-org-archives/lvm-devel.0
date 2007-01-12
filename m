From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Fri, 12 Jan 2007 18:32:09 -0500
Subject: [PATCH] (4/4) LVM2 to use dm_report
In-Reply-To: <45A81618.2080608@ce.jp.nec.com>
References: <45A81618.2080608@ce.jp.nec.com>
Message-ID: <45A81A79.8070307@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

This patch makes LVM2 to use dm_report in libdevmapper
instead of its lib/report functions.

Tested following commands where LVs of linear, striped, mirrored
and snapshot exist and confirmed the output is same with the
original LVM2 2.02.17.

  lvs
  pvs
  vgs
  lvs -a
  pvs -a
  lvs -a -o +devices
  lvs -o name,name,lv_name,vg_name
  lvs -a -o name,name,lv_name,vg_name
  lvs -a -o name,lv_name,vg_name -O name
  lvs -a -o name,lv_name,vg_name -O -name
  lvs -a -o name,lv_name,vg_name -O size
  lvs -a -o name,lv_name,vg_name -O lv_size
  lvs -a -o name,lv_name,vg_name -O -size
  pvs -o +pe_alloc_count,used,dev_size
  pvs -a -o +pe_alloc_count,used,dev_size

Thanks,
--
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
A non-text attachment was scrubbed...
Name: 04-lvm2-use-dm-report.patch
Type: text/x-patch
Size: 74176 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20070112/f4d39f00/attachment.bin>
