From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 25 Feb 2021 13:01:36 +0100
Subject: [PATCH LVM2 v1 1/2] blkdeactive: Introduce option "forcevg" to forcibly deactivate VG
In-Reply-To: <20210225110451.175956-1-leo.yan@linaro.org>
References: <20210225110451.175956-1-leo.yan@linaro.org>
Message-ID: <5ceaf113-7d5a-3a98-3937-f3e6b1406a14@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 25. 02. 21 v 12:04 Leo Yan napsal(a):
> From: Zhang Huan <zhanghuan@huayun.com>
> 
> This patch introduces new option "forcevg" for LVM, the main purpose is
> to flush in-flight I/O operations and replace the LV's device mapper
> table with 'error' target, this is accomplished by using command
> "dmsetup wipe_table".

Hi

For this moment - I'd prefer different solution in upstream.

We should first see what are the chance to support forcible deactivation
within lvm2 code directly.

This 'out-of-control' external logic may cause significant data loss breakages 
- as the external tools have not so good idea about connections between targets.

There need to be something like: vgchange -an --force --yes

tried first when the lvm2 'metadata' are present
and eventually support work with targets withot 'metadata' but
with  LVM-  uuid devices in the DM table.

Giving this to the hands of fairly naive script like blkdeactive isn't the 
right choice here.

Zdenek


