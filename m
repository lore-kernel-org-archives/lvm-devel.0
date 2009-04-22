From: Milan Broz <mbroz@redhat.com>
Date: Wed, 22 Apr 2009 19:43:25 +0200
Subject: [PATCH] lvconvert --repair
In-Reply-To: <8763hrf3fr.fsf@eriador.mornfall.net>
References: <87skn1p0jo.fsf@eriador.mornfall.net>	<498B2A94.7050105@redhat.com>
	<877i3y9od8.fsf@eriador.mornfall.net>	<87skmkc7q5.fsf@eriador.mornfall.net>
	<49CA4006.2010804@redhat.com> <8763hrf3fr.fsf@eriador.mornfall.net>
Message-ID: <49EF573D.2010407@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Petr Rockai wrote:
> Milan Broz <mbroz@redhat.com> writes:
>> please try this test - it tries to allocate new log - not sure if it is what we want,
>> but lvconvert fails but log lv is later visible, vg is still inconsistent
>> and I am confused what the correct state should be:-)
> The problem was that the code neglected to write out the consistent volume
> before trying to add new bits (which could obviously fail). The attached
> version of the patch fixes that (it also contains your test now).

Just minor things:
- some chunks (repairing vgreduce return code etc) are now already upstream
- there is also trivial merge problem, I am sure darcs merge code handle it:-)

- please check and remove some trailing whitespaces

- consider using vg->vgmem instead of cmd->mem - VG is locked
for the whole operation and failed PV list make sense only for that VG

- please add -i parameter to lvconvert in test script - it waits too long in tests

- add man page entry ;-)

Otherwise

Acked-by: Milan Broz <mbroz@redhat.com>

Milan


