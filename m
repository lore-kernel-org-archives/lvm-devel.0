From: Petr Rockai <prockai@redhat.com>
Date: Wed, 03 Apr 2013 11:32:06 +0200
Subject: duplicate pv names
In-Reply-To: <20130402212408.GA1923@redhat.com> (David Teigland's message of
	"Tue, 2 Apr 2013 17:24:08 -0400")
References: <20130402212408.GA1923@redhat.com>
Message-ID: <87r4isklih.fsf@mornfall.net>
	(sfid-20130403_113207_733349_96E34192)
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

David Teigland <teigland@redhat.com> writes:
> My current patch set it having a problem with the test vgimportclone.sh,
> which has me questioning the desired pvs output with duplicate pv names.

I ran into similar problems with a different set of patches, that remove
pv_read. What I'll probably need to do is adding a list of devices to
PVs, so we can check whether something on the command line matches any
of the "duplicate" PVs.

I see you make quite heavy use of pv_read in your new version of
process_each_pv. You can have a look at:

(git clone) http://repos.mornfall.net/lvm2/mornfall.git

branch "merged" or for more limited view of the pv_read removal patches,
branch "lvmcache". (git checkout origin/merged).

It would be good if we could get rid of pv_read, as the code for
handling nomda PVs is wrong anyway, and we always need to scan. I think
the only remaining issue with the non-pv_read version is the duplicate
handling as outlined above.

Petr

-- 
id' Ash = Ash; id' Dust = Dust; id' _ = undefined


