From: Eric Ren <zren@suse.com>
Date: Wed, 31 May 2017 13:37:00 +0800
Subject: [PATCH] clvmd: try to refresh device cache on the first failure
In-Reply-To: <f531f11d-a36c-4c51-6713-bec5d55a7c9c@suse.com>
References: <20170524084519.12204-1-zren@suse.com>
	<dafc93b4-0f3b-57a5-9055-4c9409d8fcf0@redhat.com>
	<f531f11d-a36c-4c51-6713-bec5d55a7c9c@suse.com>
Message-ID: <14fb2bba-34b0-716e-7995-8f52626671a3@suse.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi Zdenek,


On 05/24/2017 05:45 PM, Eric Ren wrote:
> Hi!
>
> On 05/24/2017 04:59 PM, Zdenek Kabelac wrote:
>> Hi
>>
>> Looking at the patch header - it doesn't really look like solution 
>> for clustered problem clvmd cannot be resolve out-of-sync trouble of 
>> your cluster - it'd be likely masking serious problems elsewhere.
>
> Sorry, I should send this one as RFC instead:-)
>
>>
>> So could you please start with regular trouble report first - i.e. 
>> what do you mean by 'sometimes' ???
> This issue was first reported here:
> https://www.redhat.com/archives/lvm-devel/2017-May/msg00058.html
>
> I also record one way how to reproduce:
> https://asciinema.org/a/c62ica4ptxe94nw2s593yto4i
>
> By "sometimes", I meant the time when the device cache in clvmd is not 
> updated.
>
> It turns out I'm wrong in understanding the root cause of this 
> problem, after discussion with Alasdair on IRC.
> After I set "obtain_device_list_from_udev = 0" in lvm.conf, the 
> locking error disappeared, which means udev
> DB is not sync with device changes - MD device, isscsi device 
> according to my test.

I was cheated by setting "obtain_device_list_from_udev = 0", because in 
daemons/clvmd/lvm-functions.c :
do_lock_lv()
{
       if (!cmd->initialized.config || config_files_changed(cmd)) /* 
lvm.conf is changed when I firstly set obtain_device_list_from_udev */
            do_refresh_cache();   /* refresh device cache and metadata */
}

I attached a patch trying to fix this issue. Yes, this patch looks not 
neat. But, as of now, it's the best one I can think of.
Welcome review and feedback from you:-P

Regards,
Eric



-------------- next part --------------
A non-text attachment was scrubbed...
Name: 0001-pvscan-device-cache-in-clvmd-is-not-refreshed-as-nee.patch
Type: text/x-patch
Size: 3234 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20170531/46a3478e/attachment.bin>
