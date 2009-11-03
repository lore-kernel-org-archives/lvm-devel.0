From: Xinwei Hu <hxinwei@gmail.com>
Date: Tue, 3 Nov 2009 11:34:58 +0800
Subject: Re: [dm-devel] Segment fault in datastruct/hash.c
In-Reply-To: <20091103004850.GJ13375@agk-dp.fab.redhat.com>
References: <1cafab770910272052v4a9ec931v893b4925dd0e2e12@mail.gmail.com>
	<20091103004850.GJ13375@agk-dp.fab.redhat.com>
Message-ID: <1cafab770911021934q8106j73d871d79a644b9b@mail.gmail.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

2009/11/3 Alasdair G Kergon <agk@redhat.com>:
> On Wed, Oct 28, 2009 at 11:52:52AM +0800, Xinwei Hu wrote:
>> ? I generate a patch against the latest git tree. Please consider it
>> for inclusion.
>
> Applied.
>
>> --- a/libdm/datastruct/hash.c
>> +++ b/libdm/datastruct/hash.c
>> @@ -143,9 +143,13 @@ static struct dm_hash_node **_find(struct dm_hash_table *t, const char *key,
>
>> + ? ? ? ? ? ? if ((*c)->keylen != len)
>> + ? ? ? ? ? ? ? ? ? ? continue
> ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ?^
Sorry about that.
I copied tested patch into git manually at that time.
Thought it's too simple to make a mistake, but I'm wrong -_-!!

> (Did you try the patch?)
>
Yes, the original patch is tested and worked.
> Alasdair
>
>


