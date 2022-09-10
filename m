From: liuzhiqiang (I) <liuzhiqiang26@huawei.com>
Date: Sat, 10 Sep 2022 01:56:59 +0000
Subject: [PATCH] vgremove: PVID file leakage in /run/lvm/pvs_online
In-Reply-To: <20220909142734.GA23063@redhat.com>
References: <2cbbffed-1d4c-b351-d9e3-8218d8964a7b@huawei.com>,
 <20220909142734.GA23063@redhat.com>
Message-ID: <49411.122090922135500503@us-mta-519.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Thanks for your reply.
/run dir is mounted as tmpfs type, which has a setting inode number by systemd service. If the number of leakage pvid files increases with time, it may cause Deny of Service for other apps because cannot create files in /run.




????David Teigland <teigland@redhat.com>
????LVM2 development <lvm-devel@redhat.com>
????zkabelac <zkabelac@redhat.com>;linfeilong <linfeilong@huawei.com>;wuguanghao <wuguanghao3@huawei.com>;liuzhiqiang (I) <liuzhiqiang26@huawei.com>
????2022-09-09 22:27:45
????Re: [lvm-devel] [PATCH] vgremove: PVID file leakage in /run/lvm/pvs_online

On Thu, Sep 08, 2022 at 10:03:40PM +0800, miaoguanqin wrote:
> We found PVID file leakage problem when exec the following test;
> pvcreate /dev/sdb
> vgcreate -s 1M docker /dev/sdb
> lvcreate -L 10M docker
> pvscan --cache --listvg --checkcomplete --vgonline --udevoutput
> --journal=output /dev/sdb
> vgremove -ff docker
>
> pvcreate operation generates a new PVID, which is used to create PVID pvid
> file
> when exec pvcan. However vgremove does not delete the old PVID file.
>
> Here, we will delete all PVID files of each pv in current vg, when exec
> vgremove.

Hi, these files are located in tmpfs, so they will disappear automatically
when the system reboots. Is there a reason that you want remove them in
vgremove instead of waiting for reboot to remove them?

Dave


-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20220910/67b53b3a/attachment.htm>
