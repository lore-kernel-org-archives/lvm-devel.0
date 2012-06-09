From: Milan Broz <mbroz@redhat.com>
Date: Sat, 09 Jun 2012 10:44:34 +0200
Subject: [linux-lvm] LVM release 2.02.96 / git / veritysetup
In-Reply-To: <20120609002308.GD15806@agk-dp.fab.redhat.com>
References: <20120609002308.GD15806@agk-dp.fab.redhat.com>
Message-ID: <4FD30CF2.8060505@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 06/09/2012 02:23 AM, Alasdair G Kergon wrote:
> veritysetup
> -----------
> Although this release contains a userspace tool for dm-verity,
>   configure --with-verity-setup=<cryptlib>
> we think the cryptsetup package would provide a better home for this
> so watch out for an updated version in an upcoming cryptsetup release.

Please do not use this version except for experiments and do not package
it in distributions yet.

Superblock format will perhaps change a little bit and also veritysetup utility
from cryptsetup source will use different command syntax (similar to dmsetup
and cryptsetup) and get full library support through libcryptsetup.

The code is maintained in separate veritysetup branch in cryptsetup git
for now, once it get back all features it will be merged to main branch (next week).
http://code.google.com/p/cryptsetup/source/browse/?name=veritysetup

Milan


