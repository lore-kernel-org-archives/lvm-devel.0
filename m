From: David Teigland <teigland@redhat.com>
Date: Wed, 7 Dec 2022 09:29:36 -0600
Subject: [PATCH] pvscan --cache /dev/xx needs to scan all disks and aliases when enable device filter
In-Reply-To: <971ecec87dad4fe2a1771f3c75c5cffb@huawei.com>
References: <971ecec87dad4fe2a1771f3c75c5cffb@huawei.com>
Message-ID: <20221207152936.GA12874@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, Dec 07, 2022 at 09:34:13AM +0000, wangzhiqiang (Q) wrote:
> When the system restarts and the disk goes online, the udev rule will be triggered to scan the metadata on
> the disk to automatically activate the logical volume, If we specify the scanned disk alias in lvm.conf, reject
> other unspecified disks, then lv cannot activate since the aliases mismatch with disk name.
> 
> If device filtering is configured in lvm.conf, then pvscan --cache /dev/xx needs to scan all disks and aliases

Hi, if I understand correctly, pvscan is already attempting to handle this
case.  See the use of "_filter_uses_symlinks" in pvscan.c.  Perhaps it
needs check for other symlink substrings?  The problem with your patch is
that it's a significant performance penalty for a common configuration.

Dave

