From: David Teigland <teigland@redhat.com>
Date: Fri, 9 Sep 2022 09:27:34 -0500
Subject: [PATCH] vgremove: PVID file leakage in /run/lvm/pvs_online
In-Reply-To: <2cbbffed-1d4c-b351-d9e3-8218d8964a7b@huawei.com>
References: <2cbbffed-1d4c-b351-d9e3-8218d8964a7b@huawei.com>
Message-ID: <20220909142734.GA23063@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, Sep 08, 2022 at 10:03:40PM +0800, miaoguanqin wrote:
> We found PVID file leakage problem when exec the following test;
>  pvcreate /dev/sdb
>  vgcreate -s 1M docker /dev/sdb
>  lvcreate -L 10M docker
>  pvscan --cache --listvg --checkcomplete --vgonline --udevoutput
> --journal=output /dev/sdb
>  vgremove -ff docker
> 
> pvcreate operation generates a new PVID, which is used to create PVID pvid
> file
> when exec pvcan. However vgremove does not delete the old PVID file.
> 
> Here, we will delete all PVID files of each pv in current vg, when exec
> vgremove.

Hi, these files are located in tmpfs, so they will disappear automatically
when the system reboots.  Is there a reason that you want remove them in
vgremove instead of waiting for reboot to remove them?

Dave

