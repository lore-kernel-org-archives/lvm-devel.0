From: Liuhua Wang <lwang@suse.com>
Date: Fri, 28 Aug 2015 05:24:26 -0600
Subject: [PATCH] libdm-iface: not output error message inside retry loops
In-Reply-To: <55E034E8.3010908@redhat.com>
References: <1440664241-6149-1-git-send-email-lwang@suse.com>
	<55DEFB92.5020106@redhat.com>
	<55E03ED2020000A000019F1D@relay2.provo.novell.com>
	<55E034E8.3010908@redhat.com>
Message-ID: <55E0D18A020000A00004DDE2@relay2.provo.novell.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Thanks for your reply.

>> Common scenario:
>>
>> The major reason for retry is 'unpredictable'  udev event processing
>> i.e. you run  'umount' -> fires watch-rule -> lvremove  could have failed -
>> retry fixes this problem.
>
>>   We first found this problem when we were testing lvcreate-usage.sh included in
>>   lvm2-2.02.120 package. The case always failed due to the following message:
>>    device-mapper: remove ioctl on (253:6) failed: Device or resource busy
>>   [ 0:01]   Node @TESTDIR@/dev/mapper/@PREFIX at vg-LV2-cow was not removed by udev. Falling >>back to direct node removal.

>Looks like udev issue.
You mean udev cookie related problem? Because I see udev cookie add and remove 
a little weird.

>
> >Then we tested more cases and found the problem occurs in the following cases:
>     >- lvremove/lvcreate a snap lv
>     >- lvremove/lvcreate a thin lv
>     >- lvremove/lvcreate a mirror lv
>
>> o Reproduce frequency:
>>     lvremove about 80%, lvcreate occurs occasionally
>
> >With the patch I attached, the lvcreate-usage.sh will not fail due to the error message.

>What is your system - is it Debian/Ubuntu?

>These tests depend on properly working udev rules.

We are using SuSE SLES12.
#udev version
 210

Regards,
Liuhua



