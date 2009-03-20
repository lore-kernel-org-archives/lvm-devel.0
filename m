From: Jonathan Brassow <jbrassow@redhat.com>
Date: Fri, 20 Mar 2009 12:12:57 -0500
Subject: lvcreate -s - why specifying size for snapshot ?
In-Reply-To: <37d33d830903200940t753c52few9ec36b3e75d68a6f@mail.gmail.com>
References: <37d33d830903200847w45cee0b1xc973299627dead2f@mail.gmail.com>
	<49C3BFDF.1090900@redhat.com>
	<BADBA4B7-ADF9-4150-9AB7-44D3EEF6CC67@redhat.com>
	<37d33d830903200940t753c52few9ec36b3e75d68a6f@mail.gmail.com>
Message-ID: <92D227CF-9560-4BE9-81AB-5276BA67F873@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


On Mar 20, 2009, at 11:40 AM, Sandeep K Sinha wrote:

> On Fri, Mar 20, 2009 at 9:48 PM, Jonathan Brassow  
> <jbrassow@redhat.com> wrote:
>>
>> On Mar 20, 2009, at 11:10 AM, Bryn M. Reeves wrote:
>>
>>> -----BEGIN PGP SIGNED MESSAGE-----
>>> Hash: SHA1
>>>
>>> Sandeep K Sinha wrote:
>>>>
>>>> Hi all,
>>>> Disk
>>>> After hunting for relevant documents and failing to find one.
>>>> I would like to know if its not true that the size of the snapshot
>>>> should be equal to the original volume?
>>>> If so, then why do we accept size for a snapshot?
>>>>
>>>> Or Am I missing something somewhere else?
>>>>
>>>
>>> The size of the snapshot governs the amount of space set aside for
>>> storing the changes to the origin volume. E.g. if you made a  
>>> snapshot
>>> and then completely overwrote the origin the snapshot would have  
>>> to be
>>> at least as big as the origin volume to hold the changes.
>>>
> Agreed to all the explainations, but then I would like to know why am
> I able to succeed in creating a snapshot > original volume.
> LVM should puke an error for it right.

You need to keep in mind that there will be some metadata associated  
with tracking blocks in the snapshot, so if you overwrote the entire  
origin, you would need 'snapshot > origin'.  Also, in the near future,  
multiple snapshots may share the same COW device... in which case you  
very well may need to create a 'snapshot > origin'.

Leaving out the subtleties, the first explanation is the best.

> Or is our snapshot like a CDP? I dont thinks so.

Snapshots might be a part of an overall CDP (continuous data  
protection) system, but not a CDP by itself.

  brassow


