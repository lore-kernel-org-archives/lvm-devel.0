From: Jonathan Brassow <jbrassow@redhat.com>
Date: Fri, 20 Mar 2009 11:18:06 -0500
Subject: lvcreate -s - why specifying size for snapshot ?
In-Reply-To: <49C3BFDF.1090900@redhat.com>
References: <37d33d830903200847w45cee0b1xc973299627dead2f@mail.gmail.com>
	<49C3BFDF.1090900@redhat.com>
Message-ID: <BADBA4B7-ADF9-4150-9AB7-44D3EEF6CC67@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


On Mar 20, 2009, at 11:10 AM, Bryn M. Reeves wrote:

> -----BEGIN PGP SIGNED MESSAGE-----
> Hash: SHA1
>
> Sandeep K Sinha wrote:
>> Hi all,
>> Disk
>> After hunting for relevant documents and failing to find one.
>> I would like to know if its not true that the size of the snapshot
>> should be equal to the original volume?
>> If so, then why do we accept size for a snapshot?
>>
>> Or Am I missing something somewhere else?
>>
>
> The size of the snapshot governs the amount of space set aside for
> storing the changes to the origin volume. E.g. if you made a snapshot
> and then completely overwrote the origin the snapshot would have to be
> at least as big as the origin volume to hold the changes.
>
> You need to dimension a snapshot according to the expected level of
> change. So for example a short-lived snapshot of a read-mostly volume,
> e.g. /usr, would need less space than a long-lived snapshot of a  
> volume
> that sees a greater number of writes such as /home.
>
> Snapshots can be grown after they have been created but you need to  
> make
> sure they don't fill up. If this happens the snapshot will become
> invalid (since it can no longer faithfully track changes on the origin
> volume).

Nice explanation!  This should be placed in the LVM manual.  I will  
notify the appropriate authorities.  :)

  brassow


