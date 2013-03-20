From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 20 Mar 2013 10:07:54 +0100
Subject: [PATCH] Pass parsed metadata to activation code.
In-Reply-To: <8738vrc634.fsf@mornfall.net>
	(sfid-20130320_003928_215503_2A328EE0)
References: <8738vrc634.fsf@mornfall.net>
	(sfid-20130320_003928_215503_2A328EE0)
Message-ID: <51497C6A.80500@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 20.3.2013 00:39, Petr Rockai napsal(a):
> Hi,
>
> the actual patches can be seen as follows:
>
> $ git clone http://repos.mornfall.net/lvm2/mornfall.git
> $ git checkout origin/mornfall
> $ git log 6a995ba..65718c8 -p
>

I've went into very quick overview - would it be possible to split some
patches into   'rename/clean old code'  'add new functionality' ?

Also - how does the new solution 'scales' in terms of having thousands of LVs 
in the metadata - I've noticed couple new linear scans 'dm_list_iterate()'. 
The trick with  lv_ondisk() code is not yet very clean to me - will need to 
find some time for this - it seems to be adding new complexity in the code.

Zdenek


