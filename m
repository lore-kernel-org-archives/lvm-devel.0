From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 25 Sep 2014 10:37:00 +0200
Subject: [PATCH] pvcreate: check the label after writing
In-Reply-To: <5423C9A6.8000304@redhat.com>
References: <1411611632-2856-1-git-send-email-lzhong@suse.com>
	<5423C9A6.8000304@redhat.com>
Message-ID: <5423D42C.60106@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 25.9.2014 v 09:52 Zdenek Kabelac napsal(a):
> Dne 25.9.2014 v 04:20 Lidong Zhong napsal(a):
>> Some device will place metadata area at the beginning part and writing
>> label may fail.Take our test for example, when running pvcreate on a CDL
>> formatted DASD device(without partition), it shows successfully create
>> a pv, but the label is not written on the second sector and pvs shows
>> nothing. Although it is not supposed to run lvm on dasd device, it's a
>> friendly behavior to check the label and return error if it fails.
>
> Hmm - if device drive tells you - it has accepted and written some bytes
> on your storage device - they really should be written there.
>
> So IMHO driver should not lie and reject write request with error ?
>
> Otherwise you would need to validate every single written byte by LVM ?
>
> Maybe DASD devices should by automatically ignored by lvm filtering
> as unusable device for PV  (just like i.e. too small devices)

It looks like DASD device is somehow supported by 'parted'

And there are some very 'innovative' ways how to work with this device and 
detect where the write is actually allowed/supported.

So it seems like lvm2 would need to learn those bits on how to manipulate DASD 
devices.

And also tools like blkid then needs to look at proper places how to recognize 
such device's signature.

Anyway - the patch you've proposed is likely not valid.

Device driver for DASD should reject write attempt to privileged disk area 
with 'error'.

It would be probably fair to disable/ignore DASD device in lvm2 for now - 
since we clearly do not understand layout of this device and try to store PV 
header into wrong place - and someone needs to write handled for this devices 
to reenable support for it.

There is BZ http://bugzilla.redhat.com/show_bug.cgi?id=1058326
which is likely related to the same issue.

Zdenek


