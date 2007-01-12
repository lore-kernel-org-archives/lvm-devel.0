From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Fri, 12 Jan 2007 18:31:45 -0500
Subject: [PATCH] (2/4) dmsetup info to use dm_report
In-Reply-To: <45A81618.2080608@ce.jp.nec.com>
References: <45A81618.2080608@ce.jp.nec.com>
Message-ID: <45A81A61.4070401@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

This patch makes "dmsetup info -c" to use dm_report
in libdevmapper.

For example, to see what maps are overlaying on each map,

  # dmsetup info -c -o name,parents_count,parent_maps -O name
  Name               Parents Parent Maps
  B8-root                  0
  B9-root                  0
  d1                       2 testvg-m1_mimage_0,testvg-lvol2
  d2                       2 testvg-m1_mimage_1,testvg-lvol2
  d3                       1 testvg-lvol0-real
  d4                       2 testvg-lvol2,testvg-lvol0-real
  d5                       1 testvg-lvol1-cow
  d6                       1 testvg-lvol2
  d7                       1 testvg-m1_mlog
  testvg-lvol0             0
  testvg-lvol0-real        2 testvg-lvol1,testvg-lvol0
  testvg-lvol1             0
  testvg-lvol1-cow         1 testvg-lvol1
  testvg-lvol2             0
  testvg-m1                0
  testvg-m1_mimage_0       1 testvg-m1
  testvg-m1_mimage_1       1 testvg-m1
  testvg-m1_mlog           1 testvg-m1

Then, to see the top level map names,
  # dmsetup info -c -o name,-parents_count=0 --noheadings
  B9-root
  testvg-m1
  testvg-lvol2
  testvg-lvol1
  testvg-lvol0
  B8-root

Output of "dmsetup info -c" is basically same as the former version
except for a few spacing difference, which should be harmless.
  - Field width is correctly aligned (e.g. in case of long map name)
  - Trailing space is added to fill the width
    (same behaviour as LVM2 lvs/pvs/vgs)

Thanks,
--
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
A non-text attachment was scrubbed...
Name: 02-dmsetup-report.patch
Type: text/x-patch
Size: 17162 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20070112/47367b4c/attachment.bin>
