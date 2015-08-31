From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon, 31 Aug 2015 11:30:16 +0200
Subject: [PATCH] libdm-iface: not output error message inside retry loops
In-Reply-To: <55E48344020000A00001A162@relay2.provo.novell.com>
References: <1440664241-6149-1-git-send-email-lwang@suse.com>
	<55DEFB92.5020106@redhat.com>
	<55E03ED2020000A000019F1D@relay2.provo.novell.com>
	<55E034E8.3010908@redhat.com>
	<55E0D18A020000A00004DDE2@relay2.provo.novell.com>
	<55E04B67.3060003@redhat.com>
	<55E48344020000A00001A162@relay2.provo.novell.com>
Message-ID: <55E41EA8.4080604@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 31.8.2015 v 10:39 Liuhua Wang napsal(a):
> Hi Zdenek,
>
>>>> On 8/28/2015 at 07:52 PM, in message <55E04B67.3060003@redhat.com>, Zdenek
> Kabelac <zkabelac@redhat.com> wrote:
>> Dne 28.8.2015 v 13:24 Liuhua Wang napsal(a):
>>>
>>> Thanks for your reply.
>>>
>>>>> Common scenario:
>>>>>
>>>>> The major reason for retry is 'unpredictable'  udev event processing
>>>>> i.e. you run  'umount' -> fires watch-rule -> lvremove  could have failed -
>>>>> retry fixes this problem.
>>>>
>>>>>     We first found this problem when we were testing lvcreate-usage.sh
>> included in
>>>>>     lvm2-2.02.120 package. The case always failed due to the following
>> message:
>>>>>      device-mapper: remove ioctl on (253:6) failed: Device or resource busy
>>>>>     [ 0:01]   Node @TESTDIR@/dev/mapper/@PREFIX at vg-LV2-cow was not removed by
>> udev. Falling >>back to direct node removal.
>>>
>>>> Looks like udev issue.
>>> You mean udev cookie related problem? Because I see udev cookie add and
>> remove
>>> a little weird.
>>>
>>
>> So the question #1 -  are you using upstream lvm2 udev rules ?
>> (matching with install package)
>>
>> Are there any modification made to upsteam lvm2 udev rules?
>> (Debian is usually having problems with those)
>>
>> The rules are quite complex and any 'touch 'to them should be consulted with
>>
>> upstream authors.
> Yes, udev rules have been modified a little, but even I replace them all with
> upstream rules and reloaded, still has the issue.

I'm afraid full audit of your udev rules is necessary then.

Upstream is developed on Fedora - so rules are checked there.

If your system has different rules - then more careful check is needed.
(and it's btw reason why we show those errors)

>
>   # lvremove -ff vg/snap -vvvvv >lvremove-snap-failed.log 2>&1
>

vg-snap-cow  is resumed with:

DISABLE_SUBSYSTEM_RULES DISABLE_DISK_RULES DISABLE_OTHER_RULES 
DISABLE_LIBRARY_FALLBACK

these rule flag's normally ensure  udev will not even try to look on these 
volumes - however you get:

device-mapper: remove ioctl on (253:2) failed: Device or resource busy


So clearly something holds this open.

To trace out this case - you need to run 'udevd' in 'debug/verbose' mode
and capture which rule is accessing DM device  (since normally upstream udev
actually skips anything  'dm' related and only we provide rules accessing dm 
devices)

Udev tracing however slows down processing of udev rules so it might be 
trickier to capture error - but anyway - you should find out which rule
cause read of -cow volume - such volume should never be scanned by udev.

As a side note - I do plan to rewrite snapshot deactivation code - but it will 
take a while - this could would eliminate resume of -cow completely.

Regards

Zdenek





