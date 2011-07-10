From: Peter Rajnoha <prajnoha@redhat.com>
Date: Sun, 10 Jul 2011 12:21:50 +0200
Subject: lvm2 2.02.86 error... udev problem?
In-Reply-To: <201107092228.44493.benscott@nwlink.com>
References: <201107092228.44493.benscott@nwlink.com>
Message-ID: <4E197D3E.3050300@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 07/10/2011 07:28 AM +0100, ben wrote:
> I just downloaded and compiled lvm2 2.02.86 and have seen the following error 
> message several times:
> 
> ~/# lvcreate --name test --mirrors 1 --size 1g vg01
>   /dev/mapper/vg01-test_mimage_0: open failed: No such file or directory
>   /dev/mapper/vg01-test: open failed: No such file or directory
>   /dev/vg01/test: not found: device not cleared
>   Aborting. Failed to wipe start of new LV.
>   LV vg01/test in use: not deactivating
>   Unable to deactivate failed new LV. Manual intervention required.
> 
> The volume is created despite the error message. Is this another udev issue? I 
> am running Debian Sid and udev 171-2.
> 

Can you please try that with 'verify_udev_operations=1' setting in lvm.conf
(in 'activation' section) and see if you get any warnings. Thanks.

Peter


