From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 14 Sep 2011 14:14:16 +0200
Subject: [PATCH] Retry dm device removal if busy
In-Reply-To: <6E8B2169-8A1D-4682-B02E-9CEA8D1B6835@redhat.com>
References: <4E6F6958.5020609@redhat.com>
	<6E8B2169-8A1D-4682-B02E-9CEA8D1B6835@redhat.com>
Message-ID: <4E709A98.8070404@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 13.9.2011 20:29, Jonathan Brassow napsal(a):
> Yes please!
> 
> All to often we come across this issue.  There are a number of bugs that are likely fixed by doing this change - even if it isn't academically perfect.
> 


Workaround is for 'external' tools cooperating with lvm.
lvm itself should work well without this hack.

(Thus I believe Petr should add lvm.conf option - and for buildbot this hack
should be disabled - so the internal bugs are clearly visible.)

Zdenek


>  brassow
> 
> On Sep 13, 2011, at 9:31 AM, Peter Rajnoha wrote:
> 
>> If a dm device is being opened in parallel while we're
>> trying to remove it, we'll end up with an error that
>> the device is busy. This is a legitimate error, but
>> with udev in play and asynchronous events generated
>> as a result of using the WATCH udev rule, we can get
>> into a situation where such failure is very unpleasant.
>>
>> Let's try the removal a few times then. Though this is
>> not a complete solution to the problem, let's use this
>> until we have one.
>>
>> Peter


