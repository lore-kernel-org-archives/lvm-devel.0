From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 31 May 2017 11:25:46 +0200
Subject: [PATCH] clvmd: try to refresh device cache on the first failure
In-Reply-To: <14fb2bba-34b0-716e-7995-8f52626671a3@suse.com>
References: <20170524084519.12204-1-zren@suse.com>
	<dafc93b4-0f3b-57a5-9055-4c9409d8fcf0@redhat.com>
	<f531f11d-a36c-4c51-6713-bec5d55a7c9c@suse.com>
	<14fb2bba-34b0-716e-7995-8f52626671a3@suse.com>
Message-ID: <1bf46b88-9b26-4437-446c-25e879b3ac3a@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 31.5.2017 v 07:37 Eric Ren napsal(a):
> Hi Zdenek,
> 
> 
> On 05/24/2017 05:45 PM, Eric Ren wrote:
>> Hi!
>>
>> On 05/24/2017 04:59 PM, Zdenek Kabelac wrote:
>>> Hi
>>>
>>> Looking at the patch header - it doesn't really look like solution for 
>>> clustered problem clvmd cannot be resolve out-of-sync trouble of your 
>>> cluster - it'd be likely masking serious problems elsewhere.
>>
>> Sorry, I should send this one as RFC instead:-)
>>
>>>
>>> So could you please start with regular trouble report first - i.e. what do 
>>> you mean by 'sometimes' ???
>> This issue was first reported here:
>> https://www.redhat.com/archives/lvm-devel/2017-May/msg00058.html
>>
>> I also record one way how to reproduce:
>> https://asciinema.org/a/c62ica4ptxe94nw2s593yto4i
>>
>> By "sometimes", I meant the time when the device cache in clvmd is not updated.
>>
>> It turns out I'm wrong in understanding the root cause of this problem, 
>> after discussion with Alasdair on IRC.
>> After I set "obtain_device_list_from_udev = 0" in lvm.conf, the locking 
>> error disappeared, which means udev
>> DB is not sync with device changes - MD device, isscsi device according to 
>> my test.
> 
> I was cheated by setting "obtain_device_list_from_udev = 0", because in 
> daemons/clvmd/lvm-functions.c :
> do_lock_lv()
> {
>        if (!cmd->initialized.config || config_files_changed(cmd)) /* lvm.conf 
> is changed when I firstly set obtain_device_list_from_udev */
>             do_refresh_cache();   /* refresh device cache and metadata */
> }
> 
> I attached a patch trying to fix this issue. Yes, this patch looks not neat. 
> But, as of now, it's the best one I can think of.
> Welcome review and feedback from you:-P

Hi  Eric

Your solution is still likely not a valid fix for your problem.

Targeted 'standard' case on modern udev-based system is - user is running lvm2 
with valid udevDB, thus 'obtain_device_list_from_udev = 1' works.

It's very bad idea to 'bypass' udev and run on system with udev and not having 
udevDB state reflecting reality of your system.

So looking at RHEL6 'doc' for clmvd:

https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/6/html/Logical_Volume_Manager_Administration/vgscan.html

When you normally add 'device' on system when obtain  is 0 (i.e. old RHEL6 
case with 'not so good udev') - admin is supposed to manually run 'vgscan'. 
The reason here is very simple - older system had some troubles with 'udev' DB 
validity - and the most 'fair' solution is to let admin decide when he really 
needs update the state. Doing so behind his back autonomously might 
significantly reduce performance of clvmd caching - since with frequent udev 
watch rule clvmd would be scanning permanently.

So back to your case - I'm not sure why do you still focusing on hacking clvmd 
where your main effort should be put into having 'udev' usable.

Once you get 'udev' working properly - you can start to use obtain.. == 1.

Then you run your: 'mdadm --assemble...'
Then likely  'udevadm  settle'  (as unfortunately mdadm is NOT cooperating 
with udev - so to be sure you md0 is known in udevDB  it's ATM upto admin to 
wait to be sure - complains about this should go to mdadm 'playground :)).

Then you run   'vgchange -ay'  - and clvmd should read devs from udev and see 
it and activate it.

So where in the above steps you see/have a problem?
Clvmd really can't be used to hack around bugs in other subsystems - it will 
simply not work too well..

Regards

Zdenek


