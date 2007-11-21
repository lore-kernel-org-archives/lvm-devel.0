From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Wed, 21 Nov 2007 16:28:02 -0500
Subject: [PATCH pvmove 2/3] support splitted destinations of pvmove
In-Reply-To: <4744A21E.7090601@ce.jp.nec.com>
References: <4744A21E.7090601@ce.jp.nec.com>
Message-ID: <4744A2E2.3070503@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Currently, pvmove can't split destination area.
This patch removes the restriction.
(Actually, a prepration for removing the restriction.)

If you have 1GB LV on a contiguous area of PV1
and would like to move it to 2 x 500MB PVs, PV2 and PV3,
you have to manually split the pvmove session into 2.

It's because pvmove assumes 1-1 relationship between
source area and destination area and forces a contiguous allocation.

This patch changes pvmove completion to split the original segment
to map to the destination areas.

Other patch ("3/3" of this series) allows allocation of splitted areas
for a single source area.

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvm2-pvmove-handle-splitted-area.patch
Type: text/x-patch
Size: 1772 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20071121/0f07c413/attachment.bin>
