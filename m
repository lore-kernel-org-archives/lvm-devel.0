From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Thu, 13 Dec 2007 16:32:01 -0500
Subject: [PATCH lvconvert Appendix] Experimental: pvmove with disk log and seg-by-seg mirrored LV
In-Reply-To: <47619E84.2060905@ce.jp.nec.com>
References: <47619E84.2060905@ce.jp.nec.com>
Message-ID: <4761A4D1.2040904@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patch is experimental and just a proof-of-concept of new APIs.
(Some changes in lib were needed for adding pvmove support.)

Examples of commands and 'dmsetup ls --tree':
("/dev/mapper/d*" are PVs)

  Normal pvmove:
  # pvmove /dev/mapper/d1 /dev/mapper/d3 
    testvg-lvol2 (254:11)
     |-d2 (254:2)
     `-testvg-pvmove0 (254:13)
        |-d3 (254:3)
        `-d1 (254:1)
    testvg-lvol1 (254:10)
     `-testvg-pvmove0 (254:13)
        |-d3 (254:3)
        `-d1 (254:1)

  Disklog pvmove:
  # pvmove --mirrorlog disk /dev/mapper/d1 /dev/mapper/d3 /dev/mapper/d5:0-0
    testvg-lvol2 (254:11)
     |-d2 (254:2)
     `-testvg-pvmove0 (254:16)
        |-testvg-pvmove0_mimage_1 (254:15)
        |  `-d3 (254:3)
        |-testvg-pvmove0_mimage_0 (254:14)
        |  `-d1 (254:1)
        `-testvg-pvmove0_mlog (254:13)
           `-d5 (254:5)
    testvg-lvol1 (254:10)
     `-testvg-pvmove0 (254:16)
        |-testvg-pvmove0_mimage_1 (254:15)
        |  `-d3 (254:3)
        |-testvg-pvmove0_mimage_0 (254:14)
        |  `-d1 (254:1)
        `-testvg-pvmove0_mlog (254:13)
           `-d5 (254:5)

  Normal corelog mirror LV:
  # lvcreate -m1 -l1 --mirrorlog core testvg
    testvg-lvol0 (254:11)
     |-testvg-lvol0_mimage_1 (254:10)
     |  `-d2 (254:2)
     `-testvg-lvol0_mimage_0 (254:9)
        `-d1 (254:1)

  Seg-by-seg corelog mirror LV:
  # lvcreate -m1 -l1 --mirrorlog seg testvg
    testvg-lvol0 (254:9)
     |-d2 (254:2)
     `-d1 (254:1)

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
A non-text attachment was scrubbed...
Name: pvmove-disklog-option.patch
Type: text/x-patch
Size: 9942 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20071213/95d64619/attachment.bin>
