From: Peter Rajnoha <prajnoha@redhat.com>
Date: Mon, 11 Jul 2011 09:06:33 +0200
Subject: lvm2 2.02.86 error... udev problem?
In-Reply-To: <201107101210.41505.benscott@nwlink.com>
References: <201107092228.44493.benscott@nwlink.com>	<4E197D3E.3050300@redhat.com>
	<201107101210.41505.benscott@nwlink.com>
Message-ID: <4E1AA0F9.9000301@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 07/10/2011 09:10 PM +0100, ben wrote:
> On Sunday, July 10, 2011 03:21:50 AM Peter Rajnoha wrote:
>> verify_udev_operations=1
> 
> That seems to help. Now I get this message:
> 
> # lvcreate  --name test --mirrors 1 --size 1g vg01
>   /dev/mapper/vg01-test_mimage_0 not set up by udev: Falling back to direct 
> node creation.
>   /dev/mapper/vg01-test not set up by udev: Falling back to direct node 
> creation.
>   The link /dev/vg01/test should had been created by udev but it was not 
> found. Falling back to direct link creation.
>   Logical volume "test" created

This normally means that udev rules are wrong. Have you also installed
upstream udev rules? (10-dm.rules, 11-dm-lvm.rules, 13-dm-disk.rules and
95-dm-notify.rules in /lib/udev/rules.d directory)

Debian has modified upstream udev rules a bit so there's a possibility
that this is the source of the problem you see (debian udev rules are
renamed: 55-dm.rules, 60-persistent-storage-dm.rules, 56-lvm.rules,
60-persistent-storage-lvm.rules).

Please, try using upstream udev rules directly and also be sure that
Debian and upstream udev rules are not installed together.

Peter


