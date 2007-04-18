From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Wed, 18 Apr 2007 15:32:58 -0400
Subject: [PATCH] LVM2: (2/2) Use dm_report filter
In-Reply-To: <46264BAC.3000504@ce.jp.nec.com>
References: <46264A57.1020800@ce.jp.nec.com> <46264BAC.3000504@ce.jp.nec.com>
Message-ID: <4626726A.3070002@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

This patch adds '--filter' option to reporting commands: lvs, vgs and pvs.

The patch depends on the following patches:
[PATCH] libdevmapper: (4/6) Add filtering feature to dm_report
https://www.redhat.com/archives/dm-devel/2007-April/msg00029.html
[PATCH] libdevmapper: (7/6) Add dm_report_get_report_types()
https://www.redhat.com/archives/dm-devel/2007-April/msg00035.html

Examples:

Find PVs used for VG vg0
# pvs --filter 'vg_name == "vg0"'

Find PVs not used by any LVs
# pvs --filter 'used == 0'

Find PVs satisfying both of the aboves
# pvs --filter 'vg_name == "vg0" && used == 0'

Find PVs not satisfying the above
# pvs --filter '! (vg_name == "vg0" && used == 0)'

Find VGs with more than 2 PVs and with more than 400 extents
# vgs --filter 'pv_count > 2 && free_count > 400'

Find active snapshot LVs
# lvs --filter 'attr =~ /^s...a/'

Find LVs using /dev/sdc
# lvs --filter 'devices =~ |/dev/sdc|'

..

Possible future enhancements:
  - Cope with units.
    I.e. lvs --filter 'size > 4G' to find LVs larger than 4GB
    Currently, the filter can handle only the raw value of the field.

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvm2-add-filter.patch
Type: text/x-patch
Size: 7144 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20070418/97908cf7/attachment.bin>
