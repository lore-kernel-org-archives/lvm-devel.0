From: Somchai Smythe <buraphalinuxserver@gmail.com>
Date: Sat, 9 Jun 2012 18:00:42 +0700
Subject: [linux-lvm] LVM release 2.02.96 / git / veritysetup
In-Reply-To: <4FD30CF2.8060505@redhat.com>
References: <20120609002308.GD15806@agk-dp.fab.redhat.com>
	<4FD30CF2.8060505@redhat.com>
Message-ID: <CAFJqGkPHjaCXPq4zYxHp_koMwxbku0w=1W0wNznM_nEnpGaUGg@mail.gmail.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Do not package LVM release 2.02.96 at all, or just the verity stuff?

On 6/9/12, Milan Broz <mbroz@redhat.com> wrote:
> On 06/09/2012 02:23 AM, Alasdair G Kergon wrote:
>> veritysetup
>> -----------
>> Although this release contains a userspace tool for dm-verity,
>>   configure --with-verity-setup=<cryptlib>
>> we think the cryptsetup package would provide a better home for this
>> so watch out for an updated version in an upcoming cryptsetup release.
>
> Please do not use this version except for experiments and do not package
> it in distributions yet.
>
> Superblock format will perhaps change a little bit and also veritysetup
> utility
> from cryptsetup source will use different command syntax (similar to
> dmsetup
> and cryptsetup) and get full library support through libcryptsetup.
>
> The code is maintained in separate veritysetup branch in cryptsetup git
> for now, once it get back all features it will be merged to main branch
> (next week).
> http://code.google.com/p/cryptsetup/source/browse/?name=veritysetup
>
> Milan
>
> _______________________________________________
> linux-lvm mailing list
> linux-lvm at redhat.com
> https://www.redhat.com/mailman/listinfo/linux-lvm
> read the LVM HOW-TO at http://tldp.org/HOWTO/LVM-HOWTO/
>


