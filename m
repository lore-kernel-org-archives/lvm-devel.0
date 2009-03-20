From: Bryn M. Reeves <bmr@redhat.com>
Date: Fri, 20 Mar 2009 17:33:03 +0000
Subject: lvcreate -s - why specifying size for snapshot ?
In-Reply-To: <49C3CD3D.3000002@redhat.com>
References: <37d33d830903200847w45cee0b1xc973299627dead2f@mail.gmail.com>	<49C3BFDF.1090900@redhat.com>	<BADBA4B7-ADF9-4150-9AB7-44D3EEF6CC67@redhat.com>	<37d33d830903200940t753c52few9ec36b3e75d68a6f@mail.gmail.com>
	<49C3CD3D.3000002@redhat.com>
Message-ID: <49C3D34F.2050808@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Bryn M. Reeves wrote:
> Sandeep K Sinha wrote:
>> On Fri, Mar 20, 2009 at 9:48 PM, Jonathan Brassow <jbrassow@redhat.com> wrote:
>>> On Mar 20, 2009, at 11:10 AM, Bryn M. Reeves wrote:
>>>
>>>> -----BEGIN PGP SIGNED MESSAGE-----
>>>> Hash: SHA1
>>>>
>>>> Sandeep K Sinha wrote:
>>>>> Hi all,
>>>>> Disk
>>>>> After hunting for relevant documents and failing to find one.
>>>>> I would like to know if its not true that the size of the snapshot
>>>>> should be equal to the original volume?
>>>>> If so, then why do we accept size for a snapshot?
>>>>>
>>>>> Or Am I missing something somewhere else?
>>>>>
>>>> The size of the snapshot governs the amount of space set aside for
>>>> storing the changes to the origin volume. E.g. if you made a snapshot
>>>> and then completely overwrote the origin the snapshot would have to be
>>>> at least as big as the origin volume to hold the changes.
>>>>
>> Agreed to all the explainations, but then I would like to know why am
>> I able to succeed in creating a snapshot > original volume.
>> LVM should puke an error for it right.
> 
> Not at all - going back to the original example: suppose you created a
> snapshot and then completely overwrite the origin volume *twice*. Now
> the snapshot must be twice the size of the origin - one to hold the data
> that was originally on the origin and one to hold the data from the
> first overwrite.

Err, scratch that. LVM's snapshots don't behave like this (never did!
:). Not enough coffee..

Bryn.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)
Comment: Using GnuPG with Fedora - http://enigmail.mozdev.org

iEYEARECAAYFAknD0qIACgkQ6YSQoMYUY96OXwCeLcXJyXcYBN6IfVB8GloF2rtE
PusAoLYCSrxJ1u1OMaQuN+Va2drps/f2
=uxLF
-----END PGP SIGNATURE-----


