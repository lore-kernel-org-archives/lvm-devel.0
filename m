From: Eric Ren <zren@suse.com>
Date: Wed, 24 May 2017 17:45:01 +0800
Subject: [PATCH] clvmd: try to refresh device cache on the first failure
In-Reply-To: <dafc93b4-0f3b-57a5-9055-4c9409d8fcf0@redhat.com>
References: <20170524084519.12204-1-zren@suse.com>
	<dafc93b4-0f3b-57a5-9055-4c9409d8fcf0@redhat.com>
Message-ID: <f531f11d-a36c-4c51-6713-bec5d55a7c9c@suse.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi!

On 05/24/2017 04:59 PM, Zdenek Kabelac wrote:
> Dne 24.5.2017 v 10:45 Eric Ren napsal(a):
>> Sometimes, the device cache in clvmd could be out of date.
>> "clvmd -R" is invented for this issue. However, to run
>> "clvmd -R" manually is not convenient, because it's hard
>> to predict when device change would happen.
>>
>
> Hi
>
> Looking at the patch header - it doesn't really look like solution for clustered problem 
> clvmd cannot be resolve out-of-sync trouble of your cluster - it'd be likely masking 
> serious problems elsewhere.

Sorry, I should send this one as RFC instead:-)

>
> So could you please start with regular trouble report first - i.e. what do you mean by 
> 'sometimes' ???
This issue was first reported here:
https://www.redhat.com/archives/lvm-devel/2017-May/msg00058.html

I also record one way how to reproduce:
https://asciinema.org/a/c62ica4ptxe94nw2s593yto4i

By "sometimes", I meant the time when the device cache in clvmd is not updated.

It turns out I'm wrong in understanding the root cause of this problem, after discussion 
with Alasdair on IRC.
After I set "obtain_device_list_from_udev = 0" in lvm.conf, the locking error disappeared, 
which means udev
DB is not sync with device changes - MD device, isscsi device according to my test.

"
[root at centos1 loopdevs]# vgchange -ay testvg
   Error locking on node 1: Volume group for uuid not found: 
wYiWFAj64kucp3e7lgC5m9xtDGFNfwA82tsvS3TzuhXiiLWMknlNpBw1yf5YfVjr
   0 logical volume(s) in volume group "testvg" now active
[root at centos1 loopdevs]# vi /etc/lvm/lvm.conf
[root at centos1 loopdevs]# vgchange -ay testvg
   1 logical volume(s) in volume group "testvg" now active
"

So, I was working on the wrong direction. Thanks for your guys' help!

Regards,
Eric

>
> Regard
>
> Zdene
>
> -- 
> lvm-devel mailing list
> lvm-devel at redhat.com
> https://www.redhat.com/mailman/listinfo/lvm-devel
>


