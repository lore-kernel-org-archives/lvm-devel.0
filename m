From: Sandeep K Sinha <sandeepksinha@gmail.com>
Date: Fri, 20 Mar 2009 22:10:19 +0530
Subject: lvcreate -s - why specifying size for snapshot ?
In-Reply-To: <BADBA4B7-ADF9-4150-9AB7-44D3EEF6CC67@redhat.com>
References: <37d33d830903200847w45cee0b1xc973299627dead2f@mail.gmail.com>
	<49C3BFDF.1090900@redhat.com>
	<BADBA4B7-ADF9-4150-9AB7-44D3EEF6CC67@redhat.com>
Message-ID: <37d33d830903200940t753c52few9ec36b3e75d68a6f@mail.gmail.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Fri, Mar 20, 2009 at 9:48 PM, Jonathan Brassow <jbrassow@redhat.com> wrote:
>
> On Mar 20, 2009, at 11:10 AM, Bryn M. Reeves wrote:
>
>> -----BEGIN PGP SIGNED MESSAGE-----
>> Hash: SHA1
>>
>> Sandeep K Sinha wrote:
>>>
>>> Hi all,
>>> Disk
>>> After hunting for relevant documents and failing to find one.
>>> I would like to know if its not true that the size of the snapshot
>>> should be equal to the original volume?
>>> If so, then why do we accept size for a snapshot?
>>>
>>> Or Am I missing something somewhere else?
>>>
>>
>> The size of the snapshot governs the amount of space set aside for
>> storing the changes to the origin volume. E.g. if you made a snapshot
>> and then completely overwrote the origin the snapshot would have to be
>> at least as big as the origin volume to hold the changes.
>>
Agreed to all the explainations, but then I would like to know why am
I able to succeed in creating a snapshot > original volume.
LVM should puke an error for it right.

Or is our snapshot like a CDP? I dont thinks so.

IMO, extending lvm to have a block level CDP as a target should be a
good option.

>> You need to dimension a snapshot according to the expected level of
>> change. So for example a short-lived snapshot of a read-mostly volume,
>> e.g. /usr, would need less space than a long-lived snapshot of a volume
>> that sees a greater number of writes such as /home.
>>
>> Snapshots can be grown after they have been created but you need to make
>> sure they don't fill up. If this happens the snapshot will become
>> invalid (since it can no longer faithfully track changes on the origin
>> volume).
>
> Nice explanation! ?This should be placed in the LVM manual. ?I will notify
> the appropriate authorities. ?:)
>
> ?brassow
>
> --
> lvm-devel mailing list
> lvm-devel at redhat.com
> https://www.redhat.com/mailman/listinfo/lvm-devel
>



-- 
Regards,
Sandeep.





 	
?To learn is to change. Education is a process that changes the learner.?


